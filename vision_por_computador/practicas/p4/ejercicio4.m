distorsion = imread("distorsion1.jpg");

G = fspecial('gaussian', 5, 1.5);
filtrado_gaussian = imfilter(distorsion, G);

M = fspecial('motion', 10, 0);
filtrado_motion = imfilter(distorsion, M);

subplot(1,3,1);
imshow(distorsion)
subplot(1,3,2);
imshow(filtrado_gaussian)
subplot(1,3,3);
imshow(filtrado_motion)