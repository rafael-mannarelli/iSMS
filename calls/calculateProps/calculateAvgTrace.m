function mainhandles = calculateAvgTrace(mainhandle,choice,selectedPairs,valuetype)
% Calculate avg. property of FRET pairs
%
%    Input:
%     mainhandle    - handle to the main window
%     choice        - 'E','S','all'
%     selectedPairs - [file pair;...]
%
%    Output:
%     mainhandles   - handles structure of the main window
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
if isempty(mainhandle) || ~ishandle(mainhandle)
    try
        mainhandle = getappdata(0,'mainhandle');
        mainhandles = guidata(mainhandle);
    catch
        mainhandles = [];
        return
    end
end
mainhandles = guidata(mainhandle);

% Defaults
if nargin<2 || isempty(choice)
    choice = 'E';
end
if nargin<3 || isempty(selectedPairs)
    selectedPairs = getPairs(mainhandle,'all');
end
if nargin<4 || isempty(valuetype)
    valuetype = 'avg';
end

% Data points
traces = getTraces(mainhandle,selectedPairs,'noDarkStates');
if isempty(traces) || ~isequal(size(selectedPairs,1),length(traces))
    return
end

%% Calculate avg.

for i = 1:length(traces)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    if strcmpi(choice,'E') || strcmpi(choice,'all')
        
        % FRET
        if strcmpi(valuetype,'avg')
            mainhandles.data(file).FRETpairs(pair).avgE = sum(traces(i).E)/length(traces(i).E); % Mean
        else
            mainhandles.data(file).FRETpairs(pair).medianE = median(traces(i).E); % Median
        end
    end
    
    if strcmpi(choice,'S') || strcmpi(choice,'all')
        
        % Stoichiometry
        if strcmpi(valuetype,'avg')
            mainhandles.data(file).FRETpairs(pair).avgS = sum(traces(i).S)/length(traces(i).S); % Mean
        else
            mainhandles.data(file).FRETpairs(pair).medianS = median(traces(i).S); % Median
        end
    end
end

%% Update

updatemainhandles(mainhandles)
