function [ frameInfo, movInfo ] = getInfo( path2File )
%GETINFO Summary of this function goes here
%   Detailed explanation goes here

[path,file,ext] = fileparts(path2File);

folder2Mov = dir(path);
folder2Mov = folder2Mov(~[folder2Mov.isdir]);
folder2Mov = folder2Mov(contains({folder2Mov.name},'.tif'));

currentFile = [folder2Mov(1).folder filesep folder2Mov(1).name];
 tObj = Tiff(currentFile,'r');

movInfo.Width  = tObj.getTag(256);
movInfo.Length = tObj.getTag(257);
tObj.setDirectory(1)
tObj.close

%store a few thing for the rest of the code
isMultiImage = false;

isZStack = false;
Cam  = 0;
%get the number of frame
maxFrame = size(folder2Mov,1);
%get the exposure time
expT     = NaN; %in ms

movInfo.isMultiImage = isMultiImage;
movInfo.isZStack = isZStack;
movInfo.Cam = Cam;
movInfo.expT = expT;
movInfo.maxFrame = maxFrame;
movInfo.Path   = fileparts(currentFile);

%Store info for output
for i = 1:size(folder2Mov,1)
    currentFile = folder2Mov(i).name;
    frameInfo(i).File = currentFile;
    frameInfo(i).folder = movInfo.Path;
end

end