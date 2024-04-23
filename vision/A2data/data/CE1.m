clear all

load("compEx1data.mat")
camera = 1;
im = imread(imfiles{camera});
im = rgb2gray(im);

figure(1)
plotcams(P)
hold on 
plot3(X(1, :), X(2, :), X(3, :), '.', 'MarkerSize', 2)
title('3D points of the reconstruction')
hold off
axis equal
pause(0.5);

proj = P{1} * X;
for i = 1:max(size(proj))
    proj(:, i) = pflat(proj(:, i));
end

visible = isfinite(x{camera}(1, :));

figure(2)
imshow(imfiles{camera})
hold on
plot(x{camera}(1, visible), x{camera}(2, visible), '*')
plot(proj(1,: ), proj(2, :), 'ro')
title('Project the 3D points into camera 1')
hold off
axis equal 
pause(0.5);

T1 = [1 0 0 0; 
      0 3 0 0;
      0 0 1 0;
      1/8 1/8 0 1];
T2 = [1 0 0 0; 
      0 1 0 0;
      0 0 1 0;
      1/16 1/16 0 1];

XT1 = T1 * X; 
XT2 = T2 * X;
for i = 1:max(size(XT1))
    XT1(:, i) = pflat(XT1(:, i));
    XT2(:, i) = pflat(XT2(:, i));
end

figure(3)
subplot(1,2,1)
plotcams(P)
hold on 
plot3(XT1(1, :), XT1(2, :), XT1(3, :), '.', 'MarkerSize', 2)
hold off
axis equal
subplot(1,2,2)
plotcams(P)
hold on 
plot3(XT2(1, :), XT2(2, :), XT2(3, :), '.', 'MarkerSize', 2)
hold off
axis equal
title('3D points of the reconstruction')
pause(0.5);

PT1=P{1} * inv(T1) * XT1;
PT2=P{1} * inv(T2) * XT2;
for i = 1:max(size(X))
    PT1(:,i) = pflat(PT1(:,i));
    PT2(:,i) = pflat(PT2(:,i));
end

figure(4)
imshow(imfiles{camera})
hold on
plot(x{camera}(1, visible), x{camera}(2, visible), '*')
plot(PT1(1,: ), PT1(2, :), 'ro')
title('Project the 3D points of T1 into camera 1')
axis equal
hold off
pause(0.5);

figure(5)
imshow(imfiles{camera})
hold on
plot(x{camera}(1, visible), x{camera}(2, visible), '*')
plot(PT2(1,: ), PT2(2, :), 'ro')
title('Project the 3D points of T2 into camera 1')
axis equal 
hold off
