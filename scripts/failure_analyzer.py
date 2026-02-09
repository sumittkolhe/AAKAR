"""
Autonomous Emotion Recognition Testing Pipeline - Failure Analyzer
==================================================================
Analyzes model failures, detects bias, and identifies improvement areas.
"""

import json
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict

from pipeline_config import (
    EMOTION_LABELS, DEMOGRAPHICS, ENVIRONMENTAL_VARIATIONS,
    CONFIDENCE_THRESHOLD, BIAS_THRESHOLD, TARGET_PER_EMOTION_ACCURACY,
    get_results_path, get_metadata_path, REPORTS_DIR
)


@dataclass
class ConfusedPair:
    """A pair of emotions that are frequently confused."""
    emotion_a: str
    emotion_b: str
    confusion_count: int
    percentage: float
    direction: str  # "a->b", "b->a", or "bidirectional"


@dataclass
class BiasReport:
    """Report on model bias across a demographic dimension."""
    dimension: str  # e.g., "skin_tone", "age_group"
    category_accuracies: Dict[str, float]
    max_accuracy: float
    min_accuracy: float
    max_category: str
    min_category: str
    bias_gap: float  # max - min
    is_biased: bool  # True if bias_gap > BIAS_THRESHOLD


@dataclass
class FailurePattern:
    """A detected pattern in model failures."""
    pattern_type: str
    description: str
    affected_samples: int
    percentage: float
    recommended_action: str


@dataclass
class FailureAnalysis:
    """Complete failure analysis for a cycle."""
    cycle_number: int
    confused_pairs: List[ConfusedPair]
    bias_reports: List[BiasReport]
    failure_patterns: List[FailurePattern]
    weak_emotions: List[str]
    weak_conditions: Dict[str, List[str]]  # {dimension: [weak_categories]}
    overall_health: str  # "good", "moderate", "poor"
    priority_improvements: List[str]


