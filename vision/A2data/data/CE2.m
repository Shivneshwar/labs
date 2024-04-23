clear all

load("compEx3data.mat")
im1 = imread('cube1.JPG');
im2 = imread('cube2.JPG');

len = size(Xmodel, 2); 
camera = 1;
model = [Xmodel; ones(1, len)];
disp("x{1}")
n1 = compute_normalization_matrix(x{1});
disp("x{2}")
n2 = compute_normalization_matrix(x{2});
x1 = n1 * x{1};
x2 = n2 * x{2};

M11 = zeros(3 * len, 12);
M12 = zeros(3 * len, 3);
for i = 1:len
    M11(((i-1)*3+1), 1:4) = model(:,i)';
    M11(((i-1)*3+2), 5:8) = model(:,i)';
    M11(((i-1)*3+3), 9:12) = model(:,i)';
    M12(((i-1)*3+1), i) = -x1(1,i)';
    M12(((i-1)*3+2), i) = -x1(2,i)';
    M12(((i-1)*3+3), i) = -1;
end
M1 = [M11 M12];
[U1, S1, V1] = svd(M1);
evl1 = (S1'*S1);
eigenval1 = evl1(end,end);
eigenvec1 = V1(:,end);

M21 = zeros(3 * len, 12);
M22 = zeros(3 * len, 3);
for i = 1:len
    M21(((i-1)*3+1), 1:4) = model(:,i)';
    M21(((i-1)*3+2), 5:8) = model(:,i)';
    M21(((i-1)*3+3), 9:12) = model(:,i)';
    M22(((i-1)*3+1), i) = -x2(1,i)';
    M22(((i-1)*3+2), i) = -x2(2,i)';
    M22(((i-1)*3+3), i) = -1;
end
M2 = [M21 M22];
[U2, S2, V2] = svd(M2);
evl2 = (S2'*S2);
eigenval2 = evl2(end,end);
eigenvec2 = V2(:,end);

P1 = inv(n1)*reshape(-eigenvec1(1:12) ,[4 3])';
P2 = inv(n2)*reshape(-eigenvec2(1:12) ,[4 3])';

C1 = P1 * model;
C2 = P2 * model;
for i=1:len
   C1(:, i) = pflat(C1(:, i));
   C2(:, i) = pflat(C2(:, i));   
end

save('CE2.mat','Xmodel','P1','P2')
[K1,R1]=rq(P1);
[K2,R2]=rq(P2);
K1 = K1./K1(3, 3);
disp(K1)
figure(1)
subplot(1,2,1)
plot([x1(1,startind); x1(1,endind )] ,...
[x1(2,startind); x1(2,endind)],'b-' );
axis equal
title('Normalized points of camera 1')
subplot(1,2,2)
plot([x2(1,startind); x2(1,endind )] ,...
[x2(2,startind); x2(2,endind)],'b-');
axis equal
title('Normalized points of camera 2')

figure(2)
plot3([Xmodel(1,startind); Xmodel(1,endind )] ,...
[Xmodel(2,startind); Xmodel(2,endind)],...
[Xmodel(3,startind); Xmodel(3 ,endind )],'b-');
hold on
plotcams({P1, P2})
hold off
title('3D points with derived cameras')
axis equal

figure(3)
subplot(1,2,1)
imshow(im1)
hold on;
plot(C1(1,:),C1(2,:),'xg','Markersize',10)
plot(x{1}(1,:),x{1}(2,:),'xr','Markersize',10)
hold off;
title('Image 1')
legend('Original points','Projected points')
subplot(1,2,2)
imshow(im2)
hold on;
plot(C2(1,:),C2(2,:),'xg','Markersize',10)
plot(x{2}(1,:),x{2}(2,:),'xr','Markersize',10)
hold off;
title('Image 2')
legend('Original points','Projected points')

function T = compute_normalization_matrix(points)
    mean_x = mean(points(1, :));
    mean_y = mean(points(2, :));
    std_x = std(points(1, :));
    std_y = std(points(2, :));
    disp(["Mean X = ", mean_x])
    disp(["Mean Y = ", mean_y])
    disp(["std X = ", std_x])
    disp(["std Y = ", std_y])
    T = [1/std_x, 0, -mean_x/std_x;
         0, 1/std_y, -mean_y/std_y;
         0, 0, 1];
end

