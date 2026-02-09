"""
Autonomous Emotion Recognition Testing Pipeline - Model Evaluator
=================================================================
Evaluates the emotion recognition model against generated test data.
"""

import json
import time
import numpy as np
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict, field

from pipeline_config import (
    EMOTION_LABELS, CNN_MODEL_PATH, MODEL_INPUT_SHAPE,
    CONFIDENCE_THRESHOLD, get_results_path, get_metadata_path,
    AMBIGUITY_THRESHOLD, AMBIGUITY_PENALTY
)


@dataclass
class PredictionResult:
    """Result of a single model prediction."""
    image_id: str
    true_emotion: str
    predicted_emotion: str
    confidence: float
    all_probabilities: Dict[str, float]
    correct: bool
    failure_type: Optional[str]  # "misclassification", "low_confidence", "no_detection"
    latency_ms: float
    is_ambiguous: bool = False


@dataclass
class EvaluationResults:
    """Aggregated evaluation results for a cycle."""
    cycle_number: int
    total_samples: int
    correct_predictions: int
    overall_accuracy: float
    per_emotion_accuracy: Dict[str, float]
    per_emotion_counts: Dict[str, Dict[str, int]]  # {emotion: {correct: N, total: M}}
    mean_confidence: float
    mean_latency_ms: float
    failure_breakdown: Dict[str, int]
    confusion_matrix: Dict[str, Dict[str, int]]
    individual_results: List[Dict] = field(default_factory=list)


