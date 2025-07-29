function mainhandles = calculateMax(mainhandle,choice,selectedPairs)
% Finds max intensity of FRET pairs
%
%    Input:
%     mainhandle    - handle to the main window
%     choice        - 'DD','AD','AA','DAsum'
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
    choice = 'DD';
end
if nargin<3 || isempty(selectedPairs)
    selectedPairs = getPairs(mainhandle,'all');
end

% Data points
traces = getTraces(mainhandle, selectedPairs, 'noDarkStates', 1);
if isempty(traces) || ~isequal(size(selectedPairs,1),length(traces))
    return
end

%% Calculate max.

for i = 1:length(traces)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);

    if strcmpi(choice,'DD') || strcmpi(choice,'all')
        mainhandles.data(file).FRETpairs(pair).maxDD = max(traces(i).DD);
    elseif strcmpi(choice,'AD') || strcmpi(choice,'all')
        mainhandles.data(file).FRETpairs(pair).maxAD = max(traces(i).AD);
    elseif strcmpi(choice,'AA') || strcmpi(choice,'all')
        mainhandles.data(file).FRETpairs(pair).maxAA = max(traces(i).AA);
    elseif strcmpi(choice,'DAsum') || strcmpi(choice,'all')
        temp = traces(i).DD + traces(i).AD;
        mainhandles.data(file).FRETpairs(pair).maxDAsum = max(temp);
    end
end

%% Update handles structure

updatemainhandles(mainhandles)
