function final_E = estimate_E_H_robust(x1, x2, e_thresh, h_thresh)
    num_points = size(x1, 2);
    alpha = 0.99;
    epsi_e = 0.10;
    epsi_h = 0.10;
    s_e = 8;
    s_h = 4;
    e_iterations = ceil((log(1-alpha)/log(1-epsi_e^s_e)));
    h_iterations = ceil((log(1-alpha)/log(1-epsi_h^s_h)));
    iterations = max(e_iterations, h_iterations);
    
    for i = 1:iterations
        perm = randperm(size(x1, 2));
        perm_x1 = x1(:, perm(1: 8));
        perm_x2 = x2(:, perm(1: 8));

        E = enforce_essential(estimate_F_DLT(perm_x1, perm_x2));
        E = E./E(end, end);
        inliers = (compute_epipolar_errors(E, x1, x2).^2 + ...
            compute_epipolar_errors (E', x2, x1).^2) / 2 < e_thresh^2;
        newepsi_e = sum(inliers)/num_points;
    
        H = estimate_H_DLT(perm_x1(:,1:4), perm_x2(:,1:4));
        H = H./H(end, end);
        Hx = pflat(H*x1);
        inliers = (Hx(1,:) - x2(1,:)).^2 + (Hx(2,:) - x2(2,:).^2) < h_thresh^2;
        newepsi_h = sum(inliers)/num_points;

        if newepsi_e > epsi_e
            epsi_e = newepsi_e;
            e_iterations = ceil((log(1-alpha)/log(1-epsi_e^s_e)));
            E_best = E;
        end
        
        if newepsi_h > epsi_h
            [bool, E_from_H] = acceptable_E_from_H([{x1}, {x2}], H, e_thresh);
            if bool
                E_from_H = E_from_H./E_from_H(end, end);
                inliers = (compute_epipolar_errors(E_from_H, x1, x2).^2 + ...
                    compute_epipolar_errors (E_from_H', x2, x1).^2) / 2 < e_thresh^2;
                newepsi_eh = sum(inliers)/num_points;
            end

            if(bool) && (newepsi_eh > epsi_e)
                epsi_h = newepsi_h;
                epsi_e = newepsi_eh;
                h_iterations = ceil((log(1-alpha)/log(1-epsi_h^s_h)));
                e_iterations =  ceil((log(1-alpha)/log(1-epsi_e^s_e)));
                E_best = E_from_H;
            end
        end

        if i >= e_iterations
            final_E = E_best./E_best(end, end);
            break
        end
    end
end

function [bool, acceptable_E] = acceptable_E_from_H(x, H, e_thresh)
    [R1,t1, ~, R2,t2, ~, ~] = homography_to_RT(H);

    E1 = enforce_essential(skew(t1)*R1);
    E1 = E1./E1(end, end);
    E2 = enforce_essential(skew(t2)*R2);
    E2 = E2./E2(end, end);
    E = [{E1}, {E2}];
    is_acceptable = [0, 0];
    scores = [0, 0];
    for j = 1:2
        total_infront = zeros(1, 4);
        P1 = [eye(3), zeros(3, 1)];
        P2 = extract_P_from_E(E{j});
        P = [{}, {}];
        P{1} = P1;
        
        inliers = (compute_epipolar_errors(E{j}, x{1}, x{2}).^2 + ...
            compute_epipolar_errors (E{j}', x{2}, x{1}).^2) / 2 < e_thresh^2;
        inliers_x1 = x{1}(:, inliers);
        inliers_x2 = x{2}(:, inliers);
        scores(j) = sum(inliers);
        num_points = size(inliers_x1, 2);
        goodp = 0;
        for i = 1:4
            P{2} = P2{i};
            X = pflat(triangulate_3D_point_DLT(P{1}, P{2}, inliers_x1, inliers_x2));
            xproj1 = P{1}*X;
            xproj2 = P{2}*X;
    
            infront1 = xproj1(3, :) > 0;
            infront2 = xproj2(3, :) > 0;   
            total_infront(i) = sum(infront1.*infront2);
            if total_infront(i) == num_points
                goodp = goodp+1;
            end
        end
        
        if goodp == 1
            is_acceptable(j) = 1;
        end
    end

    bool = true;
    if sum(is_acceptable) == 2
        if scores(1) > scores(2)
            acceptable_E = E{1};
        else
            acceptable_E = E{2};
        end
    elseif  is_acceptable(1) == 1
        acceptable_E = E{1};
    elseif  is_acceptable(2) == 1
        acceptable_E = E{2};
    else
        bool = false;
        acceptable_E = 1;
    end
end

