"""
Autonomous Emotion Recognition Testing Pipeline - Configuration
================================================================
Central configuration for the entire testing and tuning pipeline.
"""

import os
from datetime import datetime
from pathlib import Path

# ============================================================================
# PATH CONFIGURATION
# ============================================================================

PROJECT_ROOT = Path(__file__).parent.parent
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
ASSETS_DIR = PROJECT_ROOT / "assets"
MODELS_DIR = ASSETS_DIR / "models"
GENERATED_DATA_DIR = PROJECT_ROOT / "generated_data"
IMAGES_DIR = GENERATED_DATA_DIR / "images"
METADATA_DIR = GENERATED_DATA_DIR / "metadata"
RESULTS_DIR = GENERATED_DATA_DIR / "results"
REPORTS_DIR = GENERATED_DATA_DIR / "reports"

# Model paths
CNN_MODEL_PATH = MODELS_DIR / "cnn_model.tflite"

# ============================================================================
# EMOTION CONFIGURATION
# ============================================================================

# FER-Plus 8-class emotions (matches the pre-trained model)
EMOTION_LABELS = [
    "Angry", "Disgust", "Fear", "Happy", "Sad", "Surprise", "Contempt", "Neutral"
]

# Extended emotions mapping (maps additional emotions to FER-Plus classes)
EXTENDED_EMOTION_MAPPING = {
    "Confused": "Contempt",    # Similar subtle expression
    "Anxious": "Fear",         # Related emotional state
    "Calm": "Neutral",         # Relaxed expression
}

# Emotion colors for visualization
EMOTION_COLORS = {
    "Angry": "#E53935",
    "Disgust": "#8BC34A", 
    "Fear": "#9C27B0",
    "Happy": "#FFC107",
    "Sad": "#2196F3",
    "Surprise": "#FF9800",
    "Contempt": "#607D8B",
    "Neutral": "#9E9E9E",
}

# ============================================================================
# DATA GENERATION CONFIGURATION
# ============================================================================

# Variation parameters for synthetic image generation
DEMOGRAPHICS = {
    "gender": ["male", "female", "non-binary"],
    "age_group": ["child", "teen", "adult", "elderly"],
    "skin_tone": ["light", "medium-light", "medium", "medium-dark", "dark"],
    "face_shape": ["round", "oval", "square", "heart"],
}

ENVIRONMENTAL_VARIATIONS = {
    "lighting": ["low", "normal", "harsh", "dramatic"],
    "head_pose": ["frontal", "slight-left", "slight-right", "tilted", "partial-profile"],
    "background": ["plain-white", "plain-gray", "indoor", "outdoor", "studio"],
}

ACCESSORIES = {
    "glasses": ["none", "reading-glasses", "sunglasses"],
    "headwear": ["none", "hat", "cap", "headscarf"],
    "occlusion": ["none", "hand-near-face", "hair-covering-face"],
}

# Intensity levels for emotion expression
INTENSITY_LEVELS = [0.3, 0.5, 0.7, 0.9]  # Low, medium, high, very high

# ============================================================================
# GENERATION SCALE CONFIGURATION
# ============================================================================

# Demo mode settings (for testing the pipeline)
DEMO_MODE = True
DEMO_IMAGES_PER_EMOTION = 10

# Production mode settings
PRODUCTION_IMAGES_PER_EMOTION = 1000

# Get the actual count based on mode
def get_images_per_emotion():
    return DEMO_IMAGES_PER_EMOTION if DEMO_MODE else PRODUCTION_IMAGES_PER_EMOTION

# ============================================================================
# MODEL CONFIGURATION
# ============================================================================

MODEL_INPUT_SHAPE = (48, 48, 1)  # Grayscale 48x48
MODEL_OUTPUT_CLASSES = 8

# ============================================================================
# PERFORMANCE THRESHOLDS
# ============================================================================

# Target performance metrics
TARGET_OVERALL_ACCURACY = 0.90       # 90% overall accuracy
TARGET_PER_EMOTION_ACCURACY = 0.85   # 85% per-emotion accuracy
TARGET_CONFIDENCE_STABILITY = 0.80   # Mean confidence >= 0.8

# Failure thresholds
CONFIDENCE_THRESHOLD = 0.75          # Below this = low confidence failure
BIAS_THRESHOLD = 0.05                # Max allowed accuracy difference across demographics

# ============================================================================
# AUTO-TUNING CONFIGURATION
# ============================================================================

# Threshold adjustment parameters
THRESHOLD_ADJUSTMENT_STEP = 0.05     # How much to adjust thresholds per cycle
MIN_CONFIDENCE_THRESHOLD = 0.5       # Minimum allowed confidence threshold
MAX_CONFIDENCE_THRESHOLD = 0.95      # Maximum allowed confidence threshold

