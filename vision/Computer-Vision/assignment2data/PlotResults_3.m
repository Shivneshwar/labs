%% load in data

load('compEx3data.mat');
im1=imread('cube1.jpg');
im2=imread('cube2.jpg');

%% plot 3D Points

figure;
plot3(Xmodel(1,:),Xmodel(2,:),Xmodel(3,:),'.b','Markersize',10)
hold on;
plot3 ([Xmodel(1,startind);Xmodel(1,endind)],[Xmodel(2,startind);Xmodel(2,endind)],[Xmodel(3,startind);Xmodel(3,endind)],'b-');
axis equal
title('Plotted 3D-points')
hold off;

%% construct N

meanx1=mean(x{1}(1:2,:),2);
std1=std(x{1}(1:2,:),0,2);
meanx2=mean(x{2}(1:2,:),2);
std2=std(x{2}(1:2,:),0,2);

N1=[1/std1(1) 0 -meanx1(1)/std1(1); 0 1/std1(2) -meanx1(2)/std1(2); 0 0 1];
N2=[1/std2(1) 0 -meanx2(1)/std2(1); 0 1/std2(2) -meanx2(2)/std2(2); 0 0 1];


%% Normalize Points

xtilde1=N1*x{1};
xtilde2=N2*x{2};

%% Plot normalized points

figure;
hold on
plot(xtilde1(1,:),xtilde1(2,:),'.r','MarkerSize',20);
plot([xtilde1(1,startind); xtilde1(1,endind )] ,...
[xtilde1(2,startind); xtilde1(2,endind)],'r-' );
axis equal ij
title('image points normalized with N1')

figure;
hold on
plot(xtilde2(1,:),xtilde2(2,:),'.r','MarkerSize',20);
plot([xtilde2(1,startind); xtilde2(1,endind )] ,...
[xtilde2(2,startind); xtilde2(2,endind)],'r-' );
axis equal ij
title('image points normalized with N2')

%% set up DLT

M1=createM(Xmodel,xtilde1);
M2=createM(Xmodel,xtilde2);

%% solve using svd
[U1,S1,V1]=svd(M1);
v1=V1(:,end)

[U2,S2,V2]=svd(M2);
v2=V2(:,end)

D1=S1'*S1;
disp('D1(end)')
D1(end)

D2=S2'*S2;
disp('D2(end)')
D2(end)

disp('norm of M1*v1')
norm(M1*v1)
disp('norm of M2*v2')
norm(M2*v2)
%% create P matrices project points

P1=N1\reshape(-v1(1:12),[4 3])';
P2=N2\reshape(-v2(1:12),[4 3])';



% disp('P1')
% P1disp=P1./P1(end)
% disp('P2')
% P2disp=P2./P2(end)
% 
% 
 projPoints1=pflat(P1*([Xmodel;ones(1,size(Xmodel,2))]))
 projPoints2=pflat(P2*([Xmodel;ones(1,size(Xmodel,2))]))

%% plot result

figure;
plot3(Xmodel(1,:),Xmodel(2,:),Xmodel(3,:),'.b','Markersize',10)
hold on;
plot3 ([Xmodel(1,startind);Xmodel(1,endind)],[Xmodel(2,startind);Xmodel(2,endind)],[Xmodel(3,startind);Xmodel(3,endind)],'b-');
axis equal

plotcams({P1, P2})
hold off;
title('3D-plot of 3D-points and cameras')

figure;
imshow(im1)
hold on;
plot(projPoints1(1,:),projPoints1(2,:),'+b','Markersize',10)
plot(x{1}(1,:),x{1}(2,:),'+g','Markersize',10)
hold off;
title('Image 1 with plotted imagepoints and projected 3D-points')
legend('image points','projected 3D-points')

figure;
imshow(im2)
hold on;
plot(projPoints2(1,:),projPoints2(2,:),'+b','Markersize',10)
plot(x{2}(1,:),x{2}(2,:),'+g','Markersize',10)
hold off;
title('Image 2 with plotted imagepoints and projected 3D-points')
legend('image points','projected 3D-points')


%% RQ-factorize 
[K1,R1]=rq(P1);
[K2,R2]=rq(P2);
