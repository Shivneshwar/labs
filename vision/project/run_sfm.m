function run_sfm(dataset)

[K, img_names, init_pair, threshold] = get_dataset_info(dataset);
num_images = length(img_names);
epi_thresh = threshold/K(1 ,1);
homo_thresh = 3*epi_thresh;
t_thresh = 9*epi_thresh;

disp("Sift images")
[image_features, image_descriptors] = vl_sift_images(img_names);

rotations = cell(1, num_images);
rotations{1} = eye(3);
xn = cell(1, num_images-1);

disp("Rotations")
for i = 1:num_images-1
    [xn{i}, ~] = match_images(image_features, image_descriptors, i, i+1, K);
    E = estimate_E_H_robust(xn{i}{1}, xn{i}{2}, epi_thresh, homo_thresh);
    [~, P] = get_P_3D_points(xn{i}, E);
    rotations{i+1} = P{2}(1:3, 1:3);
    rotations{i+1} = rotations{i+1} * rotations{i};
end

disp("Init images")
init_im1 = init_pair(1);
init_im2 = init_pair(end);

[init_xn, desc_X] = match_images(image_features, image_descriptors, init_im1, init_im2, K);
E = estimate_E_H_robust(init_xn{1}, init_xn{2}, epi_thresh, homo_thresh);
err_vec = (compute_epipolar_errors(E, init_xn{1}, init_xn{2}).^2 + ...
    compute_epipolar_errors(E', init_xn{2}, init_xn{1}).^2)/2;
inliers = err_vec < epi_thresh^2;
init_xn{1} = init_xn{1}(:, inliers);
init_xn{2} = init_xn{2}(:, inliers);
desc_X = desc_X(:, inliers);
[center_init_X, ~] = get_P_3D_points(init_xn, E);
center_init_X = center_init_X - mean(center_init_X, 2);
center_init_X = rotations{init_im1}'*center_init_X(1:3, :);

Ps = cell(1, num_images);
final_pts = cell(1, num_images);

disp("T estimation")
for i = 1:num_images
    [matches, ~] = vl_ubcmatch(image_descriptors{i}, desc_X);
    matchx = image_features{i}(1:2, matches(1, :));
    matchX = center_init_X(:, matches(2, :));
    matchx = [matchx; ones(1, size(matchx, 2))];
    matchx = pflat(K\matchx); 
    T = estimate_T_robust(matchX, matchx, rotations{i}, t_thresh);
    Ps{i} = [rotations{i}, T];
end

disp("Triangulate points")
for i = 1:num_images-1
    [matches, ~] = vl_ubcmatch(image_descriptors{i}, image_descriptors{i+1});
    x1 = image_features{i}(1:2, matches(1, :));
    x2 = image_features{i+1}(1:2, matches(2, :));
    x1 = [x1; ones(1, size(x1, 2))];
    x2 = [x2; ones(1, size(x2, 2))];
    x1n = K\x1;
    x2n = K\x2;

    final_pts{i} = pflat(triangulate_3D_point_DLT(Ps{i}, Ps{i+1}, x1n, x2n));
    distances = sqrt(sum((final_pts{i} - mean(final_pts{i}, 2)).^2, 1));
    q90 = quantile(distances, 0.9);
    close_pts = distances <= q90;
    final_pts{i} = final_pts{i}(:, close_pts);
end

disp("Plottings")
figure
plotcams(Ps);
hold on
for i = 1:num_images-1
    plot3(final_pts{i}(1, :), final_pts{i}(2, :), final_pts{i}(3, :), "*");
end
hold off
legend("Cams")
title("3D reconstruction")
end