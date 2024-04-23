path = toolbox_path;
clc
clear
close all
run([path,'\vl_setup'])
%% Load Images
im1 = imread('a.jpg');
im2 = imread('b.jpg');

%% VLfeat

[fA, dA] = vl_sift(single(rgb2gray(im1)));
[fB, dB] = vl_sift(single(rgb2gray(im2)));
matches = vl_ubcmatch(dA,dB);
xA = fA (1:2 , matches (1 ,:));
xB = fB (1:2 , matches (2 ,:));
v=[xA;ones(1,size(xA,2))];
u=[xB;ones(1,size(xA,2))];


%% DLT RANSAC
threshold=5;
numOfInliners = 0;
inline_idx = {};
H= {};
for i=1:400  
    randind = randperm(length(v),4);    
    M=createM(v(:,randind),u(:,randind));
    tempv=v(:,randind);
    tempu=u(:,randind);
    M=zeros(size(tempv,2)*3,size(tempv,1)*3+size(tempv,2));
    for j=1:size(tempv,2)
        M(3*(j-1)+1,1:size(tempv,1))=tempv(:,j)';
        M(3*(j-1)+2,size(tempv,1)+1:2*size(tempv,1))=tempv(:,j)';
        M(3*j,size(tempv,1)*2+1:size(tempv,1)*3)=tempv(:,j)';
        M(3*(j-1)+1:3*j,3*size(tempv,1)+j)=-tempu(:,j);
    end
    [U,S,V]=svd(M);
    v_tilde=V(:,end);
    H{i}=reshape(v_tilde(1:9),[3 3])';
    cur_inl_idx = zeros(1,length(v));
    for k=1:length(v)
        if norm(pflat(H{i}*v(:,k))-u(:,k))<=threshold
        numOfInliners(i) = numOfInliners(i) + 1;
        cur_inl_idx = [cur_inl_idx k];
        end
    end
   inline_idx{i} = cur_inl_idx;
   numOfInliners = [numOfInliners  0];
end
max_inliers = numOfInliners(numOfInliners == max(numOfInliners));
[~,best]=max(numOfInliners);
%% %perform stiching using H
bestH=H{best};
tform = maketform('projective', bestH');
transfbounds = findbounds(tform ,[1 1; size(im1 ,2) size(im1 ,1)]);
xdata =[ min([transfbounds(: ,1); 1]) max([ transfbounds(: ,1); size(im2 ,2)])];
ydata =[ min([transfbounds(: ,2); 1]) max([ transfbounds(: ,2); size(im2 ,1)])];

[newA] = imtransform(im1 ,tform , 'xdata', xdata , 'ydata ', ydata );
tform2 = maketform('projective', eye(3));
[newB] = imtransform(im2 , tform2 , 'xdata', xdata ,'ydata', ydata ,'size', size( newA ));

newAB = newB ;
newAB ( newB < newA ) = newA ( newB < newA );

%% Plot rotation
figure;
imshow(newAB)
figure;
imshow(im1)
figure;
imshow(im2)

