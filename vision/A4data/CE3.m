load('compEx3data.mat');

len = size(X, 2);
delta_X = zeros(size(X));
X_ref = X;
mu = 0.0001;

first_error = zeros(1, len);
error_before = zeros(1, len);
error_after = zeros(1, len);

for i=1:100
    for j=1:len
        X_j = X_ref(:, j);
        x_1j = x{1}(:, j);
        x_2j = x{2}(:, j);
    
        [error_before(j), res] = ComputeReprojectionError(P{1}, P{2}, X_j, x_1j, x_2j);
        [r,J] = LinearizeReprojErr(P{1}, P{2}, X_j, x_1j, x_2j);
        delta_X(:, j) = ComputeUpdate(r, J, mu);
        [error_after(j), ~] = ComputeReprojectionError(P{1}, P{2}, X_j + delta_X(:, j), x_1j, x_2j);
    end

    if i == 1
        first_error = error_before;
    end

    if sum(error_after) < sum(error_before)
        X_ref = X_ref + delta_X;
        mu = mu/10;
    else
        mu = 10*mu;
    end

    if sum(error_before) - sum(error_after) < 0.000001
        break
    end
end


disp("Total Error before = " + num2str(sum(first_error)));
disp("Total Error after = " + num2str(sum(error_after)) );
disp("Median Error before = " + num2str(median(first_error)) );
disp("Median Error after = " + num2str(median(error_after)) );

figure
plot3(X(1, :), X(2, :), X(3, :), '.r', 'Markersize', 5)
hold on
plot3(X_ref(1, :), X_ref(2, :), X_ref(3, :), '.b', 'Markersize', 5)
legend("X", "Refined X")
title('3D points')

function [err,res] = ComputeReprojectionError(P_1,P_2,X_j,x_1j,x_2j)
    xproj1 = pflat(P_1*X_j);
    xproj2 = pflat(P_2*X_j);
    res = [x_1j - xproj1; x_2j - xproj2];
    res = res([1, 2, 4, 5], :);
    err = norm(res)^2;
end

function [r,J] = LinearizeReprojErr(P_1,P_2,X_j,x_1j,x_2j)
    [~, r] = ComputeReprojectionError(P_1,P_2,X_j,x_1j,x_2j);
    
    J = [
     ((P_1(1, :)*X_j)/(P_1(3, :)*X_j)^2) * P_1(3, :) - (1/(P_1(3, :)*X_j) * P_1(1, :));
     ((P_1(2, :)*X_j)/(P_1(3, :)*X_j)^2) * P_1(3, :) - (1/(P_1(3, :)*X_j) * P_1(2, :));
     ((P_2(1, :)*X_j)/(P_2(3, :)*X_j)^2) * P_2(3, :) - (1/(P_2(3, :)*X_j) * P_2(1, :));
     ((P_2(2, :)*X_j)/(P_2(3, :)*X_j)^2) * P_2(3, :) - (1/(P_2(3, :)*X_j) * P_2(2, :));
     ];
end

function delta_X_j = ComputeUpdate(r, J, mu)
    C = J.'* J + mu * eye(size(J, 2));
    c = J.'* r;
    delta_X_j = -C\c ;
end