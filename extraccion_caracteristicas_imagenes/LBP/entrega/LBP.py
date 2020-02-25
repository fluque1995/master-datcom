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


class LBPDetector():
    def __init__(self, dx, dy, bx, by, wx, wy, sx, sy, classifier):
        ## Increment
        self.dx, self.dy = dx, dy

        ## Block size
        self.bx, self.by = bx, by

        ## Window size
        self.wx, self.wy = wx, wy

        ## Step size for region proposal
        self.sx, self.sy = sx, sy

        self.classifier = classifier

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

    def _compute_patch_lbp(self, img_patch):
        histogram = [np.histogram(img_patch[i:i+self.bx,j:j+self.by],
                                  bins=np.arange(60))[0]
                     for i in range(0, self.wx - self.bx + 1, self.dx)
                     for j in range(0, self.wy - self.by + 1, self.dy)
        ]

        return np.array(histogram).reshape((1,-1)).astype(np.float32)

    def _overlap(self, bb1, bb2):
        x11, y11, x12, y12 = bb1[0], bb1[1], bb1[2], bb1[3]
        x21, y21, x22, y22 = bb2[0], bb2[1], bb2[2], bb2[3]

        x1 = x11 if x11 > x21 else x21
        y1 = y11 if y11 > y21 else y21

        x2 = x22 if x12 > x22 else x12
        y2 = y22 if y12 > y22 else y12

        overlap = (y2 - y1)*(x2 - x1)
        b_size = (y12 - y11)*(x12 - x11)

        return overlap / b_size

    def _nms(self, bboxes, thr):
        idx_del = []
        for idx, bbox in enumerate(bboxes[:-1]):
            for idy, bb in enumerate(bboxes[idx+1:]):
                if self._overlap(bbox, bb) > thr:
                    idx_del.append(idx if bb[4] < bbox[4] else idx+idy+1)

        idx_del = list(set(idx_del))
        idx_del.sort(reverse=True)

        return [elem for idx, elem in enumerate(bboxes) if idx not in idx_del]

    def _detect_size(self, img):
        difs = self._compute_cooccurrency_imgs(img)
        lbp_pixels = self._compute_lbp_pixel_values(difs)
        lbp_pixels = self._compute_uniform_lbp(lbp_pixels)

        ix = img.shape[0]
        iy = img.shape[1]

        pedestrians = []

        for i in range(0, ix - self.wx + 1, self.sx):
            for j in range(0, iy - self.wy + 1, self.sy):
                curr_hist = self._compute_patch_lbp(
                    lbp_pixels[i:i+self.wx,j:j+self.wy]
                )

                prediction = self.classifier.predict(
                    curr_hist,
                    flags=cv2.ml.STAT_MODEL_RAW_OUTPUT
                )[1][0][0]

                if (prediction<0):
                    pedestrians.append(
                        (i, j, i+self.wx, j+self.wy, prediction)
                    )

        return pedestrians

    def detect(self, img, zooms):
        detections = []
        for zoom in zooms:
            img_res = cv2.resize(img, None, fx=zoom, fy=zoom)
            dets_zoom = self._detect_size(img_res)
            detections.extend([
                (int(det[0]/zoom), int(det[1]/zoom),
                 int(det[2]/zoom), int(det[3]/zoom), det[4])
                for det in dets_zoom
            ])

        return self._nms(detections, 0.3)
