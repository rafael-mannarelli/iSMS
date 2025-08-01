function mainhandles = alignROIs(mainhandles,file,showpeakschoice)
% Aligorithm for aligning donor and acceptor ROI based on their most
% intense peak's coordinates
%
%     Input:
%      mainhandles      - handles.structure of the main figure window
%      file             - movie file
%      showpeakschoice  - 0/1 whether to show peaks used for alignment
%
%     Output:
%      mainhandles      - ..
%

% --- Copyrights (C) ---
%
% This file is part of:
% iSMS - Single-molecule FRET microscopy software
% Copyright (C) Aarhus University, @ V. Birkedal Lab
% <http://isms.au.dk>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

%% Initialize

if nargin<2 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end
if nargin<3 || isempty(showpeakschoice)
    showpeakschoice = mainhandles.settings.autoROI.showpeaks;
end

% Raw dimensions
W = size(mainhandles.data(file).avgimage,1);
H = size(mainhandles.data(file).avgimage,2);

% ROIs
[mainhandles, Droi, Aroi] = getROI(mainhandles,file,0,0);

% Prepare ROI images
[redImage greenImage] = getROIimages(mainhandles,file);

%% Make "clean" images

% Find donor peaks
npeaks = mainhandles.settings.autoROI.npeaks; % Number of peaks used from D and A ROIs

Dxy = myFastPeakFind(mainhandles,...
    greenImage,...
    'Dthreshold',...
    1,...
    mainhandles.settings.autoROI.npeaks,...
    0);

Axy = myFastPeakFind(mainhandles,...
    redImage,...
    'Athreshold',...
    1,...
    mainhandles.settings.autoROI.npeaks,...
    0);

if isempty(Dxy) || isempty(Axy)
    mymsgbox('Unable to find any reference peaks for the ROI alignment.')
    return
end

% Old, slower method
% DpeakImage = makePeakImageOld(greenImage,Dxy);
% ApeakImage = makePeakImageOld(redImage,Axy);

% New, faster method
f = fspecial('gaussian',15,1.5); % Filter
DpeakImage = makePeakImage(greenImage,Dxy);
ApeakImage = makePeakImage(redImage,Axy);

%% Show an image of the peaks used for the alignment

