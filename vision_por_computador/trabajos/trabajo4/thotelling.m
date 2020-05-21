%Read images
selection = 1;

if (selection == 1)
    for n = 1:6
        path = strcat('adra/banda', int2str(n), '.tif');
        adraImg = imread(path);
        adraImg = im2double(adraImg);
        adraImages(:,:,n) = adraImg;
    end
else
    index = 1;
    for n = 'a':'e'
        path = strcat('camiones/', n, '.jpg');
        adraImg = imread(path);
        adraImg = rgb2gray(adraImg);
        adraImg = im2double(adraImg);
        adraImages(:,:,index) = adraImg;
        index = index + 1;
    end
end
sizeVector = size(adraImages);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Applu Hotelling transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Mean and expectation mean  of pixel vectors
mean = zeros(1,sizeVector(3), 'double');
for i = 1:sizeVector(1)
    for j = 1:sizeVector(2)
        vector = adraImages(i,j,:);
        vector = squeeze(vector(1,1,:)).';
        mean = mean + vector;
    end
end
mean = mean / (sizeVector(1) * sizeVector(2));
expectationMean = ((mean') * mean) / (sizeVector(1) * sizeVector(2));

%Expectation of pixel vectors
expectation = zeros(sizeVector(3),sizeVector(3), 'double');
for i = 1:sizeVector(1)
    for j = 1:sizeVector(2)
        vector = adraImages(i,j,:);
        vector = squeeze(vector(1,1,:)).';
        expectation = expectation + vector' * vector;
    end
end
expectation = expectation / (sizeVector(1) * sizeVector(2));

%Covariance matrix
covMatrix = expectation - expectationMean;

%Get Eigenvalues and Eigenvectors
[eigenVectors, eigenValues] = eig(covMatrix);

%Order eigenVectors by eigenValues
eigenVectors = fliplr(eigenVectors);
eigenValues = flipud(fliplr(eigenValues));

%Apply Hotelling on pixel vectors y = A(x-m)
newAdraImages = adraImages;
for n = 1:sizeVector(3)
    for i = 1:sizeVector(1)
        for j = 1:sizeVector(2)
            vector = adraImages(i,j,:);
            vector = squeeze(vector(1,1,:)).';
            newAdraImages(i,j,:) = (vector - mean) * eigenVectors;
        end
    end
end

figure, subplot(2,3,1), imshow(newAdraImages(:,:,1)),...
    subplot(2,3,2), imshow(newAdraImages(:,:,2), []),...
    subplot(2,3,3), imshow(newAdraImages(:,:,3), []),...
    subplot(2,3,4), imshow(newAdraImages(:,:,4), []),...
    subplot(2,3,5), imshow(newAdraImages(:,:,5), []),...
    subplot(2,3,6), imshow(newAdraImages(:,:,6), []);
    
