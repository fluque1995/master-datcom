import cv2
import numpy as np
import os

imgs_list = []

for filename in os.listdir("data/pedestrians_neg"):
    imgs_list.append(cv2.imread("data/pedestrians_neg/{}".format(filename)))

list_len = len(imgs_list)

for i in range(924):
    img_id = np.random.randint(list_len)
    img = imgs_list[img_id]
    img_x = img.shape[0]
    img_y = img.shape[1]

    x = np.random.randint(img_x - 128)
    y = np.random.randint(img_y - 64)

    img_patch = img[x:x+128, y:y+64, :]

    cv2.imwrite("data/negative/{}.ppm".format(i), img_patch)
