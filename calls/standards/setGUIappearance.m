function setGUIappearance(hfig,normfont)
% Initializes some GUI settings that makes it nicer
%
%    Input:
%     hfig     - figure handle
%     normfont - 0/1 whether to set font units to normalized
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

% Default
if nargin<2
    normfont = 0;
end

% Set color of GUI objects so that it matches background
% originalBGColor = get(textBoxHandles(1),'BackgroundColor'); % Store the original background color of the textbox
backgrColor = get(hfig,'Color'); % Background color
set(findobj(hfig, '-property', 'BackgroundColor',...
    '-not','BackgroundColor','white',...
    '-not','Color','white',...
    '-not','BackgroundColor','black',...
    '-not','Color','black',...
    '-not','-property','data',...
    '-not','-property','YColor'),...
    'BackgroundColor',backgrColor) % Set the background color of textboxes to the same as the figure background color

% Normalize font units of GUI object, so that it doesn't look weird on
% different monitors
if normfont
    MATLABversion = version('-release');
    if (str2num(MATLABversion(1:4))>=2012) % For some reason setting Panel font units to normalized causes matlab R2010 to crash
        set(findobj(hfig, '-property', 'FontUnits'),'FontUnits', 'normalized')
    else
        set(findobj(hfig, '-property', 'FontUnits', '-not','-property','BorderType'),'FontUnits', 'normalized')
    end
end
