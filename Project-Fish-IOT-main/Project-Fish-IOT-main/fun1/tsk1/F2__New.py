from ultralytics import YOLO
import numpy as np

def predict_and_classify(image_path, model_path):
    # Load the YOLO model
    model = YOLO(model_path)

    # Predict on the image
    results = model(image_path)

    # Extract class names and probabilities
    names_dict = results[0].names
    probs = results[0].probs.data.tolist()

    # Find the index with the highest probability
    max_prob_index = np.argmax(probs)
    max_prob = probs[max_prob_index]

    # Convert the result into percentage with 5 decimal points
    max_prob_percentage = format(max_prob * 100, '.5f')

    # Classify based on conditions
    if names_dict[max_prob_index] == "Clear" and float(max_prob_percentage) >= 75:
        feed = "Good"
    elif names_dict[max_prob_index] == "Dirty" and float(max_prob_percentage) >= 75:
        feed = "Bad"
    else:
        feed = "Average"

    # Print the results
    print("Class Names:", names_dict)
    print("Probabilities:", probs)
    print("Predicted Class:", names_dict[max_prob_index])
    print("Predicted Class Probability (%):", max_prob_percentage)
    print("Feed Classification:", feed)

# Example usage:
image_path = '/home/pi/Desktop/Fish_IoT/fun1/tsk1/dirty-tank.jpg'
model_path = '/home/pi/Desktop/Fish_IoT/fun1/tsk1/best (6).pt'
predict_and_classify(image_path, model_path)
