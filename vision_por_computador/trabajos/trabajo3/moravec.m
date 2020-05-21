function [points_x, points_y] = moravec(input_image, sz, thr)
    vert_img = abs(conv2(input_image, [-1 1],'same'));
    horz_img = abs(conv2(input_image, [-1; 1], 'same'));
    diag_1_img = abs(conv2(input_image,[-1 0; 0 1],'same'));
    diag_2_img = abs(conv2(input_image,[0 -1; 1 0],'same'));
    f = ones(sz,sz);
    vert_conv = conv2(vert_img, f, 'same');
    horz_conv = conv2(horz_img, f, 'same');
    diag_1_conv = conv2(diag_1_img, f, 'same');
    diag_2_conv = conv2(diag_2_img, f, 'same');
    stack = cat(3, vert_conv, horz_conv, diag_1_conv, diag_2_conv);
    responses = min(stack, [], 3);
    [points_x, points_y] = find(responses > thr*max(responses(:)));
end