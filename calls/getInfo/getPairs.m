function selectedPairs = getPairs(mainhandle, choice, subchoice,...
    FRETpairwindowHandle,...
    histogramwindowHandle,...
    correctionfactorwindowHandle,...
    driftwindowHandle,...
    integrationwindowHandle,...
    psfwindowHandle,...
    dynamicswindowHandle)

% Returns the files and FRETpairs corresponding to the FRET-pairs defined
% by input 'choice'.
%
%  Syntax:
%   selectedPairs = getPairs(mainhandle, choice, subchoice,...
%      FRETpairwindowHandle,...
%      histogramwindowHandle,...
%      correctionfactorwindowHandle,...
%      driftwindowHandle,...
%      integrationwindowHandle,...
%      psfwindowHandle)
%
%  Output arguments:
%   selectedPairs         - [file pair;...]
%
%  Input arguments:
%   mainhandle            - handles to the main figure window (sms)
%   FRETpairwindowHandle  - handle to the FRETpairwindow
%   histogramwindowHandle - handle to the 2D histogram window
%   correctionfactorwindowHandle - handle to the correction factor window
%   driftwindowHandle     - handle to the drift window
%   integrationwindowHandle    - handle to the phontin counting window
%
%   subchoice - Specifier depending on choice:
%        file or group :if: File/Group/Bleach/DAbleach/Dbleach/Ableach.
%        channel       :if: Gaussians.
%        default       : [] (all files or selected group)
%
%  choice (default ['Selected']):
%  'All'       returns all FRETpairs in all files
%  'Selected'  returns FRET pairs selected in the FRETpair listbox
%  'Listed'    returns FRET pairs listed in the FRETpairwindow listbox in
%              the correct order
%  'File'      returns all FRETpairs in the selected movie file, unless
%              'subchoice' (filechoices) is also provided as input
%              argument
%  'Group'     returns all FRETpairs of the selected groups. If
%              'subchoice' (groupchoice) is also provided as input
%              argument, this is the groupchoice, else groupchoice is
%              selected groups in the FRETpairwindow
%  'Bleach'    returns FRETpairs in all files that have EITHER D or A
%              bleaching time defined, unless 'subchoice' (filechoice) is
%              also provided as input argument
%  'DAbleach'  returns FRETpairs in all files that have BOTH the D and A
%              bleaching times defined, unless 'subchoice' (filechoice)
%              is also provided as input argument
%  'Dbleach'   returns FRETpairs in all files that have D bleaching time
%              defined, unless 'subchoice' (filechoice) is also provided
%              as input argument
%  'Ableach'   returns FRETpairs in all files that have A bleaching time
%              defined, unless 'subchoice' (filechoice) is also provided
%              as input argument
%  'Blink'     returns FRETpairs in all files having EITHER D or A blinking
%              intervals defined
%  'BlinkBleach' returns pairs with both bleaching and blinking defined
%  'missTrace' returns FRETpairs in all files missing their intensity
%              traces
%  'Plotted'   returns FRETpairs currently being plotted in the
%              ES-histogram
%  'Dynamics'  returns FRETpairs that have idealized vbFRET traces stored
%  'dynamicsSelected' returns the pairs currently selected in the dynamics
%              window listbox
%  'Dleakage'  returns FRETpairs applicable for calculating D
%              leakage factor
%  'Adirect'   returns FRETpairs applicable for calculating
%              direct acceptor excitation factor
%  'gamma'     returns FRETpairs applicable for calculating the
%              gamma factor
%  'correctionSelected' returns pairs selected in the listbox of the
%              correction factor window
%  'correctionListed' returns the pairs currently listed in the correction
%              factor window listbox
%  'driftListed' returns FRETpairs currently listed in the FRET-pair
%              listbox in the driftwindow
%  'driftSelected' returns FRETpairs currently selected in the FRET-pair
%              listbox in the driftwindow
%  'photonSelected' returns the pair selected in the integrationsettingsWindow
%  'psfwindowSelected' returns the pair selected in the psf parameter trace
%              window
%  'psf'       returns pairs that have had their traces calculated by
%              Gaussian psf fitting. subchoice determines what channel:
%              'all' 'DD' 'AD' or 'AA' (default)
%  'bin'       Returns pairs in the recycle bin that are part of data
%              because the bin is open. [] if bin is closed
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

selectedPairs = [];

% Mainhandles structure
if nargin<1
    mainhandle = getappdata(0,'mainhandle');
end

% Return if handle to main window is lost
if isempty(mainhandle) || (~ishandle(mainhandle))
    return
end

% Get handles structures
mainhandles = guidata(mainhandle);

% Defaults
if nargin<2
    choice = 'Selected'; % Default is FRETpairs selected in the FRET pair window
end
if nargin<3
    subchoice = []; % Default is all files or selected group
end
if nargin<4
    FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
end
if nargin<5
    histogramwindowHandle = mainhandles.histogramwindowHandle;
end
if nargin<6
    correctionfactorwindowHandle = mainhandles.correctionfactorwindowHandle;
end
if nargin<7
    driftwindowHandle = mainhandles.driftwindowHandle;
end
if nargin<8
    integrationwindowHandle = mainhandles.integrationwindowHandle;
end
if nargin<9
    psfwindowHandle = mainhandles.psfwindowHandle;
end
if nargin<10
    dynamicswindowHandle = mainhandles.dynamicswindowHandle;
end

%% 'All'

