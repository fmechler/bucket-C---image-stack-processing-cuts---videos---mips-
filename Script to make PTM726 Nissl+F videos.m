

cd /data1/PORTAL_VIDEOS/PTM726_N_PNGS1

d=dir('*PTM726-N*.png');
nsect=numel(d);
for i=1:nsect
    flnm0=d(i).name;
    flnm1=[flnm0(1:13) '_C.png'];
    system(['mv ' flnm0 ' ' flnm1]);
end;


d=dir('*PTM726-F*.png');
nsect=numel(d);
tic;
for i=1:nsect
    flnm0=d(i).name;
    A1(:,:,:,i)=imread(flnm0);
    if mod(i,20)==0 fprintf(1,'read section %d of %d\n', i, nsect); end;
end;
toc;

[nZ, nX, nCh, ny] = size(A);


%**************************************
% write out N Transverese Stack
cd /data1/PORTAL_VIDEOS/PTM726_N_PNGS2/
k=0;
for j=100:1:750-100 %350:4:nZ-500
    I = permute(squeeze(A(j,end:-1:1,:,:)),[3 1 2]);  % rostrocaudal is VERT
    k=k+1;
    flnm1 = sprintf('%04d_PTM726-N_T.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,550); end;
end;

%**************************************
% write out F Transverese Stack
cd /data1/PORTAL_VIDEOS/PTM726_F_PNGS2/
k=0;
for j=100:1:750-100 %350:4:nZ-500
    I = permute(squeeze(A1(j,end:-1:1,:,:)),[3 1 2]);  % rostrocaudal is VERT
    k=k+1;
    flnm1 = sprintf('%04d_PTM726-F_T.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,550); end;
end;

%**************************************
% write out N Saggital Stack
cd /data1/PORTAL_VIDEOS/PTM726_N_PNGS3/
k=0;
for j=1000-125:-1:125 %600:4:nX-600
    I = permute(squeeze(A(75:750-75,j,:,:)),[1 3 2]);
    k=k+1;
    flnm1 = sprintf('%04d_PTM726-N_S.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,751); end;
end;

%**************************************
% write out F Saggital Stack
cd /data1/PORTAL_VIDEOS/PTM726_F_PNGS3/
k=0;
for j=1000-125:-1:125 %600:4:nX-600
    I = permute(squeeze(A1(75:750-75,j,:,:)),[1 3 2]);
    k=k+1;
    flnm1 = sprintf('%04d_PTM726-F_S.png',k);
    imwrite(I,flnm1,'png');
    if mod(k,20)==0 fprintf(1,'writing frame %d of %d\n',k,751); end;
end;


ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/PTM726_N_PNGS1/%4d_PTM726-N_C.png -r 10 -vb 20M -aspect  1.333  PTM726-N_C.mp4
ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/PTM726_F_PNGS1/%4d_PTM726-F_C.png -r 10 -vb 20M -aspect  1.333  PTM726-F_C.mp4

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/PTM726_N_PNGS2/%4d_PTM726-N_T.png -r 10 -vb 20M -aspect  0.99  PTM726-N_T.mp4
ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/PTM726_F_PNGS2/%4d_PTM726-F_T.png -r 10 -vb 20M -aspect  0.99  PTM726-F_T.mp4

ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/PTM726_N_PNGS3/%4d_PTM726-N_S.png -r 10 -vb 20M -aspect  1.655  PTM726-N_S.mp4
ffmpeg -y -r 10 -f image2 -i /data1/PORTAL_VIDEOS/PTM726_F_PNGS3/%4d_PTM726-F_S.png -r 10 -vb 20M -aspect  1.655  PTM726-F_S.mp4



