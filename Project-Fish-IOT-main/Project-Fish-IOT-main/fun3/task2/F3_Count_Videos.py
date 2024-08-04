import cv2
from pathlib import Path
from ultralytics import YOLO
from ultralytics.utils.files import increment_path



death_fish = {'Dead Fish': 0}
moduledeath = ("/home/pi/Desktop/Fish_IoT/fun3/task2/best (6).pt")
death_vid = ("/home/pi/Desktop/Fish_IoT/fun3/task2/dd.mp4")

total_deathfish_count = 0  # Initialize total_deathfish_count
vid_frame_count = 0

total_deathfish_counts = {'Dead Fish': 0}
total_vidded = 0

def deathfish_count(weights, source=None, device='cpu', exist_ok=False, line_thickness=2):
    global death_fish, total_deathfish_counts, total_vidded

    # Check source path
    if not Path(source).exists():
        raise FileNotFoundError(f"Source path '{source}' does not exist.")

    # Setup Model
    model = YOLO(weights)
    model.to('cuda') if device == 'cuda' else model.to('cpu')

    # Video setup
    videocapture = cv2.VideoCapture(source)

    # Iterate over video frames
    while videocapture.isOpened():
        success, frame = videocapture.read()
        if not success:
            break
        total_vidded += 1

        # Extract the results for the current frame
        results = model(frame)
        frame_fish_count = {name: 0 for name in death_fish}

        # Iterate over each result in the list
        for result in results:
            xyxy = result.boxes.xyxy.cpu().numpy()
            conf = result.boxes.conf.cpu().numpy()
            class_ids = result.boxes.cls.cpu().numpy()

            for (x1, y1, x2, y2), c, class_id in zip(xyxy, conf, class_ids):
                fish_type = model.names[class_id]
                frame_fish_count[fish_type] += 1  # Increment count for this fish type

                # Draw bounding box
                cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), line_thickness)

        # Update the global death_fish with the counts from this frame
        for fish_type, count in frame_fish_count.items():
            death_fish[fish_type] += count
            total_deathfish_counts[fish_type] += count  # Add count to the total for this fish type

    # Release the video capture
    videocapture.release()

# Call fish_count function
deathfish_count(moduledeath, death_vid, device='cpu')

# Calculate average fish count for each fish type
#average_death_fish = {fish_type: total_deathfish_count / total_vidded for fish_type, total_deathfish_count in total_death_fish.items()}
Death_fish_counts = {fish_type: int(total_deathfish_count / total_vidded) for fish_type, total_deathfish_count in total_deathfish_counts.items()}
# Print average fish count for each fish type
for fish_type, avg_count in Death_fish_counts.items():
    print(f"Average {fish_type} Count: {avg_count}")