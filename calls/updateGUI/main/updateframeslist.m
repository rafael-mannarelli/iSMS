function updateframeslist(mainhandles)
% Updates the frames listbox in the main window (sms)
%
%   Input:
%    mainhandles   - handles structure of the main window
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

% Check 
if isempty(mainhandles.data) % If no files are loaded
    set(mainhandles.FramesListbox,'String','')
    return
end
file = get(mainhandles.FilesListbox,'Value');

%% Make listbox string

if ~isempty(mainhandles.data(file).imageData) % If raw movie data has been deleted
    frames = cell(1,size(mainhandles.data(file).imageData,3)+2);
    for i = 1:length(mainhandles.data(file).excorder)
        frames{i+2} = sprintf('%i - %s',i,mainhandles.data(file).excorder(i));
    end
else
    frames = cell(1);
end
frames{1} = 'Avg.';
frames{2} = 'Backgr.';

%% Update listbox string

set(mainhandles.FramesListbox,'String', frames)
