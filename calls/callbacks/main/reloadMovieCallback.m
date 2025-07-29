function mainhandles = reloadMovieCallback(mainhandles)
% Callback for reloading raw movies
%
%    Input:
%     mainhandles    - handles structure of the main window
%
%    Output:
%     mainhandles    - ..
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

%% Import data

mainhandles = reloadMovies(mainhandles.figure1,[],1);

%% Update

updatefileslist(mainhandles.figure1, [], 'main')
mainhandles = updateROIhandles(mainhandles);
mainhandles = updateframesliderHandle(mainhandles);
mainhandles = updateMemorybar(mainhandles);
