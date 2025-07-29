function mainhandles = SEplotSettingsCallback(histogramwindowHandles)
% Callback for the plot options menu in the histogramwindow
%
%     Input:
%      histogramwindowHandles   - handles structure of the hist window
%
%     Output:
%      mainhandles              - handles structure of the main window
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

if (isempty(histogramwindowHandles.main)) || (~ishandle(histogramwindowHandles.main))
    mymsgbox('For some reason the handle to the main window is lost. Please reload this window.');
    return
end

% Set new plot type in the mainhandles structure
mainhandles = getmainhandles(histogramwindowHandles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

%% Prepare dialog box

prompt = {'E-S scatter plot settings:' '';...
    'Histograms plot settings:' '';...
    ...
    'Plot type: ' 'SEplotType';...
    'Plot binned histograms' 'plotBins';...
    ...
    'Data plotted: ' 'plotBleaching';...
    'Plot components of fitted E histogram' 'plotEfit';...
    ...
    'Plot only time-interval of interest, if defined' 'onlytinterest';...
    'Plot the fitted sum of E histogram' 'plotEfitTot';...
    ...
    'Exclude blinking intervals from plot' 'excludeBlinking';...
    'Plot components of fitted S histogram' 'plotSfit';...
    ...
    'Max frames included from each molecule (0 is all): ' 'maxframes';...
    'Plot the total fitted S histogram' 'plotSfitTot';...
    ...
    'Exclude spacer from bleaching/blinking time (frames): ' 'framespacer';...
    'Colorize Gaussian components in histograms' 'GaussColorChoiceHist';...
    ...
    'Marker size: ' 'markersize';...
    'Colormap: ' 'colormap';...
    'Use color inversion ' 'colorinversion';...
    'Colorize Gaussian components in SE plot' 'GaussColorChoiceSE';...
    ...
    'If using individual corrections plot ONLY molecules with the following factors determined: ' '';...
    '(unselect all to plot all molecules)' '';...
    'Gamma' 'plotgammaspec';...
    'Donor leakage' 'plotdleakspec';...
    'Acceptor direct' 'plotadirectspec'};

   
name = 'Plot settings';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% E-S scatter plot
formats(2,1).type = 'text';
formats(3,1).type = 'list';
formats(3,1).style = 'popupmenu';
formats(3,1).items = {'Regular one-color scatter','Density-colored scatter','Smoothed density-colored image'}; % Plot functions
formats(4,1).type = 'list';
formats(4,1).style = 'popupmenu';
formats(4,1).items = {...
    'All data points within the time-intervals of interest',...
    'Only data points prior 1st bleaching event',...
    'Only data points after 1st bleaching event',...
    'Only data points prior 2nd bleaching event',...
    'Only data points after 2nd bleaching event',...
    'D only points, i.e. after A and until D is bleached',...
    'A only points, i.e. after D and until A is bleached',...
    'D+A only, i.e. after one and until the other is bleached'}; % Plot functions
formats(5,1).type = 'check';
formats(6,1).type = 'check';
formats(7,1).type = 'edit';
formats(7,1).size = 50;
formats(7,1).format = 'integer';
formats(8,1).type = 'edit';
formats(8,1).size = 50;
formats(8,1).format = 'integer';
formats(11,1).type = 'edit';
formats(11,1).size = 50;
formats(11,1).format = 'float';
formats(12,1).type = 'list';
formats(12,1).style = 'popupmenu';
formats(12,1).items = {'Jet', 'HSV', 'Hot', 'Cool', 'Spring', 'Summer', 'Autumn', 'Winter', 'Gray', 'Bone', 'Copper', 'Pink'}; % Colormaps
formats(13,1).type = 'check';
formats(14,1).type = 'check';

formats(17,1).type = 'text';
formats(18,1).type = 'text';
formats(19,1).type = 'check';
formats(20,1).type = 'check';
formats(21,1).type = 'check';

% Histograms
formats(2,2).type = 'text';
formats(3,2).type = 'check';
formats(4,2).type = 'check';
formats(5,2).type = 'check';
formats(6,2).type = 'check';
formats(7,2).type = 'check';
formats(8,2).type = 'check';
% formats(2,2).type = 'text';
% formats(3,2).type = 'check';
% formats(4,2).type = 'check';
% formats(5,2).type = 'check';
% formats(6,2).type = 'check';
% formats(7,2).type = 'check';
% formats(8,2).type = 'check';

% Default choices
DefAns.SEplotType = mainhandles.settings.SEplot.SEplotType;
DefAns.onlytinterest = mainhandles.settings.SEplot.onlytinterest;
DefAns.excludeBlinking = mainhandles.settings.SEplot.excludeBlinking;
DefAns.framespacer = mainhandles.settings.SEplot.framespacer;
DefAns.maxframes = mainhandles.settings.SEplot.maxframes;
DefAns.plotgammaspec = mainhandles.settings.SEplot.plotgammaspec;
DefAns.plotdleakspec = mainhandles.settings.SEplot.plotdleakspec;
DefAns.plotadirectspec = mainhandles.settings.SEplot.plotadirectspec;
DefAns.plotBleaching = mainhandles.settings.SEplot.plotBleaching;
if strcmpi(mainhandles.settings.SEplot.colormap,'jet')
    DefAns.colormap = 1;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'hsv')
    DefAns.colormap = 2;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'hot')
    DefAns.colormap = 3;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'cool')
    DefAns.colormap = 4;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'spring')
    DefAns.colormap = 5;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'summer')
    DefAns.colormap = 6;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'autumn')
    DefAns.colormap = 7;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'winter')
    DefAns.colormap = 8;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'gray')
    DefAns.colormap = 9;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'bone')
    DefAns.colormap = 10;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'copper')
    DefAns.colormap = 11;
