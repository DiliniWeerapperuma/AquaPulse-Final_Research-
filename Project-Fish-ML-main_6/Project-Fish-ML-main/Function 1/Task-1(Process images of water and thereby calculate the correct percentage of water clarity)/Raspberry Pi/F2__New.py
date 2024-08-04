from ultralytics import YOLO

model = YOLO(r"C:\Users\theekshana\Desktop\Task-1\Weights\last (2).pt")
model.predict(source=r"C:\Users\theekshana\Desktop\Task-1\Test Dataset\866ae9bcde94dcd5c4218d0ae1e7735c5cb391a7b72373cb0a74cc7cb25776b6.0.JPG", show=True)




