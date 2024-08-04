import cv2
from pathlib import Path
from ultralytics import YOLO
from ultralytics.utils.files import increment_path
import time

# Example usage
weights_path_behavior = "/home/pi/Desktop/Fish_IoT/fun2/task2/bestFFFF.pt"
video_path_behavior = "/home/pi/Desktop/Fish_IoT/fun2/task2/Test_1_.mp4"
fish_behavior_counts_array = []

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


while True:
    # Run fish_beh function and store the result in ret
    ret = fish_beh(weights=weights_path_behavior, source=video_path_behavior, device='cpu', save_img=False, save_video=True)

    # Append the result to fish_behavior_counts_array
    fish_behavior_counts_array.append(ret)
    print(fish_behavior_counts_array)
    max_results = 2
    if len(fish_behavior_counts_array) >= max_results:
        print("max_result")
        last_five_results = fish_behavior_counts_array[-max_results:]
        print(last_five_results)
        # Access the dictionary inside the list
        result_dict = last_five_results[0]

        # Extract individual values
        feeding_count = result_dict['Feeding']
        schooling_count = result_dict['Fish-Schooling']
        resting_count = result_dict['Resting']
        swimming_count = result_dict['Swimming']
        
        # Now, you have individual variables containing the counts
        print("Feeding Count:", feeding_count)
        print("Fish-Schooling Count:", schooling_count)
        print("Resting Count:", resting_count)
        print("Swimming Count:", swimming_count)

        # Calculate total count
        total_count = feeding_count + schooling_count + resting_count + swimming_count
        # Print or use the total count as needed
        print("Total Count:", total_count)
        
        # Check if resting_count/feeding_count is equal to a specific value
        ratio_condition = resting_count / feeding_count

        if ratio_condition == 0:
            behavioral = False
            print("Resting Count / Feeding Count ratio is equal to 0:")
            print(behavioral)
        else:
            behavioral = True
            print(f"Resting Count / Feeding Count ratio is NOT equal to 0. Behavioral variable set to True.:")
            print(behavioral)
            # Your additional logic for the else case goes here
        
        # Check if schooling_count is the same in the last max_results frames
        behavioral_scl = all(result_dict['Fish-Schooling'] == last_result['Fish-Schooling'] for last_result in last_five_results[1:])
         
        scl_behavr = all(result['Fish-Schooling'] == last_five_results[0]['Fish-Schooling'] != 0 for result in last_five_results)

        if scl_behavr:
            print("Fish-Schooling count is equal in all elements and not equal to 0. scl_behavr variable set to True.")
            print(scl_behavr)
            
            
            # Your additional logic for the True case goes here
        else:
            print("Fish-Schooling count is NOT equal in all elements or equal to 0. scl_behavr variable set to False.")
            print(scl_behavr)
            # Your additional logic for the False case goes here
        
        # Reset max_results
        max_results = 0
        # Reset fish_behavior_counts_array to an empty list
        fish_behavior_counts_array = []

    else:
        print("Condition not met. Continue loop.")

    # Print statements and sleep
    print("shsissshss")
    print("shsissshss")
    print("shsissshss")
    time.sleep(100)



# Assuming beha_array contains the output [{'Feeding': 2, 'Fish-Schooling': 1, 'Resting': 0, 'Swimming': 0}]
'''
# Access the dictionary inside the list
result_dict = fish_behavior_counts_array[0]

# Extract individual values
feeding_count = result_dict['Feeding']
schooling_count = result_dict['Fish-Schooling']
resting_count = result_dict['Resting']
swimming_count = result_dict['Swimming']

# Now, you have individual variables containing the counts
print("Feeding Count:", feeding_count)
print("Fish-Schooling Count:", schooling_count)
print("Resting Count:", resting_count)
print("Swimming Count:", swimming_count)

# Assuming feeding_count, schooling_count, resting_count, swimming_count are defined

# Calculate total count
total_count = feeding_count + schooling_count + resting_count + swimming_count

# Print or use the total count as needed
print("Total Count:", total_count)

'''


