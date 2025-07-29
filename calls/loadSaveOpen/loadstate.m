function mainhandles = loadstate(mainhandle,state)
% Load all settings and data specified by the state structure
%
%    Input:
%     mainhandle    - handle to the main figure window
%     state         - structure containing data and settings, as saved by
%                     savestate.
%
%    Output:
%     mainhandles   - handles structure of the main window
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

% Get mainhandles structure
if isempty(mainhandle) || (~ishandle(mainhandle))
    state = [];
    mainhandles = [];
    return
else
    mainhandles = guidata(mainhandle);
end

% Don't load settings for open/save sessions
save = mainhandles.settings.save;
infobox = mainhandles.settings.infobox;
% setwindowSize = mainhandles.settings.save.setwindowSize;

%% Main window

% Toolbar
if mainhandles.settings.save.opensubGUIs
    set(mainhandles.Toolbar_FRETpairwindow, 'State',state.main.Toolbar_FRETpairwindow.state);
    mainhandles = guidata(mainhandle);
    set(mainhandles.Toolbar_histogramwindow, 'State',state.main.Toolbar_histogramwindow.state);
    mainhandles = guidata(mainhandle);
else
    set([mainhandles.Toolbar_FRETpairwindow mainhandles.Toolbar_histogramwindow], 'State','off');
end
set(mainhandles.Toolbar_DPeaksToggle, 'State',state.main.Toolbar_DPeaksToggle.state);
set(mainhandles.Toolbar_APeaksToggle, 'State',state.main.Toolbar_APeaksToggle.state);
set(mainhandles.Toolbar_EPeaksToggle, 'State',state.main.Toolbar_EPeaksToggle.state);
mainhandles = guidata(mainhandle); % Get update mainhandles structure (if changed by pressing one of the toggle buttons above)

message = ''; % Initialize potential message about compatibility errors

%% Load data

mainhandles.data = []; % Remove all previous content
[mainhandles.data datamessage] = importdataStructure(mainhandles, state.main.data, 1);
% mainhandles.data = state.main.data; % Load data stored in state
mainhandles.groups = []; % Remove all previous contents
mainhandles.groups = state.main.groups; % Load groups
mainhandles.notes = state.main.notes; % Notes

% Create time vector if not already made (earlier software versions)
for file = 1:length(mainhandles.data)
    if isempty(mainhandles.data(file).time) || length(mainhandles.data(file).excorder)~=length(mainhandles.data(file).time)
        mainhandles = createTimeVector(mainhandles, file);
    end
end

% Set raw frame interval if not already set (earlier software versions)
for file = 1:length(mainhandles.data)
    if isempty(mainhandles.data(file).avgimageFramesRaw)
        mainhandles.data(file).avgimageFramesRaw = mainhandles.data(file).avgimageFrames;
    end
end

%% Load settings.

[mainhandles.settings settingsmessage] = loadSettingsStructure(mainhandles.settings, state.main.settings);

% Settings that should not be loaded
mainhandles.settings.save = save;
mainhandles.settings.infobox = infobox;

% GUI components
set(mainhandles.FilesListbox, 'Value',1);%state.main.FilesListbox.value);
set(mainhandles.FramesListbox, 'Value',1);
set(mainhandles.DPeakSlider, 'Value',state.main.DPeakSlider.value);
set(mainhandles.APeakSlider, 'Value',state.main.APeakSlider.value);

% Update GUI menus
updatemainGUImenus(mainhandles)

% Various
mainhandles.filename = state.main.filename;
mainhandles = updatePeakthresholdsEditbox(mainhandles,2);

% % Imitate click in files listbox (updates GUI)
% updatemainhandles(mainhandles)
% updatefileslist(mainhandle,mainhandles.histogramwindowHandle)
% mainhandles = filesListboxCallback(mainhandles.FilesListbox, [], mainhandle); % Imitate click in files listbox
% 
% % Plot
% set(mainhandles.rawimage,'xlim',state.main.rawimage.xlim);
% set(mainhandles.rawimage,'ylim',state.main.rawimage.ylim);
% set(mainhandles.ROIimage,'xlim',state.main.ROIimage.xlim);
% set(mainhandles.ROIimage,'ylim',state.main.ROIimage.ylim);
% 
% Get screen size to check if window sizes exceeds screen size
rootunits = get(0,'units');
set(0,'Units','pixels')
scrsize = get(0,'ScreenSize');
set(0,'units',rootunits);

