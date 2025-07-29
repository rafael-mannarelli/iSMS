function [mainhandles,FRETpairwindowHandles] = filterPairs(mainhandle,FRETpairwindowHandle,histogramwindowHandle,selectedPairs)
% Delete pairs according to the criteria specified by
% mainhandles.settings.filterPairs
%
%     Input:
%      mainhandle           - handle to the main figure window
%      FRETpairwindowHandle - handle to the FRETpairwindow
%      histogramwindowHandle - handle to the histogramwindow
%      selectedPairs        - [file pair;...] of pairs to look through
%
%     Output:
%      mainhandles          - handles structure of the main window
%      FRETpairwindowHandles - handles structure of the FRETpairwindow
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

FRETpairwindowHandles = [];
if isempty(mainhandle) || (~ishandle(mainhandle))
    mainhandles = [];
    return
end

% Get handles structures
mainhandles = guidata(mainhandle);

% Default outuput
if ~isempty(FRETpairwindowHandle) && ishandle(FRETpairwindowHandle)
    FRETpairwindowHandles = guidata(FRETpairwindowHandle);
end

% Pairs to run
if nargin<4
    selectedPairs = getPairs(mainhandle, 'all');
end

if mainhandles.settings.filterPairs.filterselected
    filechoice = get(mainhandles.FilesListbox,'Value');
    selectedPairs(selectedPairs(:,1)~=filechoice,:) = [];
end

% Check if any of the filters are turned on
if (~mainhandles.settings.filterPairs.filter1 && ~mainhandles.settings.filterPairs.filter2 ...
        && ~mainhandles.settings.filterPairs.filter3) || isempty(selectedPairs)
    return
end

% Check pairs listed or plotted in other windows, to update those windows
correctionlistedPairs = getPairs(mainhandle, 'correctionListed', [],[],[], mainhandles.correctionfactorwindowHandle); % Pairs listed in the correction factor window
plottedPairs = getPairs(mainhandle, 'Plotted', [], FRETpairwindowHandle, histogramwindowHandle); % Pairs currently plotted in the E-S window

% For counting # deleted pairs
idx = [];

%% Run filter 1

if mainhandles.settings.filterPairs.filter1
    filter1frames = mainhandles.settings.filterPairs.filter1frames
    filter1counts = mainhandles.settings.filterPairs.filter1counts
    
    for i = 1:length(mainhandles.data)
        pairs = selectedPairs(selectedPairs(:,1)==i,2); % FRET pairs in selectedPairs being from file i
        for j = pairs(:)'
            
            % Sort traces according to intensity
%             gamma = getGamma(mainhandles,[i j]);
%             sumDA = sort( gamma*mainhandles.data(i).FRETpairs(j).DDtrace+mainhandles.data(i).FRETpairs(j).ADtrace, 'descend');
            sumDA = sort( mainhandles.data(i).FRETpairs(j).DDtrace+mainhandles.data(i).FRETpairs(j).ADtrace, 'descend');
            
            % Check frames does not exceed data
            if filter1frames>length(sumDA)
                filter1frames = length(sumDA);
            end
            
            % Calculate mean intensity of filter1frames most intense frames
            val = sum( sumDA(1:filter1frames) )/filter1frames;
            
            % Check if avg is below threshold
            if val<filter1counts
                idx = [idx; i j];
            end
            
        end
        
    end
end
idx
%% Run filter 2

if mainhandles.settings.filterPairs.filter2
    filter2dist = mainhandles.settings.filterPairs.filter2dist;
    for i = 1:length(mainhandles.data)
        pairs = selectedPairs(selectedPairs(:,1)==i,2); % FRET pairs in selectedPairs being from file i
        for j = pairs(:)'
            
            % Donor peaks
            AllPeaks = [mainhandles.data(i).Dpeaks; mainhandles.data(i).Apeaks];
            Dxy = mainhandles.data(i).FRETpairs(j).Dxy;
            Axy = mainhandles.data(i).FRETpairs(j).Axy;
            AllPeaks(find(ismember(AllPeaks,Axy,'rows','legacy')),:) = [];
            AllPeaks(find(ismember(AllPeaks,Dxy,'rows','legacy')),:) = [];
            temp = [sqrt(((AllPeaks(:,1)-Dxy(1)).^2 + (AllPeaks(:,2)-Dxy(2)).^2));  sqrt(((AllPeaks(:,1)-Axy(1)).^2 + (AllPeaks(:,2)-Axy(2)).^2))];
            
            if ~isempty(find(temp(:)<=filter2dist & temp>0))
                idx = [idx; i j];
            end
            
        end
    end
