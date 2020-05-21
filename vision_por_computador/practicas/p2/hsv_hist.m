function hsv_hist(rgb_img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    hsv_img = rgb2hsv(rgb_img);
    subplot(1,4,1);
    imshow(rgb_img);
    title("Imagen");
    subplot(1,4,2);
    imhist(im2uint8(hsv_img(:,:,1)), hsv(256));
    title("Color");
    subplot(1,4,3);
    imhist(hsv_img(:,:,2));
    title("Saturación");
    subplot(1,4,4);
    imhist(hsv_img(:,:,3));
    title("Brillo");
end

