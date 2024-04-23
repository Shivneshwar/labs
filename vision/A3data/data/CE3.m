clear

load('compEx3data.mat');
W=[0 -1 0;1 0 0; 0 0 1];
P1=[eye(3), zeros(3,1)];
P2{1}=[U*W*V',U(:,3)];
P2{2}=[U*W*V',-U(:,3)];
P2{3}=[U*W'*V',U(:,3)];
P2{4}=[U*W'*V',-U(:,3)];

X = cell(1, 4);
for i = 1:4
    tmp = zeros(4, len);
    for j = 1:len
        M = [P1 -x1norm(:, j) [0 0 0]'; P2{i} [0 0 0]' -x2norm(:, j)];
        [U, S, V] = svd(M);
        v = V(:, end);
        tmp(:, j) = v(1:4);
    end
    
    X{i} = pflat(tmp);
    cc2 = pflat(null(P2{i}));
    cc1 = pflat(null(P1));
    
    figure(i);
    plot3(X{i}(1, :), X{i}(2, :), X{i}(3, :), '.b', 'Markersize', 5);
    hold on;
    plotcams({P1; P2{i}});
    plot3(cc2(1), cc2(2), cc2(3), 'r.', 'MarkerSize', 10);
    plot3(cc1(1), cc1(2), cc1(3), 'r.', 'MarkerSize', 10);
    axis equal;
    title('3D points, camera centers and principal axes');
    hold off;
end

p2norm = K * P2{2};
xp2 = pflat(p2norm * X{2});
pause(1);
figure(5);
imshow('kronan2.JPG');
hold on;
plot(xp2(1, :), xp2(2, :), '+g', 'MarkerSize', 5);
plot(x{2}(1, :), x{2}(2, :), 'ro', 'MarkerSize', 5);
hold off;
title('Image points vs Projected points');
legend('Projected points', 'Image points');

