function mainhandles = autorunCallback(mainhandles)
% Callback for auto run (green toolbar button)
%
%    Input:
%     mainhandles  - handles structure of the main window
%
%    Output:
%     mainhandles   -..
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

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(mainhandles.data) % If there is no data loaded
    return
end
prev_filechoice = get(mainhandles.FilesListbox,'Value');

% Display userguide
textstr = sprintf(['Note: Define which steps to include in the Settings->Autorun menu.\n\n'...
    'Autorun performs the following procedures (depending on settings):\n\n'...
    '  1) Align ROI positions. *\n\n'...
    '  2) Find D and A peaks.\n'...
    '  3) Identify FRET pairs.\n'...
    '  4) Calculate intensity and FRET traces.\n'...
    '  5) Detect bleaching times. *\n'...
    '  6) Remove molecules according to filter thresholds. *\n'...
    '  7) Groups molecules with bleaching. *\n\n'...
    '  8) Plot traces in the FRET-pair window.\n'...
    '  9) Plot histograms in the histogram window.\n\n'...
    '* If option is set in the auto-run settings menu.\n']);
set(mainhandles.mboard, 'String',textstr)
mainhandles = myguidebox(mainhandles, 'Auto-run analysis', textstr, 'autorun',1,'http://isms.au.dk/getstarted/quick4/');

% Determine how many files to run analysis
allFilesSetting = mainhandles.settings.autorun.AllFiles;
if ischar(allFilesSetting)
    allFilesSetting = strcmpi(allFilesSetting,'all files');
elseif islogical(allFilesSetting)
    allFilesSetting = allFilesSetting~=0;
end
if allFilesSetting==1
    files = 1:length(mainhandles.data);
    
    % Check if some data files have already been analysed
    idx = [];
    for i = 1:length(mainhandles.data)
        if ~isempty(mainhandles.data(i).FRETpairs)
            idx = [idx i];
        end
    end
    
    % Display question dialog
    if ~isempty(idx)
        
        % Create dialog message
        message = sprintf('%s\n\n%s\n',...
            'You have chosen to auto-analyse all files.',...
            'However, the following files appear to be analysed already:');
        for i = 1:length(idx)
            message = sprintf('%s\n- %s',message,mainhandles.data(idx(i)).name);
        end
        message =sprintf('%s\n\nDo you wish to (re)analyse all movies or only the movies not analysed yet?',message);
        
        % Dialog
        choice = myquestdlg(message,'Auto-analysis',....
            'All movies','Only those not already analysed','Only selected file','All movies');
        
        % Answer
        if isempty(choice) || strcmpi(choice,'Cancel')
            return
        end
        
        if strcmpi(choice,'Only those not already analysed')
            
            % Analyse files not analysed already
            files(idx) = [];
            
            % Check if filechoice is now empty
            if isempty(files)
                set(mainhandles.mboard,'string','All movies have already been analysed')
                return
            end
            
        elseif strcmpi(choice,'Only selected file')
            
            % Analyse selected file
            files = get(mainhandles.FilesListbox,'Value'); % Selected movie file
        end
        
    end
else
    files = get(mainhandles.FilesListbox,'Value'); % Selected movie file
end

% Turn on waitbar
hWaitbar = mywaitbar(0,'Finding FRET-pairs. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

%% 1+2 Align ROIs and find peaks

for i = 1:length(files)
    file = files(i);
    
    % If spot-profile, ignore it
    if mainhandles.data(file).spot
        continue
    end
    
    % Clear existing peaks
    mainhandles = resetPeakSliders(mainhandles,file);
    mainhandles = clearpeaksdata(mainhandles,file);
    
    % 1) Auto-align ROIs
    if mainhandles.settings.autorun.autoROI
        
        % Run ROI optimization twice as this often gives a better result
        setappdata(0,'closewindows',0) % Tells ROIcallback not to close open windows
        mainhandles = alignROIs(mainhandles,file,0);
        mainhandles = alignROIs(mainhandles,file,0);
        rmappdata(0,'closewindows')
    end
    
    % 2) Find D+A peaks and FRET-pairs
    % Find peak
    mainhandles = findEpairsCallback(mainhandles, 0, file, 0);
    
    % Update GUI
    if file == get(mainhandles.FilesListbox,'Value')
        updatepeakcounter(mainhandles)
    end
    
    % Update waitbar
    waitbar(i/length(files))