if strcmpi(choice,'All') % Return a list with all FRET pairs in all files
    
    % For pre-allocation
    npairs = 0;
    for i = 1:length(mainhandles.data)
        npairs = npairs+length(mainhandles.data(i).FRETpairs);
    end
    
    % Make selectedPairs
    if npairs>0
        selectedPairs = zeros(npairs,2);
        idx1 = 1;
        for i = 1:length(mainhandles.data)
            npairs = length(mainhandles.data(i).FRETpairs);
            if npairs>0
                idx2 = idx1+npairs-1;
                selectedPairs(idx1:idx2,:) = [ones(npairs,1)*i [1:npairs]'];
                idx1 = idx2+1;
            end
        end
    end
    
    return
end
%% 'Selected'

if strcmpi(choice,'Selected')
    % FRETpairwindow handles
    if isempty(FRETpairwindowHandle) || (~ishandle(FRETpairwindowHandle))
        return
    end
    FRETpairwindowHandles = guidata(FRETpairwindowHandle);
    
    % Listed pairs
    listedPairs = getPairs(mainhandle, 'Listed', [], FRETpairwindowHandle);
    if isempty(listedPairs)
        return
    end
    
    pairchoices = get(FRETpairwindowHandles.PairListbox,'Value'); % Selected FRET-pair
    if isempty(pairchoices)
        return
    end
    if size(listedPairs,1) < pairchoices(end) % Check if selected value is greater than number of list items
        set(FRETpairwindowHandles.PairListbox,'Value',size(listedPairs,1))
        pairchoices = get(FRETpairwindowHandles.PairListbox,'Value');
    elseif isempty(pairchoices) || (length(pairchoices)==1 && pairchoices==0)
        pairchoices = 1;
        set(FRETpairwindowHandles.PairListbox,'Value',1)
    end
    selectedPairs = listedPairs(pairchoices,:);
    
    return
end
%% 'Listed'
if strcmpi(choice,'Listed')
    % FRETpairwindow handles
    if isempty(FRETpairwindowHandle) || (~ishandle(FRETpairwindowHandle))
        return
    end
    FRETpairwindowHandles = guidata(FRETpairwindowHandle);
    sortpairsChoice = mainhandles.settings.FRETpairplots.sortpairs;
    
    if sortpairsChoice==1
        % Don't sort
        selectedPairs = getPairs(mainhandle, 'All');
        
    elseif sortpairsChoice==2
        % Sort according to group
        
        selectedPairs = getPairs(mainhandle, 'All');
        if isempty(selectedPairs)
            return
        end
        
        idx1 = 1;
        for i = 1:length(mainhandles.groups)
            groupmembers = getPairs(mainhandle, 'Group', i, FRETpairwindowHandle);
            if isempty(groupmembers)
                continue
            end
            
            npairs = size(groupmembers,1);
            idx2 = idx1+npairs-1;
            selectedPairs(idx1:idx2,:) = groupmembers;
            idx1 = idx2+1;
        end
        
        % Insert molecules with group last
        if idx2~=size(selectedPairs,1)
            nogroupPairs = getgroupmembers(mainhandles.figure1,[]);
            if size(selectedPairs,1)-idx2==size(nogroupPairs,1)
                selectedPairs(idx1:end,:) = nogroupPairs;
            end
        end
        
    elseif sortpairsChoice==3 || sortpairsChoice==4
        % Sort according to avg. E or S
        
        % Get pairs to be listed
        selectedPairs = getPairs(mainhandle,'all');
        if isempty(selectedPairs)
            return
        end
        
        % Sort pairs
        if sortpairsChoice==3
            selectedPairs = sortpairs(selectedPairs, 'avgE');
        else
            selectedPairs = sortpairs(selectedPairs, 'avgS');
        end
        
    elseif sortpairsChoice==5 || sortpairsChoice==6 || sortpairsChoice==7 || sortpairsChoice==8
        % Sort according to max intensity
        
        % Get pairs to be listed
        selectedPairs = getPairs(mainhandle,'all');
        if isempty(selectedPairs)
            return
        end
        
        temp = zeros(size(selectedPairs,1),3);
        temp(:,2:3) = selectedPairs; % Selected pairs including avg E
        
        % Calculate max intensity of all pairs
        if sortpairsChoice==5
            
            for i = 1:size(selectedPairs,1)
                file = selectedPairs(i,1);
                pair = selectedPairs(i,2);
                if isempty(mainhandles.data(file).FRETpairs(pair).maxDAsum)
                    mainhandles = calculateMax(mainhandle,'DAsum',[file pair]);
                end
                temp(i,1) = mainhandles.data(file).FRETpairs(pair).maxDAsum;
            end
            
        elseif sortpairsChoice==6
            
            for i = 1:size(selectedPairs,1)
                file = selectedPairs(i,1);
                pair = selectedPairs(i,2);
                if isempty(mainhandles.data(file).FRETpairs(pair).maxDD)
                    mainhandles = calculateMax(mainhandle,'DD',[file pair]);
                end
                temp(i,1) = mainhandles.data(file).FRETpairs(pair).maxDD;
            end
            
        elseif sortpairsChoice==7
            
            for i = 1:size(selectedPairs,1)
                file = selectedPairs(i,1);
                pair = selectedPairs(i,2);
                if isempty(mainhandles.data(file).FRETpairs(pair).maxAD)
                    mainhandles = calculateMax(mainhandle,'AD',[file pair]);
                end
                temp(i,1) = mainhandles.data(file).FRETpairs(pair).maxAD;
            end
            
        elseif sortpairsChoice==8
            
            for i = 1:size(selectedPairs,1)
                file = selectedPairs(i,1);
                pair = selectedPairs(i,2);
                if isempty(mainhandles.data(file).FRETpairs(pair).maxAA)
                    mainhandles = calculateMax(mainhandle,'AA',[file pair]);
                end
                temp(i,1) = mainhandles.data(file).FRETpairs(pair).maxAA;
            end
            
        end
        
        % Sort according to intensity
        temp = flipud( sortrows(temp) );
        selectedPairs = temp(:,2:3);

    elseif sortpairsChoice==9
        % Sort according to DeepFRET confidence with threshold filters

        selectedPairs = getPairs(mainhandle,'all');
        if isempty(selectedPairs)
            return
        end

        minConf = mainhandles.settings.FRETpairplots.minDeepFRETConf;
        minFrames = mainhandles.settings.FRETpairplots.minBleachFrames;

        temp = zeros(size(selectedPairs,1),3);
        keep = false(size(selectedPairs,1),1);

        for i = 1:size(selectedPairs,1)
            file = selectedPairs(i,1);
            pair = selectedPairs(i,2);

            conf = 0;
            if isfield(mainhandles.data(file).FRETpairs(pair),'DeepFRET_confidence') && ...
                    ~isempty(mainhandles.data(file).FRETpairs(pair).DeepFRET_confidence)
                conf = mainhandles.data(file).FRETpairs(pair).DeepFRET_confidence;
            end

            Dtime = mainhandles.data(file).FRETpairs(pair).DbleachingTime;
            Atime = mainhandles.data(file).FRETpairs(pair).AbleachingTime;
            times = [Dtime Atime];
            times = times(~isnan(times) & times>0);
            if isempty(times)
                frames = mainhandles.data(file).rawmovieLength;
            else
                frames = min(times);
            end

            if conf >= minConf && frames >= minFrames
                keep(i) = true;
                temp(i,1) = conf;
                temp(i,2:3) = selectedPairs(i,:);
            end
        end

        temp = temp(keep,:);
        if isempty(temp)
            selectedPairs = zeros(0,2);
        else
            temp = flipud(sortrows(temp));
            selectedPairs = temp(:,2:3);
        end
        
    else
        % If only pairs in selected movie file is selected
        filechoice = get(mainhandles.FilesListbox,'Value'); % Selected movie file
        selectedPairs = getPairs(mainhandle, 'File', filechoice);
    end
    
    % Delete pairs listed twice
    selectedPairs = unique(selectedPairs,'rows','stable');
    
    return
end
%% 'File'

if strcmpi(choice,'File') % Return a list with all FRET pairs in all files
    
    % For pre-allocation
    if isempty(subchoice)
        filechoices = get(mainhandles.FilesListbox,'Value'); % Selected movie file
    else
        filechoices = subchoice; % Filechoices sent as input arguments
    end
    npairs = 0;
    for i = 1:length(filechoices)
        filechoice = filechoices(i);
        npairs = npairs+length(mainhandles.data(filechoice).FRETpairs);
    end
    
    if npairs==0
        return
    end
    
    % Make selectedPairs
    selectedPairs = zeros(npairs,2);
    idx1 = 1;
    for i = 1:length(filechoices)
        filechoice = filechoices(i);
        npairs = length(mainhandles.data(filechoice).FRETpairs);
        if npairs>0
            idx2 = idx1+npairs-1;
            selectedPairs(idx1:idx2,:) = [ones(npairs,1)*filechoice [1:npairs]'];
            idx1 = idx2+1;
        end
    end
    
    return
end
%% 'Group'

if strcmpi(choice,'Group')
    % FRETpairwindow handles
    Epairs = size(getPairs(mainhandle,'all'),1);
    if isempty(mainhandles.data) || isequal(Epairs,0) ...
            || isempty(mainhandles.groups)
        return
    end
    
    % Return members of selected group
    if isempty(subchoice)
        if isempty(FRETpairwindowHandle) || (~ishandle(FRETpairwindowHandle))
            return
        end
        FRETpairwindowHandles = guidata(FRETpairwindowHandle);
        groupchoices = get(FRETpairwindowHandles.GroupsListbox,'Value');
    else
        groupchoices = subchoice;
    end
    
    % If subchoice was supplied as string specifying (single) group name
    if ischar(groupchoices)
        for i = 1:length(mainhandles.groups)
            if strcmpi(mainhandles.groups(i).name, groupchoices)
                groupchoices = i;
                break
            end
        end
    end
    if ischar(groupchoices)
        % If still char, there is no group called subchoice
        return
    end
    
    % Get all FRET-pairs in selected group, temp is for preallocation
    temp = [];
    for i = 1:length(mainhandles.data)
        for j = 1:length(mainhandles.data(i).FRETpairs)
            continued = 0;
            for g = 1:length(mainhandles.data(i).FRETpairs(j).group)
                if continued
                    continue
                end
                for k = 1:length(groupchoices)
                    % ismember is slow, hence the many for loops
                    % old: ismember(groupchoices(k),mainhandles.data(i).FRETpairs(j).group)
                    % new hotness (x10 faster):
                    if ~continued && groupchoices(k)==mainhandles.data(i).FRETpairs(j).group(g)
                        temp = [temp; i j];
                        continued = 1;
                        continue
                    end
                end
            end
        end
    end
    if ~isempty(temp)
        selectedPairs = zeros(size(temp));
        selectedPairs(:,1) = temp(:,1);
        selectedPairs(:,2) = temp(:,2);
    end
    
    % make sure the same molecule is not returned twice if its in 2 groups
    if ~isempty(selectedPairs)
        selectedPairs = unique(selectedPairs,'rows');
    end
    
    return
end
%% 'Bleach'

if strcmpi(choice,'Bleach')
    % For pre-allocation
    if isempty(subchoice)
        filechoices = 1:length(mainhandles.data);
    else
        filechoices = subchoice; % Filechoices sent as input arguments
    end
    npairs = 0;
    for i = 1:length(filechoices)
        filechoice = filechoices(i);
        for j = 1:length(mainhandles.data(filechoice).FRETpairs)
            if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DbleachingTime)) || (~isempty(mainhandles.data(filechoice).FRETpairs(j).AbleachingTime))
                npairs = npairs+1;
            end
        end
    end
    
    
    % Make pairs
    if npairs>0
        selectedPairs = zeros(npairs,2);
        run = 1;
        for i = 1:length(filechoices)
            filechoice = filechoices(i);
            for j = 1:length(mainhandles.data(filechoice).FRETpairs)
                if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DbleachingTime)) || (~isempty(mainhandles.data(filechoice).FRETpairs(j).AbleachingTime))
                    selectedPairs(run,:) = [filechoice j];
                    run = run+1;
                end
            end
        end
    end
    
    return