class FailureAnalyzer:
    """
    Analyzes model failures to identify weaknesses and biases.
    
    Performs:
    - Confusion matrix analysis
    - Bias detection across demographics
    - Failure pattern identification
    - Improvement prioritization
    """
    
    def __init__(self, cycle_number: int = 1):
        """
        Initialize the failure analyzer.
        
        Args:
            cycle_number: Current training cycle number
        """
        self.cycle_number = cycle_number
        self.results_data = None
        self.metadata_data = None
        
    def load_data(self) -> bool:
        """Load results and metadata for analysis."""
        results_path = get_results_path(self.cycle_number)
        metadata_path = get_metadata_path(self.cycle_number)
        
        if not results_path.exists():
            print(f"❌ Results not found: {results_path}")
            return False
        
        if not metadata_path.exists():
            print(f"❌ Metadata not found: {metadata_path}")
            return False
        
        with open(results_path, "r") as f:
            self.results_data = json.load(f)
        
        with open(metadata_path, "r") as f:
            self.metadata_data = json.load(f)
        
        return True
    
    def analyze_confusion(self) -> List[ConfusedPair]:
        """
        Analyze confusion matrix to find commonly confused emotion pairs.
        
        Returns:
            List of ConfusedPair objects sorted by confusion count
        """
        confusion_matrix = self.results_data.get("confusion_matrix", {})
        confused_pairs = []
        
        # Find pairs with significant confusion
        processed = set()
        
        for true_emotion in EMOTION_LABELS:
            for pred_emotion in EMOTION_LABELS:
                if true_emotion == pred_emotion:
                    continue
                
                pair_key = tuple(sorted([true_emotion, pred_emotion]))
                if pair_key in processed:
                    continue
                processed.add(pair_key)
                
                # Get confusion counts in both directions
                a_to_b = confusion_matrix.get(true_emotion, {}).get(pred_emotion, 0)
                b_to_a = confusion_matrix.get(pred_emotion, {}).get(true_emotion, 0)
                
                total_confusion = a_to_b + b_to_a
                
                if total_confusion > 0:
                    # Calculate percentage of total samples
                    total_samples = self.results_data.get("total_samples", 1)
                    percentage = (total_confusion / total_samples) * 100
                    
                    # Determine direction
                    if a_to_b > b_to_a * 1.5:
                        direction = f"{true_emotion}->{pred_emotion}"
                    elif b_to_a > a_to_b * 1.5:
                        direction = f"{pred_emotion}->{true_emotion}"
                    else:
                        direction = "bidirectional"
                    
                    confused_pairs.append(ConfusedPair(
                        emotion_a=true_emotion,
                        emotion_b=pred_emotion,
                        confusion_count=total_confusion,
                        percentage=percentage,
                        direction=direction,
                    ))
        
        # Sort by confusion count
        confused_pairs.sort(key=lambda x: x.confusion_count, reverse=True)
        
        return confused_pairs[:10]  # Top 10 confused pairs
    
    def analyze_bias(self) -> List[BiasReport]:
        """
        Analyze model bias across demographic dimensions.
        
        Returns:
            List of BiasReport objects for each dimension
        """
        bias_reports = []
        
        # Get individual results and metadata images
        results = self.results_data.get("individual_results", [])
        images = {img["image_id"]: img for img in self.metadata_data.get("images", [])}
        
        # Dimensions to analyze
        dimensions = {
            "skin_tone": DEMOGRAPHICS["skin_tone"],
            "age_group": DEMOGRAPHICS["age_group"],
            "gender": DEMOGRAPHICS["gender"],
            "lighting_condition": ENVIRONMENTAL_VARIATIONS["lighting"],
            "head_pose": ENVIRONMENTAL_VARIATIONS["head_pose"],
        }
        
        for dimension, categories in dimensions.items():
            # Track accuracy per category
            category_stats = {cat: {"correct": 0, "total": 0} for cat in categories}
            
            for result in results:
                image_id = result.get("image_id")
                if image_id not in images:
                    continue
                
                img_meta = images[image_id]
                category = img_meta.get(dimension)
                
                if category and category in category_stats:
                    category_stats[category]["total"] += 1
                    if result.get("correct"):
                        category_stats[category]["correct"] += 1
            
            # Calculate accuracies
            category_accuracies = {}
            for cat, stats in category_stats.items():
                if stats["total"] > 0:
                    category_accuracies[cat] = stats["correct"] / stats["total"]
                else:
                    category_accuracies[cat] = 0.0
            
            if not category_accuracies:
                continue
            
            # Find max/min
            max_acc = max(category_accuracies.values())
            min_acc = min(category_accuracies.values())
            max_cat = max(category_accuracies, key=category_accuracies.get)
            min_cat = min(category_accuracies, key=category_accuracies.get)
            bias_gap = max_acc - min_acc
            
            bias_reports.append(BiasReport(
                dimension=dimension,
                category_accuracies=category_accuracies,
                max_accuracy=max_acc,
                min_accuracy=min_acc,
                max_category=max_cat,
                min_category=min_cat,
                bias_gap=bias_gap,
                is_biased=bias_gap > BIAS_THRESHOLD,
            ))
        
        # Sort by bias gap
        bias_reports.sort(key=lambda x: x.bias_gap, reverse=True)
        
        return bias_reports
    
    def detect_failure_patterns(self) -> List[FailurePattern]:
        """
        Detect common patterns in model failures.
        
        Returns:
            List of FailurePattern objects
        """
        patterns = []
        results = self.results_data.get("individual_results", [])
        total_samples = len(results)
        
        if total_samples == 0:
            return patterns
        
        # Pattern 1: Low confidence failures
        low_conf_failures = sum(1 for r in results if r.get("failure_type") == "low_confidence")
        if low_conf_failures > 0:
            patterns.append(FailurePattern(
                pattern_type="low_confidence",
                description=f"Model shows low confidence (<{CONFIDENCE_THRESHOLD}) on {low_conf_failures} samples",
                affected_samples=low_conf_failures,
                percentage=(low_conf_failures / total_samples) * 100,
                recommended_action="Increase training data diversity or adjust confidence thresholds",
            ))
        
        # Pattern 2: Ambiguous predictions
        ambiguous = sum(1 for r in results if r.get("is_ambiguous"))
        if ambiguous > 0:
            patterns.append(FailurePattern(
                pattern_type="ambiguous",
                description=f"Model produces ambiguous predictions on {ambiguous} samples",
                affected_samples=ambiguous,
                percentage=(ambiguous / total_samples) * 100,
                recommended_action="Add more training data for distinguishing similar emotions",
            ))
        
        # Pattern 3: Consistent misclassification
        failure_breakdown = self.results_data.get("failure_breakdown", {})
        misclass = failure_breakdown.get("misclassification", 0)
        if misclass > total_samples * 0.1:  # > 10%
            patterns.append(FailurePattern(
                pattern_type="consistent_misclassification",
                description=f"High misclassification rate: {misclass} samples",
                affected_samples=misclass,
                percentage=(misclass / total_samples) * 100,
                recommended_action="Review confused emotion pairs and add discriminative training data",
            ))
        
        # Pattern 4: Detection failures
        no_detect = failure_breakdown.get("no_detection", 0)
        if no_detect > 0:
            patterns.append(FailurePattern(
                pattern_type="no_detection",
                description=f"Failed to detect faces in {no_detect} samples",
                affected_samples=no_detect,
                percentage=(no_detect / total_samples) * 100,
                recommended_action="Improve preprocessing or add face detection step",
            ))
        
        return patterns
    
    def identify_weak_areas(self) -> Tuple[List[str], Dict[str, List[str]]]:
        """
        Identify emotions and conditions that need improvement.
        
        Returns:
            Tuple of (weak_emotions, weak_conditions dict)
        """
        per_emotion_acc = self.results_data.get("per_emotion_accuracy", {})
        
        # Find weak emotions (below target)
        weak_emotions = [
            emotion for emotion, acc in per_emotion_acc.items()
            if acc < TARGET_PER_EMOTION_ACCURACY
        ]
        
        # Find weak conditions from bias reports
        weak_conditions = {}
        bias_reports = self.analyze_bias()
        
        for report in bias_reports:
            if report.is_biased:
                # Find categories significantly below average
                avg_acc = sum(report.category_accuracies.values()) / len(report.category_accuracies)
                weak_cats = [
                    cat for cat, acc in report.category_accuracies.items()
                    if acc < avg_acc - 0.1  # 10% below average
                ]
                if weak_cats:
                    weak_conditions[report.dimension] = weak_cats
        
        return weak_emotions, weak_conditions
    
    def calculate_health(self) -> str:
        """
        Calculate overall model health.
        
        Returns:
            "good", "moderate", or "poor"
        """
        overall_acc = self.results_data.get("overall_accuracy", 0)
        mean_conf = self.results_data.get("mean_confidence", 0)
        
        # Check per-emotion accuracy
        per_emotion_acc = self.results_data.get("per_emotion_accuracy", {})
        all_above_target = all(acc >= TARGET_PER_EMOTION_ACCURACY for acc in per_emotion_acc.values())
        
        if overall_acc >= 0.9 and mean_conf >= 0.8 and all_above_target:
            return "good"
        elif overall_acc >= 0.75 and mean_conf >= 0.6:
            return "moderate"
        else:
            return "poor"
    
    def get_priority_improvements(self) -> List[str]:
        """
        Get prioritized list of improvements needed.
        
        Returns:
            List of improvement recommendations
        """
        improvements = []
        
        weak_emotions, weak_conditions = self.identify_weak_areas()
        
        # Priority 1: Weak emotions
        if weak_emotions:
            improvements.append(f"Increase training data for: {', '.join(weak_emotions)}")
        
        # Priority 2: Bias issues
        bias_reports = self.analyze_bias()
        for report in bias_reports:
            if report.is_biased:
                improvements.append(
                    f"Address {report.dimension} bias: {report.min_category} "
                    f"({report.min_accuracy*100:.1f}%) vs {report.max_category} "
                    f"({report.max_accuracy*100:.1f}%)"
                )
        
        # Priority 3: Confused pairs
        confused = self.analyze_confusion()
        for pair in confused[:3]:  # Top 3
            if pair.percentage > 5:  # Significant confusion
                improvements.append(
                    f"Improve discrimination between {pair.emotion_a} and {pair.emotion_b} "
                    f"({pair.confusion_count} confusions)"
                )
        
        # Priority 4: Failure patterns
        patterns = self.detect_failure_patterns()
        for pattern in patterns:
            if pattern.percentage > 10:  # Significant pattern
                improvements.append(pattern.recommended_action)
        
        return improvements[:5]  # Top 5 improvements
    
    def analyze(self) -> FailureAnalysis:
        """
        Perform complete failure analysis.
        
        Returns:
            FailureAnalysis with all findings
        """
        print("=" * 60)
        print(f"🔍 Failure Analysis - Cycle {self.cycle_number}")
        print("=" * 60)
        
        if not self.load_data():
            raise RuntimeError("Failed to load data for analysis")
        
        # Run all analyses
        confused_pairs = self.analyze_confusion()
        bias_reports = self.analyze_bias()
        failure_patterns = self.detect_failure_patterns()
        weak_emotions, weak_conditions = self.identify_weak_areas()
        health = self.calculate_health()
        improvements = self.get_priority_improvements()
        
        analysis = FailureAnalysis(
            cycle_number=self.cycle_number,
            confused_pairs=confused_pairs,
            bias_reports=bias_reports,
            failure_patterns=failure_patterns,
            weak_emotions=weak_emotions,
            weak_conditions=weak_conditions,
            overall_health=health,
            priority_improvements=improvements,
        )
        
        # Save analysis
        self._save_analysis(analysis)
        
        # Print summary
        self._print_summary(analysis)
        
        return analysis
    
    def _save_analysis(self, analysis: FailureAnalysis):
        """Save analysis to file."""
        analysis_path = REPORTS_DIR / f"cycle_{self.cycle_number:03d}_analysis.json"
        analysis_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Convert to serializable format
        data = {
            "cycle_number": analysis.cycle_number,
            "confused_pairs": [asdict(p) for p in analysis.confused_pairs],
            "bias_reports": [asdict(r) for r in analysis.bias_reports],
            "failure_patterns": [asdict(p) for p in analysis.failure_patterns],
            "weak_emotions": analysis.weak_emotions,
            "weak_conditions": analysis.weak_conditions,
            "overall_health": analysis.overall_health,
            "priority_improvements": analysis.priority_improvements,
        }
        
        with open(analysis_path, "w") as f:
            json.dump(data, f, indent=2)
        
        print(f"💾 Analysis saved to: {analysis_path}")
    
    def _print_summary(self, analysis: FailureAnalysis):
        """Print analysis summary."""
        print()
        print(f"📊 Model Health: {analysis.overall_health.upper()}")
        print()
        
        print("🎭 Confused Emotion Pairs:")
        for pair in analysis.confused_pairs[:5]:
            print(f"  • {pair.emotion_a} ↔ {pair.emotion_b}: {pair.confusion_count} ({pair.percentage:.1f}%)")
        
        print()
        print("⚖️ Bias Analysis:")
        for report in analysis.bias_reports[:3]:
            status = "⚠️ BIASED" if report.is_biased else "✅ OK"
            print(f"  • {report.dimension}: {status} (gap: {report.bias_gap*100:.1f}%)")
        
        print()
        print("😟 Weak Emotions:")
        if analysis.weak_emotions:
            print(f"  {', '.join(analysis.weak_emotions)}")
        else:
            print("  None - all emotions performing well!")
        
        print()
        print("🎯 Priority Improvements:")
        for i, improvement in enumerate(analysis.priority_improvements, 1):
            print(f"  {i}. {improvement}")
        
        print("=" * 60)


if __name__ == "__main__":
    # Demo: Analyze cycle 1
    analyzer = FailureAnalyzer(cycle_number=1)
    analyzer.analyze()
