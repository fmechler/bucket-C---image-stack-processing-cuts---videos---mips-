
%***************************************************************************************************************
%***************************************************************************************************************
% Read in the in-skull registered color Nissl 10 x 10 x 10 image cube that Amit generated at some time in 2014

datadir=['/data1/DUKE_dataset/10x10x10_Corrected_Final2/'];
d=dir([datadir filesep '*_JGA_N_*.png']);
nsect = numel(d);
%A=zeros(1500,1500,3,1056);
for i=1:nsect
    A(:,:,:,i)=imread([datadir filesep d(i).name]); 
    if mod(i,20)==0 fprintf(1,'reading frame %d of %d\n',i,nsect); end;
end;
%A=uint8(A);
[nZ, nX, nCh, ny] = size(A);
[1500, 1500, 3, 1056]

%**************************************
% write out N Coronal Stack
cd /data1/PORTAL_VIDEOS/JGA1_N_PNGS1/
k=0;
for j=1:1:1056 
    %I = squeeze(A(:,:,:,j));
    I = uint8(A(188:1500-188,:,:,j));   % Vert=1125 Horiz=1500
    k=k+1;
    flnm1 = sprintf('%04d_JGA1-N_C.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,1056); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/JGA1_N_PNGS1/%4d_JGA1-N_C.png -r 10 -vb 20M -aspect 1.333 JGA1-N_C.mp4


%**************************************
% write out N Transverese Stack
cd /data1/PORTAL_VIDEOS/JGA1_N_PNGS2/
k=0;
for j=375:1:1500-375 
    I = permute(uint8(squeeze(A(j,222:1500-222,:,:))),[3 1 2]);   % permute(*,[3 1 2]) -> rostrocaudal=Vert=1056 mediolateral=Horiz=1056
    k=k+1;
    flnm1 = sprintf('%04d_JGA1-N_T.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,751); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/JGA1_N_PNGS2/%4d_JGA1-N_T.png -r 10 -vb 20M -aspect 1.000  JGA1-N_T.mp4

%**************************************
% write out N Saggital Stack
cd /data1/PORTAL_VIDEOS/JGA1_N_PNGS3/
k=0;
for j=250:1:1500-250 
    I = permute(uint8(squeeze(A(188:1500-188,j,:,:))),[1 3 2]);    % Vert=1125 Horiz=1056
    k=k+1;
    flnm1 = sprintf('%04d_JGA1-N_S.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,1001); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/JGA1_N_PNGS3/%4d_JGA1-N_S.png -r 10 -vb 20M -aspect  0.9467  JGA1-N_S.mp4
%1065/1125 = 0.9467

% aspectratios [max coronal section id = 1065]
X=1500*10; Y=1500*10; Z=1065*10; 
aS=Y/Z; aC=X/Z; aT=Y/X;
round([X Y Z])        
[aC aT aS]
% 15000       10650       15000
% 1.0000      1.4085      1.4085
% 1/1.4085 = 0.71  (need inverse aspect ratio b/c ffmpeg automatically
% applies it to short:long instead of Vert:Horiz

%***************************************************************************************************************
%***************************************************************************************************************
% Read in the de-skulled registered monochrome Nissl 20 x 20 x 22.5 image cube that Amit generated at some time in 2014
for i=1:540 
    A(:,:,:,i)=imread('/data1/Nissl_Atlas_Pipeline/Data/amitExamples/JGA120x20x20_gray_deskulled.tif','Index',i); 
end;

[nZ, nX, nCh, ny] = size(A);
[750, 750, 1, 540]

cd /data1/PORTAL_VIDEOS/;
mkdir JGA1_N_PNGS1/;
mkdir JGA1_N_PNGS2/;
mkdir JGA1_N_PNGS3/;

%**************************************
% write out N Coronal Stack
cd /data1/PORTAL_VIDEOS/JGA1_N_PNGS1/
k=0;
for j=1:1:540 
    I = squeeze(A(:,:,:,j));
    k=k+1;
    flnm1 = sprintf('%04d_JGA1-N_C.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,540); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/JGA1_N_PNGS1/%4d_JGA1-N_C.png -r 10 -vb 20M -aspect 1.000 JGA1-N_C.mp4

%**************************************
% write out N Transverese Stack
cd /data1/PORTAL_VIDEOS/JGA1_N_PNGS2/
k=0;
for j=180:1:520 %350:4:nZ-500
    I = permute(squeeze(A(j,:,:,:)),[1 3 2]);
    k=k+1;
    flnm1 = sprintf('%04d_JGA1-N_T.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,341); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/JGA1_N_PNGS2/%4d_JGA1-N_T.png -r 10 -vb 20M -aspect 0.82  JGA1-N_T.mp4

%**************************************
% write out N Saggital Stack
cd /data1/PORTAL_VIDEOS/JGA1_N_PNGS3/
k=0;
for j=120:1:630 %350:4:nZ-500
    I = permute(squeeze(A(:,j,:,:)),[1 3 2]);
    k=k+1;
    flnm1 = sprintf('%04d_JGA1-N_S.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,511); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/JGA1_N_PNGS3/%4d_JGA1-N_S.png -r 10 -vb 20M -aspect  0.82  JGA1-N_S.mp4


% aspectratios
X=750*20; Y=540*20; Z=750*20; 
aS=Y/Z; aC=X/Z; aT=Y/X;
round([X Y Z])        
[aC aT aS]
% 15000       10800       15000
% 1.0000    0.7200    0.7200
X=750*20; Y=540*23; Z=750*20; 
aS=Y/Z; aC=X/Z; aT=Y/X;
round([X Y Z])        
[aC aT aS]

% 15000       12420       15000
% 1.0000    0.8200    0.8200 

