function mainhandles = importfromSession(mainhandles)
% Callback for loading data from another session
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

%% Open a dialog for specifying file

[FileName,PathName,chose] = uigetfile3(mainhandles,'session','*.iSMSsession','Import from session','name','off');
if chose == 0
    return
end
file = fullfile(PathName,FileName);

%% Open file and retrieve state structure

temp = load(file,'-mat');
if ~isfield(temp,'state')
    set(mainhandles.mboard,'String',sprintf(...
        'No correct iSMS session selected. A correct session is a .iSMSsession file containing a structure named state.'))
    return
end
inputdata = temp.state.main.data;

% If there is no data in loaded session
if isempty(inputdata)
    mymsgbox('No data found in loaded session.')
    return
end

% Open file selection dialog
name = 'Import data';
prompt = {'Select data: ' 'filechoices';...
    'Import also raw data' 'importRaw'};

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = {inputdata(:).name}';
formats(2,1).size = [500 300];
formats(2,1).limits = [0 2]; % multi-select
formats(4,1).type = 'check';

% Make DefAns structure
DefAns.filechoices = 1:length(inputdata);
DefAns.importRaw = mainhandles.settings.import.importRaw;

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
if cancelled==1 || isempty(answer.filechoices)
    return
end

%% Interpret choices

filechoices = answer.filechoices;
tracesonly = ~answer.importRaw;
mainhandles.settings.import.importRaw = answer.importRaw;
updatemainhandles(mainhandles)

% Prepare import data structure so that it matches the current data
% structure format
data_new = importdataStructure(mainhandles,inputdata(filechoices),tracesonly);
data_new = orderfields(data_new);

% Put in handles structure
if isempty(data_new)
    return
end
if isempty(mainhandles.data)
    mainhandles.data = data_new;
else
    mainhandles.data = orderfields(mainhandles.data);
    mainhandles.data(end+1:end+length(data_new)) = data_new;
end
updatemainhandles(mainhandles)

% Show message
set(mainhandles.mboard, 'String',sprintf('%i files were added to the current session.',length(data_new)))

%% Update

updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle,'all',mainhandles.driftwindowHandle) % Update listbox items
set(mainhandles.FilesListbox, 'Value',length(mainhandles.data))
mainhandles = filesListboxCallback(mainhandles.FilesListbox, [], mainhandles.figure1); % Imitate click in files listbox
