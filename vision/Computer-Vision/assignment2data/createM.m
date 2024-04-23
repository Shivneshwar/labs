function [M] = createM(Xmodel,xtilde)
M=zeros(size(Xmodel,2)*3,4*3+size(Xmodel,2));
for i=1:size(Xmodel,2)
M(3*(i-1)+1,1:4)=[Xmodel(:,i);1]';
M(3*(i-1)+2,5:8)=[Xmodel(:,i);1]';
M(3*i,9:12)=[Xmodel(:,i);1]';
M(3*(i-1)+1:3*i,12+i)=-xtilde(:,i);
end

end

