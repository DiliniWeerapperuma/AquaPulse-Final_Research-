from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
import pandas as pd
import tensorflow as tf
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Load the trained model using TensorFlow
model = tf.keras.models.load_model(r'C:\Users\theekshana\Desktop\ML_2\Model 4-AdamEp1000Bs256')

# Load the scaler and encoder
scaler = joblib.load(r'C:\Users\theekshana\Desktop\ML_2\scaler.joblib')
encoder = joblib.load(r'C:\Users\theekshana\Desktop\ML_2\encoder.joblib')

# Define numerical_features and categorical_features based on your actual data
numerical_features = ['Species Count', 'Sunlight_Exposure', 'Feeding Frequency']
categorical_features = ['Tank Size', 'Uneaten food', 'Water Quality']

# Function for preprocessing input data
def preprocess_input_data(input_data):
    input_numerical = input_data[numerical_features]
    input_categorical = input_data[categorical_features]

    input_numerical_scaled = scaler.transform(input_numerical)
    input_categorical_encoded = encoder.transform(input_categorical).toarray()

    input_final = np.concatenate([input_numerical_scaled, input_categorical_encoded], axis=1)

    return input_final

# Pydantic model for request data
class InputData(BaseModel):
    Species_Count: float
    Sunlight_Exposure: float
    Feeding_Frequency: float
    Tank_Size: str
    Uneaten_food: str
    Water_Quality: str

# Enable CORS (Cross-Origin Resource Sharing)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Set this to your frontend's URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/predict")
async def predict(data: InputData):
    input_data = pd.DataFrame({
        'Species Count': [data.Species_Count],
        'Sunlight_Exposure': [data.Sunlight_Exposure],
        'Feeding Frequency': [data.Feeding_Frequency],
        'Tank Size': [data.Tank_Size],
        'Uneaten food': [data.Uneaten_food],
        'Water Quality': [data.Water_Quality]
    })

    preprocessed_input = preprocess_input_data(input_data)
    predictions = model.predict(preprocessed_input)
    rounded_predictions = np.round(predictions.flatten()).astype(int)

    return {"predicted_days": int(rounded_predictions[0])}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8002)
