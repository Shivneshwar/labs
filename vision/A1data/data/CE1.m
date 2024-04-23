load('compEx1.mat');

x2D_normalized = pflat(x2D);
x3D_normalized = pflat(x3D);

plot_points_2D(x2D_normalized);
plot_points_3D(x3D_normalized);

function plot_points_2D(points)    
    figure;
    plot(points(1, :), points(2, :), 'o');
    title('2D Points');
    xlabel('X-axis');
    ylabel('Y-axis');
    axis equal;
    grid on;
end

function plot_points_3D(points)
    figure;
    plot3(points(1, :), points(2, :), points(3, :), 'o');
    title('3D Points');
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    axis equal;
    grid on;
end