end

%% Run filter 3

if mainhandles.settings.filterPairs.filter3
    filter3frames = mainhandles.settings.filterPairs.filter3frames;
    for i = 1:length(mainhandles.data)
        pairs = selectedPairs(selectedPairs(:,1)==i,2); % FRET pairs in selectedPairs being from file i
        for j = pairs(:)'
            if ~isempty(mainhandles.data(i).FRETpairs(j).DbleachingTime) && mainhandles.data(i).FRETpairs(j).DbleachingTime<=filter3frames
                idx = [idx; i j];
            elseif ~isempty(mainhandles.data(i).FRETpairs(j).AbleachingTime) && mainhandles.data(i).FRETpairs(j).AbleachingTime<=filter3frames
                idx = [idx; i j];
            end
        end
    end
end

%% Run filter 4

if mainhandles.settings.filterPairs.filter4 && mainhandles.settings.excitation.alex
    filter4frames = mainhandles.settings.filterPairs.filter4frames;
    filter4counts = mainhandles.settings.filterPairs.filter4counts;
    
    for i = 1:length(mainhandles.data)
        pairs = selectedPairs(selectedPairs(:,1)==i,2); % FRET pairs in selectedPairs being from file i
        for j = pairs(:)'
            
            % Sort traces according to intensity
            sumAA = sort( mainhandles.data(i).FRETpairs(j).AAtrace );
            
            % Check frames does not exceed data
            if filter4frames>length(sumAA)
                filter4frames = length(sumAA);
            end
            
            % Calculate mean intensity of filter1frames most intense frames
            val = sum( sumAA(1:filter4frames) )/filter4frames;
            
            % Check if avg is below threshold
            if val<filter4counts
                idx = [idx; i j];
            end
            
        end
    end
end

%% Delete found pairs

filteredPairs = unique(idx,'rows');
if isempty(filteredPairs)
    %         mymsgbox(sprintf(...
    %     'No FRET-pairs found based on specified filter criteria.',deleted),...
    %     'No FRET Pairs deleted')
    return
end

% Put pairs to be deleted in the recycle bin
mainhandles = binPair(mainhandles, idx);

% Now delete
for i = 1:length(mainhandles.data)
    if ismember(i,filteredPairs(:,1))
        pairs = filteredPairs(filteredPairs(:,1)==i,2); % FRET pairs in selectedPairs being from file i
        mainhandles.data(i).FRETpairs(pairs) = [];
    end
end

% Update mainhandles structure
updatemainhandles(mainhandles)

%% Update

mainhandles = updateFRETpairs(mainhandles,unique(selectedPairs(:,1)));
mainhandles = updatepeakplot(mainhandles,'FRET',0); % This will also run updateFRETpairlist, updatemainhandles and highlightFRETpair
FRETpairwindowHandles = updateFRETpairplots(mainhandle,FRETpairwindowHandle,'all'); % Updates the intensity traces and molecule images
FRETpairwindowHandles = updateMoleculeFrameSliderHandles(mainhandle,FRETpairwindowHandle);

% Update correction factor window
if ismember(1,ismember(filteredPairs,correctionlistedPairs,'rows','legacy'))
    updateCorrectionFactorPairlist(mainhandle,mainhandles.correctionfactorwindowHandle)
    updateCorrectionFactorPlots(mainhandle,mainhandles.correctionfactorwindowHandle)
end

% Update the ES histogram
if nargin<3
    histogramwindowHandle = mainhandles.histogramwindowHandle;
end
if ismember(1,ismember(filteredPairs,plottedPairs,'rows','legacy')) % If the removed pairs are in the plot
    mainhandles = updateSEplot(mainhandle,FRETpairwindowHandle,histogramwindowHandle,'all');
end

% Show message about filtered pairs
mainhandles = myguidebox(mainhandles,'Pairs removed',...
    sprintf(['The molecule filter removed %i pairs.\n'...
    'Deleted pairs can be reused by opening the recycle bin in the FRET-pair window.\n\n',...
    'Set the Molecule filter settings in the Settings menu of the main window.'],size(filteredPairs,1)),'filterpairs',1,...
    'http://isms.au.dk/documentation/molecule-filters/');
