function mainhandles = autoalignROIsCallback(mainhandles,file)
% Callback for autoaligning ROIs in the main window
%
%    Input:
%     mainhandles  - handles structure of the main window
%     file         - movie file
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

% Get handles
mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(mainhandles.data)
    return
end

% Default
if nargin<2 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end

% Check if raw movie has been deleted
if isempty(mainhandles.data(file).imageData)
    
    % Dialog
    choice = myquestdlg(sprintf('The raw movie has been deleted for this file (%s). Do you want to reload the movie from file?',mainhandles.data(file).name),...
        'Movie deleted',...
        'Yes','No','No');
    
    % Reload
    if strcmp(choice,'Yes')
        mainhandles = reloadMovieCallback(mainhandles);
    end
    return
end

%% Align ROIs

% Run ROI optimization twice as this often gives a better result (the
% second optimization uses images optimized in the first)
mainhandles = alignROIs(mainhandles,file);
mainhandles = alignROIs(mainhandles,file);

%% Update local peak coordinats

mainhandles = updatepeaklocal(mainhandles,'all',file);
