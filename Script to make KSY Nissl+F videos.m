
brainID='KSY4'; seriesID='N';
th_rgb=100; noMask_flag=1; 

datadir='/mnt/data001/registeredTIFFreduce8/';
    dirname=[datadir filesep brainID filesep];
    d=dir([dirname filesep '*-' seriesID '*.tif']);
    nd=numel(d);
    A=zeros(2250,3000,3,nd,'uint16');

% for each section in the list, extract filename and mode index
% filename and store it an a structure 'SectionOnDisk'
clear secNo secName
for id=1:nd
    secName{id}=d(id).name([1:end-4]);
    secNo(id)=sscanf(d(id).name([end-7:end-4]),'%d');
end;
[secNo_ord, ii_ord]=sort(secNo);
d1=d(ii_ord);

%% Load image stack
imx=nd;
tic;
for i=1:imx
    im_flnm=[dirname filesep d1(i).name];
    I=imfinfo(im_flnm);
    nx=I.Width; ny=I.Height;
    u=imread(im_flnm);
    A(1:ny,1:nx,:,i)=u;
    %Amx=max(A,[],4);
    %A(:,:,:,1)=Amx;
    if mod(i,10)==0 fprintf(1,'...reading image %d of %d \n',i,imx); end;
end;
toc;

%% Mask brain-tissue from background
if ~noMask_flag
    A=Mask_F_Imcube(A);
end;


[nZ nX nch nY]=size(A);
Xpxl = 2^3*0.45;
Zpxl = 2^3*0.45;
Ypxl = (diff(secNo_ord([1 end]))+1)/nY*40;
[Xpxl Ypxl Zpxl]

%**************************************
% write out Coronal Stack
k=0;  dj0=0; djend=0;
for j=1+dj0:nY-djend
    I = permute(squeeze(A(:,:,:,j)),[1 2 3]);
    I = imresize(I,[size(I,1) round(size(I,2)*Zpxl/Xpxl)]);
    k=k+1;
    flnm = sprintf(['%04d_' brainID '-' seriesID '-x3rTIF_C.png'],k);
    imwrite(uint8(I),flnm,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,round((nY-dj0-djend)/1)); end;
end;

%**************************************
% write out Saggital Stack
k=0; dj0=200; djend=200;
for j=nX-djend:-10:dj0
    I = permute(squeeze(A(:,j,:,:)),[1 3 2]);
    I = imresize(I,[size(I,1) round(size(I,2)*Ypxl/Xpxl)]);
    k=k+1;
    flnm = sprintf(['%04d_' brainID '-' seriesID '-x3rTIF_S.png'],k);
    imwrite(uint8(I),flnm,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,round((nX-dj0-djend)/10)); end;
end;

%**************************************
% write out Transverse Stack
k=0; dj0=200; djend=200;
for j=nZ-djend:-10:dj0
    I = permute(squeeze(A(j,:,:,:)),[1 3 2]);
    I = imresize(I,[size(I,1) round(size(I,2)*Ypxl/Xpxl)]);
    k=k+1;
    flnm = sprintf(['%04d_' brainID '-' seriesID '-x3rTIF_T.png'],k);
    imwrite(uint8(I),flnm,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,round((nZ-dj0-djend)/10)); end;
end;


ffmpeg -y -r 10 -f image2 -i KSY2_C/%4d_KSY2-F-x3rTIF_C.png -r 10 -vb 20M -aspect  1.333  KSY2_C.mp4
ffmpeg -y -r 10 -f image2 -i KSY2_S/%4d_KSY2-F-x3rTIF_S.png -r 10 -vb 20M -aspect  1.16  KSY2_S.mp4
ffmpeg -y -r 10 -f image2 -i KSY2_T/%4d_KSY2-F-x3rTIF_T.png -r 10 -vb 20M -aspect  0.87  KSY2_T.mp4

ffmpeg -y -r 10 -f image2 -i KSY4_N_C/%4d_KSY4-N-x3rTIF_C.png -r 10 -vb 20M -aspect  1.333  KSY4_N_C.mp4
ffmpeg -y -r 10 -f image2 -i KSY4_N_S/%4d_KSY4-N-x3rTIF_S.png -r 10 -vb 20M -aspect  1.516  KSY4_N_S.mp4
ffmpeg -y -r 10 -f image2 -i KSY4_N_T/%4d_KSY4-N-x3rTIF_T.png -r 10 -vb 20M -aspect  1.137  KSY4_N_T.mp4

ffmpeg -y -r 10 -f image2 -i KSY4_C/%4d_KSY4-F-x3rTIF_C.png -r 10 -vb 20M -aspect  1.333  KSY4_C.mp4
ffmpeg -y -r 10 -f image2 -i KSY4_S/%4d_KSY4-F-x3rTIF_S.png -r 10 -vb 20M -aspect  1.516  KSY4_S.mp4
ffmpeg -y -r 10 -f image2 -i KSY4_T/%4d_KSY4-F-x3rTIF_T.png -r 10 -vb 20M -aspect  1.137  KSY4_T.mp4

    