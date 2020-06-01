% Creamos dos funciones diferentes para afrontar este problema, debido a
% que en una imagen tenemos letras negras sobre fondo blanco y en otra
% formas blancas sobre fondo negro. Nos será más sencillo trabajar siempre
% con el fondo en negro (valore de píxel bajos) y los objetos en blanco
% (valores de píxel altos). Por ello, lo que haremos será invertir el valor
% de los píxeles del texto para que sean las letras las que quedan en
% blanco. Una vez hecha esa apreciación, la idea del algoritmo es la misma.
% Se realiza la operación de convolución entre la imagen original y la
% forma que queremos reconocer, de forma que para el píxel en cuestión éste
% valor será más alto cuanto mejor esté alineada la forma a detectar (en el
% filtro) con ella misma en la imagen. Así, quedándonos con los valores más
% altos del mapa de respuestas que se produce, tenemos los centros de las
% figuras (o las letras) que vamos buscando. Se colocan las figuras o las
% letras en dicha posición en la imagen para marcar dónde se han
% encontrado.

original = imread("formas.png");
cuadrado = imread("cuadrado.png");
ovalo = imread("ovalo.png");
estrella = imread("estrella.png");

% En la detección de las formas, ocurre cierto problema. Debido a que la
% forma de cuadrado que estamos utilizando encaja correctamente dentro del
% cuadrado girado de mayor tamaño, tenemos falsos positivos,
% correspondientes a dichos puntos. En el caso del óvalo y la estrella, se
% reconocen las cinco formas presentes correctamente en ambos casos.
detect_shapes(cuadrado, original, 0.95)
pause
detect_shapes(ovalo, original, 0.95)
pause
detect_shapes(estrella, original, 0.95)
pause

text = imread("texto.png");
text = rgb2gray(text);
letra_i = imread("letra_i.png");
letra_i = rgb2gray(letra_i);
letra_k = imread("letra_k.png");
letra_k = rgb2gray(letra_k);
letra_m = imread("letra_m.png");
letra_m = rgb2gray(letra_m);
letra_o = imread("letra_o.png");
letra_o = rgb2gray(letra_o);
letra_p = imread("letra_p.png");
letra_p = rgb2gray(letra_p);

% En el caso de las letras, tenemos el mismo problema con la letra i. Esta
% letra encaja completamente tanto en la P de la palabra preview como en la
% I mayúscula de Interest, así que aquí se producen dos falsos positivos.
% El resto de letras, aunque no se ha hecho una revisión minuciosa exacta
% para todas ellas, parecen dar buenos resultados. En particular, la k y la
% m se han comprobado exhaustivamente, y encuentran todas las formas de la
% imagen sin falsos positivos, y la i de la misma manera, a excepción de
% los dos casos anteriores.
detect_letters(letra_i, text, 0.95)
pause
detect_letters(letra_k, text, 0.95)
pause
detect_letters(letra_m, text, 0.99)
pause
detect_letters(letra_o, text, 0.99)
pause
detect_letters(letra_p, text, 0.99)

function detect_shapes(form, image, thr)
    form = im2double(form);
    image = im2double(image);
    detections = imfilter(image, form, 'same');
    [idx, idy] = find(detections >= thr*max(detections(:)));
    result = zeros(size(image));
    for i = 1:length(idx)
        j = idx(i) - round(size(form, 1)/2);
        k = idy(i) - round(size(form, 2)/2);
        j = max(j, 1);
        k = max(k, 1);
        l = j + size(form, 1) - 1;
        m = k + size(form, 2) - 1;
        result(j:l, k:m) = form(1:l-j+1, 1:m-k+1);
    end
    subplot(1,2,1);
    imshow(image);
    title("Imagen original");
    subplot(1,2,2);
    imshow(result);
    title("Forma detectada");
end

function detect_letters(letter, text, thr)
    text = 255 - text;
    letter = 255 - letter;
    letter = im2double(letter);
    text = im2double(text);
    detections = imfilter(text, letter, 'same');
    [idx, idy] = find(detections >= thr*max(detections(:)));
    letter = 1 - letter;
    result = zeros(size(text)) + 1;
    for i = 1:length(idx)
        j = idx(i) - round(size(letter, 1)/2);
        k = idy(i) - round(size(letter, 2)/2);
        l = j + size(letter, 1) - 1;
        m = k + size(letter, 2) - 1;
        result(j:l, k:m) = letter;
    end
    subplot(2,1,1);
    imshow(1 - text);
    title("Texto original");
    subplot(2,1,2);
    imshow(result);
    title("Letra detectada");
end