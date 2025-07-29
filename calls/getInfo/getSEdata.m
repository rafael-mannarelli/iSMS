function [mainhandles, data] = getSEdata(mainhandles,selectedPairs,valuesplotted)
% Returns single point data values of selectedPairs to be plotted in the
% histogram window
%
%    Input:
%     mainhandles    - handles structure of the main window
%     selectedPairs  - [file1 pair1;...]
%     valuesplotted  - 2) avg values. 3) median values.
%
%    Output:
%     mainhandles    - ..
%     data           - data structure
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
data = struct(...
    'E', [],...
    'S', [],...
    'idx', []);
data(1) = [];

% Default
if nargin<2
    selectedPairs = getPairs(mainhandles.figure1, 'Plotted');
end
if nargin<3 || isempty(valuesplotted)
    valuesplotted = mainhandles.settings.SEplot.valuesplotted;
end

% Check pairs
if isempty(selectedPairs)
    return
end

%% Return values

if valuesplotted==2
    % Avg values
    for i = 1:size(selectedPairs,1)
        file = selectedPairs(i,1);
        pair = selectedPairs(i,2);
        
        % Check values have been calculated
        if isempty(mainhandles.data(file).FRETpairs(pair).avgS) ...
                || isempty(mainhandles.data(file).FRETpairs(pair).avgE)
            mainhandles = calculateAvgTrace(mainhandles.figure1,'all',selectedPairs(i,:),'avg');
        end
        
        % Collect
        data(i).S = mainhandles.data(file).FRETpairs(pair).avgS;
        data(i).E = mainhandles.data(file).FRETpairs(pair).avgE;
        
    end
    
elseif valuesplotted==3
    % Median values
    for i = 1:size(selectedPairs,1)
        file = selectedPairs(i,1);
        pair = selectedPairs(i,2);
        
        % Check values have been calculated
        if isempty(mainhandles.data(file).FRETpairs(pair).medianS) ...
                || isempty(mainhandles.data(file).FRETpairs(pair).medianE)
            mainhandles = calculateAvgTrace(mainhandles.figure1,'all',selectedPairs(i,:),'median');
        end
        
        % Collect
        data(i).S = mainhandles.data(file).FRETpairs(pair).medianS;
        data(i).E = mainhandles.data(file).FRETpairs(pair).medianE;
        
    end
    
end
