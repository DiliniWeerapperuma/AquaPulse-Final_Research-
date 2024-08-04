import cv2
from pathlib import Path
from ultralytics import YOLO

dead_fish_count = 0

def run(
    weights=r"C:\Users\theekshana\Desktop\Project-Fish-ML\Project-Fish-ML\Function 3\Task-2(Dead Fish Identification and Dead fish count)\Raspberry Pi\best (6).pt",  # Change to your dead fish detection model weights
    source=None,
    device='cpu',
    view_img=False,
    save_img=False,
    save_video=True,
    exist_ok=False,
    line_thickness=2,
):
    global dead_fish_count

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
    save_dir = Path('output_directory')  # Change to your desired output directory
    save_dir.mkdir(parents=True, exist_ok=True)
    video_writer = cv2.VideoWriter(str(save_dir / f'{Path(source).stem}_dead_fish_counted.mp4'), fourcc, fps, (frame_width, frame_height))

    # Iterate over video frames
    while videocapture.isOpened():
        success, frame = videocapture.read()
        if not success:
            break
        vid_frame_count += 1

        # Extract the results for the current frame
        results = model(frame)

        # Reset dead fish count for each frame
        dead_fish_count = 0

        # Iterate over each result in the list
        for result in results:
            # Access the xyxy property and confidence values
            xyxy = result.boxes.xyxy.cpu().numpy()
            conf = result.boxes.conf.cpu().numpy()
            class_ids = result.boxes.cls.cpu().numpy()

            for (x1, y1, x2, y2), c, class_id in zip(xyxy, conf, class_ids):
                # Assuming dead fish is the first class (class ID 0), replace this with your actual class ID
                if class_id == 0:
                    dead_fish_count += 1

                    # Draw bounding box
                    cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 0, 255), line_thickness)

        # Display the dead fish count on the frame at the top-right corner
        count_label = f'Dead Fish Count: {dead_fish_count}'
        cv2.putText(frame, count_label, (frame_width - 300, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

        # Display the frame with dead fish count
        if view_img:
            cv2.imshow('Dead Fish Detection', frame)
            cv2.waitKey(1)

        # Save the frame if specified
        if save_img:
            cv2.imwrite(str(save_dir / f'output_frame_{vid_frame_count}.jpg'), frame)

        # Write the frame to the output video
        if save_video:
            video_writer.write(frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    del vid_frame_count
    video_writer.release()
    videocapture.release()
    cv2.destroyAllWindows()

# Example usage
weights_path_dead_fish =r"C:\Users\theekshana\Desktop\Project-Fish-ML\Project-Fish-ML\Function 3\Task-2(Dead Fish Identification and Dead fish count)\Raspberry Pi\best (6).pt"
video_path = r"C:\Users\theekshana\Desktop\Project-Fish-ML\Project-Fish-ML\Function 3\Task-2(Dead Fish Identification and Dead fish count)\Raspberry Pi\Test_Videos\stock-footage-dead-fantail-goldfish-in-an-aquarium-under-the-water.webm"

run(weights=weights_path_dead_fish, source=video_path, device='cpu', view_img=True, save_img=False, save_video=True)
