clc
clear all 
close all

im = imread ('compEx2.JPG');
imagesc(im) % Displays the image
colormap gray % changes the colormap of the current image to gray scale

points = load('compEx2.mat');
p1 = points.p1;
p2 = points.p2;
p3 = points.p3;

figure(1)
markerSize = 6;
hold on
L1 = pflat(cross(p1(:,1),p1(:,2)));
L2 = pflat(cross(p2(:,1),p2(:,2)));
L3 = pflat(cross(p3(:,1),p3(:,2)));
rital(L1);
rital(L2);
rital(L3);
plot(p1(1,:),p1(2,:),'o','MarkerSize',markerSize,'MarkerEdgeColor','blue',...
    'MarkerFaceColor','blue')
plot(p2(1,:),p2(2,:),'o','MarkerSize',markerSize,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
plot(p3(1,:),p3(2,:),'o','MarkerSize',markerSize,'MarkerEdgeColor','yellow',...
    'MarkerFaceColor','yellow')
L2_3_intersection = pflat(cross(L2,L3));
plot(L2_3_intersection(1),L2_3_intersection(2),'o','MarkerSize',markerSize,'MarkerEdgeColor','black',...
    'MarkerFaceColor','white')
distance = abs(L1(1)*L2_3_intersection(1)+L1(2)*L2_3_intersection(2)+L1(3))/...
    sqrt(L1(1)^2+L1(2)^2);
