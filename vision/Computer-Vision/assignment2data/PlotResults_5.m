close all
clear all
clc
%% load data
im1= imread('cube1.jpg');
im2= imread('cube2.jpg');

%% find features 
[f1 d1]=vl_sift(single(rgb2gray(im1)),'PeakThresh',1);
[f2 d2]=vl_sift(single(rgb2gray(im2)),'PeakThresh',1);

%% plot image and features
% figure;
% imshow(im1);
% hold on
% vl_plotframe(f1)
% hold off
% 
% figure;
% imshow(im2)
% hold on
% vl_plotframe(f2)
% hold off

%% match images

[matches, scores] = vl_ubcmatch (d1, d2);
x1 = [ f1(1,matches(1,:)); f1(2,matches(1,:))];
x2 = [ f2(1,matches(2,:)); f2(2,matches(2,:))];

%% plot correspondences

% perm = randperm ( size ( matches ,2));
% figure ;
% imagesc ([ im1 im2 ]);
% hold on ;
% plot ([ x1(1 , perm(1:10)); x2(1 , perm(1:10))+ size(im1 ,2)] ,[ x1(2 ,perm (1:10)); x2(2 , perm(1:10))] , '-' );
% hold off ;

%% run PlotResults3, run if variables not i workspace

PlotResults_3

close all
%% set up and solve the final DLT
X=[];
for i=1:length(x1)
    M=[P1 -[x1(:,i);1] [0 0 0]' ; P2 [0 0 0]' -[x2(:,i); 1]];
    [U,S,V]=svd(M);
    v=V(:,end);
    X=[X v(1:4,:)];
end

%sort out bad matches
xproj1 = pflat2(P1*X );
xproj2 = pflat2(P2*X );
good_points = (sqrt(sum(( x1 - xproj1(1:2 ,:)).^2)) < 3 & sqrt( sum(( x2 - xproj2(1:2 ,:)).^2)) < 3);
X = X (: , good_points );

X=pflat2(X);
%plot reconstructed 3D-points
figure;
plot3(X(1,:),X(2,:),X(3,:),'.b','Markersize',2);
hold on;
plotcams({P1,P2})
plot3([Xmodel(1,startind);Xmodel(1,endind)],[Xmodel(2,startind);Xmodel(2,endind)],[Xmodel(3,startind);Xmodel(3,endind)],'r-');
grid on;
axis equal
hold off;
title('Reconstructed 3D-Points aswell as provided 3D-points')
axis equal;

%Plot projected 3D-points in the two images
xproj1=P1*X;
xproj1=pflat2(xproj1);
figure;
imshow(im1);
hold on;
plot(xproj1(1,:),xproj1(2,:),'+g');
plot(x1(1,:),x1(2,:),'ro')
hold off;
legend('projected points','image feature points')

xproj2=P2*X;
xproj2=pflat2(xproj2);
figure;
imshow(im2);
hold on;
plot(xproj2(1,:),xproj2(2,:),'+g');
plot(x2(1,:),x2(2,:),'ro')
hold off;
legend('projected points','image feature points')