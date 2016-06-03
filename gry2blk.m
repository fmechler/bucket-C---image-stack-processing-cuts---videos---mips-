
function  Aout = gry2blk(Ain)

% function  Aout = gry2blk(Ain)
%
% Paint all solid gray pxls (r=g=b>0) black (r=g=b=0) in input image Ain
%
% (Solid gray pxls are hall-mark of imposed background and are unlikely to be present in tissue part of section images)
%   
% Written by Ferenc Mechler 2014

ndim=ndims(Ain);
% monochrome single 2-dim image
if ndim < 3
    nim=1;
    nclr=1;
end;
if ndim == 3
    % single 2-dim 3-color image
    if size(Ain,3)==3
        nim=1;
        nclr=3;
        % stack of 2-d monochrome images
    else
        nim=size(Ain,3);
        nclr=1;
    end;
end;
if ndim > 3
    % stack of 2-d 3-clr images
    if ndim==4 & size(Ain,3)==3
        nim=size(Ain,4);
        nclr=3;
    else
        fprintf('Error with size of Ain: unknown image format. Exiting.\n')
        return;
    end;
end;

A2=Ain;

if nclr<3
        fprintf('Error: Ain should be color image. Exiting.\n')
        return;
end;

if nclr==3
    for i=1:nim
    r=squeeze(Ain(:,:,1,i));
    g=squeeze(Ain(:,:,2,i));
    b=squeeze(Ain(:,:,3,i));
    ii=find(r==g & r==b);
    r(ii)=0;
    g(ii)=0;
    b(ii)=0;
    A2(:,:,1,i)=r;
    A2(:,:,2,i)=g;
    A2(:,:,3,i)=b;
    end;
end;

Aout = A2;

