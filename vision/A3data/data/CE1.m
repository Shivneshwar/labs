clear

load('compEx1data.mat');
im = imread('kronan2.JPG');

%n1 = compute_normalization_matrix(x{1});
%n2 = compute_normalization_matrix(x{2});
n1 = eye(3);
n2 = eye(3);
x1norm = pflat(n1*x{1});
x2norm = pflat(n2*x{2});
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
S(3,3) = 0;
F = U*S*V';

if det(F)~=0
    disp("Determinant not equal to 0")
end
if mean(x2norm'*F*x1norm, "all")>0.01
    disp("epipolar constraints  ̃xT2  ̃F  ̃x1 = 0 are not fulfilled")
end

F = n2'*F*n1;
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
title('CE1 Image points and epipolar lines')
legend('Image points','Epipolar lines')

dis = abs(sum(l.*x{2}));
mn = mean(dis);
display(['Mean distance = ' num2str(mn)])
display(num2str(F))

figure(2)
hist(dis,100);
title('CE1 Histogram of Distances Between Image Points and Their Respective Epipolar Lines')
xlabel('Distance Between Epipolar Line and Image Point')
ylabel('Number of Image Points')
