function mainhandles = reusebinCallback(FRETpairwindowHandles, choice, subchoice)
% Callback for re-using pairs from bin
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRETpair window
%     choice                 - 'all','file'
%     subchoice              - filechoice if choice='file'
%
%    Output:
%     mainhandles            - handles structure of the main window
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

% Get handles structures
mainhandles = getmainhandles(FRETpairwindowHandles);
if isempty(mainhandles)
    return
end

% Defaults
if nargin<2
    choice = 'all';
end
if nargin<3
    subchoice = get(mainhandles.FilesListbox,'Value');
end

% All FRET pairs
allPairs = getPairs(mainhandles.figure1,'all');

% Pairs currently in bin
binnedPairs = getbinnedPairs(mainhandles.figure1,choice,subchoice);
if isempty(binnedPairs)
    return
end

% Files
if strcmpi(choice,'all')
    files = 1:length(mainhandles.data);    
elseif strcmpi(choice,'file')
    files = subchoice;
end

%% Reuse

mainhandles = reusePairs(mainhandles,files);

%% Update

% Update mainhandles structure
updatemainhandles(mainhandles)

% 
[mainhandles FRETpairwindowHandles] = updateafterReusePairs(mainhandles, FRETpairwindowHandles, files);
% % Remove FRET pairs potentially listed twice
% mainhandles = updateFRETpairs(mainhandles, files);
% 
% % Update bin counter
% updateFRETpairbinCounter(mainhandles.figure1, FRETpairwindowHandles.figure1);
% 
% % Update peak plot and FRET pair lists and counters
% ok = 0;
% if ismember(get(mainhandles.FilesListbox,'Value'), files)
%     mainhandles = updatepeakplot(mainhandles,'FRET'); % This will also run updateFRETpairs, updateFRETpairlist, updatemainhandles, highlightFRETpair, and updategrouplist
%     ok = 1;
%     
% else
%     % These would have been run by updatepeakplot
%     updatepeakcounter(mainhandles) % Updates the peak counters in the sms window
%     updateFRETpairlist(mainhandles.figure1,mainhandles.FRETpairwindowHandle); % Update the FRET pair list of the FRET-pair window (if open)
%     updategrouplist(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
% end
% 
% % Update FRETpairwindowPlots if reusing warrants a new pair selection
% [mainhandles, FRETpairwindowHandles] = FRETpairlistboxCallback(FRETpairwindowHandles.figure1);
% % FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'all'); % Updates the intensity traces and molecule images
% % FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1);
% 
% % Update correction factor window
% % updateCorrectionFactorPairlist(FRETpairwindowHandles.main,mainhandles.correctionfactorwindowHandle)
% 
% % Return focus to current window
% if ok
%     figure(FRETpairwindowHandles.figure1)
% end
% 
end

function mainhandles = reusePairs(mainhandles,files)
% Reuses pairs in filechoices
if isempty(files)
    return
end

% Look through all files in filechoice
for i = 1:length(files)
    file = files(i);
    
    % Number of binned pairs
    n = length(mainhandles.data(file).FRETpairsBin);
    if n==0
        continue
    end
    
    % Sort fields so they match
    mainhandles.data(file).FRETpairs = orderfields(mainhandles.data(file).FRETpairs);
    FRETpairsBin = orderfields(mainhandles.data(file).FRETpairsBin);
    
    % Binned FRET pairs in file i
    if isempty(mainhandles.data(file).FRETpairs)
        mainhandles.data(file).FRETpairs = FRETpairsBin;
    else
        mainhandles.data(file).FRETpairs(end+1:end+n) = FRETpairsBin;
    end
    
    % Remove from bin
    mainhandles.data(file).FRETpairsBin(:) = [];
    
end
end

