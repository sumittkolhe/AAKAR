"""
Autonomous Emotion Recognition Testing Pipeline - Auto-Tuner
============================================================
Automatically adjusts model parameters and triggers retraining.
"""

import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict

from pipeline_config import (
    EMOTION_LABELS, CNN_MODEL_PATH, SCRIPTS_DIR,
    TARGET_OVERALL_ACCURACY, TARGET_PER_EMOTION_ACCURACY, TARGET_CONFIDENCE_STABILITY,
    THRESHOLD_ADJUSTMENT_STEP, MIN_CONFIDENCE_THRESHOLD, MAX_CONFIDENCE_THRESHOLD,
    REWEIGHT_FACTOR_MIN, REWEIGHT_FACTOR_MAX, AUGMENT_THRESHOLD, AUGMENT_MULTIPLIER,
    REPORTS_DIR, get_results_path
)


@dataclass
class TuningAction:
    """A tuning action to be applied."""
    action_type: str  # "threshold_adjust", "class_reweight", "augment", "retrain"
    target: str  # Emotion or parameter name
    old_value: float
    new_value: float
    reason: str


@dataclass
class TuningState:
    """Current state of tuning parameters."""
    cycle_number: int
    confidence_thresholds: Dict[str, float]  # Per-emotion thresholds
    class_weights: Dict[str, float]
    augmentation_targets: List[str]
    last_accuracy: float
    history: List[Dict]  # Previous states


