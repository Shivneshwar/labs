clc
clear all
close all

%% Load necessairy data
cameraNumber = 1;
load("compEx1data.mat")
im(:,:,:) = imread(imfiles{cameraNumber}); %Reads the imagefile with name in imfiles{i}
im = rgb2gray(im);

%% Plot all points and camera quivers
figure(1)
plotcams(P)
hold on 
plot3(X(1,:),X(2,:),X(3,:),"b*",'MarkerSize',1)
axis equal
hold off
%% Projections for camera P1
temp_proj=P{1}*X;
for i=1:max(size(X))
proj(:,i)=pflat(temp_proj(:,i));
end
visible_P1 = isfinite(x{cameraNumber}(1,:));
figure(2)
imshow(imfiles{cameraNumber})
hold on
%plot x-y in reverse to have the reconstruction unrotated
plot(x{cameraNumber}(2,visible_P1),max(x{cameraNumber}(1,visible_P1))...
    -x{cameraNumber}(1,visible_P1),"ro",'MarkerSize',2.5);
plot(proj(2,:),max(x{cameraNumber}(1,visible_P1))...
    -proj(1,:),"b*",'MarkerSize',1)
title('2D-Projection of the camera P1')
axis equal 

%% Projetive Transdormations
T1=[1 0 0 0; 
    0 4 0 0;
    0 0 1 0;
    1/10 1/10 0 1];
T2 = eye(4); T2(4,1:2)=1/16;

X_T1 = T1*X; X_T2 = T2*X;
P1_T1 = {P{1}*inv(T1)}; P1_T2 = {P{1}*inv(T2)};

for i=1:max(size(X_T1))
X_T1(:,i)=pflat(X_T1(:,i));
X_T2(:,i)=pflat(X_T2(:,i));
end

figure(3)
subplot(1,2,1)
plotcams(P1_T1)
hold on 
plot3(X_T1(1,:),X_T1(2,:),X_T1(3,:),"b*",'MarkerSize',1)
hold off
axis equal
subplot(1,2,2)
plotcams(P1_T2)
hold on 
plot3(X_T2(1,:),X_T2(2,:),X_T2(3,:),"b*",'MarkerSize',1)
hold off
axis equal

%% Projecct the transformations
temp_proj_X_T1=P{1}*X_T1;
temp_proj_X_T2=P{1}*X_T2;
for i=1:max(size(X))
proj_X_T1(:,i)=pflat(temp_proj_X_T1(:,i));
proj_X_T2(:,i)=pflat(temp_proj_X_T2(:,i));
end
visible_P1 = isfinite(x{cameraNumber}(1,:));
figure(4)
subplot(1,2,1)
imshow(imfiles{cameraNumber})
hold on
% plot x-y in reverse to have the reconstruction unrotated
plot(x{cameraNumber}(2,visible_P1),max(x{cameraNumber}(1,visible_P1))...
    -x{cameraNumber}(1,visible_P1),"ro",'MarkerSize',2.5);
plot(proj_X_T1(2,:),max(x{cameraNumber}(1,visible_P1))...
    -proj_X_T1(1,:),"b*",'MarkerSize',1)
title('2D-Projection of the camera P1\_T1')
axis equal
subplot(1,2,2)
imshow(imfiles{cameraNumber})
hold on
% plot x-y in reverse to have the reconstruction unrotated
plot(x{cameraNumber}(2,visible_P1),max(x{cameraNumber}(1,visible_P1))...
    -x{cameraNumber}(1,visible_P1),"ro",'MarkerSize',2.5);
plot(proj_X_T2(2,:),max(x{cameraNumber}(1,visible_P1))...
     -proj_X_T2(1,:),"b*",'MarkerSize',1)
title('2D-Projection of the camera P1\_T2')
axis equal 

%% CE2
[K1, R_T1]=rq(P1_T1{1});gamma1=K1(1)/K1(2,2);f1=K1(2,2);
[K2, R_T2]=rq(P1_T2{1});gamma2=K2(1)/K2(2,2);f2=K2(2,2);
disp(['gamma1 = ',num2str(gamma1)])
disp(['focal1 = ',num2str(f1)])
disp(['gamma2 = ',num2str(gamma2)])
disp(['focal2 = ',num2str(f2)])