import numpy as np
import cv2

class LBPDescriptor():
    def __init__(self, dx, dy, bx, by, wx, wy, uniform = False):
        ## Increment
        self.dx = dx
        self.dy = dy

        ## Block size
        self.bx = bx
        self.by = by

        ## Window size
        self.wx = wx
        self.wy = wy

        self.uniform = uniform

        self.displacements = [
            (1, 1), (1, 0), (1, -1), (0, -1),
            (-1, -1), (-1, 0), (-1, 1), (0, 1),
        ]

        self.uniform_mapping = np.array([0, 1, 2, 3, 4, 58, 5, 6, 7,
            58, 58, 58, 8, 58, 9, 10, 11, 58, 58, 58, 58, 58, 58, 58,
            12, 58, 58, 58, 13, 58, 14, 15, 16, 58, 58, 58, 58, 58,
            58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 17, 58, 58, 58,
            58, 58, 58, 58, 18, 58, 58, 58, 19, 58, 20, 21, 22, 58,
            58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
            58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
            58, 58, 23, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
            58, 58, 58, 58, 24, 58, 58, 58, 58, 58, 58, 58, 25, 58,
            58, 58, 26, 58, 27, 28, 29, 30, 58, 31, 58, 58, 58, 32,
            58, 58, 58, 58, 58, 58, 58, 33, 58, 58, 58, 58, 58, 58,
            58, 58, 58, 58, 58, 58, 58, 58, 58, 34, 58, 58, 58, 58,
            58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
            58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 35,
            36, 37, 58, 38, 58, 58, 58, 39, 58, 58, 58, 58, 58, 58,
            58, 40, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
            58, 58, 58, 41, 42, 43, 58, 44, 58, 58, 58, 45, 58, 58,
            58, 58, 58, 58, 58, 46, 47, 48, 58, 49, 58, 58, 58, 50,
            51, 52, 58, 53, 54, 55, 56, 57])

    def _compute_cooccurrency_imgs(self, img):
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        comparisons = np.array([
            gray <= np.roll(gray, disp, axis=(0,1))
            for disp in self.displacements
        ])

        return comparisons.astype(np.int)

    def _compute_lbp_pixel_values(self, cooccurrency_mat):
        importance_mat = cooccurrency_mat * np.array(
            [2**i for i in range(7, -1, -1)]
        ).reshape((8,1,1))

        return np.sum(importance_mat, axis=0)

    def _compute_uniform_lbp(self, classical_lbp):
        return self.uniform_mapping[classical_lbp]

    def compute(self, img):
        difs = self._compute_cooccurrency_imgs(img)
        lbp_pixels = self._compute_lbp_pixel_values(difs)

        if self.uniform:
            lbp_pixels = self._compute_uniform_lbp(lbp_pixels)

        nbatch = 59 if self.uniform else 256

        lbp_descriptors = [
            np.histogram(lbp_pixels[i:i+self.bx,j:j+self.bx],
                         bins=np.arange(nbatch+1))[0]
            for i in range(0, self.wx - self.bx + 1, self.dx)
            for j in range(0, self.wy - self.by + 1, self.dy)
        ]

        return np.array(lbp_descriptors).flatten().astype(np.float32)
