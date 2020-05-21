function chroma(background, foreground, posX, posY, color, tolerance)
    foreground_hsv = rgb2hsv(foreground);
    for i = 1:size(foreground, 1)
        for j = 1:size(foreground, 2)
            if abs(foreground_hsv(i, j) - color) > tolerance
                background(posX + i, posY + j,:) = foreground(i,j,:);
            end
        end
    end
    imshow(background)
end

