function mainhandles = deleteDpeaksCallback(mainhandles, showinfo)
% Callback for manually deleting green peaks in the main window toolbar
%
%     Input:
%      mainhandles   - handles structure of the main window
%      showinfo      - 0/1 whether to show infobox on startup
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

if nargin<2
    showinfo = 1;
end

if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end
mainhandles = turnofftoggles(mainhandles,'Dminus'); % Turns off all other selection toggles

% Make sure peaks are visualized
if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_DPeaksToggle,'state','on')
end

file = get(mainhandles.FilesListbox,'Value'); % Selected movie file
[~,greenImage] = getROIimages(mainhandles); % Donor and acceptor ROI data

% Return if there are no peaks to delete
if isempty(mainhandles.data(file).Dpeaks)
    set(mainhandles.mboard,'String','No donors in image')
    set(mainhandles.Toolbar_DeleteDPeaks,'State','off')
    return
end

% Color
if mainhandles.settings.view.colorblind
    col = 'g';%'b';
else
    col = 'g';
end

%% User selection

% User guide
textstr = sprintf(['How to remove peaks manually:\n\n'...
    '  1) Click at green peaks one by one in the ROI image using left mouse button.\n'...
    '  2) To finish selection, press right mouse button within the ROI image .\n ']);
set(mainhandles.mboard, 'String',textstr)
if showinfo
    mainhandles = myguidebox(mainhandles, 'Remove green peaks', textstr, 'removeDApeaks');
end

% Indices of peaks to delete
idx = [];
idxRaw = [];

but = 1;
while but == 1
    
    % Mouse click input
    [x,y,but,ax] = myginputc(1, 'Color',col ,'ValidAxes', mainhandles.ROIimage, 'FigHandle',mainhandles.figure1, 'parent', mainhandles.uipanelROIimage);
    
    % Check gui state and where mouse button was pressed
    if strcmpi(get(mainhandles.Toolbar_DeleteDPeaks,'State'),'off') || ~isequal(ax,mainhandles.ROIimage) ...
            || x<0 || y<0 || x>size(greenImage,1) || y>size(greenImage,2)
        if but~=30
            but = 0;
        end
    end
    
    if but == 1
        
        % Find closest donor
        cutsize = 5;
        dist = sqrt((mainhandles.data(file).Dpeaks(:,1)-x).^2+(mainhandles.data(file).Dpeaks(:,2)-y).^2); % Distances to all acceptors in image
        if min(dist) < cutsize
            
            % Selected peak
            idx(end+1) = find( dist==min(dist) );
            coord = mainhandles.data(file).Dpeaks(idx(end),:);
            idxRaw(end+1) = find( ismember(mainhandles.data(file).DpeaksRaw(:,2:3),coord,'rows') );
            
            % Get data points in plot
            h = findobj(mainhandles.ROIimage,'MarkerEdgeColor',col);%'Marker','o',
            x = get(h,'xdata');
            y = get(h,'ydata');
            
            % Sometimes the scatter plot is individual handles
            ok = 1;
            if iscell(x)
                try x = [x{:}]; 
                    x = cell2mat(x);
                catch err
                end
                try y = [y{:}];
                catch
                    y = cell2mat(y);
                end
                
                ok = 0;
            end
            
            % Collect
            xy = [x(:) y(:)];
            
            % Index of data point from plot
            remov = find( ismember(xy,coord,'rows') );
            
            % Remove
            if ok
                xy(remov,:) = [];
                set(h,'xdata',xy(:,1),'ydata',xy(:,2))
            else
                try delete(h(remov)), end
            end
            
        end
        
    elseif but==30 % If but==30 it means that ginputc was auto-exited because a previous instance was running. Then just re-run this function.
        mainhandles = deleteDpeaksCallback(mainhandles, 0);
        return
        
    elseif strcmpi(get(mainhandles.Toolbar_DeleteDPeaks,'State'),'on')   % For turning off the point selection-mode
        set(mainhandles.Toolbar_DeleteDPeaks,'State','off')
    end
end

%% Update

% Delete peaks
mainhandles.data(file).Dpeaks(idx,:) = []; % Remove closest peak
mainhandles.data(file).DpeaksRaw(idxRaw,:) = [];
mainhandles = updatepeakglobal(mainhandles,'donor');

% Update peak plot
Epairs_p = length(mainhandles.data(file).FRETpairs); % Number of FRET-pairs prior to deletion
mainhandles = updatepeakplot(mainhandles,'donor'); % Updates the peaks on the ROI image, removes FRET-pairs of deleted peaks, via updateFRETpairs, and updates the FRETpairwindow if open
Epairs_n = length(mainhandles.data(file).FRETpairs); % Number of FRET-pairs post deletion

% If number of FRET-pairs has changed, update the the histogramwindow
if Epairs_p~=Epairs_n
    
    % Pairs plotted in the window
    plottedPairs = getPairs(mainhandles.figure1,'plotted');
    if ~isempty(plottedPairs) && ismember(file,plottedPairs(:,1))
        mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
    end
end

% Reset message board
set(mainhandles.mboard, 'String','')
