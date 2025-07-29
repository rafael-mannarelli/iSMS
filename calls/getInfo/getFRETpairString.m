function namestr = getFRETpairString(mainhandle, FRETpairwindowHandle)
% Returns the listbox string (cell array) for the FRET-pair listbox
%
%   Input:
%    mainhandle           - handle for the main figure window (sms)
%    FRETpairwindowHandle - handle for the FRETpairwindow
%
%   Output:
%    namestr              - Cell array of strings of size {npairs,1}
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

% Initialize output
namestr = {};

% If one of the windows is closed
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);

listedPairs = getPairs(mainhandle, 'Listed', [], FRETpairwindowHandle); % Pairs to be listed in the listbox, in correct order [file pair; ...]
if isempty(listedPairs)
    return
end

%% Make string cell

npairs = size(listedPairs,1);
namestr = cell(npairs,1);
for i = 1:npairs
    file = listedPairs(i,1);
    pair = listedPairs(i,2);
    
    % If listing all files files add file suffix
    namestr{i} = sprintf('%i,%i', file, pair); % Change listbox string
    
    % Add avg. FRET to listbox names
    if mainhandles.settings.FRETpairplots.avgFRET
        if isempty(mainhandles.data(file).FRETpairs(pair).avgE)
            mainhandles = calculateAvgTrace(mainhandle,'E',[file pair]);
        end
        
        avgE = mainhandles.data(file).FRETpairs(pair).avgE;
        namestr{i} = sprintf('%s (%.2f)', namestr{i},avgE);
    end
    
    % Sort according to group order
    group = sort(mainhandles.data(file).FRETpairs(pair).group);
    
    % Add group name
    if mainhandles.settings.grouping.nameList
        
        % Groups of this pair
        if ~isempty(group) && group(1)<=length(mainhandles.groups)
            % If group is valid
            namestr{i} = sprintf('%s - %s', namestr{i},mainhandles.groups(group(1)).name); % Change listbox string
            
            % Add more if molecule belongs to more than one group
            if length(group)>1
                for k = 2:length(group)
                    if group(k)<=length(mainhandles.groups)
                        namestr{i} = sprintf('%s; %s', namestr{i},mainhandles.groups(group(k)).name); % Change listbox string
                    end
                end
            end
            
        else
            
            % Assigned group does not exists
            if mainhandles.settings.grouping.showNoGroup
                namestr{i} = sprintf('%s - (no group)', namestr{i}); % Change listbox string
            end
        end
    end
    
    % Colorize listbox according to group
    if mainhandles.settings.grouping.colorList
        
        % Group color
        if ~isempty(group) && group(1)<=length(mainhandles.groups)
            % If group is valid
            color = mainhandles.groups(group(1)).color;
        else
            % Black color if group is not valid
            color = [0 0 0];
        end
        
        % Update string
        namestr{i} = sprintf('<HTML><BODY color="rgb(%i, %i, %i)">%s</HTML>', color, namestr{i}); % Change string to HTML code
    end
end
