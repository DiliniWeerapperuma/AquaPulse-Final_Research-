from ultralytics import YOLO
import numpy as np

model = YOLO("C:/Users/ashen/OneDrive/Desktop/Project-Fish-ML/Function 1/Raspberry Pi/last.pt")  # load a custom model

# Make predictions and get the first element of the list
results = model(source="C:/Users/ashen/OneDrive/Desktop/Project-Fish-ML/Function 1/Raspberry Pi/dirty-tank.jpg", show=True, conf=0.4, save=True)[0]

names_dict = model.names

probs = results.probs.data.cpu().numpy().tolist()

print("Class Names:", names_dict)
print("Probabilities:", probs)

# Find the index with the highest probability
max_prob_index = np.argmax(probs)
max_prob = probs[max_prob_index]

# Convert the result into percentage with 5 decimal points
max_prob_percentage = format(max_prob * 100, '.5f')

print("Predicted Class:", names_dict[max_prob_index])
print("Predicted Class Probability (%):", max_prob_percentage)