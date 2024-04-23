clc
clear all
close all

%% Load data
load('compEx2data.mat');

%% Camera matrices
P1 = [eye(3) zeros(3,1)];
e2 = null(F');
e2x = [0 -e2(3) e2(2); e2(3) 0 -e2(1); -e2(2) e2(1) 0];
P2 = [e2x*F e2];
P1_norm = N1*P1; 
P2_norm = N2*P2;

%% Triangulation
X=zeros(4,length(x1_norm));
for i=1:length(x1_norm)
  M=[P1_norm -[x1_norm(:,i), zeros(3,1)] ; [P2_norm zeros(3,1)] -x2_norm(:,i)]; 
  [U,S,V]=svd(M);
  v=V(:,end);
  X=[X v(1:4,:)];
end
for i=1:length(X)
X(:,i)=pflat(X(:,i));
end

%% Project points
x1 = zeros(3,length(X));
x2 = zeros(3,length(X));
 for i=1:length(X)
x1(:,i) = pflat(P1*X(:,i) );
x2(:,i) = pflat(P2*X(:,i) );
end

%% Plots

figure(1);
plot3(X(1,:),X(2,:),X(3,:),'.g','Markersize',1);
hold on;
grid on;
hold off;
title('3D reconstruction')
hold off

figure(2);
imshow(imread('kronan1.JPG'));
hold on;
plot(x1(1,:),x1(2,:),'bo','MarkerSize',8);
plot(x{1}(1,:),x{1}(2,:),'r*','MarkerSize',5);
hold off;
title('Image points vs projected 3D-points')
legend('Projected points','Image points')