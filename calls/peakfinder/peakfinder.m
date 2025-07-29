function mainhandles = peakfinder(mainhandles,channel,autodetectD,autodetectA,files)
% Finds donor and acceptor peaks
%
%    Input:
%     mainhandles    - handles structure of the main window
%     channel        - 'donor' 'acceptor' 'both'
%     autodetectD    - automatically sets peak threshold
%     autodetectA    - automatically sets peak threshold
%     files          - files to analyse
%
%    Output:
%     mainhandles    - handles structure of the mainw window
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

% Defaults
if nargin<3 || isempty(autodetectD)
    autodetectD = 0;
end
if nargin<4 || isempty(autodetectA)
    autodetectA = 0;
end
if nargin<5 || isempty(files)
    files = get(mainhandles.FilesListbox,'Value');
end

%% Run peakfinder

for i = 1:length(files)
    file = files(i);
    
    % Don't do anything if its an intensity profile
    if mainhandles.data(file).spot
        continue
    end
    
    if mainhandles.settings.peakfinder.choice==1
        
        % Find peaks in selected image/frame
        mainhandles = peakfinder1(mainhandles,channel,autodetectD,autodetectA,file);
        
    else % If scanning movie, run peakfinder2
        
        % Check if raw movie has been deleted
        if isempty(mainhandles.data(file).imageData)
            choice = myquestdlg(sprintf('The raw movie has been deleted for this file (%s). Do you want to reload the movie from file?',mainhandles.data(file).name),...
                'Movie deleted',...
                'Yes','No','No');
            if strcmp(choice,'Yes')
                mainhandles = reloadMovieCallback(mainhandles);
            else
                continue
            end
        end
        
        mainhandles = peakfinder2(mainhandles,channel,autodetectD,autodetectA,file);
    end
    
    % Update coordinates within the global coordinate system
    mainhandles = updatepeakglobal(mainhandles,'all',file); % Also updates handles structure
    
    % Put D's at A's and vice versa
    mainhandles = updateDatA(mainhandles, file);
    
end

end

% Find peaks in one image
function mainhandles = peakfinder1(mainhandles,channel,autodetectD,autodetectA,file)
% Finds peaks in selected image/frame of sms main window
%
%    Input:
%     mainhandles  - handles structure of the main window (sms)
%     channel      - 'donor', 'acceptor', 'both'
%     autodetect   - binary parameter determining whether the peak slider
%                    values are set according to the peak intensity
%                    thresholds. This is 1 when peakfinder is called using
%                    autorun.
%
%    Output:
%     mainhandles  - handles structure of the main window
%

%% Initialize

% Defaults
if nargin<2
    channel = 'both';
end
if nargin<3
    autodetectD = 0;
end
if nargin<4
    autodetectA = 0;
end
if nargin<5 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end
if isempty(mainhandles.data)
    return
end

% Get image
imageData = getimageData(mainhandles,file,-1); % Returns average image
if isempty(imageData) %&& get(mainhandles.FramesListbox,'Value')==2
    set(mainhandles.FramesListbox,'Value',1)
    updatemainhandles(mainhandles)
    mainhandles = filesListboxCallback(mainhandles.FilesListbox); % Imitate click in files listbox
    return
end

% Get ROIs
[mainhandles, Droi, Aroi] = getROI(mainhandles,file,imageData);
if (Droi(3)==0) || (Droi(4)==0) % If ROI has been squeezed to zero
    return
end

%% Donor peaks

if (strcmp(channel,'donor')) || (strcmp(channel,'both'))
    
    % Find peaks
    mainhandles = findthempeaks(mainhandles,'D',Droi,autodetectD);
    
end

%% Acceptor peaks

if (strcmp(channel,'acceptor')) || (strcmp(channel,'both'))
    
    % Find peaks
    mainhandles = findthempeaks(mainhandles,'A',Aroi,autodetectA);
    
end

% Update handles
updatemainhandles(mainhandles)

%% Make sure average image is selected

if get(mainhandles.FramesListbox,'Value')~=1
    set(mainhandles.FramesListbox,'Value',1)
    mainhandles = filesListboxCallback(mainhandles.FilesListbox); % Imitate click in files listbox
