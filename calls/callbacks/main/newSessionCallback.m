function newSessionCallback(mainhandles)
% Callback for starting a new session
% 
%   Input:
%    mainhandles  - handles structure of the main window
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


if ~isdeployed
    % Initialize
    cd(mainhandles.workdir) % Change directory to working directory
    guiPosition = get(gcbf,'Position'); % Get the current position of the GUI
    close(gcbf); % Close the old GUI
    
    % Check if user pressed cancel
    if ~isempty(getappdata(0,'closeok'))
        return
    end
    
    % Open new GUI and set its position
    set(iSMS,'Position',guiPosition);

else
    % For the compiled version we cannot do the above
    
    % Ask to save
    if mainhandles.settings.close.asktosave && ~isempty(mainhandles.data)
        
        % Dialog
        choice = myquestdlg('Do you wish to save the current session before closing? ','Save session',...
            ' Yes ', ' No ', ' Cancel ', ' No ');
        
        if isempty(choice) || strcmpi(choice, ' Cancel ')
            setappdata(0,'closeok',1)
            return
            
        elseif strcmpi(choice,' Yes ')
            % Save session
            mainhandles = savesession(mainhandles.figure1);
        end
    end
    
    % Close windows
    mainhandles = closeWindows(mainhandles);
    
    % Settings
    settings = internalSettingsStructure(); % Initialize settings structure with internal values
    [mainhandles.settings, ok] = loadDefaultSettings(mainhandles, settings); % Load default settings from file
    % Settings that should not be changed:
    mainhandles.settings.view.ROIimage = 1; % Always start with an overlay plot in the ROI image
    mainhandles.settings.integration.type = 1; % Always start intensity trace calculation using aperture photometry
    mainhandles.settings.bin.lastpair = []; % No last binned pair
    
    % Data
    mainhandles.data = struct([]); % Data structure is defined and populated when loading data in storeMovie.m
    mainhandles = createNewGroup(mainhandles); % Initialize groups structure
    mainhandles.profiles = struct([]); % Laser spot profile structure is defined and populated when making the spot profiles
    
    % File, state and various
    mainhandles.filename = [];
    mainhandles.notes = '';
    mainhandles.state1 = [];
    mainhandles.state2 = [];
    
    % Load default ROIs from file. This will overwrite above settings
    mainhandles = loaddefaultROIs(mainhandles);
    
    % Initialize handles
    mainhandles = initobjectHandles(mainhandles);
    
    % Update peakfinder threshold editboxes
    mainhandles = updatePeakthresholdsEditbox(mainhandles,2);
    updatemainhandles(mainhandles)
    
    % Update
    updatefileslist(mainhandles.figure1);
    updateframeslist(mainhandles);
    mainhandles = filesListboxCallback([],[],mainhandles.figure1);
    updatecontrastSliders(mainhandles);
    
    % Initiate image axes
    set([mainhandles.rawimage mainhandles.ROIimage],'XTickLabel','','YTickLabel','','Color',[0 0 0])
    set([mainhandles.rawframesliderAxes mainhandles.ROIframesliderAxes mainhandles.rawcontrastSliderAx...
        mainhandles.redROIcontrastSliderAx mainhandles.greenROIcontrastSliderAx],...
        'XTick',[],'YTick',[],'Color','white')
end