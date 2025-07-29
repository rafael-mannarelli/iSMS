function mainhandles = binPair(mainhandles, selectedPairs, update)
% Moves selectedPairs to the recycle bin
%
%     Input:
%      mainhandles   - handles structure of the main window
%      selectedPairs - [file pair;...]
%      update        - 0/1 whether to update GUI afterwards. Default: 1
%
%     Output:
%      mainhandles   - ..
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

% Defaults
if nargin<2 || isempty(selectedPairs)
    return
end
if nargin<3
    update = 1;
end

% Sort fields so they match
for i = 1:length(mainhandles.data)
    mainhandles.data(i).FRETpairs = orderfields(mainhandles.data(i).FRETpairs);
    mainhandles.data(i).FRETpairsBin = orderfields(mainhandles.data(i).FRETpairsBin);
end

%% Add all selectedPairs to bin

for i = 1:size(selectedPairs,1)
    
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    % Add to bin
    if mainhandles.settings.bin.open
        
        % Add to bin group
        mainhandles.data(file).FRETpairs(pair).group = getbingroup(mainhandles.figure1);
        
    else
        % Add to bin structure
        if isempty(mainhandles.data(file).FRETpairsBin)
            mainhandles.data(file).FRETpairsBin = mainhandles.data(file).FRETpairs(pair);
        else
            mainhandles.data(file).FRETpairsBin(end+1) = mainhandles.data(file).FRETpairs(pair);
        end
    end
    
    
end

% Store this as the last binned pair
mainhandles.settings.bin.lastpair = selectedPairs;

%% Update mainhandles

updatemainhandles(mainhandles)

% Update bin counter in the FRETpairwindow
updateFRETpairbinCounter(mainhandles.figure1, mainhandles.FRETpairwindowHandle)