if mainhandles.settings.autoROI.showpeaks
    
    % Make figure
    if (isempty(mainhandles.autoROIimageHandle)) || (~ishandle(mainhandles.autoROIimageHandle))
        fh = figure;
        set(fh,'name','Peaks used for auto-alignment','numbertitle','off')
        updatelogo(fh)
        
        mainhandles.autoROIimageHandle = fh;
        updatemainhandles(mainhandles)
    end
    
    % Current figure
    figure(mainhandles.autoROIimageHandle)
    
    % D image
    subplot(1,2,1)
    imagesc(DpeakImage')
    axis(gca,'image')
    set(gca,'YDir','normal')
    title('Donor peaks')
    
    % A image
    subplot(1,2,2)
    imagesc(ApeakImage')
    axis(gca,'image')
    set(gca,'YDir','normal')
    title('Acceptor peaks')
    colormap(hot)

else
    try delete(mainhandles.autoROIimageHandle), end
end

%% Registration and alignment

if mainhandles.settings.autoROI.refframe == 1 % If donor ROI is used as fixed frame
    mainhandles = runalign(mainhandles, DpeakImage,ApeakImage, Droi,Aroi, 'DROIhandle','AROIhandle');
else
    mainhandles = runalign(mainhandles, ApeakImage,DpeakImage, Aroi,Droi, 'AROIhandle','DROIhandle');
end

%% Move peaks plot to the front

if mainhandles.settings.autoROI.showpeaks
    if (~isempty(mainhandles.autoROIimageHandle)) || (ishandle(mainhandles.autoROIimageHandle))
        try figure(mainhandles.autoROIimageHandle), end
    end
end

%% Nested

    function peakImage = makePeakImage(img,xy)
        % Creates "clean" images for image registration
        xyInd = sub2ind(size(img),xy(:,2),xy(:,3));
        peakImage = zeros(size(img));
        peakImage(xyInd) = 1;
        peakImage = imfilter(peakImage,f);
    end

    function mainhandles = runalign(mainhandles, img1,img2, r1,r2, roi1field,roi2field)
        % Run registration and aligns ROIs accordingly
        %
        %    Input:
        %     img1      - fixed reference image
        %     img2      - image to align
        %     r1        - ROI of img1
        %     r2        - ROI of img2
        %     roi1field - fieldname of ROI 1
        %     roi2field - fieldname of ROI 2
        
        % Image registration
        output = dftregistration(fft2(img2), fft2(img1),10); % Register image shift
        r2(1:2) = r2(1:2)+output(3:4); % New ROI 2
        
        % Control that new ROI does not exceed image limits
        if r2(1)>=0.5 && r2(2)>=0.5 ...
                && sum(r2([1 3]))<W+.5 && sum(r2([2 4]))<H+.5
            
            % Set new ROI2 position
            if file==get(mainhandles.FilesListbox,'Value')
                setPosition(mainhandles.(roi2field),r2) % [x y width height]
            else
                ROIcallback(r2,roi1field(1),r1,file)
            end
            
        else
            
            % New roi size makes Aroi exceed image limits, try resizing
            
            if mainhandles.settings.autoROI.autoResize
                % Use auto-resizing
                update1 = 0; % Update donor ROI size before acceptor ROI
                update2 = 0; % Update donor ROI position after acceptor ROI
                ROI1n = r1; % Donor position after A ROI update
                
                if r2(1) < 0.5
                    % New acceptor ROI exceeds negative x-limit
                    ROI1n(1) = r1(1)+abs(r2(1)); % New D-ROI position
                    update2 = 1; % Register that D ROI position must be updated after A ROI in order to set its position correctly
                    
                    r2(3) = r2(3)-abs(r2(1));
                    r2(1) = 1;
                    
                elseif sum(r2([1 3])) >= W+0.5
                    % New acceptor ROI exceeds positive x-limit
                    diff = sum(r2([1 3])) - W - 0.4; % Exceeded amount
                    r2(3) = r2(3)-diff; % Change A ROI size
                    update1 = 1; % Register that the D ROI size must be updated before A ROI
                end
                
                if r2(2) < 0.5
                    
                    % New acceptor ROI exceeds negative y-limit
                    ROI1n(2) = r1(2)+abs(r2(2)); % New D-ROI position
                    update2 = 1; % Register that D ROI position must be updated after A ROI in order to set its position correctly
                    
                    r2(4) = r2(4)-abs(r2(2)); % New A ROI size
                    r2(2) = 1; % New A ROI position
                    
                elseif sum(r2([2 4])) >= H+.5
                    % New acceptor ROI exceeds positive y-limit
                    diff = sum(r2([2 4])) - H-0.4; % Exceeded amount
                    r2(4) = r2(4)-diff; % Change A ROI size
                    update1 = 1; % Register that the size of the D ROI must be updated before A ROI
                end
                
                % Control that resized ROI is larger than threshold
                if (r2(3)>=mainhandles.settings.autoROI.lowerSize) && (r2(4)>=mainhandles.settings.autoROI.lowerSize)
                    % Update the size of the donor ROI so its position does not
                    % change when changing the A ROI
                    if update1
                        r1(3:4) = r2(3:4);
                        
                        if file==get(mainhandles.FilesListbox,'Value')
                            setPosition(mainhandles.(roi1field),r1) % [x y width height]
                        else
                            ROIcallback(r1,roi1field(1),r2,file)
                        end
                    end
                    
                    % Then set new ROI2 position
                    if file==get(mainhandles.FilesListbox,'Value')
                        setPosition(mainhandles.(roi2field),r2) % [x y width height]
                    else
                        ROIcallback(r2,roi1field(1),r1,file)
                    end
                    
                    % Update donor position if left side of A ROI was is smaller, so overlap is kept
                    if update2
                        ROI1n(3:4) = r2(3:4);
                        % Set new ROI2 position
                        if file==get(mainhandles.FilesListbox,'Value')
                            setPosition(mainhandles.(roi1field),ROI1n) % [x y width height]
                        else
                            ROIcallback(ROI1n,roi1field(1),r2,file)
                        end
                    end
                    
                else % If the new size is smaller than threshold
                    mymsgbox(sprintf('%s%s',...
                        'I was not able to position the ROIs automatically. ',...
                        'Try increasing the number of peaks used for the alignment in Settings -> Align ROIs settings.'),...
                        'Or, do manual alignment.')
                end
                
                
            else % If auto-resizing is not activated
                mymsgbox(sprintf('%s%s%s',...
                    'I was not able to position the ROIs automatically without exceeding movie limits. ',...
                    'You should consider making the ROIs smaller. ',...
                    'Or, try increasing the number of peaks used for the alignment in Settings -> Align ROIs settings.'),...
                    'Or, do manual alignment.')
            end
        end
        
        mainhandles = guidata(mainhandles.figure1);
    end


    function peakImage = makePeakImageOld(img,xy)
        % Make donor Gaussians image from peaks
        mu = xy(:,2:3); % Donor Gaussian means
        sigma = zeros(2,2,size(xy,1)); % Gaussian widths
        for i = 1:size(xy,1)
            sigma(:,:,i) = 3*eye(2);
        end
        x = 1:size(img,1);
        y = 1:size(img,2);
        [X,Y] = meshgrid(x,y); % Make x,y grid for clean images
        
        obj = gmdistribution(mu,sigma); % Make bivariate distribution object
        peakImage = pdf(obj,[X(:) Y(:)]); % Make gaussians on X-Y grid
        peakImage = reshape(peakImage,length(y),length(x))'; % Resize to image size
        %
        % % Make acceptor Gaussians image from peaks
        % mu = Axy(:,2:3); % Acceptor Gaussian means
        % sigma = zeros(2,2,size(Axy,1)); % Gaussian widths
        % for i = 1:size(Axy,1)
        %     sigma(:,:,i) = 3*eye(2);
        % end
        % obj = gmdistribution(mu,sigma); % Make bivariate distribution object
        % ApeakImage = pdf(obj,[X(:) Y(:)]); % Make gaussians on X-Y grid
        % ApeakImage = reshape(ApeakImage,length(y),length(x))'; % Resize to image size
    end

    function mainhandles = runAlignOld()
        if mainhandles.settings.autoROI.refframe == 1 % If donor ROI is used as fixed frame
            output = dftregistration(fft2(ApeakImage), fft2(DpeakImage),10); % Register image shift
            Aroi(1:2) = mainhandles.data(file).Aroi(1:2)+output(3:4); % New acceptor ROI
            
            % Control that new ROI does not exceed image limits
            if Aroi(1)>=0.5 && Aroi(2)>=0.5 && sum(Aroi([1 3]))<W+.5 && sum(Aroi([2 4]))<H+.5
                % Set new A ROI position
                setPosition(mainhandles.AROIhandle,Aroi) % [x y width height]
                
            else % If new roi size makes Aroi exceed image limits, try resizing
                if mainhandles.settings.autoROI.autoResize % If using auto-resizing
                    updateD1 = 0; % Update donor ROI size before acceptor ROI
                    updateD2 = 0; % Update donor ROI position after acceptor ROI
                    Droi2 = Droi; % Donor position after A ROI update
                    if Aroi(1) < 0.5 % If new acceptor ROI exceeds negative x-limit
                        Droi2(1) = Droi(1)+abs(Aroi(1)); % New D-ROI position
                        updateD2 = 1; % Register that D ROI position must be updated after A ROI in order to set its position correctly
                        
                        Aroi(3) = Aroi(3)-abs(Aroi(1));
                        Aroi(1) = 1;
                    elseif sum(Aroi([1 3])) >= W+0.5 % If new acceptor ROI exceeds positive x-limit
                        diff = sum(Aroi([1 3])) - W - 0.4; % Exceeded amount
                        Aroi(3) = Aroi(3)-diff; % Change A ROI size
                        updateD1 = 1; % Register that the D ROI size must be updated before A ROI
                    end
                    if Aroi(2) < 0.5 % If new acceptor ROI exceeds negative y-limit
                        Droi2(2) = Droi(2)+abs(Aroi(2)); % New D-ROI position
                        updateD2 = 1; % Register that D ROI position must be updated after A ROI in order to set its position correctly
                        
                        Aroi(4) = Aroi(4)-abs(Aroi(2)); % New A ROI size
                        Aroi(2) = 1; % New A ROI position
                    elseif sum(Aroi([2 4])) >= H+.5 % If new acceptor ROI exceeds positive y-limit
                        diff = sum(Aroi([2 4])) - H-0.4; % Exceeded amount
                        Aroi(4) = Aroi(4)-diff; % Change A ROI size
                        updateD1 = 1; % Register that the size of the D ROI must be updated before A ROI
                    end
                    
                    % Control that resized ROI is larger than threshold
                    if (Aroi(3)>=mainhandles.settings.autoROI.lowerSize) && (Aroi(4)>=mainhandles.settings.autoROI.lowerSize)
                        % Update the size of the donor ROI so its position does not
                        % change when changing the A ROI
                        if updateD1
                            Droi(3:4) = Aroi(3:4);
                            setPosition(mainhandles.DROIhandle,Droi) % [x y width height]
                        end
                        
                        % Then set new A ROI position
                        setPosition(mainhandles.AROIhandle,Aroi) % [x y width height]
                        
                        % Update donor position if left side of A ROI was is smaller, so overlap is kept
                        if updateD2
                            Droi2(3:4) = Aroi(3:4);
                            setPosition(mainhandles.DROIhandle,Droi2) % [x y width height]
                        end
                        
                    else % If the new size is smaller than threshold
                        mymsgbox(sprintf('%s%s',...
                            '�v, I was no able to position the ROIs automatically. ',...
                            'Try increasing the number of peaks used for the alignment in Settings -> Align ROIs settings.'),...
                            'Do manual alignment.')
                    end
                    
                    
                else % If auto-resizing is not activated
                    mymsgbox(sprintf('%s%s%s',...
                        '�v, I was no able to position the ROIs automatically without exceeding movie limits. ',...
                        'You should consider making the ROIs smaller. ',...
                        'Or, try increasing the number of peaks used for the alignment in Settings -> Align ROIs settings.'),...
                        'Do manual alignment.')
                end
            end
        end
        
        if mainhandles.settings.autoROI.refframe == 2 % If acceptor ROI is used as fixed frame
            output = dftregistration(fft2(DpeakImage), fft2(ApeakImage),10); % Register image shift
            Droi(1:2) = mainhandles.data(file).Droi(1:2)+output(3:4); % New donor ROI
            
            % Control that new ROI does not exceed image limits
            if (Droi(1)>=0.5) && (Droi(2)>=0.5) && (Droi(1)+Droi(3)<W+.5) && (Droi(2)+Droi(4)<H+0.5)
                % Set new D ROI position
                setPosition(mainhandles.DROIhandle,Droi) % [x y width height]
                
                
            else % If new roi position makes D ROI exceed image limits, try resizing
                if mainhandles.settings.autoROI.autoResize % If using auto-resizing
                    updateA1 = 0; % Update A ROI size before D ROI
                    updateA2 = 0; % Update A ROI position after D ROI
                    Aroi2 = Aroi; % A position after D ROI update
                    if Droi(1) < 0.5 % If new D ROI exceeds negative x-limit
                        Aroi2(1) = Aroi(1)+abs(Droi(1)); % New A-ROI position
                        updateA2 = 1; % Register that A ROI position must be updated after D ROI in order to set its position correctly
                        
                        Droi(3) = Droi(3)-abs(Droi(1));
                        Droi(1) = 1;
                    elseif Droi(1)+Droi(3) >= W+.5 % If new D ROI exceeds positive x-limit
                        diff = (Droi(1)+Droi(3)-1) - W; % Exceeded amount
                        Droi(3) = Droi(3)-diff; % Change D ROI size
                        updateA1 = 1; % Register that the A ROI size must be updated before D ROI
                    end
                    if Droi(2) < 0.5 % If new D ROI exceeds negative y-limit
                        Aroi2(2) = Aroi(2)+abs(Droi(2)); % New A-ROI position
                        updateA2 = 1; % Register that A ROI position must be updated after D ROI in order to set its position correctly
                        
                        Droi(4) = Droi(4)-abs(Droi(2)); % New D ROI size
                        Droi(2) = 1; % New D ROI position
                    elseif Droi(2)+Droi(4) > H+.5 % If new D ROI exceeds positive y-limit
                        diff = sum(Droi([2 4])) - H-.4; % Exceeded amount
                        Droi(4) = Droi(4)-diff; % Change D ROI size
                        updateA1 = 1; % Register that the size of the A ROI must be updated before D ROI
                    end
                    
                    % Control that resized ROI is larger than threshold
                    if (Droi(3)>=mainhandles.settings.autoROI.lowerSize) && (Droi(4)>=mainhandles.settings.autoROI.lowerSize)
                        % Update the size of the A ROI so its position does not
                        % change when changing the D ROI
                        if updateA1
                            Aroi(3:4) = Droi(3:4);
                            setPosition(mainhandles.AROIhandle,Aroi) % [x y width height]
                        end
                        
                        % Then set new D ROI position
                        setPosition(mainhandles.DROIhandle,Droi) % [x y width height]
                        
                        % Update A position so overlap is kept
                        if updateA2
                            Aroi2(3:4) = Droi(3:4);
                            setPosition(mainhandles.AROIhandle,Aroi2) % [x y width height]
                        end
                        
                    else % If the new size is smaller than threshold
                        mymsgbox(sprintf('%s%s',...
                            '�v, I was no able to position the ROIs automatically. ',...
                            'Try increasing the number of peaks used for the alignment in Settings -> Align ROIs settings.'),...
                            'Do manual alignment.')
                    end
                    
                    
                else % If auto-resizing is not activated
                    mymsgbox(sprintf('%s%s%s',...
                        '�v, I was no able to position the ROIs automatically without exceeding movie limits. ',...
                        'Try increasing the number of peaks used for the alignment in Settings -> Align ROIs settings.'),...
                        'Do manual alignment.')
                end
            end
        end
    end

end