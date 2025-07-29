function [mainhandles, fpwHandles] = bleachfinderCallback(mainhandle, files, waitbarchoice)
% Callback for the automated bleachfinder in the FRETpairwindow
%
%    Input:
%     mainhandle              - handle to the main window
%     files                   - files to analyse [default:all]
%     waitbarchoice           - 0/1 whether to show waitbar
%
%    Output:
%     mainhandles             - handles structure of the main window
%     fpwHandles              - handles structure of the FRETpair window
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

% Get main handles structure
mainhandles = guidata(mainhandle);

% Default
if nargin<2 || isempty(files)
    files = 1:length(mainhandles.data);
end
if nargin<3 || isempty(waitbarchoice)
    waitbarchoice = 1;
end

% Handle to FRET pair window
fpwHandle = mainhandles.FRETpairwindowHandle;
if ~isempty(fpwHandle) && ishandle(fpwHandle)
    fpwHandles = guidata(fpwHandle);
else
    fpwHandles = [];
end

% All FRET pairs
selectedPairs = getPairs(mainhandle, 'file',files);

%% Detect if some traces already have bleaching defined, then show dialog

bleachedPairs = getPairs(mainhandle, 'Bleach');
if ~isempty(bleachedPairs) && ismember(1,ismember(files,bleachedPairs(:,1)))
    
    % Dialog
    choice = myquestdlg(...
        sprintf('There are %i pairs with bleaching times defined already. Do you wish to auto-detect bleaching in these too?',size(bleachedPairs,1)),...
        'Detect bleaching',...
        'Yes, analyse all pairs','No, only analyse pairs without bleaching','Specify subset of pairs','Yes, analyse all pairs');
    
    % User pressed X
    if isempty(choice)
        return
    end
    
    % Only use subset of pairs
    if strcmpi(choice,'No, only pairs without bleaching')
        selectedPairs(ismember(selectedPairs,bleachedPairs,'rows','legacy'),:) = [];

    elseif strcmpi(choice,'Specify subset of pairs')
        
        selectedPairs = getPairs(mainhandle,'all');
        
        % Dialog for specifying pairs to analyse
        if ~isempty(fpwHandles)
            
            % FRET pair window is open
            liststr = getFRETpairString(mainhandle,fpwHandle);
            defans = get(fpwHandles.PairListbox,'Value');
        else
            
            % FRET pair window is not open
            npairs = size(selectedPairs,1);
            liststr = cell(npairs,1);
            for i = 1:npairs
                file = selectedPairs(i,1);
                pair = selectedPairs(i,2);
                
                % If listing all files files add file suffix
                liststr{i} = sprintf('%i,%i', file, pair); % Change listbox string
            end
            defans = 1;
        end
        
        % Open dialog
        answer = mylistdlg('ListString',liststr,...
            'SelectionMode','multiple',...
            'InitialValue', defans,...
            'Name','Select pairs');

        if isempty(answer)
            return
        end
        
        % Choice
        selectedPairs = selectedPairs(answer,:);
    end
end

%% More initialization

if isempty(selectedPairs)
    return
end

% Info box
str = sprintf(['Note: The performance of the bleachfinder is very dependent on intensity threshold settings.\n\n'...
    'Set the thresholds in the bleachfinder settings menu and save the optimized thresholds as defaults.']);
mainhandles = myguidebox(mainhandles,'Bleachfinder',str,'bleachfinder',1,...
    'http://isms.au.dk/documentation/bleaching-and-blinking/automated-detection-of-bleaching/');

% Turn on waitbar
if waitbarchoice
    hWaitbar = mywaitbar(0,'Finding bleaching events. Please wait...','name','iSMS');
    setFigOnTop % Sets the waitbar so that it is always in front
end

% Bleachfinder settings
allow = mainhandles.settings.bleachfinder.allow;

% For calculating new intensities based on bleach times
newIntensityPairs = [];

%% Detect bleaching times

AidxAll = {};
DidxAll = {};
for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    % Start by clearing previous data
    mainhandles = clearBleachingTime(mainhandles,[file pair],0);
    
    % Get sum trace
    sumDA = mainhandles.data(file).FRETpairs(pair).ADtrace+mainhandles.data(file).FRETpairs(pair).DDtrace;
    
    % Old used FRET-corrected traces, however, this makes the bleachfinder
    % very dependent on correction factor settings. We don't want that.
%     gamma = getGamma(mainhandles,[file pair]);
%     sumDA = mainhandles.data(file).FRETpairs(pair).ADtraceCorr+gamma*mainhandles.data(file).FRETpairs(pair).DDtrace;
    
    % Initialize
    Didx = mainhandles.data(file).FRETpairs(pair).DbleachingTime;
    Aidx = mainhandles.data(file).FRETpairs(pair).AbleachingTime;
    
    % Detect bleaching
    if mainhandles.settings.bleachfinder.findD
        Didx = detectTraceBleach(sumDA, mainhandles.settings.bleachfinder.Dthreshold); % Donor bleaching
    end
    if mainhandles.settings.bleachfinder.findA
        if mainhandles.settings.excitation.alex
            Aidx = detectTraceBleach(mainhandles.data(file).FRETpairs(pair).AAtrace, mainhandles.settings.bleachfinder.Athreshold);
        else
            Aidx = detectADtraceBleach();
        end
    end
    
    % Store
    DidxAll{end+1} = Didx;
    AidxAll{end+1} = Aidx;
    
    % Put result in mainhandles structure
    mainhandles.data(file).FRETpairs(pair).AbleachingTime = Aidx;
    mainhandles.data(file).FRETpairs(pair).DbleachingTime = Didx;
    
    % Make pair re-applicable for correction factor calculation
    if ~isempty(Aidx) || ~isempty(Didx)
        
        % Calculate new intensity trace if bleach background is being used
        if mainhandles.settings.background.bleachchoice
            newIntensityPairs = [newIntensityPairs; file pair];
        end
    end
    
