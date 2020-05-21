porter = imread("castillo.png");
message = imread("vacas.png");

porter_with_message = hide_image(porter, message);
imshow(porter_with_message);

pause

recovered_message = recover_image(porter_with_message, porter);
imshow(recovered_message);