class AutoTuner:
    """
    Automatically tunes model parameters based on failure analysis.
    
    Implements:
    - Dynamic threshold adjustment
    - Class weight recalculation
    - Targeted augmentation triggers
    - Retraining orchestration
    """
    
    def __init__(self, cycle_number: int = 1):
        """
        Initialize the auto-tuner.
        
        Args:
            cycle_number: Current training cycle number
        """
        self.cycle_number = cycle_number
        self.state = self._load_or_init_state()
        self.actions: List[TuningAction] = []
        
    def _load_or_init_state(self) -> TuningState:
        """Load existing state or initialize new one."""
        state_path = REPORTS_DIR / "tuning_state.json"
        
        if state_path.exists():
            with open(state_path, "r") as f:
                data = json.load(f)
            return TuningState(
                cycle_number=self.cycle_number,
                confidence_thresholds=data.get("confidence_thresholds", 
                    {e: 0.75 for e in EMOTION_LABELS}),
                class_weights=data.get("class_weights", 
                    {e: 1.0 for e in EMOTION_LABELS}),
                augmentation_targets=data.get("augmentation_targets", []),
                last_accuracy=data.get("last_accuracy", 0.0),
                history=data.get("history", []),
            )
        else:
            return TuningState(
                cycle_number=self.cycle_number,
                confidence_thresholds={e: 0.75 for e in EMOTION_LABELS},
                class_weights={e: 1.0 for e in EMOTION_LABELS},
                augmentation_targets=[],
                last_accuracy=0.0,
                history=[],
            )
    
    def _save_state(self):
        """Save current tuning state."""
        state_path = REPORTS_DIR / "tuning_state.json"
        state_path.parent.mkdir(parents=True, exist_ok=True)
        
        data = {
            "cycle_number": self.state.cycle_number,
            "confidence_thresholds": self.state.confidence_thresholds,
            "class_weights": self.state.class_weights,
            "augmentation_targets": self.state.augmentation_targets,
            "last_accuracy": self.state.last_accuracy,
            "history": self.state.history,
        }
        
        with open(state_path, "w") as f:
            json.dump(data, f, indent=2)
    
    def load_results(self) -> Dict:
        """Load evaluation results for current cycle."""
        results_path = get_results_path(self.cycle_number)
        
        if not results_path.exists():
            raise FileNotFoundError(f"Results not found: {results_path}")
        
        with open(results_path, "r") as f:
            return json.load(f)
    
    def load_analysis(self) -> Optional[Dict]:
        """Load failure analysis for current cycle."""
        analysis_path = REPORTS_DIR / f"cycle_{self.cycle_number:03d}_analysis.json"
        
        if analysis_path.exists():
            with open(analysis_path, "r") as f:
                return json.load(f)
        return None
    
    def adjust_thresholds(self, results: Dict, analysis: Dict) -> List[TuningAction]:
        """
        Adjust confidence thresholds based on per-emotion performance.
        
        Args:
            results: Evaluation results
            analysis: Failure analysis
            
        Returns:
            List of threshold adjustment actions
        """
        actions = []
        per_emotion_acc = results.get("per_emotion_accuracy", {})
        
        for emotion in EMOTION_LABELS:
            acc = per_emotion_acc.get(emotion, 0.0)
            current_threshold = self.state.confidence_thresholds.get(emotion, 0.75)
            
            if acc < TARGET_PER_EMOTION_ACCURACY:
                # Lower threshold for underperforming emotions
                new_threshold = max(
                    MIN_CONFIDENCE_THRESHOLD,
                    current_threshold - THRESHOLD_ADJUSTMENT_STEP
                )
                
                if new_threshold != current_threshold:
                    actions.append(TuningAction(
                        action_type="threshold_adjust",
                        target=emotion,
                        old_value=current_threshold,
                        new_value=new_threshold,
                        reason=f"Accuracy {acc*100:.1f}% below target {TARGET_PER_EMOTION_ACCURACY*100:.0f}%",
                    ))
                    self.state.confidence_thresholds[emotion] = new_threshold
            
            elif acc > 0.95:
                # Raise threshold for very high-performing emotions
                new_threshold = min(
                    MAX_CONFIDENCE_THRESHOLD,
                    current_threshold + THRESHOLD_ADJUSTMENT_STEP
                )
                
                if new_threshold != current_threshold:
                    actions.append(TuningAction(
                        action_type="threshold_adjust",
                        target=emotion,
                        old_value=current_threshold,
                        new_value=new_threshold,
                        reason=f"High accuracy {acc*100:.1f}% - raising confidence bar",
                    ))
                    self.state.confidence_thresholds[emotion] = new_threshold
        
        return actions
    
    def recalculate_weights(self, results: Dict, analysis: Dict) -> List[TuningAction]:
        """
        Recalculate class weights based on performance.
        
        Args:
            results: Evaluation results
            analysis: Failure analysis
            
        Returns:
            List of reweighting actions
        """
        actions = []
        per_emotion_acc = results.get("per_emotion_accuracy", {})
        per_emotion_counts = results.get("per_emotion_counts", {})
        
        # Calculate target weights based on inverse accuracy
        # Lower accuracy = higher weight
        accuracy_values = list(per_emotion_acc.values())
        mean_acc = sum(accuracy_values) / len(accuracy_values) if accuracy_values else 0.5
        
        for emotion in EMOTION_LABELS:
            acc = per_emotion_acc.get(emotion, mean_acc)
            counts = per_emotion_counts.get(emotion, {})
            total = counts.get("total", 0)
            
            if total == 0:
                continue
            
            current_weight = self.state.class_weights.get(emotion, 1.0)
            
            # Calculate new weight based on inverse accuracy
            if acc > 0:
                # Weight inversely proportional to accuracy
                raw_weight = mean_acc / acc
                
                # Clamp to valid range
                new_weight = max(REWEIGHT_FACTOR_MIN, min(REWEIGHT_FACTOR_MAX, raw_weight))
                
                # Only update if significant change
                if abs(new_weight - current_weight) > 0.1:
                    actions.append(TuningAction(
                        action_type="class_reweight",
                        target=emotion,
                        old_value=current_weight,
                        new_value=new_weight,
                        reason=f"Accuracy {acc*100:.1f}%, adjusting weight to balance training",
                    ))
                    self.state.class_weights[emotion] = new_weight
        
        return actions
    
    def identify_augmentation_targets(self, results: Dict, analysis: Dict) -> List[TuningAction]:
        """
        Identify emotions and conditions needing augmentation.
        
        Args:
            results: Evaluation results
            analysis: Failure analysis
            
        Returns:
            List of augmentation actions
        """
        actions = []
        per_emotion_acc = results.get("per_emotion_accuracy", {})
        
        # Find emotions below augmentation threshold
        augment_targets = []
        
        for emotion in EMOTION_LABELS:
            acc = per_emotion_acc.get(emotion, 0.0)
            
            if acc < AUGMENT_THRESHOLD:
                if emotion not in self.state.augmentation_targets:
                    actions.append(TuningAction(
                        action_type="augment",
                        target=emotion,
                        old_value=0,
                        new_value=AUGMENT_MULTIPLIER,
                        reason=f"Accuracy {acc*100:.1f}% below {AUGMENT_THRESHOLD*100:.0f}% - needs more data",
                    ))
                    augment_targets.append(emotion)
        
        # Add weak conditions from analysis
        weak_conditions = analysis.get("weak_conditions", {}) if analysis else {}
        for dimension, categories in weak_conditions.items():
            for cat in categories:
                target = f"{dimension}:{cat}"
                if target not in self.state.augmentation_targets:
                    actions.append(TuningAction(
                        action_type="augment",
                        target=target,
                        old_value=0,
                        new_value=AUGMENT_MULTIPLIER,
                        reason=f"Weak performance in {dimension}={cat}",
                    ))
                    augment_targets.append(target)
        
        self.state.augmentation_targets = augment_targets
        
        return actions
    
    def should_retrain(self, results: Dict) -> Tuple[bool, str]:
        """
        Determine if model should be retrained.
        
        Args:
            results: Evaluation results
            
        Returns:
            Tuple of (should_retrain, reason)
        """
        overall_acc = results.get("overall_accuracy", 0)
        mean_conf = results.get("mean_confidence", 0)
        per_emotion_acc = results.get("per_emotion_accuracy", {})
        
        # Check if targets are met
        if overall_acc >= TARGET_OVERALL_ACCURACY:
            all_emotions_good = all(
                acc >= TARGET_PER_EMOTION_ACCURACY 
                for acc in per_emotion_acc.values()
            )
            if all_emotions_good and mean_conf >= TARGET_CONFIDENCE_STABILITY:
                return False, "All targets met"
        
        # Check if there's improvement potential
        if self.state.augmentation_targets:
            return True, f"Need to train on augmented data for: {', '.join(self.state.augmentation_targets[:3])}"
        
        # Check if weights have changed significantly
        weight_changed = any(
            abs(w - 1.0) > 0.2 
            for w in self.state.class_weights.values()
        )
        if weight_changed:
            return True, "Class weights adjusted significantly"
        
        # Default: retrain if not meeting targets
        if overall_acc < TARGET_OVERALL_ACCURACY:
            return True, f"Overall accuracy {overall_acc*100:.1f}% below target {TARGET_OVERALL_ACCURACY*100:.0f}%"
        
        return False, "No retraining needed"
    
    def tune(self) -> Dict:
        """
        Perform complete auto-tuning based on latest results.
        
        Returns:
            Dictionary with tuning summary
        """
        print("=" * 60)
        print(f"🔧 Auto-Tuning - Cycle {self.cycle_number}")
        print("=" * 60)
        
        # Load data
        results = self.load_results()
        analysis = self.load_analysis()
        
        # Perform tuning actions
        threshold_actions = self.adjust_thresholds(results, analysis)
        weight_actions = self.recalculate_weights(results, analysis)
        augment_actions = self.identify_augmentation_targets(results, analysis)
        
        self.actions = threshold_actions + weight_actions + augment_actions
        
        # Check for retraining
        should_retrain, retrain_reason = self.should_retrain(results)
        
        # Update state
        self.state.cycle_number = self.cycle_number
        self.state.last_accuracy = results.get("overall_accuracy", 0)
        self.state.history.append({
            "cycle": self.cycle_number,
            "accuracy": self.state.last_accuracy,
            "actions": len(self.actions),
            "timestamp": datetime.now().isoformat(),
        })
        
        # Save state
        self._save_state()
        
        # Generate summary
        summary = {
            "cycle_number": self.cycle_number,
            "actions_taken": len(self.actions),
            "threshold_adjustments": len(threshold_actions),
            "weight_adjustments": len(weight_actions),
            "augmentation_targets": len(augment_actions),
            "should_retrain": should_retrain,
            "retrain_reason": retrain_reason,
            "new_thresholds": self.state.confidence_thresholds,
            "new_weights": self.state.class_weights,
            "augmentation_targets": self.state.augmentation_targets,
        }
        
        # Save summary
        self._save_summary(summary)
        
        # Print summary
        self._print_summary(summary)
        
        return summary
    
    def _save_summary(self, summary: Dict):
        """Save tuning summary."""
        summary_path = REPORTS_DIR / f"cycle_{self.cycle_number:03d}_tuning.json"
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(summary_path, "w") as f:
            json.dump(summary, f, indent=2)
        
        print(f"💾 Tuning summary saved to: {summary_path}")
    
    def _print_summary(self, summary: Dict):
        """Print tuning summary."""
        print()
        print(f"📊 Tuning Summary")
        print(f"   Actions taken: {summary['actions_taken']}")
        print(f"   - Threshold adjustments: {summary['threshold_adjustments']}")
        print(f"   - Weight adjustments: {summary['weight_adjustments']}")
        print(f"   - Augmentation targets: {summary['augmentation_targets']}")
        print()
        
        if self.actions:
            print("📝 Actions Taken:")
            for action in self.actions[:10]:
                print(f"   • [{action.action_type}] {action.target}: {action.old_value:.2f} → {action.new_value:.2f}")
                print(f"     Reason: {action.reason}")
        
        print()
        print(f"🔄 Retrain: {'YES' if summary['should_retrain'] else 'NO'}")
        print(f"   Reason: {summary['retrain_reason']}")
        print("=" * 60)
    
    def get_augmentation_config(self) -> Dict:
        """
        Get configuration for targeted data augmentation.
        
        Returns:
            Dictionary with augmentation settings
        """
        return {
            "target_emotions": [t for t in self.state.augmentation_targets if ":" not in t],
            "target_conditions": {
                t.split(":")[0]: t.split(":")[1]
                for t in self.state.augmentation_targets if ":" in t
            },
            "multiplier": AUGMENT_MULTIPLIER,
        }
    
    def get_training_config(self) -> Dict:
        """
        Get configuration for model retraining.
        
        Returns:
            Dictionary with training settings
        """
        return {
            "class_weights": self.state.class_weights,
            "confidence_thresholds": self.state.confidence_thresholds,
            "learning_rate_adjustment": 0.9 if self.cycle_number > 1 else 1.0,
            "epochs": 10 if self.cycle_number > 1 else 20,  # Fewer epochs for fine-tuning
        }


if __name__ == "__main__":
    # Demo: Tune cycle 1
    tuner = AutoTuner(cycle_number=1)
    tuner.tune()
