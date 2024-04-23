clc 
clear 
close all
%% Load data
im1=imread('cube1.JPG');
im2=imread('cube2.JPG');
load('compEx5data.mat')
load('compEx5cameras.mat')
%% Calibrate the first camera into P1=[I 0]
A1=P1(:,1:3); t1=P1(:,4);
A2=P2(:,1:3); t2=P2(:,4);
H1 = [inv(A1) -inv(A1)*t1; 0 0 0 1];
P1 = round(P1*H1);% compute to test; round cause of error
[K1,R1]=rq(P1);
[K2,R2]=rq(P2);
%% DLT
x1=inv(K1)*[x1;ones(1,max(size(x1)))]; 
x2=inv(K2)*[x2;ones(1,max(size(x2)))];
for i=1:max(size(x1))
    x1(:,i)=pflat(x1(:,i));
    x2(:,i)=pflat(x2(:,i));
end
x1=x1(1:2,:);
x2=x2(1:2,:);
X=[];
for i=1:max(size(x1))
    M=[P1 -[x1(:,i);1] [0; 0; 0] ; P2 [0; 0; 0] -[x2(:,i); 1]];
    [U,S,V]=svd(M);
    v=V(:,end);
    X=[X v(1:4,:)];
end
for i=1:max(size(X))
    X(:,i)=pflat(X(:,i));
end
%% Projections
xproj1 = K1*X(1:3,:);
xproj2 = K2*X(1:3,:);
for i=1:max(size(xproj1))
    xproj1(:,i)=pflat(xproj1(:,i));
    xproj2(:,i)=pflat(xproj2(:,i));
end
xproj1 = K1*(P1*inv(H1) * X);
xproj2 = K2*(P2 * X);
for i=1:max(size(xproj1))
    xproj1(:,i)=pflat(xproj1(:,i));
    xproj2(:,i)=pflat(xproj2(:,i));
end

x1=K1 * [x1;ones(1,max(size(x1)))];
x2=K2 * [x2;ones(1,max(size(x2)))];
for i=1:max(size(x1))
    x1(:,i)=pflat(x1(:,i));
    x2(:,i)=pflat(x2(:,i));
end
x1=x1(1:2,:);
x2=x2(1:2,:);
% good_points =(sqrt(sum((x1 - xproj1(1:2 ,:)).^2))<3&...
%     sqrt(sum((x2 - xproj2(1:2 ,:)).^2))< 3);
% X = X (:,good_points );

%recompute for the good points
xproj1_good = K1*(P1 * X);
xproj2_good = K2*(P2 * X);
for i=1:max(size(xproj1))
    xproj1_good(:,i)=pflat(xproj1_good(:,i));
    xproj2_good(:,i)=pflat(xproj2_good(:,i));
end

xproj1_good=xproj1_good(1:2,:);
xproj2_good=xproj2_good(1:2,:);
% Removes points that are not good enough .
%% Plot and compare SIFT and projection points
figure(1)
subplot(1,2,1)
imshow(im1);
hold on;
plot(xproj1(1,:),xproj1(2,:),'xg','Markersize',5);
plot(x1(1,:),x1(2,:),'or','Markersize',8)
hold off;
title('First image with SIFT and projected points (All)')
legend('Projected points','SIFT points')

subplot(1,2,2)
imshow(im2);
hold on;
plot(xproj2(1,:),xproj2(2,:),'xg','Markersize',5);
plot(x2(1,:),x2(2,:),'or','Markersize',8)
hold off;
title('Second image with SIFT and projected points (All)')
legend('Projected points','SIFT points')

%% Plot and compare SIFT and projection points
%All points plot
figure(1)
subplot(2,2,1)
imshow(im1);
hold on;
plot(xproj1(1,:),xproj1(2,:),'xg','Markersize',5);
plot(x1(1,:),x1(2,:),'or','Markersize',8)
hold off;
title('First image with SIFT and projected points (All)')
legend('Projected points','SIFT points')

subplot(2,2,2)
imshow(im2);
hold on;
plot(xproj2(1,:),xproj2(2,:),'xg','Markersize',5);
plot(x2(1,:),x2(2,:),'or','Markersize',8)
hold off;
title('Second image with SIFT and projected points (All)')
legend('Projected points','SIFT points')

%Good points plot
subplot(2,2,3)
imshow(im1);
hold on;
plot(xproj1_good(1,:),xproj1_good(2,:),'xg','Markersize',5);
plot(x1(1,:),x1(2,:),'or','Markersize',8)
hold off;
title('First image with SIFT and projected points (Good)')
legend('Projected points','SIFT points')

subplot(2,2,4)
imshow(im2);
hold on;
plot(xproj2_good(1,:),xproj2_good(2,:),'xg','Markersize',5);
plot(x2(1,:),x2(2,:),'or','Markersize',8)
hold off;
title('Second image with SIFT and projected points (God)')
legend('Projected points','SIFT points')