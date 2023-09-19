clear 
clc
close all
%% User input
file.path = 'D:\Documents\Unif\PostDoc\2023 - data\09 - September\Jagannath\21062003 Polystyrene 1um 1w_Series028_z42';
file.ext  = '.tif';

pxSize.xy = 0.052;
pxSize.z  = 0.1;%in nm
minDist = 5; %in pixels (min distant expected between particles)
ROI = [8 8];
sizeParticles = 1;
%parameter
info.type = 'normal';%Transmission or normal 
info.checkSync = false; %true if want to check for camera synchronization
info.useSameROI = true;
info.runMethod = 'load';% 'run'
toAnalyze = 'file';%accepted: .mp4, .ome.tif, folder. (folder that contain folders of .ome.tif.
outputFolder = 'Results'; %name of the folder to output the results

%% Loading
myMovie = Core.LocMovie3D(file,info);  
data = myMovie.getFrame;

%% Step 1 detection object detection
detectParam = 5;
[detectedObj] = myMovie.detectObjects(data, detectParam);


%% Step 2 Fitting
[locPos] = myMovie.fit3D(data,ROI);


%% Step 3 representation

myMovie.render3D(pxSize,sizeParticles)


%% Step 4 analyzing crystal structure










