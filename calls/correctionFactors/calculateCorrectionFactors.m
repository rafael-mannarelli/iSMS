function mainhandles = calculateCorrectionFactors(mainhandle,selectedPairs,factorchoice,resetchoice)
% Calculates correction factors (Dleak, Adirect, gamma) of selectedPairs
%
%     Input:
%      mainhandle   - handle to the main window (sms)
%      selectedPair - pairs to calculate [file pair;...]
%      factorchoice - 'Dleakage', 'Adirect', 'gamma', 'all'
%      resetchoice  - binary parameter setting whether to force a
%                     re-calculation of the intervals used for the
%                     correction factor
%
%     Output:
%      mainhandles  - handles structure of the main window

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

% Set defaults
if nargin<2
    selectedPairs = getPairs(mainhandle, 'all');
end
if nargin<3
    factorchoice = 'all';
end
if nargin<4
    resetchoice = 0;
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)

% If there is no data, return
if (isempty(mainhandles.data)) || isempty(selectedPairs)
    return
end

%% Calculate correction factors

spacer = mainhandles.settings.corrections.spacer; % Fill frames in between bleaching and interval used for calculating the correction factors
minframes = mainhandles.settings.corrections.minframes; % Minimum no. frames allowed for correction factor calculation
for i = 1:size(selectedPairs,1)
    
    % Initialize pair
    file = selectedPairs(i,1); % Movie file
    pairchoice = selectedPairs(i,2); % FRET-pair
    pair = mainhandles.data(file).FRETpairs(pairchoice); % FRET pair i
    
    % Initialize bleaching times
    bD = pair.DbleachingTime; % Donor bleaching time
    bA = pair.AbleachingTime; % Acceptor bleaching time
    if isempty(bD)
        bD = length(pair.DDtrace); % If D hasn't been specified, set it to the final frame
    end
    if isempty(bA)
        bA = length(pair.ADtrace); % If A hasn't been specified, set it to the final frame
    end
    
    % Donor leakage factor. This is AD/DD for D-only species
    if strcmpi(factorchoice,'Dleakage') || strcmpi(factorchoice,'all')
        
        mainhandles = calculateDleakage(mainhandles);
        
    end
    
    % Direct A excitation. This is AD/AA for A-only species
    if strcmpi(factorchoice,'Adirect') || strcmpi(factorchoice,'all')
        
        mainhandles = calculateAdirect(mainhandles);
        
    end
    
    % Gamma factor. This is (ADpre-ADpost)/(DDpost-DDpre) across
    % acceptor bleaching events (~20 frames pre and 20 post bleach)
    if strcmpi(factorchoice,'gamma') || strcmpi(factorchoice,'all')
        
        mainhandles = calculateGamma(mainhandles);
        
    end
    
end

%% Update

updatemainhandles(mainhandles)

% Update traces if using molecule specific correction factors
if mainhandles.settings.corrections.molspec
    mainhandles = correctTraces(mainhandle,selectedPairs);
    
    % Update FRET pair window
    selectedFRETpairs = getPairs(mainhandle,'Selected');
    if ~isempty(selectedFRETpairs) && ismember(1,ismember(selectedFRETpairs,selectedPairs))
        [FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandle, mainhandles.FRETpairwindowHandle, 'traces','ADcorrect');
        updateCorrectionFactors(mainhandle, mainhandles.FRETpairwindowHandle)
    end
    
    % Update SE window
    plottedPairs = getPairs(mainhandle,'Plotted');
    if ~isempty(plottedPairs) && ismember(1,ismember(plottedPairs,selectedPairs))
        mainhandles = updateSEplot(mainhandle);
    end
end

