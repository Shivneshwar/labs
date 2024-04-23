function run_sfm(dataset)

[K, img_names, init_pair, threshold] = get_dataset_info(dataset);
num_images = length(img_names);

[image_features, image_descriptors] = vl_sift_images(img_names);

rotations = cell(1, num_images);
rotations{1} = eye(3);
xn = cell(1, num_images-1);
Xn = cell(1, num_images-1);

for i = 1:num_images-1
    [xn{i}, ~] = match_images(image_features, image_descriptors, i, i+1, K);

    [E, inliers] = estimate_E_robust(K, K*xn{i}{1}, K*xn{i}{2}, threshold);
    xn{i}{1} = xn{i}{1}(:, inliers);
    xn{i}{2} = xn{i}{2}(:, inliers);
    [Xn{i}, P] = get_P_3D_points(xn{i}, E);

    rotations{i+1} = P{2}(1:3, 1:3);
    rotations{i+1} = rotations{i+1} * rotations{i};
end

init_im1 = init_pair(1);
init_im2 = init_pair(end);

[init_xn, desc_X] = match_images(image_features, image_descriptors, init_im1, init_im2, K);
[E, inliers] = estimate_E_robust(K, K*init_xn{1}, K*init_xn{2}, threshold);
init_xn{1} = init_xn{1}(:, inliers);
init_xn{2} = init_xn{2}(:, inliers);
desc_X = desc_X(:, inliers);
[init_X, ~] = get_P_3D_points(init_xn, E);
center_init_X = rotations{init_im1}'*init_X(1:3, :);
center_init_X(4, :) = 1;

Ps = cell(1, num_images);
final_pts = cell(1, num_images);

for i = 1:num_images
    [matches, ~] = vl_ubcmatch(image_descriptors{i}, desc_X);
    x1 = image_features{1}(1:2, matches(2, :));
    x2 = image_features{i}(1:2, matches(1, :));
    X = center_init_X(:, matches(2, :));

    x1 = [x1; ones(1, size(x1, 2))];
    x1n = pflat(K\x1);
    x2 = [x2; ones(1, size(x2, 2))];
    x2n = pflat(K\x2);

    T_test = estimate_T_robust(X, x1n, x2n, rotations{i}, 3*threshold);
    P_est = [rotations{i}, T_test];
    Ps{i} = P_est;

    final_pts{i} = pflat(triangulate_3D_point_DLT(Ps{1}, P_est, x1n, x2n));
    distances = sqrt(sum((final_pts{i} - mean(final_pts{i}, 2)).^2, 1));
    q90 = quantile(distances, 0.9);
    close_pts = distances <= 5 * q90;
    final_pts{i} = final_pts{i}(:, close_pts);
end

figure
plotcams(Ps);
hold on
for i = 1:num_images
    plot3(final_pts{i}(1, :), final_pts{i}(2, :), final_pts{i}(3, :), "*");
end
hold off
legend("Cams")
title("Triangulated 3D points from base image pair")

figure
plotcams(Ps);
hold on
for i = 1:num_images-1
    plot3(Xn{i}(1, :), Xn{i}(2, :), Xn{i}(3, :), "*");
end
hold off
legend("Cams")
title("Triangulated 3D points from consecutive image pair")

end