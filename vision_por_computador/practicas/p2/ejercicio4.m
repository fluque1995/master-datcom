back = imread("imagenes_chromakey/praga1.jpg");
front = imread("imagenes_chromakey/chromakey_original.jpg");

chroma(back, front, 120, 10, 0.33, 0.05)