%% Nested
    function mainhandles = calculateDleakage(mainhandles)
        % Reset time interval
        if resetchoice
            mainhandles.data(file).FRETpairs(pairchoice).DleakageIdx = [];
        end
        
        % Find time interval used
        if isempty(mainhandles.data(file).FRETpairs(pairchoice).DleakageIdx) ...
                && (bD<=length(pair.DDtrace)) && (bA<=length(pair.ADtrace)) ...
                && (bD-spacer>bA+spacer) && bD-2*spacer-bA>=minframes
            mainhandles.data(file).FRETpairs(pairchoice).DleakageIdx = [bA+spacer bD-spacer];
        end
        
        % Correction factor
        if ~isempty(mainhandles.data(file).FRETpairs(pairchoice).DleakageIdx) % If using previously set time interval
            
            % Interval used for calculating correction factor
            idx = mainhandles.data(file).FRETpairs(pairchoice).DleakageIdx;
            
            % Old method took average of each trace, then ratio
            % mainhandles.data(filechoice).FRETpairs(pairchoice).Dleakage = mean(pair.ADtrace(idx(1):idx(2)))/mean(pair.DDtrace(idx(1):idx(2)));
            
            % New method. Take avg. of correction factor trace
            ctrace = pair.ADtrace(idx(1):idx(2))./pair.DDtrace(idx(1):idx(2));
            if mainhandles.settings.corrections.medianI
                mainhandles.data(file).FRETpairs(pairchoice).Dleakage = median(ctrace);
                mainhandles.data(file).FRETpairs(pairchoice).DleakageVar = (pi/2)*var(ctrace); % Variance of median is ~pi/2*variance of mean
            else
                mainhandles.data(file).FRETpairs(pairchoice).Dleakage = mean(ctrace);
                mainhandles.data(file).FRETpairs(pairchoice).DleakageVar = var(ctrace); % Factor uncertainty: variance
            end
            
            % Store trace
            x = getX(idx);
            mainhandles.data(file).FRETpairs(pairchoice).DleakageTrace = [x(:) ctrace(:)];
        end
    end

    function mainhandles = calculateAdirect(mainhandles)
        % Reset time interval
        if resetchoice
            mainhandles.data(file).FRETpairs(pairchoice).AdirectIdx = [];
        end
        
        % Determine time interval
        if isempty(mainhandles.data(file).FRETpairs(pairchoice).AdirectIdx) ...
                && (bD<=length(pair.DDtrace)) && (bA<=length(pair.ADtrace)) ...
                && (bD+spacer<bA-spacer) && bA-2*spacer-bD>=minframes
            mainhandles.data(file).FRETpairs(pairchoice).AdirectIdx = [bD+spacer bA-spacer];
        end
        
        % Correction factor
        if ~isempty(mainhandles.data(file).FRETpairs(pairchoice).AdirectIdx) % If using previously set time interval
            
            if mainhandles.settings.excitation.alex
                % Direct A in ALEX scheme
                
                % Interval used for calculating correction factor
                idx = mainhandles.data(file).FRETpairs(pairchoice).AdirectIdx;
                
                % Old method took average of each intensity trace, then ratio
                % mainhandles.data(filechoice).FRETpairs(pairchoice).Adirect = mean(pair.ADtrace(idx(1):idx(2)))/mean(pair.AAtrace(idx(1):idx(2)));
                
                % New method. Take avg. of correction factor trace
                ctrace = pair.ADtrace(idx(1):idx(2))./pair.AAtrace(idx(1):idx(2));
                if mainhandles.settings.corrections.medianI
                    mainhandles.data(file).FRETpairs(pairchoice).Adirect = median(ctrace);
                    mainhandles.data(file).FRETpairs(pairchoice).AdirectVar = (pi/2)*var(ctrace); % Variance of median is ~pi/2*variance of mean
                else
                    mainhandles.data(file).FRETpairs(pairchoice).Adirect = mean(ctrace);
                    mainhandles.data(file).FRETpairs(pairchoice).AdirectVar = var(ctrace);
                end
                
                % Store trace
                x = getX(idx);
                mainhandles.data(file).FRETpairs(pairchoice).AdirectTrace = [x(:) ctrace(:)];
            end
            
        end
        
    end

    function mainhandles = calculateGamma(mainhandles)
        % Reset time interval
        if resetchoice
            mainhandles.data(file).FRETpairs(pairchoice).gammaIdx = [];
        end
        
        % Determine time-interval, if not already defined
        if isempty(mainhandles.data(file).FRETpairs(pairchoice).gammaIdx)
            
            % No. of frames to be used on either side of A bleaching
            gammaframes = mainhandles.settings.corrections.gammaframes;
            
            % Frames used for AD
            if bA-spacer>gammaframes
                % Full interval can be used prior bleaching
                Aidx1 = bA-spacer-gammaframes;
            else
                Aidx1 = 1;
            end
            if bA+spacer+gammaframes<bD-spacer
                % Full interval can be used post bleaching
                Aidx2 = bA+spacer+gammaframes;
            else
                Aidx2 = bD-spacer;
            end
            
            % Frames used for DD
            if bA-spacer>gammaframes
                % Full interval can be used prior bleaching
                Didx1 = bA-spacer-gammaframes;
            else
                Didx1 = 1;
            end
            if bA+spacer+gammaframes<bD-spacer
                % Full interval can be used post bleaching
                Didx2 = bA+spacer+gammaframes;
            else
                Didx2 = bD-spacer;
            end
            
            % Interval
            if (bA-spacer)-Aidx1>=minframes && Aidx2-(bA+spacer)>=minframes && (bA-spacer)-Didx1>=minframes && Didx2-(bA+spacer)>=minframes
                % D and A intensities prior and post A bleaching
                %                 Apre = mean(pair.ADtrace(Aidx1:bA-spacer));
                %                 Apost = mean(pair.ADtrace(bA+spacer:Aidx2));
                %                 Dpre = mean(pair.DDtrace(Didx1:bA-spacer));
                %                 Dpost = mean(pair.DDtrace(bA+spacer:Didx2));
                
                % Gamma factor
                %                 mainhandles.data(filechoice).FRETpairs(pairchoice).gamma = (Apre-Apost)/(Dpost-Dpre);
                mainhandles.data(file).FRETpairs(pairchoice).gammaIdx = [Aidx1 bA-spacer bA+spacer Aidx2; Didx1 bA-spacer bA+spacer Didx2];
            end
            
        end
        
        % Calculate correction factor
        if ~isempty(mainhandles.data(file).FRETpairs(pairchoice).gammaIdx) % If using previously set time-interval
            idx = mainhandles.data(file).FRETpairs(pairchoice).gammaIdx;
            
            % Old method took average of each intensity trace, then ratio
            % New method: Take avg. of correction factor trace
            
            % D and A intensities prior and post A bleaching
            A1 = pair.ADtraceCorr(idx(1,1):idx(1,2));
            A2 = pair.ADtraceCorr(idx(1,3):idx(1,4));
            D1 = pair.DDtrace(idx(2,1):idx(2,2));
            D2 = pair.DDtrace(idx(2,3):idx(2,4));
            
            % Calculate gamma and variance
            [gamma, variance] = calculateGammaVariance(mainhandles,A1,A2,D1,D2);
            
            % x vector
            x = getX(idx);
            
            % Store in handles
            mainhandles.data(file).FRETpairs(pairchoice).gammaTrace = [x(:) ones(length(x),1)*gamma];
            mainhandles.data(file).FRETpairs(pairchoice).gamma = gamma;
            mainhandles.data(file).FRETpairs(pairchoice).gammaVar = variance;
            
        end
        
    end

    function x = getX(idx)
        idx1 = min(min(idx));
        idx2 = max(max(idx));
        x = idx1:idx2;
    end

end