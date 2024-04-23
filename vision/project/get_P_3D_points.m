function [X, P] = get_P_3D_points(xn, E)
    P1 = [eye(3), zeros(3, 1)];
    P2 = extract_P_from_E(E);
    P = cell(1, 2);
    P{1} = P1;
    X_tmp = cell(1, 4);
    points = zeros(1, 4);
    for i = 1:4
        P{2} = P2{i};
        X_tmp{i} = pflat(triangulate_3D_point_DLT(P{1}, P{2}, xn{1}, xn{2}));
        x_proj1 = P{1}*X_tmp{i};
        x_proj2 = P{2}*X_tmp{i};
        points(i) = sum(x_proj1(3, :) > 0) + sum(x_proj2(3, :) > 0);
    end
    chosen = find(points==max(points));
    X = X_tmp{chosen};
    P{2} = P2{chosen};
end
