"""
Autonomous Emotion Recognition Testing Pipeline - Main Loop Controller
======================================================================
Orchestrates the complete autonomous testing and tuning pipeline.
"""

import json
import sys
import argparse
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from pipeline_config import (
    EMOTION_LABELS, DEMO_MODE, get_images_per_emotion,
    TARGET_OVERALL_ACCURACY, TARGET_PER_EMOTION_ACCURACY, TARGET_CONFIDENCE_STABILITY,
    MAX_CYCLES, PLATEAU_CYCLES, PLATEAU_THRESHOLD,
    get_final_report_path, ensure_directories, REPORTS_DIR
)
from data_generator import DataGenerator
from model_evaluator import ModelEvaluator
from failure_analyzer import FailureAnalyzer
from auto_tuner import AutoTuner


class CycleMetrics:
    """Tracks metrics across training cycles."""
    
    def __init__(self):
        self.history: List[Dict] = []
    
    def add_cycle(self, cycle_number: int, results: Dict, tuning: Dict):
        """Add metrics from a completed cycle."""
        self.history.append({
            "cycle": cycle_number,
            "timestamp": datetime.now().isoformat(),
            "overall_accuracy": results.get("overall_accuracy", 0),
            "mean_confidence": results.get("mean_confidence", 0),
            "per_emotion_accuracy": results.get("per_emotion_accuracy", {}),
            "actions_taken": tuning.get("actions_taken", 0),
            "should_retrain": tuning.get("should_retrain", False),
        })
    
    def get_improvement(self) -> float:
        """Get accuracy improvement from last cycle."""
        if len(self.history) < 2:
            return 1.0  # First cycle always counts as improvement
        
        current = self.history[-1]["overall_accuracy"]
        previous = self.history[-2]["overall_accuracy"]
        
        return current - previous
    
    def is_plateaued(self) -> bool:
        """Check if performance has plateaued."""
        if len(self.history) < PLATEAU_CYCLES:
            return False
        
        recent = self.history[-PLATEAU_CYCLES:]
        improvements = []
        
        for i in range(1, len(recent)):
            diff = recent[i]["overall_accuracy"] - recent[i-1]["overall_accuracy"]
            improvements.append(abs(diff))
        
        # Plateaued if all recent improvements are below threshold
        return all(imp < PLATEAU_THRESHOLD for imp in improvements)
    
    def targets_met(self) -> bool:
        """Check if all performance targets are met."""
        if not self.history:
            return False
        
        latest = self.history[-1]
        
        # Check overall accuracy
        if latest["overall_accuracy"] < TARGET_OVERALL_ACCURACY:
            return False
        
        # Check per-emotion accuracy
        per_emotion = latest["per_emotion_accuracy"]
        if not all(acc >= TARGET_PER_EMOTION_ACCURACY for acc in per_emotion.values()):
            return False
        
        # Check confidence
        if latest["mean_confidence"] < TARGET_CONFIDENCE_STABILITY:
            return False
        
        return True


