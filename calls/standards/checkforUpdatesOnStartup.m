function mainhandles = checkforUpdatesOnStartup(mainhandles)
% Callback for ticking whether to check for updates on startup in the help
% menu of the program
%
%    Input:
%     handles  - handles structures of the main window. Must have a field
%     with startup.checkforUpdates and .workdir
%
%    Output:
%     handles  - ..
%

% --- Copyrights (C) ---
%
% Copyright (C)  Søren Preus, FluorTools.com
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

% Update handles structure
mainhandles = savesettingasDefault(mainhandles,'startup','checkforUpdates',abs(mainhandles.settings.startup.checkforUpdates-1));

% Update GUI menus
updatemainGUImenus(mainhandles)
