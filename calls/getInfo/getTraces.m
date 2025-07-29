function traces = getTraces(mainhandle,selectedPairs,choice,intensities)
% Returns a structure with fields E and S containing the trace-intervals of
% interest of selectedPairs
%
%    Input:
%     mainhandle            - handle to the main figure window
%     selectedPairs         - [file pair;...] pairs to return the traces
%                             of. length(traces) = size(selectedPairs,1)
%     choice                - 'SEplot', 'vbFRET', 'noDarkStates'. vbFRET
%                             gives the same as noDarkStates which excludes
%                             all frames with either blinking or bleaching.
%     intensities           - 0/1 whether to export DD, AD, AA traces too.
%                             Default: 0
%
%    Output:
%     traces                - traces.E, traces.S, traces.idx.
%                             length(traces) = size(selectedPairs,1)
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

% Minimum fields
traces = struct(...
    'E', [],...
    'S', [],...
    'idx', []);
traces(1) = [];

% Set defaults
if nargin<2
    selectedPairs = getPairs(mainhandle, 'Plotted', [], FRETpairwindowHandle, histogramwindowHandle);
end
if nargin<3
    choice = 'SEplot';
end
if nargin<4
    intensities = 0;
end
if strcmpi(choice,'noDarkStates')
    % The same choice as vbFRET
    choice = 'vbFRET';
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)

% If there is no data, clear all axes and return
if isempty(mainhandles.data)
    return
end

%% Get full traces

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pairchoice = selectedPairs(i,2);
    traces(i).E = mainhandles.data(file).FRETpairs(pairchoice).Etrace(:)';
    traces(i).S = mainhandles.data(file).FRETpairs(pairchoice).StraceCorr(:)';
    
    if intensities
        traces(i).DD = mainhandles.data(file).FRETpairs(pairchoice).DDtrace(:)';
        traces(i).AD = mainhandles.data(file).FRETpairs(pairchoice).ADtrace(:)';
        traces(i).ADcorr = mainhandles.data(file).FRETpairs(pairchoice).ADtraceCorr(:)';
        traces(i).AA = mainhandles.data(file).FRETpairs(pairchoice).AAtrace(:)';
        traces(i).DDback = mainhandles.data(file).FRETpairs(pairchoice).DDback(:)';
        traces(i).ADback = mainhandles.data(file).FRETpairs(pairchoice).ADback(:)';
        traces(i).AAback = mainhandles.data(file).FRETpairs(pairchoice).AAback(:)';
    end
end