end
%% 'DAbleach'

if strcmpi(choice,'DAbleach')
    % For pre-allocation
    if isempty(subchoice)
        filechoices = 1:length(mainhandles.data);
    else
        filechoices = subchoice; % Filechoices sent as input arguments
    end
    npairs = 0;
    for i = 1:length(filechoices)
        filechoice = filechoices(i);
        for j = 1:length(mainhandles.data(filechoice).FRETpairs)
            if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DbleachingTime)) ...
                    && (~isempty(mainhandles.data(filechoice).FRETpairs(j).AbleachingTime))
                npairs = npairs+1;
            end
        end
    end
    
    
    % Make pairs
    if npairs>0
        selectedPairs = zeros(npairs,2);
        run = 1;
        for i = 1:length(filechoices)
            filechoice = filechoices(i);
            for j = 1:length(mainhandles.data(filechoice).FRETpairs)
                if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DbleachingTime)) && (~isempty(mainhandles.data(filechoice).FRETpairs(j).AbleachingTime))
                    selectedPairs(run,:) = [filechoice j];
                    run = run+1;
                end
            end
        end
    end
    
    return
end
%% 'Dbleach'

if strcmpi(choice,'Dbleach')
    % For pre-allocation
    if isempty(subchoice)
        filechoices = 1:length(mainhandles.data);
    else
        filechoices = subchoice; % Filechoices sent as input arguments
    end
    npairs = 0;
    for i = 1:length(filechoices)
        filechoice = filechoices(i);
        for j = 1:length(mainhandles.data(filechoice).FRETpairs)
            if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DbleachingTime))
                npairs = npairs+1;
            end
        end
    end
    
    
    % Make pairs
    if npairs>0
        selectedPairs = zeros(npairs,2);
        run = 1;
        for i = 1:length(filechoices)
            filechoice = filechoices(i);
            for j = 1:length(mainhandles.data(filechoice).FRETpairs)
                if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DbleachingTime))
                    selectedPairs(run,:) = [filechoice j];
                    run = run+1;
                end
            end
        end
    end
    
    return
