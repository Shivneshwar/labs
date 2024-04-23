clc
clear all 
close all

%% X1 and X2 transdormation 
H = [1 1 0; 0 1 0; -1 0 1];
x1 = [1;0; 1]; x2 = [0; 1; 1];

y1 = H*x1; y2 = H*x2;

%y1(3)=1;
%% Lines that pass through the points of interset %%
L1 = pflat(cross(x1,x2));
L2 =pflat(cross(y1,y2));
L3 = pflat(inv(H)'*L1);
figure(1)
markerSize = 6;
hold on
plot(x1(1),x1(2),'o','MarkerSize',markerSize,'MarkerEdgeColor','blue',...
    'MarkerFaceColor','blue')
plot(x2(1),x2(2),'o','MarkerSize',markerSize,'MarkerEdgeColor','blue',...
    'MarkerFaceColor','blue')
plot([x2(1,:); x1(1,:)],[x2(2,:); x1(2,:)],'b-');
xlim([-1 2])
ylim([-1 2])

figure(2)
markerSize = 6;
hold on
plot(y1(1),y1(2),'o','MarkerSize',markerSize,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
plot(y2(1),y2(2),'o','MarkerSize',markerSize,'MarkerEdgeColor','red',...
    'MarkerFaceColor','red')
plot([y2(1,:); y1(1,:)],[y2(2,:); y1(2,:)],'b-');
xlim([-1 2])
ylim([-1 2])

% figure(3)
% L1_x = L1(1)*linspace(0,1,100);
% L1_y = L1(2)*linspace(0,1,100);
% L1_z = L1(3)*linspace(0,1,100);
% 
% scatter3([y1(1);y2(1)],[y1(2);y2(2)],[y1(3);y2(3)])
