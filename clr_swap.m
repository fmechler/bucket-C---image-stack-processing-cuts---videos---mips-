
function  Aout = clr_swap(Ain,c1,c2)

% function  Aout = clr_swap(Ain,c1,c2)
%
% Replace color c1=[r1,g1,b1] with c2=[r2,g2,b2] in input image Ain
%
% Example: Aout = clr_swap(Ain,[127 127 127], [c0 0 0])
% to re-color solid gray patches in the background into black
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

if nclr==1
    ii=find(Ain==c1(1));
    A2(ii)=c2(1);
end;

if nclr==3
    for i=1:nim
        r=squeeze(Ain(:,:,1,i));
        g=squeeze(Ain(:,:,2,i));
        b=squeeze(Ain(:,:,3,i));
        ii=find(r==c1(1) & g==c1(2) & b==c1(3));
        r(ii)=c2(1);
        g(ii)=c2(2);
        b(ii)=c2(3);
        A2(:,:,1,i)=r;
        A2(:,:,2,i)=g;
        A2(:,:,3,i)=b;
    end;
end;

Aout = A2;

