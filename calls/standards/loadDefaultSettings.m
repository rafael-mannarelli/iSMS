function [settings_default ok] = loadDefaultSettings(mainhandles, settings_internal)
% Attempts to load the default settings structure from a stored .settings
% file located at workdir/calls/settings/default.settings. The
% fields of the loaded settings structure (i.e. the defaults) will replace
% the corresponding fields in the settings_internal structure. If there is
% no default settings file a new one is created.
%
%     Input:
%      handles           - handles structure of the main window
%      settings_internal - the internal settings structure which is defined
%                          initially within the program
%
%     Output:
%      settings_default  - new settings structure with field values defined
%                          in the default settings file
%      ok                - 0/1 whether disk write was successful
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

% Default
settings_default = settings_internal;
ok = 1;

% Filepath
filepath = fullfile(mainhandles.settingsdir,'default.settings');

% Load settings structure from file
[settings_default message err] = loadSettings(settings_internal, filepath);

% Display message in message board
if ~isempty(message)
    % Use try because it may not have been created yet
    try set(mainhandles.mboard, 'String',message), end
end

% Display message about error and try resaving default settings file
if ~isempty(err)
    
    % If it was because the defaults-file was not found try to make a new
    if strcmp(err.identifier,'MATLAB:load:couldNotReadFile')
        
        % Save file with settings structure
        ok = saveSettings(mainhandles, settings_internal, filepath);
        
        % Display message
        try
            set(mainhandles.mboard,'String',sprintf(...
                'OBS! A new default settings file has been created at: %s.',...
                filepath))
        end
    else
        if isdeployed
            set(mainhandles.mboard,'String',message)
        else
            mymsgbox(message)
        end
        
    end
end
