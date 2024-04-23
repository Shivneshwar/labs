clear

load('compEx1data.mat');
load('compEx2data.mat');
im = imread('kronan2.JPG');

x1norm = pinv(K)*x{1};
x2norm = pinv(K)*x{2};
len = length(x1norm);

M = zeros(len, 9);
for i=1:len
    xx = x2norm(:,i)*x1norm(:,i)';
    M(i,:) = xx(:)';
end

[U,S,V] = svd(M);
v = V(:,end);
Fn = reshape(v,[3 3]);
[U,S,V] = svd(Fn);
if det(U*V')<0
    V = -V;
end
E = U*diag([1 1 0])*V';

if det(E)>0.01
    error("Determinant not equal to 0")
end
if mean(x2norm'*E*x1norm, "all")>0.01
    error("epipolar constraints  ̃xT2  ̃E  ̃x1 = 0 are not fulfilled")
end

F = pinv(K')*E*pinv(K);
F = F./F(end);
l = F * x{1}; % Computes the epipolar lines
l = l ./ sqrt (repmat(l(1,:).^2 +l(2 ,:).^2,[3 1]));

randp = randperm(len,20);
rpoints = x{2}(:,randp);

figure(1)
imshow(im)
hold on
plot(rpoints(1,:),rpoints(2,:),'r*','Markersize',10)
rital(l(:,randp));
hold off
title('CE2 Image points and epipolar lines')
legend('Image points','Epipolar lines')

dis = abs(sum(l.*x{2}));
mn = mean(dis);
display(['Mean distance = ' num2str(mn)])

figure(2)
hist(dis,100);
title('CE2 Histogram of Distances Between Image Points and Their Respective Epipolar Lines')
xlabel('Distance Between Epipolar Line and Image Point')
ylabel('Number of Image Points')
save('compEx3data.mat')
