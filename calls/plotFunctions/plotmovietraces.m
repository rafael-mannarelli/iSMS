function windowhandle = plotmovietraces(mainhandles,channel)
% Opens a plot window with selected image intensity traces. Used by average
% image settings menu.
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     windowhandle  - handle to the opened window
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

windowhandle = [];
if isempty(mainhandles.data) % If no data is loaded, return
    return
end
file = get(mainhandles.FilesListbox,'Value'); % Selected movie file

% Check if raw movie has been deleted
if isempty(mainhandles.data(file).imageData)
%     choice = myquestdlg(sprintf('The raw movie has been deleted for this file (%s). Do you want to reload the movie from file?',mainhandles.data(file).name),...
%         'Movie deleted',...
%         'Yes','No','No');
%     if strcmp(choice,'Yes')
%         mainhandles = reloadMovieCallback(mainhandles);
        return
%     elseif strcmp(choice,'No')
%         return
%     end
end

%% Plot

if mainhandles.settings.excitation.alex
    
    % Get ROIs
    Droi = round(mainhandles.data(file).Droi); %  [x y width height]; Donor ROI position within global image
    Aroi = round(mainhandles.data(file).Aroi); %  [x y width height]; Acceptor ROI position within global image
    if (Droi(3)==0) || (Droi(4)==0) % If ROI has been squeezed to zero, return
        return
    end
    if ~isequal(Droi(3:4),Aroi(3:4)) % If, due to a bug, the A and D ROIs are not of same size
        display('Donor-ROI and acceptor-ROI are not of equal size!')
        return
    end
    
    % ---------------- Calculate intensiy traces ----------------%
    % D and A data ranges
    Dx = Droi(1):(Droi(1)+Droi(3))-1; % Donor ROI x-range
    Dy = Droi(2):(Droi(2)+Droi(4))-1; % Donor ROI y-range
    Ax = Aroi(1):(Aroi(1)+Aroi(3))-1; % Acceptor ROI x-range
    Ay = Aroi(2):(Aroi(2)+Aroi(4))-1; % Acceptor ROI y-range
    
    % Calculate intensity trace in Droi with D excitation
    Dframes = find(mainhandles.data(file).excorder=='D')'; % Indices of all D-excitation frames within the movie
    DroiTrace = zeros(length(Dframes),2); % Pre-allocate data memory for the D-ROI intensity trace
    % DroiTrace(:,1) = Dframes;
    DroiTrace(:,1) = 1:length(Dframes);
    for i = 1:length(Dframes)
        ROIimage = mainhandles.data(file).imageData(Dx,Dy,Dframes(i))'; % Movie frame i
        DroiTrace(i,2) = sum(ROIimage(:)); % Total intensity of movie frame i
    end
    
    % Calculate intensity trace in Aroi with A excitation
    Aframes = find(mainhandles.data(file).excorder=='A')'; % Indices of all A-excitation frames within the movie
    AroiTrace = zeros(length(Aframes),2); % Pre-allocate data memory for the A-ROI intensity trace
    % AroiTrace(:,1) = Aframes;
    AroiTrace(:,1) = 1:length(Aframes);
    for i = 1:length(Aframes)
        ROIimage = mainhandles.data(file).imageData(Ax,Ay,Aframes(i))'; % Movie frame i
        AroiTrace(i,2) = sum(ROIimage(:)); % Total intensity of movie frame i
    end
    
    %-------- Plot calculated intensity traces ---------%
    if (isempty(mainhandles.plotmovietracesHandle)) || (~ishandle(mainhandles.plotmovietracesHandle))
        windowhandle = figure;
        updatelogo(windowhandle)
        mainhandles.plotmovietracesHandle = gcf;
        set(gcf,'name','Total image intensity plots','numbertitle','off')
        movegui(gcf,'east') % Move figure to the northeast of the screen
    end
    
    figure(mainhandles.plotmovietracesHandle)
    
    % Donor trace
    subplot(2,1,1)
    plot(DroiTrace(:,1),DroiTrace(:,2),'green')
    xlabel('Frame')
    ylabel('Total intensity')
    title('Total intensity in D-ROI with D-exc')
    
    % Acceptor trace
    subplot(2,1,2)
    plot(AroiTrace(:,1),AroiTrace(:,2),'red')
    xlabel('Frame')
    ylabel('Total intensity')
    title('Total intensity in A-ROI with A-exc')
    
else
    
    % Not alex
    n = size(mainhandles.data(file).imageData,3);
    trace = zeros(n,2); % Pre-allocate data memory for the D-ROI intensity trace    
    trace(:,1) = 1:n;
    for i = 1:n
        img = mainhandles.data(file).imageData(:,:,i); % Movie frame i
        trace(i,2) = sum(img(:)); % Total intensity of movie frame i
    end
    
    if (isempty(mainhandles.plotmovietracesHandle)) || (~ishandle(mainhandles.plotmovietracesHandle))
        windowhandle = figure;
        updatelogo(windowhandle)
        mainhandles.plotmovietracesHandle = gcf;
        set(gcf,'name','Total image intensity plot','numbertitle','off')
        movegui(gcf,'east') % Move figure to the northeast of the screen
    end
    
    figure(mainhandles.plotmovietracesHandle)
    
    % Donor trace
    plot(trace(:,1),trace(:,2),'blue')
    xlabel('Frame')
    ylabel('Total intensity')
    title('Total intensity in raw movie')
    
end