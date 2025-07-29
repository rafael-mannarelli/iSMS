function mainhandles = findEpairsCallback(mainhandles, slidercall, file, updatepeakplotChoice)
% Callback for toolbar button for finding FRET-pairs in the main window
%
%    Input:
%     mainhandles   - handles structure of the main window
%     slidercall    - 0/1 whether function was called from a peak slider
%     file          - file to analyse
%     updatepeakplotChoice - 0/1 whether to run updatepeakplot
%
%    Output:
%     mainhandles    - ..
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

mainhandles = turnofftoggles(mainhandles,'all');% Turns off all selection toggles
if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end

% Default
if nargin<2 || isempty(slidercall)
    slidercall = 0;
end
if nargin<3 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value'); % Selected movie file
end
if nargin<4 || isempty(updatepeakplotChoice)
    updatepeakplotChoice = 1;
end

if ~slidercall % If function is not being called from one of the peak sliders
    % Turn on D, A and E peaks
    if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
        set(mainhandles.Toolbar_DPeaksToggle,'state','on')
    end
    if strcmp(get(mainhandles.Toolbar_APeaksToggle,'State'),'off')
        set(mainhandles.Toolbar_APeaksToggle,'state','on')
    end
    if strcmp(get(mainhandles.Toolbar_EPeaksToggle,'State'),'off')
        set(mainhandles.Toolbar_EPeaksToggle,'state','on')
    end
    
    % If there are not both donor and acceptor peaks run peakfinder
    if isempty(mainhandles.data(file).Dpeaks) || isempty(mainhandles.data(file).Apeaks)
        mainhandles = findpeaksCallback(mainhandles,file,1);
    end
    
else
    % Function was called from one of the peak sliders
    
    % If there are not both donor and acceptor peaks, return
    if isempty(mainhandles.data(file).Dpeaks) || isempty(mainhandles.data(file).Apeaks)
        return
    end
    
    if strcmp(get(mainhandles.Toolbar_EPeaksToggle,'State'),'off')
        set(mainhandles.Toolbar_EPeaksToggle,'state','on')
    end
end

%% Find all donor-acceptor pairs within distance criteria

Dpeaks = mainhandles.data(file).Dpeaks;
Apeaks = mainhandles.data(file).Apeaks;
if isempty(Dpeaks) || isempty(Apeaks)
    return
end

criteria = mainhandles.settings.peakfinder.Ecriteria; % Donor-acceptor distance criteria /pixel separation

% Distance between all donor and acceptor peaks [size(Dpeaks)]
[x1 x2] = meshgrid(Apeaks(:,1),Dpeaks(:,1));
[y1 y2] = meshgrid(Apeaks(:,2),Dpeaks(:,2));
alldist = sqrt( single((x2-x1).^2+(y2-y1).^2) );

% All donor acceptor pairs separated within the distance criteria
[Ds,As] = find(alldist<criteria);

% Put found FRET-pairs into handles structure
for i = 1:length(Ds)
    mainhandles.data(file).FRETpairs(end+1).Dxy = Dpeaks(Ds(i),:);
    mainhandles.data(file).FRETpairs(end).Axy = Apeaks(As(i),:);
end

% Update coordinates in global frame
mainhandles = updatepeakglobal(mainhandles,'FRET',file); % Updates the peak coordinates in the global window frame,

%% Update GUIs

% Update handles structure
updatemainhandles(mainhandles)

% The updatepeakplot updates the peaks on the ROI image, removes FRET-pairs
% detected twice and FRET-pairs where the donor or acceptor is part of
% another FRET-pair, both via updateFRETpairs, and updates the
% FRETpairwindow, via updateFRETpairlist
if updatepeakplotChoice
    mainhandles = updatepeakplot(mainhandles,'FRET');
else
    mainhandles = updateDApeaks(mainhandles); % Removes DA peaks listed twice
    mainhandles = updateFRETpairs(mainhandles,file); % Removes FRETpairs listed twice or consisting of deleted
end

% Update the intensity traces, if the FRETpair window is open
ok = 0;
if (strcmp(get(mainhandles.Toolbar_FRETpairwindow,'State'),'on')) && (~isempty(Ds))
    if (isempty(mainhandles.data(file).DD_ROImovie)) || (isempty(mainhandles.data(file).AD_ROImovie)) || (isempty(mainhandles.data(file).AA_ROImovie))
        [mainhandles,MBerror] = saveROImovies(mainhandles);  % Saves ROI movies to handles structure if not already done so
        if MBerror % If couldn't save ROI movies due to lack of memory, return
            return
        end
    end
    
    updatemainhandles(mainhandles)
    pairs = length(mainhandles.data(file).FRETpairs);
    selectedPairs = [ones(pairs,1)*file  [1:pairs]'];
    mainhandles = calculateIntensityTraces(mainhandles.figure1, selectedPairs);
    FRETpairwindowHandles = updateFRETpairplots(mainhandles.figure1,mainhandles.FRETpairwindowHandle,'all','all');
    
    ok = 1;
end

% If number of FRET-pairs has changed, update the histogramwindow if it's open
if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on'))
    mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
    ok = 1;
end

if ok
    figure(mainhandles.figure1)
end
