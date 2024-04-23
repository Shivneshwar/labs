load('compEx1.mat');
for i=1:max(size(x2D))
    two_D(:,i) = pflat(x2D(:,i));
end
for i=1:max(size(x3D))
three_D(:,i) = pflat(x3D(:,i));
end
figure(1)
subplot(1,2,1)
plot(two_D(1,:),two_D(2,:),'o','MarkerSize',4,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
title('Homogeneous coordinates of x2D')
axis equal
subplot(1,2,2)
plot3(three_D(1,:),three_D(2,:),three_D(3,:),'o','MarkerSize',4,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
title('Homogeneous coordinates of x3D')
axis equal