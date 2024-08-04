from ultralytics import YOLO
import numpy as np

model = YOLO(r"C:\Users\theekshana\Desktop\Task-1\Weights\last (2).pt")  # load a custom model

results = model(r"C:\Users\theekshana\Desktop\Task-1\Test Dataset\images.jpg")  # predict on an image

names_dict = model.names

probs = results.xyxy[0][:, -1].cpu().numpy().tolist()

print("Class Names:", names_dict)
print("Probabilities:", probs)

# Find the index with the highest probability
max_prob_index = np.argmax(probs)
max_prob = probs[max_prob_index]

# Convert the result into percentage with 5 decimal points
max_prob_percentage = format(max_prob * 100, '.5f')

print("Predicted Class:", names_dict[max_prob_index])
print("Predicted Class Probability (%):", max_prob_percentage)







