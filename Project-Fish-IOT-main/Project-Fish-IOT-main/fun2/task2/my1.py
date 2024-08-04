import cv2
from pathlib import Path
from ultralytics import YOLO
from ultralytics.utils.files import increment_path
import time

# Example usage
weights_path_behavior = "/home/pi/Desktop/Fish_IoT/fun2/task2/bestFFFF.pt"
video_path_behavior = "/home/pi/Desktop/Fish_IoT/fun2/task2/Test_1.mp4"

def fish_beh(
    weights, source=None, device='cpu',save_img=False, save_video=True, exist_ok=False,
    line_thickness=2,
    ):

    fish_behavior_counts = {'Feeding': 0, 'Fish-Schooling': 0, 'Resting': 0, 'Swimming': 0}

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

    # Output setup
    save_dir = Path('./output') / 'exp'
    save_dir.mkdir(parents=True, exist_ok=True)
    output_video_path = save_dir / f'{Path(source).stem}_behavior_counted.mp4'
    video_writer = cv2.VideoWriter(str(output_video_path), fourcc, fps, (frame_width, frame_height))

    # Iterate over video frames
    while videocapture.isOpened():
        success, frame = videocapture.read()
        if not success:
            break
        vid_frame_count += 1

        # Extract the results for the current frame
        results = model(frame)

        # Reset counts for each fish behavior in this frame
        fish_behavior_counts = {'Feeding': 0, 'Fish-Schooling': 0, 'Resting': 0, 'Swimming': 0}

        # Iterate over each result in the list
        for result in results:
            # Access the xyxy property and confidence values
            xyxy = result.boxes.xyxy.cpu().numpy()
            conf = result.boxes.conf.cpu().numpy()
            class_ids = result.boxes.cls.cpu().numpy()

            for (x1, y1, x2, y2), c, class_id in zip(xyxy, conf, class_ids):
                behavior_classes = ['Feeding', 'Fish-Schooling', 'Resting', 'Swimming']

                # Convert class_id to integer
                class_id = int(class_id)
                behavior = behavior_classes[class_id]

                # Draw bounding box
                cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), line_thickness)

                # Display count on the frame at top-right corner
                fish_behavior_counts[behavior] += 1
        '''
        # Display the counts on the frame at top-right corner
        count_label = " | ".join([f'{behavior}: {count}' for behavior, count in fish_behavior_counts.items()])
        cv2.putText(frame, count_label, (frame_width - 300, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

        # Display the frame with fish count
        if view_img:
            cv2.imshow('Fish Behavior Detection', frame)
            cv2.waitKey(1)
        '''
        # Save the frame if specified
        if save_img:
            cv2.imwrite(f'output_frame_{vid_frame_count}.jpg', frame)

        # Write the frame to the output video
        if save_video:
            video_writer.write(frame)

    video_writer.release()
    videocapture.release()
    print("Save video Done")
    #cv2.destroyAllWindows()

    return fish_behavior_counts




# Now, `result_counts` contains the counts of fish behaviors
while True:
    result_counts = fish_beh(weights=weights_path_behavior, source=video_path_behavior, device='cpu', save_img=False, save_video=True)
    print(result_counts)
    time.sleep(20)
    external_array = []

    for _ in range(5):  # Update the array 5 times continuously
        behavior_counts = fish_beh(weights='your_weights', source='your_video_source')
        external_array.append(behavior_counts)

    print(external_array)
