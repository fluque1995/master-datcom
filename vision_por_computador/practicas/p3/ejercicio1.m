% Apartado a), utilizamos una función lineal para convertir el intervalo
% [mínimo_imagen, máximo_imagen] en el intervalo [0,255]
mujer = imread("mujer.jpg");
min_mujer = min(mujer(:));
max_mujer = max(mujer(:));
mujer = 255*double(mujer-min_mujer)/double(max_mujer-min_mujer);
imshow(uint8(round(mujer)));
pause

% Apartado b), realizamos el ajuste anterior con imadjust
mujer = imread("mujer.jpg");
range = stretchlim(mujer);
mujer = imadjust(mujer, range, [0 1]);
imshow(mujer);
pause

% Apartado c), aplicamos una función de tipo gamma sobre la imagen. Se
% muestran los histogramas para ver cómo se modifica el mismo al utilizar
% esta función de transferencia. Podemos ver cómo el los valores pequeños
% se mapean a valores a más distancia, haciendo que los colores oscuros
% crezcan más rápido que los claros, debido a un coeficiente gamma menor
% que 1
mujer = imread("mujer.jpg");
range = stretchlim(mujer);
mujer_gamma = imadjust(mujer, range, [0 1], 0.5);
subplot(1,2,1);
histogram(mujer);
subplot(1,2,2);
histogram(mujer_gamma);
pause
subplot(1,1,1);
imshow(mujer_gamma);
pause

% Apartado d), aplicamos una función de transferencia lineal a trozos.
mujer = imread("mujer.jpg");
mujer = imadjust(mujer, [100/255 1], [0 1]);
histogram(mujer);
pause
imshow(mujer);
pause

% Apartado e), equalizamos la imagen
mujer = imread("mujer.jpg");
mujer = histeq(mujer);
imshow(mujer);


