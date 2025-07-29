function mainhandles = updatePublic(mainhandles,fpwHandle,hwHandle,cfwHandle,dwHandle)
% Updates GUI depending on whether software is for internal or public use.
%
%    Input:
%     mainhandles  - handles structure of the main window
%     fpwHandle    - handle to the FRETpair window
%     hwHandle     - handle to the histogramwindow
%     cfwHandle    - handle to the correction factor window
%     dwHandle     - handle to the dynamics window
%
%    Output:
%     mainhandles   - ..
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

% Defaults
if nargin<2 || isempty(fpwHandle)
    fpwHandle = mainhandles.FRETpairwindowHandle;
end
if nargin<3 || isempty(hwHandle)
    hwHandle = mainhandles.histogramwindowHandle;
end
if nargin<4 || isempty(cfwHandle)
    cfwHandle = mainhandles.correctionfactorwindowHandle;
end
if nargin<5 || isempty(dwHandle)
    dwHandle = mainhandles.dynamicswindowHandle;
end

% Get handles structures
fpwHandles = [];
hwHandles = [];
cfwHandles = [];
dwHandles = [];
if ~isempty(fpwHandle) && ishandle(fpwHandle)
    fpwHandles = guidata(fpwHandle);
end
if ~isempty(hwHandle) && ishandle(hwHandle)
    hwHandles = guidata(hwHandle);
end
if ~isempty(cfwHandle) && ishandle(cfwHandle)
    cfwHandles = guidata(cfwHandle);
end
if ~isempty(dwHandle) && ishandle(dwHandle)
    dwHandles = guidata(dwHandle);
end

% Public version or not
ispublic = mainhandles.ispublic;

%% Update settings

if ispublic
    
    % Settings
    mainhandles.settings.background.backtype = 1; % Mean background
    mainhandles.settings.corrections.medianI = 0; % Mean intensities
    mainhandles.settings.corrections.globalavgChoice = 1; % Global avg is mean
    mainhandles.settings.corrections.FRETmethod = 0; % Always ratiometric method
    
    % Update handles
    updatemainhandles(mainhandles)
    
end

%% Update main window

% Handles to all internal items
h = [mainhandles.Tools_SpotProfile mainhandles.Settings_LaserSpotProfiles...
    mainhandles.Tools_Windows_SpotProfiles...
    mainhandles.Tools_Windows_TFM];

% Turn on/off
if ispublic
    set(h,'Visible','off')
else
    set(h,'Visible','on')
end

%% Update FRETpair window

if ~isempty(fpwHandles)
    
    % Handles to all non-public menus
    h = [fpwHandles.Tools_CheckBack fpwHandles.Tools_CheckDynamics...
        fpwHandles.Plot_CoordinateCorrelation...
        fpwHandles.Settings_FRETmethod];
%      fpwHandles.Plot_AperturePlot fpwHandles.Plot_Percentile 
    % Turn on/off
    if ispublic
        set(h,'Visible','off')
    else
        set(h,'Visible','on')
    end
end

%% Update histogram window

if ~isempty(hwHandles)
    
    % Handles to all unpublic menus
    h = [];
    
    % Turn on/off
    if ispublic
        set(h,'Visible','off')
        
    else
        set(h,'Visible','on')
        
    end
    
end

%% Update correction factor window

if ~isempty(cfwHandles)
    
    % Handles to all unpublic menus
    h = [cfwHandles.View_Correction_Coordinate ...
        cfwHandles.Settings_IntensityMenu cfwHandles.Settings_GlobalValueMenu];
    
    % Turn on/off
    if ispublic
        set(h,'Visible','off')
        
    else
        set(h,'Visible','on')
        
    end
    
end

%% Update dynamics window


if ~isempty(dwHandles)
    
    % Handles to all unpublic menus
    h = [dwHandles.Settings_DSplotTimefilter];
    
    % Turn on/off
    if ispublic
        set(h,'Visible','off')
        
    else
        set(h,'Visible','on')
        
    end
    
end