function mainhandles = EplotSettingsCallback(hwHandles)
% Callback for plot settings in single-color exc scheme in histogram window
%
%    Input:
%     hwHandles    - handles structure of the histogramwindow
%
%    Output:
%     mainhandles  - handles structure of the main window
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

if (isempty(hwHandles.main)) || (~ishandle(hwHandles.main))
    mymsgbox('For some reason the handle to the main window is lost. Please reload this window.');
    return
end

% Set new plot type in the mainhandles structure
mainhandles = getmainhandles(hwHandles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

%% Prepare dialog box

prompt = {'Data points: ' '';...
    'Plot only time-interval of interest, if defined in FRET-pair window' 'onlytinterest';...
    'Exclude blinking intervals from plot' 'excludeBlinking';...
    'Exclude spacer from bleaching/blinking time (frames): ' 'framespacer';...
    'Max frames included from each molecule (0 is all): ' 'maxframes';...
    ...
    'Fit: ' '';...
    'Plot components of fitted histogram' 'plotEfit';...    
    'Plot the fitted sum of histogram' 'plotEfitTot';...
    'Colorize Gaussian components in histograms' 'GaussColorChoiceHist';...
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
formats(1,1).type = 'text';
formats(2,1).type = 'check';
formats(3,1).type = 'check';
formats(4,1).type = 'edit';
formats(4,1).size = 50;
formats(4,1).format = 'integer';
formats(5,1).type = 'edit';
formats(5,1).size = 50;
formats(5,1).format = 'integer';
formats(7,1).type = 'text';
formats(8,1).type = 'check';
formats(9,1).type = 'check';
formats(10,1).type = 'check';

formats(12,1).type = 'text';
formats(13,1).type = 'text';
formats(14,1).type = 'check';
formats(15,1).type = 'check';
formats(16,1).type = 'check';

% Default choices
DefAns.onlytinterest = mainhandles.settings.SEplot.onlytinterest;
DefAns.excludeBlinking = mainhandles.settings.SEplot.excludeBlinking;
DefAns.framespacer = mainhandles.settings.SEplot.framespacer;
DefAns.maxframes = mainhandles.settings.SEplot.maxframes;
DefAns.plotgammaspec = mainhandles.settings.SEplot.plotgammaspec;
DefAns.plotdleakspec = mainhandles.settings.SEplot.plotdleakspec;
DefAns.plotadirectspec = mainhandles.settings.SEplot.plotadirectspec;
DefAns.plotBleaching = mainhandles.settings.SEplot.plotBleaching;
DefAns.GaussColorChoiceHist = mainhandles.settings.SEplot.GaussColorChoiceHist;
DefAns.plotEfit = mainhandles.settings.SEplot.plotEfit;
DefAns.plotEfitTot = mainhandles.settings.SEplot.plotEfitTot;

options.CancelButton = 'on';

%% Open dialog box
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1) || (isequal(DefAns,answer))
    return
end

%% Update settings structure

mainhandles.settings.SEplot.onlytinterest = answer.onlytinterest;
mainhandles.settings.SEplot.excludeBlinking = answer.excludeBlinking;
mainhandles.settings.SEplot.framespacer = abs(answer.framespacer);
mainhandles.settings.SEplot.maxframes = abs(answer.maxframes);
mainhandles.settings.SEplot.plotBleaching = answer.plotBleaching;
mainhandles.settings.SEplot.plotgammaspec = answer.plotgammaspec;
mainhandles.settings.SEplot.plotdleakspec = answer.plotdleakspec;
mainhandles.settings.SEplot.plotadirectspec = answer.plotadirectspec;
mainhandles.settings.SEplot.GaussColorChoiceHist = answer.GaussColorChoiceHist;
mainhandles.settings.SEplot.plotEfit = answer.plotEfit;
mainhandles.settings.SEplot.plotEfit = answer.plotEfitTot;
updatemainhandles(mainhandles)

%% Update plot

mainhandles = updateSEplot(hwHandles.main,mainhandles.FRETpairwindowHandle,hwHandles.figure1,'all',[],[],1);
