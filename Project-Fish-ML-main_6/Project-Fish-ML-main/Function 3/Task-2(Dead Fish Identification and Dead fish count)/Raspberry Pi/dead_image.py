import cv2
from pathlib import Path
from ultralytics import YOLO

dead_fish_count = 0

def run(
    weights=r"C:\Users\theekshana\Desktop\Project-Fish-ML\Project-Fish-ML\Function 3\Task-2(Dead Fish Identification and Dead fish count)\Raspberry Pi\best (6).pt",  # Change to your dead fish detection model weights
    source=None,
    view_img=False,
    save_img=False,
    line_thickness=2,
):
    global dead_fish_count

    # Check source path
    if not Path(source).exists():
        raise FileNotFoundError(f"Source path '{source}' does not exist.")

    # Setup Model
    model = YOLO(weights)
    model.to('cpu')  # Adjust this line based on your hardware, 'cuda' for GPU, 'cpu' for CPU

    # Read the input image
    frame = cv2.imread(source)

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
    cv2.putText(frame, count_label, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

    # Display the frame with dead fish count
    if view_img:
        cv2.imshow('Dead Fish Detection', frame)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    # Save the frame if specified
    if save_img:
        output_path = Path('./output') / f'{Path(source).stem}_dead_fish_counted.jpg'
        cv2.imwrite(str(output_path), frame)

# Example usage locally
weights_path_dead_fish = r"C:\Users\theekshana\Desktop\Project-Fish-ML\Project-Fish-ML\Function 3\Task-2(Dead Fish Identification and Dead fish count)\Raspberry Pi\best (6).pt"
image_path_dead_fish = r"C:\Users\theekshana\Desktop\Project-Fish-ML\Project-Fish-ML\Function 3\Task-2(Dead Fish Identification and Dead fish count)\Raspberry Pi\Test_Images\Dead_Fish_train064.png"

run(weights=weights_path_dead_fish, source=image_path_dead_fish, view_img=True, save_img=True)
