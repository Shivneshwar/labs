clc
clear all
close all

%% Load Data
load('compEx1data.mat');
im1=imread('house1.jpg');
im2=imread('house2.jpg');

%% Least squares and RMS
    X=pflat(X);
    meanX=mean(X,2);%Computes the mean 3D point 
    Xtilde=(X-repmat(meanX,[1 size(X,2)]));
    %Subtracts the mean from the 3D points 
    M= Xtilde(1:3,:)*Xtilde(1:3,:)' ;

    % compute eigenvalues
    [V,~]=eig(M);%Computes eigenvalues and eigenvectors of M
    plane_abc=V(:,1);
    d= -plane_abc'*meanX(1:3);
    final_plane=[plane_abc; d];
    final_plane = final_plane ./ norm(final_plane(1:3));

    %compute RMS
    erms_ls=sqrt(sum((final_plane'*X).^2)/size(X ,2));
    
%% RANSAC
runs=50;
planes = cell(runs,1);
numOfInliners = zeros(runs,1);
in_idx =  cell(runs,1);
threshold = 0.1;
for i=1:runs
    planes{i} = null(X(:,randperm(length(X),3))');
    %Computes a plane from a sample set.    
    planes{i} = planes{i}./norm(planes{i}(1:3));
    %Makes sure that the plane has a unit length norm
    
    current_inliers = [];
    for j=1:length(X)
        if (abs(planes{i}' * X(:,j)) < 0.1 )
            numOfInliners(i) = numOfInliners(i) + 1;
            current_inliers = [current_inliers j];
        end
    end
    in_idx{i} = current_inliers;
end

% find matches
best_match = find(numOfInliners == max(numOfInliners));
best_match = best_match(1);
max_inliers = numOfInliners(best_match);
plane  = planes{best_match};
X_inl = X(:,in_idx{best_match});

erms_ransac = sqrt(sum((plane'*X_inl).^2)/size(X_inl ,2));

%% Intiers LS
    X_inl=pflat(X_inl);
    meanX_inl=mean(X_inl,2);%Computes the mean 3D point 
    X_inl_tilde=(X_inl-repmat(meanX_inl,[1 size(X_inl,2)]));
    %Subtracts the mean from the 3D points 
    M_inl= X_inl_tilde(1:3,:)*X_inl_tilde(1:3,:)' ;

    % compute eigenvalues
    [V_inl,~]=eig(M_inl);%Computes eigenvalues and eigenvectors of M
    plane_abc_inl=V_inl(:,1);
    d_inl= -plane_abc_inl'*meanX_inl(1:3);
    final_plane_inl=[plane_abc_inl; d_inl];
    final_plane_inl = final_plane_inl ./ norm(final_plane_inl(1:3));

    erms_ls_inl=sqrt(sum((final_plane_inl'*X_inl).^2)/size(X_inl ,2));
    
%% Inline projections
    proj{1}=pflat(P{1}*X_inl);
    proj{2}=pflat(P{1}*X_inl);

%% Homos
%% Homography
v=pflat(K\P{1}*X);
u=pflat(K\P{2}*X);

Pnorm{1}=K\P{1};
Pnorm{2}=K\P{2};
R=Pnorm{2}(1:3,1:3);
t=Pnorm{2}(:,4);
pi=pflat(final_plane_inl);
H = (R-t*pi(1:3)');

homo=pflat(H*v);
up=K*u;
vp=K*homo;

mean(mean(vp-up))

%% Plots
figure(1);
histogram(abs(plane'*X_inl),100,'FaceColor','y',...
'EdgeColor','r','EdgeAlpha',0.4);
title('RANSAC histogram')

figure(2);
histogram(abs(final_plane_inl'*X_inl),100,'FaceColor','y',...
'EdgeColor','r','EdgeAlpha',0.4);
title('Least squares on inliers histogram')

figure(3);
imshow(im1);
hold on
plot(proj{1}(1,:),proj{1}(2,:),'g*','markersize', 10)
hold off

figure(4);
imshow(im2);
hold on
plot(proj{2}(1,:),proj{2}(2,:),'y*','markersize', 10)
hold off

figure(5);
imshow(im2);
hold on
plot(up(1,:),up(2,:),'bo');
plot(vp(1,:),vp(2,:),'g+');
legend(['3D-points projected into camera 2'], ['3D-points projected to camera 2, transformed to camera 2 via Homography'])
%axis equal
hold off