class ModelEvaluator:
    """
    Evaluates the emotion recognition model on generated data.
    
    Loads the TFLite model and runs inference on all generated images,
    collecting predictions, confidence scores, and latency metrics.
    """
    
    def __init__(self, cycle_number: int = 1):
        """
        Initialize the evaluator.
        
        Args:
            cycle_number: Current training cycle number
        """
        self.cycle_number = cycle_number
        self.model = None
        self.interpreter = None
        self.results: List[PredictionResult] = []
        
    def load_model(self) -> bool:
        """
        Load the TFLite model for inference.
        
        Returns:
            True if model loaded successfully, False otherwise
        """
        try:
            import tensorflow as tf
            
            if not CNN_MODEL_PATH.exists():
                print(f"❌ Model not found: {CNN_MODEL_PATH}")
                return False
            
            self.interpreter = tf.lite.Interpreter(model_path=str(CNN_MODEL_PATH))
            self.interpreter.allocate_tensors()
            
            # Get input/output details
            self.input_details = self.interpreter.get_input_details()
            self.output_details = self.interpreter.get_output_details()
            
            print(f"✅ Model loaded: {CNN_MODEL_PATH}")
            print(f"   Input shape: {self.input_details[0]['shape']}")
            print(f"   Output shape: {self.output_details[0]['shape']}")
            
            return True
            
        except ImportError:
            print("⚠️ TensorFlow not available, using mock predictions")
            return False
        except Exception as e:
            print(f"❌ Failed to load model: {e}")
            return False
    
    def _preprocess_image(self, image_path: str) -> Optional[np.ndarray]:
        """
        Preprocess an image for model input.
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Preprocessed numpy array or None if failed
        """
        try:
            from PIL import Image
            
            # For demo mode with placeholders, generate synthetic input
            if image_path.endswith(".json"):
                # This is a placeholder, generate random input
                return self._generate_synthetic_input(image_path)
            
            # Load and preprocess real image
            img = Image.open(image_path).convert('L')  # Grayscale
            img = img.resize((48, 48))
            
            # Normalize to 0-1
            img_array = np.array(img, dtype=np.float32) / 255.0
            
            # Add batch and channel dimensions: [1, 48, 48, 1]
            img_array = np.expand_dims(img_array, axis=-1)
            img_array = np.expand_dims(img_array, axis=0)
            
            return img_array
            
        except Exception as e:
            print(f"  ⚠️ Failed to preprocess image: {e}")
            return None
    
    def _generate_synthetic_input(self, metadata_path: str) -> np.ndarray:
        """
        Generate synthetic input based on metadata (for demo mode).
        
        Args:
            metadata_path: Path to the metadata JSON file
            
        Returns:
            Synthetic input array
        """
        # Load metadata to get the target emotion
        with open(metadata_path, "r") as f:
            metadata = json.load(f)
        
        emotion = metadata.get("metadata", {}).get("emotion_label", "Neutral")
        intensity = metadata.get("metadata", {}).get("intensity_level", 0.7)
        
        # Generate structured noise that's biased toward the correct emotion
        np.random.seed(hash(metadata_path) % (2**32))
        
        # Create base noise
        noise = np.random.randn(1, 48, 48, 1).astype(np.float32) * 0.3
        
        # Add emotion-specific patterns (simplified simulation)
        emotion_idx = EMOTION_LABELS.index(emotion) if emotion in EMOTION_LABELS else 0
        
        # Add some structure based on emotion
        pattern = np.zeros((48, 48), dtype=np.float32)
        if emotion in ["Happy", "Surprise"]:
            # Upward curves (smile-like patterns)
            pattern[30:40, 10:38] = 0.3
        elif emotion in ["Sad", "Fear"]:
            # Downward curves
            pattern[25:35, 10:38] = -0.2
        elif emotion in ["Angry", "Disgust"]:
            # Concentrated center
            pattern[15:35, 15:35] = 0.2
        
        noise[0, :, :, 0] += pattern * intensity
        
        # Normalize to 0-1 range
        noise = (noise - noise.min()) / (noise.max() - noise.min() + 1e-7)
        
        return noise
    
    def _run_inference(self, input_data: np.ndarray) -> Tuple[Dict[str, float], float]:
        """
        Run model inference on preprocessed input.
        
        Args:
            input_data: Preprocessed image array
            
        Returns:
            Tuple of (probability dict, latency in ms)
        """
        if self.interpreter is not None:
            # Real model inference
            start_time = time.perf_counter()
            
            self.interpreter.set_tensor(self.input_details[0]['index'], input_data)
            self.interpreter.invoke()
            output = self.interpreter.get_tensor(self.output_details[0]['index'])
            
            latency_ms = (time.perf_counter() - start_time) * 1000
            
            # Convert to probability dict
            probs = {}
            for i, label in enumerate(EMOTION_LABELS):
                probs[label] = float(output[0][i]) if i < len(output[0]) else 0.0
            
            # Apply softmax if needed
            probs = self._softmax(probs)
            
            return probs, latency_ms
        else:
            # Mock inference for demo
            return self._mock_inference(input_data)
    
    def _mock_inference(self, input_data: np.ndarray) -> Tuple[Dict[str, float], float]:
        """
        Generate mock predictions for demo mode.
        
        Args:
            input_data: Input data (used for seeding)
            
        Returns:
            Tuple of (probability dict, latency in ms)
        """
        # Use input data to seed random for consistency
        seed = int(np.sum(input_data * 1e6)) % (2**31)
        np.random.seed(seed)
        
        # Generate random probabilities with some structure
        probs = {}
        weights = [0.5, 0.4, 0.4, 2.5, 0.6, 1.2, 0.3, 2.0]  # Bias toward Happy, Neutral
        
        for i, label in enumerate(EMOTION_LABELS):
            probs[label] = np.random.random() * weights[i]
        
        # Normalize
        total = sum(probs.values())
        probs = {k: v / total for k, v in probs.items()}
        
        # Simulate latency (5-50ms)
        latency_ms = np.random.uniform(5, 50)
        
        return probs, latency_ms
    
    def _softmax(self, logits: Dict[str, float]) -> Dict[str, float]:
        """Apply softmax to convert logits to probabilities."""
        values = list(logits.values())
        max_val = max(values)
        exp_values = [np.exp(v - max_val) for v in values]
        sum_exp = sum(exp_values)
        
        result = {}
        for i, label in enumerate(logits.keys()):
            result[label] = exp_values[i] / sum_exp
        
        return result
    
    def _check_ambiguity(self, probs: Dict[str, float]) -> bool:
        """
        Check if prediction is ambiguous (top-2 emotions too close).
        
        Args:
            probs: Probability dictionary
            
        Returns:
            True if ambiguous, False otherwise
        """
        sorted_probs = sorted(probs.values(), reverse=True)
        if len(sorted_probs) >= 2:
            diff = sorted_probs[0] - sorted_probs[1]
            return diff < AMBIGUITY_THRESHOLD
        return False
    
    def _determine_failure_type(self, predicted: str, true_label: str, 
                                 confidence: float, is_ambiguous: bool) -> Optional[str]:
        """
        Determine the type of prediction failure.
        
        Args:
            predicted: Predicted emotion
            true_label: True emotion label
            confidence: Prediction confidence
            is_ambiguous: Whether prediction was ambiguous
            
        Returns:
            Failure type string or None if correct
        """
        if predicted == true_label:
            return None
        
        if confidence < CONFIDENCE_THRESHOLD:
            return "low_confidence"
        elif is_ambiguous:
            return "ambiguous"
        else:
            return "misclassification"
    
    def evaluate_sample(self, image_path: str, true_emotion: str, image_id: str) -> PredictionResult:
        """
        Evaluate a single image sample.
        
        Args:
            image_path: Path to the image
            true_emotion: Ground truth emotion label
            image_id: Unique image identifier
            
        Returns:
            PredictionResult with all metrics
        """
        # Preprocess
        input_data = self._preprocess_image(image_path)
        
        if input_data is None:
            return PredictionResult(
                image_id=image_id,
                true_emotion=true_emotion,
                predicted_emotion="unknown",
                confidence=0.0,
                all_probabilities={e: 0.0 for e in EMOTION_LABELS},
                correct=False,
                failure_type="no_detection",
                latency_ms=0.0,
                is_ambiguous=False,
            )
        
        # Run inference
        probs, latency_ms = self._run_inference(input_data)
        
        # Get prediction
        predicted = max(probs, key=probs.get)
        confidence = probs[predicted]
        
        # Check ambiguity
        is_ambiguous = self._check_ambiguity(probs)
        
        # Apply ambiguity penalty
        if is_ambiguous:
            confidence *= (1 - AMBIGUITY_PENALTY)
        
        # Determine correctness and failure type
        correct = predicted == true_emotion
        failure_type = self._determine_failure_type(predicted, true_emotion, confidence, is_ambiguous)
        
        return PredictionResult(
            image_id=image_id,
            true_emotion=true_emotion,
            predicted_emotion=predicted,
            confidence=confidence,
            all_probabilities=probs,
            correct=correct,
            failure_type=failure_type,
            latency_ms=latency_ms,
            is_ambiguous=is_ambiguous,
        )
    
    def evaluate_cycle(self, metadata_path: Optional[Path] = None) -> EvaluationResults:
        """
        Evaluate all images from a generation cycle.
        
        Args:
            metadata_path: Path to metadata file (uses default if None)
            
        Returns:
            EvaluationResults with aggregated metrics
        """
        metadata_path = metadata_path or get_metadata_path(self.cycle_number)
        
        print("=" * 60)
        print(f"🔬 Starting Model Evaluation - Cycle {self.cycle_number}")
        print("=" * 60)
        
        # Load model
        model_loaded = self.load_model()
        if not model_loaded:
            print("⚠️ Using mock predictions (model not available)")
        
        # Load metadata
        if not metadata_path.exists():
            raise FileNotFoundError(f"Metadata not found: {metadata_path}")
        
        with open(metadata_path, "r") as f:
            metadata = json.load(f)
        
        images = metadata.get("images", [])
        print(f"   Evaluating {len(images)} images...")
        
        # Initialize tracking
        confusion_matrix = {e: {e2: 0 for e2 in EMOTION_LABELS} for e in EMOTION_LABELS}
        per_emotion_counts = {e: {"correct": 0, "total": 0} for e in EMOTION_LABELS}
        failure_breakdown = {"misclassification": 0, "low_confidence": 0, "no_detection": 0, "ambiguous": 0}
        total_confidence = 0.0
        total_latency = 0.0
        
        # Evaluate each image
        for idx, img_meta in enumerate(images):
            # Handle placeholder vs real images
            image_path = img_meta["image_path"]
            if not Path(image_path).exists():
                # Try placeholder JSON
                image_path = Path(image_path).with_suffix(".json")
            
            result = self.evaluate_sample(
                str(image_path),
                img_meta["emotion_label"],
                img_meta["image_id"]
            )
            
            self.results.append(result)
            
            # Update metrics
            per_emotion_counts[result.true_emotion]["total"] += 1
            if result.correct:
                per_emotion_counts[result.true_emotion]["correct"] += 1
            
            confusion_matrix[result.true_emotion][result.predicted_emotion] += 1
            
            if result.failure_type:
                failure_breakdown[result.failure_type] = failure_breakdown.get(result.failure_type, 0) + 1
            
            total_confidence += result.confidence
            total_latency += result.latency_ms
            
            # Progress
            if (idx + 1) % max(1, len(images) // 5) == 0:
                print(f"  ✓ Evaluated {idx + 1}/{len(images)} images")
        
        # Calculate aggregates
        total_samples = len(self.results)
        correct_predictions = sum(1 for r in self.results if r.correct)
        overall_accuracy = correct_predictions / total_samples if total_samples > 0 else 0.0
        
        per_emotion_accuracy = {}
        for emotion in EMOTION_LABELS:
            counts = per_emotion_counts[emotion]
            if counts["total"] > 0:
                per_emotion_accuracy[emotion] = counts["correct"] / counts["total"]
            else:
                per_emotion_accuracy[emotion] = 0.0
        
        mean_confidence = total_confidence / total_samples if total_samples > 0 else 0.0
        mean_latency = total_latency / total_samples if total_samples > 0 else 0.0
        
        # Create results object
        results = EvaluationResults(
            cycle_number=self.cycle_number,
            total_samples=total_samples,
            correct_predictions=correct_predictions,
            overall_accuracy=overall_accuracy,
            per_emotion_accuracy=per_emotion_accuracy,
            per_emotion_counts=per_emotion_counts,
            mean_confidence=mean_confidence,
            mean_latency_ms=mean_latency,
            failure_breakdown=failure_breakdown,
            confusion_matrix=confusion_matrix,
            individual_results=[asdict(r) for r in self.results],
        )
        
        # Save results
        self._save_results(results)
        
        # Print summary
        self._print_summary(results)
        
        return results
    
    def _save_results(self, results: EvaluationResults):
        """Save evaluation results to file."""
        results_path = get_results_path(self.cycle_number)
        results_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(results_path, "w") as f:
            json.dump(asdict(results), f, indent=2)
        
        print(f"💾 Results saved to: {results_path}")
    
    def _print_summary(self, results: EvaluationResults):
        """Print evaluation summary."""
        print("=" * 60)
        print("📊 Evaluation Summary")
        print("=" * 60)
        print(f"Total samples: {results.total_samples}")
        print(f"Correct predictions: {results.correct_predictions}")
        print(f"Overall accuracy: {results.overall_accuracy * 100:.1f}%")
        print(f"Mean confidence: {results.mean_confidence:.3f}")
        print(f"Mean latency: {results.mean_latency_ms:.1f}ms")
        print()
        print("Per-emotion accuracy:")
        for emotion, acc in results.per_emotion_accuracy.items():
            counts = results.per_emotion_counts[emotion]
            print(f"  {emotion}: {acc * 100:.1f}% ({counts['correct']}/{counts['total']})")
        print()
        print("Failure breakdown:")
        for failure_type, count in results.failure_breakdown.items():
            print(f"  {failure_type}: {count}")
        print("=" * 60)


def load_results(cycle_number: int) -> Optional[Dict]:
    """Load results from a previous evaluation cycle."""
    results_path = get_results_path(cycle_number)
    if results_path.exists():
        with open(results_path, "r") as f:
            return json.load(f)
    return None


if __name__ == "__main__":
    # Demo: Evaluate cycle 1
    evaluator = ModelEvaluator(cycle_number=1)
    evaluator.evaluate_cycle()
