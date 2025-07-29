function mainhandles = ScoordinateCorrelationCallback(mainhandles)
% Callback for plotting the correlation between S and molecule coordinate
%
%    Input:
%     mainhandles  - handles structure of the main window
%
%    Output:
%     mainhandles  - ..
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

% Pairs to be plotted
allPairs = getPairs(mainhandles.figure1, 'listed');

if isempty(allPairs)
    mymsgbox('No pairs to plot.')
    return
end

try FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
    defans = get(FRETpairwindowHandles.PairListbox,'Value');
catch err
    defans = 1;
end

%% File dialog

% Prepare dialog
prompt = {'Select pairs: ' 'selectedPairs';...
    'Show text labels' 'showtext';...
    'Show markers' 'showmarker'};
name = 'Coordinate correlation plot';

formats = prepareformats();

formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = getFRETpairString(mainhandles.figure1,mainhandles.FRETpairwindowHandle);
formats(2,1).size = [200 400];
formats(2,1).limits = [0 2];
formats(4,1).type = 'check';
formats(5,1).type = 'check';

DefAns.selectedPairs = defans;
DefAns.showtext = mainhandles.settings.coordinatecorrelationPlot.showtext;
DefAns.showmarker = mainhandles.settings.coordinatecorrelationPlot.showmarker;

% Open dialog
[answer, cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled || isempty(answer.selectedPairs)
    return
end

% Save settings
pairchoices = answer.selectedPairs;
mainhandles.settings.coordinatecorrelationPlot.showtext = answer.showtext;
mainhandles.settings.coordinatecorrelationPlot.showmarker = answer.showmarker;
updatemainhandles(mainhandles)

% Selected pairs
selectedPairs = allPairs(pairchoices,:);
if isempty(selectedPairs)
    return
end

%% Data points

traces = getTraces(mainhandles.figure1,selectedPairs,'noDarkStates');
if isempty(traces) || ~isequal(size(selectedPairs,1),length(traces))
    return
end

% Calculate avg.
cc = zeros(length(traces),3);
for i = 1:length(traces)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    xy = (mainhandles.data(file).FRETpairs(pair).Dxy+mainhandles.data(file).FRETpairs(pair).Axy)/2;
    cc(i,:) = [xy(:)' mean(traces(i).S)];
end

%% Calculate and plot

% New figure
fh = figure;
updatelogo(fh)

% Grid data
[xq,yq] = meshgrid(1:1:round(mainhandles.data(1).Droi(3)), 1:1:round(mainhandles.data(1).Droi(4)));

% Create surface. Must be double precision
cc = double(cc);
xq = double(xq);
yq = double(yq);
vq = griddata(cc(:,1),cc(:,2),cc(:,3),xq,yq); % Interpolate
hold on

% Plot surface
mesh(vq)
% plot3k(cc,'MarkerSize',15)

% Plot markers
if mainhandles.settings.coordinatecorrelationPlot.showmarker
    scatter3(cc(:,1),cc(:,2),cc(:,3),'*')
end

% Plot text labels
if mainhandles.settings.coordinatecorrelationPlot.showtext
    labels = {};
    for i = 1:size(selectedPairs,1)
        labels{i,1} = sprintf('(%i,%i)',selectedPairs(i,1),selectedPairs(i,2));
    end
    h = text(cc(:,1),cc(:,2),ones(size(selectedPairs,1),1)*10, labels, 'VerticalAlignment','bottom', ...
        'HorizontalAlignment','right','Color','black');
%     uistack(h, 'top')
end

% Axis properties
axis equal
xlim([0 mainhandles.data(1).Droi(3)])
ylim([0 mainhandles.data(1).Droi(4)])
xlabel(gca,'ROI x /pixel index')
ylabel(gca,'ROI y /pixel index')
set(gcf,'name',sprintf('%i molecules',size(selectedPairs,1)),'numbertitle','off')
title(sprintf('S-coordinate correlation plot: %i molecules',size(selectedPairs,1)))

% Colorbar
cb = colorbar;
ylabel(cb,'Stoichiometry (S)');

% Store figure handle so that it is closed when closing program
mainhandles.figures{end+1} = fh;
updatemainhandles(mainhandles)