end

%% Calculate new background

if ~isempty(newIntensityPairs)
    waitbar(0.5,hWaitbar,'Calculating new backgrounds...')
    updatemainhandles(mainhandles)
    [mainhandles, fpwHandles] = calculateIntensityTraces(mainhandle, newIntensityPairs);
end

%% Update

if waitbarchoice
    waitbar(1,hWaitbar,'Updating plots...')
end

updatemainhandles(mainhandles)
[fpwHandles,mainhandles] = updateFRETpairplots(mainhandle,mainhandles.FRETpairwindowHandle,'traces','all');
fpwHandles = updateMoleculeFrameSliderHandles(mainhandle,mainhandles.FRETpairwindowHandle);
updateBleachCounters(mainhandle,mainhandles.FRETpairwindowHandle)

% Update FRET pair listbox
% if mainhandles.settings.
    
    
% Update correction factor window
ok = 0; % Put focus back to FRET pair window?
listedPairs = getPairs(mainhandle, 'correctionListed', [],[],[], mainhandles.correctionfactorwindowHandle);

if ismember(1,ismember(selectedPairs,listedPairs,'rows','legacy'))
    updateCorrectionFactorPairlist(mainhandle,mainhandles.correctionfactorwindowHandle)
    plottedPairs = getPairs(mainhandle,'correctionSelected', [],[],[], mainhandles.correctionfactorwindowHandle);
    
    if ismember(1,ismember(selectedPairs,plottedPairs,'rows','legacy'))
        updateCorrectionFactorPlots(mainhandle,mainhandles.correctionfactorwindowHandle)
        ok = 1;
    end
end

% If histogram is open update the histogram
plottedPairs = getPairs(mainhandle, 'Plotted', [], mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle);
if ismember(1,ismember(selectedPairs,plottedPairs,'rows','legacy'))
    histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);
    
    if mainhandles.settings.SEplot.plotBleaching~=1
        mainhandles = updateSEplot(mainhandle,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
        ok = 1;
    end
end

% Put focus back to FRETpairwindow
if ok
    try figure(mainhandles.FRETpairwindowHandle), end
end

% Delete the waitbar
try delete(hWaitbar), end

%% Nested

    function idx = detectTraceBleach(I,threshold)
        idx = [];
        
        % Median filter
        I = medianSmoothFilter(I,7); % Apply median filter
        
        if length(I)>allow+1 && ismember(1, I(end-allow:end)<threshold) % If one of the last frames is below threshold
            run = 0; % Parameter counting how many consecutive frames is above threshold
            for j = length(I):-1:1
                if I(j)<threshold
                    idx = j;
                    run = 0;
                else
                    run = run+1;
                    if run>allow
                        break
                    end
                end
            end
            
            % If bleaching was identified as one of the very last or
            % first frames, ignore it
            if ~isempty(idx) && (idx>=length(I)-allow ...
                    || idx<2)
                idx = [];
            end
        end
        
    end

    function Aidx = detectADtraceBleach()
        Aidx = [];
        I = mainhandles.data(file).FRETpairs(pair).ADtraceCorr;
        
        % Median filter
        I = medianSmoothFilter(I,11); % Apply median filter
        
        if isempty(Didx)
            
            last = length(I);
            first = Didx+2;
            threshold = mainhandles.settings.bleachfinder.Dthreshold*2;
            sumDA = medianSmoothFilter(sumDA,7); % Apply median filter
            
            if length(I)>allow+1 && ismember(1, I(end-allow:end)<threshold) % If one of the last frames is below threshold
                run = 0; % Parameter counting how many consecutive frames is above threshold
                for j = last-2:-1:first
                    if I(j)<threshold && sumDA>mainhandles.settings.bleachfinder.Athreshold
                        Aidx = j;
                        run = 0;
                    else
                        run = run+1;
                        if run>allow
                            break
                        end
                    end
                end
                
                % If bleaching was identified as one of the very last or
                % first frames, ignore it
                if ~isempty(Aidx) && Aidx<2
                    Aidx = [];
                end
            end
            
        else
            last = Didx;
            first = 2;
            threshold = mainhandles.settings.bleachfinder.Dthreshold;
            
            if length(I)>allow+1 && ismember(1, I(end-allow:end)<threshold) % If one of the last frames is below threshold
                run = 0; % Parameter counting how many consecutive frames is above threshold
                for j = last-2:-1:first
                    if I(j)<threshold
                        Aidx = j;
                        run = 0;
                    else
                        run = run+1;
                        if run>allow
                            break
                        end
                    end
                end
                
                % If bleaching was identified as one of the very last or
                % first frames, ignore it
                if ~isempty(Aidx) && Aidx<4
                    Aidx = [];
                end
            end

        end
        
        
    end

end