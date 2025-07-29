function ok = saveDefaultSettings(mainhandles, settings)
% Saves the settings structure to a file located in sttings subfolder
%
%    Input:
%     mainhandles   - handles structure of the main window
%     settings      - default settings structure to save
%
%    Output:
%     ok            - 0/1 whether file write was succesful
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

% Default is the current settings structure
if nargin<2
    settings = mainhandles.settings;
end

% File to be saved
defaultSettingsFile = fullfile(mainhandles.settingsdir,'default.settings'); 

% Saves settings structure to .mat file
ok = saveSettings(mainhandles, settings, defaultSettingsFile);

% update messageboard. Use try because it may not have been created yet.
try 
    if ok
        set(mainhandles.mboard,'String',sprintf('Default settings saved to:\n%s\n',defaultSettingsFile))
    end
end
