clc
clear all
close all

%% LOAD DATA %%
im1 = imread ('compEx4im1.JPG');
im2 = imread('compEx4im2.JPG');

load('compEx4.mat');

%% DECOMPOSE CAMERAS %%

[~, ~, cp1, pp1, pv1] = decomposecamera(P1);
[~, ~, cp2, pp2, pv2] = decomposecamera(P2);

for n = 1:max(size(U))
    U_norm(:,n) = pflat(U(:,n));
end

proj1=P1*U_norm;
proj2=P2*U_norm;
for i=1:length(U_norm)   
   proj1(:,i)=pflat(proj1(:,i));
   proj2(:,i)=pflat(proj2(:,i));
end


figure(1)
plot3(U_norm(1,:),U_norm(2,:),U_norm(3,:),'.','Markersize',2);
hold on
quiver3(cp1(1),cp1(2),cp1(3),pv1(1),pv1(2),pv1(3),40,'r') 
plot3(cp1(1),cp1(2),cp1(3),'r.','Markersize',10);
quiver3(cp2(1),cp2(2),cp2(3),pv2(1),pv2(2),pv2(3),40,'g') 
plot3(cp2(1),cp2(2),cp2(3),'g.','Markersize',10);
grid on
axis equal
hold off

figure(2)
hold on
imagesc(im1) 
colormap gray 
plot(proj1(1,:),proj1(2,:),'.b','Markersize',2);
axis equal

hold off

figure(3)
hold on
imagesc(im2)
colormap gray 
plot(proj2(1,:),proj2(2,:),'.b','Markersize',2);

axis equal
hold off
