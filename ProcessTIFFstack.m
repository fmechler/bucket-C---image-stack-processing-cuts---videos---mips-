function  ProcessTIFFstack(brainID,seriesID, th_rgb,noMask_flag)

%***************************************************************************************
% read in a complete TIFF stack for the F series of the brain 'portalBrainName' stored on mitradevel dir
%               /mnt/data001/registeredTIFF8reduced/
% order it based on meta data (mode index, isVisible)stored on portal DB ('mbaDB')
% generate MaxIntProjs (MIPs) in 3 cardinal cuts
% clean MIPs
% save PNG images of MIPs
% write txt file for section order list
%
% CALLS:  
%  Mask_F_Imcube.m
%  MySQL read calls to mbaDB (portal data base) - OPTIONAL
% Written by Ferenc Mechler  2014
%***************************************************************************************
fprintf(1,'Processing brain %s-%s\n',brainID,seriesID);

noMask_flag_default=0;
th_rgb_default=[0 0 100];
if nargin<4
    noMask_flag=noMask_flag_default;
end;
if nargin<3
    th_rgb=th_rgb_default;
end;

% dir list all 8-reduced TIFF sections in the F series of the brain 'portalBrainName'
%***************************************************************************************
if 0
    % GPU2 32x reduced PNGs
    datadir='/data1/PORTAL_VIDEOS/';
    dirname = [datadir filesep brainID '_' seriesID '_PNGS'];
    d=dir([dirname filesep '*-' seriesID '*.png']);
    nd=numel(d);
    A=zeros(562,750,3,nd,'uint8');
end; % if 0

if 1
    % MITRADEVEL 8x reduced TIFFs
    datadir='/mnt/data001/registeredTIFFreduce8/';
    dirname=[datadir filesep brainID filesep];
    d=dir([dirname filesep '*-' seriesID '*.tif']);
    nd=numel(d);
    A=zeros(2250,3000,3,nd,'uint16');
end; % if 0

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

%% down-sample TIFF by factor 4x
tic;
fprintf(1,'...downsampling images...');
if 1
    B=zeros(round(size(A,1)/4),round(size(A,2)/4),3,nd,'uint16');
    for id=1:nd
        B(:,:,:,id)=imresize(A(:,:,:,id),1/4);
    end;
    A=B;
end;
fprintf(1,'...done\n');
toc;

%% Mask brain-tissue from background
if ~noMask_flag
    A=Mask_F_Imcube(A);
end;

%% Calculate MIPs in 3 cardinal cuts
tic;
% Maximum Intensity Projections used for Fluorescent images
if 1
    AmxC = permute(squeeze(max(A,[],4)),[1 2 3]);
    AmxT = permute(squeeze(max(A,[],1)),[1 3 2]);
    AmxS = permute(squeeze(max(A,[],2)),[1 3 2]);
end

% Minimum Intensity Projections used for Bright Field images
if 0
    AmxC = permute(squeeze(min(A,[],4)),[1 2 3]);
    AmxT = permute(squeeze(min(A,[],1)),[1 3 2]);
    AmxS = permute(squeeze(min(A,[],2)),[1 3 2]);
    %AmxC = permute(squeeze(median(A,4)),[1 2 3]);
    %AmxT = permute(squeeze(median(A,1)),[1 3 2]);
    %AmxS = permute(squeeze(median(A,2)),[1 3 2]);
end;
toc;
%% calculate voxel size to be used for correct aspect ratios
[nZ nX nch nY]=size(A);
if 1  % MITRAGPU2 32x reduced PNGs
    Xpxl = 2^5*0.45;
    Zpxl = 2^5*0.45;
end;
if 0  % MITRADEVEL 8x reduced TIFFS
    Xpxl = 2^3*0.45;
    Zpxl = 2^3*0.45;
end;

Ypxl = (diff(secNo_ord([1 end]))+1)/nY*40;
[Xpxl Ypxl Zpxl]

%% clean colored artifacts from MIPs
th_r=th_rgb(1);
th_g=th_rgb(2);
th_b=th_rgb(3);

