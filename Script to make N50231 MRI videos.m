
%**************************************************
% registered Nissls from PMD2084 and PMD2050
%**************************************************

datadir = '/nfs/data/main/M1/danieldf/Nissl_Atlas_Pipeline/Data/';
flnm = 'movingToFixed_prWSgreedySyN_bwarp.tif'; 

for i=1:300
    A(:,:,:,i)=imread([datadir filesep flnm],'index',i); 
    if mod(i,20)==0 fprintf(1,'reading frame %d of %d\n',i,nsect); end;
end;
%A=uint8(A);
[nZ, nX, nCh, ny] = size(A);
[1125, 1500, 3, 1056]

%**************************************
datadir = '/data1/DUKE_dataset/';
flnm = 'DUKE_mri_Coronal_withSkull.tif';

for i=1:1024
    A(:,:,:,i)=imread([datadir filesep flnm],'index',i); 
    if mod(i,20)==0 fprintf(1,'reading frame %d of %d\n',i,nsect); end;
end;
%A=uint8(A);
[nZ, nX, nCh, ny] = size(A);
[514, 512, 1, 1024]


%**************************************
% write out N Coronal Stack
cd /data1/PORTAL_VIDEOS/N50231_MRI_PNGS1/
k=0;
for j=1:1:1024 
    %I = squeeze(A(:,:,:,j));
    I = uint8(A(:,:,:,j));   % Vert=514 Horiz=512
    k=k+1;
    flnm1 = sprintf('%04d_N50231-MRI_C.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,1024); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/N50231_MRI_PNGS1/%4d_N50231-MRI_C.png -r 10 -vb 20M -aspect 1.000 N50231-MRI_C.mp4

%**************************************
% write out MRI Transverese Stack
cd /data1/PORTAL_VIDEOS/N50231_MRI_PNGS2/
k=0;
for j=51:1:464 
    I = permute(uint8(squeeze(A(j,:,:,:))),[1 2]);   % permute(*,[1 2]) -> rostrocaudal=Vert=1024 mediolateral=Horiz=512
    k=k+1;
    flnm1 = sprintf('%04d_N50231-MRI_T.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,413); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/N50231_MRI_PNGS2/%4d_N50231-MRI_T.png -r 10 -vb 20M -aspect 2.0  N50231-MRI_T.mp4

%**************************************
% write out MRI Saggital Stack
cd /data1/PORTAL_VIDEOS/N50231_MRI_PNGS3/
k=0;
for j=1:1:512 
    I = permute(uint8(squeeze(A(:,j,:,:))),[1 2]);    % Vert=514 Horiz=1024
    k=k+1;
    flnm1 = sprintf('%04d_N50231-MRI_S.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,512); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/N50231_MRI_PNGS3/%4d_N50231-MRI_S.png -r 10 -vb 20M -aspect  2.0  N50231-MRI_S.mp4

