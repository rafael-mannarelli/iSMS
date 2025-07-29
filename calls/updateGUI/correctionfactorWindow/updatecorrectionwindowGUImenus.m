function updatecorrectionwindowGUImenus(cwHandles)
% Updates the GUI menu checkmarks in the correction factor window
%
%    Input:
%     cwHandles   - handles structure of the correction factor window
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
mainhandles = getmainhandles(cwHandles);

%% View menu

set([cwHandles.View_Axes4_S cwHandles.View_Axes4_E cwHandles.View_Axes4_C], 'Checked','off')
if mainhandles.settings.correctionfactorplot.ax4==1
    set(cwHandles.View_Axes4_C, 'Checked','on')    
elseif mainhandles.settings.correctionfactorplot.ax4==2
    set(cwHandles.View_Axes4_S, 'Checked','on')    
elseif mainhandles.settings.correctionfactorplot.ax4==3
    set(cwHandles.View_Axes4_E, 'Checked','on')
end

if mainhandles.settings.correctionfactorplot.plotfactorvalue
    set(cwHandles.View_Axes4_plotfactor,'checked','on')
else
    set(cwHandles.View_Axes4_plotfactor,'checked','off')
end

set([cwHandles.View_Correction_Histogram cwHandles.View_Correction_FRET cwHandles.View_Correction_Coordinate],...
    'Checked','off')
if mainhandles.settings.correctionfactorplot.histogramplot==1
    set(cwHandles.View_Correction_Histogram,'Checked','on')
elseif mainhandles.settings.correctionfactorplot.histogramplot==2
    set(cwHandles.View_Correction_FRET,'Checked','on')
else
    set(cwHandles.View_Correction_Coordinate,'Checked','on')
end

%% Sort menu

set([cwHandles.Sort_file cwHandles.Sort_value cwHandles.Sort_var cwHandles.Sort_group cwHandles.Sort_E cwHandles.Sort_S],...
    'Checked','off')
if mainhandles.settings.correctionfactorplot.sortpairs==1
    set(cwHandles.Sort_file,'Checked','on')
elseif mainhandles.settings.correctionfactorplot.sortpairs==2
    set(cwHandles.Sort_value,'Checked','on')
elseif mainhandles.settings.correctionfactorplot.sortpairs==3
    set(cwHandles.Sort_group,'Checked','on')
elseif mainhandles.settings.correctionfactorplot.sortpairs==4
    set(cwHandles.Sort_E,'Checked','on')
elseif mainhandles.settings.correctionfactorplot.sortpairs==5
    set(cwHandles.Sort_S,'Checked','on')
elseif mainhandles.settings.correctionfactorplot.sortpairs==6
    set(cwHandles.Sort_var,'Checked','on')
end

%% Settings menu

set([cwHandles.Settings_IntensityMenu_Median cwHandles.Settings_IntensityMenu_Mean...
    cwHandles.Settings_GlobalMenu_Mean cwHandles.Settings_GlobalMenu_Median cwHandles.Settings_GlobalMenu_WeightedMean], ...
    'checked','off')

% Intensity
if mainhandles.settings.corrections.medianI
    set(cwHandles.Settings_IntensityMenu_Median,'checked','on')
else
    set(cwHandles.Settings_IntensityMenu_Mean,'checked','on')
end

% Global average
if mainhandles.settings.corrections.globalavgChoice==1
    set(cwHandles.Settings_GlobalMenu_Mean,'checked','on')
elseif mainhandles.settings.corrections.globalavgChoice==2
    set(cwHandles.Settings_GlobalMenu_WeightedMean,'checked','on')
elseif mainhandles.settings.corrections.globalavgChoice==3
    set(cwHandles.Settings_GlobalMenu_Median,'checked','on')
end
