im = imread('compEx2.jpg');
figure;
imagesc(im);
colormap gray;
hold on;

load('compEx2.mat');
plot(p1(1,:), p1(2,:), 'o','MarkerSize', 10,'MarkerEdgeColor','blue',...
    'MarkerFaceColor','blue')
plot(p2(1,:), p2(2,:), 'o','MarkerSize', 10,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
plot(p3(1,:), p3(2,:), 'o','MarkerSize', 10,'MarkerEdgeColor','green',...
    'MarkerFaceColor','green')

line1 = cross(p1(:,1), p1(:,2));
line2 = cross(p2(:,1), p2(:,2));
line3 = cross(p3(:,1), p3(:,2));

rital(line1, 'blue');
rital(line2, 'red');
rital(line3, 'green');

intersection_point = pflat(cross(line2, line3));
plot(intersection_point(1), intersection_point(2), 'o','MarkerSize', ...
    10,'MarkerEdgeColor','white', 'MarkerFaceColor','white')

distance_line1_point = point_line_distance_2D(intersection_point, line1);
disp(['Distance between the first line and intersection point: ', ...
    num2str(distance_line1_point)]);

function distance = point_line_distance_2D(point, line)
    a = line(1);
    b = line(2);
    c = line(3);
    
    distance = abs(a * point(1) + b * point(2) + c) / sqrt(a^2 + b^2);
end