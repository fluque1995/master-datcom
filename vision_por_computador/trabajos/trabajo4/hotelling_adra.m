adra1 = double(imread("adra/banda1.tif"));
adra2 = double(imread("adra/banda2.tif"));
adra3 = double(imread("adra/banda3.tif"));
adra4 = double(imread("adra/banda4.tif"));
adra5 = double(imread("adra/banda5.tif"));
adra6 = double(imread("adra/banda6.tif"));

bandas = cat(3, adra1, adra2, adra3, adra4, adra5, adra6);

[output, ev] = hotelling_transform(bandas);

subplot(2,3,1);
imshow(output(:,:,1), []);
subplot(2,3,2);
imshow(output(:,:,2), []);
subplot(2,3,3);
imshow(output(:,:,3), []);
subplot(2,3,4);
imshow(output(:,:,4), []);
subplot(2,3,5);
imshow(output(:,:,5), []);
subplot(2,3,6);
imshow(output(:,:,6), []);