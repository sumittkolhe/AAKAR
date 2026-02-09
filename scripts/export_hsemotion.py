import os
import sys
import shutil

# Ensure hsemotion_onnx is importable
try:
    from hsemotion_onnx.facial_emotions import HSEmotionRecognizer
    print("✅ hsemotion_onnx loaded")
except ImportError as e:
    print(f"❌ Failed to import hsemotion_onnx: {e}")
    sys.exit(1)

def export_model():
    print("🚀 Initializing HSEmotionRecognizer (downloads model if needed)...")
    # model_name='enet_b0_8_best_afew'
    try:
        recognizer = HSEmotionRecognizer(model_name='enet_b0_8_best_afew')
    except Exception as e:
        print(f"❌ Failed to initialize recognizer: {e}")
        return

    print(f"✅ Model loaded: {recognizer.model_name}")
    
    # Locate the model file
    home_dir = os.path.expanduser('~')
    # hsemotion usually saves to ~/.hsemotion
    model_path = os.path.join(home_dir, '.hsemotion', 'enet_b0_8_best_afew.onnx')
    
    if not os.path.exists(model_path):
        print(f"⚠️ Model not found in {model_path}, checking package dir...")
        import hsemotion_onnx
        package_dir = os.path.dirname(hsemotion_onnx.__file__)
        model_path = os.path.join(package_dir, 'models', 'enet_b0_8_best_afew.onnx')
    
    if os.path.exists(model_path):
        print(f"✅ Found ONNX model at: {model_path}")
        
        # Copy to assets/models
        dest_dir = 'assets/models'
        os.makedirs(dest_dir, exist_ok=True)
        dest_path = os.path.join(dest_dir, 'affectnet_model.onnx')
        shutil.copy2(model_path, dest_path)
        print(f"🎉 Model copied to: {dest_path}")
        print(f"Size: {os.path.getsize(dest_path) / 1024 / 1024:.2f} MB")
    else:
        print("❌ Could not locate the downloaded ONNX model file.")

if __name__ == '__main__':
    export_model()
