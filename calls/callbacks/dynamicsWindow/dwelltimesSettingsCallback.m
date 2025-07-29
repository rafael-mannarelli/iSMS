function mainhandles = dwelltimesSettingsCallback(dwHandles)
% Callback for setting dwell time options in the dynamics window
%
%   Input:
%    dwHandles    - handles structure of the dynamics window
%
%   Output:
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

%% Initialize
mainhandles = getmainhandles(dwHandles);
if isempty(mainhandles)
    return
end

%% Dialog

name = 'Dwell time settings';
prompt = {'Dwell times cut by bleaching do not report on conformational states but rather fluorophore photophysics. ' '';...
    'Include dwell times cut by bleaching or blinking' 'includeEnds';...
    'Color of cut dwell times in dwell-time plots' 'colorEnds'};

formats = prepareformats();

formats(1,1).type = 'text';
formats(4,1).type = 'check';
formats(5,1).type = 'list';
formats(5,1).style = 'popupmenu';
formats(5,1).items = {'Same as all other';'Red';'Green';'Blue'};

DefAns.includeEnds = mainhandles.settings.dynamicsplot.includeEnds;
DefAns.colorEnds = mainhandles.settings.dynamicsplot.colorEnds;

[answer, cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled || isequal(DefAns,answer)
    return
end

%% Update settings and plot

% Settings
mainhandles.settings.dynamicsplot.includeEnds = answer.includeEnds;
mainhandles.settings.dynamicsplot.colorEnds = answer.colorEnds;
updatemainhandles(mainhandles)

% Update plot
updateDynamicsPlot(mainhandles.figure1,dwHandles.figure1,'hist')
