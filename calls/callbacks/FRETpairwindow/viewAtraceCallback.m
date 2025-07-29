function [fpwHandles, mainhandles] = viewAtraceCallback(fpwHandles,choice,field)
% Callback for selecting which AD trace to plot in FRETpairwindow
%
%    Input:
%     fpwHandles  - handles structure of the FRETpairwindow
%     choice      - 0/1
%     field       - 'plotDgamma': D trace setting. 'plotADcorr': A trace
%    
%    Output:
%     fpwHandles   - ... 
%     mainhandles  - handles structure of the main window
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

% Get mainhandles
mainhandles = getmainhandles(fpwHandles);
if isempty(mainhandles) || isequal(mainhandles.settings.FRETpairplots.(field),choice)
    return
end

%% Update settings

mainhandles.settings.FRETpairplots.(field) = choice;
updatemainhandles(mainhandles)

%% Update GUI menu checkmark

updateFRETpairwindowGUImenus(mainhandles,fpwHandles)

%% Update plot

[fpwHandles,mainhandles] = updateFRETpairplots(mainhandles.figure1,fpwHandles.figure1);