end

%% 3) Open FRETpairwindow & histogramwindow

% Update FRET pair window, if already open
if strcmpi(get(mainhandles.Toolbar_FRETpairwindow,'State'),'on') ...
        && ~isempty(mainhandles.FRETpairwindowHandle) && ishandle(mainhandles.FRETpairwindowHandle)
    updateFRETpairlist(mainhandles.figure1)
    [FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandles.figure1);
end

% Open FRET pair and
if strcmpi(get(mainhandles.Toolbar_histogramwindow,'State'),'off') || strcmpi(get(mainhandles.Toolbar_FRETpairwindow,'State'),'off')
    waitbar(1/2,hWaitbar,'Initializing FRET-pair window...')
    set(mainhandles.Toolbar_histogramwindow,'State','on')
    mainhandles = guidata(mainhandles.figure1);
end

% Set selection to all new pairs
histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);
set(histogramwindowHandles.plotAllPairsRadiobutton,'value',1)
set(histogramwindowHandles.FilesListbox,'Value',files)
mainhandles = SEplotchoiceCallback(histogramwindowHandles.figure1);

% Get updated mainhandles structure
mainhandles = guidata(mainhandles.figure1);

%% 4) Detect bleaching

if mainhandles.settings.autorun.autoBleach
    waitbar(3/4,hWaitbar,'Initializing FRET-pair window...')
    [mainhandles, FRETpairwindowHandles] = bleachfinderCallback(mainhandles.figure1,files);
end

%% 5) Molecule filters

if mainhandles.settings.autorun.filter1 ...
        || mainhandles.settings.autorun.filter2 ...
        || mainhandles.settings.autorun.filter3
    
    % Don't have waitbar in front because of potential dialogs from filter
    try delete(hWaitbar), end
    
    % Current filter settings (to restore below)
    filter1 = mainhandles.settings.filterPairs.filter1;
    filter2 = mainhandles.settings.filterPairs.filter2;
    filter3 = mainhandles.settings.filterPairs.filter3;
    
    % Temporary filter settings defined by autorunner
    mainhandles.settings.filterPairs.filter1 = mainhandles.settings.autorun.filter1;
    mainhandles.settings.filterPairs.filter2 = mainhandles.settings.autorun.filter2;
    mainhandles.settings.filterPairs.filter3 = mainhandles.settings.autorun.filter3;
    updatemainhandles(mainhandles)
    
    % Run filters
    newPairs = getPairs(mainhandles.figure1,'file',files);
    [mainhandles,FRETpairwindowHandles] = filterPairs(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,newPairs);
    
    % Restore original filter settings
    mainhandles.settings.filterPairs.filter1 = filter1;
    mainhandles.settings.filterPairs.filter2 = filter2;
    mainhandles.settings.filterPairs.filter3 = filter3;
    updatemainhandles(mainhandles)
end

%% 6) Create groups for bleaching

if mainhandles.settings.autorun.groupbleach
    mainhandles = creategroupforCallback(mainhandles.FRETpairwindowHandle,'Dbleach');
    mainhandles = creategroupforCallback(mainhandles.FRETpairwindowHandle,'Ableach');
    mainhandles = creategroupforCallback(mainhandles.FRETpairwindowHandle,'DAbleach');
end

%% Set filechoice back to previous

% Waitbar
try waitbar(1,hWaitbar,'Updating plots...'), end

if length(files)>1
    set(mainhandles.FilesListbox,'Value',prev_filechoice)
    updatemainhandles(mainhandles)
end

mainhandles = filesListboxCallback(mainhandles.FilesListbox); % Imitate click in listbox

% Turn attention to histogram window
figure(mainhandles.histogramwindowHandle)

% Turn off waitbar
try delete(hWaitbar), end

