clear 
clc
close all
%% User input
file.path = 'D:\Documents\Unif\PostDoc\2023 - data\09 - September\Jagannath\21062003 Polystyrene 1um 1w_Series028_z42';
file.ext  = '.tif';

pxSize.xy = 0.052;
pxSize.z  = 0.1;%in nm
ROI = [8 8]; % radius around the particle for fitting [xy z];
sizeParticles = 1;% in um
%parameter
info.type = 'normal';%Transmission or normal 
%% Loading
myMovie = Core.LocMovie3D(file,info);  
data = myMovie.getFrame;

%% Step 1 detection object detection
detectParam = 5;%not needed just a placeholder parameter
[detectedObj] = myMovie.detectObjects(data, detectParam);


%% Step 2 Fitting
[locPos] = myMovie.fit3D(data,ROI);


%% Step 3 representation

myMovie.render3D(pxSize,sizeParticles)


%% Step 4 analyzing crystal structure

%select a section of the data
idx = 65;

h = figure(5);
imagesc(data(:,:,idx));

roi = drawrectangle(gca);

myMovie.analyzeCrystalStruct(roi.Position)








