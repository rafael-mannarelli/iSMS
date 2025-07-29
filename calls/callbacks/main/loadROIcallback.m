function mainhandles = loadROIcallback(mainhandles)
% Callback for importing ROI positions from file
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ..
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
if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end

%% Open a dialog for specifying file

[FileName,PathName,chose] = uigetfile3(mainhandles,'settings',{'*.rois;*.mat'},'Load ROIs','name','off');
if chose == 0
    return
end

% Open file and retrieve state structure
temp = load(fullfile(PathName,FileName),'-mat');
if ~isfield(temp,'ROIs')    
    set(mainhandles.mboard,'String',sprintf('No correct iSMS ROI file selected.'))
    return
end

% Selected files
mainhandles.settings.ROIs = temp.ROIs;
if isempty(mainhandles.data)
    filechoices = [];

elseif length(mainhandles.data)==1 
    % There is just one loaded file
    filechoices = 1;

elseif length(mainhandles.data)>1 
    % There are more than one file loaded
    
    % Dialog
    choice = myquestdlg('Do you wish to set the loaded ROI positions for all files, or just the currently selected file?',...
        'Load ROIs',...
        'All files','Selected file','Selected file');
    if strcmp(choice,'All files')
        filechoices = 1:length(mainhandles.data);
    else
        filechoices = get(mainhandles.FilesListbox,'Value');
    end
end

%% Set ROIs

[mainhandles, message] = applyROIposition(mainhandles, filechoices, temp.ROIs);
