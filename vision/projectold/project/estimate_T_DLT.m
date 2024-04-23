function T = estimate_T_DLT(X, x)
    num_points = size(x, 2);
    M = zeros(2*num_points, 3);
    Z = zeros(2*num_points, 1);
    for i = 1:num_points
        M(2*i - 1, 3) = -x(1, i);  
        M(2*i - 1, 1) = 1;
        M(2*i    , 3) = -x(2, i);
        M(2*i    , 2) = 1;
        Z(2*i - 1, 1) = x(1, i)*X(3, i) - X(1, i);
        Z(2*i    , 1) = x(2, i)*X(3, i) - X(2, i);
    end
    [U, S, V] = svd(M);
    T = V'*pinv(S)*U'*Z;
end
