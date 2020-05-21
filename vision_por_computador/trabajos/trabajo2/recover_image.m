function [output_image] = recover_image(input_image, original_image)
    message = bitxor(input_image, original_image);
    values = unique(message);
    output_image = zeros(size(input_image));
    projected_values = uint8(linspace(0, 255, length(values)));
    for i = 1:length(values)
        output_image(message == values(i)) = projected_values(i);
    end   
    output_image = uint8(output_image);
end

