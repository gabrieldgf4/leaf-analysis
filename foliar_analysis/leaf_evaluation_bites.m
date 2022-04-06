%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%

% [result_TP_FP_FN] = leaf_evaluation_bites(bite_sign, original_bite_sign_to_model, 5, 12, 0.5);

function [result_TP_FP_FN] = leaf_evaluation_bites(...
    bite_sign, original_bite_sign_to_model, remove_small_bites, dilate_bite, IoU_thresh)

[h,w,c] = size(bite_sign);
if c >= 3
    bite_sign = bite_sign(:,:,2) > 0;
end

[~,~,c] = size(original_bite_sign_to_model);
if c >= 3
    gt = original_bite_sign_to_model(:,:,2) > 0;
else
    gt = original_bite_sign_to_model;
end

bite_sign = bwareaopen(bite_sign, remove_small_bites);
bite_sign = imdilate(bite_sign, strel('disk', dilate_bite));
bite_sign = bwmorph(bite_sign, 'skel', Inf);

gt = bwareaopen(gt, remove_small_bites);
gt = imdilate(gt, strel('disk', dilate_bite));
gt = bwmorph(gt, 'skel', Inf);

bite_sign_copy = bite_sign;
% gt_copy = gt;

st_bite = regionprops(bite_sign, 'BoundingBox' );
st_gt = regionprops(gt, 'BoundingBox' );
% figure, imshow(bite_sign);
% for k = 1 : length(st_bite)
%   thisBB = st_bite(k).BoundingBox;
%   rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%   'EdgeColor','r','LineWidth',2 )
% end

TP = 0;
gt_labels = bwlabel(gt);
gt_used_labels = 0;

for i=1:length(st_bite)
    xMin1 = ceil(st_bite(i).BoundingBox(1));
    xMax1 = xMin1 + st_bite(i).BoundingBox(3) - 1;
    yMin1 = ceil(st_bite(i).BoundingBox(2));
    yMax1 = yMin1 + st_bite(i).BoundingBox(4) - 1;
    
    mask_bite = zeros(h,w);
    mask_bite(yMin1:yMax1, xMin1:xMax1) = 1;
    
    for j=1:length(st_gt)
        xMin2 = ceil(st_gt(j).BoundingBox(1));
        xMax2 = xMin2 + st_gt(j).BoundingBox(3) - 1;
        yMin2 = ceil(st_gt(j).BoundingBox(2));
        yMax2 = yMin2 + st_gt(j).BoundingBox(4) - 1;
        
        mask_gt = zeros(h,w);
        mask_gt(yMin2:yMax2, xMin2:xMax2) = 1;
        
        IoU_1 = sum(sum(mask_gt & mask_bite)) / sum(sum(mask_bite));
        IoU_2 = sum(sum(mask_gt & mask_bite)) / sum(sum(mask_gt));
        
        IoU = max(IoU_1, IoU_2);
        
        if IoU >= IoU_thresh
            TP = TP + 1;
            bite_sign_copy(yMin1:yMax1, xMin1:xMax1) = 0;
            gt_labels_copy = gt_labels;
            gt_labels_copy(~mask_bite) = 0;
            gt_labels_used = unique(gt_labels_copy);
            gt_used_labels = [gt_used_labels, gt_labels_used'];
            break;
        end
    end
end

st_FP = regionprops(bite_sign_copy, 'BoundingBox' );
% figure, imshow(bite_sign_copy);
% for k = 1 : length(st_FP)
%   thisBB = st_FP(k).BoundingBox;
%   rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%   'EdgeColor','r','LineWidth',2 )
% end
 
FP = length(st_FP);

gt_labels_unique = unique(gt_labels);
gt_used_labels_unique = unique(gt_used_labels);

FN = abs( length(gt_labels_unique) - length(gt_used_labels_unique) );
 
result_TP_FP_FN = [TP, FP, FN];

end