function val = sliderpos2contrast(mainhandles,pos,file,lims)
% Converts slider positions to contrast values
%
%    Input:
%     mainhandles   - handles structure of the main window
%     pos           - slider left and right position
%     file          - file. Default: selected
%     lims          - lower and upper limit of intensity and slider
%
%    Output:
%     val           - contrast values in intensity [min max]
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
if nargin<3 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end
if nargin<4 || isempty(lims)
    lims = mainhandles.data(file).contrastLims;
end

% Info
rnge = diff(lims); % Intensity range

% Convert from logscale
logx = linspace(log10(lims(1)),log10(lims(2)),100);
idx = round(pos*100);
idx(idx<1) = 1;

val = 10.^logx(idx);

% Non log-scale:
% val = pos*rnge+lims(1);
