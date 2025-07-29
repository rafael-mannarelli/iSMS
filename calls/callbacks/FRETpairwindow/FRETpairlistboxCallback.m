function [mainhandles, FRETpairwindowHandles] = FRETpairlistboxCallback(FRETpairwindowHandle)
% Callback for selection change in the FRET pair listbox in the FRET pair
% window
%
%     Input:
%      FRETpairwindowHandle   - handle to the FRETpair window
%
%     Output:
%      mainhandles            - handles structure of the main window
%      FRETpairwindowHandles  - handles structure of the FRETpair window
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

if isempty(FRETpairwindowHandle) || ~ishandle(FRETpairwindowHandle)
    mainhandles = guidata(getappdata(0,'mainhandle'));
    FRETpairwindowHandles = [];
    return
end

% Get handles structure of the FRET pair window
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles); % Turn of integration ROIs
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Turn off framesliders
if mainhandles.settings.FRETpairplots.frameSliders
    set(FRETpairwindowHandles.Toolbar_frameSliders,'state','off')
    mainhandles.settings.FRETpairplots.frameSliders = 0;
    updatemainhandles(mainhandles)
    updateFRETpairwindowGUImenus(mainhandles,FRETpairwindowHandles)
end

% Show warning about highlighting slowing down
if mainhandles.settings.FRETpairplots.showIntPixels || mainhandles.settings.FRETpairplots.showBackPixels
    mainhandles = myguidebox(mainhandles,...
        'Highlighting turned on',...
        sprintf(['Note that you have pixel highlighting turned on in the molecule images.\n'...
        'This slows down the program and hinders the use of arrow keys for listbox scrolling.\n\n'...
        'It is recommended you turn off highlighting when you don''t use it.']),...
        'pixelhighlighting');
end

%% Action

% Set contrast slider value
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1);
if size(selectedPairs,1)==1
    
    if isempty(mainhandles.data(selectedPairs(1)).FRETpairs(selectedPairs(2)).contrastslider)
        mainhandles.data(selectedPairs(1)).FRETpairs(selectedPairs(2)).contrastslider = 0;
        updatemainhandles(mainhandles)
    end
    
    set(FRETpairwindowHandles.ContrastSlider,'Value',mainhandles.data(selectedPairs(1)).FRETpairs(selectedPairs(2)).contrastslider);
end

% Highlight selected pair on ROI image
highlightFRETpair(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1)

% Update intensity trace plots and molecule images
[FRETpairwindowHandles,mainhandles] = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'all');

% Update frame sliders
[FRETpairwindowHandles,mainhandles] = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1);

% Update correction factor boxes
updateCorrectionFactors(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)

% If histogram is open and choice is on selected pair, update the histogram
if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')) ...
        && (~isempty(mainhandles.histogramwindowHandle)) && (ishandle(mainhandles.histogramwindowHandle))
    
    histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);
    if get(histogramwindowHandles.plotSelectedPairRadiobutton,'Value') ...
            || (get(histogramwindowHandles.plotAllExceptRadiobutton,'Value') && mainhandles.settings.SEplot.exceptchoice==1)
        mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
        figure(FRETpairwindowHandles.figure1)
        
    end
    
end
