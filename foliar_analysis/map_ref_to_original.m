%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


% lf = map_ref_to_original(leaf_models{1,1}, leaf_original_back(1,:));
%
% lf = map_ref_to_original(leaf_models{138,1}, leaf_original_back(138,:));
% figure; imshowpair(leaf_original_and_seg{138,1}, lf)

function leaf = map_ref_to_original(leaf, leaf_original_back)
 
 leaf = imresize(leaf, leaf_original_back{1}, 'nearest', 'Antialiasing', false);
 
 leaf = padarray(leaf, [0, leaf_original_back{2}(1)], 'pre');
 leaf = padarray(leaf, [0, leaf_original_back{2}(2)], 'post');
 leaf = padarray(leaf, [leaf_original_back{2}(3), 0], 'pre');
 leaf = padarray(leaf, [leaf_original_back{2}(4), 0], 'post');
  
 leaf = imrotate(leaf, leaf_original_back{3});
  
 bw = logical(leaf(:,:,2));
 bw = imfill(bw,'holes');
 [rows, columns] = find(bw);
 leaf = leaf(min(rows):max(rows), min(columns):max(columns), : );
 
 leaf = imresize(leaf, leaf_original_back{4}, 'nearest', 'Antialiasing', false);
 
 leaf = imresize(leaf, leaf_original_back{5}, 'nearest', 'Antialiasing', false);

 leaf = padarray(leaf, [0, leaf_original_back{6}(1)], 'pre');
 leaf = padarray(leaf, [0, leaf_original_back{6}(2)], 'post');
 leaf = padarray(leaf, [leaf_original_back{6}(3), 0], 'pre');
 leaf = padarray(leaf, [leaf_original_back{6}(4), 0], 'post');
 
 leaf = imresize(leaf, leaf_original_back{4}, 'nearest', 'Antialiasing', false);


end