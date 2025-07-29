function groupnumber = getbingroup(mainhandle)
% Returns the group bumber of the group called 'Recycle bin' 
%
%    Input:
%     mainhandle   - handle to the main window
%
%    Output:
%     groupnumnber - groupnumber
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

groupnumber = [];

% Get mainhandles structure
if isempty(mainhandle) || ~ishandle(mainhandle)
    return
end
mainhandles = guidata(mainhandle);

%% Find groupnumber

for i = 1:length(mainhandles.groups)
    if strcmpi(mainhandles.groups(i).name,'Recycle bin')
        groupnumber = [groupnumber i];
    end
end
