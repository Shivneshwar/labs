clc
clear all
close all

x1 = [1 2 3 1];
x2 = [1 1 1 1];
x3 = [1 1 -1 1];

P = [eye(3),[0 ;0; 1]];
lambda = 1;

X1 = (P*x1')/lambda; X2 = (P*x2')/lambda; X3 = (P*x3')/lambda;
labels = {'point 1','point 2','point 3'};
figure(1)
plot3([x1(1),x2(1),x3(1)],[x1(2),x2(2),x3(2)],[x1(3),x2(3),x3(3)],'o','MarkerSize',4,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
title('Points in 3D space')
text([x1(1),x2(1)-0.1,x3(1)],[x1(2),x2(2)-0.1,x3(2)+0.2],[x1(3)-0.5,x2(3),x3(3)],labels)
grid on
xlabel('X-coordinate')
ylabel('Y-coordinate')
zlabel('Z-coordinate')
figure(2)
plot([X1(1), X2(1), X3(1)],[X1(2), X2(2), X3(2)],'o','MarkerSize',4,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
title('Points in camera plane')
text([X1(1)+0.1, X2(1)+0.1, X3(1)-0.3],[X1(2)-0.06, X2(2)+0.06, X3(2)+0.06],labels)
grid on
xlabel('X-coordinate')
ylabel('Y-coordinate')
