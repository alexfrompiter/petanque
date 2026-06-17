#!/usr/bin/env python3
"""Run inference on an image and print normalized coordinates."""
import argparse
import os
import torch
import sys

# Fix torch.load for our model
_original_load = torch.load
def safe_load(*args, **kwargs):
    if 'weights_only' not in kwargs:
        kwargs['weights_only'] = False
    return _original_load(*args, **kwargs)
torch.load = safe_load

from ultralytics import YOLO

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('image', help='Path to image file')
    parser.add_argument('--model', default='runs/detect/train2/weights/best.pt',
                        help='Path to model weights')
    parser.add_argument('--conf', type=float, default=0.25, help='Confidence threshold')
    parser.add_argument('--imgsz', type=int, default=640, help='Inference size')
    args = parser.parse_args()

    # Change to model directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    model = YOLO(args.model)
    results = model.predict(source=args.image, conf=args.conf, imgsz=args.imgsz, save=False)

    for r in results:
        orig_w, orig_h = r.orig_shape[1], r.orig_shape[0]
        print(f'Image: {os.path.basename(r.path)}')
        print(f'Original size: {orig_w}x{orig_h}')
        print(f'---')
        for box in r.boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            xyxy = box.xyxy[0].tolist()
            cx = (xyxy[0] + xyxy[2]) / 2 / orig_w  # center x normalized
            cy = (xyxy[1] + xyxy[3]) / 2 / orig_h  # center y normalized
            w  = (xyxy[2] - xyxy[0]) / orig_w      # width normalized
            h  = (xyxy[3] - xyxy[1]) / orig_h      # height normalized
            name = model.names[cls]
            print(f'{name}: conf={conf:.3f}')
            print(f'  pixel xyxy: [{xyxy[0]:.1f}, {xyxy[1]:.1f}, {xyxy[2]:.1f}, {xyxy[3]:.1f}]')
            print(f'  normalized: cx={cx:.4f}, cy={cy:.4f}, w={w:.4f}, h={h:.4f}')
        print()

if __name__ == '__main__':
    main()
