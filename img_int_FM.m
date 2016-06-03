function [ Ai, Am, Hi, Ii, th0 ] = img_int_FM( A, th )
%UNTITLED Computes intensity of image cube; threshholds at intensity th;
% outputs intensity histogram in pair [Hi, Ii]; outputs
% masked original image in Am.
%   Input: X x Y x 3 x z
%   Computes intensity = sqrt(R^2+G^2+B^2) and stores in Ai
%   Computes histogram of intensities with binwidth of 1 between 0 and 440=sqrt(3)*256
%   [Note that max(A(:)) is <= 255 since A is the stack of 8-bit PNG files]
%
% Written by Ferenc Mechler 2014

Ai= uint16(squeeze(sqrt(sum(uint16(A).^2,3))));
sz=size(Ai);
A1=reshape(Ai,[sz(1)*sz(2)*sz(3),1]);
[Hi Ii]=hist(A1,[0.5:1:440.5]);

% Automatically detect the optimal luminance threshold, th0
% Optimal threshold here is defined by the locus of minimum on the median-filtered (smoothed)
% histogram curve between the two peaks on either side of the pre-defined threshold, th
% (the pre-defined threshold should be in the ballpark of the optimal threshold here to be determined

% smooth the histogam
H_smooth = medfilt1(Hi(:),7);
if max(H_smooth)==0
    th0=th;
else
    % find all local peaks in the smoothed histogram that are higher than a criterion and further apart than a criterion
    [pks,locs_pk] = findpeaks(H_smooth,'minpeakheight',min(10,0.1*max(H_smooth)),'minpeakdistance',20);
    % find peak on the left side of th
    [pk_1,i_pk1]=max(pks(locs_pk<th));
    locs1=locs_pk(locs_pk<th);
    ipk1=locs1(i_pk1);
    % find peak on the right side of th
    [pk_2,i_pk2]=max(pks(locs_pk>th));
    locs2=locs_pk(locs_pk>th);
    ipk2=locs2(i_pk2);
    % find absolute min between the left and right peaks
    if max(H_smooth(ipk1:ipk2))==0 | ipk1==ipk2
        ivl1 = mean([ipk1,ipk2]);
    elseif isempty(ipk1) | isempty(ipk2)
        ivl1 = th;
    else
        [vls,locs_vl] = findpeaks(-H_smooth(ipk1:ipk2));
        [vl_1,i_vl1]=max(vls);
        ivl1 = ipk1 + locs_vl(i_vl1);
    end;
    th0=ivl1;
end;

% define optimal intensity threshold at the locus of the above minimum
Am=Ai<th0;

end

