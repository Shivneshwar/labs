load('compEx3.mat');
U_normalized = pflat(U);

[center1, axis1] = camera_center_and_axis(P1);
[center2, axis2] = camera_center_and_axis(P2);
scale = 10;

figure;
plot3(U_normalized(1, :), U_normalized(2, :), U_normalized(3, :), 'o', 'MarkerSize', 5);
hold on;
plot3(center1(1), center1(2), center1(3), 'rx', 'MarkerSize', 10);
plot3(center2(1), center2(2), center2(3), 'bx', 'MarkerSize', 10);
quiver3(center1(1), center1(2), center1(3), axis1(1) * scale, axis1(2) * scale, axis1(3) * scale, 'r');  
quiver3(center2(1), center2(2), center2(3), axis2(1) * scale, axis2(2) * scale, axis2(3) * scale, 'b'); 
title('3D Points, Camera Centers, and Projections');
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
axis equal;
grid on;


project_and_plot_points(P1, U, 'compEx3im1.jpg');
project_and_plot_points(P2, U, 'compEx3im2.jpg');

function [center, axis] = camera_center_and_axis(P)
    K = P(:, 1:3);    
    center = null(P);    
    center = center / center(4);
    axis = K(3, :);
    axis = axis / norm(axis);
    center = center(1:3);
end

function project_and_plot_points(P, U, image_path)
    projected_points = P * U;
    projected_points = projected_points ./ projected_points(3, :);

    im = imread(image_path);
    figure;
    imagesc(im);
    colormap gray;
    hold on;

    plot(projected_points(1, :), projected_points(2, :), 'ro', 'MarkerSize', 2, 'LineWidth', 2);

    xlabel('X');
    ylabel('Y');
    title('Projection of 3D Points into Image Plane');
    grid on;
    axis equal;
    hold off;
end

