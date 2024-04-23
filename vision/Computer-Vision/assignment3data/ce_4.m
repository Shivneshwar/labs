clc
clear all
close all

%% Load data
load('compEx4data.mat');

%% Set up cameras according to ex6
W=[0 -1 0;1 0 0; 0 0 1];
P1=[eye(3), zeros(3,1)];
P2{1}=[U*W*V', U(:,3)];
P2{2}=[U*W*V', -U(:,3)];
P2{3}=[U*W'*V', U(:,3)];
P2{4}=[U*W'*V', -U(:,3)];

%% DLT and quiver plots
X={};
for i=1:4  
    temp=[];
    for j=1:length(x1_norm)
        M=[P1 -x1_norm(:,j) [0 0 0]' ; P2{i} [0 0 0]' -x2_norm(:,j)];
        [U,S,V]=svd(M);
        v=V(:,end);
        temp=[temp v(1:4,:)];
    end    
    X{i}=temp;
    
    X{i}=pflat(X{i});
    camera_center_2 = pflat(null(P2{i}));
    camera_center_1 = pflat(null(P1));
    figure(i);
    plot3(X{i}(1,:),X{i}(2,:),X{i}(3,:),'.b','Markersize',3);
    hold on
    plotcams({P1; P2{i}})
    plot3(camera_center_2(1),camera_center_2(2),camera_center_2(3),'r.','MarkerSize',12);
    plot3(camera_center_1(1),camera_center_1(2),camera_center_1(3),'r.','MarkerSize',12);
    axis equal
    hold off
end

%% Projections
%hardcoded solution fro P2{2}
P2_norm=K*P2{2};
x_P2{2}=pflat(P2_norm*X{2});

figure(5);
hold off
imshow('kronan2.JPG')
hold on
plot(x_P2{2}(1,:),x_P2{2}(2,:),'+r')
plot(x{2}(1,:),x{2}(2,:),'bo');
hold off
title('Image points vs projected 3D-points for camera P_2(2)')
legend('Projected points','Image points')