
datadir=['/nfs/data/main/M23/ztemp/LAT1/']; 

k=0; clear d
for i=1:405
    dN=dir([datadir filesep 'LAT1-N*LAT1*_' sprintf('%04d',i) '.tif']);
    if ~isempty(dN)
        k=k+1;
        d(k)=dN(1);
    end;
    dIHC=dir([datadir filesep 'LAT1-IHC*LAT1*_' sprintf('%04d',i) '.tif']);
    if ~isempty(dIHC)
        k=k+1;
        d(k)=dIHC(1);
    end;
end;
nsect=numel(d);
tic;
for i=1:nsect
    flnm0=d(i).name;
    A(:,:,:,i)=imread([datadir filesep flnm0]);
    if mod(i,20)==0 fprintf(1,'read section %d of %d\n', i, nsect); end;
end;
toc;

[nZ, nX, nCh, ny] = size(A);
[1125, 1500, 3, 779]

%**************************************
% write out N Coronal Stack
cd /data1/PORTAL_VIDEOS/LAT1_N_PNGS1/
k=0;
for j=70:1:750 %1:4:779
    I = permute(squeeze(A(:,:,:,j)),[1 2 3]);
    k=k+1;
    flnm1 = sprintf('%04d_LAT1-N_C.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,681); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/LAT1_N_PNGS1/%4d_LAT1-N_C.png -r 10 -vb 20M -aspect 1.333 LAT1-N_C.mp4

%**************************************
% write out N Transverese Stack
cd /data1/PORTAL_VIDEOS/LAT1_N_PNGS2/
k=0;
for j=1:3:nZ %350:4:nZ-500
    I = permute(squeeze(A(j,:,:,:)),[1 3 2]); % rostrocaudal is HORIZ
    k=k+1;
    flnm1 = sprintf('%04d_LAT1-N_T.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,375); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/LAT1_N_PNGS2/%4d_LAT1-N_T.png -r 10 -vb 20M -aspect 1.4674  LAT1-N_T.mp4

%**************************************
% write out N Saggital Stack
cd /data1/PORTAL_VIDEOS/LAT1_N_PNGS3/
k=0;
for j=nX:-3:1 %350:4:nZ-500
    I = permute(squeeze(A(:,j,:,:)),[1 3 2]);
    k=k+1;
    flnm1 = sprintf('%04d_LAT1-N_S.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,500); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/LAT1_N_PNGS3/%4d_LAT1-N_S.png -r 10 -vb 20M -aspect  1.9565  LAT1-N_S.mp4


% aspectratios
X=1500*16*0.46; Y=810*20; Z=1125*16*0.46; 
aS=Y/Z; aC=X/Z; aT=Y/X;
round([X Y Z])
[aC aT aS]


%******************************************************
%******************************************************
datadir=['/nfs/data/main/M23/ztemp/LAT2/'];

k=0; clear d
for i=1:519
    dN=dir([datadir filesep 'LAT2-N*LAT2*_' sprintf('%04d',i) '.tif']);
    if ~isempty(dN)
        k=k+1;
        d(k)=dN(1);
    end;
    dIHC=dir([datadir filesep 'LAT2-IHC*LAT2*_' sprintf('%04d',i) '.tif']);
    if ~isempty(dIHC)
        k=k+1;
        d(k)=dIHC(1);
    end;
end;
nsect=numel(d);
tic;
k=0;
for i=1:2:nsect
    flnm0=d(i).name;
    k=k+1;
    A(:,:,:,k)=imread([datadir filesep flnm0]);
    if mod(k,20)==0 fprintf(1,'read section %d of %d\n', i, nsect); end;
end;
toc;

[nZ, nX, nCh, ny] = size(A)
[1125, 1500, 3, 911]
[2250, 3000, 3, 456]

%**************************************
% write out N Coronal Stack
cd /data1/PORTAL_VIDEOS/LAT2_N_PNGS1/
k=0;
for j=1:1:456 %1:4:779
    I = permute(squeeze(A(:,:,:,j)),[1 2 3]);
    k=k+1;
    flnm1 = sprintf('%04d_LAT2-N_C.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,681); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/LAT2_N_PNGS1/%4d_LAT2-N_C.png -r 10 -vb 20M -aspect 1.333 LAT2-N_C.mp4

%**************************************
% write out N Transverese Stack
cd /data1/PORTAL_VIDEOS/LAT2_N_PNGS2/
k=0;
for j=51:3:nZ %350:4:nZ-500
    I = permute(squeeze(A(j,:,:,:)),[1 3 2]);  % rostrocaudal is HORIZ
    k=k+1;
    flnm1 = sprintf('%04d_LAT2-N_T.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,734); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/LAT2_N_PNGS2/%4d_LAT2-N_T.png -r 10 -vb 20M -aspect 0.9420  LAT2-N_T.mp4

%**************************************
% write out N Saggital Stack
cd /data1/PORTAL_VIDEOS/LAT2_N_PNGS3/
k=0;
for j=nX-500:-3:500 %350:4:nZ-500
    I = permute(squeeze(A(:,j,:,:)),[1 3 2]);
    k=k+1;
    flnm1 = sprintf('%04d_LAT2-N_S.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,667); end;
end;

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/LAT2_N_PNGS3/%4d_LAT2-N_S.png -r 10 -vb 20M -aspect  1.2560  LAT2-N_S.mp4


% aspectratios
X=3000*16*0.46; Y=1040*20; Z=2250*16*0.46; 
aS=Y/Z; aC=X/Z; aT=Y/X;
round([X Y Z])
[aC aT aS]
22080     20800     16560
1.3333    0.9420    1.2560