end

%% Nested

    function mainhandles = findthempeaks(mainhandles,c,ROI,autodetect)
        
        if isempty(mainhandles.data(file).([c 'peaksRaw']))
            % Data range
            x = ROI(1):(ROI(1)+ROI(3))-1;
            y = ROI(2):(ROI(2)+ROI(4))-1;
            
            % Cut ROI from image
            if strcmpi(c,'A') && size(imageData,3)==2
                img = imageData(x , y , 2);
            else
                img = imageData(x , y , 1);
            end
            
            % Apply spot-profile correction
            if mainhandles.settings.peakfinder.useSpot
                if strcmpi(c,'D')
                    spot = mainhandles.data(file).GspotProfile;
                else
                    spot = mainhandles.data(file).RspotProfile;
                end
                if ~isempty(spot) && isequal(size(spot),size(imageData(:,:,1)))
                    img = img./(spot(x,y)/max(spot(:)));
                end
            end
            
            % Threshold
%             threshold = mainhandles.settings.peakfinder.([c 'threshold']);
%             temp = sort(img(:)); % Image pixels sorted according to brightness
%             threshold = mean(temp(1:round(end*threshold))); % Threshold for peakfinder is the mean of the 95% least-bright pixels
            
            % Find peaks sorted according to intensity
            Ixy = myFastPeakFind(mainhandles,...
                img,...
                [c 'threshold'],...
                mainhandles.settings.peakfinder.useBack,...
                mainhandles.settings.peakfinder.maxpeaks,...
                mainhandles.settings.peakfinder.subpixel);
            
            % Store all peaks in handles structure
            mainhandles.data(file).([c 'peaksRaw']) = Ixy;
            
        end
        
        % Get most intense peaks according to specified slider value
        ok = 1;
        if autodetect
            
            % Auto-set peak slider value according to default threshold
            peakIntensityThreshold = mainhandles.settings.peakfinder.([c 'peakIntensityThreshold']);
            temp = find(mainhandles.data(file).([c 'peaksRaw'])(:,1)>=peakIntensityThreshold);
            
            if ~isempty(temp)
                slider = temp(end)/size(mainhandles.data(file).([c 'peaksRaw']),1);
                if file==get(mainhandles.FilesListbox,'Value')
                    set(mainhandles.([c 'PeakSlider']),'Value',slider)
                end
                
                mainhandles.data(file).peakslider.([c 'slider']) = slider;
                ok = 0;
            end
            
        end
        
        % Use slider value manually set
        if ok
            slider = get(mainhandles.([c 'PeakSlider']),'Value'); % Chosen threshold
        end
        
        % Store peaks
        mainhandles.data(file).([c 'peaks']) = mainhandles.data(file).([c 'peaksRaw'])(1:round(end*slider),2:3);
        
    end

end

% Find peaks through movie
function mainhandles = peakfinder2(mainhandles,channel,autodetectD,autodetectA,file)
% Finds peaks in selected movie of the sms main window by scanning through
% the movie.
%
%    Input:
%     mainhandles - handles structure of the main window
%     channel     - 'donor', 'acceptor', 'both'
%     autodetectD - automatically sets peak threshold
%     autodetectA - automatically sets peak threshold
%
%    Output:
%     mainhandles - handles structure of the main window
%

%% Initialize

if nargin<2
    channel = 'both';
end
if nargin<3
    autodetectD = 0;
end
if nargin<4
    autodetectA = 0;
end
if nargin<5 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end
if isempty(mainhandles.data)
    return
end

% Selected movie
framechoice = get(mainhandles.FramesListbox,'Value')-2;
imageData = mainhandles.data(file).imageData;

% Settings
avgFrames = mainhandles.settings.peakfinder.avgFrames;
stepsize = mainhandles.settings.peakfinder.stepsize;
scanperc = mainhandles.settings.peakfinder.scanperc;
distCriteria = mainhandles.settings.peakfinder.distCriteria;

%% Find donor peaks

