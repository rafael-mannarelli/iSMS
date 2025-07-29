function [mainhandles, FRETpairwindowHandles] = turnOnSelectBackPixelsCallback(FRETpairwindowHandles)
% Callback for turning on the select background pixels tool in the FRET
% pair window
%
%     Input:
%      FRETpairwindowHandles   - handles structure of the FRETpairwindow
%
%     Output:
%      mainhandles             - handles structure of the main window
%      FRETpairwindowHandles   - handles structure of the FRETpairwindow
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

% Turn of other toggle buttons
FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'backPixels');

% Get handles structure of the main figure window
mainhandles = getmainhandles(FRETpairwindowHandles);
if isempty(mainhandles)
    set(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State','off')
    return
end

% File and pair choice
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    set(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State','off')
    return
elseif size(selectedPairs,1)>1
    mymsgbox('You must select a single FRET-pair only in order to use this tool.','Integration area');
    set(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State','off')
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% Scheme
alex = mainhandles.settings.excitation.alex;

% Check raw data
[mainhandles, hasRaw, hasROI] = checkRawData(mainhandles,filechoice);
if ~hasROI
    set(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State','off')
    return
end

% Display userguide info box
textstr = sprintf(['You have activated the pixel selection tool. How to select background pixels manually:\n\n'...
    '  1) Using the activated crosshair, point at the first pixel of interest.\n'...
    '  2) Left-click mouse on the pixel. If the pixel is already used for background it will be removed.\n'...
    '  3) Wait for the GUI to update before clicking next pixel.\n'...
    '  4) When GUI is updated, click on the next pixel of interest.\n'...
    '  5) To FINISH, right-click mouse on image.\n\n'...
    'The intensity and FRET traces can be automatically updated according to the new background pixels - if this setting is ticked.\n\n ']);
set(mainhandles.mboard, 'String',textstr)
mainhandles = myguidebox(mainhandles, 'Set background pixels', textstr, 'backgroundPixels',1,'http://isms.au.dk/documentation/intensities-and-background/');

% Make sure pixels are visualized
showpixels = 1;
if mainhandles.settings.FRETpairplots.showBackPixels==0
    mainhandles.settings.FRETpairplots.showBackPixels = 1;
    set(FRETpairwindowHandles.View_PixelHighlighting_BackMask,'Checked','on')
    updatemainhandles(mainhandles)
    FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1, 'images');
    showpixels = 0;
end

% Get mask
range = get(FRETpairwindowHandles.Toolbar_ShowIntegrationArea,'UserData');
Dxrange = range{1};
Dyrange = range{2};
Axrange = range{3};
Ayrange = range{4};

DbackMask = mainhandles.data(filechoice).FRETpairs(pairchoice).DbackMask(Dxrange,Dyrange);
AbackMask = mainhandles.data(filechoice).FRETpairs(pairchoice).AbackMask(Axrange,Ayrange);

% Cursor color
if strcmp(mainhandles.settings.FRETpairplots.backMaskColor,'white') % If white mask, plot ginput in grey
    ginputColor = [0.5 0.5 0.5];
else % If grey mask, plot ginput in white
    ginputColor = [1 1 1];
end

% Set current figure
set(0,'currentfigure',FRETpairwindowHandles.figure1)

%% User input

but = 1;
ok = 0; % To check if it is ok to update handles and GUI
while but == 1
    % Active axes
    if alex
        axs = [FRETpairwindowHandles.DDimageAxes FRETpairwindowHandles.ADimageAxes FRETpairwindowHandles.AAimageAxes];
    else
        axs = [FRETpairwindowHandles.DDimageAxes FRETpairwindowHandles.ADimageAxes];
    end

    % Mouse click input    
    [x,y,but,ax] = myginputc2(1,...
        'FigHandle', FRETpairwindowHandles.figure1,...
        'ValidAxes', axs,...
        'Color',ginputColor);
    
    % Check selection
    if isempty(but) || (but~=1 && but~=30)... % If user didn't press left
            || (~isequal(ax,FRETpairwindowHandles.DDimageAxes) ... % If user pressed outside axes
            && ~isequal(ax,FRETpairwindowHandles.ADimageAxes) ...
            && ~isequal(ax,FRETpairwindowHandles.AAimageAxes))
        
        % Update GUI and handles
        [mainhandles,FRETpairwindowHandles] = updateWindow(mainhandles,FRETpairwindowHandles, ~mainhandles.settings.FRETpairplots.liveupdateTrace);
        set(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State','off')
        return
    end
    
    % Reset hInvisibleAxes used by ginputc
    if but~=30
        setappdata(0,'hInvisibleAxes',[])
        
    elseif but==30
        % Re-run this function
        [mainhandles, FRETpairwindowHandles] = turnOnSelectBackPixelsCallback(FRETpairwindowHandles);
        return
    end
    
    % If user turned off the toggle button
    if strcmp(get(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State'),'off')
        but = 0;
    end
    
    % Perform action
    if but == 1
        
        x = round(x);
        y = round(y);
        if (isequal(ax,FRETpairwindowHandles.DDimageAxes)) ...
                && (x>0) && (y>0) && (x<size(DbackMask,1)) && (y<size(DbackMask,2))
            
            if DbackMask(x,y)==0
                DbackMask(x,y) = 1;
            elseif DbackMask(x,y)==1
                DbackMask(x,y) = 0;
            end
            mainhandles.data(filechoice).FRETpairs(pairchoice).DbackMask(Dxrange,Dyrange) = DbackMask;
            
            ok = 1;
            
        elseif ((isequal(ax,FRETpairwindowHandles.ADimageAxes)) || (alex && isequal(ax,FRETpairwindowHandles.AAimageAxes))) ...
                && (x>0) && (y>0) && (x<size(AbackMask,1)) && (y<size(AbackMask,2))
            
            if AbackMask(x,y)==0
                AbackMask(x,y) = 1;
            elseif AbackMask(x,y)==1
                AbackMask(x,y) = 0;
            end
            mainhandles.data(filechoice).FRETpairs(pairchoice).AbackMask(Axrange,Ayrange) = AbackMask;
            
            ok = 1;
            
        else
            but = 0;
        end
        
        % Update GUI and handles
        [mainhandles,FRETpairwindowHandles] = updateWindow(mainhandles,FRETpairwindowHandles, mainhandles.settings.FRETpairplots.liveupdateTrace);
        
    elseif strcmpi(get(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State'),'on')   % For turning off the point selection-mode
        
        set(FRETpairwindowHandles.Toolbar_SelectBackPixels,'State','off')
        
    end
end

% Update GUI and handles
[mainhandles,FRETpairwindowHandles] = updateWindow(mainhandles,FRETpairwindowHandles, ~mainhandles.settings.FRETpairplots.liveupdateTrace);

% Remove highlighting
if ~showpixels
    mainhandles.settings.FRETpairplots.showBackPixels = 0;
    set(FRETpairwindowHandles.View_PixelHighlighting_BackMask,'Checked','off')
    updatemainhandles(mainhandles)
    FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1, 'images');
end

%% Nested

    function [mainhandles, FRETpairwindowHandles] = updateTraces(mainhandles, FRETpairwindowHandles)
        
        % Update trace according to new selection and update plot
        mainhandles = calculateIntensityTraces(FRETpairwindowHandles.main,[filechoice pairchoice]);
        
        % Keep listbox selection if it has changed
        if mainhandles.settings.FRETpairplots.sortpairs>2
            listedPairs = getPairs(FRETpairwindowHandles.main,'listed',[],FRETpairwindowHandles.figure1); % Pairs listed
            idx = find( ismember(listedPairs,[filechoice pairchoice],'rows','legacy') ); % Find new idx
            set(FRETpairwindowHandles.PairListbox, 'Value',idx) % Set to new idx
        end
        
        FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1, 'all');
        FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1);
        
        % If histogram is open update the histogram
        if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')) && (~isempty(mainhandles.histogramwindowHandle)) && (ishandle(mainhandles.histogramwindowHandle))
            plottedPairs = getPairs(FRETpairwindowHandles.main, 'Plotted', [], FRETpairwindowHandles.figure1, mainhandles.histogramwindowHandle);
            if ismember([filechoice pairchoice],plottedPairs,'rows','legacy')
                mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
%                 axes(FRETpairwindowHandles.DDtraceAxes)
            end
        end
        
    end

    function [mainhandles, FRETpairwindowHandles] = updateWindow(mainhandles,FRETpairwindowHandles,calc)
        if ~ok
            return
        end
        
        % Update traces
        updatemainhandles(mainhandles)
        
        % Update plots
        if calc
            [mainhandles,FRETpairwindowHandles] = updateTraces(mainhandles,FRETpairwindowHandles);
            
        else
            
            % Only live-update image
            FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1, 'images');
        end
    end

end
