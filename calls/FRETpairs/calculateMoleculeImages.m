function mainhandles = calculateMoleculeImages(mainhandle,selectedPairs,imagechoice)
% Calculates the averaged molecule images of DD, AD and AA and stores them
% in the mainhandles structure
%
%     Input:
%      mainhandle    - handle to the main sms window
%      selectedPairs - [file pair;...] list of the molecules to calculate
%      imagechoice   - 'DD', 'AD', 'AA', 'all'
%
%     Output:
%      mainhandles   - ..
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

if isempty(mainhandle) || ~ishandle(mainhandle)
    mainhandles = [];
    return
end

mainhandles = guidata(mainhandle);
if isempty(selectedPairs)
    return
end

if nargin<3
    imagechoice = 'all';
end

%% Calculate images

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    % Check if data for calculating movies exists
    if isempty(mainhandles.data(file).DD_ROImovie)
        continue
    end
    
    % DD image
    [DDimg,xlimDcorrect,ylimDcorrect,Dxrange,Dyrange,Dedge] = getavgimg('DD');
    if ~isempty(DDimg)
        mainhandles.data(file).FRETpairs(pair).DD_avgimage = DDimg;
    end
    
    % AD image
    [ADimg,xlimAcorrect,ylimAcorrect,Axrange,Ayrange,Aedge] = getavgimg('AD');
    if ~isempty(ADimg)
        mainhandles.data(file).FRETpairs(pair).AD_avgimage = ADimg;
    end
    
    % AA image
    if mainhandles.settings.excitation.alex
        [AAimg,xlimAcorrect,ylimAcorrect,Axrange,Ayrange,Aedge] = getavgimg('AA',xlimAcorrect,ylimAcorrect,Axrange,Ayrange,Aedge); % We can use the same info as for AD
        if ~isempty(AAimg)
            mainhandles.data(file).FRETpairs(pair).AA_avgimage = AAimg;
        end
    end
    
    % Info used for plotting images
    if ~isempty(xlimDcorrect) && ~isempty(xlimAcorrect)
        mainhandles.data(file).FRETpairs(pair).limcorrect = [xlimDcorrect ylimDcorrect xlimAcorrect ylimAcorrect]; % Round off corrections of center position
        mainhandles.data(file).FRETpairs(pair).edges = [Dedge; Aedge]; % Pixels outside ROI in order [left right bottom top]
    end
    if ~isempty(Dxrange)
        mainhandles.data(file).FRETpairs(pair).Dxrange = Dxrange;
        mainhandles.data(file).FRETpairs(pair).Dyrange = Dyrange;
    end
    if ~isempty(Axrange)
        mainhandles.data(file).FRETpairs(pair).Axrange = Axrange;
        mainhandles.data(file).FRETpairs(pair).Ayrange = Ayrange;
    end
    
    %----- Set default contrast slider value
    if isempty(mainhandles.data(file).FRETpairs(pair).contrastslider)
        mainhandles.data(file).FRETpairs(pair).contrastslider = 0;
    end
end

% Update handles structure
updatemainhandles(mainhandles)

%% Nested

    function [img,xlimcorrect,ylimcorrect,xrange,yrange,edge] = getavgimg(ch,xlimcorrect,ylimcorrect,xrange,yrange,edge)
        
        % Initialize
        img = [];
        if nargin<2
            xlimcorrect = [];
            ylimcorrect = [];
            xrange = [];
            yrange = [];
            edge = [0 0 0 0]; % Pixels outside ROI in order [left right bottom top]
        end
        
        if ~strcmpi(imagechoice,ch) && ~strcmpi(imagechoice,'all')
            return
        end
        
        % Initialize field names
        driftmovieField = [ch '_ROImovieDriftCorr'];
        movieField = [ch '_ROImovie'];
        xyField = [ch(1) 'xy'];
        whField = [ch(1) 'wh'];
        intervalField = sprintf('%savgImageInterval',ch);
        
        % ROI movie data
        if mainhandles.data(file).drifting.choice && ~isempty(mainhandles.data(file).(driftmovieField))
            % If using drift-corrected movie
            ROImovie = mainhandles.data(file).(driftmovieField);
            
        else
            % If not using drift-correction
            ROImovie = mainhandles.data(file).(movieField);
        end
        
        % If raw data is missing
        if isempty(ROImovie)
            return
        end
        
        %% Get molecule area information
        
        if isempty(xrange)
            
            % Position and width
            xy = mainhandles.data(file).FRETpairs(pair).(xyField); % Position of the molecule within the ROI [x y]
            wh = mainhandles.data(file).FRETpairs(pair).(whField); % Width and height of the integration area
            
            % exPixels extra in each side for the donor and acceptor images -----%
            p = round([round(xy(1))-wh(1)/2,  round(xy(2))-wh(2)/2,  wh(1),  wh(2)]); % Position area [xmin ymin width height]. xy is rounded off to avoid double-roundoff error
            
            % Detect round-off difference in order to correct image centers later
            xlimcorrect = diff([p(1)  xy(1)-wh(1)/2]);
            ylimcorrect = diff([p(2)  xy(2)-wh(2)/2]);
            
            % Extra pixels in each side for images
            exPixels = mainhandles.settings.FRETpairplots.exPixels ...
                + mainhandles.data(file).FRETpairs(pair).backspace ...
                + mainhandles.data(file).FRETpairs(pair).backwidth;
            p(1:2) = p(1:2)-exPixels; % Set x,y position exPixels lower
            p(3:4) = p(3:4)+2*exPixels; % Make width and height 2*exPixels bigger
            
            % Image data ranges
            xrange = p(1):sum(p([1 3]))-1;
            yrange = p(2):sum(p([2 4]))-1;
            
            % If mol is at the edge of the ROI make image smaller
            while xrange(1) < 1 % If edge is to the left
                xrange = xrange(2:end);
                edge(1) = edge(1)+1;
            end
            while xrange(end) > size(ROImovie,1) % If edge is to the right
                xrange = xrange(1:end-1);
                edge(2) = edge(2)+1;
            end
            while yrange(1) < 1 % If edge is towards bottom
                yrange = yrange(2:end);
                edge(3) = edge(3)+1;
            end
            while yrange(end) > size(ROImovie,2) % If edge is towards top
                yrange = yrange(1:end-1);
                edge(4) = edge(4)+1;
            end
            
        end
        
        %% Cut movie and take avg.
        
        imageData = ROImovie(xrange, yrange,:);
        
        % Avg. image interval
        idx = round(mainhandles.data(file).FRETpairs(pair).(intervalField));
        
        % Cut length and take avg.
        if length(idx)==2 && idx(2)>idx(1) 
            
            frames = idx(1):idx(2);
            
            % If there is specified time-intervals of interest
            img = sum( imageData(:,:,frames) ,3)'/length(frames);
%             img = mean(imageData(:,:,idx(1):idx(2)),3)';
            
        else
            % If no time-interval is specified, average entire movie
            img = sum(imageData,3)'/size(imageData,3);
%             img = mean(imageData,3)';
        end
        
    end

end