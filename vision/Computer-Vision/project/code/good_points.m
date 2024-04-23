function inds = good_points(dist_mat)
out = squareform(pdist(dist_mat'));
threshold = min(min(maxk(out,100)));
rowSums=sum(out>threshold);
nums = 1.9*mean(sum(out>threshold));
final = rowSums<nums;
inds = find(final);
end