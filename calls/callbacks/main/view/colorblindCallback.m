function mainhandles = colorblindCallback(mainhandles)
% Callback for turning on/off colorblindness in the main window view menu
%
%    Input:
%     mainhandles   - handles structure of the main window
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

% New settings
mainhandles.settings.view.colorblind = abs(mainhandles.settings.view.colorblind-1);

% Update mainhandles structure and GUI menus
updatemainhandles(mainhandles)
updatemainGUImenus(mainhandles)

% Clear peaks
h = findobj(mainhandles.ROIimage,'Marker','o');
delete(h)
mainhandles.DpeaksHandle = [];
mainhandles.ApeaksHandle = [];
mainhandles.EpeaksHandle = [];

% Update image
mainhandles = updateROIimage(mainhandles,0,0,0);
mainhandles = updatepeakplot(mainhandles,[],0,0);

% Set contrast histogram colors
h1 = findobj(mainhandles.greenROIcontrastSliderAx,'-property','BarWidth');
h2 = findobj(mainhandles.redROIcontrastSliderAx,'-property','BarWidth');
if ~isempty(h1) && ~isempty(h2)
    if mainhandles.settings.view.colorblind
        set(h1,'edgecolor','g','facecolor','g') % Color
        set(h2,'edgecolor','m','facecolor','m') % Color
    else
        set(h1,'edgecolor','g','facecolor','g') % Color
        set(h2,'edgecolor','r','facecolor','r') % Color
    end
end

% Update ROIs
if mainhandles.settings.view.colorblind
    setColor(mainhandles.DROIhandle,'green')%'blue')
    setColor(mainhandles.AROIhandle,'magenta')%'yellow')
else
    setColor(mainhandles.DROIhandle,'green')
    setColor(mainhandles.AROIhandle,'red')
end

% Save as default
mainhandles = savesettingasDefaultDlg(mainhandles,'view','colorblind',mainhandles.settings.view.colorblind);
