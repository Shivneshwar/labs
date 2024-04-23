function [M, v] = estimate_camera_DLT(X,x)

    len = size(X, 2); 
    M1 = zeros(3 * len, 12);
    M2 = zeros(3 * len, 3);
    for i = 1:len
        M1(((i-1)*3+1), 1:4) = X(:,i)';
        M1(((i-1)*3+2), 5:8) = X(:,i)';
        M1(((i-1)*3+3), 9:12) = X(:,i)';
        M2(((i-1)*3+1), i) = -x(1,i)';
        M2(((i-1)*3+2), i) = -x(2,i)';
        M2(((i-1)*3+3), i) = -1;
    end
    M = [M1 M2];
    [U, S, V] = svd(M);
    v = V(:, end);
end