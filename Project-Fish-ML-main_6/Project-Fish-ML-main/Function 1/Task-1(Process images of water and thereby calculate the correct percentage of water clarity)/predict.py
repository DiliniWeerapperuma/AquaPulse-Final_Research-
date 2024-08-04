from ultralytics import YOLO
import numpy as np

model = YOLO('/content/drive/MyDrive/last (2).pt')  # load a custom model

results = model('/content/drive/MyDrive/Test Dataset/Dirty/IMG_20231203_155141.jpg')  # predict on an image

names_dict = results[0].names

probs = results[0].probs.data.tolist()

print("Class Names:", names_dict)
print("Probabilities:", probs)

# Find the index with the highest probability
max_prob_index = np.argmax(probs)
max_prob = probs[max_prob_index]

# Convert the result into percentage with 5 decimal points
max_prob_percentage = format(max_prob * 100, '.5f')

print("Predicted Class:", names_dict[max_prob_index])
print("Predicted Class Probability (%):", max_prob_percentage)
