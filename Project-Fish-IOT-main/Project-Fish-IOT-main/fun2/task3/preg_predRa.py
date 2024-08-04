import cv2
import numpy as np
from tflite_runtime.interpreter import Interpreter


model_pathpr='/home/pi/Desktop/Fish_IoT/fun2/task3/Fish_Preg_Converted_model1.tflite'
image_pathpr = '/home/pi/Desktop/Fish_IoT/fun2/task3/Test_Images/captured_image.jpg'
def detect_pregnant_fish(image_pathpr,model_pathpr, threshold=0.1):
    # Load the TFLite model
    interpreter = Interpreter(model_pathpr)
    interpreter.allocate_tensors()

    input_tensor_index = interpreter.get_input_details()[0]['index']
    output = interpreter.tensor(interpreter.get_output_details()[0]['index'])

    # Load and preprocess the input image
    input_image = cv2.imread(image_pathpr)
    input_image = cv2.resize(input_image, (128, 128))
    input_image = input_image / 255.0  # Normalize to [0, 1]
    input_image = np.expand_dims(input_image, axis=0).astype(np.float32)

    # Perform inference
    interpreter.set_tensor(input_tensor_index, input_image,)
    interpreter.invoke()
    yhat = output()[0][0]

    # Check the prediction
    pregnant_detected = yhat > threshold

    # Assign the result to a variable
    if pregnant_detected:
        result = "Pregnant Fish Detect"
    else:
        result = "Non Pregnant Fish Detect"

    return pregnant_detected, result

# Example usage

pregnant_detected, result = detect_pregnant_fish(image_pathpr,model_pathpr)

print(result)
