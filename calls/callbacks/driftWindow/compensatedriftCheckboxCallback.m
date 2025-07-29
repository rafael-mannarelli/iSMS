function mainhandles = compensatedriftCheckboxCallback(dwHandles)
% Callback for the compensate drift checkbox in the drift window
%
%    Input:
%     dwHandles    - handles structure of the drift window
%
%    Output:
%     mainhandles  - handles structure of the main window
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

mainhandles = getmainhandles(dwHandles); % Get handles structure of the main window
if isempty(mainhandles)
    return
end
if isempty(mainhandles.data)
    set(CompensateCheckbox,'Value',0)
    return
end
if nargin<4
    runCompensation = 1;
end
filechoice = get(dwHandles.FilesListbox,'Value'); % Selected movie file

% Act to selection: Compensate drift
h = [dwHandles.CompensationPanel];
ok = 1;
if get(dwHandles.CompensateCheckbox,'Value')==1
    mainhandles.data(filechoice).drifting.choice = 1;
    if runCompensation
        updatemainhandles(mainhandles)
        mainhandles = compensateDrift(dwHandles.main,filechoice); % Run drift compensation
        ok = 0;
    end
    set(h,'Visible','on')
else
    mainhandles.data(filechoice).drifting.choice = 0;
    mainhandles.data(filechoice).DD_ROImovieDriftCorr = [];
    mainhandles.data(filechoice).AD_ROImovieDriftCorr = [];
    mainhandles.data(filechoice).AA_ROImovieDriftCorr = [];
    set(h,'Visible','off')
end
updatemainhandles(mainhandles)

%% Calculate drift compensated intensity traces, images and update plots

if ok && runCompensation
    filePairs = getPairs(dwHandles.main, 'File', filechoice);
    if ~isempty(filePairs)
        [mainhandles FRETpairwindowHandles] = calculateIntensityTraces(dwHandles.main, filePairs); % Calculate new intensity traces
        mainhandles = calculateMoleculeImages(dwHandles.main, filePairs); % Calculate new molecule images
    end
end

%% Update

% Update other GUI windows
ok = 0;
% Update FRET pair window plots
selectedPairs = getPairs(dwHandles.main, 'Selected', [], mainhandles.FRETpairwindowHandle);
if size(selectedPairs,1)==1 && selectedPairs(1)==filechoice
    [FRETpairwindowHandles,mainhandles] = updateFRETpairplots(dwHandles.main,mainhandles.FRETpairwindowHandle);
    ok = 1;
end

% Update SE histogramwindow
plottedPairs = getPairs(dwHandles.main, 'Plotted', [], mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle);
if ~isempty(plottedPairs) && ismember(filechoice,plottedPairs(:,1))
    mainhandles = updateSEplot(dwHandles.main,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle);
    ok = 1;
end

% Return focus to current window
if ok
    figure(dwHandles.figure1)
end

% Update memory statusbar
mainhandles = updateMemorybar(mainhandles);

% Update GUI
updateDriftWindowPairlist(dwHandles.main,dwHandles.figure1)
mainhandles = updateDriftWindowPlots(dwHandles.main,dwHandles.figure1,'pair');
