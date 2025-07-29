function updateEhistGauss(mainhandle,histogramwindowHandle)
% Updates FRET histogram in the histogramwindow
%
%    Input:
%     mainhandle            - handle to the main window
%     histogramwindowHandle - handle to the histogramwindow
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

h = findobj(histogramwindowHandles.Ehist,'type','line');
try delete(h), end

% if mainhandles.settings.SEplot.GaussianType==2
%     return
% end

if ~mainhandles.settings.SEplot.plotEfitTot && ~mainhandles.settings.SEplot.plotEfit
    return
end

EGaussians = mainhandles.settings.SEplot.EGaussians;
if isempty(EGaussians)
    return
end

%% Make Gaussians

% xlims = get(histogramwindowHandles.Ehist,'xlim');
% x = linspace(-0.1,1.1,100);

hold(histogramwindowHandles.Ehist,'on')
if mainhandles.settings.SEplot.plotEfitTot && ~isempty(mainhandles.settings.SEplot.EGaussTot)
    x = mainhandles.settings.SEplot.EGaussTot(:,1);
    y = mainhandles.settings.SEplot.EGaussTot(:,2);
    plot(histogramwindowHandles.Ehist, x,y, 'k', 'LineWidth',2)
end

if mainhandles.settings.SEplot.plotEfit
    for i = 1:length(EGaussians)
        
        % Plot fitted distribution
        if mainhandles.settings.SEplot.GaussColorChoiceHist
            gausscolor = EGaussians(i).color;
        else
            gausscolor = EGaussians(1).color;
        end
        
        plot(histogramwindowHandles.Ehist, EGaussians(i).x, EGaussians(i).y, gausscolor, 'LineWidth',2)
        
    end
end
hold(histogramwindowHandles.Ehist,'off')

