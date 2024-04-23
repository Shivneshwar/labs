clear
close all
clc

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

for i=1:7
 for j=1:numel(image_info)
     U{i,j}=(data{j}.U{i}-repmat(mean(data{j}.U{i},2),[1 size(data{j}.U{i},2)])); %rows = objects, cols = cameras
     u{i,j}=data{j}.u{i};
     bboxes{i,j}=data{j}.bounding_boxes{i};
     trues{i,j}= data{j}.poses{i};
 end
end

%% Pick MinSolvs with RANSAC
iterations = 1000;

for i=1:7
 for j=1:numel(image_info) 
    scores = zeros(1,iterations);
    candidateCams = cell(1,iterations);
    goodPoints=good_points(U{i,j});
    meanX=mean(U{i,j}(:,goodPoints),2);%Computes the mean 3D point
    Xtilde = (U{i,j}(:,goodPoints)-repmat(meanX,[1 size(U{i,j}(:,goodPoints),2)]));
    U_meaned{i,j}=Xtilde;

    ptCloud = pointCloud(Xtilde');
    [~,goodPoints,~] = pcfitplane(ptCloud,0.02);
    imagePoints=u{i,j}(:,goodPoints);
    worldPoints=Xtilde(:,goodPoints);
   for k=1:iterations
            ind = randsample(size(imagePoints,2),3);
            Ps = minimalCameraPose(pextend(u{i,j}(:,ind)),Xtilde(:,ind));
            if ~isempty(Ps)
                [candidateCams{k},scores(k)] = camera_score(imagePoints,worldPoints,Ps);
            end
   end
    [~,ind]=max(scores);
     poses{i,j}=candidateCams{ind};
  end
end

%% L-M refinement
iterations = 500;

for i=1:7
 for j=1:numel(image_info)
    temp_iter = 0;
    P={[eye(3),zeros(3,1)],poses{i,j}};
    lambda = 0.1;
    ind = randsample(size(u{i,j},2),450);
    u_temp={pextend(u{i,j}(:,ind)),pextend(u{i,j}(:,ind))};
    U_temp=pextend(U{i,j}(:,ind));
    min_error=inf;
    for k=1:iterations
    Ps{k}=P{2};
    temp_iter=temp_iter+1;
    [temp_err,res]=ComputeReprojectionError(P{2},U_temp,u_temp{2});
    errors{k}=temp_err;  

    if temp_iter == iterations/10
       temp_iter = 0;
       lambda=lambda/1.5;
    end
    lamda=min(lambda,0.000001);
    [r,J] = LinearizeReprojErr(P,U_temp,u_temp);
    C = J'*J+lambda*speye(size(J,2));
    c = J'*r;
    deltav = - C\c;
    [P,U_temp] = update_solution(deltav,P,U_temp);  
    end
    error_check=cell2mat(errors);
    [~,indmin]=min(error_check);
    LM_poses{i,j}=Ps{indmin};
    disp([i,j])
 end
end

%% Tester

for i=1:numel(image_info)
    draw_bounding_boxes(images{i}, trues(:,i) , LM_poses(:,i), bboxes(:,i) );
    scores{i} = eval_pose_estimates (trues(:,i),LM_poses(:,i),bboxes(:,i)  );
end
clearvars data_info image_info
save('sols')

