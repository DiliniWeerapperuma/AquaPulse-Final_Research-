import os

from ultralytics import YOLO
# Load a model
model = YOLO('yolov8n-cls.pt')  #build a new model from scratch
# Use the model
results = model.train(data=ROOT_DIR, epochs=20, imgsz=64) #train the model

