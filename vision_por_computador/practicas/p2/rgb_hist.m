function rgb_hist(rgb_img)
    subplot(1,4,1);
    imshow(rgb_img);
    title("Imagen");
    subplot(1,4,2);
    imhist(rgb_img(:,:,1));
    title("Rojo");
    subplot(1,4,3);
    imhist(rgb_img(:,:,2));
    title("Verde");
    subplot(1,4,4);
    imhist(rgb_img(:,:,3));
    title("Azul");
end

