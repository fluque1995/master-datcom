% Leemos la imagen, y utilizamos imadjust definiendo el intervalo de salida
% (entre 110 y 190), y el intervalo de llegada (entre 0 y 255). Aplicamos
% también una transformación gamma de 0.75.
campo = imread("campo.ppm");
campo = imadjust(campo, [110/255, 190/255], [0 1], 0.75);
imshow(campo)