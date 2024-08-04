import cv2
from pathlib import Path
from ultralytics import YOLO
from ultralytics.utils.files import increment_path


'''
fish_counts = {'Goldfish': 0, 'Guppy': 0, 'Angel': 0}
weights_path = "/home/pi/Desktop/Fish_IoT/fun2/task1/best.pt"
video_path = "/home/pi/Desktop/Fish_IoT/fun2/task1/A.webm"
'''
# Load a pretrained YOLOv8n model
model = YOLO('/home/pi/Desktop/Fish_IoT/fun2/task1/best.pt')

# Define path to video file
source = '/home/pi/Desktop/Fish_IoT/fun2/task1/A.webm'

# Run inference on the source
results = model(source, stream=True)  # generator of Results objects