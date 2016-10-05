function d = sqdist(a,b)
% sqdist - computes pairwise squared Euclidean distances between points

% original version by Roland Bunschoten, 1999

d1 = bsxfun(@plus,sum(a.^2,1)',sum(b.^2,1));
d2 = (2*a)'*b;
d = d1 - d2;

