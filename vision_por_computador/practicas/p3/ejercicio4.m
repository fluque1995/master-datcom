mujer = imread("mujer.jpg");
mujer_adapt = adapthisteq(mujer);
subplot(1,2,1);
histogram(mujer);
subplot(1,2,2);
histogram(mujer_adapt);
pause
subplot(1,2,1);
imshow(mujer);
subplot(1,2,2)
imshow(mujer_adapt);

% Como podemos observar en el resultado, el histograma tiene un aspecto
% mucho más continuo. Dejan de existir barras aisladas, de forma que los
% tonos de color son mucho más homogéneos. Además, las barras de mayor
% longitud se sitúan más en el centro del histograma, haciendo así que haya
% menos extremos. Al haber un mayor reparto de tonos, los colores son menos
% homogéneos (la imagen deja de estar dominada por unos pocos tonos, lo
% cual hace que los bordes estén mejor definidos
