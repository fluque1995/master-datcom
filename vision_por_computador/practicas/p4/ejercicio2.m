distorsion2 = imread("distorsion2.jpg");
rostro1 = imread("rostro1.png");
rostro2 = imread("rostro2.png");

% Para la primera imagen, tenemos un emborronamiento del primer plano
F = fspecial('unsharp');
distorsion2_treated = imfilter(distorsion2, F);
distorsion2_treated = medfilt3(distorsion2_treated);
subplot(1,2,1);
imshow(distorsion2);
title("Imagen distorsionada");
subplot(1,2,2);
imshow(distorsion2_treated);
title("Imagen tratada");
pause

%Para las imágenes de los rostros, tenemos un emborronamiento en el primer
%caso y ruido gaussiano en el segundo.
H = fspecial("unsharp");
rostro1_sharp = imfilter(rostro1, H);
G = fspecial("gaussian", 5, 1.5);
rostro2_gauss = imfilter(rostro2, G);
subplot(2,2,1);
imshow(rostro1);
title("Rostro 1 - sin tratar");
subplot(2,2,2);
imshow(rostro1_sharp);
title("Rostro 1 - bordes resaltados");
subplot(2,2,3);
imshow(rostro2);
title("Rostro 2 - sin tratar");
subplot(2,2,4);
imshow(rostro1_sharp);
title("Rostro 2 - Filtrado gaussiano");