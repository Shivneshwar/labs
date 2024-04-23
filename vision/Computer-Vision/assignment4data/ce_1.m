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
    pi=[plane_abc; d];
    pi = pi ./ norm(pi(1:3));

    %compute RMS
    erms_ls=sqrt(sum((pi'*X).^2)/size(X ,2));
    
%% RANSAC
    runs=500;
    planes = cell(runs,1);
    numOfInliners = zeros(runs,1);
    in_idx =  cell(runs,1);
    threshold = 0.1;
    for i=1:runs
        planes{i} = null(X(:,randperm(length(X),3))');
        %Computes a plane from a sample set.    
        planes{i} = planes{i}./norm(planes{i}(1:3));
        %Makes sure that the plane has a unit length norm

        temp_inliers = [];
        for j=1:length(X)
            if (abs(planes{i}' * X(:,j)) < threshold )
                numOfInliners(i) = numOfInliners(i) + 1;
                temp_inliers = [temp_inliers j];
            end
        end
        in_idx{i} = temp_inliers;
    end

    % accept all points that have error bellow the threshold
    best_match = find(numOfInliners == max(numOfInliners));
    best_match = best_match(1);
    max_inliers = numOfInliners(best_match);
    plane  = planes{best_match};
    X_inl = X(:,in_idx{best_match});

    erms_ransac = sqrt(sum((plane'*X_inl).^2)/size(X_inl ,2));

    %% ransac iterations prob
%     temp = zeros(500,1);
%     counter = 1;
%     steps = linspace(1,1000,500);
%     for runs = 1:2:1000
%     planes2 = cell(runs,1);
%     numOfInliners2 = zeros(runs,1);
%     in_idx2 =  cell(runs,1);
%     for i=1:runs
%         planes2{i} = null(X(:,randperm(length(X),3))');
%         %Computes a plane from a sample set.    
%         planes2{i} = planes2{i}./norm(planes2{i}(1:3));
%         %Makes sure that the plane has a unit length norm
% 
%         temp_inliers2 = [];
%         for j=1:length(X)
%             if (abs(planes2{i}' * X(:,j)) < threshold )
%                 numOfInliners2(i) = numOfInliners2(i) + 1;
%            end
%         end
%     end
%     temp(counter)=max(numOfInliners2);
%     counter=counter+1;
%     end
%     figure(1)
%     plot(steps(:,1:50),temp(1:50,:)/max(temp),'LineWidth',3,'Color','r')
%     title('Evolution of RANSAC success with iterations')
%     xlim([1 100])
%     ylim([0 1.1])
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
    proj{2}=pflat(P{2}*X_inl);

%% Homographs
    %normalize cameras
    P1=pinv(K)*P{1};
    P2=pinv(K)*P{2};
    
    % P1 is [I|0]
    R=P2(1:3,1:3);
    t=P2(:,4);
    pi=pflat(final_plane_inl);
    H = (R-t*pi(1:3)');
    points1x_transf = pflat(K*H*pinv(K)*x);

%% Plots

figure(2);
imshow(im1);
hold on
plot(proj{1}(1,:),proj{1}(2,:),'g.','markersize', 10)
hold off

figure(3);
imshow(im2);
hold on
plot(proj{2}(1,:),proj{2}(2,:),'y.','markersize', 10)
hold off

figure(4);
histogram(abs(plane'*X_inl),100,'FaceColor','y',...
'EdgeColor','r','EdgeAlpha',0.4);
title('RANSAC histogram')
hold off

figure(5);
histogram(abs(final_plane_inl'*X_inl),100,'FaceColor','y',...
'EdgeColor','r','EdgeAlpha',0.4);
title('Least squares on inliers histogram')
hold off 

figure(6)
plotcams({P1,P2})
hold on 
plot3(X(1,:),X(2,:),X(3,:),"b*",'MarkerSize',1)
axis equal
hold off

figure(7);
subplot(1,2,1)
imshow(im1);
hold on
plot(x(1,:),x(2,:),'y*');
title('x points to im1')
hold off
subplot(1,2,2)
imshow(im2);
hold on
plot(points1x_transf(1,:),points1x_transf(2,:),'g*');
title('x points to im2')
hold off
