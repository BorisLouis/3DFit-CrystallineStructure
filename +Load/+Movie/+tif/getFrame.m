function [ mov ] = getFrame( path2File, frames )
%GETFRAMES Summary of this function goes here
%   Detailed explanation goes here

assert(min(size(frames))==1,'frames must be a vector of positive integers')

%2 cases, either all frames are in one file OR each frame is separated into
%its own file.

%case1
if length(path2File) == 1
    
    currentFile = [path2File(1).folder filesep path2File(1).File];
    f_n = length(frames);

    tObj = Tiff(currentFile,'r');
    l    = tObj.getTag(256);
    w    = tObj.getTag(257);
    tObj.setDirectory(frames(1));

    im1  = tObj.read;
    nClass = class(im1);
    mov = zeros(w,l,f_n,nClass);
    convert = false;

    if length(size(im1))~=2
        warning('Colored images received, conversion to grayscale is performed')
        convert = true;
    end

    for i = 1:f_n
        f_i = frames(i);
        tObj.setDirectory(f_i)
        movTmp = tObj.read;  
        if convert
            movTmp = rgb2gray(movTmp);
        end
        mov(:,:,i) = movTmp;    
    end
    tObj.close
else
    for i = frames
        currentFile = [path2File(i).folder filesep path2File(i).File];
        tObj = Tiff(currentFile,'r');
        if i == 1
            l    = tObj.getTag(256);
            w    = tObj.getTag(257);
            tObj.setDirectory(frames(i));

            im1  = tObj.read;
            nClass = class(im1);
            mov = zeros(w,l,length(frames),nClass);
            convert = false;
            if length(size(im1))~=2
                warning('Colored images received, conversion to grayscale is performed')
                convert = true;
            end
        else
        end
               
        movTmp = tObj.read;  
        if convert
            movTmp = rgb2gray(movTmp);
        end
        mov(:,:,i) = movTmp;    
        
        tObj.close
       
        
        
        
    end
    
    
end

end