runbar = 0;
hWaitbar = [];
if (strcmp(channel,'donor')) || (strcmp(channel,'both'))
    if isempty(mainhandles.data(file).DpeaksRaw)
        hWaitbar = mywaitbar(runbar,'Scanning movie for green peaks...','name','iSMS'); % Update waitbar
        
        % Frames to be used
        Dchoice = mainhandles.settings.averaging.avgDchoice;
        if strcmpi(Dchoice,'all')
            interval = 1:ceil(size(imageData,3)*scanperc);
            avgimage = mainhandles.data(file).avgimage;
        elseif strcmpi(Dchoice,'Dexc')
            Dframes = find(mainhandles.data(file).excorder=='D'); % Indices of all donor exc frames
            interval = Dframes(1:ceil(end*scanperc));
            avgimage = mainhandles.data(file).avgDimage;
        end
        
        % Steps
        steps = floor(length(interval)/(avgFrames+stepsize)); % #steps
        
        % Get ROI
        Droi = round(mainhandles.data(file).Droi); %  [x y width height]
        if (Droi(3)==0) || (Droi(4)==0) % If ROI has been squeezed to zero
            return
        end
        
        % Data range
        Dx = Droi(1):(Droi(1)+Droi(3))-1;
        Dy = Droi(2):(Droi(2)+Droi(4))-1;
        
        % Run analysis
        DpeaksRawAll = zeros(100*steps,3); % [int x y]
        idx1 = 1;
        idx1b = 1;
        DpeaksMovie = cell(1,steps);
        for i = 1:steps
            % Get image of step i
            idx2 = idx1+avgFrames-1;
            image = single( mean(mainhandles.data(file).imageData(:,:,interval(idx1:idx2)),3) ); % Avg. image
            idx1 = idx2+stepsize;
            
            % Cut ROI from image
            image = image(Dx , Dy);
            
            % Apply spot-profile correction
            if mainhandles.settings.peakfinder.useSpot
                spot = mainhandles.data(file).GspotProfile;
                if ~isempty(spot) && isequal(size(spot),size(imagedata(:,:,1)))
                    image = image./(spot(Dx,Dy)/max(spot(:)));
                end
            end
            
            %-- Find all peaks and sort them in order of brightness
            Dthreshold = mainhandles.settings.peakfinder.Dthreshold;
            temp = sort(image(:)); % Image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*Dthreshold))); % Threshold for peakfinder is the mean of the 95% least-bright pixels
            DpeaksRaw = FastPeakFind(image,threshold); % Peaks in [x; y; x; y]
            DpeaksRaw = [DpeaksRaw(1:2:end-1) DpeaksRaw(2:2:end)]; % Peaks in [x y; x y]
            idx = sub2ind(size(image), DpeaksRaw(:,1), DpeaksRaw(:,2)); % Convert to linear indexing in order to evaluate Dint
            
            % Calculate peak intensities
            Dint = image(idx); % Brightness of peak pixels
            % Subtract background
            if mainhandles.settings.peakfinder.useBack
                for j = 1:size(DpeaksRaw,1)
                    [~, DbackMask] = getMask(...
                        size(image), DpeaksRaw(j,1), DpeaksRaw(j,2), mainhandles.settings.integration.wh(1), mainhandles.settings.integration.wh(2),...
                        'both', mainhandles.settings.background.backwidth, mainhandles.settings.background.backspace); % Get background mask
                    DidxBack = find(DbackMask); % Convert to linear indexes
                    Dback = mean(image(DidxBack));
                    Dint(j) = Dint(j)-Dback; % Subtract background
                end
            end
            
            % Sort
            temp = sortrows([Dint DpeaksRaw]); % Sort in ascending order
            DpeaksRaw = flipud(temp(:,:)); % Flip to descending order
            
            % Threshold of peak fitting
            ok = 1;
            if autodetectD
                DpeakIntensityThreshold = mainhandles.settings.peakfinder.DpeakIntensityThreshold;
                temp = find(DpeaksRaw(:,1)>=DpeakIntensityThreshold);
                if ~isempty(temp)
                    DsliderInternal = temp(end)/size(DpeaksRaw,1);
                    ok = 0;
                end
            end
            if ok
                DsliderInternal = mainhandles.settings.peakfinder.DsliderInternal; % Chosen threshold
            end
            DpeaksRaw = DpeaksRaw(1:round(end*DsliderInternal),:);
            
            % Put in global array
            if size(DpeaksRaw,1)>0
                idx2b = idx1b+size(DpeaksRaw,1)-1;
                if idx2b<=size(DpeaksRawAll,1)
                    DpeaksRawAll(idx1b:idx2b,:) = DpeaksRaw;
                else % If size of DpeaksAll has exceeded 100*steps
                    DpeaksRawAll = [DpeaksRawAll; DpeaksRaw];
                end
                idx1b = idx2b+1;
            end
            DpeaksMovie{i} = DpeaksRaw; % Save peaks found in throughout movie
            
            % Update waitbar
            if (strcmp(channel,'both'))
                runbar = i/(steps*2);
            else
                runbar = i/steps;
            end
            waitbar(runbar,hWaitbar,'Scanning movie for green peaks...')
        end
        
        % Save peak movie
        mainhandles.data(file).DpeaksMovie = DpeaksMovie;
        
        %---- Remove some peaks ---%
        % Remove peaks found more than once
        [~,idx,~] = unique(DpeaksRawAll(:,2:3),'rows');
        DpeaksRaw = DpeaksRawAll(idx,:);
        DpeaksRaw(ismember(DpeaksRaw,[0 0 0],'rows','legacy'),:) = [];
        
        % Remove closely spaced peaks
        [x1 x2] = meshgrid(DpeaksRaw(:,2),DpeaksRaw(:,2));
        [y1 y2] = meshgrid(DpeaksRaw(:,3),DpeaksRaw(:,3));
        alldist = sqrt( (x2-x1).^2+(y2-y1).^2 ); % Distance between all donor and acceptor peaks [size(Dpeaks)]
        [row1,row2] = find(alldist<distCriteria); % All peaks separated within the distance criteria
        if ~isempty(row1)
            rows = sort([row1(:) row2(:)],2);
            rows(rows(:,1)==rows(:,2),:) = []; % Remove identical items
            
            idx = zeros(size(rows,1),1);
            for i = 1:size(rows,1)
                [~,x] = min([DpeaksRaw(rows(i,1),1) DpeaksRaw(rows(i,2),1)]); % Index of the row representing the peak with lowest intensity
                idx(i) = rows(i,x);
            end
            DpeaksRaw(idx,:) = []; % Remove the peak with lowest intensity
        end
        
        % Sort again
        temp = sortrows(DpeaksRaw); % Sort in ascending order
        mainhandles.data(file).DpeaksRaw = flipud(temp); % Flip to descending order
    end
    
    % Extract most intense peaks using threshold defined by the peak slider
    ok = 1;
    if autodetectD
        DpeakIntensityThreshold = mainhandles.settings.peakfinder.DpeakIntensityThreshold;
        temp = find(mainhandles.data(file).DpeaksRaw(:,1)>=DpeakIntensityThreshold);
        if ~isempty(temp)
            Dslider = temp(end)/size(mainhandles.data(file).DpeaksRaw,1);
            set(mainhandles.DPeakSlider,'Value',Dslider)
            mainhandles.data(file).peakslider.Dslider = Dslider;
            ok = 0;
        end
    end
    if ok
        Dslider = get(mainhandles.DPeakSlider,'Value'); % Chosen threshold
    end
    %     Dslider = get(mainhandles.DPeakSlider,'Value'); % Chosen threshold
    mainhandles.data(file).Dpeaks = mainhandles.data(file).DpeaksRaw(1:round(end*Dslider),2:3); % Apply threshold again and remove intensities from peaks array
    
    % Update handles structure
    mainhandles = updatepeakglobal(mainhandles,'donor'); % Also updates handles structure
