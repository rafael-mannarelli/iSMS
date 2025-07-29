function turnoffDeployed(mainhandles, fpwHandle, hwHandle, cfwHandle, dwHandle, ...
    pflwHandle, ...
    drftwHandle, ...
    intwHandle, ...
    psfwHandle)
% Turns off some features and menus for the deployed version
%
%    Input:
%     mainhandles   - handles structure of the main window
%     fpwHandle     - handle to the FRET pair window
%     hwHandle      - handle to the histogram window
%     cfwHandle     - handle to the correction factor window
%     dwHandle      - handle to the dynamics window
%     pflwHandle    - handle to the spot profile window
%     drftwHandle   - handle to the drift correction window
%     intwHandle    - handle to the integration settings window
%     psfwHandle    - handle to the PSF /TFM window
%     dvslwHandle   - handle to the data visualizer window
%     dlclwHandle   - handle to the data localizer window
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

% Return if MATLAB version
if ~isdeployed
    return
end

% Default
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
if nargin<6 || isempty(pflwHandle)
    pflwHandle = mainhandles.profilewindowHandle;
end
if nargin<7 || isempty(drftwHandle)
    drftwHandle = mainhandles.driftwindowHandle;
end
if nargin<8 || isempty(intwHandle)
    intwHandle = mainhandles.integrationwindowHandle;
end
if nargin<9 || isempty(psfwHandle)
    psfwHandle = mainhandles.psfwindowHandle;
end

%% Main window

turnoffMenu([mainhandles.Help_DevelopersMenu mainhandles.File_ImportMovieWorkspace...
    mainhandles.File_Export_Workspace])

%% FRETpair window

if ~isempty(fpwHandle) && ishandle(fpwHandle)
    fpwHandles = guidata(fpwHandle);
    turnoffMenu([fpwHandles.Help_mfile fpwHandles.Help_figfile...
        fpwHandles.Help_updatefcn fpwHandles.Export_Workspace])
end

%% Histogram window

if ~isempty(hwHandle) && ishandle(hwHandle)
    hwHandles = guidata(hwHandle);
    turnoffMenu([hwHandles.Help_mfile hwHandles.Help_figfile...
        hwHandles.Help_updateplotfcn hwHandles.Export_Workspace])
end

%% Correction factor window

if ~isempty(cfwHandle) && ishandle(cfwHandle)
    cfwHandles = guidata(cfwHandle);
    turnoffMenu([cfwHandles.Help_mfile cfwHandles.Help_figfile...
        cfwHandles.Help_updateplotfcn cfwHandles.Help_correctioncalcfile...
        cfwHandles.Help_correctingtracesfcn cfwHandles.Export_Workspace])
end

%% Dynamics window

if ~isempty(dwHandle) && ishandle(dwHandle)
    dwHandles = guidata(dwHandle);
    turnoffMenu([dwHandles.Help_mfile dwHandles.Help_figfile...
        dwHandles.Help_gridflexfile dwHandles.Help_updateplotfcn...
        dwHandles.Help_vbfretfile dwHandles.Export_Workspace])
end

%% Profile window

if ~isempty(pflwHandle) && ishandle(pflwHandle)
    pwHandles = guidata(pflwHandle);
    turnoffMenu([pwHandles.Help_mfile pwHandles.Help_figfile...
        pwHandles.Help_handles])
end

%% Drift window

if ~isempty(drftwHandle) && ishandle(drftwHandle)
    drftwHandles = guidata(drftwHandle);
    turnoffMenu([drftwHandles.Help_mfile drftwHandles.Help_figfile...
        drftwHandles.Help_updateplotfcn drftwHandles.Help_driftanalysis...
        drftwHandles.Help_driftcompensationfile])
end

%% Integration window

if ~isempty(intwHandle) && ishandle(intwHandle)
    intwHandles = guidata(intwHandle);
    turnoffMenu([intwHandles.Help_mfile intwHandles.Help_figfile...
        intwHandles.Help_plotfcn intwHandles.Help_integrationfcn])
end

%% PSF / TFM window

if ~isempty(psfwHandle) && ishandle(psfwHandle)
    psfwHandles = guidata(psfwHandle);
    turnoffMenu([psfwHandles.Help_mfile psfwHandles.Help_figfile])
end

%% Data visualizer window

if ~isempty(dvslwHandle) && ishandle(dvslwHandle)
    dvslwHandles = guidata(dvslwHandle);
    turnoffMenu([dvslwHandles.Help_mfile dvslwHandles.Help_figfile...
        dvslwHandles.Menu_HandletoWorkspace])
end

%% Data localizer window

if ~isempty(dlclwHandle) && ishandle(dlclwHandle)
    dlclwHandles = guidata(dlclwHandle);
    turnoffMenu([dlclwHandles.Help_mfile dlclwHandles.Help_figfile...
        dlclwHandles.Menu_Help_Send])
end

%% Nested

    function turnoffMenu(hs)
        for i = 1:length(hs)
            h = hs(i);
            
            if strcmpi(get(h,'enable'),'on')
                s = get(h,'Label');
                set(h,...
                    'Enable','Off',...
                    'Label', sprintf('%s (only MATLAB version)',s))
            end
        end
    end

end