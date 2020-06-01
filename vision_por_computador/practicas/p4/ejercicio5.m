% La función detectHarrisFeatures devuelve los puntos Harris encontrados en
% una imagen. Se pueden filtrar los $k$ puntos más relevantes, pero se ha
% decidido mostrarlos todos para comprobar cómo se distribuyen perfectamente 
% en las aristas que definen las formas. En una segunda imagen se han
% filtrado los más relevantes para ver cómo en efecto se sitúan primero en
% las esquinas, y después se distribuyen por los bordes.

figuras = imread("formas.png");
esquinas = detectHarrisFeatures(figuras);
subplot(1,2,1);
imshow(figuras); hold on;
plot(esquinas);
subplot(1,2,2);
imshow(figuras); hold on;
plot(selectStrongest(esquinas, 170));