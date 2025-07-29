function handles = initobjectHandles(handles)
% Initializes all fields for object handles, such as sub gui windows
%
%    Input:
%     handles    - handles structure of the main window
%
%    Output:
%     handles    - ..
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

%% Various handles

handles.DROIhandle = []; % Handle to the D ROI in the global window
handles.AROIhandle = []; % Handle to the A ROI in the global window
handles.zoomwindowHandle = []; % Handle to the zoom window
handles.zoomwindowSPHandle = []; % Handle to the scroll panel used by the zoom tool
handles.imoverviewpanelHandle = []; % Handle to an image overview panel created for the zoom tool
handles.impixelregionWindowHandle = []; % Handle to the inspect pixel values window
handles.liveROIhandle = []; % Handle to a ROI integration sphere with live update-feature
handles.adjustROIswindowHandle = []; % Handle to the fine-adjust ROIs window
handles.ROIimageHandle = []; % Handle to the ROI image
handles.ROIframesliderHandle = []; % Handle to the raw frame slider
handles.greenROIcontrastSliderHandle = []; % Handle to the frame slider
handles.redROIcontrastSliderHandle = []; % Handle to the frame slider
handles.rawImageHandle = []; % Handle to the raw image
handles.rawframesliderHandle = []; % Handle to the raw frame slider
handles.rawcontrastSliderHandle = []; % Handle to the imrect raw contrast slider in the main window
handles.DpeaksHandle = []; % Handle to the green peaks scatter in the ROI image
handles.ApeaksHandle = []; % Handle to the red peaks scatter in the ROI image
handles.EpeaksHandle = []; % Handle to the yellow peaks scatter in the ROI image
handles.EpeaksLabelHandle = []; % Handle to the FRET pair text labels on the ROIimage

%% Window handles

handles.FRETpairwindowHandle = []; % Handle to the FRETpair window
handles.histogramwindowHandle = []; % Handle to the S-E histogram plot window
handles.dynamicswindowHandle = []; % Handle to the dynamics analysis window
handles.correctionfactorwindowHandle = []; % Handle to the correction factor window
handles.profilewindowHandle = []; % Handle to the laser profile editor
handles.driftwindowHandle = []; % Handle to the drift analysis window
handles.integrationwindowHandle = []; % Handle to the window comparing photon counting methods
handles.psfwindowHandle = []; % Handle to the window plotting Gaussian PSF parameters
handles.notebookHandle = []; % Handle to the notebook window

handles.GaussianComponentsWindowHandle = []; % Handle to the table displaying information on the fitted Gaussian components of the SE plot
handles.liveROIwindowHandle = []; % Handle to the plot window associated with the live-ROI
handles.autoROIimageHandle = []; % Handle to the plot of peaks used for automated ROI alignment
handles.plotmovietracesHandle = []; % Handle to the window with plot of total image intensities
handles.figures = cell(1); handles.figures(1) = []; % Various external figure handles

%% GUI object handles

handles.recentsessionsMenu = []; % Handle to the recent session files menu in the file menu of the main window
handles.recentmoviesMenu = []; % Handle to the recent movie files menu in the file menu of the main window
