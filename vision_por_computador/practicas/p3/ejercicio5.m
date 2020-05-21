paisaje = imread("paisaje.jpg");

paisaje_1 = rgb2lab(paisaje);
L = paisaje_1(:,:,1)/100;
L = adapthisteq(L);
paisaje_1(:,:,1) = 100*L;
paisaje_1 = lab2rgb(paisaje_1);
paisaje_2 = imadjust(paisaje, [], [], 0.7);
paisaje_3 = rgb2hsv(paisaje);
paisaje_3(:,:,3) = histeq(paisaje_3(:,:,3));
paisaje_3 = hsv2rgb(paisaje_3);
paisaje_4 = rgb2hsv(paisaje);
paisaje_4(:,:,2) = histeq(paisaje_4(:,:,2));
paisaje_4(:,:,3) = histeq(paisaje_4(:,:,3));
paisaje_4 = hsv2rgb(paisaje_4);


subplot(2,2,1);
imshow(paisaje_1)
title("Equalización del histograma con adapthisteq")
subplot(2,2,2);
imshow(paisaje_2)
title("Ajuste gamma con gamma = 0.7")
subplot(2,2,3);
imshow(paisaje_3)
title("Equalización de la banda V")
subplot(2,2,4);
imshow(paisaje_4)
title("Equalización de las bandas SV")

% La primera de las equalizaciones realizadas resalta la banda L del mapa
% de colores LAB, lo cual produce un resalto de los bordes. El segundo
% realiza se hace a través de una función gamma, que elimina parte de la
% oscuridad de la imagen. La tercera, equaliza el histograma de la banda V,
% lo cual mejora la oscuridad de la imagen, resaltando las partes de la
% montaña que estaban más oscuras. La última equaliza también la banda S,
% aumentando la saturación de la imagen. Los cuatro resultados son
% significativamente distintos, y serán más o menos adecuados para la
% utilización posterior de la imagen. A la hora de ser presentada para que
% la vea una persona, probablemente una de las dos de abajo sea la más
% adecuada, ya que los colores son más vivos y están más claras, lo que
% hace que sea más sencillo apreciar los detalles a simple vista. Las dos
% de arriba quedan un poco oscuras.