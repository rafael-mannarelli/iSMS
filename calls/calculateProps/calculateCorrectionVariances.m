function mainhandles = calculateCorrectionVariances(mainhandles,selectedPairs,forceCalc)
% Calculates variances of correction factors
%
%    Input:
%     mainhandles   - handles structure of the main window
%     selectedPairs - [file1 pair1;...]
%     forceCalc     - 0/1 force new calculation even if already calculate
%
%    Output:
%     mainhandles   - ...
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

if isempty(selectedPairs)
    return
end

%% Calculate

for i = 1:size(selectedPairs,1)
    
    filechoice = selectedPairs(i,1);
    pairchoice = selectedPairs(i,2);
    pair = mainhandles.data(filechoice).FRETpairs(pairchoice);
    
    mainhandles.data(filechoice).FRETpairs(pairchoice).DleakageVar = calcVar('Dleakage');
    mainhandles.data(filechoice).FRETpairs(pairchoice).AdirectVar = calcVar('Adirect');
    mainhandles.data(filechoice).FRETpairs(pairchoice).gammaVar = calcgammaVar();
end

% Update handles
updatemainhandles(mainhandles)

%% Nested

    function val = calcVar(f)
        fstr1 = [f 'Var'];
        val = pair.(fstr1);
        if ~isempty(val) && ~forceCalc
            return
        end
        
        fstr2 = [f 'Trace'];
        if size(pair.(fstr2),2)==2
            val = var(pair.(fstr2)(:,2));
        end
        if isnan(val)
            val = [];
        end
        if mainhandles.settings.corrections.globalavgChoice==3
            val = val*pi/2; % Variance of median
        end
    end

    function val = calcgammaVar()
        
        val = pair.gammaVar;
        if ~isempty(val) && ~forceCalc
            return
        end
        
        idx = pair.gammaIdx;
        if isempty(idx)
            val = [];
            return
        end
        
        % D and A intensities prior and post A bleaching
        A1 = pair.ADtraceCorr(idx(1,1):idx(1,2));
        A2 = pair.ADtraceCorr(idx(1,3):idx(1,4));
        D1 = pair.DDtrace(idx(2,1):idx(2,2));
        D2 = pair.DDtrace(idx(2,3):idx(2,4));
        
        % Calculate variance
        [~, val] = calculateGammaVariance(mainhandles,A1,A2,D1,D2)
        
    end
end
