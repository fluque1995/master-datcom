# Instalar opencv con pip:
# pip install opencv-python

# Importamos paquete opencv
import cv2


# Leemos la imagen

str_img_prueba = "Fry.jpg"
image = cv2.imread(str_img_prueba)
print("Tamaño de imagen: "+str(image.shape))

# La opencv para python representa las imágenes como un array de tres dimensiones
# Usa la librería numpy para ello
# print(type(image))

# Obtenemos una versión en nivel de gris y otra suavizada
gris = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
blur = cv2.blur(gris, (3, 3))

# Podemos mostrar las imágenes
# cv2.imshow('Imagen difuminada', blur)
# cv2.imshow('Imagen en nivel de gris', gris)
# cv2.waitKey(0)

# 1. Canny
canny = cv2.Canny(blur, 10, 100)

# 2. Harris
harris = cv2.cornerHarris(gris,2,3,0.04)
# harris = cv2.dilate(harris,None) # Resalta (no necesario)
# Para visualizar, normalizo entre 0 y 255
# aunque devuelva el resultado, es necesario pasarle None como imagen destino
harris = cv2.normalize(harris, None, 0, 255, cv2.NORM_MINMAX)
harris = cv2.convertScaleAbs(harris, None)
# Umbralizo (no necesario, solo para ver los valores mayores)
# En python, cv2.threshold devuelve el valor de threshold y la imagen resultado
# ret_val, harris_bin = cv2.threshold(harris, 128, 255, cv2.THRESH_BINARY)
# cv2.imshow('Harris Binary', harris_bin)
# cv2.waitKey(0)

# 3. HOG
# Constructor por defecto.
# block size: 16x16, window size: 64x128, stride size: 8x8,
# cell size: 8x8, number of bins: 9, descriptor size: 3780
hog = cv2.HOGDescriptor()

# Otra opcion sería indicar los tamaños de celda, bloque, etc.
# win_size = (32,128)
# cell_size = (8,8)
# block_size = (16,16)
# block_stride = (8,8)
# n_bins_orientacion = 9
# hog = cv2.HOGDescriptor(win_size,block_size,block_stride,cell_size,n_bins_orientacion)
descriptors = hog.compute(image)
print("""\nHOG ({0}):
    block size: {1},
    window size: {2},
    stride size: {3},
    cell size: {4},
    number of bins: {5},
    descriptor size: {6}\n""".format(
    len(descriptors),
    hog.blockSize,
    hog.winSize,
    hog.blockStride,
    hog.cellSize,
    hog.nbins, hog.getDescriptorSize()))

# 4. SIFT
# La forma de crear los puntos SIFT sería la que se muestra a
# continuación, pero desde la versión 3.x no está en la distribución
# básica. Los descriptores SIFT, así como otros que están protegidos
# por derechos de autor, se encuentran en la extensión 'opencv_contrib'
# (es necesario compilar a partir de las fuentes)
# img_sift = image
# sift = cv2.xfeatures2d.SIFT_create()
# kp = sift.detect(gris, None)
# img_sift = cv2.drawKeypoints(gris,kp,img_sift)
# cv2.imshow('Puntos SIFT', img_sift)
# cv2.waitKey(0)


# A modo de ejemplo, se calculan otros puntos sí disponibles en la
# distribución básica
fd  = cv2.FastFeatureDetector_create()
kp = fd.detect(gris, None);
img_sift = cv2.drawKeypoints(gris, kp, None)

# Mostramos resultados
cv2.imshow(str_img_prueba, image)
cv2.imshow('Canny', canny)
cv2.imshow('Harris', harris)
cv2.imshow('SIFT', img_sift)
cv2.waitKey(0)

#5. Clasificación
import cv2
import ejemplo_clasificador
preds, classes = ejemplo_clasificador.ejemplo_clasificador_imagenes()