# Class reweighting parameters
REWEIGHT_FACTOR_MIN = 0.5            # Minimum class weight
REWEIGHT_FACTOR_MAX = 2.0            # Maximum class weight

# Data augmentation triggers
AUGMENT_THRESHOLD = 0.80             # Per-class accuracy below this triggers augmentation
AUGMENT_MULTIPLIER = 2               # Generate 2x more samples for failing classes

# ============================================================================
# LOOP CONTROL CONFIGURATION
# ============================================================================

# Termination criteria
MAX_CYCLES = 20                      # Maximum training cycles
PLATEAU_CYCLES = 3                   # Stop if no improvement for 3 cycles
PLATEAU_THRESHOLD = 0.01             # Improvement less than 1% = plateau

# Cycle configuration
CYCLE_LOG_FREQUENCY = 1              # Log every cycle
DETAILED_LOGGING = True              # Enable detailed per-sample logging

# ============================================================================
# AUTISM-SPECIFIC CONFIGURATION
# ============================================================================

# Micro-expression focus for autism context
MICRO_EXPRESSION_WEIGHT = 1.5        # Extra weight for subtle expressions
SUBTLETY_FACTOR = 0.7                # Prefer subtle over exaggerated expressions

# Penalize over-confidence on ambiguous faces
AMBIGUITY_PENALTY = 0.1              # Reduce confidence on ambiguous predictions
AMBIGUITY_THRESHOLD = 0.4            # Top-2 emotions within this range = ambiguous

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

def get_cycle_dir(cycle_number: int) -> Path:
    """Get the directory for a specific cycle."""
    return IMAGES_DIR / f"cycle_{cycle_number:03d}"

def get_metadata_path(cycle_number: int) -> Path:
    """Get the metadata file path for a specific cycle."""
    return METADATA_DIR / f"cycle_{cycle_number:03d}_metadata.json"

def get_results_path(cycle_number: int) -> Path:
    """Get the results file path for a specific cycle."""
    return RESULTS_DIR / f"cycle_{cycle_number:03d}_results.json"

def get_final_report_path() -> Path:
    """Get the final report file path."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return REPORTS_DIR / f"final_report_{timestamp}.json"

def ensure_directories():
    """Create all necessary directories."""
    for dir_path in [GENERATED_DATA_DIR, IMAGES_DIR, METADATA_DIR, RESULTS_DIR, REPORTS_DIR]:
        dir_path.mkdir(parents=True, exist_ok=True)

def get_prompt_for_emotion(emotion: str, variations: dict) -> str:
    """
    Generate a detailed prompt for synthetic face image generation.
    
    Args:
        emotion: The target emotion label
        variations: Dict with demographic and environmental variations
    
    Returns:
        A detailed prompt string for image generation
    """
    intensity = variations.get("intensity", 0.7)
    intensity_desc = "subtle" if intensity < 0.5 else "moderate" if intensity < 0.8 else "clear"
    
    gender = variations.get("gender", "person")
    age = variations.get("age_group", "adult")
    skin_tone = variations.get("skin_tone", "medium")
    
    lighting = variations.get("lighting", "normal")
    pose = variations.get("head_pose", "frontal")
    background = variations.get("background", "plain")
    
    glasses = variations.get("glasses", "none")
    occlusion = variations.get("occlusion", "none")
    
    # Build the prompt
    prompt_parts = [
        f"Photorealistic portrait photograph of a {age} {gender}",
        f"with {skin_tone} skin tone",
        f"showing a {intensity_desc} {emotion.lower()} expression",
        f"in {lighting} lighting conditions",
        f"with {pose} head pose",
        f"against a {background} background",
    ]
    
    if glasses != "none":
        prompt_parts.append(f"wearing {glasses}")
    
    if occlusion != "none":
        prompt_parts.append(f"with {occlusion}")
    
    prompt_parts.extend([
        "high quality, sharp focus, natural expression",
        "suitable for facial emotion recognition, close-up face shot",
    ])
    
    return ", ".join(prompt_parts)


if __name__ == "__main__":
    print("=" * 60)
    print("Pipeline Configuration Summary")
    print("=" * 60)
    print(f"Project Root: {PROJECT_ROOT}")
    print(f"Model Path: {CNN_MODEL_PATH}")
    print(f"Mode: {'DEMO' if DEMO_MODE else 'PRODUCTION'}")
    print(f"Images per emotion: {get_images_per_emotion()}")
    print(f"Total images per cycle: {get_images_per_emotion() * len(EMOTION_LABELS)}")
    print(f"Target accuracy: {TARGET_OVERALL_ACCURACY * 100:.0f}%")
    print(f"Emotions: {', '.join(EMOTION_LABELS)}")
    print("=" * 60)
