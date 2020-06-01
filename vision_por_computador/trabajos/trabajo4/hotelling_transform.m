function [output_channels, eigenvals] = hotelling_transform(list_images)
    vectors = reshape(...
        list_images, size(list_images, 1)*size(list_images, 2),...
        size(list_images, 3));

    mean_vec = mean(vectors, 1);
    cov_mat = cov(vectors);

    [eigenvecs, eigenvals] = eig(cov_mat);
    [~, ordering] = sort(diag(eigenvals), 'descend');
    eigenvecs = eigenvecs(:,ordering);
 
    vectors = (eigenvecs'*(vectors - mean_vec)')';
    output_channels = reshape(vectors, size(list_images, 1),...
        size(list_images, 2), size(list_images, 3));
end

