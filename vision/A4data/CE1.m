load("compEx1data.mat");

x1norm = pflat(inv(K)*x{1});
x2norm = pflat(inv(K)*x{2});
len = length(x1norm);

M = zeros(len, 9);
for i=1:len
    xx = x2norm(:,i)*x1norm(:,i)';
    M(i,:) = xx(:)';
end

[~,~,V] = svd(M);
v = V(:,end);
Fn = reshape(v,[3 3]);
[U,~,V] = svd(Fn);
if det(U*V')<0
    V = -V;
end
E = U*diag([1 1 0])*V';

F = pinv(K')*E*pinv(K);
F = F./F(end);

l1 = F'*x{2};
l2 = F*x{1};

l1 = l1 ./ sqrt (repmat(l1(1,:).^2 +l1(2 ,:).^2,[3 1]));
l2 = l2 ./ sqrt (repmat(l2(1,:).^2 +l2(2 ,:).^2,[3 1]));

dist1 = abs(sum(l1.*x{1}));
dist2 = abs(sum(l2.*x{2}));

rms_value = sqrt(1 / (2 * len) * (sum(dist1.^2) + sum(dist2.^2)));
disp(['Root Mean Square (rms) value with all points' num2str(rms_value)]);

figure(1)
histogram(dist1,100)
title('Image 1 without RANSAC')
xlabel('Distance Between Epipolar Line and Image Point')
ylabel('Number of Image Points')
figure(2)
histogram(dist2,100)
title('Image 2 without RANSAC')
xlabel('Distance Between Epipolar Line and Image Point')
ylabel('Number of Image Points')

randp = randperm(len,20);
r1 = x{1}(:,randp);
r2 = x{2}(:,randp);

im1 = imread("round_church1.jpg");
im2 = imread("round_church2.jpg");

figure(3)
imshow(im1)
hold on
plot(r1(1,:),r1(2,:),'r*','Markersize',10)
rital(l1(:,randp));
hold off
title('Image 1 without RANSAC')
legend('Image points','Epipolar lines')

figure(4)
imshow(im2)
hold on
plot(r2(1,:),r2(2,:),'r*','Markersize',10)
rital(l2(:,randp));
hold off
title('Image 2 without RANSAC')
legend('Image points','Epipolar lines')

err_thershold = 0.0002;
alpha = 0.95;
eps = 0.1;
s = 8;
T = log10(1-alpha)/log10(1-eps^s);

E_final = [];
dist1_final = [];
dist2_final = [];
num_inliers = -inf;

while T~=0
randp = randperm(len,s);
r1 = x1norm(:,randp);
r2 = x2norm(:,randp);

M = zeros(s, 9);
for i=1:s
    xx = r2(:,i)*r1(:,i)';
    M(i,:) = xx(:)';
end

[~,~,V] = svd(M);
v = V(:,end);
Fn = reshape(v,[3 3]);
[U,~,V] = svd(Fn);
if det(U*V')<0
    V = -V;
end
E = U*diag([1 1 0])*V';

l1 = E'*x2norm;
l2 = E*x1norm;

l1 = l1 ./ sqrt (repmat(l1(1,:).^2 +l1(2 ,:).^2,[3 1]));
l2 = l2 ./ sqrt (repmat(l2(1,:).^2 +l2(2 ,:).^2,[3 1]));

dist1 = abs(sum(l1.*x1norm));
dist2 = abs(sum(l2.*x2norm));

inliers = (dist1.^2+dist2.^2)/2 < err_thershold^2;
num_inliers_new = sum(inliers);
if num_inliers_new > num_inliers
    num_inliers = num_inliers_new;
    E_final = E;
    dist1_final = dist1;
    dist2_final = dist2;
end
if eps < num_inliers/len
    eps = num_inliers/len;
    T = ceil(log10(1-alpha)/log10(1-eps^s));
else
    T = T - 1;
end
end

F = pinv(K')*E_final*pinv(K);
F = F./F(end);

l1 = F'*x{2};
l2 = F*x{1};

l1 = l1 ./ sqrt (repmat(l1(1,:).^2 +l1(2 ,:).^2,[3 1]));
l2 = l2 ./ sqrt (repmat(l2(1,:).^2 +l2(2 ,:).^2,[3 1]));

dist1 = abs(sum(l1.*x{1}));
dist2 = abs(sum(l2.*x{2}));

rms_value = sqrt(1 / (2 * len) * (sum(dist1.^2) + sum(dist2.^2)));
disp(['Root Mean Square (rms) value using RANSAC ' num2str(rms_value)]);

figure(5)
histogram(dist1,100)
title('Image 1 with RANSAC')
xlabel('Distance Between Epipolar Line and Image Point')
ylabel('Number of Image Points')
pause(1)
figure(6)
histogram(dist2,100)
title('Image 2 with RANSAC')
xlabel('Distance Between Epipolar Line and Image Point')
ylabel('Number of Image Points')
pause(1)

randp = randperm(len,20);
r1 = x{1}(:,randp);
r2 = x{2}(:,randp);

figure(7)
imshow(im1)
hold on
plot(r1(1,:),r1(2,:),'r*','Markersize',10)
rital(l1(:,randp));
hold off
title('Image 1 with RANSAC')
legend('Image points','Epipolar lines')
pause(1)
figure(8)
imshow(im2)
hold on
plot(r2(1,:),r2(2,:),'r*','Markersize',10)
rital(l2(:,randp));
hold off
title('Image 2 with RANSAC')
legend('Image points','Epipolar lines')