%% Get the time-interval chosen to be plotted

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pairchoice = selectedPairs(i,2);
    pair = mainhandles.data(file).FRETpairs(pairchoice);
    
    traceLength = length(pair.Etrace);
    Bidx = [1 traceLength]; % Indices from bleaching events
    
    %% Take bleaching events into account
    
    if strcmpi(choice,'SEplot')
        % Traces for SEplot
        
        if mainhandles.settings.SEplot.plotBleaching ~= 1
            
            % Initialize data indices derived from bleaching events
            Bidx = []; % Empty means that there is no data within the chosen bleaching interval
            
            % Bleaching times
            bD = pair.DbleachingTime; % Donor bleaching time
            if ~isempty(bD)
                bD = bD-mainhandles.settings.SEplot.framespacer;
            else
                bD = traceLength; % If D hasn't been specified, set it to the final frame
            end
            bA = pair.AbleachingTime; % Acceptor bleaching time
            if ~isempty(bA)
                bA = bA-mainhandles.settings.SEplot.framespacer;
            else
                bA = traceLength; % If A hasn't been specified, set it to the final frame
            end
            bF = min([bD bA]); % Time of 1st bleaching event
            bS = max([bD bA]); % Time of 2nd bleaching event
            
            % Find indices of bleaching events
            if mainhandles.settings.SEplot.plotBleaching == 2 % If plotting only data points prior first bleaching event
                if bF < traceLength % Make sure end time exists and does not exceed data
                    Bidx = [1 bF];
                else
                    Bidx = [1 traceLength]; % If bleaching is not set or outside data range, use entire data interval
                end
            elseif mainhandles.settings.SEplot.plotBleaching == 3 % If plotting only data points after first bleaching event
                if bF < traceLength % Make sure end time exists and does not exceed data
                    Bidx = [bF traceLength];
                end
            elseif mainhandles.settings.SEplot.plotBleaching == 4 % If plotting only data points before 2nd bleaching event
                if bS < traceLength
                    Bidx = [1 bS];
                else
                    Bidx = [1 traceLength];
                end
            elseif mainhandles.settings.SEplot.plotBleaching == 5 % If plotting only data points after 2nd bleaching event
                if bS < traceLength
                    Bidx = [bS traceLength];
                end
            elseif mainhandles.settings.SEplot.plotBleaching == 6 % If plotting D only data points, i.e. after A has bleached but before D has bleached
                if (bD>bA) && (bD<=traceLength) && (bA<=traceLength)
                    Bidx = [bA bD];
                end
            elseif mainhandles.settings.SEplot.plotBleaching == 7 % If plotting A only data points, i.e. after D has bleached but before A has bleached
                if (bA>bD) && (bD<=traceLength) && (bA<=traceLength)
                    Bidx = [bD bA];
                end
            elseif mainhandles.settings.SEplot.plotBleaching == 8 % If plotting D+A only data points, i.e. where exactly one has been bleached
                if (bD>bA) && (bD<=traceLength) && (bA-1<=traceLength)
                    Bidx = [bA bD];
                elseif (bA>bD) && (bD<=traceLength) && (bA<=traceLength)
                    Bidx = [bD bA];
                end
            end
        end
        
    elseif strcmpi(choice,'vbFRET')
        % Traces for analysis
        
        % Initialize data indices derived from bleaching events
        Bidx = []; % Empty means that there is no data within the chosen bleaching interval
        
        % Bleaching times
        bD = pair.DbleachingTime; % Donor bleaching time
        if isempty(bD)
            bD = traceLength; % If D hasn't been specified, set it to the final frame
        end
        bA = pair.AbleachingTime; % Acceptor bleaching time
        if isempty(bA)
            bA = traceLength; % If A hasn't been specified, set it to the final frame
        end
        bF = min([bD bA]); % Time of 1st bleaching event
        
        if bF < traceLength % Make sure end time exists and does not exceed data
            Bidx = [1 bF];
        else
            Bidx = [1 traceLength]; % If bleaching is not set or outside data range, use entire data interval
        end
        
    end
    
    %% Take specified time-interval of interest into account
    if ~isempty(Bidx) && Bidx(1) == 0
       Bidx = [1, Bidx(2)]; 
    end
    
    idx = Bidx;
    if ~isempty(pair.timeInterval) && mainhandles.settings.SEplot.onlytinterest % If time-interval of interest has been specified
        
        % Correct indices according to the interval defined by bleach
        if ~isempty(idx)
            
            % 1. Delete intervals that lie outside bleaching interval
            d = [];
            for j = 1:size(pair.timeInterval,1) % Loop over all time-intervals in FRET pair i
                if ((pair.timeInterval(j,1)<idx(1)) && (pair.timeInterval(j,2)<idx(1))) || ((pair.timeInterval(j,1)>idx(2)) && (pair.timeInterval(j,2)>idx(2)))
                    d = [d j];
                end
            end
            pair.timeInterval(d,:) = [];
            
            % 2. change indices of intervals overlapping with bleach inter.
            for j = 1:size(pair.timeInterval,1) % Loop over all time-intervals in FRET pair i
                if (pair.timeInterval(j,1)<idx(1)) && (pair.timeInterval(j,2)<idx(2)) % If left idx is outside bleaching interval
                    pair.timeInterval(j,1) = idx(1);
                elseif (pair.timeInterval(j,1)>idx(1)) && (pair.timeInterval(j,2)>idx(2)) % If right index is outside bleaching interval
                    pair.timeInterval(j,2) = idx(2);
                end
            end
            
            idx = pair.timeInterval;
        end
    end
    
    %% Take specified blinking-interval into accound
    
    idx1 = [];
    for j = 1:size(idx,1)
        idx1 = [idx1 idx(j,1):idx(j,2)];
    end
    
    if (~isempty(pair.DblinkingInterval) || ~isempty(pair.AblinkingInterval)) ...
            && (strcmpi(choice,'vbFRET') || (strcmpi(choice,'SEplot') && mainhandles.settings.SEplot.excludeBlinking))
        % Time-interval of interest has been specified
        
        % All blinking intervals
        blinkingInterval = [pair.DblinkingInterval; pair.AblinkingInterval];
        
        % Remove spacer close to blinking times
        blinkingInterval(:,1) = blinkingInterval(:,1)-mainhandles.settings.SEplot.framespacer;
        blinkingInterval(:,2) = blinkingInterval(:,2)+mainhandles.settings.SEplot.framespacer;
        
        % Correct indices according to the interval defined by bleach
        if ~isempty(idx)
            
            blidx = [];
            for j = 1:size(blinkingInterval,1)
                blidx = [blidx blinkingInterval(j,1):blinkingInterval(j,2)];
            end
            idx1( ismember(idx1,blidx) ) = []; % Idx1 is the indices of frames used for the plot
            
            % Change so that indexing matches idx format [x1 x2; x3 x4;...]
            temp = find(diff(idx1)>1);
            if ~isempty(temp)
                idx = zeros(length(temp)+1,2);
                idx(1,:) = [1 idx1(temp(1))];
                for j = 1:length(temp)
                    if j < length(temp)
                        idx(j+1,:) = [idx1(temp(j)+1) idx1(temp(j+1))];
                    else
                        idx(j+1,:) = [idx1(temp(j)+1) idx1(end)];
                    end
                end
                
            else
                idx = [min(idx1) max(idx1)];
            end
        end
    end
    
    %% Final indices and cut traces
    traces(i).idx = idx;
    traces(i).E = getTrace('E');
    traces(i).S = getTrace('S');
    
    % Max frames
    if strcmpi(choice,'SEplot') && mainhandles.settings.SEplot.maxframes>0
        
        if length(traces(i).E)>mainhandles.settings.SEplot.maxframes
            traces(i).E = traces(i).E(1:mainhandles.settings.SEplot.maxframes);

            if mainhandles.settings.excitation.alex
                traces(i).S = traces(i).S(1:mainhandles.settings.SEplot.maxframes);
            end
        end
    end
    
    % Intensity traces
    if intensities
        
        traces(i).DD = getTrace('DD');
        traces(i).AD = getTrace('AD');
        traces(i).ADcorr = getTrace('ADcorr');
        traces(i).AA = getTrace('AA');
        traces(i).DDback = getTrace('DDback');
        traces(i).ADback = getTrace('ADback');
        traces(i).AAback = getTrace('AAback');
        
    end
end

%% Nested

    function trace = getTrace(choice)
        trace = traces(i).(choice);
        
        if isempty(idx) || isempty(trace)
            trace = [];
        else
            % Count no. of data points within intervals for pre-allocation
            points = 0;
            for j = 1:size(idx,1)
                points = points + idx(j,2)-idx(j,1)+1;
            end
            
            % Cut traces according to intervals
            temp = zeros(points,1);
            idx1 = 1;
            for j = 1:size(idx,1)
                idx2 = idx1 + idx(j,2)-idx(j,1);
                temp(idx1:idx2) = trace(idx(j,1):idx(j,2));
                idx1 = idx2+1;
            end
            trace = temp(:)';
        end
        
    end

end