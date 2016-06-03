function [ Am_open ] = imcube_open3_FM( Am, nr, nr_scl )
%imcube_open3_FM.m
% opens the images of Am (assumed to be a series of masks) using
% a disk shaped structure element of radius nr - applied in all 3 coordinate
% directions
%   
% CALLS: imopen.m,  im_dilate.m
% Written by Ferenc Mechler 2014

if nargin < 3
    nr_scl = 4;
end;

se=strel('disk',nr);
sz=size(Am);
Am_open=Am;

for i=1:sz(1),
    Am_open(i,:,:)=imopen(squeeze(Am(i,:,:)),se);
end
for i=1:sz(2),
    Am_open(:,i,:)=imopen(squeeze(Am_open(:,i,:)),se);
end
for i=1:sz(3),
    Am_open(:,:,i)=imopen(squeeze(Am_open(:,:,i)),se);
end
for i=1:sz(3),
    % Fill "moth-eaten"holes using a scaled-up structural element. Preferably nr_scl is specific tuned to F IHC and N images
    Am_open(:,:,i)=imdilate(squeeze(Am_open(:,:,i)),strel('disk',nr*nr_scl));
end

end

