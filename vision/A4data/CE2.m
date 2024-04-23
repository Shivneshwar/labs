clear
load("compEx2data.mat");
im1 = imread('fountain1.png');
im2 = imread('fountain2.png');

[f1, d1] = vl_sift(single(rgb2gray(im1)));
[f2, d2] = vl_sift(single(rgb2gray(im2)));

matches = vl_ubcmatch(d1, d2);

x1 = [f1(1, matches(1, :)); f1(2, matches(1, :))];
x2 = [f2(1, matches(2, :)); f2(2, matches(2, :))];

x1 = [x1; ones(1, size(x1, 2))];
x2 = [x2; ones(1, size(x2, 2))];

x1norm = pflat(inv(K)*x1);
x2norm = pflat(inv(K)*x2);
len = length(x1norm);

err_thershold = 0.0002;
alpha = 0.99;
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
    x1_inliers = x1norm(:,inliers);
    x2_inliers = x2norm(:,inliers);
end
if eps < num_inliers/len
    eps = num_inliers/len;
    T = ceil(log10(1-alpha)/log10(1-eps^s));
else
    T = T - 1;
end
end

W=[0 -1 0;1 0 0; 0 0 1];
P1=[eye(3), zeros(3,1)];
P2{1}=[U*W*V',U(:,3)];
P2{2}=[U*W*V',-U(:,3)];
P2{3}=[U*W'*V',U(:,3)];
P2{4}=[U*W'*V',-U(:,3)];

X = cell(1, 4);
for i = 1:4
    tmp = zeros(4, len);
    for j = 1:num_inliers
        M = [P1 -x1_inliers(:, j) [0 0 0]'; P2{i} [0 0 0]' -x2_inliers(:, j)];
        [U, S, V] = svd(M);
        v = V(:, end);
        tmp(:, j) = v(1:4);
    end
    
    X{i} = pflat(tmp);
    cc2 = pflat(null(P2{i}));
    cc1 = pflat(null(P1));
    px = P2{i}*X{i};
    lr = px(end, :);
    ss = sum(lr > 0);

    figure(i);
    plot3(X{i}(1, :), X{i}(2, :), X{i}(3, :), '.b', 'Markersize', 5);
    hold on;
    plotcams({P1; P2{i}});
    plot3(cc2(1), cc2(2), cc2(3), 'r.', 'MarkerSize', 10);
    plot3(cc1(1), cc1(2), cc1(3), 'r.', 'MarkerSize', 10);
    axis equal;
    title(['Num of points in front of P2 =', num2str(ss)]);
    hold off;
end