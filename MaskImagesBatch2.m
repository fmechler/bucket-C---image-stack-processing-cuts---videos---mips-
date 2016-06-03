
function  MaskImagesBatch2(dir_in, dir_out, th_mask, animate_flag,save_flag)

% function  MaskImagesBatch2(dir_in, dir_out, th_mask, animate_flag,save_flag)
%
% Produce Masked image cube from input *.png section images of F or IHC
% brain in dir_in (ful path).
% It checks the filenme of the input *.png to determine the image modality  F or IHC
% The output, the tissue-masked images masked_00xx.png, are written into dir_in
%
%  Calls:
%       make_imcube
%       img_int_FM
%       imcube_open3_FM  % uses imopen & imdilate (Matlab image toolbox functions)
%       imcube_mask_FM
%       animate_cube
%
%  Modified by Ferenc Mechler 2014 from script written by Partha

tic;
% echo off all

[pathstr,name,ext] = fileparts(dir_in);

if nargin < 2
    % dir_out = pwd;
    % dir_out = dir_in;
    dir_out = [pwd filesep name '_MSK'];
end;

[SUCCESS,MESSAGE,MESSAGEID] = mkdir(dir_out);
fprintf('DIR_OUT:   %s %30s\n',dir_out,MESSAGE);

if nargin < 4
    animate_flag = false;
    %animate_flag =  true;
end;

if nargin < 5
    save_flag = true;
end;

if regexp(name,'F')
    im_mode = 1;
elseif regexp(name,'IHC') | regexp(name,'HC')
    im_mode = 2;
elseif regexp(name,'N')
    im_mode = 3;
else
    fprintf(1,'\nError in MaskImages - Exiting\n Unknown image modality (should be F or IHC or N) in this directory\n');
    return;
end;

fprintf(1,'Building & saving image cube from transformed *.png images found in...\nDIR_IN: %s:\n',dir_in);
A = make_imcube(dir_in, dir_out);
toc;

% A = image cube

% Ai    is the intensity image.
% th    is a threshhold that has been set to be 325 for _F images & 40 for _IHC images
%       (& presumably _N images, too, but this needs to be experimentally verified)
%       Generally, examination of the histogram of intensities may be required to adjust the threshhold.
% Am    is the resulting (binary) image mask.
% Am_open are the images after morphological operation to remove stray voxels in the background

fprintf(1,'\nMasking images...\n');
for k_pass=1:2
    
    % Define default pamaters for each image-modality
    switch im_mode
        case 1
            GryLvl_mask = 0;
            th_default = 30;
            strel_rad = 5;
            strel_scaleup = 10;
        case 2
            GryLvl_mask = 220;
            th_default = 335;
            strel_rad = 5;
            strel_scaleup = 4;
        case 3
            GryLvl_mask = 220;
            th_default = 370;
            strel_rad = 2;
            strel_scaleup = 10;
        otherwise
            return;
    end;
    
    if nargin >= 3
        th = th_mask;
    else
        th = th_default;
    end;
    % create binary mask with 1==above_th0 and  0==below_th0 intensity
    % where th0 is the computed optimal intensity threshold (assumes there is a histogram valley in the neighborhood of th)
    [Ai Am hi Ii, th0]=img_int_FM(A,th);
    % invert mask for darfield (F) images where the background is dark
    if im_mode==1
        Am=1-Am;
    end;
    fprintf(1,'Optimal intensity threshold at level %6d  (where 441 is max corresponding to grey level 255)\n',th0);
    
    switch k_pass
        case 1
            % erode isolated specks (and fill in "moth-eaten" holes) in mask
            Am_open=imcube_open3_FM(Am,strel_rad,strel_scaleup);
            % Mask the original image and re-color solid-grey backround patches
            Amasked=imcube_mask_FM(A,Am_open,GryLvl_mask);
            % Save light intensity histogramm
            hist_flnm = [dir_out filesep 'IntensityHisto.mat'];
            save(hist_flnm, 'hi', 'Ii');
            figure(2); plot(Ii,hi);
        case 2
            % keep mask unchanged
            Am_open=imcube_open3_FM(Am,1);
            % Mask the image
            Amasked=imcube_mask_FM(A,Am_open,GryLvl_mask);
    end;
    
    A=Amasked;
    
end; % for k_pass
toc;

if animate_flag
    % Animate the cube for visual inspection
    fprintf(1,'\nAnimating masked images...\n');
    figure(1); clf;
    for k=1:1
        animate_cube(Amasked/255);
    end;
else
        fprintf(1,'\nSkipping Animation of masked images...\n');
end;
    toc;

if save_flag
    % Write the masked *.png images
    fprintf(1,'\nWriting masked transformed *.png images in %s....\n', dir_out);
    Aout = uint8(Amasked);
    [nw,nh,nchan,nC] = size(Aout);
    % Coronal Fly-through
    for i=1:nC
        outflnm = [dir_out filesep sprintf('%04d',i) '_masked_C.png'];
        imwrite(squeeze(Aout(:,:,:,i)),outflnm,'png');
    end;
    % Sagittal Fly-through
    i_offset = 70;
    for i=i_offset:3:nh-i_offset
        outflnm = [dir_out filesep sprintf('%04d',1+(i-i_offset)/3) '_masked_S.png'];
        imwrite(permute(squeeze(Aout(:,i,:,:)),[1 3 2]),outflnm,'png');
    end;
    % Horizontal Fly-through
    for i=i_offset:3:nw-i_offset
        outflnm = [dir_out filesep sprintf('%04d',1+(i-i_offset)/3) '_masked_T.png'];
        imwrite(permute(squeeze(Aout(i,:,:,:)),[1 3 2]),outflnm,'png');
    end;
    
    toc;
end;

clear all;
