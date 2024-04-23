function [CTS, CTE] = transformPoints( startPoints, endPoints, H)
%This function transformes the points in startPoints and endPoints
%according the transformation matrix H. It also divides the expression by
%the last coordinate in every vector.

if size(H,1) ~= size(startPoints,1)
TS=H*[startPoints; ones(1,size(startPoints,2))];
TE=H*[endPoints; ones(1,size(endPoints,2))];
CTS=zeros(2,length(startPoints));
CTE=zeros(2,length(endPoints));

else
   TS=H*startPoints;
   TE=H*endPoints;
   CTS=zeros(size(startPoints,1)-1,length(startPoints));
   CTE=zeros(size(startPoints,1)-1,length(endPoints));
end

for i=1:length(TS)
    
    temp=pflat(TS(:,i));
    CTS(:,i)=temp(1:end-1); 
    temp=pflat(TE(:,i));
    CTE(:,i)=temp(1:end-1); 
end

end

