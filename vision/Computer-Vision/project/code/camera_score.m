function [P,score] = camera_score(points2d,cloudPoints,Ps)
    temp_err=20;
    P=Ps{1};
    for i=1:length(Ps)
        reprojected = pflat([eye(3),zeros(3,1)]*pextend(Ps{i}*pextend(cloudPoints)));
        diff=norm(mean(points2d-reprojected(1:2,:),2));
        if temp_err>diff
            P=Ps{i};
        end
    end
    reprojected = reprojected(1:2,:);
    diff=sqrt((points2d(1,:)-reprojected(1,:)).^2+(points2d(2,:)-reprojected(2,:)).^2);
    score=sum((abs(diff)<0.01));
        
end