end
%% 'Ableach'

if strcmpi(choice,'Ableach')
    % For pre-allocation
    if isempty(subchoice)
        filechoices = 1:length(mainhandles.data);
    else
        filechoices = subchoice; % Filechoices sent as input arguments
    end
    npairs = 0;
    for i = 1:length(filechoices)
        filechoice = filechoices(i);
        for j = 1:length(mainhandles.data(filechoice).FRETpairs)
            if (~isempty(mainhandles.data(filechoice).FRETpairs(j).AbleachingTime))
                npairs = npairs+1;
            end
        end
    end
    
    
    % Make pairs
    if npairs>0
        selectedPairs = zeros(npairs,2);
        run = 1;
        for i = 1:length(filechoices)
            filechoice = filechoices(i);
            for j = 1:length(mainhandles.data(filechoice).FRETpairs)
                if (~isempty(mainhandles.data(filechoice).FRETpairs(j).AbleachingTime))
                    selectedPairs(run,:) = [filechoice j];
                    run = run+1;
                end
            end
        end
    end
    
    return
end
%% 'Blink'

if strcmpi(choice,'Blink')
    % For pre-allocation
    if isempty(subchoice)
        filechoices = 1:length(mainhandles.data);
    else
        filechoices = subchoice; % Filechoices sent as input arguments
    end
    npairs = 0;
    for i = 1:length(filechoices)
        filechoice = filechoices(i);
        for j = 1:length(mainhandles.data(filechoice).FRETpairs)
            if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DblinkingInterval)) || (~isempty(mainhandles.data(filechoice).FRETpairs(j).AblinkingInterval))
                npairs = npairs+1;
            end
        end
    end
    
    
    % Make pairs
    if npairs>0
        selectedPairs = zeros(npairs,2);
        run = 1;
        for i = 1:length(filechoices)
            filechoice = filechoices(i);
            for j = 1:length(mainhandles.data(filechoice).FRETpairs)
                if (~isempty(mainhandles.data(filechoice).FRETpairs(j).DblinkingInterval)) || (~isempty(mainhandles.data(filechoice).FRETpairs(j).AblinkingInterval))
                    selectedPairs(run,:) = [filechoice j];
                    run = run+1;
                end
            end
        end
    end
    
    return
end
%% 'BlinkBleach'

if strcmpi(choice,'BlinkBleach')
    
    % Pairs with either bleaching or blinking
    bleachPairs = getPairs(mainhandle,'bleach');
    if isempty(bleachPairs)
        return
    end
    
    blinkPairs = getPairs(mainhandle,'blink');
    if isempty(blinkPairs)
        return
    end
    
    % Pairs with both bleaching and blinking
    selectedPairsPairs = bleachPairs(ismember(bleachPairs,blinkPairs,'rows','legacy'),:);
    
    return
end
%% 'missingTrace'

