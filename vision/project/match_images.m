function [x, desc_X] = match_images(image_features, image_descriptors, idx1, idx2, K)    
    matches = vl_ubcmatch(image_descriptors{idx1}, image_descriptors{idx2});
    x = [{}, {}];
    x1 = image_features{idx1}(1:2, matches(1, :));
    x2 = image_features{idx2}(1:2, matches(2, :));
    
    x1 = [x1; ones(1, size(x1, 2))];
    x2 = [x2; ones(1, size(x2, 2))];
    x{1} = K\x1;
    x{2} = K\x2;

    desc_X = image_descriptors{idx1}(:, matches(1, :));
end