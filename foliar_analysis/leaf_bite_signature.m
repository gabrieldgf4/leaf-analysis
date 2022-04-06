%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%

% bite_sign = leaf_bite_signature(leaf_model, leaf_damaged_to_model, 25, 2, 0.98)

function bite_sign = leaf_bite_signature(leaf_model, leaf_damaged_to_model,...
    remove_small_bites, size_disc_element, ecc_thresh)

%leaf_model_mask = leaf_model(:,:,2) > 0;
%leaf_damaged_to_model_mask = leaf_damaged_to_model(:,:,2) > 0;
leaf_model_mask = logical(leaf_model(:,:,2));
leaf_model_mask = imfill(leaf_model_mask,'holes');
leaf_damaged_to_model_mask = logical(leaf_damaged_to_model(:,:,2));
%leaf_damaged_to_model_mask = imfill(leaf_damaged_to_model_mask,'holes');

e = bwmorph(leaf_model_mask, 'remove');
e2 = bwmorph(leaf_damaged_to_model_mask, 'remove');

bite_sign = leaf_model_mask & e2;

bite_sign = bwareaopen(bite_sign, remove_small_bites);
bite_sign = imdilate(bite_sign, strel('disk', size_disc_element));

bite_labels = bwlabel(bite_sign);
st_bite = regionprops(bite_sign, 'BoundingBox', 'Eccentricity' );

for i=1:length(st_bite)
    if st_bite(i).Eccentricity > ecc_thresh
        bite_sign(bite_labels == i) = 0;
    end
end

bite_sign = imerode(bite_sign, strel('disk', size_disc_element));

% st_bite = regionprops(bite_sign, 'BoundingBox', 'Eccentricity' );
% figure, imshow(bite_sign);
% for k = 1 : length(st_bite)
%   thisBB = st_bite(k).BoundingBox;
%   rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%   'EdgeColor','r','LineWidth',2 )
% end


end