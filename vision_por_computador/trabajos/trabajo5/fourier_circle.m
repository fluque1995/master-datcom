function [img_recovered] = fourier_circle(x, y, r)
    %PLOT_CIRCLE Summary of this function goes here
    %   Detailed explanation goes here
    img = zeros(256, 256);
    img = complex(img,0);

    for i = 1:256
        for j = 1:256
            if (i - x)^2 + (j - y)^2 < r^2
                img(i,j) = 1;
            end
        end
    end

    img_recovered = real(ifft2(img));
end

