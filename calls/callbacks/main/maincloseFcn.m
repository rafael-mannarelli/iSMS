function maincloseFcn(hObject, mainhandles)
% Runs when the software is closed
%
%    Input:
%     hObject       - handle to the main window
%     mainhandles   - handles structure of the main window
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

%% Save dialog

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

%% Aims to delete all data and handles used by the program before closing

% Delete splash screen created by the main function (which is run before
% closing GUI)
try % Delete splash screen
    splashScreenHandle = getappdata(0,'smsSplashHandle');
    if ~isempty(splashScreenHandle) && isvalid(splashScreenHandle)
        try delete(splashScreenHandle), end
        rmappdata(0,'smsSplashHandle')
    end
end

% Delete opened windows:
try delete(mainhandles.FRETpairwindowHandle), end % Handle to the FRET pair GUI window
try delete(mainhandles.histogramwindowHandle), end % Handle to the histogram plot window
try delete(mainhandles.dynamicswindowHandle), end % Handle to the histogram plot window
try delete(mainhandles.correctionfactorwindowHandle), end % Handle to the histogram plot window
try delete(mainhandles.driftwindowHandle), end % Handle to the drift plot window
try delete(mainhandles.GaussianComponentsWindowHandle), end % Handle to the table displaying information on the fitted Gaussian components of the SE plot
try delete(mainhandles.profilewindowHandle), end % Handle to the laser profile editor
try delete(mainhandles.integrationwindowHandle), end % Handle to the window comparing photon counting methods
try delete(mainhandles.psfwindowHandle), end % Handle to the window comparing photon counting methods
try delete(mainhandles.notebookHandle), end % Handle to the notebook
try delete(mainhandles.liveROIwindowHandle), end % Handle to the plot window associated with the live-ROI
try delete(mainhandles.autoROIimageHandle), end % Handle to the plot of peaks used for automated ROI alignment
try delete(mainhandles.plotmovietracesHandle), end, % Handle to the figure with total image intensities (opened when opening averaging settings)
try delete(mainhandles.adjustROIswindowHandle), end, % Handle to fine-tune ROIs

% Delete undocked panels
try % mboard
    if isvalid( mainhandles.mboardBoxPanel ) && ~strcmpi( mainhandles.mboardBoxPanel.BeingDeleted, 'on' ) && ~mainhandles.mboardBoxPanel.IsDocked
        delete( ancestor( mainhandles.mboardBoxPanel, 'figure' ) );
    end
end
try % Peakfinder panel
    if isvalid( mainhandles.peakfinderBoxPanel ) && ~strcmpi( mainhandles.peakfinderBoxPanel.BeingDeleted, 'on' ) && ~mainhandles.peakfinderBoxPanel.IsDocked
        delete( ancestor( mainhandles.peakfinderBoxPanel, 'figure' ) );
    end
end

% Close external figure windows
for i = 1:length(mainhandles.figures)
    try delete(mainhandles.figures{i}), end
end

% Delete ROI handles
try if ishandle(mainhandles.DROIhandle)
        delete(mainhandles.DROIhandle), end, end % Handle to the donor ROI in the global image (left)
try if ishandle(mainhandles.AROIhandle)
        delete(mainhandles.AROIhandle), end, end % Handle to the acceptor ROI in the global image (left)
try if ishandle(mainhandles.liveROIhandle)
        delete(mainhandles.liveROIhandle), end, end % Handle to the live ROI

%% System defaults
try
    if mainhandles.matver>8.3
        set(0,'DefaultAxesLabelFontSizeMultiplier',1.1) % Set back previous font sizes (introduced in R2014b with default 1.1)
    end
end

%% Clear the handles structure (data, settings, etc.):
try cla(mainhandles.rawimage), end
try cla(mainhandles.ROIimage), end
try mainhandles = []; end
try mainhandles.figure1 = hObject; end
try guidata(hObject,mainhandles), end

%% Close GUI
try delete(hObject); end

%% Remove search paths:
workdir = getappdata(0,'workdirSMS');
if ~isempty(workdir)
    warning off
    try rmpath(genpath(fullfile(workdir,'calls'))), end % Removes the calls subdirectory and its subfolders
    try rmpath(workdir), end % Removes the installation directory
    try addpath(genpath(fullfile(workdir,'calls','GUILayout-v1p14'))), end
    warning on
end

% Remove appdata:
try rmappdata(0,'mainhandles'), end
try rmappdata(0,'mainhandle'), end
try rmappdata(0,'workdirSMS'),end
% try rmappdata(0,'versionSMS'), end
try rmappdata(0,'smsSplashHandle'),end % Remove splashScreen handle
try rmappdata(0,'smsSplashCounter'),end % Remove splashScreen progressbar counter
try rmappdata(0,'hInvisibleAxes'),end
try rmappdata(0,'stopselectdata'),end
try rmappdata(0,'closeok'), end
try rmappdata(0,'iSMSstarted'), end