%% FRETpair window

% Get FRETpairwindowHandles structure
FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
if mainhandles.settings.save.opensubGUIs ...
        && (~isempty(FRETpairwindowHandle)) && (ishandle(FRETpairwindowHandle))
    FRETpairwindowHandles = guidata(FRETpairwindowHandle);
    
    % Set window size
    if mainhandles.settings.save.setwindowSize
        set(FRETpairwindowHandles.figure1,'Position',state.FRETpairwindow.figure1.Position);
        
        % Check window size
        winsize = getpixelposition(FRETpairwindowHandles.figure1);
        winsize2 = checkWindowSize(winsize);
        if ~isequal(winsize,winsize2)
            setpixelposition(FRETpairwindowHandles.figure1,winsize2);
        end
    end
    
    updateFRETpairlist(mainhandle,FRETpairwindowHandle)
    set(FRETpairwindowHandles.PairListbox,'Value',state.FRETpairwindow.PairListbox.value);
    set(FRETpairwindowHandles.GroupsListbox,'Value',state.FRETpairwindow.GroupsListbox.value);
    set(FRETpairwindowHandles.Toolbar_ShowIntegrationArea,'UserData',state.FRETpairwindow.Toolbar_ShowIntegrationArea.UserData); % Used by the pixel pointer selection tool
    
    % Imitate click in files listbox (updates GUI)
    %     guidata(FRETpairwindowHandles.figure1,FRETpairwindowHandles)
    %     guidata(mainhandle,mainhandles)
    FRETpairwindowHandles = guidata(FRETpairwindowHandle);
    PairListbox_Callback = FRETpairwindowHandles.functionHandles.PairListbox_Callback; % Handle to the Files Listbox Callback function of the main figure window (sms)
    PairListbox_Callback(FRETpairwindowHandles.PairListbox, [], FRETpairwindowHandles) % Imitate
    
    % Update group listbox
    updategrouplist(mainhandle,FRETpairwindowHandle)
    
    % Updaet GUI menus
    updateFRETpairwindowGUImenus(mainhandles,FRETpairwindowHandles)
    
    % Update handles structures
    mainhandles = guidata(mainhandles.figure1);
    FRETpairwindowHandles = guidata(FRETpairwindowHandles.figure1);
    
end

%% Histogram window

% Get histogramwindowHandles structure
histogramwindowHandle = mainhandles.histogramwindowHandle;
if mainhandles.settings.save.opensubGUIs ...
        && (~isempty(histogramwindowHandle)) && (ishandle(histogramwindowHandle))
    histogramwindowHandles = guidata(histogramwindowHandle);
    
    % Set window size
    if mainhandles.settings.save.setwindowSize
        set(histogramwindowHandles.figure1,'Position',state.histogramwindow.figure1.Position);
        
        % Check window size
        winsize = getpixelposition(histogramwindowHandles.figure1);
        winsize2 = checkWindowSize(winsize);
        if ~isequal(winsize,winsize2)
            setpixelposition(histogramwindowHandles.figure1,winsize2);
        end
    end
    
    % GUI components
    set(histogramwindowHandles.plotSelectedPairRadiobutton, 'Value',state.histogramwindow.plotSelectedPairRadiobutton.value);
    set(histogramwindowHandles.plotSelectedGroupRadiobutton, 'Value',state.histogramwindow.plotSelectedGroupRadiobutton.value);
    set(histogramwindowHandles.plotAllPairsRadiobutton, 'Value',state.histogramwindow.plotAllPairsRadiobutton.value);
    
    h = [histogramwindowHandles.MergeFilesTextbox histogramwindowHandles.FilesListbox];
    if get(histogramwindowHandles.plotAllPairsRadiobutton, 'Value')
        set(h,'Visible','on')
    else
        set(h,'Visible','off')
    end
    
    set(histogramwindowHandles.GaussiansEditbox, 'String',state.histogramwindow.GaussiansEditbox.string);
    set(histogramwindowHandles.GaussiansSlider, 'Value',state.histogramwindow.GaussiansSlider.value);
    
    set(histogramwindowHandles.EbinsizeSlider, 'Value',state.histogramwindow.EbinsizeSlider.value);
    set(histogramwindowHandles.SbinsizeSlider, 'Value',state.histogramwindow.SbinsizeSlider.value);
    updatefileslist(mainhandle,histogramwindowHandle)
    set(histogramwindowHandles.FilesListbox, 'Value',state.histogramwindow.FilesListbox.value);
    
    % Update GUI menus
    updateHistwindowGUImenus(mainhandles, histogramwindowHandles)
    
    % Update plot
    mainhandles = updateSEplot(mainhandle,FRETpairwindowHandle,histogramwindowHandle);
    set(histogramwindowHandles.SEplot,'xlim',state.histogramwindow.SEplot.xlim);
    set(histogramwindowHandles.SEplot,'ylim',state.histogramwindow.SEplot.ylim);
