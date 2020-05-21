figuras = imread("formas.png");
esquinas = corner(figuras);
imshow(figuras); hold on;
plot(esquinas(:,1), esquinas(:,2), 'r*');