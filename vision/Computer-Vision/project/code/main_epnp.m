% MAIN Illustrates how to use the EPnP algorithm described in:
%
%       Francesc Moreno-Noguer, Vincent Lepetit, Pascal Fua.
%       Accurate Non-Iterative O(n) Solution to the PnP Problem. 
%       In Proceedings of ICCV, 2007. 
%
% Copyright (C) <2007>  <Francesc Moreno-Noguer, Vincent Lepetit, Pascal Fua>
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the version 3 of the GNU General Public License
% as published by the Free Software Foundation.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% General Public License for more details.       
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%
% Francesc Moreno-Noguer, CVLab-EPFL, September 2007.
% fmorenoguer@gmail.com, http://cvlab.epfl.ch/~fmoreno/ 

clear all; close all;

addpath EPnP;
load('sols.mat');

%% Load and prepare data
curdir = strcat(pwd,'/data/');
image_info = dir(fullfile(curdir,'img*.jpg'));
data_info = dir(fullfile(curdir,'data*.mat'));
images = cell(1,numel(image_info));
data = cell(1,numel(data_info));
for i=1:numel(image_info)
 images{i} = imread(strcat(curdir,image_info(i).name));
 data{i} = load(strcat(curdir,data_info(i).name));
end



K = [572.4410, 0, 325.26110; 0, 573.57043, 242.04899; 0, 0, 1];
for i=1:7
 for j=1:numel(image_info)      
    goodPoints=good_points(U{i,j});
    meanX=mean(U{i,j}(:,goodPoints),2);%Computes the mean 3D point
    Xtilde = (U{i,j}(:,goodPoints)-repmat(meanX,[1 size(U{i,j}(:,goodPoints),2)]));
    ptCloud = pointCloud(Xtilde');
    [~,goodPoints,~] = pcfitplane(ptCloud,0.02);
    imagePoints=u{i,j}(:,goodPoints);
    worldPoints=Xtilde(:,goodPoints);
    X=pextend(worldPoints');
    x=pextend(imagePoints');
    Cc=mean(x,1);
    K = [572.4410, 0, Cc(1); 0, 573.57043, Cc(2); 0, 0, 1];
    [Rp,Tp,Xc,sol]=efficient_pnp(X,x,K);

poses_epnp{i,j}=[Rp LM_poses{i,j}(1:3,4)];
 end
end


for i=1:numel(image_info)
    draw_bounding_boxes(images{i}, trues(:,i) , poses_epnp(:,i), bboxes(:,i) );
    scores = eval_pose_estimates (trues(:,i),poses_epnp(:,i),bboxes(:,i)  );
end

save('epnp')



