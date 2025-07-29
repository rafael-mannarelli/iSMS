function [mainhandles, fpwHandles] = plotcrosscorrCallback(fpwHandles)
% Callback for plotting pair D-A trace cross correlation
%
%    Input:
%     fpwHandles  - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles - handles structure of the main window
%     fpwHandles  - ..
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

fpwHandles = turnoffFRETpairwindowtoggles(fpwHandles); % Turn of integration ROIs
mainhandles = getmainhandles(fpwHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

selectedPairs = getPairs(fpwHandles.main, 'Selected', [], fpwHandles.figure1);
if isempty(selectedPairs)
    return
end

% Prepare traces
traces = getTraces(fpwHandles.main,selectedPairs,'nodarkstates',1);

%% Calculate cross-correlation

for i = 1:length(traces)
    
    Dtrace = traces(i).DD(:);
    Atrace = traces(i).AD(:);
    
    % Method 3
    lags = 50; % Number of lags
    cc = zeros(lags+1,1); % Initialize
    denom = (mean(Atrace)*mean(Dtrace)); % Denominator
    for j = 0:lags
        cc(j+1) = mean(Atrace.*circshift(Dtrace,[j 0]))/denom-1;
    end
    
    % Plot
    fh = figure(1);
    updatelogo(fh)
    plot(0:lags,cc)
    set(fh,'name','Cross-correlation plot','Numbertitle','off')
    xlabel('deltaT')
    ylabel('Cross-correlation (A to D)')
    
    % Store in handles so it is close when closing program
    mainhandles.figures{end+1} = fh;
    updatemainhandles(mainhandles)

end

