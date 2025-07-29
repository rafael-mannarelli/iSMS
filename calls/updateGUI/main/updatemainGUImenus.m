function updatemainGUImenus(mainhandles)
% Updates check marks etc. of the menu items in the main window
%
%     Input:
%      mainhandles   - handles structure of the main window
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

%% Startup

if mainhandles.settings.startup.checkforUpdates
    set(mainhandles.Help_CheckForUpdatesStartup, 'Checked','on')
else
    set(mainhandles.Help_CheckForUpdatesStartup, 'Checked','off')
end

%% View menu

if mainhandles.settings.view.rawlogscale
    set(mainhandles.View_rawlogscale,'checked','on')
else
    set(mainhandles.View_rawlogscale,'checked','off')
end
if mainhandles.settings.view.ROIsqrt
    set(mainhandles.View_ROIsqrt,'Checked','on')
else
    set(mainhandles.View_ROIsqrt,'Checked','off')
end
if mainhandles.settings.view.ROIgreen
    set(mainhandles.View_ROIchannel_Green,'Checked','on')
else
    set(mainhandles.View_ROIchannel_Green,'Checked','off')
end
if mainhandles.settings.view.ROIred
    set(mainhandles.View_ROIchannel_Red,'Checked','on')
else
    set(mainhandles.View_ROIchannel_Red,'Checked','off')
end
if mainhandles.settings.view.colorblind
    set(mainhandles.View_Colorblind,'Checked','on')
    set(mainhandles.View_ROIchannel_Green,'Label','Blue channel (donor)')
    set(mainhandles.View_ROIchannel_Red,'Label','Yellow channel (acceptor)')
else
    set(mainhandles.View_Colorblind,'Checked','off')
    set(mainhandles.View_ROIchannel_Green,'Label','Green channel (donor)')
    set(mainhandles.View_ROIchannel_Red,'Label','Red channel (acceptor)')
end
if mainhandles.settings.view.rotate
    set(mainhandles.View_Rotate,'Checked','on')
else
    set(mainhandles.View_Rotate,'Checked','off')
end
if mainhandles.settings.view.flipud
    set(mainhandles.View_FlipVer,'Checked','on')
else
    set(mainhandles.View_FlipVer,'Checked','off')
end
if mainhandles.settings.view.fliplr
    set(mainhandles.View_FlipHor,'Checked','on')
else
    set(mainhandles.View_FlipHor,'Checked','off')
end
set([mainhandles.View_RawColormap_Gray mainhandles.View_RawColormap_Jet],'Checked','off')
if strcmpi(mainhandles.settings.view.rawcolormap,'gray')
    set(mainhandles.View_RawColormap_Gray,'Checked','on')
else
    set(mainhandles.View_RawColormap_Jet,'Checked','on')
end
if mainhandles.settings.view.contrastsliders
    set(mainhandles.View_ContrastSliders,'Checked','on')
else
    set(mainhandles.View_ContrastSliders,'Checked','off')
end
if mainhandles.settings.view.framesliders
    set(mainhandles.View_FrameSliders,'Checked','on')
else
    set(mainhandles.View_FrameSliders,'Checked','off')
end

%% Settings menu

set([mainhandles.Settings_ExcScheme_ALEX mainhandles.Settings_ExcScheme_Single],'checked','off')
if mainhandles.settings.excitation.alex
    set(mainhandles.Settings_ExcScheme_ALEX,'checked','on')
else
    set(mainhandles.Settings_ExcScheme_Single,'checked','on')
end
if mainhandles.settings.settings.askdefault
    set(mainhandles.Settings_AskDefault,'checked','on')
else
    set(mainhandles.Settings_AskDefault,'checked','off')
end

%% Performance menu

if mainhandles.settings.performance.parallel
    set(mainhandles.Performance_Parallel_Choice,'Checked','on')
else
    set(mainhandles.Performance_Parallel_Choice,'Checked','off')
end

%% Help menu

if mainhandles.settings.startup.checkforUpdates
    set(mainhandles.Help_CheckForUpdatesStartup,'Checked','on')
else
    set(mainhandles.Help_CheckForUpdatesStartup,'Checked','off')
end
