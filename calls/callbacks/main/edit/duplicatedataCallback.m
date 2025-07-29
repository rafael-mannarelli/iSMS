function mainhandles = duplicatedataCallback(mainhandles)
% Callback for duplicating data set in the main window
%
%   Input:
%    mainhandles  - handles structure of the main window
%
%   Output:
%    mainhandles  - ..
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

% Check data
if (isempty(mainhandles.data)) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end

% Open selection dialog box:
movchoice = selectionDlg(mainhandles,'Duplicate data set','Select data to duplicate:');
if isempty(movchoice)
    return
end

%% Duplicate selected spectra

for i = 1:length(movchoice)
    mainhandles.data(end+1) = mainhandles.data(movchoice(i));
end

%% Update GUI

updatemainhandles(mainhandles)
updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle)
