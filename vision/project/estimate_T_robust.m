function T_best = estimate_T_robust(X, x, R, err_threshold)

    num_points = size(x, 2);
    
    alpha = 0.99;
    epsilon = 0.10;
    s = 2;
    iterations = ceil((log(1-alpha)/log(1-epsilon^s)));
    
    for i = 1:iterations
        perm = randperm(num_points);
        random_x = x(:, perm(1: 2));
        random_X = X(:, perm(1: 2));
        T = estimate_T_DLT(random_X, random_x, R);
        x_est = pflat(R*X + T);
        inliers = sqrt((x(1, :) - x_est(1, :)).^2 + (x(2, :) - x_est(2, :)).^2) < err_threshold;
        new_epsilon = sum(inliers)/num_points;
    
        if new_epsilon > epsilon
            epsilon = new_epsilon;
            iterations = ceil((log(1-alpha)/log(1-epsilon^s)));
            T_best = T;
        end
        if i >= iterations
            break
        end
    end
end
