clc
clear 
close all

%% Load images
im1 = imread('cube1.JPG');
im2 = imread('cube2.JPG');

%% SIFT features and descriptors
[f1, d1]=vl_sift(single(rgb2gray(im1)) ,'PeakThresh',1);
[f2, d2]=vl_sift(single(rgb2gray(im2)) ,'PeakThresh',1);

%% plots features (coordinates and orientation)
figure(1)
subplot(1,2,1)
vl_plotframe(f1);
axis equal
subplot(1,2,2)
vl_plotframe(f2);
axis equal

%% (Unique) matching points
[matches , scores] = vl_ubcmatch(d1,d2);

%% Extract matching points
x1 = [f1(1,matches(1,:)); f1(2,matches(1,:))];
x2 = [f2(1,matches(2,:)); f2(2,matches(2,:))];

%% Plot
perm = randperm(size(matches,2));
figure(2);
imagesc([im1,im2]);
hold on ;
plot([x1(1,perm (1:10)); x2(1,perm(1:10))+ size(im1,2)],...
[x1(2,perm(1:10));x2(2 ,perm(1:10))],'-');
axis equal
hold off ;

%% Save x1 and x2 for the next exercise
save('compEx5data.mat','x1','x2');