import cv2
from pathlib import Path
from ultralytics import YOLO

fish_counts = {'Goldfish': 0, 'Guppy': 0, 'Angel': 0}

weights_path = ("/home/pi/Desktop/Raspberry Pi (1)/best.pt")
image_path = ("/home/pi/Desktop/Raspberry Pi (1)/61wN0bSvL6L.jpg")

def run(weights,source=None,device='cpu',view_img=False,save_img=False,exist_ok=False,line_thickness=2,):
    
    global fish_counts
    # Check source path
    if not Path(source).exists():
        raise FileNotFoundError(f"Source path '{source}' does not exist.")
    # Setup Model
    model = YOLO(weights)
    model.to('cuda') if device == 'cuda' else model.to('cpu')
    # Read the input image
    frame = cv2.imread(source)
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

            # Draw bounding box
            cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 255, 0), line_thickness)

            # Display count on the frame at top-right corner
            fish_counts[fish_type] += 1
'''
    # Display the counts on the frame at top-right corner
    count_label = " | ".join([f'{name}: {count}' for name, count in fish_counts.items()])
    cv2.putText(frame, count_label, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

    # Display the frame with fish count
    if view_img:
        cv2.imshow('Frame', frame)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    # Save the frame if specified
    if save_img:
        output_path = Path('/path/to/output') / 'exp' / f'{Path(source).stem}_counted.jpg'
        cv2.imwrite(str(output_path), frame)
'''
# Example usage in VS Code


run(weights=weights_path, source=image_path, device='cpu', view_img=True, save_img=True)
