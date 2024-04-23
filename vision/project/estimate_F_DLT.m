function F = estimate_F_DLT(x1, x2)
    num_points = size(x1, 2);
    M = zeros(num_points, 9);
    for i = 1:num_points
        vec = x2(:, i)*x1(:, i)';
        M(i, :) = vec(:)';
    end  
    [~, ~, V] = svd(M);
    v = V(:, end);
    F = reshape(v, [3 3]);
end
