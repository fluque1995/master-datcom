original = imread("formas.png");
cuadrado = imread("cuadrado.png");
ovalo = imread("ovalo.png");
estrella = imread("estrella.png");

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
letra_o = imread("letra_o.png");
letra_o = rgb2gray(letra_o);

detect_letters(letra_i, text, 0.95)
pause
detect_letters(letra_k, text, 0.95)
pause
detect_letters(letra_m, text, 0.99)
pause
detect_letters(letra_o, text, 0.99)

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
    imshow(result)
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
    imshow(result)
end