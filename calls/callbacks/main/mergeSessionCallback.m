function mainhandles = mergeSessionCallback(mainhandles)
% Callback for merging sessions
%
%    Input:
%     mainhandles    - handles structure of the main window
%
%    Output:
%     mainhandles    - ...
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

mainhandles = turnofftoggles(mainhandles,'all'); % Turn off all interactive toggle buttons in the toolbar
if isempty(mainhandles.data) % If no data is loaded, open a session
    mainhandles = opensession(mainhandles.figure1);
    return
end

% Open a dialog for specifying file
fileformats = {'*.iSMSsession', 'iSMS session files'; '*.mat', 'Old session files'; '*.*', 'All files'};
[FileName,PathName,chose] = uigetfile3(mainhandles,'session',...
   fileformats,...
    'Merge iSMS Session','','off');
if chose == 0
    return
end
file = fullfile(PathName,FileName);

% Turn on waitbar
hWaitbar = mywaitbar(1,'Opening session. Please wait...','name','iSMS');

% Open file and retrieve state structure
temp = load(file, '-mat');
if ~myIsField(temp,'state')
    if myIsField(temp,'settings')
        set(mainhandles.mboard,'String',sprintf(...
            'It appears the selected file was a settings file, not a session file. Please select a new session file.'))
    else
        set(mainhandles.mboard,'String',sprintf(...
            'No correct iSMS session selected. A correct session is an .mat file containing a structure named state.'))
    end
    
    % Close waitbar
    delete(hWaitbar)
    return
end
state = temp.state;

% If there is no loaded data
if isempty(state.main.data)
    set(mainhandles.mboard,'String','No data found in loaded session')
    return
end

% First check if ROI movies exist in the loaded session
onlytraces = 0;
for i = 1:length(state.main.data)
    if ~isempty(state.main.data(i).DD_ROImovie)
        choice = myquestdlg('Do you wish to load the ROI movie data or just the FRET pair data (traces, etc.)? You can reload the raw movie at any time from the Memory menu.',...
            'Merge session',...
            'Only traces','Both traces and movies','Cancel','Only traces');
        if strcmpi(choice,'Only traces')
            onlytraces = 1;
        elseif isempty(choice) || strcmpi(choice,'Cancel')
            return
        end
        break
    end
end

%% Merge groups

if ~isempty(state.main.groups)
    % Check if there are any groups with identical names and ask to merge
    groups = {mainhandles.groups(:).name};
    newgroups = {state.main.groups(:).name};
    [overlap,overlapIdx] = ismember(newgroups,groups);
    if ismember(1,overlap) % If there is an overlap between groupnames
        newidx = zeros(1,length(overlap)); % New group indices of loaded groups
        choice = myquestdlg('Do you wish to merge groups with the same name?',...
            'Merge groups',...
            'Yes', 'No, rename the groups in the loaded session','Yes');
        if strcmpi(choice,'Yes') % Delete one set of the overlapping groups
            
            % Change group indices of FRETpairs in loaded session
            run = 1;
            for i = 1:length(newidx)
                if overlap(i)
                    newidx(i) = overlapIdx(i);
                else
                    newidx(i) = length(groups)+run;
                    run = run+1;
                end
            end
            
            % Delete groups with overlap
            state.main.groups(overlap) = [];
            
        else % Change the name of the loaded groups
            for i = 1:length(overlap)
                if overlap(i)
                    state.main.groups(i).name = sprintf('%s (merged)',state.main.groups(i).name);
                end
            end
            
            % Change group indices of FRETpairs in loaded session
            run = 1;
            for i = 1:length(newidx)
                newidx(i) = length(groups)+run;
                run = run+1;
            end
            
        end
        
        % Change group-indices of FRET pairs in loaded session
        for i = 1:length(state.main.data)
            for j = 1:length(state.main.data(i).FRETpairs)
                prev = state.main.data(i).FRETpairs(j).group;
                state.main.data(i).FRETpairs(j).group = newidx(prev);
            end
        end
        
    end
    
    % Add groups to handles structure
    if ~isempty(state.main.groups)
        for i = 1:length(state.main.groups)
            mainhandles.groups(end+1) = state.main.groups(i);
        end
    end
end

%% Load data

prevPairs = getPairs(mainhandles.figure1, 'all');

% Data template file
inputdata = importdataStructure(mainhandles, state.main.data, onlytraces);
inputdata = orderfields(inputdata); % Same order of fields is necessary, even if all fieldnames are identical

if ~isempty(inputdata) && isempty(mainhandles.data)
    mainhandles.data = inputdata;
elseif ~isempty(inputdata) && ~isempty(mainhandles.data)
    mainhandles.data = orderfields(mainhandles.data); % Same order of fields is necessary, even if all fieldnames are identical
    mainhandles.data(end+1:end+length(inputdata)) = inputdata;
end

%% Update

updatemainhandles(mainhandles)
updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle)
updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
updategrouplist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)

% Update plots
if strcmpi(get(mainhandles.Toolbar_FRETpairwindow,'State'),'on') && isempty(prevPairs)
    [FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandles.figure1,mainhandles.FRETpairwindowHandle);
end
if strcmpi(get(mainhandles.Toolbar_FRETpairwindow,'State'),'on')
    plottedPairs = getPairs(mainhandles.figure1, 'Plotted', [], mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle);
    files = length(mainhandles.data)-length(state.main.data):length(mainhandles.data);
    if ~isempty(plottedPairs) && ismember(1,ismember(files',plottedPairs(:,1)))
        mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle);
    end
end

% Update memory statusbar
mainhandles = updateMemorybar(mainhandles);

% Close waitbar
delete(hWaitbar)
