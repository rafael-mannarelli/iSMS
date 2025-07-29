function setTracefigSize(fh,ax1,ax2)
% Adjusts size of exported trace figure to match appr. the dimensions of
% the parent plot
%
%    Input:
%     fh     - handle to new figure window
%     ax1    - new ax handle
%     ax2    - parent ax handle
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

s = getpixelposition(ax2);
s = [s(1:2) s(3)*1.5 s(4)*2];
setpixelposition(fh,s)
set(ax1,'units','normalized','outerposition',[0 0 0.95 0.95])
movegui(fh,'center')
