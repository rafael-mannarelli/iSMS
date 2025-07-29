function mainhandles = analysedriftCallback(dwHandles)
% Callback for analysing drift button in drift window
%
%     Input:
%      dwHandles   - handles structure of the drift window
%     
%     Output:
%      mainhandles - handles structure of the main window
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

% Get mainhandles
mainhandles = getmainhandles(dwHandles);
if isempty(mainhandles)
    return
end

% Return if there is no data
if isempty(mainhandles.data)
    set(CompensateCheckbox,'Value',0)
    return
end

% Selected file
file = get(dwHandles.FilesListbox,'Value');

%% Analyse drift

mainhandles = analyseDrift(dwHandles.main,file);
mainhandles = updateDriftWindowPlots(dwHandles.main,dwHandles.figure1,'all');

%% Turn of drift compensation of selected file

if mainhandles.data(file).drifting.choice
    % Update setting
    mainhandles.data(file).drifting.choice = 0;
    updatemainhandles(mainhandles)
    
    % Update GUI
    set(dwHandles.CompensateCheckbox,'Value',0)
    mainhandles = compensatedriftCheckboxCallback(dwHandles);
end
