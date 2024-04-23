function H = estimate_H_DLT(x1, x2)
    num_points = size(x1, 2);
    M = zeros(2*num_points, 9);

    for i = 1:num_points
        M(2*i - 1, 1:3) = x1(:, i)';  
        M(2*i - 1, 7:9) = -x2(1, i)*x1(:, i)';  
        M(2*i    , 4:6) = x1(:, i)';  
        M(2*i    , 7:9) = -x2(2, i)*x1(:, i)';  
    end
    [~, ~, V] = svd(M);
    v = V(:, end);
    H = reshape(v, [3 3])';
end