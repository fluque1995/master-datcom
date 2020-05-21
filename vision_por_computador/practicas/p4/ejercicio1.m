disney1 = imread("disney_r1.png");
disney2 = imread("disney_r2.png");
disney3 = imread("disney_r3.png");
disney4 = imread("disney_r4.png");
disney5 = imread("disney_r5.png");

subplot(3,5,1);
imshow(disney1);
subplot(3,5,2);
imshow(disney2);
subplot(3,5,3);
imshow(disney3);
title("Imágenes originales")
subplot(3,5,4);
imshow(disney4);
subplot(3,5,5);
imshow(disney5);

subplot(3,5,6);
imshow(medfilt2(disney1));
subplot(3,5,7);
imshow(medfilt2(disney2));
subplot(3,5,8);
imshow(medfilt2(disney3));
title("Filtros de mediana")
subplot(3,5,9);
imshow(medfilt2(disney4));
subplot(3,5,10);
imshow(medfilt2(disney5));

fg=fspecial('gaussian',3,1.5);
subplot(3,5,11);
imshow(imfilter(disney1, fg));
subplot(3,5,12);
imshow(imfilter(disney2, fg));
subplot(3,5,13);
imshow(imfilter(disney3, fg));
title("Filtros gaussianos")
subplot(3,5,14);
imshow(imfilter(disney4, fg));
subplot(3,5,15);
imshow(imfilter(disney5, fg));

% En las tres primeras imágenes tenemos distintos ruidos de tipo sal y 
% pimienta. Por este motivo, el filtro de mediana ofrece mejores resultados 
% que el filtro gaussiano, ya que la mediana es más robusta a valores 
% extremos que la media ponderada. A pesar de esto, cuando el ruido es
% demasiado fuerte, ninguno de los filtros es capaz de eliminar
% completamente el ruido presente. Los dos últimos ruidos parecen ser
% gaussianos, ya que el filtro de gaussiana arroja mejores resultados que
% el de mediana. Aun así, al igual que en el caso anterior, la presencia de
% un ruido excesivo no es eliminada completamente por ninguno de los
% filtros.