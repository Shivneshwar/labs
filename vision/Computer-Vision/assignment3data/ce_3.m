clc
clear all
close all

%% Load data
load('compEx1data.mat');
load('compEx2data.mat');

%% Normalization
x1_norm=pinv(K)*x{1};
x2_norm=pinv(K)*x{2};

%% Create M
M = zeros(length(x1_norm),9);
    for i = 1:length(x1_norm) 
        temp=x2_norm(:,i)*x1_norm(:,i)';
        M(i,:)=temp(:)';       
    end
    
%% SVD and check
[~,S,V]=svd(M);
v=V(:,end);
eigVals=S'*S;
normMV = norm(M*v);

%% Essential matrix
Eapprox=reshape(v,[3 3]);
[U,S,V]=svd(Eapprox);
if det(U*V')>0
    E =U*diag([1 1 0])*V';
else
    V = -V;
    E = U*diag([1 1 0])*V';
end
E = E./E(3,3);
if abs(S(1,1)-S(2,2))<0.01 && abs(S(3,3))<0.01
    disp('First check ok')
end
if abs(mean(mean(x2_norm'*E*x1_norm)))<0.01
    disp('Second check ok')
end

%% Fundamental matrix
F = pinv(K')*E*pinv(K);
F=F./F(end);
l = F*x{1}; % Computes the epipolar lines
l = l./sqrt(repmat(l(1 ,:).^2 + l(2 ,:).^2 ,[3 1]));
rand_points=randperm(length(x1_norm),20);
plot_points=x{2}(:,rand_points);

%% Plots
figure(1);
hold off
imshow(imread('kronan2.JPG'));
hold on
plot(plot_points(1,:),plot_points(2,:),'r*','Markersize',10,'LineWidth',1.3)
rital(l(:,rand_points));
title('Image points vs their corresponding epipolar lines')
legend('Image points','Epipolar lines')
hold off

figure(2);
hist(abs(sum(l.*x{2})),100);
title('Distance histogram of image points and their corresponding epipolar line')
xlabel('Distance of epipolar line and image point')
ylabel('Number of image points')
%mean error
meanD=mean(abs(sum(l.*x{2})));

save('compEx4data.mat')