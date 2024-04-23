function T = estimate_T_DLT(X, x, R)
    num_points = size(x, 2);
    M = zeros(2*num_points, 3);
    B = zeros(2*num_points, 1);

    Xr = R * X;
    M(1, :) = [1, 0, -x(1, 1)];
    M(2, :) = [0, 1, -x(2, 1)];
    M(3, :) = [1, 0, -x(1, 2)];
    M(4, :) = [0, 1, -x(2, 2)];
    
    B(1) = Xr(3, 1)*x(1, 1) - Xr(1, 1);
    B(2) = Xr(3, 1)*x(2, 1) - Xr(2, 1);
    B(3) = Xr(3, 2)*x(1, 2) - Xr(1, 2);
    B(4) = Xr(3, 2)*x(2, 2) - Xr(2, 2);
    
    T = M\B;
end
