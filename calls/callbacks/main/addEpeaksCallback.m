function mainhandles = addEpeaksCallback(mainhandles, showinfo)
% Callback for selecting E-peaks manually in the main toolbar
%
%     Input:
%      mainhandles    - handles structure of the main window
%      showinfo       - 0/1 whether to show infobox on start
%
%     Output:
%      mainhandles    - ...
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
mainhandles = turnofftoggles(mainhandles,'E'); % Turns off all other selection toggles (A peaks and D peaks)

file = get(mainhandles.FilesListbox,'Value');
if isempty(mainhandles.data) || isempty(mainhandles.data(file).Dpeaks) || isempty(mainhandles.data(file).Apeaks)
    set(mainhandles.Toolbar_AddEPeaks,'state','off')
    set(mainhandles.mboard,'String','At least one donor and one acceptor must be found first')
    return
end
[redImage,~] = getROIimages(mainhandles); % Donor and acceptor ROI data

% Turn on D, A and E peaks
if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_DPeaksToggle,'state','on')
end
if strcmp(get(mainhandles.Toolbar_APeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_APeaksToggle,'state','on')
end
if strcmp(get(mainhandles.Toolbar_EPeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_EPeaksToggle,'state','on')
end

% Color setting
[Dcolor,Acolor,Ecolor] = getColors(mainhandles);

%% User selection

% Display userguide info box
textstr = sprintf(['How to select donor-acceptor pairs manually:\n\n'...
    '  1) Click at the green peak in the ROI image using left mouse button.\n\n'...
    '  2) Click at the red peak in the ROI image using left mouse button.\n\n'...
    '  3) Redo step 1-2) for the next pair.\n\n'...
    '  4) To finish selection, press right mouse button within the ROI image .\n ']);
set(mainhandles.mboard, 'String',textstr)
if showinfo
    mainhandles = myguidebox(mainhandles, 'Define pairs manually', textstr, 'addEpeaks');
end

but = 1;
first = 1;
set(mainhandles.mboard,'string','First select donor on ROI image.')
Epairs = [];
while but == 1
    % Mouse click input
    if first
        [x,y,but,ax] = myginputc(1, 'Color','g' ,'ValidAxes', mainhandles.ROIimage, 'FigHandle',mainhandles.figure1, 'parent', mainhandles.uipanelROIimage);
    else
        [x,y,but,ax] = myginputc(1, 'Color','r' ,'ValidAxes', mainhandles.ROIimage, 'FigHandle',mainhandles.figure1, 'parent', mainhandles.uipanelROIimage);
    end
    
    % Reset hInvisibleAxes used by ginputc
    if but~=30
        setappdata(0,'hInvisibleAxes',[])
    end
    
    % Check gui state and where mouse button was pressed
    if strcmpi(get(mainhandles.Toolbar_AddEPeaks,'State'),'off') || (~isequal(ax,mainhandles.ROIimage)) || x<0 || y<0 || x>size(redImage,1) || y>size(redImage,2)
        if but~=30
            but = 0;
        end
    end
    
    if but == 1
        if first
            % Find closest donor
            dist = sqrt((mainhandles.data(file).Dpeaks(:,1)-x).^2+(mainhandles.data(file).Dpeaks(:,2)-y).^2);
            Dpeak = mainhandles.data(file).Dpeaks(dist==min(dist),:);
            
            % Plot as filled circle
            hold(mainhandles.ROIimage,'on')
            scatter(mainhandles.ROIimage,Dpeak(1),Dpeak(2),'filled','MarkerFaceColor',Dcolor)
            hold(mainhandles.ROIimage,'off')
            first = 0;
            set(mainhandles.mboard,'string','Then select acceptor on ROI image.')
            
        else
            % Find closest acceptor
            dist = sqrt((mainhandles.data(file).Apeaks(:,1)-x).^2+(mainhandles.data(file).Apeaks(:,2)-y).^2);
            Apeak = mainhandles.data(file).Apeaks(dist==min(dist),:);
            
            hold(mainhandles.ROIimage,'on')
            scatter(mainhandles.ROIimage,Apeak(1),Apeak(2),'filled','MarkerFaceColor',Acolor)
            pause(0.01)
            hold(mainhandles.ROIimage,'off')
            
            % Check if either donor or acceptor already is in a FRET pair
            idx = [];
            for i = 1:length(mainhandles.data(file).FRETpairs)
                if (isequal(mainhandles.data(file).FRETpairs(i).Dxy,Dpeak)) || (isequal(mainhandles.data(file).FRETpairs(i).Axy,Apeak))
                    idx = [idx i];
                end
            end
            mainhandles.data(file).FRETpairs(idx) = [];
            
            % Put into FRETpairs structure and update plot
            Epairs_p = length(mainhandles.data(file).FRETpairs); % Number of FRET-pairs prior to deletion
            mainhandles.data(file).FRETpairs(end+1).Dxy = Dpeak;
            mainhandles.data(file).FRETpairs(end).Axy = Apeak;
            mainhandles = updatepeakglobal(mainhandles,'FRET',file); % Updates the peak coordinates in the global window frame,
            mainhandles = updatepeakplot(mainhandles,'FRET'); % Updates the peaks on the ROI image, removes FRET-pairs detected twice, via updateFRETpairs, and updates the FRETpairwindow
            Epairs_n = length(mainhandles.data(file).FRETpairs); % Number of FRET-pairs post deletion
            
            % Count new FRET pairs
            if Epairs_n>Epairs_p
                Epairs = [Epairs; length(mainhandles.data(file).FRETpairs)];
            end
            
            % If number of FRET-pairs has changed, update the
            % histogramwindow if it's open
            if (Epairs_p~=Epairs_n) && (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on'))
                mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
            end
            
            first = 1; % Reset marker tool to select new FRET-pair
            
            % Remove temporary markers
            % VERSION DEPENDENT SYNTAX
            if mainhandles.matver>8.3
                h = findobj(mainhandles.ROIimage,'MarkerFaceColor','flat');
                delete(h)
            else
                h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor','green');
                delete(h)
                h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor','red');
                delete(h)
            end
            
            set(mainhandles.mboard,'string','First select donor on ROI image.')
        end
        
    elseif but==30 % If but==30 it means that ginputc was auto-exited because a previous instance was running. Then just re-run this function.
        mainhandles = addEpeaksCallback(mainhandles, 0);
        return
        
    else % Turn off
        if mainhandles.matver>8.3
            h = findobj(mainhandles.ROIimage,'MarkerFaceColor','flat');
            delete(h)
        else
            h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor','green');
            delete(h)
            h = findobj(mainhandles.ROIimage,'Marker','o','MarkerFaceColor','red');
            delete(h)
        end
        set(mainhandles.Toolbar_AddEPeaks,'State','off')
    end
end

updatemainhandles(mainhandles)

%% Update

ok = 0;
if strcmp(get(mainhandles.Toolbar_FRETpairwindow,'State'),'on') && (~isempty(Epairs))
    if (isempty(mainhandles.data(file).DD_ROImovie)) || (isempty(mainhandles.data(file).AD_ROImovie)) || (isempty(mainhandles.data(file).AA_ROImovie))
        [mainhandles,MBerror] = saveROImovies(mainhandles); % Saves ROI movies to handles structure if not already done so
        if MBerror % If couldn't save ROI movies due to lack of memory, return
            return
        end
    end
    
    selectedPairs = [ones(length(Epairs),1)*file Epairs(:)];
    mainhandles = calculateIntensityTraces(mainhandles.figure1,selectedPairs);
    FRETpairwindowHandles = updateFRETpairplots(mainhandles.figure1,mainhandles.FRETpairwindowHandle,'all','all');
    ok = 1;
end

% If number of FRET-pairs has changed, update the histogramwindow if it's open
if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on'))
    mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
    ok = 1;
end

% Return to iSMS window
if ok
    figure(mainhandles.figure1)
end

% Reset message board
set(mainhandles.mboard, 'String','')
