function [state,mainhandles] = savestate(mainhandle,FRETpairwindowHandle,histogramwindowHandle,sc)
% Saves current state of the program (data etc.)
%
%    Input:
%     mainhandle            - handle to the main window
%     FRETpairwindowHandle  - handle to the FRETpairwindow
%     histogramwindowHandle - handle to the histogramwindow
%     sc                    - no longer used
%
%    Output:
%     state          - structure with all the info
%     mainhandles    - updated mainhandle structure
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

if nargin == 1
    sc = [];
end

% Get mainhandles structure
if isempty(mainhandle) || (~ishandle(mainhandle))
    state = [];
    mainhandles = [];
    return
else 
    mainhandles = guidata(mainhandle);
end

% Get FRETpairwindowHandles structure
if isempty(FRETpairwindowHandle) || (~ishandle(FRETpairwindowHandle))
    FRETpairwindowHandles = [];
else
    FRETpairwindowHandles = guidata(FRETpairwindowHandle);
end

% Get histogramwindowHandles structure
if isempty(histogramwindowHandle) || (~ishandle(histogramwindowHandle))
    histogramwindowHandles = [];
else
    histogramwindowHandles = guidata(histogramwindowHandle);
end

% Check that all molecule images have been calculated
allPairs = getPairs(mainhandle,'all');
for i = 1:size(allPairs,1)
    file = allPairs(i,1);
    pair = allPairs(i,2);
    
    if isempty(mainhandles.data(file).FRETpairs(pair).DD_avgimage) ...
            || isempty(mainhandles.data(file).FRETpairs(pair).AD_avgimage) ...
            || isempty(mainhandles.data(file).FRETpairs(pair).AA_avgimage)
        mainhandles = calculateMoleculeImages(mainhandle,[file pair]);
    end
end

% State structure
state = struct(...
    'smsVersion', getappdata(0,'versionSMS'),...% Software version
    'main', [],... % Data and settings of the main figure window (sms)
    'FRETpairwindow', [],... % Data and settings of the FRETpairwindow
    'histogramwindow', [],... % Data and settings of the histogramwindow
    'dynamicswindow',[]);

%% Main window

% Data, groups ans settings
state.main.data = mainhandles.data;
state.main.groups = mainhandles.groups;
state.main.settings = mainhandles.settings;
state.main.notes = mainhandles.notes;

% Don't store raw movies
for i = 1:length(mainhandles.data)
    state.main.data(i).imageData = [];
    if ~mainhandles.settings.save.saveROImovies
        state.main.data(i).DD_ROImovie = [];
        state.main.data(i).AD_ROImovie = [];
        state.main.data(i).AA_ROImovie = [];
        state.main.data(i).DA_ROImovie = [];
    end
end

% Toolbar
state.main.Toolbar_FRETpairwindow.state = get(mainhandles.Toolbar_FRETpairwindow,'State');
state.main.Toolbar_histogramwindow.state = get(mainhandles.Toolbar_histogramwindow,'State');
state.main.Toolbar_DPeaksToggle.state = get(mainhandles.Toolbar_DPeaksToggle,'State');
state.main.Toolbar_APeaksToggle.state = get(mainhandles.Toolbar_APeaksToggle,'State');
state.main.Toolbar_EPeaksToggle.state = get(mainhandles.Toolbar_EPeaksToggle,'State');

% GUI components
state.main.FilesListbox.value = get(mainhandles.FilesListbox,'Value');
state.main.FramesListbox.value = get(mainhandles.FramesListbox,'Value');
state.main.DPeakSlider.value = get(mainhandles.DPeakSlider,'Value');
state.main.APeakSlider.value = get(mainhandles.APeakSlider,'Value');

% Various
state.main.mboard.String = get(mainhandles.mboard,'String');
state.main.figure1.Position = get(mainhandles.figure1,'Position');
state.main.filename = mainhandles.filename;

% Plot
state.main.rawimage.xlim = get(mainhandles.rawimage,'xlim');
state.main.rawimage.ylim = get(mainhandles.rawimage,'ylim');
state.main.ROIimage.xlim = get(mainhandles.ROIimage,'xlim');
state.main.ROIimage.ylim = get(mainhandles.ROIimage,'ylim');

%% FRETpair window

if ~isempty(FRETpairwindowHandles)
    state.FRETpairwindow.PairListbox.value = get(FRETpairwindowHandles.PairListbox,'Value');
    state.FRETpairwindow.GroupsListbox.value = get(FRETpairwindowHandles.GroupsListbox,'Value');
    state.FRETpairwindow.figure1.Position = get(FRETpairwindowHandles.figure1,'Position');
    state.FRETpairwindow.Toolbar_ShowIntegrationArea.UserData = get(FRETpairwindowHandles.Toolbar_ShowIntegrationArea,'UserData'); % Used by the pixel pointer selection tool
end

%% Histogram window

if ~isempty(histogramwindowHandles)
    state.histogramwindow.figure1.Position = get(histogramwindowHandles.figure1,'Position');

    % GUI components
    state.histogramwindow.plotSelectedPairRadiobutton.value = get(histogramwindowHandles.plotSelectedPairRadiobutton,'Value');
    state.histogramwindow.plotSelectedGroupRadiobutton.value = get(histogramwindowHandles.plotSelectedGroupRadiobutton,'Value');
    state.histogramwindow.plotAllPairsRadiobutton.value = get(histogramwindowHandles.plotAllPairsRadiobutton,'Value');
    
    state.histogramwindow.GaussiansEditbox.string = get(histogramwindowHandles.GaussiansEditbox,'String');
    state.histogramwindow.GaussiansSlider.value = get(histogramwindowHandles.GaussiansSlider,'Value');
    
    state.histogramwindow.EbinsizeSlider.value = get(histogramwindowHandles.EbinsizeSlider,'Value');
    state.histogramwindow.SbinsizeSlider.value = get(histogramwindowHandles.SbinsizeSlider,'Value');
    state.histogramwindow.FilesListbox.value = get(histogramwindowHandles.FilesListbox,'Value');
    
    state.histogramwindow.SEplot.xlim = get(histogramwindowHandles.SEplot,'xlim');
    state.histogramwindow.SEplot.ylim = get(histogramwindowHandles.SEplot,'ylim');
end

% if ~isempty(sc)
%     mainhandles.state2 = mainhandles.state1; % State 2 is the old state
%     mainhandles.state1 = state; % State 1 is the current state
% end

%% Update
updatemainhandles(mainhandles)