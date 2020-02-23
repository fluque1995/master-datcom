import numpy as np
import cv2

class LBPDescriptor():
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

        self.pix_order = [
            (-1, -1), (-1, 0), (-1, 1), (0,-1),
            (0, 1), (1, -1), (1, 0), (1, 1)
        ]

    def _lbp_descriptor(self, mat):
        ## Packbits interpreta un array de 8 valores binarios como
        ## un valor entero entre 0 y 255
        return np.packbits([
            mat[i+1, j+1] >= mat[1,1] for i, j in self.pix_order
        ])[0]

    def _lbp_histogram(self, block):
        hist = [0]*256
        for i in range(1, self.bx - 1):
            for j in range(1, self.by - 1):
                desc = self._lbp_descriptor(block[i-1:i+2, j-1:j+2])
                hist[desc] += 1

        return hist

    def compute(self, img):
        descriptor_list = []
        for i in range(0, self.wx, self.dx):
            for j in range(0, self.wy, self.dy):
                if i + self.bx <= self.wx and j + self.by <= self.wy:
                    descriptor_list.append(
                        self._lbp_histogram(
                            img[i:i+self.bx+1, j:j+self.by+1]
                        )
                    )

        return np.array(descriptor_list).flatten().astype(np.float32)
