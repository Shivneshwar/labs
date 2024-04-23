function X = triangulate_3D_point_DLT(P1, P2, x1, x2)
    num_points = size(x1, 2);
    X = zeros(4, num_points);
    M = zeros(4, 4);
    for i = 1:num_points
        M(1, :) = P1(1, :) - x1(1, i)*P1(3, :);
        M(2, :) = P1(2, :) - x1(2, i)*P1(3, :);
        M(3, :) = P2(1, :) - x2(1, i)*P2(3, :);
        M(4, :) = P2(2, :) - x2(2, i)*P2(3, :);
        [~, ~, V] = svd(M);
        X(:, i) = V(:, end);
    end
end