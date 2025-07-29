function updateShistGauss(mainhandle,histogramwindowHandle)
% Updates the S histogram in the histogramwindow
%
%     Input:
%      mainhandle             - handle to the main window
%      histogramwindowHandle  - handle to the histogramwindow
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

if isempty(mainhandle) || isempty(histogramwindowHandle) || ~ishandle(mainhandle) || ~ishandle(histogramwindowHandle)
    return
end

mainhandles = guidata(mainhandle);
histogramwindowHandles = guidata(histogramwindowHandle);

if isempty(mainhandles.data)
    return
end

h = findobj(histogramwindowHandles.Shist,'type','line');
try delete(h), end

if ~mainhandles.settings.SEplot.plotSfitTot && ~mainhandles.settings.SEplot.plotSfit
    return
end

SGaussians = mainhandles.settings.SEplot.SGaussians;
if isempty(SGaussians)
    return
end

%% Make Gaussians

% xlims = get(histogramwindowHandles.Shist,'xlim');
% x = linspace(-0.1,1.1,100);

hold(histogramwindowHandles.Shist,'on')
if mainhandles.settings.SEplot.plotSfitTot && ~isempty(mainhandles.settings.SEplot.SGaussTot)
    x = mainhandles.settings.SEplot.SGaussTot(:,1);
    y = mainhandles.settings.SEplot.SGaussTot(:,2);
    plot(histogramwindowHandles.Shist, x,y, 'k', 'LineWidth',2)
end

if mainhandles.settings.SEplot.plotSfit
    for i = 1:length(SGaussians)
        
        % Plot fitted distribution
        if mainhandles.settings.SEplot.GaussColorChoiceHist
            gausscolor = SGaussians(i).color;
        else
            gausscolor = SGaussians(1).color;
        end
        
        plot(histogramwindowHandles.Shist, SGaussians(i).x, SGaussians(i).y, gausscolor, 'LineWidth',2)
        
    end
end
hold(histogramwindowHandles.Shist,'off')

