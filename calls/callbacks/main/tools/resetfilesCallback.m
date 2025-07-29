function mainhandles = resetfilesCallback(mainhandles)
% Callback for resetting files in the tools menu of the main window
%
%    Input:
%     mainhandles    - handles structure of the main window
%
%    Output:
%     mainhandles     - ...
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

if isempty(mainhandles.data)
    set(mainhandles.mboard,'No data loaded.')
    return
end

% File dialog
if length(mainhandles.data)==1
    files = 1;
else
    files = mylistdlg(...
        'ListString', {mainhandles.data(:).name}',...
        'InitialValue', get(mainhandles.FilesListbox,'Value'),...
        'Name', 'Select files',...
        'ListSize', [300 300]);
    if isempty(files)
        return
    end
end

% Sure dialog
ok = mysuredlg('Reset files', 'This will close open windows and delete all FRET-pairs and peaks.');
if ~ok
    return
end

%% Close open windows

mainhandles = closeWindows(mainhandles);

%% Reset files

for i = 1:length(files)
    file = files(i);
    
    % Reset peaks
    mainhandles = resetPeakSliders(mainhandles,file);
    mainhandles = clearpeaksdata(mainhandles,file);
end

%% Update

mainhandles = filesListboxCallback([],[],mainhandles.figure1);
% mainhandles = updatepeakplot(mainhandles,[],0,0);