if strcmpi(choice,'missingTrace')
    % For pre-allocation
    npairs = 0;
    for i = 1:length(mainhandles.data)
        for j = 1:length(mainhandles.data(i).FRETpairs)
            if (isempty(mainhandles.data(i).FRETpairs(j).DDtrace)) ||...
                    (~isempty(mainhandles.data(i).DD_ROImovie) && ~isequal(length(mainhandles.data(i).FRETpairs(j).DDtrace), size(mainhandles.data(i).DD_ROImovie,3)))
                npairs = npairs+1;
            end
        end
    end
    
    % Make pairs
    if npairs>0
        selectedPairs = zeros(npairs,2);
        run = 1;
        for i = 1:length(mainhandles.data)
            for j = 1:length(mainhandles.data(i).FRETpairs)
                if (isempty(mainhandles.data(i).FRETpairs(j).DDtrace)) ||...
                        (~isempty(mainhandles.data(i).DD_ROImovie) && ~isequal(length(mainhandles.data(i).FRETpairs(j).DDtrace), size(mainhandles.data(i).DD_ROImovie,3)))
                    selectedPairs(run,:) = [i j];
                    run = run+1;
                end
            end
        end
    end
    
    return
end
%% 'Plotted'

if strcmpi(choice,'Plotted')
    if isempty(histogramwindowHandle) || ~ishandle(histogramwindowHandle)
        return
    end
    
    % Plotted FRET-pairs in histogramwindow:
    histogramwindowHandles = guidata(histogramwindowHandle);
    if get(histogramwindowHandles.plotSelectedPairRadiobutton,'Value') % If plotting only data-points from the FRET-pair selected in the FRETpairwindow GUI
        selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle);
    elseif get(histogramwindowHandles.plotSelectedGroupRadiobutton,'Value') % If plotting selected group
        selectedPairs = getPairs(mainhandle, 'Group', [], FRETpairwindowHandle);
    elseif get(histogramwindowHandles.plotAllPairsRadiobutton,'Value') % If plotting all FRETpairs
        selectedPairs = getPairs(mainhandle, 'All');
        removechoices = 1:length(mainhandles.data);
        filechoices = get(histogramwindowHandles.FilesListbox,'Value');
        for i = 1:length(removechoices)
            if ~ismember(removechoices(i),filechoices)
                selectedPairs(selectedPairs(:,1)==removechoices(i),:) = [];
            end
        end
    elseif get(histogramwindowHandles.plotAllWithBleachRadiobutton,'Value') % If plotting all FRETpairs with bleaching defined
        selectedPairs = getPairs(mainhandle, 'Bleach');
        if isempty(selectedPairs)
            return
        end
        
        removechoices = 1:length(mainhandles.data);
        filechoices = get(histogramwindowHandles.FilesListbox,'Value');
        for i = 1:length(removechoices)
            if ~ismember(removechoices(i),filechoices)
                selectedPairs(selectedPairs(:,1)==removechoices(i),:) = [];
            end
        end
        
    elseif get(histogramwindowHandles.plotAllExceptRadiobutton,'Value')
        % All pairs, except exceptchoice
        
        % All pairs
        selectedPairs = getPairs(mainhandle,'all');
        
        % Pairs not to show
        exceptchoice = mainhandles.settings.SEplot.exceptchoice;
        exceptPairs = [];
        if exceptchoice==1
            exceptPairs = getPairs(mainhandle,'selected');
        elseif exceptchoice==2
            filechoices = get(histogramwindowHandles.FilesListbox,'Value');
            exceptPairs = getPairs(mainhandle,'file',filechoices);
        elseif exceptchoice==3
            FRETpairwindowHandles = guidata(FRETpairwindowHandle);
            groupchoices = get(FRETpairwindowHandles.GroupsListbox,'Value');
            exceptPairs = getPairs(mainhandle,'group', groupchoices);
        end
        
        % Remove pairs
        if ~isempty(exceptPairs)
            idx = find(ismember(selectedPairs,exceptPairs,'rows')); % Indices of pairs to remove
            selectedPairs(idx,:) = [];
        end
        
    end
    
    if isempty(selectedPairs)
        return
    end
    
    % Remove pairs without correction factors determined
%     mainhandles.settings.corrections.molspec
    if (mainhandles.settings.SEplot.plotgammaspec || mainhandles.settings.SEplot.plotdleakspec || mainhandles.settings.SEplot.plotadirectspec)
%         mainhandles.settings.corrections.molspec ...
        temp = [];
        gIdx = [];
        dIdx = [];
        aIdx = [];
        for i = 1:size(selectedPairs,1)
            
            file = selectedPairs(i,1);
            pair = selectedPairs(i,2);
            d = mainhandles.data(file).FRETpairs(pair);
            
            % Check correction factors
            if (mainhandles.settings.SEplot.plotgammaspec ...
                    && (isempty(d.gamma) || (~isempty(d.gammaRemoved) && d.gammaRemoved)))
                gIdx = [gIdx i];
                temp = [temp i];
            end
            
            if (mainhandles.settings.SEplot.plotdleakspec ...
                    && (isempty(d.Dleakage) || (~isempty(d.DleakageRemoved) && d.DleakageRemoved)))
                dIdx = [dIdx i];
                temp = [temp i];
            end
            
            if (mainhandles.settings.SEplot.plotadirectspec ...
                    && (isempty(d.Adirect) || (~isempty(d.AdirectRemoved) && d.AdirectRemoved)))
                aIdx = [aIdx i];
                temp = [temp i];
            end
            
        end
        
        % Remove pairs with no determined correction factors
        if length(temp)<size(selectedPairs,1)
            selectedPairs(temp,:) = [];
            
        else
            % Dialog about no molecules with correction factors
            if size(selectedPairs,1)>1
                message = sprintf(['Note: You have selected "plot only molecules with correction factors determined" in the S-E plot.\n'...
                    'However, no molecules of the current plot-selection has individual correction factors. \nAll selected molecules are therefore plotted.']);
            else
                message = sprintf(['Obs: You have selected "Plot only molecules with correction factors determined" in the S-E plot.\n'...
                    'However, the selected molecule has no correction factor determined.']);
            end
            
            mainhandles = myguidebox(mainhandles,'Individualized corrections',message,'plotmolspec');
        end
    end
    
    return
