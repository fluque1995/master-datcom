img = imread("danza.ppm");

img = rgb2hsv(img);

img(:,:,1) = mod(img(:,:,1) + 0.2, 1);

imtool(hsv2rgb(img))