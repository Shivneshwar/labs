function [image_features, image_descriptors] = vl_sift_images(img_names)
    num_images = length(img_names);
    image_features = cell(1, num_images);
    image_descriptors = cell(1, num_images);

    for i = 1:num_images
        im = imread(img_names{i});
        [image_features{i}, image_descriptors{i}] = vl_sift(single(rgb2gray(im)));
    end
end