end
%% 'Dynamics'

if strcmpi(choice,'Dynamics')
    % For pre-allocation
    npairs = 0;
    for i = 1:length(mainhandles.data)
        for j = 1:length(mainhandles.data(i).FRETpairs)
            if ~isempty(mainhandles.data(i).FRETpairs(j).vbfitE_fit)
                npairs = npairs+1;
            end
        end
    end
    
    % Find FRET pairs
    if npairs == 0
        return
    end
    selectedPairs = zeros(npairs,2);
    run = 1;
    for i = 1:length(mainhandles.data)
        for j = 1:length(mainhandles.data(i).FRETpairs)
            if ~isempty(mainhandles.data(i).FRETpairs(j).vbfitE_fit)
                selectedPairs(run,:) = [i j];
                run = run+1;
            end
        end
    end
    
    return
end
%% 'dynamicsSelected'

if strcmpi(choice,'dynamicsSelected')
    if isempty(dynamicswindowHandle) || ~ishandle(dynamicswindowHandle)
        return
    end
    
    % Get listed pairs
    listedPairs = getPairs(mainhandle, 'Dynamics');
    if isempty(listedPairs)
        return
    end
    
    % Selected pairs
    dynamicswindowHandles = guidata(dynamicswindowHandle);
    pairchoices = get(dynamicswindowHandles.PairListbox,'Value');
    if size(listedPairs,1) < pairchoices(end) % Check if selected value is greater than number of list items
        set(dynamicswindowHandles.PairListbox,'Value',size(listedPairs,1))
        pairchoices = get(dynamicswindowHandles.PairListbox,'Value');
    elseif isempty(pairchoices) || (length(pairchoices)==1 && pairchoices==0)
        pairchoices = 1;
        set(dynamicswindowHandles.PairListbox,'Value',1)
    end
    selectedPairs = listedPairs(pairchoices,:); % Pairs selected in the dynamics window [file pair;...]
    
    return
end
%% 'Dleakage'

if strcmpi(choice,'Dleakage') % Molecules applicable for calculating the D leakage factor
    AbleachPairs = getPairs(mainhandle, 'Ableach');
    if isempty(AbleachPairs)
        return
    end
    
    % Check for applicable pairs within all with A bleaching
    for i = 1:size(AbleachPairs,1)
        filechoice = AbleachPairs(i,1); % Movie file
        pairchoice = AbleachPairs(i,2); % FRET-pair
        pair = mainhandles.data(filechoice).FRETpairs(pairchoice); % FRET pair i
        
        % Check if pair has been removed from the correction factor list
        if ~isempty(pair.DleakageRemoved)
            continue
        end
        
        % Check for frames available for correction factor calculation
        bD = pair.DbleachingTime; % Donor bleaching time
        bA = pair.AbleachingTime; % Acceptor bleaching time
        if isempty(bD)
            bD = length(pair.DDtrace); % If D hasn't been specified, set it to the final frame
        end
        
        spacer = mainhandles.settings.corrections.spacer;
        minframes = mainhandles.settings.corrections.minframes;
        
        % Donor leakage factor is AD/DD for D-only species
        if bD+spacer>bA-spacer && bD-2*spacer-bA>=minframes
            selectedPairs(end+1,:) = [filechoice pairchoice];
        end
    end
    
    return
end
%% 'Adirect'

if strcmpi(choice,'Adirect') % Molecules applicable for calculating A direct correction factor

    if ~mainhandles.settings.excitation.alex
        % A direct for single-color scheme not implemented yet
        return
    end
    
    DbleachPairs = getPairs(mainhandle, 'Dbleach');
    if isempty(DbleachPairs)
        return
    end
    
    % Check for applicable pairs within all with A bleaching
    for i = 1:size(DbleachPairs,1)
        filechoice = DbleachPairs(i,1); % Movie file
        pairchoice = DbleachPairs(i,2); % FRET-pair
        pair = mainhandles.data(filechoice).FRETpairs(pairchoice); % FRET pair i
        
        % Check if pair has been removed from the correction factor list
        if ~isempty(pair.AdirectRemoved)
            continue
        end
        
        % Check for frames available for correction factor calculation
        bD = pair.DbleachingTime; % Donor bleaching time
        bA = pair.AbleachingTime; % Acceptor bleaching time
        if isempty(bA)
            bA = length(pair.ADtrace); % If D hasn't been specified, set it to the final frame
        end
        
        spacer = mainhandles.settings.corrections.spacer;
        minframes = mainhandles.settings.corrections.minframes;
        
        % Direct A factor is AD/AA for A-only species
        if bA+spacer>bD-spacer && bA-2*spacer-bD>=minframes
            selectedPairs(end+1,:) = [filechoice pairchoice];
        end
    end
    
    return
end
%% 'gamma'

