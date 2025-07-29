function mainhandles = deletePairs(mainhandle, selectedPairs)
% Deletes selectedPairs and updates all windows accordingly
%
%     Input:
%      mainhandle   - handle to the main window
%      selectedPairs - [file pair;...]
%
%     Output:
%      mainhandles  - handles structure of the main window
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

% Get handles structure
if isempty(mainhandle) || ~ishandle(mainhandle)
    mainhandles = guidata(getappdata(0,'mainhandle'));
    return
end
mainhandles = guidata(mainhandle);

% Check
if isempty(mainhandles.data) || nargin<2 || isempty(selectedPairs)
    return
end

% FRETpairs window handles
if isempty(mainhandles.FRETpairwindowHandle) || ~ishandle(mainhandles.FRETpairwindowHandle)
    return
end
FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);

% Check pairs listed or plotted in other windows, to update those windows
correctionlistedPairs = getPairs(FRETpairwindowHandles.main, 'correctionListed', [],[],[], mainhandles.correctionfactorwindowHandle); % Pairs listed in the correction factor window
plottedPairs = getPairs(FRETpairwindowHandles.main, 'Plotted', [], FRETpairwindowHandles.figure1, mainhandles.histogramwindowHandle); % Pairs currently plotted in the E-S window
npairs_prev = size(getPairs(FRETpairwindowHandles.main,'Listed'),1);

% Check bin open status
if mainhandles.settings.bin.open && isempty(getbingroup(mainhandle))
    mainhandles.settings.bin.open = 0;
    set(FRETpairwindowHandles.Bin_open,'Checked','off')
    updatemainhandles(mainhandles)
end


%% Delete pairs
files = unique(selectedPairs(:,1));
okbin = 0; % Ok to update bin counter?
for i = 1:length(files)
    
    % Selected pairs in file i
    file = files(i);
    idx = find(selectedPairs(:,1)==file);
    pairs = selectedPairs(idx,2);
    
    % Move to bin
    if mainhandles.settings.bin.open
        
            

        % Check if selected pairs are in the bin already, if so delete them
        binnedPairs = getPairs(mainhandles.figure1,'bin');
        if ismember(0, ismember(selectedPairs(idx,:),binnedPairs,'rows','legacy') )
            mainhandles = binPair(mainhandles, selectedPairs(idx,:)); % Put in bin if there are at least one molecule that is not already in bin
        else
            % Just delete directly since they are all already in the bin
            mainhandles.data(file).FRETpairs(pairs) = []; 
            okbin = 1;
        end
        
    else
        % Put in bin if bin is not open, then delete
        mainhandles = binPair(mainhandles, selectedPairs(idx,:));
        mainhandles.data(file).FRETpairs(pairs) = [];
    end
    
end

%% Update
updatemainhandles(mainhandles)

% Update bin counter
if okbin
    updateFRETpairbinCounter(mainhandles.figure1, mainhandles.FRETpairwindowHandle)
end

% Set new pair selection
pairchoices = get(FRETpairwindowHandles.PairListbox,'Value');
Epairs = npairs_prev-size(selectedPairs,1);
if (Epairs==0) % If there are no FRET-pairs left
    set(FRETpairwindowHandles.PairListbox,'Value',1)
    
elseif length(pairchoices) > 1 % If there were more than one pair selected, set the value to the first
    if min(pairchoices) <= Epairs
        set(FRETpairwindowHandles.PairListbox,'Value',min(pairchoices))
    else set(FRETpairwindowHandles.PairListbox,'Value',Epairs)
    end
    
elseif pairchoices > Epairs % If the selected pair was the last
    set(FRETpairwindowHandles.PairListbox,'Value',Epairs)
    
else
    set(FRETpairwindowHandles.PairListbox,'Value',pairchoices) % Else set value to the same as before
end

% Update peak plot and FRET pair lists and counters
if ismember(get(mainhandles.FilesListbox,'Value'), files)
    mainhandles = updatepeakplot(mainhandles,'FRET'); % This will also run updateFRETpairs, updateFRETpairlist, updatemainhandles, highlightFRETpair, and updategrouplist

else
    % These would have been run by updatepeakplot
    updatepeakcounter(mainhandles) % Updates the peak counters in the sms window
    updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle); % Update the FRET pair list of the FRET-pair window (if open)
    updategrouplist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
end

% Update FRETpairwindowPlots
FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'all'); % Updates the intensity traces and molecule images
FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1);

% Update correction factor window
ok = 0;
if ismember(1,ismember(selectedPairs,correctionlistedPairs,'rows','legacy'))
    updateCorrectionFactorPairlist(FRETpairwindowHandles.main,mainhandles.correctionfactorwindowHandle)
    updateCorrectionFactorPlots(FRETpairwindowHandles.main,mainhandles.correctionfactorwindowHandle)
    ok = 1;
end

% Update the ES histogram
if ismember(1,ismember(selectedPairs,plottedPairs,'rows','legacy')) % If the removed pairs are in the plot
    mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
    ok = 1;
end

% Return to current figure
if ok
    figure(FRETpairwindowHandles.figure1)
end
