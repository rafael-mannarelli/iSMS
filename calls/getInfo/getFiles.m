function files = getFiles(mainhandles,choice)
% Returns all files corresponding to choice
%
%    Input:
%     mainhandles   - handles structure of the main window
%     choice        - 'all', ['notspots'], 'Gspot', 'Rspot'
%
%    Output.
%     files         - [file1 file2...]
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

files = [];

% Check data
if isempty(mainhandles.data)
    return
end

% Default
if nargin<2 || isempty(choice)
    choice = 'notspots';
end

%% All
if strcmpi(choice,'all')
    files = 1:length(mainhandles.data);
    return
end

%% All except spots
if strcmpi(choice,'notspots')
    for i = 1:length(mainhandles.data)
        if ~mainhandles.data(i).spot
            files = [files i];
        end
    end
    return
end
    
%% Green spot
if strcmpi(choice,'Gspot')
    for i = 1:length(mainhandles.data)
        if mainhandles.data(i).spot==1
            files = [files i];
        end
    end
    return
end

%% Red spot
if strcmpi(choice,'Rspot')
    for i = 1:length(mainhandles.data)
        if mainhandles.data(i).spot==2
            files = [files i];
        end
    end
    return
end
