clear all 

im1 = imread('cube1.JPG');
im2 = imread('cube2.JPG');

[f1, d1] = vl_sift(single(rgb2gray(im1)) , 'PeakThresh', 1);
[f2, d2] = vl_sift(single(rgb2gray(im2)) , 'PeakThresh', 1);

figure(1)
subplot(1,2,1)
vl_plotframe(f1);
axis equal
subplot(1,2,2)
vl_plotframe(f2);
axis equal

[matches , scores] = vl_ubcmatch(d1, d2);

x1 = [f1(1, matches(1, :)); f1(2, matches(1, :))];
x2 = [f2(1, matches(2, :)); f2(2, matches(2, :))];

perm = randperm(size(matches,2));
figure(2);
imagesc([im1, im2]);
hold on;
plot([x1(1, perm(1:10)); x2(1, perm(1:10)) + size(im1,2)],...
[x1(2, perm(1:10));x2(2, perm(1:10))],'-');
hold off;
axis equal

save('CE3.mat', 'x1', 'x2');