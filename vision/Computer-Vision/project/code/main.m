clear
close all
clc

%% Load and prepare data
curdir = strcat(pwd,'/data/');
image_info = dir(fullfile(curdir,'img*.jpg'));
data_info = dir(fullfile(curdir,'data*.mat'));
images = cell(1,numel(image_info));
data = cell(1,numel(data_info));
iterations = 100;
for i=1:numel(image_info)
 images{i} = imread(strcat(curdir,image_info(i).name));
 data{i} = load(strcat(curdir,data_info(i).name));
end

for i=1:7
 for j=1:numel(image_info)
     U{i,j}=(data{j}.U{i}-repmat(mean(data{j}.U{i},2),[1 size(data{j}.U{i},2)])); %rows = objects, cols = cameras
     u{i,j}=data{j}.u{i};
     bboxes{i,j}=data{j}.bounding_boxes{i};
     trues{i,j}= data{j}.poses{i};
 end
end

%%
% obj1 = buda
% obj2 = pot
% obj3 = cat
% obj4 = duck
% obj5 = eggbox
% obj6 = bottle
% obj7 = stapler
% l = 5;
%  for j=1:7
%      temp = U{j,l};
%      tempu = u{j,l};
%      tempPose = trues{j,l};
%      tempTranslated = tempPose*[temp;ones(1,length(temp))];
%      reprojected = (([eye(3),zeros(3,1)]*[tempTranslated;ones(1,length(tempTranslated))]));
%      figure
%      subplot(1,3,1)
%      plot3(temp(1,:),temp(2,:),temp(3,:),'.')
%      axis ij equal
%      subplot(1,3,2)
%      plot(tempu(1,:),tempu(2,:),'.')
%      axis ij equal
%      subplot(1,3,3)
%      plot(reprojected(1,:),reprojected(2,:),'.')
%      axis ij equal
%      check{j}=tempu-reprojected(1:2,:);
%  end

% Mean algorithm try

% for i=1:7
%  for j=1:numel(image_info)
%    obj_idx=i;
%    cam = j;
%    goodPoints=good_points(U{i,j});
%    ptCloud = pointCloud(U{i,j}(:,goodPoints)');
%    [~,goodPoints,~] = pcfitplane(ptCloud,0.01);
%    for k=1:iterations
%             ind = randsample(size(goodPoints,1),20);
% %             Ps = minimalCameraPose(pextend(u{i,j}(:,goodPoints(ind))),U{i,j}(:,goodPoints(ind)));
% %             cam_center = median(u{i,j},2);
%             imagePoints=u{i,j}(:,goodPoints);
%             worldPoints=U{i,j}(:,goodPoints);
%             [rot, trans]  = classicPosit(imagePoints(:,ind)', worldPoints(:,ind)', 1) ;
%             Ps{1}=[rot trans'];
%             Ps{2}=[rot trans'];
%        
%         if min(size(Ps))~=0
%             proj1 = pflat(Ps{1}*pextend(worldPoints));
%             proj2 = pflat(Ps{2}*pextend(worldPoints));
%             sum1 = sum(sum(abs(proj1-pextend(imagePoints))));            
%             sum2 = sum(sum(abs(proj2-pextend(imagePoints))));
%             if sum1>sum2
%                 tempPs=Ps{2};
%             else
%                 tempPs=Ps{1};
%             end
%         end
%        if k~=1
%         prev_proh=pflat(poses{i,j}*pextend(worldPoints));
%         prev_sum = sum(sum(abs(prev_proh-pextend(imagePoints))));
%         if prev_sum>tempPs
%          poses{i,j}=tempPs;
%         end
%        else
%         poses{i,j}=tempPs;  
%        end
%    end
%  end
% end
% for i=1:numel(image_info)
%     draw_bounding_boxes(images{i}, trues(:,i) , poses(:,i), bboxes(:,i) );
% end
%% DLT
lambda = 0.001;
threshold = 0.00001;
for i=1:7
 for j=1:numel(image_info)
   goodPoints=good_points(U{i,j});
   ptCloud = pointCloud(U{i,j}(:,goodPoints)');
   [~,goodPoints,~] = pcfitplane(ptCloud,0.01);
   ind = randsample(size(goodPoints,1),3);
   Ps = minimalCameraPose(pextend(u{i,j}(:,goodPoints(ind))),U{i,j}(:,goodPoints(ind)));
    err_counter = 0;
    error=0;
    imagePoints=u{i,j}(:,goodPoints);
    worldPoints=U{i,j}(:,goodPoints);
    uu{1}=pextend(imagePoints);
    UU=pextend(worldPoints);
   [temp_err1,~]=ComputeReprojectionError(Ps(1),UU,uu);
   [temp_err2,~]=ComputeReprojectionError(Ps(2),UU,uu);
   if (temp_err1>temp_err2); P{1}=Ps{2}; else; P{1}=Ps{1}; end
%     P{1}= poses{i,j};
    while err_counter<5
        [temp_err,res]=ComputeReprojectionError(P,UU,uu);
        if abs(error(end)-temp_err)<threshold
           err_counter=err_counter+1;
        end
        error=[error; temp_err];
        [r,J] = LinearizeReprojErr(P,UU,uu);
        C = J'*J+lambda*speye(size(J,2));
        c = J'*r;
        deltav = - C\c;
        [P,~] = update_solution(deltav,P,UU);
    end
    poses{i,j}=P{1};
 end
 end

   
   



%% results
close all
for i=1:numel(image_info)
    draw_bounding_boxes(images{i}, trues(:,i) , poses(:,i), bboxes(:,i) );
end
clearvars data_info image_info


