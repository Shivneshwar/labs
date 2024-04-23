function h_points = pflat(points)
    assert(all(points(end, :) ~= 0), 'Last coordinate cannot be zero');
    h_points = points ./ points(end, :);
end

