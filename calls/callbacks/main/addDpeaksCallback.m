function mainhandles = addDpeaksCallback(mainhandles, showinfo)
% Callback for manually adding red peaks in the main window toolbar
%
%     Input:
%      mainhandles   - handles structure of the main window
%      showinfo      - 0/1 whether to show info box on start
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

mainhandles = turnofftoggles(mainhandles,'D');% Turns off all other selection toggles (A peaks and FRET-pair peaks)

% Make sure peaks are visualized
if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_DPeaksToggle,'state','on')
end

file = get(mainhandles.FilesListbox,'Value'); % Selected movie file
[~,greenImage] = getROIimages(mainhandles); % Donor and acceptor ROI data

%% User selection

% Display userguide
textstr = sprintf(['How to add peaks manually:\n\n'...
    '  1) Click at green peaks one by one in the ROI image using left mouse button.\n'...
    '  2) To finish selection, press right mouse button within the ROI image .\n ']);
set(mainhandles.mboard, 'String',textstr)
if showinfo
    mainhandles = myguidebox(mainhandles, 'Add donor peaks', textstr, 'addDApeaks');
end

but = 1;
while but == 1
    % Mouse click input
    [x,y,but,ax] = myginputc(1, 'Color','g' ,'ValidAxes', mainhandles.ROIimage, 'FigHandle',mainhandles.figure1, 'parent', mainhandles.uipanelROIimage);
    x = round(x);
    y = round(y);
    
    % Check gui state and where mouse button was pressed
    if strcmpi(get(mainhandles.Toolbar_AddDPeaks,'State'),'off') || (~isequal(ax,mainhandles.ROIimage)) || x<0 || y<0 || x>size(greenImage,1) || y>size(greenImage,2)
        if but~=30
            but = 0;
        end
    end
    
    if but == 1 % If left mouse button was pressed within the ROI image
        cutsize = 4; % Size of local image to cut out
        if (x>cutsize) && (y>cutsize) && (x<size(greenImage,1)-cutsize) && (y<size(greenImage,2)-cutsize)
            Z = greenImage(x-cutsize:x+cutsize , y-cutsize:y+cutsize); % Cut out a small area around selected point and find its global maximum
            P = double(peakfit2d(Z)) + double([x-cutsize-1 y-cutsize-1]);
        else
            P = [x y];
        end
        
        % Add donor and update plot
        mainhandles.data(file).Dpeaks(end+1,:) = P;
        mainhandles.data(file).DpeaksRaw = [1 P; mainhandles.data(file).DpeaksRaw]; % Put it into raw array as the "highest intensity"
        mainhandles = updatepeakglobal(mainhandles,'donor',file); % Updates the peak coordinates in the global window frame,
        mainhandles = updatepeakplot(mainhandles,'donor'); % Updates the plot of peaks on the ROI image and removes peaks detected twice, via updateDApeaks
        
        % Add acceptor if this setting is chosen
        if mainhandles.settings.peakfinder.AatD
            mainhandles.data(file).Apeaks(end+1,:) = P;
            mainhandles.data(file).ApeaksRaw = [1 P; mainhandles.data(file).ApeaksRaw]; % Put it into raw array as the "highest intensity"
            mainhandles = updatepeakglobal(mainhandles,'acceptor',file); % Updates the peak coordinates in the global window frame,
            mainhandles = updatepeakplot(mainhandles,'acceptor'); % Updates the plot of peaks on the ROI image and removes peaks detected twice, via updateDApeaks
        end
        
    elseif but==30 % If but==30 it means that ginputc was auto-exited because a previous instance was running. Then just re-run this function.
        mainhandles = addDpeaksCallback(mainhandles, 0);
        return
        
    elseif strcmpi(get(mainhandles.Toolbar_AddDPeaks,'State'),'on') % For turning off the point selection-mode:
        set(mainhandles.Toolbar_AddDPeaks,'State','off')
    end
end

% Reset message board
set(mainhandles.mboard, 'String','')
