function [err,res] = ComputeReprojectionError(P,U,u)
%Compute the reprojection error from the current solution P,U and the
%imagedata u. The value of each residual is in res.

err = 0;
res = [];
proj = pflat(P*U);
proj = proj(1:2,:);
vis = isfinite(u(1,:));
err=norm(proj - u(1:2,:));
res = ((P(1,:)*U(:,vis))./(P(3,:)*U(:,vis)) - u(1,vis)).^2 + ...
            ((P(2,:)*U(:,vis))./(P(3,:)*U(:,vis)) - u(2,vis)).^2;

end
