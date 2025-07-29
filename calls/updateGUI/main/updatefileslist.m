function updatefileslist(mainhandle,histogramwindowHandle,choice,driftwindowHandle)
% Updates the files listboxes in the sms main GUI, the histogramwindow
% GUI, and the driftwindow GUI
%
%     Input:
%      mainhandle            - handle to the main window
%      histogramwindowHandle - handle to the histogramwindow
%      choice                - 'main','histogramwindow','all'
%      driftwindowHandle     - handle to the driftwindow
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

% Default
if nargin<3
    choice = 'all';
end

%% First update the main window

if (isempty(mainhandle)) || (~ishandle(mainhandle)) % If there is no main handle input, return
    return
end
mainhandles = guidata(mainhandle); % Get handles structure

if strcmpi(choice,'main') || strcmpi(choice,'all')
    % Set string name
    namestr = '';
    if isempty(mainhandles.data) 
        
        % If no files are loaded, set empty string
        set(mainhandles.FilesListbox,'String','')

    else
        
        % If files are loaded update the filenames in the listbox
        namestr = getfileslistStr(mainhandles);
        set(mainhandles.FilesListbox,'String',namestr)
        %     set(mainhandles.FilesListbox,'String',{mainhandles.data(:).name})
    end
    
    % Check listbox value
    if ~isempty(namestr) && (isempty(get(mainhandles.FilesListbox,'Value')) || get(mainhandles.FilesListbox,'Value')>length(namestr))
        set(mainhandles.FilesListbox,'Value',length(namestr))
    end
end

%% Then do histogram window

% Get handle
if nargin<2 || isempty(histogramwindowHandle)
    histogramwindowHandle = mainhandles.histogramwindowHandle;
end

if (strcmpi(choice,'histogramwindow') || strcmpi(choice,'all')) ...
        && (~isempty(histogramwindowHandle)) && (ishandle(histogramwindowHandle))
    
    % Get handles structure
    histogramwindowHandles = guidata(histogramwindowHandle);
    
    % Set string name
    if isempty(mainhandles.data) % If no files are loaded, set empty string
        set(histogramwindowHandles.FilesListbox,'String','')
    else % If files are loaded update the filenames in the listbox
        namestr = cell(length(mainhandles.data),1);
        for i = 1:length(mainhandles.data)
            namestr{i} = sprintf('%i) %s', i, mainhandles.data(i).name); % Change listbox string
        end
        set(histogramwindowHandles.FilesListbox,'String',namestr)
        %     set(histogramwindowHandles.FilesListbox,'String',{mainhandles.data(:).name})
    end
end

%% Then do drift window files list

if (strcmpi(choice,'driftwindow') || strcmpi(choice,'all'))
    
    % Get handle
    if nargin<4 || isempty(driftwindowHandle)
        driftwindowHandle = mainhandles.driftwindowHandle;
    end
    
    % Get handles structure
    if (isempty(driftwindowHandle)) || (~ishandle(driftwindowHandle))
        return
    end
    driftwindowHandles = guidata(driftwindowHandle);
    
    % Set string name
    if isempty(mainhandles.data) 
        % If no files are loaded, set empty string
        set(driftwindowHandles.FilesListbox,'String','')
    else
        % If files are loaded update the filenames in the listbox
        namestr = cell(length(mainhandles.data),1);
        for i = 1:length(mainhandles.data)
            namestr{i} = sprintf('%i) %s', i, mainhandles.data(i).name); % Change listbox string
        end
        set(driftwindowHandles.FilesListbox,'String',namestr)
    end
end

% Update memory bar to reflect new number of datasets
mainhandles = updateMemorybar(mainhandles);
