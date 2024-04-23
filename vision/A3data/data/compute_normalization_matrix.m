function T = compute_normalization_matrix(points)
    mean_x = mean(points(1, :));
    mean_y = mean(points(2, :));
    std_x = std(points(1, :));
    std_y = std(points(2, :));

    T = [1/std_x, 0, -mean_x/std_x;
         0, 1/std_y, -mean_y/std_y;
         0, 0, 1];
end