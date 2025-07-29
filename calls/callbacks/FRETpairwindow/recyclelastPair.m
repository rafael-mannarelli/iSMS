function mainhandles = recyclelastPair(fpwHandles)
% Callback for recycling last binned pair in the FRET-pair window
%
%    Input:
%     fpwHandles   - handles structure of the FRET-pair window
%
%    Output:
%     mainhandles  - handles structure of the main window
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

% Get mainhandles structure
mainhandles = getmainhandles(fpwHandles);
if isempty(mainhandles.data)
    mymsgbox('No data loaded')
    return
end

% If bin is open
if mainhandles.settings.bin.open
    mymsgbox('Please close the bin first.')
    return
end

% Check bin
n = 0;
for file = 1:length(mainhandles.data)
    n = n+length(mainhandles.data(file).FRETpairsBin);
end
if n==0
    mymsgbox('The bin is empty.')
    return
end

% Last binned pairs
lastPairs = mainhandles.settings.bin.lastpair;

% Check last binned pair
if isempty(mainhandles.data) || isempty(lastPairs)
    mymsgbox('There are no last binned pairs stored.')
    return
end

% Check that all files still are there
for i = 1:size(lastPairs,1)
    file = lastPairs(i,1);
    pair = lastPairs(i,2);
    
    % Dialog and return
    if file>length(mainhandles.data) ...
            || length(lastPairs(find(lastPairs(:,1)==file),1)) > length(mainhandles.data(file).FRETpairsBin)
        
        mymsgbox('Unable to recycle last binned pairs. This is likely because you have loaded or deleted files since they were binned')
        return
    end
end

% Sort fields so they match
for i = 1:length(mainhandles.data)
    mainhandles.data(i).FRETpairs = orderfields(mainhandles.data(i).FRETpairs);
    mainhandles.data(i).FRETpairsBin = orderfields(mainhandles.data(i).FRETpairsBin);
end

%% Recycle

files = unique(lastPairs(:,1));

for i = 1:length(files)
    file = files(i);
    
    % Bin-pairs in file
    pairs = lastPairs(find(lastPairs(:,1)==file),2);
    
    % Index in FRET-pairs bin
    idx = length(mainhandles.data(file).FRETpairsBin)-length(pairs)+1;
    
    for j = 1:length(pairs)
        pair = pairs(j);
        
        % Restore
        mainhandles.data(file).FRETpairs(end+1) = mainhandles.data(file).FRETpairsBin(idx);
        mainhandles.data(file).FRETpairsBin(idx) = [];
        
        % Insert pair at the same position from which it was removed
        FRETpairs = mainhandles.data(file).FRETpairs;
        if pair>1
            mainhandles.data(file).FRETpairs(1:pair-1) = FRETpairs(1:pair-1);
        end
        mainhandles.data(file).FRETpairs(pair) = FRETpairs(end);
        if pair<length(FRETpairs)
            mainhandles.data(file).FRETpairs(pair+1:end) = FRETpairs(pair:end-1);
        end
    
    end
end

%% Update

% Update mainhandles structure
updatemainhandles(mainhandles)

% Update GUI
[mainhandles fpwHandles] = updateafterReusePairs(mainhandles,fpwHandles,unique(lastPairs(:,1)));

% Select the reused pairs
selectPairs(mainhandles, fpwHandles, lastPairs)
[mainhandles, fpwHandles] = FRETpairlistboxCallback(fpwHandles.figure1);