elseif strcmpi(mainhandles.settings.SEplot.colormap,'pink')
    DefAns.colormap = 12;
end
DefAns.colorinversion = mainhandles.settings.SEplot.colorinversion;
DefAns.GaussColorChoiceHist = mainhandles.settings.SEplot.GaussColorChoiceHist;
DefAns.GaussColorChoiceSE = mainhandles.settings.SEplot.GaussColorChoiceSE;
DefAns.markersize = mainhandles.settings.SEplot.markersize;
DefAns.plotBins = mainhandles.settings.SEplot.plotBins;
DefAns.plotEfit = mainhandles.settings.SEplot.plotEfit;
DefAns.plotSfit = mainhandles.settings.SEplot.plotSfit;
DefAns.plotEfitTot = mainhandles.settings.SEplot.plotEfitTot;
DefAns.plotSfitTot = mainhandles.settings.SEplot.plotSfitTot;

options.CancelButton = 'on';

%% Open dialog box
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1) || (isequal(DefAns,answer))
    return
end

%% Check what has changed

ok_updateSE = 0;
ok_updateEhist = 0;
ok_updateShist = 0;

% What axes to update is based on selection
if ~isequal(DefAns.SEplotType,answer.SEplotType) ||...
    ~isequal(DefAns.plotBleaching,answer.plotBleaching) ||...
    ~isequal(DefAns.plotgammaspec,answer.plotgammaspec) ||...
    ~isequal(DefAns.plotdleakspec,answer.plotdleakspec) ||...
    ~isequal(DefAns.plotadirectspec,answer.plotadirectspec) ||...
    (~isequal(DefAns.colorinversion,answer.colormap) && answer.SEplotType~=1) ||...
    (~isequal(DefAns.colorinversion,answer.colorinversion) && answer.GaussColorChoiceSE) ||...
    (~isequal(DefAns.GaussColorChoiceSE,answer.GaussColorChoiceSE) && answer.SEplotType==1) ||...
    (~isequal(DefAns.markersize,answer.markersize) && answer.SEplotType~=3) ||...
    ~isequal(DefAns.plotBins,answer.plotBins) || ~isequal(DefAns.onlytinterest,answer.onlytinterest) ||...
    ~isequal(DefAns.excludeBlinking,answer.excludeBlinking) || ...
    ~isequal(DefAns.maxframes,answer.maxframes) || ...
    ~isequal(DefAns.framespacer,answer.framespacer)
    
    ok_updateSE = 1;
