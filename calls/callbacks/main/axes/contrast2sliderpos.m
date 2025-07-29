function val = contrast2sliderpos(mainhandles,contrastVal,choice)
% Converts contrast intensity values to slider position
%
%    Input:
%     mainhandles   - handles structure of the main window
%     contrastVal   - contrast value [lower upper]
%     choice        - not used
%
%    Output:
%     val           - slider position value [left right]
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
file = get(mainhandles.FilesListbox,'Value');

% Scale
minmax = mainhandles.data(file).contrastLims;
logx = linspace(log10(minmax(1)),log10(minmax(2)),100);

% Convert
[~,idx1] = min(abs(logx-log10(contrastVal(1))));
[~,idx2] = min(abs(logx-log10(contrastVal(2))));

% Value
val = [idx1 idx2]/100;
