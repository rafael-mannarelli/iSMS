function updateHistwindowGUImenus(mainhandles,hwHandles)
% Updates checkmarks etc. of gui menus in the histogramwindow
%
%    Input:
%     mainhandles            - handles structure of the main window
%     histogramwindowHandles - handles structure of the histogram window
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

%% View

set([hwHandles.View_Plotted_All hwHandles.View_Plotted_Prior1st...
    hwHandles.View_Plotted_Post1st hwHandles.View_Plotted_Prior2nd...
    hwHandles.View_Plotted_Post2nd hwHandles.View_Plotted_Donly...
    hwHandles.View_Plotted_Aonly hwHandles.View_Plotted_DAonly],...
    'checked','off')
if mainhandles.settings.SEplot.plotBleaching==1
    set(hwHandles.View_Plotted_All,'Checked','on')
elseif mainhandles.settings.SEplot.plotBleaching==2
    set(hwHandles.View_Plotted_Prior1st,'Checked','on')
elseif mainhandles.settings.SEplot.plotBleaching==3
    set(hwHandles.View_Plotted_Post1st,'Checked','on')    
elseif mainhandles.settings.SEplot.plotBleaching==4
    set(hwHandles.View_Plotted_Prior2nd,'Checked','on')
elseif mainhandles.settings.SEplot.plotBleaching==5
    set(hwHandles.View_Plotted_Post2nd,'Checked','on')
elseif mainhandles.settings.SEplot.plotBleaching==6
    set(hwHandles.View_Plotted_Donly,'Checked','on')
elseif mainhandles.settings.SEplot.plotBleaching==7
    set(hwHandles.View_Plotted_Aonly,'Checked','on')
elseif mainhandles.settings.SEplot.plotBleaching==8
    set(hwHandles.View_Plotted_DAonly,'Checked','on')
end

set([hwHandles.View_Values_All hwHandles.View_Values_Avg hwHandles.View_Values_Median],...
    'checked','off')
if mainhandles.settings.SEplot.valuesplotted==1
    set(hwHandles.View_Values_All,'checked','on')
elseif mainhandles.settings.SEplot.valuesplotted==2
    set(hwHandles.View_Values_Avg,'checked','on')
else
    set(hwHandles.View_Values_Median,'checked','on')
end

if mainhandles.settings.SEplot.excludeBlinking
    set(hwHandles.View_Plotted_All,'Label','All   (excl. blinking)')
    set(hwHandles.View_ExcludeBlinking,'Checked','on')
else
    set(hwHandles.View_Plotted_All,'Label','All')
    set(hwHandles.View_ExcludeBlinking,'Checked','off')
end

if mainhandles.settings.SEplot.inverseS
    set(hwHandles.View_PlotInverseS,'Checked','on')
else
    set(hwHandles.View_PlotInverseS,'Checked','off')
end

if mainhandles.settings.SEplot.showbins
    set([hwHandles.EbinsTextbox hwHandles.SbinsTextbox],'Visible','on')
else
    set([hwHandles.EbinsTextbox hwHandles.SbinsTextbox],'Visible','off')
end
if ~mainhandles.settings.excitation.alex
    set(hwHandles.SbinsTextbox,'Visible','off') % Is always turned on in sc
end

if isempty(mainhandles.settings.SEplot.lockEbinsize)
    set(hwHandles.View_lockEbinsize,'Checked','off')
else
    set(hwHandles.View_lockEbinsize,'Checked','on')
end
if isempty(mainhandles.settings.SEplot.lockSbinsize)
    set(hwHandles.View_lockSbinsize,'Checked','off')
else
    set(hwHandles.View_lockSbinsize,'Checked','on')
end

set([hwHandles.View_Type_RegScatter hwHandles.View_Type_DensScatter hwHandles.View_Type_DensImg], 'Checked','off')
if mainhandles.settings.SEplot.SEplotType==1
    set(hwHandles.View_Type_RegScatter,'Checked','on')
elseif mainhandles.settings.SEplot.SEplotType==2
    set(hwHandles.View_Type_DensScatter,'Checked','on')
elseif mainhandles.settings.SEplot.SEplotType==3
    set(hwHandles.View_Type_DensImg,'Checked','on')
end
