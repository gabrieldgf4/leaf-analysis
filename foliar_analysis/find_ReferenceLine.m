%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%

% Try to find the central line of a leaf

function ref_line = find_ReferenceLine(leaf)

%e_bordas = bwmorph(leaf(:,:,2) > 0, 'remove');
bw = logical(leaf(:,:,2));
bw = imfill(bw,'holes');
e_bordas = bwmorph(bw, 'remove');

[rows, columns] = find(e_bordas);

xy = [rows, columns];
D = pdist(xy, 'mahalanobis');
Z = squareform(D);

[a, b] = find( Z == max(Z(:)), 1 );

p1 = xy( a, : );
p2 = xy( b, : );

ref_line = [ p1; p2 ];

end