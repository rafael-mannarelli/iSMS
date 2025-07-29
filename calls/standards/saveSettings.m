function ok = saveSettings(mainhandles, settings, filename)
% Saves the settings structure to filename
%
%    Input:
%     mainhandles - handles structure of the main window
%     settings    - settings structure of the program (usually
%                   handles.settings)
%     filename    - path+file to be saved
%
%    Output:
%     ok          - 0/1 whether disk write was successful
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

%% Initialize

% Default is the usual default settings folder
if nargin<2
    settings = mainhandles.settings;
end
if nargin<3
    filename = fullfile(mainhandles.settingsdir,'default.settings');
end

ok = 1;

%% Save file

try 
    save(filename,'settings'); 
    try rmappdata(0,'administratorMsgbox'), end
    
catch err
    
    % Access denied error
    if strcmpi(err.identifier,'MATLAB:save:permissionDenied') && isempty(getappdata(0,'administratorMsgbox'))
        
        % Message box
        message = sprintf(['Unable to create necessary settings files at:\n  %s\n\n'...
            'You must have administrator rights at the directory of installation.\n\n'...
            'ALL YOU NEED now is probably just to copy the iSMS program folder and associated files to another location such as your Documents folder.\n\n'...
            '\n'],mainhandles.workdir);
        
        h = myquestdlg(message,'iSMS permission denied','OK','OK');
        
        % Only show box once
        setappdata(0,'administratorMsgbox', 1)
        
    end
    ok = 0;
    
    % Turn attention back to figure
    figure(mainhandles.figure1)
    
end

end
