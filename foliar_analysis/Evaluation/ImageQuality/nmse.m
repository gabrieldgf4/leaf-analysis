% Normalized Mean Square Error

function [NMSEval] = nmse(Io,In,Imf)
%/************************************************************************\
%/*                       KYUNG HEE UNIVERSITY                           *\
%/*                       Biomedical Department                          *\
%/*                 Medical Imaging System Laboratory                    *\
%/*                                                                      *\
%/*Name of Program: NORMALIZED MEAN SQUARE ERROR (NMSE)                  *\
%/*By: Eric Michel                                                       *\
%/*Date: 16th January 2011                                               *\
%/************************************************************************\
%
% Arguments:
%       Io          - Noise free (true) image
%       In          - Noisy (corrupted) image
%       Imf         - Image after beeing processed (filtered)
%
%
% Returns:
%       NMSEval     - Normalized Mean Square Error value
%
%
% Usage Example:
%               - NMSE would represent how the filtered image
%                 resembles the true image (0 value is the best).
%               NMSEval(1,iter) = nmse(Io,In,Imf);
%
%
%  Please refer (and cite) to:   
%
%  [1]  Eric Michel, Min H. Cho and Soo Y. Lee, "Geometric nonlinear 
%       diffusion filter and its application to X-ray imaging"
%       BioMedical Engineering OnLine 2011, 10:47.
%       http://www.biomedical-engineering-online.com/content/10/1/47
%
%
%       Any comments and suggestions to: eric.michel.glez@gmail.com
%                     
%                    Copyright (c) since 2011 ERIC MICHEL     
%
%**************************************************************************
%**************************************************************************
    
%------------------------------------------------------%
%      (NER)  NOISE ENERGY REDUCTION COMPUTATION       %
%------------------------------------------------------%
        %Normalize the input images
        max_i = max(Io(:));
        Io = Io./max_i;
        
        max_i = max(In(:));
        In = In./max_i;
        
        max_i = max(Imf(:));
        Imf = Imf./max_i;
        
        %Normalized Mean Square Method
        NMSEval = sum(sum((Imf-Io).^2))/sum(sum((In-Io).^2));
        
end