end

if ok_updateSE ||...
    ~isequal(DefAns.plotBins,answer.plotBins) ||...
    ~isequal(DefAns.plotEfit,answer.plotEfit) ||...
    ~isequal(DefAns.plotEfitTot,answer.plotEfitTot) || ...
    ~isequal(DefAns.maxframes,answer.maxframes)
    
    ok_updateEhist = 1;
end

if ok_updateSE ||...
    ~isequal(DefAns.plotBins,answer.plotBins) ||...
    ~isequal(DefAns.plotSfit,answer.plotSfit) ||...
    ~isequal(DefAns.plotSfitTot,answer.plotSfitTot) || ...
    ~isequal(DefAns.maxframes,answer.maxframes)
    
    ok_updateShist = 1;
end

%% Update settings structure

mainhandles.settings.SEplot.SEplotType = answer.SEplotType;
mainhandles.settings.SEplot.onlytinterest = answer.onlytinterest;
mainhandles.settings.SEplot.excludeBlinking = answer.excludeBlinking;
mainhandles.settings.SEplot.framespacer = abs(answer.framespacer);
mainhandles.settings.SEplot.maxframes = abs(answer.maxframes);
mainhandles.settings.SEplot.plotBleaching = answer.plotBleaching;
mainhandles.settings.SEplot.plotgammaspec = answer.plotgammaspec;
mainhandles.settings.SEplot.plotdleakspec = answer.plotdleakspec;
mainhandles.settings.SEplot.plotadirectspec = answer.plotadirectspec;
if answer.colormap==1
    mainhandles.settings.SEplot.colormap = 'jet';
elseif answer.colormap==2
    mainhandles.settings.SEplot.colormap = 'hsv';
elseif answer.colormap==3
    mainhandles.settings.SEplot.colormap = 'hot';
elseif answer.colormap==4
    mainhandles.settings.SEplot.colormap = 'cool';
elseif answer.colormap==5
    mainhandles.settings.SEplot.colormap = 'spring';
elseif answer.colormap==6
    mainhandles.settings.SEplot.colormap = 'summer';
elseif answer.colormap==7
    mainhandles.settings.SEplot.colormap = 'autumn';
elseif answer.colormap==8
    mainhandles.settings.SEplot.colormap = 'winter';
elseif answer.colormap==9
    mainhandles.settings.SEplot.colormap = 'gray';
elseif answer.colormap==10
    mainhandles.settings.SEplot.colormap = 'bone';
elseif answer.colormap==11
    mainhandles.settings.SEplot.colormap = 'copper';
elseif answer.colormap==12
    mainhandles.settings.SEplot.colormap = 'pink';
end
mainhandles.settings.SEplot.colorinversion = answer.colorinversion;
mainhandles.settings.SEplot.GaussColorChoiceHist = answer.GaussColorChoiceHist;
mainhandles.settings.SEplot.GaussColorChoiceSE = answer.GaussColorChoiceSE;
mainhandles.settings.SEplot.markersize = abs(answer.markersize);
mainhandles.settings.SEplot.plotBins = answer.plotBins;
mainhandles.settings.SEplot.plotEfit = answer.plotEfit;
mainhandles.settings.SEplot.plotSfit = answer.plotSfit;
mainhandles.settings.SEplot.plotEfit = answer.plotEfitTot;
mainhandles.settings.SEplot.plotSfit = answer.plotSfitTot;
updatemainhandles(mainhandles)

%% Update plot

if ok_updateSE
    mainhandles = updateSEplot(histogramwindowHandles.main,mainhandles.FRETpairwindowHandle,histogramwindowHandles.figure1,'all',[],[],1);
end
if ok_updateEhist
    updateEhistGauss(histogramwindowHandles.main, histogramwindowHandles.figure1)
end
if ok_updateShist
    updateShistGauss(histogramwindowHandles.main, histogramwindowHandles.figure1)
end
