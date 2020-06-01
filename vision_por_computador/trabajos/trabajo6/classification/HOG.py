import numpy as np
import cv2

class HOGDescriptor():
    def __init__(self, dx, dy, bx, by, wx, wy):
        ## Increment
        self.dx = dx
        self.dy = dy

        ## Block size
        self.bx = bx
        self.by = by

        ## Window size
        self.wx = wx
        self.wy = wy

    def _compute_gradient_intensity_and_direction(self, img):
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        horz_gradient = cv2.filter2D(gray, -1, np.array([-1,0,1], ndmin=2))
        vert_gradient = cv2.filter2D(
            gray, -1, np.array([[-1],[0],[1]], ndmin=2)
        )
        intensity_map = np.sqrt(
            np.square(horz_gradient) + np.square(vert_gradient)
        )
        direction_map = np.rad2deg(
            np.arctan(np.divide(vert_gradient, horz_gradient + 0.0000001))
        ) + 90

        return (intensity_map, direction_map)

    def compute(self, img):
        intensity, direction = self._compute_gradient_intensity_and_direction(
            img
        )

        prev_direction = (np.floor(np.divide(direction - 10, 20))*20)+10
        post_direction = prev_direction + 20

        dist_to_prev = 20 - (direction - prev_direction)
        dist_to_post = 20 - (post_direction - direction)

        weight_prev = (intensity * dist_to_prev) / 20
        weight_post = (intensity * dist_to_post) / 20

        prev_direction[prev_direction == -10] = 170
        post_direction[prev_direction == 190] = 10

        prev_descriptors = [
            np.bincount(
                prev_direction[i:i+self.bx,j:j+self.bx].flatten().astype(np.int64),
                weights=weight_prev[i:i+self.bx,j:j+self.bx].flatten()
            )
            for i in range(0, self.wx - self.bx + 1, self.dx)
            for j in range(0, self.wy - self.by + 1, self.dy)
        ]

        post_descriptors = [
            np.bincount(
                post_direction[i:i+self.bx,j:j+self.bx].flatten().astype(np.int64),
                weights=weight_post[i:i+self.bx,j:j+self.bx].flatten()
            )
            for i in range(0, self.wx - self.bx + 1, self.dx)
            for j in range(0, self.wy - self.by + 1, self.dy)
        ]

        prev_descs = [
            np.append(elem, 0).take(
                [10,30,50,70,90,110,130,150,170], mode="clip"
            )
            for elem in prev_descriptors
        ]

        post_descs = [
            np.append(elem, 0).take(
                [10,30,50,70,90,110,130,150,170], mode="clip"
            )
            for elem in post_descriptors
        ]
        descriptors = np.array(prev_descs) + np.array(post_descs)
        return (
            descriptors / (np.max(descriptors, axis=1) + 0.000001).reshape((-1,1))
        ).flatten()
