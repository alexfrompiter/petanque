import os
import glob
import torch
from ultralytics import YOLOv10

# WORKAROUND: Patch torch.load to default weights_only=False
# This is required because our trained model contains custom classes that PyTorch 2.6+ 
# blocks by default for security, but we trust our own training.
_original_load = torch.load

def safe_load(*args, **kwargs):
    if 'weights_only' not in kwargs:
        kwargs['weights_only'] = False
    return _original_load(*args, **kwargs)

torch.load = safe_load

# Paths
model_path = 'runs/detect/train2/weights/best.pt'
test_images_dir = 'TIPE-petank-2/test/images'

# Load the trained model
# Note: We use YOLOv10 class but load our custom trained weights
model = YOLOv10(model_path)

# Get list of images
image_extensions = ['*.jpg', '*.jpeg', '*.png', '*.bmp']
images = []
for ext in image_extensions:
    images.extend(glob.glob(os.path.join(test_images_dir, ext)))

print(f"Found {len(images)} images in {test_images_dir}")

if images:
    # Run inference
    # save=True will save images with bounding boxes to runs/detect/predict...
    results = model.predict(source=test_images_dir, save=True, conf=0.25)
    print("Inference complete. Check runs/detect/predict (or predict2, etc.) for results.")
else:
    print("No images found to test.")