tic;
for j=1:3
    if j==1 C=AmxC; end;
    if j==2 C=AmxS; end;
    if j==3 C=AmxT; end;
    % clean up speckles and colored bright noise
    C=uint16(C);
    r=C(:,:,1);
    g=C(:,:,2);
    b=C(:,:,3);
    if 0
        % brains with GFP only(e.g., nuclear GFP in Hua Cre-2HG
        % threshold on RED and BLU (artifact)
        % th_r=1000; th_b=500;
        iir=find(r>th_r);
        iib=find(b>th_b);
        r(iir)=0;
        b(iib)=0;
        g(iir)=th_r; g(iib)=th_r;
    end
    if 1
        % brains with RFP & GFP only(e.g., AAV tdTomato and EGFP)
        % threshold on BLU (artifact)
        % th_b=75;
        iib=find(b>th_b);
        b(iib)=0;
        r(iib)=th_b;
        g(iib)=th_b;
    end
    C1=C;
    C1(:,:,1)=r;
    C1(:,:,3)=b;
    C1(:,:,2)=g;
    
    if j==1 AmxC_cln=C1; end;
    if j==2 AmxS_cln=C1; end;
    if j==3 AmxT_cln=C1; end;
    
    toc;
end;

%% Correct aspect ratio for each MIP
AmxS_cln_resize=imresize(AmxS_cln,[size(AmxS_cln,1) round(size(AmxS_cln,2)*Ypxl/Xpxl)]);
AmxT_cln_resize=imresize(AmxT_cln,[size(AmxT_cln,1) round(size(AmxT_cln,2)*Ypxl/Xpxl)]);
AmxC_cln_resize=AmxC_cln;

%% combine the vertical [3 x 1] array of [Coronal;Sagittal;Transverse] MIPs into a single image of size [2*size(AmxC_cln,1)+size(AmxC_cln,2),size(AmxC_cln,2)] pxls
u=zeros(size(AmxC_cln_resize,1)*2+size(AmxC_cln_resize,2),size(AmxC_cln_resize,2),3,'uint8');
u(1:size(AmxC_cln_resize,1),1:size(AmxC_cln_resize,2),:)=AmxC_cln_resize;
if size(AmxC_cln_resize,2) < size(AmxS_cln_resize,2)
    u(size(AmxC_cln_resize,1)+[1:size(AmxC_cln_resize,1)],1:size(AmxC_cln_resize,2),:)=AmxS_cln_resize(:,1:size(AmxC_cln_resize,2),:);
else
    u(size(AmxC_cln_resize,1)+[1:size(AmxC_cln_resize,1)],1:size(AmxS_cln_resize,2),:)=AmxS_cln_resize(:,1:size(AmxS_cln_resize,2),:);
end

if size(AmxC_cln_resize,2) < size(AmxT_cln_resize,2)
    u(2*size(AmxC_cln_resize,1)+[1:size(AmxT_cln_resize,1)],1:size(AmxC_cln_resize,2),:)=AmxT_cln_resize(:,1:size(AmxC_cln_resize,2),:);
else
    u(2*size(AmxC_cln_resize,1)+[1:size(AmxT_cln_resize,1)],1:size(AmxT_cln_resize,2),:)=AmxT_cln_resize(:,1:size(AmxT_cln_resize,2),:);
end

% add thin white margin
white_margin = round(0.01*size(AmxC_cln_resize,2));
u1=255*ones(size(u,1)+2*white_margin,size(u,2)+2*white_margin,3,'uint8');
u1(white_margin+[1:size(u,1)],white_margin+[1:size(u,2)],:)=u;

%% write Coronal/Sagittal/Transverse MIP image files (PNG) with correct aspect ratio
tic;
fprintf(1,'Writing MIPs for brain %s-%s...',brainID,seriesID);
if 1 % MITRAGPU2 32x reduced PNGs
    C_outflnm=[brainID '-' seriesID '-x32rTIF-Cmip.png'];
    S_outflnm=[brainID '-' seriesID '-x32rTIF-Smip.png'];
    T_outflnm=[brainID '-' seriesID '-x32rTIF-Tmip.png'];
end;
if 0 % MITRADEVEL 8x reduced PNGs
    C_outflnm=[brainID '-' seriesID '-x8rTIF-Cmip.png'];
    S_outflnm=[brainID '-' seriesID '-x8rTIF-Smip.png'];
    T_outflnm=[brainID '-' seriesID '-x8rTIF-Tmip.png'];
end;

imwrite(uint8(AmxC_cln_resize), C_outflnm,'png');
imwrite(uint8(AmxS_cln_resize), S_outflnm,'png');
imwrite(uint8(AmxT_cln_resize), T_outflnm,'png');
%% write single file with combined Coronal/Sagittal/Transverse MIP images (PNG)
CST_outflnm=[brainID '-' seriesID '-x8rTIF-CSTmip.png'];
imwrite(u1, CST_outflnm,'png');
fprintf(1,'...finished successfully\n\n');
toc;

if 0
    
    %***************************************************************************************
    % Read from portal DB ('mbaDB') the relevant meta data (mode index, isVisible flag) for each section in the stack
    % The meta data is to be used to construct correct section order from the isVisiblle subset
    %***************************************************************************************
    
    %***************************************************************************************
    % construct from brainID the corresponding portal brain name
    % brainID='PMD2233'; seriesID='F';
    %***************************************************************************************
    projName=brainID(regexp(brainID,'\D'));
    brainIDno = str2num(brainID(regexp(brainID,'\d')));
    if strcmp(projName,'PMD')
        portalBrainName=['MouseBrain_' sprintf('%04d',brainIDno)];
    else
        portalBrainName=['MouseBrain_' brainID];
    end;
    [brainID '    ' portalBrainName]
    
    % connect to portal DB ("mbaDB")
    javaaddpath('mysql-connector-java-5.1.20-bin.jar');
    connPortal = database('mbaDB','mitralab','bungt0wn','com.mysql.jdbc.Driver','jdbc:mysql://143.48.220.13:3306/mbaDB');
    if ~isconnection(connPortal)
        fprintf('Cannot connect to the portal database\n');
        return;
    end
    fprintf('Connection successful\n');
    
    %get brain_id
    qBrain = fetch(connPortal,['SELECT id FROM seriesbrowser_brain WHERE name="',portalBrainName,'"']);
    if isempty(qBrain)
        fprintf('Cannot find brain %s in the portal database\n',portalBrainName);
        return;
    end;
    brain_id = qBrain{1};
    
    %get meta data from portal DB for every section
    for i=1:numel(SectionOnDisk)
        if strcmp(SectionOnDisk{i}.label,'F') == 0
            continue;
        end
        sectionName = SectionOnDisk{i}.name
        sectionModeIndex_fromname = SectionOnDisk{i}.modeIndex;
        q = fetch(connPortal, ['SELECT id FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
        if isempty(q)
            fprintf('Section is NOT posted on the portal : %s\n',sectionName);
            continue;
        end;
        fastinsert(connPortal,'seriesbrowser_section',{'seriesbrowser_section.isVisible', 'seriesbrowser_section.series_id', 'seriesbrowser_section.name', 'seriesbrowser_section.sectionOrder', 'seriesbrowser_section.pngPathLow', 'seriesbrowser_section.jp2Path', 'seriesbrowser_section.jp2FileSize', 'seriesbrowser_section.jp2BitDepth', 'seriesbrowser_section.y_coord'}, {1, series_id, sectionName, int32(SectionOnDisk{i}.modeIndex),SectionOnDisk{i}.pngPathlow, SectionOnDisk{i}.jp2Path, SectionOnDisk{i}.jp2FileSize,jp2BitDepth ,sectionYCoordinate});
        q = fetch(connPortal, ['SELECT id isVisible FROM seriesbrowser_section WHERE name = "', sectionName,'"'] );
        
        fprintf('pulled Mode Index for section %s\n',sectionName);
    end;
    
end; % if 0

