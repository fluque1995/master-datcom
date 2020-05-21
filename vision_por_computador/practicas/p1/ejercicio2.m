rosa = imread("rosa.jpg");

% Mostramos la imagen original junto con los tres canales en blanco y
% negro. Podemos observar cómo los pétalos rojos, rosas y amarillos, en el
% mapa rojo se observan blancos (equivalente a valores altos). Para los
% pétalos amarillos y verdes ocurre lo mismo en el mapa verde, y para los
% azules y morados en el mapa azul. Asímismo, el fondo, que tiene un tono
% malva, está activado en los mapas azul y rojo especialmente, y mucho
% menos en el verde.
subplot(2,2,1);
imshow(rosa);
subplot(2,2,2);
imshow(rosa(:,:,1));
subplot(2,2,3);
imshow(rosa(:,:,2));
subplot(2,2,4);
imshow(rosa(:,:,3));

% Anulamos la componente roja de la imagen, lo que la convierte, por un
% lado, en una imagen mucho más oscura, y por otro, mucho más fria, ya que
% hemos eliminado los tonos rojos. Los pétalos rojizos pasan a ser casi
% negros, los morados pasan a ser azules, y los amarillos se vuelven
% verdes.
rosa_copy = rosa;
rosa_copy(:,:,1) = 0;
imtool(rosa_copy);

% Si ahora anulamos los verdes, la imagen toma tonos muy rojizos y morados.
% Al no haber pétalos completamente verdes, estos se vuelven de un tono
% morado oscuro, pero no llegan a verse negros. Ahora, los pétalos
% amarillos se vuelven rojos en lugar de verdes.
rosa_copy = rosa;
rosa_copy(:,:,2) = 0;
imtool(rosa_copy);

sintetica = imread("sintetica.jpg");
imtool(sintetica);

% Tomamos una nueva imagen y probamos otro tipo de transformaciones. En
% primer lugar, vamos a invertir sólo uno de los canales de color. Podemos
% observar cómo los tonos marrones de la piel, que contienen bastante rojo,
% ahora se tornan azulados, debido a la falta de este color. En cambio, el
% pelo, que era negro, se torna rojo, ya que el valor de este canal en esta
% zona aumenta
sint_copy = sintetica;
sint_copy(:,:,1) = 255 - sint_copy(:,:,1);
imtool(sint_copy);

% Ahora, desplazamos dos de los canales, uno en vertical y otro en
% horizontal. Esto hace que la imagen se vea distorsionada, porque la
% silueta del individuo se desalinea entre los tres canales, lo cual da
% sensación de mareo
sint_copy = sintetica;
sint_copy(:,:,1) = circshift(sint_copy(:,:,1), 10, 2);
sint_copy(:,:,2) = circshift(sint_copy(:,:,2), 10, 1);
imtool(sint_copy);

% Ahora, reordenamos los canales. El canal rojo pasa a ser el verde, el
% verde toma el lugar del azul, y el azul toma el lugar del rojo. Podemos
% observar cómo la imagen se torna verdosa, lo cual nos indica que en la
% imagen original la mayor parte del color era rojo
sint_copy = sintetica;
sint_copy = circshift(sint_copy, 1, 3);
imtool(sint_copy);