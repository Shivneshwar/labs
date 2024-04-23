clc
clear all
close all

%% LOAD DATA %%
im = imread ('CompEx5.jpg');
load('compEx5.mat');

%% PLOT IMAGE AND CORNERS%%
figure(1)
imagesc(im)
hold on
colormap gray
axis equal
plot(corners(1,[1: end 1]),corners (2,[1: end 1]),'*-');

%% CALIBRATE %%
norm_corners = inv(K)*corners;
figure(2)
plot(norm_corners(1,[1: end 1]),norm_corners (2,[1: end 1]),'*-');
axis ij equal

%% 3D POINTS
% We use the derivations of the prevews question

U = pflat(v);
pts_2D = U(1:3);
s = -pts_2D'* norm_corners;
tempPts_3D = [norm_corners;s];
for i=1:max(size(norm_corners))
    pts_3D(:,i)=pflat(tempPts_3D(:,i));
end
pts_3D = pts_3D(1:3,:);
cc = [0;0;0];
pv = [0;0;1];
figure(3)
plot3( pts_3D(1 ,[1: end 1]) , pts_3D(2 ,[1: end 1]), pts_3D(3 ,[1: end 1]) , '*-' )
axis equal ij
hold on 
quiver3(cc(1), cc(2), cc(3), pv(1), pv(2), pv(3), 6,'g')

R = [sqrt(3)/2, 0, 0.5; 0, 1, 0; -0.5, 0, sqrt(3) /2];
t = [0;0;0]-R*[2;0;0];
P_mat = [R,t]; H = R- t*pts_2D' ;

transformed_corners = pflat(H*norm_corners);
%transformed_corners = pflat(transformed_corners);
figure(4)
plot(transformed_corners(1 ,[1: end 1]) , transformed_corners(2 ,[1: end 1]) , 'r*-' );
hold on
axis ij equal

transformed_points = P_mat*[pts_3D;[1 1 1 1]];
for i=1:max(size(transformed_points))
transformed_points(:,i) = pflat(transformed_points(:,i));
end
plot ( transformed_points(1 ,[1: end 1]) , transformed_points(2 ,[1: end 1]) , 'b*-' );

H_final = K*H*inv(K);
hold off
figure (5)

tform = maketform('projective',H_final');
% Creates a projective transformation that can be used in imtransform
% NOTE : Matlab uses the transposed version of the homografi .
[ trans_im , x , y ] = imtransform (im , tform , 'size', size (im));
% Creastes a transformed image ( using tform )
% of the same size as the original one .

imagesc ( x , y , trans_im );
colormap('gray')
hold on
plot(transformed_corners(1 ,[1: end 1]) , transformed_corners(2 ,[1: end 1]) , 'r*-' );
axis ij equal

% plots the new image with xdata and ydata on the axes