function [ Cartesian ] = pflat( Homo )
    for i=1:size(Homo,2)
        Cartesian(:,i)=Homo(:,i)./Homo(end,i); 
    end
end

