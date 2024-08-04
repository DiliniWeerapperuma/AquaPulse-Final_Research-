from ultralytics import YOLO

model = YOLO(r"C:\Users\theekshana\Desktop\bestFFFF.pt")
model.predict(source=r"C:\Users\theekshana\Desktop\Test_1.mp4", show=True)