end

% Imitate click in files listbox (updates GUI)
updatemainhandles(mainhandles)
updatefileslist(mainhandle,mainhandles.histogramwindowHandle)
mainhandles = filesListboxCallback(mainhandles.FilesListbox, [], mainhandle); % Imitate click in files listbox

% Plot
set(mainhandles.rawimage,'xlim',state.main.rawimage.xlim);
set(mainhandles.rawimage,'ylim',state.main.rawimage.ylim);
set(mainhandles.ROIimage,'xlim',state.main.ROIimage.xlim);
set(mainhandles.ROIimage,'ylim',state.main.ROIimage.ylim);

% % Imitate click in files listbox (updates GUI)
% updatemainhandles(mainhandles)
% mainhandles = filesListboxCallback(mainhandles.FilesListbox); % Imitate click in files listbox

% Display message in board
if ~isempty(datamessage)
    set(mainhandles.mboard, 'String',datamessage);
elseif ~isempty(settingsmessage)
    set(mainhandles.mboard, 'String',settingsmessage);
else
    set(mainhandles.mboard, 'String',state.main.mboard.String);
end

% Set window size
if mainhandles.settings.save.setwindowSize    
    set(mainhandles.figure1, 'Position',state.main.figure1.Position);
    
    % Check window size
    winsize = getpixelposition(mainhandles.figure1);
    winsize2 = checkWindowSize(winsize);
    if ~isequal(winsize,winsize2)
        setpixelposition(mainhandles.figure1,winsize2);
    end
end

%% Update handles structure
updatemainhandles(mainhandles);

%%  Other windows

% Just turn off (temporary fix)
set(mainhandles.Toolbar_dynamicswindow,'State','off')
set(mainhandles.Toolbar_correctionfactorWindow,'State','off')
% set(mainhandles.Toolbar_profileWindow,'State','off')
try delete(mainhandles.driftwindowHandle), end
try delete(mainhandles.integrationwindowHandle), end
try delete(mainhandles.psfwindowHandle), end
try delete(mainhandles.notebookHandle), end

%% Update handles structure
mainhandles = guidata(mainhandles.figure1);

%% Subroutines

    function winsize2 = checkWindowSize(winsize)
        % Checks if window size exceeds screensize and adjusts accordingly
        winsize2 = winsize;
        
        % Check position
        if winsize2(1)<0
            winsize2(1) = 1;
        end
        if winsize2(2)<0
            winsize2(2) = 1;
        end
        
        % Check size
        if winsize2(3)>scrsize(3)
            
            % If window size is larger than screen size
            winsize2(1) = 1;
            winsize2(3) = scrsize(3);
            
        elseif sum(winsize2([1 3]))>scrsize(3)
            
            % If right border exceeds right screen size
            d = sum(winsize2([1 3]))-scrsize(3);
            winsize2(1) = winsize2(1)-d;
            if winsize2(1)<0
                
                % If movement caused the window to go outside left bound
                winsize2(3) = winsize2(3)+winsize2(1)-1;
                winsize2(1) = 1;
            end
        end
        
        if winsize2(4)>scrsize(4)
            
            % If window size is larger than screen size
            winsize2(2) = 1;
            winsize2(4) = scrsize(4);
            
        elseif sum(winsize2([2 4]))>scrsize(4)
            
            % If right border exceeds right screen size
            d = sum(winsize2([2 4]))-scrsize(4);
            winsize2(2) = winsize2(2)-d;
            if winsize2(2)<0
                
                % If movement caused the window to go outside left bound
                winsize2(4) = winsize2(4)+winsize2(2)-1;
                winsize2(2) = 1;
            end
        end
        
    end

end