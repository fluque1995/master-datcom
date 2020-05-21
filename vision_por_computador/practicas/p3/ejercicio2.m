% Ecualización original. Los resultados son malos en ambos casos. La
% distribución de los histogramas de los tres canales de color RGB no es la
% misma, por lo que aplicar el método a los tres canales de forma
% independiente produce problemas de color. Igualmente, al aplicar la
% ecualización a los tres canales de HSV, el canal de color se transforma y
% da lugar a cambios en el color de la imagen.
danza_orig = imread("danza.ppm");
danza_hsv_1 = danza_orig;
danza_hsv = rgb2hsv(danza_orig);

danza_hsv_1(:,:,1) = histeq(danza_hsv_1(:,:,1));
danza_hsv_1(:,:,2) = histeq(danza_hsv_1(:,:,2));
danza_hsv_1(:,:,3) = histeq(danza_hsv_1(:,:,3));

danza_hsv(:,:,1) = histeq(danza_hsv(:,:,1));
danza_hsv(:,:,2) = histeq(danza_hsv(:,:,2));
danza_hsv(:,:,3) = histeq(danza_hsv(:,:,3));

subplot(1,2,1);
imshow(danza_hsv_1);
title("RGB eq por canales");
subplot(1,2,2)
imshow(hsv2rgb(danza_hsv));
title("HSV eq por canales");
pause

% Ĺa ecualización busca, en realidad, evitar que una imagen en blanco y
% negro sea demasiado homogénea, así que lo que está variando son tonos de
% gris, que se pueden ver como luminosidades en HSV. Por tanto, podemos
% equalizar sólamente la componente V de este espacio de color y obtener
% buenos resultados. Opcionalmente se puede equalizar también la
% saturación, aunque en este caso la imagen se satura en exceso en algunos
% puntos.
danza_hsv_1 = rgb2hsv(danza_orig);
danza_hsv_2 = rgb2hsv(danza_orig);

danza_hsv_1(:,:,2) = histeq(danza_hsv_1(:,:,2));
danza_hsv_1(:,:,3) = histeq(danza_hsv_1(:,:,3));

danza_hsv_2(:,:,3) = histeq(danza_hsv_2(:,:,3));

subplot(1,2,1);
imshow(hsv2rgb(danza_hsv_1));
title("HSV eq (canales S y V)");
subplot(1,2,2)
imshow(hsv2rgb(danza_hsv_2));
title("HSV eq (solo canal V)");
pause