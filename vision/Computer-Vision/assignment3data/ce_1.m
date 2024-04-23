clc
clear all
close all

%% Load data
load('compEx1data.mat');
im1 = imread('kronan1.JPG');
im2 = imread('kronan2.JPG');

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
% Unormalized version
% N1=eye(3);
% N2 = N1;
x1_norm=pflat(N1*x{1});

x2_norm=pflat(N2*x{2});

%% Set up M matrix
M = zeros(length(x1_norm),9);
    for i = 1:length(x1_norm) 
        temp=x2_norm(:,i)*x1_norm(:,i)';
        M(i,:)=temp(:)';       
    end
%% SVD and check
[U,S,V]=svd(M);
v=V(:,end);
eigVals=S'*S;
normMV = norm(M*v);

%% Define F matrix and check the determinant
Fn = reshape (v ,[3 3]);
%refine
[U,S,V]=svd(Fn);
S(3,3)=0;
Fn=U*S*V';

disp(['Determinant of F is ' num2str(round(det(Fn)))])
disp(['Mean value of x2_norm^T F x1_norm is ' num2str(mean(mean(x2_norm'* Fn * x1_norm)))])
figure(1);
plot (diag(x2_norm'*Fn*x1_norm));
ylim([-0.1 0.1])
xlim([0 2000])
hold off
%% Unormalize F and epipolar lines
F=N2'*Fn*N1;
F=F./F(end);
l = F*x{1}; % Computes the epipolar lines
l = l./sqrt(repmat(l(1 ,:).^2 + l(2 ,:).^2 ,[3 1]));

rand_points=randperm(length(x1_norm),20);
plot_points=x{2}(:,rand_points);
%% Plots

figure(2);
hold off
cla reset
imshow(im2);
hold on
plot(plot_points(1,:),plot_points(2,:),'r*','Markersize',10,'LineWidth',1.3)
rital(l(:,rand_points));

title('Image points vs their corresponding epipolar lines')
legend('Image points','Epipolar lines')
hold off

figure(3);
hist(abs(sum(l.*x{2})),100);
title('Distance histogram of image points and their corresponding epipolar line')
xlabel('Distance of epipolar line and image point')
ylabel('Number of image points')
%mean error
meanD=mean(abs(sum(l.*x{2})));
%% Save for ce2
save('compEx2data.mat')