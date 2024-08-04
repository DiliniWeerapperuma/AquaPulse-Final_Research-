import cv2
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt

img = cv2.imread(r"C:\Users\theekshana\Desktop\Preg - Final\test\Pregnant Fish\TestP7.jpg")
plt.imshow(img)
plt.show()

IMAGE_SIZE = (128, 128)
resized_image = tf.image.resize(tf.convert_to_tensor(img), IMAGE_SIZE)
scaled_image = resized_image / 255

# Make sure to provide the correct path to your saved model
new_model = tf.keras.models.load_model('/path/to/your/saved_model/my_model0')

yhat = new_model.predict(np.expand_dims(scaled_image, 0))

if yhat > 0.1:
    print('Pregnant Fish')
else:
    print('Non Pregnant Fish')