if strcmpi(choice,'gamma') % Molecules applicable for calculating the gamma factor
    AbleachPairs = getPairs(mainhandle, 'Ableach');
    if isempty(AbleachPairs)
        return
    end
    
    % Check for applicable pairs within all with A bleaching
    for i = 1:size(AbleachPairs,1)
        filechoice = AbleachPairs(i,1); % Movie file
        pairchoice = AbleachPairs(i,2); % FRET-pair
        pair = mainhandles.data(filechoice).FRETpairs(pairchoice); % FRET pair i
        
        % Check if pair has been removed from the correction factor list
        if ~isempty(pair.gammaRemoved)
            continue
        end
        
        % Check for frames available for correction factor calculation
        bD = pair.DbleachingTime; % Donor bleaching time
        bA = pair.AbleachingTime; % Acceptor bleaching time
        if isempty(bD)
            bD = length(pair.DDtrace); % If D hasn't been specified, set it to the final frame
        end
        
        spacer = mainhandles.settings.corrections.spacer;
        minframes = mainhandles.settings.corrections.minframes;
        gammaframes = mainhandles.settings.corrections.gammaframes; % No. of frames used on either side of A bleaching
        
        if (bD-spacer>bA+spacer) && bD-2*spacer-bA>=minframes
            % Frames used for AD
            if bA-spacer>gammaframes % If full interval can be used prior bleaching
                Aidx1 = bA-spacer-gammaframes;
            else
                Aidx1 = 1;
            end
            if bA+spacer+gammaframes<bD-spacer % If full interval can be used post bleaching
                Aidx2 = bA+spacer+gammaframes;
            else
                Aidx2 = bD-spacer;
            end
            % Frames used for DD
            if bA-spacer>gammaframes % If full interval can be used prior bleaching
                Didx1 = bA-spacer-gammaframes;
            else
                Didx1 = 1;
            end
            if bA+spacer+gammaframes<bD-spacer % If full interval can be used post bleaching
                Didx2 = bA+spacer+gammaframes;
            else
                Didx2 = bD-spacer;
            end
            
            % If there are enough frames available
            if (bA-spacer)-Aidx1>=minframes && Aidx2-(bA+spacer)>=minframes && (bA-spacer)-Didx1>=minframes && Didx2-(bA+spacer)>=minframes
                selectedPairs(end+1,:) = [filechoice pairchoice];
            end
        end
    end
    
    return
end
%% 'correctionSelected'

if strcmpi(choice,'correctionSelected')
    if isempty(correctionfactorwindowHandle) || ~ishandle(correctionfactorwindowHandle)
        return
    end
    
    % Get listed pairs
    listedPairs = getPairs(mainhandle, 'correctionListed', [],[],[], correctionfactorwindowHandle);
    if isempty(listedPairs)
        return
    end
    
    % Selected pairs
    correctionfactorwindowHandles = guidata(correctionfactorwindowHandle);
    pairchoices = get(correctionfactorwindowHandles.PairListbox,'Value');
    
    if isempty(pairchoices)
        set(correctionfactorwindowHandles.PairListbox,'Value',1)
        return
    end
    
    if size(listedPairs,1) < pairchoices(end) % Check if selected value is greater than number of list items
        set(correctionfactorwindowHandles.PairListbox,'Value',size(listedPairs,1))
        pairchoices = get(correctionfactorwindowHandles.PairListbox,'Value');
    elseif isempty(pairchoices) || (length(pairchoices)==1 && pairchoices==0)
        pairchoices = 1;
        set(correctionfactorwindowHandles.PairListbox,'Value',1)
    end
    selectedPairs = listedPairs(pairchoices,:); % Pairs selected in the dynamics window [file pair;...]
    
    return
end
%% 'correctionListed'

if strcmpi(choice,'correctionListed')
    if isempty(correctionfactorwindowHandle) || ~ishandle(correctionfactorwindowHandle)
        return
    end
    
    % Get listed pairs
    if mainhandles.settings.correctionfactorplot.factorchoice == 1 % Donor leakage pairs
        selectedPairs = getPairs(mainhandle, 'Dleakage');
    elseif mainhandles.settings.correctionfactorplot.factorchoice == 2 % Direct A pairs
        selectedPairs = getPairs(mainhandle, 'Adirect');
    elseif mainhandles.settings.correctionfactorplot.factorchoice == 3 % Gamma factor pairs
        selectedPairs = getPairs(mainhandle, 'gamma');
    end
    
    % Sort
    if mainhandles.settings.correctionfactorplot.sortpairs==1
        % Sort according to file (already done)
        return
        
    elseif mainhandles.settings.correctionfactorplot.sortpairs==2
        
        % Sort according to factor value
        if mainhandles.settings.correctionfactorplot.factorchoice == 1
            selectedPairs = sortpairs(selectedPairs, 'Dleakage');
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 2
            selectedPairs = sortpairs(selectedPairs, 'Adirect');
        else
            selectedPairs = sortpairs(selectedPairs, 'gamma');
        end
        
    elseif mainhandles.settings.correctionfactorplot.sortpairs==3
        
        % Sort according to group
        
        selectedPairs = sortpairs(selectedPairs, 'group');
        
    elseif mainhandles.settings.correctionfactorplot.sortpairs==4
        
        % Sort according to E
        selectedPairs = sortpairs(selectedPairs, 'avgE');
        
    elseif mainhandles.settings.correctionfactorplot.sortpairs==5
        
        % Sort according to S
        selectedPairs = sortpairs(selectedPairs, 'avgS');
        
    elseif mainhandles.settings.correctionfactorplot.sortpairs==6
        
        % Sort according to factor std. dev.
        if mainhandles.settings.correctionfactorplot.factorchoice == 1
            selectedPairs = sortpairs(selectedPairs, 'DleakageVar');
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 2
            selectedPairs = sortpairs(selectedPairs, 'AdirectVar');
        else
            selectedPairs = sortpairs(selectedPairs, 'gammaVar');
        end
    end
    
    return
end
%% 'driftListed'

if strcmpi(choice,'driftListed')
    if isempty(driftwindowHandle) || ~ishandle(driftwindowHandle)
        return
    end
    
    % driftwindow handles structure
    driftwindowHandles = guidata(driftwindowHandle);
    
    % Listed pairs
    filechoice = get(driftwindowHandles.FilesListbox,'Value'); % Selected movie file (only 1 file can be selected at the time)
    if isempty(filechoice) || (length(filechoice)==1 && filechoice==0)
        return
    end
    selectedPairs = getPairs(mainhandle, 'File', filechoice);
    
    return
end
%% 'driftSelected'