end

%% Find acceptor peaks

if (strcmp(channel,'acceptor')) || (strcmp(channel,'both'))
    if isempty(mainhandles.data(file).ApeaksRaw)
        if isempty(hWaitbar)
            hWaitbar = mywaitbar(runbar,'Scanning movie for red peaks...','name','iSMS'); % Update waitbar
        else
            waitbar(runbar,hWaitbar,'Scanning movie for red peaks...') % Update waitbar
        end
        
        % Frames to be used
        Achoice = mainhandles.settings.averaging.avgAchoice;
        if strcmpi(Achoice,'all')
            interval = 1:ceil(size(imageData,3)*scanperc);
            avgimage = mainhandles.data(file).avgimage;
        elseif strcmpi(Achoice,'Dexc')
            Aframes = find(mainhandles.data(file).excorder=='D'); % Indices of all donor exc frames
            interval = Aframes(1:ceil(end*scanperc));
            avgimage = mainhandles.data(file).avgDimage;
        elseif strcmpi(Achoice,'Aexc')
            Aframes = find(mainhandles.data(file).excorder=='A'); % Indices of all donor exc frames
            interval = Aframes(1:ceil(end*scanperc));
            avgimage = mainhandles.data(file).avgAimage;
        end
        
        % Steps
        steps = floor(length(interval)/(avgFrames+stepsize)); % #steps
        
        % Run analysis
        ApeaksAllRaw = zeros(100*steps,3);
        idx1 = 1;
        idx1b = 1;
        ApeaksMovie = cell(1,steps);
        for i = 1:steps
            % Get image of step i
            idx2 = idx1+avgFrames-1;
            image = single( mean(mainhandles.data(file).imageData(:,:,interval(idx1:idx2)),3) ); % Avg. image
            idx1 = idx2+stepsize;
            
            % Get ROIs
            Aroi = round(mainhandles.data(file).Aroi); %  [x y width height]
            if (Aroi(3)==0) || (Aroi(4)==0) % If ROI has been squeezed to zero
                return
            end
            
            % Data range
            Ax = Aroi(1):(Aroi(1)+Aroi(3))-1;
            Ay = Aroi(2):(Aroi(2)+Aroi(4))-1;
            
            % Cut ROI from image
            image = image(Ax , Ay);
            
            % Apply spot-profile correction
            if mainhandles.settings.peakfinder.useSpot
                spot = mainhandles.data(file).RspotProfile;
                if ~isempty(spot) && isequal(size(spot),size(imagedata(:,:,1)))
                    image = image./(spot(Ax,Ay)/max(spot(:)));
                end
            end
            
            % Find all peaks and sort them in order of brightness
            Athreshold = mainhandles.settings.peakfinder.Athreshold;
            temp = sort(image(:)); % Image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*Athreshold))); % Threshold for peakfinder is the mean of the 95% least-bright pixels
            ApeaksRaw = FastPeakFind(image,threshold); % Peaks in [x; y; x; y]
            ApeaksRaw = [ApeaksRaw(1:2:end-1) ApeaksRaw(2:2:end)]; % Peaks in [x y; x y]
            idx = sub2ind(size(image), ApeaksRaw(:,1), ApeaksRaw(:,2)); % Convert to linear indexing in order to evaluate Dint
            
            %- Sort peaks according to intensity
            Aint = image(idx); % Brightness of peak pixels
            % Subtract background
            if mainhandles.settings.peakfinder.useBack
                for j = 1:size(ApeaksRaw,1)
                    [~, AbackMask] = getMask(...
                        size(image), ApeaksRaw(j,1), ApeaksRaw(j,2), mainhandles.settings.integration.wh(1), mainhandles.settings.integration.wh(2),...
                        'backMask', mainhandles.settings.background.backwidth, mainhandles.settings.background.backspace); % Get background mask
                    AidxBack = find(AbackMask); % Convert to linear indexes
                    Aback = mean(image(AidxBack));
                    Aint(j) = Aint(j)-Aback; % Subtract background
                end
            end
            
            % Sort
            temp = sortrows([Aint ApeaksRaw]); % Sort in ascending order
            ApeaksRaw = flipud(temp(:,:)); % Flip to descending order
            
            % Extract most intense peaks according to threshold defined by
            % AsliderInternal
            ok = 1;
            if autodetectA
                ApeakIntensityThreshold = mainhandles.settings.peakfinder.ApeakIntensityThreshold;
                temp = find(ApeaksRaw(:,1)>=ApeakIntensityThreshold);
                if ~isempty(temp)
                    AsliderInternal = temp(end)/size(ApeaksRaw,1);
                    ok = 0;
                end
            end
            if ok
                AsliderInternal = mainhandles.settings.peakfinder.AsliderInternal; % Chosen threshold
            end
            %             AsliderInternal = mainhandles.settings.peakfinder.AsliderInternal; % Chosen threshold
            ApeaksRaw = ApeaksRaw(1:round(end*AsliderInternal),:); % Apply threshold
            
            % Put in global array
            if size(ApeaksRaw,1)>0
                idx2b = idx1b+size(ApeaksRaw,1)-1;
                if idx2b<=size(ApeaksAllRaw,1)
                    ApeaksAllRaw(idx1b:idx2b,:) = ApeaksRaw;
                else % If size of DpeaksAll has exceeded 100*steps
                    ApeaksAllRaw = [ApeaksAllRaw; ApeaksRaw];
                end
                idx1b = idx2b+1;
            end
            ApeaksMovie{i} = ApeaksRaw; % Save peaks found in throughout movie
            
            % Update waitbar
            if (strcmp(channel,'both'))
                runbar = (steps+i)/(steps*2);
            else
                runbar = i/steps;
            end
            waitbar(runbar,hWaitbar,'Scanning movie for red peaks...')
            
        end
        
        % Save all peaks
        mainhandles.data(file).ApeaksMovie = ApeaksMovie;
        
        %---- Remove some peaks ---%
        % Remove peaks found more than once
        [~,idx,~] = unique(ApeaksAllRaw(:,2:3),'rows');
        ApeaksRaw = ApeaksAllRaw(idx,:);
        ApeaksRaw(ismember(ApeaksRaw,[0 0 0],'rows','legacy'),:) = [];
        
        % Remove closely spaced peaks
        [x1 x2] = meshgrid(ApeaksRaw(:,2),ApeaksRaw(:,2));
        [y1 y2] = meshgrid(ApeaksRaw(:,3),ApeaksRaw(:,3));
        alldist = sqrt( (x2-x1).^2+(y2-y1).^2 ); % Distance between all donor and acceptor peaks [size(Dpeaks)]
        [row1,row2] = find(alldist<distCriteria); % All peaks separated within the distance criteria
        if ~isempty(row1)
            rows = sort([row1(:) row2(:)],2);
            rows(rows(:,1)==rows(:,2),:) = []; % Remove identical items
            
            idx = zeros(size(rows,1),1);
            for i = 1:size(rows,1)
                [~,x] = min([ApeaksRaw(rows(i,1),1) ApeaksRaw(rows(i,2),1)]); % Index of the row representing the peak with lowest intensity
                idx(i) = rows(i,x);
            end
            ApeaksRaw(idx,:) = []; % Remove the peak with lowest intensity
        end
        
        % Sort again
        temp = sortrows(ApeaksRaw); % Sort in ascending order
        mainhandles.data(file).ApeaksRaw = flipud(temp); % Flip to descending order
    end
    
    % Extract most intense peaks using threshold defined by the peak slider
    ok = 1;
    if autodetectA
        ApeakIntensityThreshold = mainhandles.settings.peakfinder.ApeakIntensityThreshold;
        temp = find(mainhandles.data(file).ApeaksRaw(:,1)>=ApeakIntensityThreshold);
        if ~isempty(temp)
            Aslider = temp(end)/size(mainhandles.data(file).ApeaksRaw,1);
            set(mainhandles.APeakSlider,'Value',Aslider)
            mainhandles.data(file).peakslider.Aslider = Aslider;
            ok = 0;
        end
    end
    if ok
        Aslider = get(mainhandles.APeakSlider,'Value'); % Chosen threshold
    end
    %         Aslider = get(mainhandles.APeakSlider,'Value'); % Chosen threshold
    mainhandles.data(file).Apeaks = mainhandles.data(file).ApeaksRaw(1:round(end*Aslider),2:3); % Apply threshold again and remove intensities from peaks array
    
    % Update handles structure
    mainhandles = updatepeakglobal(mainhandles,'acceptor'); % Also updates handles structure
end

%% Update

% Close waitbar
try delete(hWaitbar), end

% Update mainhandles structure
updatemainhandles(mainhandles)

end