class MainLoopController:
    """
    Orchestrates the complete autonomous testing and tuning pipeline.
    
    Runs the Generate → Test → Analyze → Tune → Retrain loop
    until performance targets are met or plateau is detected.
    """
    
    def __init__(self, demo_mode: bool = True, max_images_per_emotion: int = None):
        """
        Initialize the main loop controller.
        
        Args:
            demo_mode: If True, run with reduced data for testing
            max_images_per_emotion: Override for images per emotion
        """
        self.demo_mode = demo_mode
        self.max_images = max_images_per_emotion
        self.metrics = CycleMetrics()
        self.current_cycle = 0
        self.start_time = None
        self.end_time = None
        
        # Override config if needed
        if max_images_per_emotion:
            import pipeline_config
            pipeline_config.DEMO_IMAGES_PER_EMOTION = max_images_per_emotion
    
    def run_cycle(self, cycle_number: int) -> Tuple[Dict, Dict, Dict]:
        """
        Run a single cycle of the pipeline.
        
        Args:
            cycle_number: Current cycle number
            
        Returns:
            Tuple of (generation_stats, evaluation_results, tuning_summary)
        """
        print()
        print("╔" + "═" * 58 + "╗")
        print(f"║{'CYCLE ' + str(cycle_number):^58}║")
        print("╚" + "═" * 58 + "╝")
        print()
        
        # Phase 1: Data Generation
        print("▶ PHASE 1: DATA GENERATION")
        generator = DataGenerator(cycle_number=cycle_number)
        
        # Check if we need targeted generation
        if cycle_number > 1:
            tuner = AutoTuner(cycle_number=cycle_number - 1)
            aug_config = tuner.get_augmentation_config()
            
            if aug_config["target_emotions"]:
                print(f"  Targeting weak emotions: {aug_config['target_emotions']}")
                generator.generate_targeted(
                    aug_config["target_emotions"],
                    aug_config["multiplier"]
                )
            else:
                generator.generate_all_emotions()
        else:
            generator.generate_all_emotions()
        
        generation_stats = generator.generation_stats
        
        # Phase 2: Model Evaluation
        print()
        print("▶ PHASE 2: MODEL EVALUATION")
        evaluator = ModelEvaluator(cycle_number=cycle_number)
        results = evaluator.evaluate_cycle()
        evaluation_results = {
            "overall_accuracy": results.overall_accuracy,
            "per_emotion_accuracy": results.per_emotion_accuracy,
            "mean_confidence": results.mean_confidence,
            "mean_latency_ms": results.mean_latency_ms,
            "failure_breakdown": results.failure_breakdown,
            "confusion_matrix": results.confusion_matrix,
        }
        
        # Phase 3: Failure Analysis
        print()
        print("▶ PHASE 3: FAILURE ANALYSIS")
        analyzer = FailureAnalyzer(cycle_number=cycle_number)
        analysis = analyzer.analyze()
        
        # Phase 4: Auto-Tuning
        print()
        print("▶ PHASE 4: AUTO-TUNING")
        tuner = AutoTuner(cycle_number=cycle_number)
        tuning_summary = tuner.tune()
        
        # Track metrics
        self.metrics.add_cycle(cycle_number, evaluation_results, tuning_summary)
        
        return generation_stats, evaluation_results, tuning_summary
    
    def check_termination(self) -> Tuple[bool, str]:
        """
        Check if the loop should terminate.
        
        Returns:
            Tuple of (should_terminate, reason)
        """
        # Check cycle limit
        if self.current_cycle >= MAX_CYCLES:
            return True, f"Maximum cycles ({MAX_CYCLES}) reached"
        
        # Check if targets are met
        if self.metrics.targets_met():
            return True, "All performance targets achieved!"
        
        # Check for plateau
        if self.metrics.is_plateaued():
            return True, f"Performance plateaued for {PLATEAU_CYCLES} consecutive cycles"
        
        return False, ""
    
    def generate_final_report(self) -> Dict:
        """
        Generate the final summary report.
        
        Returns:
            Final report dictionary
        """
        latest = self.metrics.history[-1] if self.metrics.history else {}
        
        # Calculate confusion matrix summary
        confusion_summary = self._summarize_confusion()
        
        # Generate bias report summary
        bias_summary = self._summarize_bias()
        
        report = {
            "execution_summary": {
                "start_time": self.start_time,
                "end_time": self.end_time,
                "total_cycles": self.current_cycle,
                "mode": "DEMO" if self.demo_mode else "PRODUCTION",
            },
            "final_accuracy": latest.get("overall_accuracy", 0),
            "per_emotion_accuracy": latest.get("per_emotion_accuracy", {}),
            "mean_confidence": latest.get("mean_confidence", 0),
            "confusion_matrix_summary": confusion_summary,
            "bias_report": bias_summary,
            "model_ready_status": self.metrics.targets_met(),
            "cycle_history": self.metrics.history,
        }
        
        return report
    
    def _summarize_confusion(self) -> Dict:
        """Summarize confusion patterns across cycles."""
        try:
            # Load latest analysis
            analysis_path = REPORTS_DIR / f"cycle_{self.current_cycle:03d}_analysis.json"
            if analysis_path.exists():
                with open(analysis_path, "r") as f:
                    analysis = json.load(f)
                
                confused_pairs = analysis.get("confused_pairs", [])[:5]
                return {
                    "top_confused_pairs": [
                        f"{p['emotion_a']} <-> {p['emotion_b']}: {p['confusion_count']}"
                        for p in confused_pairs
                    ],
                    "most_confused": confused_pairs[0] if confused_pairs else None,
                }
        except Exception as e:
            print(f"Warning: Could not summarize confusion: {e}")
        
        return {"top_confused_pairs": [], "most_confused": None}
    
    def _summarize_bias(self) -> Dict:
        """Summarize bias findings across cycles."""
        try:
            analysis_path = REPORTS_DIR / f"cycle_{self.current_cycle:03d}_analysis.json"
            if analysis_path.exists():
                with open(analysis_path, "r") as f:
                    analysis = json.load(f)
                
                bias_reports = analysis.get("bias_reports", [])
                biased = [r for r in bias_reports if r.get("is_biased")]
                
                return {
                    "dimensions_analyzed": len(bias_reports),
                    "biased_dimensions": [r["dimension"] for r in biased],
                    "worst_bias": biased[0] if biased else None,
                    "all_fair": len(biased) == 0,
                }
        except Exception as e:
            print(f"Warning: Could not summarize bias: {e}")
        
        return {"dimensions_analyzed": 0, "biased_dimensions": [], "all_fair": True}
    
    def run(self) -> Dict:
        """
        Run the complete autonomous pipeline loop.
        
        Returns:
            Final report dictionary
        """
        print()
        print("╔" + "═" * 58 + "╗")
        print("║" + " " * 10 + "AUTONOMOUS EMOTION RECOGNITION TESTING" + " " * 9 + "║")
        print("║" + " " * 15 + "A.A.K.A.R PIPELINE v1.0" + " " * 20 + "║")
        print("╚" + "═" * 58 + "╝")
        print()
        print(f"Mode: {'DEMO' if self.demo_mode else 'PRODUCTION'}")
        print(f"Images per emotion: {get_images_per_emotion()}")
        print(f"Target accuracy: {TARGET_OVERALL_ACCURACY * 100:.0f}%")
        print(f"Max cycles: {MAX_CYCLES}")
        print(f"Plateau detection: {PLATEAU_CYCLES} cycles")
        print()
        
        self.start_time = datetime.now().isoformat()
        ensure_directories()
        
        try:
            while True:
                self.current_cycle += 1
                
                # Run cycle
                gen_stats, eval_results, tuning = self.run_cycle(self.current_cycle)
                
                # Check termination
                should_stop, reason = self.check_termination()
                
                print()
                print(f"📊 Cycle {self.current_cycle} Summary:")
                print(f"   Accuracy: {eval_results['overall_accuracy'] * 100:.1f}%")
                print(f"   Confidence: {eval_results['mean_confidence']:.3f}")
                print(f"   Improvement: {self.metrics.get_improvement() * 100:+.1f}%")
                
                if should_stop:
                    print()
                    print("🏁 " + reason)
                    break
                
                # Check if retraining is needed
                if not tuning.get("should_retrain", False):
                    print()
                    print("✅ No retraining needed, targets may be achievable with current model")
                    # Continue to next cycle with different data
                
                print()
                print("🔄 Continuing to next cycle...")
            
        except KeyboardInterrupt:
            print()
            print("⚠️ Pipeline interrupted by user")
        except Exception as e:
            print()
            print(f"❌ Pipeline error: {e}")
            raise
        
        self.end_time = datetime.now().isoformat()
        
        # Generate and save final report
        final_report = self.generate_final_report()
        report_path = get_final_report_path()
        
        with open(report_path, "w") as f:
            json.dump(final_report, f, indent=2)
        
        # Print final summary
        self._print_final_summary(final_report)
        
        return final_report
    
    def _print_final_summary(self, report: Dict):
        """Print the final summary."""
        print()
        print("╔" + "═" * 58 + "╗")
        print("║" + " " * 20 + "FINAL REPORT" + " " * 26 + "║")
        print("╚" + "═" * 58 + "╝")
        print()
        
        exec_summary = report.get("execution_summary", {})
        print(f"📅 Start: {exec_summary.get('start_time', 'N/A')}")
        print(f"📅 End: {exec_summary.get('end_time', 'N/A')}")
        print(f"🔄 Total cycles: {exec_summary.get('total_cycles', 0)}")
        print()
        
        print("📊 Final Performance:")
        print(f"   Overall Accuracy: {report.get('final_accuracy', 0) * 100:.1f}%")
        print(f"   Mean Confidence: {report.get('mean_confidence', 0):.3f}")
        print()
        
        print("🎭 Per-Emotion Accuracy:")
        for emotion, acc in report.get("per_emotion_accuracy", {}).items():
            status = "✅" if acc >= TARGET_PER_EMOTION_ACCURACY else "⚠️"
            print(f"   {status} {emotion}: {acc * 100:.1f}%")
        print()
        
        confusion = report.get("confusion_matrix_summary", {})
        print("🎭 Top Confused Pairs:")
        for pair in confusion.get("top_confused_pairs", [])[:3]:
            print(f"   • {pair}")
        print()
        
        bias = report.get("bias_report", {})
        if bias.get("all_fair", True):
            print("⚖️ Bias: ✅ No significant bias detected")
        else:
            print(f"⚖️ Bias: ⚠️ Bias detected in: {', '.join(bias.get('biased_dimensions', []))}")
        print()
        
        ready = report.get("model_ready_status", False)
        if ready:
            print("🚀 MODEL STATUS: ✅ READY FOR DEPLOYMENT")
        else:
            print("🚀 MODEL STATUS: ⚠️ NEEDS IMPROVEMENT")
        
        print()
        print("=" * 60)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Autonomous Emotion Recognition Testing Pipeline"
    )
    parser.add_argument(
        "--demo", 
        action="store_true",
        default=True,
        help="Run in demo mode with reduced data (default: True)"
    )
    parser.add_argument(
        "--production",
        action="store_true",
        help="Run in production mode with full data"
    )
    parser.add_argument(
        "--max-images-per-emotion",
        type=int,
        default=None,
        help="Override images per emotion count"
    )
    parser.add_argument(
        "--single-cycle",
        action="store_true",
        help="Run only a single cycle (for testing)"
    )
    
    args = parser.parse_args()
    
    # Determine mode
    demo_mode = not args.production
    
    # Override max cycles for single-cycle mode
    if args.single_cycle:
        import pipeline_config
        pipeline_config.MAX_CYCLES = 1
    
    # Run the pipeline
    controller = MainLoopController(
        demo_mode=demo_mode,
        max_images_per_emotion=args.max_images_per_emotion,
    )
    
    report = controller.run()
    
    # Return status code based on model readiness
    return 0 if report.get("model_ready_status", False) else 1


if __name__ == "__main__":
    sys.exit(main())