if strcmpi(choice,'driftSelected')
    if isempty(driftwindowHandle) || ~ishandle(driftwindowHandle)
        return
    end
    
    % driftwindow handles structure
    driftwindowHandles = guidata(driftwindowHandle);
    
    % Listed pairs
    listedPairs = getPairs(mainhandle, 'driftListed', [],[],[],[], driftwindowHandle);
    if isempty(listedPairs)
        return
    end
    
    % Selected pair
    pairchoice = get(driftwindowHandles.PairListbox,'Value'); % Selected pair (only 1 pair can be selected at the time)
    if isempty(pairchoice) || (length(pairchoice)==1 && pairchoice==0)
        return
    end
    selectedPairs = listedPairs(pairchoice,:);
    
    return
end
%% 'photonSelected'

if strcmpi(choice,'photonSelected')
    if isempty(integrationwindowHandle) || ~ishandle(integrationwindowHandle)
        return
    end
    
    % integrationsettingsWindow handles structure
    integrationwindowHandles = guidata(integrationwindowHandle);
    
    % Listed pairs
    listedPairs = getPairs(mainhandle, 'all');
    if isempty(listedPairs)
        return
    end
    
    % Selected pair
    pairchoice = get(integrationwindowHandles.PairListbox,'Value');
    if isempty(pairchoice) || (length(pairchoice)==1 && pairchoice==0)
        return
    end
    selectedPairs = listedPairs(pairchoice,:);
    
    return
end
%% 'psfwindowSelected'

if strcmpi(choice,'psfwindowSelected')
    if isempty(psfwindowHandle) || ~ishandle(psfwindowHandle)
        return
    end
    
    % integrationsettingsWindow handles structure
    psfwindowHandles = guidata(psfwindowHandle);
    
    % Listed pairs
    listedPairs = getPairs(mainhandle, 'all');
    if isempty(listedPairs)
        return
    end
    
    % Selected pair
    pairchoice = get(psfwindowHandles.PairListbox,'Value');
    if isempty(pairchoice) || (length(pairchoice)==1 && pairchoice==0)
        return
    end
    selectedPairs = listedPairs(pairchoice,:);
    
    return
end
%% 'psf'

if strcmpi(choice,'psf')
    % Channel
    if isempty(subchoice)
        subchoice = 'AA';
    end
    
    % For pre-allocation
    npairs = 0;
    for i = 1:length(mainhandles.data)
        for j = 1:length(mainhandles.data(i).FRETpairs)
            
            if strcmpi(subchoice,'DD') && ~isempty(mainhandles.data(i).FRETpairs(j).DDGaussianTrace)
                npairs = npairs+1;
            elseif strcmpi(subchoice,'AD') && ~isempty(mainhandles.data(i).FRETpairs(j).ADGaussianTrace)
                npairs = npairs+1;
            elseif strcmpi(subchoice,'AA') && ~isempty(mainhandles.data(i).FRETpairs(j).AAGaussianTrace)
                npairs = npairs+1;
            elseif strcmpi(subchoice,'all') && ~isempty(mainhandles.data(i).FRETpairs(j).DDGaussianTrace)...
                    && ~isempty(mainhandles.data(i).FRETpairs(j).ADGaussianTrace)...
                    && ~isempty(mainhandles.data(i).FRETpairs(j).AAGaussianTrace)
                npairs = npairs+1;
            end
            
        end
    end
    
    % Find FRET pairs
    if npairs == 0
        return
    end
    selectedPairs = zeros(npairs,2);
    run = 1;
    for i = 1:length(mainhandles.data)
        for j = 1:length(mainhandles.data(i).FRETpairs)
            if strcmpi(subchoice,'DD') && ~isempty(mainhandles.data(i).FRETpairs(j).DDGaussianTrace)
                selectedPairs(run,:) = [i j];
                run = run+1;
            elseif strcmpi(subchoice,'AD') && ~isempty(mainhandles.data(i).FRETpairs(j).ADGaussianTrace)
                selectedPairs(run,:) = [i j];
                run = run+1;
            elseif strcmpi(subchoice,'AA') && ~isempty(mainhandles.data(i).FRETpairs(j).AAGaussianTrace)
                selectedPairs(run,:) = [i j];
                run = run+1;
            elseif strcmpi(subchoice,'all') && ~isempty(mainhandles.data(i).FRETpairs(j).DDGaussianTrace)...
                    && ~isempty(mainhandles.data(i).FRETpairs(j).ADGaussianTrace)...
                    && ~isempty(mainhandles.data(i).FRETpairs(j).AAGaussianTrace)
                selectedPairs(run,:) = [i j];
                run = run+1;
            end
        end
    end
    
    return
end
%% 'bin'

if strcmpi(choice,'bin')
    
    % Pairs in the recycle bin are in the group called 'Recycle bin'
    selectedPairs = getPairs(mainhandle,'group','Recycle bin');
    return
end
%% Nested

    function selectedPairs = sortpairs(selectedPairs, choice)
        if isempty(selectedPairs)
            return
        end
        
        % Initialize
        temp = zeros(size(selectedPairs,1),3);
        temp(:,2:3) = selectedPairs; % Selected pairs including avg E
        
        % Get all values
        for ii = 1:size(temp,1)
            file = selectedPairs(ii,1);
            pair = selectedPairs(ii,2);
            
            % Calculate avg. E or S, if missing
            if isempty(mainhandles.data(file).FRETpairs(pair).(choice))
                mainhandles = calculateAvgTrace(mainhandle,choice(end),[file pair]);
            end
            
            % Store value
            if ~isempty(mainhandles.data(file).FRETpairs(pair).(choice))
                temp(ii,1) = mainhandles.data(file).FRETpairs(pair).(choice)(1);
            end
        end
        
        % Sort according to value
        temp = flipud( sortrows(temp) );
        selectedPairs = temp(:,2:3);
        
    end

end