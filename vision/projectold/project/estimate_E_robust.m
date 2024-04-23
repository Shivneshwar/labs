function [E_final, inliers_final] = estimate_E_robust(K, x1, x2, err_threshold_px)
    x1n = K\x1;
    x2n = K\x2;
    num_points = size(x1, 2);
    
    alpha = 0.99;
    epsilon = 0.10;
    s = 8;
    T_best = ceil((log(1-alpha)/log(1-epsilon^s)));
    err_threshold = err_threshold_px/K(1 ,1);
    
    for i = 1:T_best
        perm = randperm(size(x1, 2));
        perm_x1n = x1n(:, perm(1: s));
        perm_x2n = x2n(:, perm(1: s));
        E = enforce_essential(estimate_F_DLT(perm_x1n, perm_x2n));
        E = E./E(end, end);
    
        inliers = (compute_epipolar_errors(E, x1n, x2n).^2 + ...
            compute_epipolar_errors (E', x2n, x1n).^2) / 2 < err_threshold^2;
        new_epsilon = sum(inliers)/num_points;
    
        if new_epsilon > epsilon
            epsilon = new_epsilon;
            T_best = ceil((log(1-alpha)/log(1-epsilon^s)));
            E_final = E;
            inliers_final = inliers;
        end
        if i >= T_best
            E_final = E_final./E_final(end, end);
    
            break
        end
    end
end
