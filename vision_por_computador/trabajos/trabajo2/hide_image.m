function [output_image] = hide_image(input_image, input_message)
    hidden_message = zeros(size(input_message));
    unique_vals = unique(input_message);
    for i = 1:length(unique_vals)
        hidden_message(input_message == unique_vals(i)) = i - 1;
    end
    hidden_message = uint8(hidden_message);
    input_image = uint8(input_image);
    output_image = bitxor(input_image, hidden_message, 'uint8');
end

