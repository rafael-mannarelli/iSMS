function updateFRETpairwindowGUImenus(mainhandles,FRETpairwindowHandles)
% Updates the checkmarks etc. of the FRETpairwindow GUI menus according to
% the settings structure
%
%    Input:
%     mainhandles  - handles structure of the main window
%     FRETpairwindowHandles - handles structure of the FRETpairwindow
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

updateCorrectionFactors(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
if mainhandles.settings.FRETpairplots.plotBackground==0
    set(FRETpairwindowHandles.View_BackgroundTraces,'Checked','off')
elseif mainhandles.settings.FRETpairplots.plotBackground==1
    set(FRETpairwindowHandles.View_BackgroundTraces,'Checked','on')
elseif mainhandles.settings.FRETpairplots.plotBackground==2
    set(FRETpairwindowHandles.View_BackgroundTraces,'Checked','on')
end

if mainhandles.settings.FRETpairplots.autozoom==1
    set(FRETpairwindowHandles.View_AutoZoom,'Checked','on')
else
    set(FRETpairwindowHandles.View_AutoZoom,'Checked','off')
end
if mainhandles.settings.FRETpairplots.logImage==1
    set(FRETpairwindowHandles.View_logImage,'Checked','on')
else
    set(FRETpairwindowHandles.View_logImage,'Checked','off')
end
if mainhandles.settings.FRETpairplots.frameSliders==1
    set(FRETpairwindowHandles.View_ImageSliders_Activate,'Checked','on')
    set(FRETpairwindowHandles.Toolbar_frameSliders,'State','on')
else
    set(FRETpairwindowHandles.View_ImageSliders_Activate,'Checked','off')
    set(FRETpairwindowHandles.Toolbar_frameSliders,'State','off')
end
if mainhandles.settings.FRETpairplots.linkFrameSliders==1
    set(FRETpairwindowHandles.View_ImageSliders_Link,'Checked','on')
else
    set(FRETpairwindowHandles.View_ImageSliders_Link,'Checked','off')
end

if mainhandles.settings.FRETpairplots.avgFRET==1
    set(FRETpairwindowHandles.View_avgFRET,'Checked','on')
else
    set(FRETpairwindowHandles.View_avgFRET,'Checked','off')
end

if mainhandles.settings.FRETpairplots.liveupdateTrace
    set(FRETpairwindowHandles.View_liveupdateTrace,'Checked','on')
else
    set(FRETpairwindowHandles.View_liveupdateTrace,'Checked','off')
end

set([FRETpairwindowHandles.View_DtraceMenu_gamma FRETpairwindowHandles.View_DtraceMenu_Raw],'checked','off')
if mainhandles.settings.FRETpairplots.plotDgamma
    set(FRETpairwindowHandles.View_DtraceMenu_gamma,'checked','on')
else
    set(FRETpairwindowHandles.View_DtraceMenu_Raw,'checked','on')
end
set([FRETpairwindowHandles.View_AtraceMenu_ADcorr FRETpairwindowHandles.View_AtraceMenu_Raw],'checked','off')
if mainhandles.settings.FRETpairplots.plotADcorr
    set(FRETpairwindowHandles.View_AtraceMenu_ADcorr,'checked','on')
else
    set(FRETpairwindowHandles.View_AtraceMenu_Raw,'checked','on')
end

%% Settings

if mainhandles.settings.corrections.FRETmethod
    set(FRETpairwindowHandles.Settings_FRETmethod,'Checked','on')
else
    set(FRETpairwindowHandles.Settings_FRETmethod,'Checked','off')
end

%% Sort molecules choice

set([FRETpairwindowHandles.Sort_File...
    FRETpairwindowHandles.Sort_Group...
    FRETpairwindowHandles.Sort_avgE...
    FRETpairwindowHandles.Sort_avgS...
    FRETpairwindowHandles.Sort_maxDAsum...
    FRETpairwindowHandles.Sort_maxDD...
    FRETpairwindowHandles.Sort_maxAD...
    FRETpairwindowHandles.Sort_maxAA...
    ], 'Checked','off')
if mainhandles.settings.FRETpairplots.sortpairs==1
    set(FRETpairwindowHandles.Sort_File, 'Checked','on')
    
elseif mainhandles.settings.FRETpairplots.sortpairs==2
    set(FRETpairwindowHandles.Sort_Group, 'Checked','on')
    
elseif mainhandles.settings.FRETpairplots.sortpairs==3
    set(FRETpairwindowHandles.Sort_avgE, 'Checked','on')
    
elseif mainhandles.settings.FRETpairplots.sortpairs==4
    set(FRETpairwindowHandles.Sort_avgS, 'Checked','on')
    
elseif mainhandles.settings.FRETpairplots.sortpairs==5
    set(FRETpairwindowHandles.Sort_maxDAsum, 'Checked','on')
    
elseif mainhandles.settings.FRETpairplots.sortpairs==6
    set(FRETpairwindowHandles.Sort_maxDD, 'Checked','on')
    
elseif mainhandles.settings.FRETpairplots.sortpairs==7
    set(FRETpairwindowHandles.Sort_maxAD, 'Checked','on')
    
elseif mainhandles.settings.FRETpairplots.sortpairs==8
    set(FRETpairwindowHandles.Sort_maxAA, 'Checked','on')
end

if mainhandles.settings.bin.open
    set(FRETpairwindowHandles.Bin_open,'Checked','on')
else
    set(FRETpairwindowHandles.Bin_open,'Checked','off')
end

%% Recycle bin menu label

updateFRETpairbinCounter(mainhandles.figure1, FRETpairwindowHandles.figure1)

%% Grouping 2

if mainhandles.settings.grouping.removefromPrevious
    set(FRETpairwindowHandles.Grouping_RemoveFromPrevious,'Checked','on')
else
    set(FRETpairwindowHandles.Grouping_RemoveFromPrevious,'Checked','off')
end
