"""
Autonomous Emotion Recognition Testing Pipeline - Data Generator
=================================================================
Generates synthetic facial images with varied emotions, demographics, and conditions.
"""

import json
import random
import hashlib
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
import itertools

from pipeline_config import (
    EMOTION_LABELS, DEMOGRAPHICS, ENVIRONMENTAL_VARIATIONS, ACCESSORIES,
    INTENSITY_LEVELS, get_images_per_emotion, get_cycle_dir, get_metadata_path,
    ensure_directories, get_prompt_for_emotion, DEMO_MODE
)


@dataclass
class ImageMetadata:
    """Metadata for a generated synthetic image."""
    image_id: str
    emotion_label: str
    intensity_level: float
    gender: str
    age_group: str
    skin_tone: str
    face_shape: str
    head_pose: str
    lighting_condition: str
    background: str
    glasses: str
    occlusion_flag: bool
    image_path: str
    generated_at: str
    prompt_used: str


class DataGenerator:
    """
    Generates synthetic facial images for emotion recognition testing.
    
    In demo mode, creates placeholder images with metadata.
    In production mode, can integrate with image generation APIs.
    """
    
    def __init__(self, cycle_number: int = 1):
        """
        Initialize the data generator.
        
        Args:
            cycle_number: Current training cycle number
        """
        self.cycle_number = cycle_number
        self.cycle_dir = get_cycle_dir(cycle_number)
        self.metadata_path = get_metadata_path(cycle_number)
        self.generated_metadata: List[ImageMetadata] = []
        self.generation_stats = {
            "total_generated": 0,
            "per_emotion": {e: 0 for e in EMOTION_LABELS},
            "failures": 0,
            "start_time": None,
            "end_time": None,
        }
        
    def _generate_image_id(self, emotion: str, variation_idx: int) -> str:
        """Generate a unique image ID."""
        seed = f"{self.cycle_number}_{emotion}_{variation_idx}_{datetime.now().isoformat()}"
        return hashlib.md5(seed.encode()).hexdigest()[:12]
    
    def _get_variation_combinations(self, emotion: str, target_count: int) -> List[Dict]:
        """
        Generate diverse variation combinations for an emotion.
        
        Args:
            emotion: Target emotion
            target_count: Number of variations to generate
            
        Returns:
            List of variation dictionaries
        """
        # Create all possible combinations
        all_combinations = []
        
        for gender in DEMOGRAPHICS["gender"]:
            for age in DEMOGRAPHICS["age_group"]:
                for skin in DEMOGRAPHICS["skin_tone"]:
                    for face in DEMOGRAPHICS["face_shape"]:
                        for lighting in ENVIRONMENTAL_VARIATIONS["lighting"]:
                            for pose in ENVIRONMENTAL_VARIATIONS["head_pose"]:
                                for bg in ENVIRONMENTAL_VARIATIONS["background"]:
                                    for glasses in ACCESSORIES["glasses"]:
                                        for intensity in INTENSITY_LEVELS:
                                            all_combinations.append({
                                                "gender": gender,
                                                "age_group": age,
                                                "skin_tone": skin,
                                                "face_shape": face,
                                                "lighting": lighting,
                                                "head_pose": pose,
                                                "background": bg,
                                                "glasses": glasses,
                                                "occlusion": random.choice(ACCESSORIES["occlusion"]),
                                                "intensity": intensity,
                                            })
        
        # Shuffle and select target count
        random.shuffle(all_combinations)
        
        if len(all_combinations) >= target_count:
            return all_combinations[:target_count]
        else:
            # If we need more than available, repeat with slight variations
            extended = all_combinations.copy()
            while len(extended) < target_count:
                variation = random.choice(all_combinations).copy()
                variation["intensity"] = random.choice(INTENSITY_LEVELS)
                extended.append(variation)
            return extended[:target_count]
    
    def _create_placeholder_image(self, emotion: str, image_path: Path, metadata: ImageMetadata) -> bool:
        """
        Create a placeholder image file.
        
        In demo mode, this creates a simple text file placeholder.
        Can be extended to call actual image generation APIs.
        
        Args:
            emotion: Target emotion
            image_path: Path to save the image
            metadata: Image metadata
            
        Returns:
            True if successful, False otherwise
        """
        try:
            # In demo mode, create a placeholder file with metadata
            # This would be replaced with actual image generation in production
            image_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Create a placeholder JSON file (simulating image creation)
            placeholder_path = image_path.with_suffix(".json")
            with open(placeholder_path, "w") as f:
                json.dump({
                    "type": "placeholder_image",
                    "description": "This represents a synthetic facial image",
                    "metadata": asdict(metadata),
                    "prompt": metadata.prompt_used,
                }, f, indent=2)
            
            return True
            
        except Exception as e:
            print(f"  ❌ Failed to create image: {e}")
            return False
    
    def generate_for_emotion(self, emotion: str, count: Optional[int] = None) -> List[ImageMetadata]:
        """
        Generate synthetic images for a specific emotion.
        
        Args:
            emotion: Target emotion label
            count: Number of images to generate (uses config default if None)
            
        Returns:
            List of generated image metadata
        """
        if emotion not in EMOTION_LABELS:
            raise ValueError(f"Unknown emotion: {emotion}")
        
        count = count or get_images_per_emotion()
        print(f"📸 Generating {count} images for emotion: {emotion}")
        
        # Create emotion-specific directory
        emotion_dir = self.cycle_dir / emotion.lower()
        emotion_dir.mkdir(parents=True, exist_ok=True)
        
        # Get variation combinations
        variations = self._get_variation_combinations(emotion, count)
        generated = []
        
        for idx, variation in enumerate(variations):
            image_id = self._generate_image_id(emotion, idx)
            image_filename = f"{emotion.lower()}_{image_id}.png"
            image_path = emotion_dir / image_filename
            
            # Generate prompt
            prompt = get_prompt_for_emotion(emotion, variation)
            
            # Create metadata
            metadata = ImageMetadata(
                image_id=image_id,
                emotion_label=emotion,
                intensity_level=variation["intensity"],
                gender=variation["gender"],
                age_group=variation["age_group"],
                skin_tone=variation["skin_tone"],
                face_shape=variation["face_shape"],
                head_pose=variation["head_pose"],
                lighting_condition=variation["lighting"],
                background=variation["background"],
                glasses=variation["glasses"],
                occlusion_flag=variation["occlusion"] != "none",
                image_path=str(image_path),
                generated_at=datetime.now().isoformat(),
                prompt_used=prompt,
            )
            
            # Create the image (placeholder in demo mode)
            if self._create_placeholder_image(emotion, image_path, metadata):
                generated.append(metadata)
                self.generation_stats["per_emotion"][emotion] += 1
            else:
                self.generation_stats["failures"] += 1
            
            # Progress indicator
            if (idx + 1) % max(1, count // 5) == 0:
                print(f"  ✓ Generated {idx + 1}/{count} images")
        
        self.generated_metadata.extend(generated)
        self.generation_stats["total_generated"] += len(generated)
        
        return generated
    
    def generate_all_emotions(self) -> List[ImageMetadata]:
        """
        Generate synthetic images for all emotions.
        
        Returns:
            List of all generated image metadata
        """
        print("=" * 60)
        print(f"🚀 Starting Data Generation - Cycle {self.cycle_number}")
        print(f"   Mode: {'DEMO' if DEMO_MODE else 'PRODUCTION'}")
        print(f"   Target: {get_images_per_emotion()} images per emotion")
        print(f"   Total: {get_images_per_emotion() * len(EMOTION_LABELS)} images")
        print("=" * 60)
        
        self.generation_stats["start_time"] = datetime.now().isoformat()
        ensure_directories()
        
        for emotion in EMOTION_LABELS:
            self.generate_for_emotion(emotion)
            print()
        
        self.generation_stats["end_time"] = datetime.now().isoformat()
        
        # Save all metadata
        self._save_metadata()
        
        # Print summary
        self._print_summary()
        
        return self.generated_metadata
    
    def generate_targeted(self, weak_emotions: List[str], multiplier: int = 2) -> List[ImageMetadata]:
        """
        Generate additional images for weak-performing emotions.
        
        Args:
            weak_emotions: List of emotions needing more training data
            multiplier: How many times the normal count to generate
            
        Returns:
            List of generated image metadata
        """
        print("=" * 60)
        print(f"🎯 Targeted Data Generation - Cycle {self.cycle_number}")
        print(f"   Targeting: {', '.join(weak_emotions)}")
        print(f"   Multiplier: {multiplier}x")
        print("=" * 60)
        
        extra_count = get_images_per_emotion() * multiplier
        
        for emotion in weak_emotions:
            if emotion in EMOTION_LABELS:
                self.generate_for_emotion(emotion, extra_count)
                print()
        
        self._save_metadata()
        return self.generated_metadata
    
    def _save_metadata(self):
        """Save all generated metadata to file."""
        self.metadata_path.parent.mkdir(parents=True, exist_ok=True)
        
        data = {
            "cycle_number": self.cycle_number,
            "generation_stats": self.generation_stats,
            "images": [asdict(m) for m in self.generated_metadata],
        }
        
        with open(self.metadata_path, "w") as f:
            json.dump(data, f, indent=2)
        
        print(f"💾 Metadata saved to: {self.metadata_path}")
    
    def _print_summary(self):
        """Print generation summary."""
        print("=" * 60)
        print("📊 Generation Summary")
        print("=" * 60)
        print(f"Total images generated: {self.generation_stats['total_generated']}")
        print(f"Failures: {self.generation_stats['failures']}")
        print("\nPer-emotion breakdown:")
        for emotion, count in self.generation_stats["per_emotion"].items():
            print(f"  {emotion}: {count}")
        print("=" * 60)


def load_metadata(cycle_number: int) -> Optional[Dict]:
    """
    Load metadata from a previous generation cycle.
    
    Args:
        cycle_number: Cycle number to load
        
    Returns:
        Metadata dictionary or None if not found
    """
    metadata_path = get_metadata_path(cycle_number)
    if metadata_path.exists():
        with open(metadata_path, "r") as f:
            return json.load(f)
    return None


if __name__ == "__main__":
    # Demo: Generate images for all emotions
    generator = DataGenerator(cycle_number=1)
    generator.generate_all_emotions()
