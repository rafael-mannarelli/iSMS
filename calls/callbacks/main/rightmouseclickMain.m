function rightmouseclickMain(mainhandles) 
% Imitates a right-mousebutton click in main window ROI image
%
%    Input:
%     mainhandles   - handles structure of the main window
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

mpos = get(0,'PointerLocation'); % Detect cursor position in pixels
figpos = getpixelposition(mainhandles.figure1); % Screen position of GUI in pixels
imagepos = getpixelposition(mainhandles.ROIimage); % Position of ROI image in pixels relative to GUI
inputemu('move',figpos([1 2]) + imagepos([1 2]) + [25 25]); % Move cursor back to original position

import java.awt.Robot;
import java.awt.event.*;
mouse = Robot;
mouse.mouseRelease(InputEvent.BUTTON3_MASK);

% inputemu('normal',figpos([1 2]) + imagepos([1 2])) % Move mouse into ROI image axes and emulate mouse press
% inputemu('move',mpos); % Move cursor back to original position

