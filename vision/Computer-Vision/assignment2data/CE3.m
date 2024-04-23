clc
clear
close all

%% Load necessairy data
cameraNumber = 1;
load("compEx3data.mat")
Xmodel_hom = [Xmodel;ones(1,max(size(Xmodel)))];
im1 = imread('cube1.JPG');
im2 = imread('cube2.JPG');
%% Normalize x
mean_x1=mean(x{1}(1:2,:),2);
std_x1=std(x{1}(1:2,:),0,2);
mean_x2=mean(x{2}(1:2,:),2);
std_x2=std(x{2}(1:2,:),0,2);

N1=[1/std_x1(1) 0 -mean_x1(1)/std_x1(1); 
    0 1/std_x1(2) -mean_x1(2)/std_x1(2); 
    0 0 1];
N2=[1/std_x2(1) 0 -mean_x2(1)/std_x2(1); 
    0 1/std_x2(2) -mean_x2(2)/std_x2(2); 
    0 0 1];

x1=N1*x{1};
x2=N2*x{2};

%% Set up M matrix for DLT
M1_1st= zeros(3*max(size(Xmodel)),12);
M1_2nd= zeros(3*max(size(Xmodel)),3);
for i=1:max(size(Xmodel))
    M1_1st(((i-1)*3+1),1:4) = Xmodel_hom(:,i)';
    M1_1st(((i-1)*3+2),5:8) = Xmodel_hom(:,i)';
    M1_1st(((i-1)*3+3),9:12) = Xmodel_hom(:,i)';
    M1_2nd(((i-1)*3+1),i) = -x1(1,i)';
    M1_2nd(((i-1)*3+2),i) = -x1(2,i)';
    M1_2nd(((i-1)*3+3),i) = -1;
end
M=[M1_1st M1_2nd];
[U1, S1, V1] = svd(M);
M_eigen1=(S1'*S1);
smallestEigenVal1 = M_eigen1(end,end);
smallestEigenVec1 = V1(:,end);

M2_1st= zeros(3*max(size(Xmodel)),12);
M2_2nd= zeros(3*max(size(Xmodel)),3);
for i=1:max(size(Xmodel))
    M2_1st(((i-1)*3+1),1:4) = Xmodel_hom(:,i)';
    M2_1st(((i-1)*3+2),5:8) = Xmodel_hom(:,i)';
    M2_1st(((i-1)*3+3),9:12) = Xmodel_hom(:,i)';
    M2_2nd(((i-1)*3+1),i) = -x2(1,i)';
    M2_2nd(((i-1)*3+2),i) = -x2(2,i)';
    M2_2nd(((i-1)*3+3),i) = -1;
end
M=[M2_1st M2_2nd];
[U2, S2, V2] = svd(M);
M_eigen1=(S1'*S1);
smallestEigenVal2 = M_eigen1(end,end);
smallestEigenVec2 = V2(:,end);
%% Setup the cameras
P1 = inv(N1)*reshape(-smallestEigenVec1(1:12) ,[4 3])';
P2 = inv(N2)*reshape(-smallestEigenVec2(1:12) ,[4 3])';
%minus after checking that the camera is behind the object

pointsC1=P1*(Xmodel_hom);
pointsC2=P2*(Xmodel_hom);
for i=1:max(size(Xmodel))
   pointsC1(:,i)=pflat(pointsC1(:,i));
   pointsC2(:,i)=pflat(pointsC2(:,i));   
end
save('compEx5cameras.mat','P1','P2')
%% K,R extraction with QR 
[K1,R1]=rq(P1);
[K2,R2]=rq(P2);
%% Plots
close all
figure(1)
plot3([Xmodel(1,startind); Xmodel(1,endind )] ,...
[Xmodel(2,startind); Xmodel(2,endind)],...
[Xmodel(3,startind); Xmodel(3 ,endind )],'b-' );
hold on 
plot3([Xmodel(1,startind); Xmodel(1,endind )] ,...
[Xmodel(2,startind); Xmodel(2,endind)],...
[Xmodel(3,startind); Xmodel(3 ,endind )],'b.','MarkerSize',20 );
title('3D-plot of 3D-points')

figure(2)
plot3([Xmodel(1,startind); Xmodel(1,endind )] ,...
[Xmodel(2,startind); Xmodel(2,endind)],...
[Xmodel(3,startind); Xmodel(3 ,endind )],'b-' );
hold on 
plot3([Xmodel(1,startind); Xmodel(1,endind )] ,...
[Xmodel(2,startind); Xmodel(2,endind)],...
[Xmodel(3,startind); Xmodel(3 ,endind )],'b.','MarkerSize',20 );
hold on
plotcams({P1, P2})
hold off
title('3D-plot of 3D-points with derived cameras')
axis equal

figure(3)
subplot(1,2,1)
hold on
plot([x1(1,startind); x1(1,endind )] ,...
[x1(2,startind); x1(2,endind)],'b-' );
plot([x1(1,startind); x1(1,endind )] ,...
[x1(2,startind); x1(2,endind)],'b.','MarkerSize',20 );
axis equal ij
title('First camera - Norm')
xlim([-2 2])

subplot(1,2,2)
hold on
plot([x2(1,startind); x2(1,endind )] ,...
[x2(2,startind); x2(2,endind)],'b-');
plot([x2(1,startind); x2(1,endind )] ,...
[x2(2,startind); x2(2,endind)],'b.','MarkerSize',20);
axis equal ij
title('Second camera - Norm')
xlim([-2 2])

figure(4)
subplot(1,2,1)
imshow(im1)
hold on;
plot(pointsC1(1,:),pointsC1(2,:),'xg','Markersize',10)
plot(x{1}(1,:),x{1}(2,:),'xr','Markersize',10)
hold off;
title('First image with correct and derived 3D-points')
legend('Image points','Projected points')
subplot(1,2,2)
imshow(im2)
hold on;
plot(pointsC2(1,:),pointsC2(2,:),'xg','Markersize',10)
plot(x{2}(1,:),x{2}(2,:),'xr','Markersize',10)
hold off;
title('Second image with correct and derived 3D-points')
legend('Image points','Projected points')