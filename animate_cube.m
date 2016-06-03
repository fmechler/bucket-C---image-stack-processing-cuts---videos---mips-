function [ null ] = animate_cube(A)
% animate_cube.m:  animates a 4D array treating the 3rd index as color and the 4th index as time

sz=size(A); 
nt=sz(4); 
for i=1:nt, image(squeeze(A(:,:,:,i))); pause(0.1); end


end

