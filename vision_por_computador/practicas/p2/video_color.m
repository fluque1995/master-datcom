function video_color(img, nframes)
    step = 1/nframes;
    vid(nframes) = struct('cdata', [], 'colormap', []);
    hsv_img = rgb2hsv(img);
    for i = 1:nframes
        hsv_img(:,:,1) = mod(hsv_img(:,:,1) + step, 1);
        vid(i) = im2frame(hsv2rgb(hsv_img));
    end
    movie(vid)
end

