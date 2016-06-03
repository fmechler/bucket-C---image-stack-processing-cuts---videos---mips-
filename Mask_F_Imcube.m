function     [Amasked]=Mask_F_Imcube(A)

% returns Amasked, a masked version of A, the input F image cube
% CALLS custom functions:
%   (1) img_int_FM;
%   (2) imcube_open3_FM;
%   (3) imcube_mask_FM;
%   (4) clr_swap;
%   (5) gry2blk
%
% Written by Ferenc Mechler (2015)

% set default masking parameters (assuming F images)
GryLvl_mask = 0;
th_default = 30;
strel_rad = 5;
strel_scaleup = 10;

th = th_default;

%Amasked=double(A);
Amasked=A;

% A = image cube
% Ai    is the intensity image.
% th    is a threshhold that has been set to be 325 for _F images & 40 for _IHC images
%       (& presumably _N images, too, but this needs to be experimentally verified)
%       Generally, examination of the histogram of intensities may be required to adjust the threshhold.
% Am    is the resulting (binary) image mask.
% Am_open are the images after morphological operation to remove stray voxels in the background

fprintf(1,'\nMasking images...\n');
tic;
for k_pass=1:2
    fprintf(1,'... Round %d ...\n',k_pass);

    % create binary mask with 1==above_th0 and  0==below_th0 intensity
    % where th0 is the computed optimal intensity threshold (assumes there is a histogram valley in the neighborhood of th)
    [Ai Am hi Ii, th0]=img_int_FM(Amasked,th);
    % invert mask (Am, logical) for darkfield (F) images where the background is dark
    Am=~Am;
    % Save light intensity histogramm
    %hist_flnm = [dir_out filesep 'IntensityHisto.mat'];
    %save(hist_flnm, 'hi', 'Ii');
    %figure(2); plot(Ii,hi);
    fprintf(1,'Optimal intensity threshold at level %6d  (where 441 is max corresponding to grey level 255)\n',th0);
    
    switch k_pass
        case 1
            % erode isolated specks (and fill in "moth-eaten" holes) in mask
            fprintf(1,'... dilate-erode image cube ...\n');
            Am_open=imcube_open3_FM(Am,strel_rad,strel_scaleup);
        case 2
            % keep mask unchanged
            Am_open=imcube_open3_FM(Am,1);
    end;
    % Mask the image
    Amasked=imcube_mask_FM(Amasked,Am_open,GryLvl_mask);
    toc;
end; % for k_pass

