from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from pathlib import Path
from ultralytics import YOLO
import numpy as np

app = FastAPI()

# CORS (Cross-Origin Resource Sharing) Middleware
origins = ["*"]  # You can specify specific origins if needed
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the YOLO model
model_path = r"C:\Users\theekshana\Desktop\Task-1\Weights\last (2).pt"
model = YOLO(model_path)
names_dict = model.names

# Specify the custom directory
custom_directory = r"C:\Users\theekshana\Desktop\Task-1\Test Dataset"

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        # Save the uploaded image to the custom directory
        image_path = Path(custom_directory).joinpath(file.filename)
        print(f"Image Path: {image_path}")

        with open(image_path, "wb") as buffer:
            buffer.write(file.file.read())

        # Predict on the image
        results = model(image_path)
        probs = results[0].probs.data.tolist()

        # Prepare the response with all class probabilities
        all_class_probs = {class_name: prob * 100 for class_name, prob in zip(names_dict, probs)}

        # Find the index with the highest probability
        max_prob_index = np.argmax(probs)
        max_prob = probs[max_prob_index]

        # Convert the result into a percentage with 5 decimal points
        max_prob_percentage = format(max_prob * 100, '.5f')

        # Prepare the final response
        response_data = {
            "all_class_probabilities": all_class_probs,
            "predicted_class": names_dict[max_prob_index],
            "predicted_class_probability": max_prob_percentage,
        }

        # Print the result to the console
        print("All Class Probabilities:", all_class_probs)
        print("Predicted Class:", names_dict[max_prob_index])
        print("Predicted Class Probability (%):", max_prob_percentage)

        return JSONResponse(content=response_data)

    except Exception as e:
        print(f"Error: {str(e)}")
        return JSONResponse(content={"error": str(e)}, status_code=500)