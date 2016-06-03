
function A = make_imcube(dirname, dir_out, animate_flag, save_flag) 

%function make_imcube(dirname)
%
%%
% Reads the *png images from the directory specified in the input var.
% Orders the images in ascending sequence
% Assembles them in an 4-d [nx ny nchan nimage] Matlab array == "image cube"
% Animates the image cube
% Saves the 4d array in a *.mat file in the input directory
%
% Ferenc Mechler Sep-2013

if nargin < 2
    out_dirname = pwd;
else
    out_dirname = dir_out;
end;

if nargin < 3
    animate_flag = false;
end;

if nargin < 4
    save_flag = false;
end;


[pathstr,name,ext] = fileparts(dirname);
datacube_flnm = [name 'CUBE.mat'];

d = dir([dirname filesep '*.png']);
nd = length(d);
fprintf(1,'Found %6d *.png image files to process\n',nd);
% get the image ordinal numbers in ascending order
for i=1:nd
    flnm=d(i).name;
    j=findstr(flnm,'.png');
    % DEFAULT: Read image serial # from the end of file name
    % i_fl(i) = sscanf(flnm(j+[-4:-1]),'%d');
    % ALTERNATIVE: Use this variant code line below when MaskImagesBartch is called for a 2nd pass (reads image serial # from the beginning of file name)
    ubu = sscanf(flnm([1:4]),'%d');
    if isempty(ubu)
        ubu = sscanf(flnm(j+[-4:-1]),'%d');
    end;
    i_fl(i) = ubu;
    d(i).i_fl = i_fl(i);
end;
[i_fl, ii] = sort(i_fl);
d=d(ii);
% all(diff([i_fl])>0)

A0=imread([dirname filesep d(1).name]);
[nx,ny,nch]=size(A0);

fprintf(1,'\n    reading in *.png images & building image cube...\n');
A=zeros(nx,ny,nch,nd);
for id=1:nd
    imflnm = [dirname filesep d(id).name];
    A(:,:,:,id) = imread(imflnm);
end;

if animate_flag
    fprintf(1,'\n    animating image cube...\n');
    figure(1); clf;
    for i=1:nd image(A(:,:,:,i)/255);
        set(gca,'ylim',[1 nx],'xlim',[1 ny]);
        title([name '    ' int2str(d(i).i_fl)]);
        pause(.01);
    end;
end;

if save_flag
    fprintf(1,'\n    saving image cube in dir %s...\n', out_dirname);
    save([out_dirname filesep datacube_flnm], 'A', 'd', '-v7.3');
    fprintf(1,'\n    ...done.\n');
end;

