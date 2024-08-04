import cv2
from pathlib import Path
from ultralytics import YOLO
from ultralytics.utils.files import increment_path

fish_counts = {'Goldfish': 0, 'Guppy': 0, 'Angel': 0}
weights_path = ("/home/pi/Desktop/Fish_IoT/fun3/task2/best (6).pt")
video_path = ("/home/pi/Desktop/Fish_IoT/fun3/task2/dd.mp4")

def fish_count(weights,source=None,device='cpu',exist_ok=False,line_thickness=2,):
    global fish_counts

    vid_frame_count = 0
    
    # Check source path
    if not Path(source).exists():
        raise FileNotFoundError(f"Source path '{source}' does not exist.")

    # Setup Model
    model = YOLO(weights)
    model.to('cuda') if device == 'cuda' else model.to('cpu')

    # Video setup
    videocapture = cv2.VideoCapture(source)
    frame_width, frame_height = int(videocapture.get(3)), int(videocapture.get(4))
    fps, fourcc = int(videocapture.get(5)), cv2.VideoWriter_fourcc(*'mp4v')
    
    # Iterate over video frames
    while videocapture.isOpened():
        success, frame = videocapture.read()
        if not success:
            break
        vid_frame_count += 1 
        # Extract the results for the current frame
        results = model(frame)
        # Reset counts for each fish type in this frame
        fish_counts = {name: 0 for name in fish_counts}
    
        # Iterate over each result in the list
        for result in results:
            # Access the xyxy property and confidence values
            xyxy = result.boxes.xyxy.cpu().numpy()
            conf = result.boxes.conf.cpu().numpy()
            class_ids = result.boxes.cls.cpu().numpy()

            for (x1, y1, x2, y2), c, class_id in zip(xyxy, conf, class_ids):
                fish_type = model.names[class_id]
                
                print(fish_type)
        
                # Draw bounding box
                cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), line_thickness)

               # Example usage in VS Code

    
fish_count(weights=weights_path, source=video_path, device='cpu')


