import os
from ultralytics import YOLOv10

# Define dataset location
dataset_location = os.path.abspath("TIPE-petank-2")

# Load pre-trained weights
model = YOLOv10.from_pretrained('jameslahm/yolov10n')

# Start training
model.train(
    data=f"{dataset_location}/data.yaml",
    epochs=100,
    imgsz=640,
    batch=32,      # Increased batch size (monitor memory usage)
    device='mps',  # Use macOS GPU
    workers=8,     # Use available CPU cores for data loading
    cache=True     # Cache images in RAM for faster access
)
