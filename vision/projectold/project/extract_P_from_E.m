function P = extract_P_from_E(E)
    P = cell(1, 4);
    [U, ~, V] = svd(E);
    if det(U*V') < 0
        V = -V;
    end
    W = [0, -1, 0;
         1, 0, 0;
         0, 0, 1];
    P{1} = [U*W*V', U(:, 3)];
    P{2} = [U*W*V', -U(:, 3)];
    P{3} = [U*W'*V', U(:, 3)];
    P{4} = [U*W'*V', -U(:, 3)];
end
