clear all

im1=imread('cube1.JPG');
im2=imread('cube2.JPG');
load('CE2.mat')
load('CE3.mat')

X=[];
for i = 1:max(size(x1))
    M=[P1 -[x1(:,i);1] [0 0 0]' ; P2 [0 0 0]' -[x2(:,i); 1]];
    [U,S,V]=svd(M);
    v=V(:,end);
    X=[X v(1:4,:)];
end

xproj1=pflat(P1*X);
xproj2=pflat(P2*X);

figure(1)
subplot(1,2,1)
imshow(im1);
hold on;
plot(xproj1(1,:), xproj1(2,:), 'xg', 'Markersize',5);
plot(x1(1,:),x1(2,:), 'xr', 'Markersize', 5)
hold off;
title('Image 1')
legend('Projected points','SIFT points')

subplot(1,2,2)
imshow(im2);
hold on;
plot(xproj2(1,:),xproj2(2,:), 'xg', 'Markersize',5);
plot(x2(1,:), x2(2,:), 'xr', 'Markersize', 5)
hold off;
title('Image 2')
legend('Projected points','SIFT points')

[K1,R1]=rq(P1);
[K2,R2]=rq(P2);

nx1=pflat(inv(K1)*[x1;ones(1,max(size(x1)))]); 
nx2=pflat(inv(K2)*[x2;ones(1,max(size(x2)))]);
nx1=nx1(1:2,:);
nx2=nx2(1:2,:);

X=[];
for i=1:max(size(nx1))
    M=[R1 -[nx1(:,i);1] [0 0 0]' ; R2 [0 0 0]' -[nx2(:,i); 1]];
    [U,S,V]=svd(M);
    v=V(:,end);
    X=[X v(1:4,:)];
end

xproj1 = pflat(P1*X);
xproj2 = pflat(P2*X);

err1 = sqrt(sum((x1(1:2,:) - xproj1(1:2,:)).^2));
err2 = sqrt(sum((x2(1:2,:) - xproj2(1:2,:)).^2));

goodp = (err1 < 3 & err2 < 3);
xgood = pflat(X(:, goodp));

figure(2)
subplot(1,2,1)
imshow(im1);
hold on;
plot(xproj1(1,:), xproj1(2,:), 'xg', 'Markersize',5);
plot(x1(1,:), x1(2,:), 'xr', 'Markersize', 5)
hold off;
title('Image 1 with normalization')
legend('Projected points','SIFT points')

subplot(1,2,2)
imshow(im2);
hold on;
plot(xproj2(1,:), xproj2(2,:), 'xg', 'Markersize',5);
plot(x2(1,:), x2(2,:), 'xr', 'Markersize', 5)
hold off;
title('Image 2 with normalization')
legend('Projected points','SIFT points')

figure(3)
plot3(xgood(1,:),xgood(2,:),xgood(3,:),'.')
hold on 
plot3(Xmodel(1,:),Xmodel(2,:),Xmodel(3,:),'*')
hold on
plotcams({P1, P2})
legend("3D points","Cube model")