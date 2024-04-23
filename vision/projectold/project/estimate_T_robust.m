function T_final = estimate_T_robust(X, x1n, x2n, R, err_threshold)
    num_points = size(x2n, 2);
    alpha = 0.99;
    epsilon = 0.10;
    s = 2;
    iterations = ceil((log(1-alpha)/log(1-epsilon^s)));

    for i = 1:iterations
        perm = randperm(size(x2n, 2));
        perm_x = x2n(1:2, perm(1: 2));
        perm_X = X(1:3, perm(1: 2));

        T = estimate_T_DLT(R*perm_X, perm_x);
        E = skew(T')*R;
    
        inliers = (compute_epipolar_errors(E, x1n, x2n).^2 + ...
            compute_epipolar_errors (E', x2n, x1n).^2) / 2 < err_threshold^2;
        new_epsilon = sum(inliers)/num_points;

        if new_epsilon > epsilon
            epsilon = new_epsilon;
            iterations = ceil((log(1-alpha)/log(1-epsilon^s)));
            T_final = T;
        end
        if i >= iterations
            break
        end
    end
end
