% Se lee la imagen desde fichero
disney = imread("disney.png");

% Se muestra con imshow (correctamente)
imshow(disney);
w = waitforbuttonpress;
% Se muestra con imtool (correctamente, se abre una nueva ventana)
imtool(disney);
w = waitforbuttonpress;
% Se muestra con imagesc. La paleta de colores por defecto
% en MATLAB se mueve entre el azul y el amarillo, por lo que
% se alteran los colores. Además, esta función no mantiene
% las proporciones de la imagen
imagesc(disney);
w = waitforbuttonpress;

% Convertimos la imagen a double. Se convierten los valores a double
% pero no se modifica su valor
disneydouble = double(disney);

% Esta conversión no es entendida por imshow ni imtool, que muestran
% imágenes en blanco. imagesc sigue mostrando el mismo resultado que
% antes
imshow(disneydouble);
w = waitforbuttonpress;
imtool(disneydouble);
w = waitforbuttonpress;
imagesc(disneydouble);
w = waitforbuttonpress;

% Ahora se realiza la conversión correctamente, la función im2double
% transforma el intervalo [0,255] de números enteros en el intervalo
% [0,1] de números decimales. De esta forma sí funcionan correctamente
% las funcionas imshow y imtool
disneyim2double = im2double(disney);

imshow(disneyim2double);
w = waitforbuttonpress;
imtool(disneyim2double);
w = waitforbuttonpress;
imagesc(disneyim2double);
w = waitforbuttonpress;