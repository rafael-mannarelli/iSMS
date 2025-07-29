function mainhandles = loaddefaultROIs(mainhandles)
% Loads the default ROI positions from file upon startup
%
%    Input:
%     handles   - handles structure of the main window
%
%    Output:
%     handles   - ..
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

try 
    % Open default ROIs from file
    defaultROIsFile = fullfile(mainhandles.settingsdir,'default.rois');
    temp = load(defaultROIsFile,'-mat');
    if myIsField(temp,'ROIs')
        % Load ROIs
        mainhandles.settings.ROIs = temp.ROIs;
        
    else
        set(mainhandles.mboard,'String',sprintf(...
            'OBS!\n The default ROI position file does not contain a ROIs structure (%s).\nPlease make a new default ROIs file from the File menu.',...
            defaultROIsFile))
    end
    
catch err
    
    % Save new default ROIs
    try
        defaultROIsFile = fullfile(mainhandles.settingsdir,'default.rois');
        ROIs = mainhandles.settings.ROIs;
        save(defaultROIsFile,'ROIs');
    catch err
        try set(mainhandles.mboard,'String',sprintf('Error when trying to create a default ROIs file: %s',err.message)), end
    end
end
