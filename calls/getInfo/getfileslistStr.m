function namestr = getfileslistStr(mainhandles,filechoices)
% Returns the list string to display in files listboxes
%
%    Input:
%     mainhandles   - handles structure of the main window
%     filechoices   - files to display
%
%    Output:
%     namestr       - string to populate list
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

namestr = {};
if isempty(mainhandles.data)
    return
end

% Default
if nargin<2
    filechoices = 1:length(mainhandles.data);
end

%% String

namestr = cell(length(filechoices),1);

for i = 1:length(filechoices)
    file = filechoices(i);
    
    % Start by number) name
    namestr{i} = sprintf('%i) %s', i, mainhandles.data(file).name); 
    
    % Boldface missing raw data. Change string to HTML code
    if isempty(mainhandles.data(file).imageData) && isempty(mainhandles.data(file).DD_ROImovie)
        namestr{i} = sprintf('<HTML>%s  <b>(-raw)</b></HTML>', namestr{i});
    elseif isempty(mainhandles.data(file).imageData) && ~isempty(mainhandles.data(file).DD_ROImovie)
        namestr{i} = sprintf('<HTML>%s  <b>(ROI only)</b></HTML>', namestr{i});
    end
    
end
