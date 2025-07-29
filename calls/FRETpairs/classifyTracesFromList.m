function mainhandles = classifyTracesFromList(mainhandle,listfile,groupName)
%CLASSIFYTRACESFROMLIST Group molecules specified in a text file
%
%   mainhandles = CLASSIFYTRACESFROMLIST(mainhandle,listfile,groupName)
%   reads a plain text file where each line corresponds to an exported
%   trace filename of the form
%       Traces_<movie>_pair<index>.txt
%   and places the corresponding FRET pairs in the specified group.
%   If the group does not exist it will be created.
%
%   Input arguments:
%       mainhandle - handle to the main iSMS window
%       listfile   - path to text file containing trace filenames
%       groupName  - (optional) name of group (default: 'Good FRET')
%
%   Output:
%       mainhandles - updated handles structure
%
%   The movie name should match the filename used in the session. Note that
%   exported traces replace '.' with '_' and ensure the string is a valid
%   MATLAB variable name. The same conversion is used for matching.
%
%   Example line of list file:
%       Traces_Movie1_pair5.txt

% --- Copyrights (C) ---
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

if nargin<3 || isempty(groupName)
    groupName = 'Good FRET';
end

mainhandles = [];
if isempty(mainhandle) || ~ishandle(mainhandle)
    return
end
mainhandles = guidata(mainhandle);
if isempty(mainhandles) || isempty(mainhandles.data) || ~exist(listfile,'file')
    return
end

%% Read file list
fid = fopen(listfile,'r');
if fid==-1
    return
end
C = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
lines = C{1};

selectedPairs = [];
for i = 1:numel(lines)
    line = strtrim(lines{i});
    if isempty(line)
        continue
    end
    tokens = regexp(line,'^Traces_(.*)_pair(\d+)\.txt$','tokens','once');
    if isempty(tokens)
        continue
    end
    movename = tokens{1};
    pairnum = str2double(tokens{2});

    for f = 1:length(mainhandles.data)
        validname = matlab.lang.makeValidName(strrep(mainhandles.data(f).name,'.','_'));
        if strcmpi(movename,validname)
            if pairnum<=length(mainhandles.data(f).FRETpairs)
                selectedPairs = [selectedPairs; f pairnum];
            end
            break
        end
    end
end

selectedPairs = unique(selectedPairs,'rows');
if isempty(selectedPairs)
    return
end

%% Determine group index
if ~isfield(mainhandles,'groups') || ~isstruct(mainhandles.groups) || isempty(mainhandles.groups)
    idx = [];
else
    idx = find(strcmpi({mainhandles.groups.name},groupName),1);
end
if isempty(idx)
    mainhandles = createNewGroup(mainhandles, selectedPairs, groupName, [], 0);
else
    for k = 1:size(selectedPairs,1)
        file = selectedPairs(k,1);
        pair = selectedPairs(k,2);
        prev = mainhandles.data(file).FRETpairs(pair).group;
        mainhandles.data(file).FRETpairs(pair).group = unique([prev idx],'stable');
    end
end

updatemainhandles(mainhandles)
mainhandles = updateGUIafterNewGroup(mainhandles.figure1);

end
