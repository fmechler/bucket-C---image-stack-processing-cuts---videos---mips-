function [ Amasked ] = imcube_mask_FM( A, Am, GryLvl_mask )
%imcube_mask.m
% masks A (a color image cube) with Am (a binary mask)
%   
% CALLS: gry2blk.m,  clr_swap.m
% Written by Ferenc Mechler 2014

% Default grey-level of masked image pixels
if nargin<3
    GryLvl_mask=0;
end;

sz=size(A);
nt=sz(4);
Amasked = A;
switch class(A)
    case 'uint8'
        Am=uint8(Am);
    case 'uint16'
        Am=uint16(Am);
    case 'double'
        Am=double(Am);
end;
% fprintf(1,'class A: %s    Am: %s\n',class(A),class(Am));

for i=1:nt,
    for c=1:3
        Amasked(:,:,c,i)=squeeze(A(:,:,c,i)).*squeeze(Am(:,:,i));
    end
end

%re-color solid gray patches in the background into black
Amasked = gry2blk(Amasked);
if 0
    gry = 127*[1 1 1];
    blk = [0 0 0 ];
    Amasked = clr_swap(Amasked,gry,blk);
end;

%re-color solid blk background into prescribed backround grey level
Amasked(Amasked==0) = GryLvl_mask;