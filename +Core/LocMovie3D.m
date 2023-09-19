classdef LocMovie3D < Core.Movie 
    %Class to process 3D localization data
    
    properties (SetAccess = 'protected')
        detectParam
        detectedObj
        locPos
    end
    
    methods
        function obj = LocMovie3D(raw,info)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@Core.Movie(raw,info);
        end
        
        function detObj = detectObjects(obj,data, detectParam)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            gData = imgaussfilt(data,[5 5]);
            
            bwData = imbinarize(gData,0.2);
            
            gData = gData.*uint8(bwData);
            
            regMax = imregionalmax(gData);
            
            
            
            
            %make movie for checking the quality of the detection
            filename = [obj.raw.movInfo.Path filesep 'localizationMovie.gif'];
            frameRate = 5;
            h = figure(1);
            for i = 1:size(regMax,3)
               
                imagesc(gData(:,:,i))
                
                cent = regionprops(regMax(:,:,i));
                if ~isempty(cent)
                    coord = [cent.Centroid];
                    coord = reshape(coord,[2,length(coord)/2])';
                    hold on
                    scatter(coord(:,1),coord(:,2),5,'r','filled')
                end
                axis image
                set(gca,'visible','off');
                set(gcf,'color','w');
                caxis([0 double(max(gData(:)))])
                drawnow;
                
                frame = getframe(h);
                im = frame2im(frame);
                
                [imind,cm] = rgb2ind(im,256);

                if i == 1

                    imwrite(imind,cm,filename,'gif','DelayTime',1/frameRate, 'loopcount',inf);

                else

                    imwrite(imind,cm,filename,'gif','DelayTime',1/frameRate, 'writemode','append');

                end
                 clf;
            end
            
            % get the coordinate of all:
            coord = regionprops3(regMax,'Centroid');
          
            detObj = coord;
            obj.detectedObj = coord;
            obj.detectParam = detectParam;
        end
        
        function locPos = fit3D(obj,data,ROI)
            assert(~isempty(obj.detectedObj),'No detected object found, please run detectObjects first');
            
            coord = obj.detectedObj;
            locPos = table(zeros(height(coord),1),zeros(height(coord),1),...
                zeros(height(coord),1),'Variablenames',{'row','col','z'});
            for i = 1 : size(coord,1)
                currentCoord = coord(i,:).Centroid;
                %use ROI to crop the data range to be fitted
                x = currentCoord(1)-ROI(1):currentCoord(1)+ROI(1);
                y = currentCoord(2)-ROI(1):currentCoord(2)+ROI(1);
                z = currentCoord(3)-ROI(2):currentCoord(3)+ROI(2);
                [x,y,z] = Core.LocMovie3D.fixCoord(x,y,z,size(data));
                
                %extract the data within the ROI to be fitted and convert
                %to double for fitting function
                data2Fit = double(data(y,x,z));
                
                %create a meshgrid to be used as domain for fitting
                [X,Y,Z] = meshgrid(x,y,z);
                
                domain(:,:,:,1) = X;
                domain(:,:,:,2) = Y;
                domain(:,:,:,3) = Z;
                
                width.xy = 0;
                width.z  = 0;
                
                [gpar,resnorm,res,fit] = Localization.Gauss.MultipleGFit3D(data2Fit,currentCoord(1),...
                    currentCoord(2),currentCoord(3),domain,1,width);
                
                locPos(i,:).col = gpar(5);
                locPos(i,:).row = gpar(6);
                locPos(i,:).z = gpar(7);
                clear domain;
 
            end
            obj.locPos = locPos;
            
            figure
            subplot(1,2,1)
            scatter3(locPos.col,locPos.row,locPos.z,100,locPos.z,'filled');
            axis image
            subplot(1,2,2)
            scatter3(locPos.col,locPos.row,locPos.z,10,locPos.z,'filled');
            axis image
            
        end
        
        function render3D(obj,pxSize,sizeParticles)
            locP = obj.locPos;
            %1) convert localization position to real scale and center
            %around 0
            locP.row = locP.row*pxSize.xy;
            locP.col = locP.col*pxSize.xy;
            locP.z   = locP.z*pxSize.z;
            
            locP.row = locP.row - mean(locP.row);
            locP.col = locP.col - mean(locP.col);
            locP.z = locP.z - mean(locP.z);
            
            %2) create a sphere
            [x,y,z] = sphere(32);
            x = x*sizeParticles/2;
            y = y*sizeParticles/2;
            z = z*sizeParticles/2;
            figure(2)
            hold on
            %3) plot the sphere at the desired position
            for i = 1:height(locP)
                
                X = x+locP.col(i);
                Y = y+locP.row(i);
                Z = z+locP.z(i);

                surf(X,Y,Z,'LineStyle','none','Facecolor',[0.4,0.4,0.4],'FaceAlpha',0.5)
                
            end
            axis image
            camlight
            lighting('gouraud');

        end
        
        
    end
    
    methods (Static, Access = private)
        function [x,y,z] = fixCoord(x,y,z,dim)
           x = floor(x);
           x(x<1) = [];
           x(x>dim(1)) = [];
           
           y = floor(y);
           y(y<1) = [];
           y(y>dim(2)) = [];
           
           z = floor(z);
           z(z<1) = [];
           z(z>dim(3)) = [];
            
        end
    end
end

