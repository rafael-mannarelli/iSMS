function mainhandles = renameDataCallback(mainhandles)
% Rename data callback
%
%    Input:
%     mainhandles  - handles structure of the main window
%
%    Output:
%     mainhandles  - ..
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

%% Open selection dialog if there are too many spectra

if length(mainhandles.data)>=15
    % Open file selection dialog
    [filechoices,OK] = mylistdlg(...
        'ListString', {mainhandles.data(:).name}',...
        'SelectionMode', 'Multiple',...
        'ListSize', [300 400], ...
        'InitialValue', get(mainhandles.FilesListbox,'Value'),...
        'Name', 'Rename data',...
        'PromptString', 'Select files: ',...
        'OKString', '  Rename  ');
    
    if ~OK || isempty(filechoices)
        return
    end

else
    filechoices = 1:length(mainhandles.data);
end

selected = mainhandles.data(filechoices); % Seleced data

if isempty(selected)
    return
end

%% Prepare dialog box

name = 'Rename data';

% Make prompt structure
prompt = {'Files: ' ''};
for i = 1:length(filechoices)
    % Replace all '_' with '\_' to avoid legend subscripts
    n = mainhandles.data(filechoices(i)).name;
    n = strrep(n,'_','\_');
    prompt{end+1,1} = sprintf('%s: ',n);
    prompt{end,2} = sprintf('file%i',i);
end

% Make formats structure
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(1,1).type   = 'text';
for i = 1:length(filechoices)
    formats(end+1,1).type   = 'edit';
    formats(end).size = [300 20];
end

% Make DefAns structure
for i = 1:length(filechoices)
    DefAns.(sprintf('file%i',i)) = mainhandles.data(filechoices(i)).name;
end

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
if cancelled
    return
end

%% Make new choices happen

for i = 1:length(filechoices)
    mainhandles.data(filechoices(i)).name = answer.(sprintf('file%i',i));
end

guidata(mainhandles.figure1,mainhandles)
updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle)
