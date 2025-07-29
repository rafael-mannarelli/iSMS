function [mainhandles, FRETpairwindowHandles] = turnOffIntegrationROIcallback(FRETpairwindowHandles)
% Called when the integration ROI is turned off in the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles   - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles             - handles structure of the main window
%     FRETpairwindowHandles   - ..
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

mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end
ok = 0; % Just to check if GUI should in fact be updated

% Get the selected pair like this because the PairListbox value may
% have changed before turning off the toggle button
PairSelection = getappdata(0,'PairSelection');
filechoice = PairSelection(1);
pairchoice = PairSelection(2);

% Check if raw movie is still there
[mainhandles, hasRaw, hasROI] = checkRawData(mainhandles,filechoice);
if ~hasROI
    mymsgbox('Note that, without the raw image data, nothing thus happens when changing the integration ROI.')
    try delete(FRETpairwindowHandles.DintROIhandle),  end
    try delete(FRETpairwindowHandles.AintROIhandle),  end
    try delete(FRETpairwindowHandles.AAintROIhandle),  end
    return
end

%% Set new donor integration area

if (~isempty(FRETpairwindowHandles.DintROIhandle))% && (ishandle(handles.DintROIhandle))
    
    % Previous position of the integration area (= center of image)
    xlimD = get(FRETpairwindowHandles.DDimageAxes,'xlim');
    ylimD = get(FRETpairwindowHandles.DDimageAxes,'ylim');
    imageCenter = [median(xlimD) median(ylimD)];
    
    % New integration area defined by the ROI position
    p = getPosition(FRETpairwindowHandles.DintROIhandle); % ROI position and size [xmin ymin width height]
    xy = p(1:2)+p(3:4)/2-0.5; % Center of ROI
    wh = p(3:4); % Size of ROI
    
    % Try deleting the ROI in the DD image
    try delete(FRETpairwindowHandles.DintROIhandle),  end
    
    % Only update if ROI has been changed
    if (~isequal(xy,imageCenter)) || (~isequal(mainhandles.data(filechoice).FRETpairs(pairchoice).Dwh,wh))
        % Difference between old and new center
        diff = xy(1:2) - imageCenter;
        
        % Put new D integration range into the selected data field of the mainhandles structure
        idx = find( ismember(mainhandles.data(filechoice).Dpeaks, mainhandles.data(filechoice).FRETpairs(pairchoice).Dxy, 'rows','legacy') ); % Index of donor peak in Dpeaks
        mainhandles.data(filechoice).Dpeaks(idx,:) = mainhandles.data(filechoice).Dpeaks(idx,:) + diff;
        mainhandles.data(filechoice).FRETpairs(pairchoice).Dxy = mainhandles.data(filechoice).FRETpairs(pairchoice).Dxy + diff;
        mainhandles.data(filechoice).FRETpairs(pairchoice).Dwh = wh;
        
        % Create new integration and background mask
        %     maskMATLAB = createMask(handles.AintROIhandle,handles.ADimage)
        %         [intMask,backMask] = getMask(size(getimage(handles.DDimage)),xy(1),xy(2),wh(1),wh(2));
        mainhandles.data(filechoice).FRETpairs(pairchoice).DintMask = []; % This will force a new mask calculation by calculateIntensityTraces
        mainhandles.data(filechoice).FRETpairs(pairchoice).DbackMask = [];
        
        % It's ok to update the handles structure
        ok = 1;
    end
end

%% Set new acceptor integration area

if (~isempty(FRETpairwindowHandles.AintROIhandle))% && (ishandle(handles.AintROIhandle)) % Try deleting the ROI in the AD image
    
    % Previous position of the integration area (= center of image)
    xlimA = get(FRETpairwindowHandles.ADimageAxes,'xlim');
    ylimA = get(FRETpairwindowHandles.ADimageAxes,'ylim');
    imageCenter = [median(xlimA) median(ylimA)];
    
    % New integration area defined by the ROI position
    p = getPosition(FRETpairwindowHandles.AintROIhandle); % ROI position and size [xmin ymin width height]
    xy = p(1:2)+p(3:4)/2-0.5; % Center of ROI
    wh = p(3:4); % Size of ROI
    
    % Try deleting the ROI in the AD image
    try delete(FRETpairwindowHandles.AintROIhandle),  end
    
    % Only update if ROI has been changed
    if (~isequal(xy,imageCenter)) || (~isequal(mainhandles.data(filechoice).FRETpairs(pairchoice).Awh,wh))
        % Difference between old and new center
        diff = xy(1:2) - imageCenter;
        
        % Put new integration range into the selected data field of the mainhandles structure
        idx = find( ismember(mainhandles.data(filechoice).Apeaks, mainhandles.data(filechoice).FRETpairs(pairchoice).Axy, 'rows','legacy') ); % Index of acceptor peak in Dpeaks
        mainhandles.data(filechoice).Apeaks(idx,:) = mainhandles.data(filechoice).Apeaks(idx,:) + diff;
        mainhandles.data(filechoice).FRETpairs(pairchoice).Axy = mainhandles.data(filechoice).FRETpairs(pairchoice).Axy + diff;
        mainhandles.data(filechoice).FRETpairs(pairchoice).Awh = wh;
        
        % Create new integration and background mask
        mainhandles.data(filechoice).FRETpairs(pairchoice).AintMask = []; % This will force a new mask calculation by calculateIntensityTraces
        mainhandles.data(filechoice).FRETpairs(pairchoice).AbackMask = [];
        
        % It's ok to update the handles structure
        ok = 1;
    end
end
if (~isempty(FRETpairwindowHandles.AAintROIhandle))% && (ishandle(handles.AAintROIhandle)) % Try deleting the ROI in the AA image
    try delete(FRETpairwindowHandles.AAintROIhandle),  end
end

%% Update handles, intensity trace and plots

if ok
    
    % Update handles structure
    updatemainhandles(mainhandles)
    
    % Update intensity traces
    mainhandles = updatepeakglobal(mainhandles,'all'); % Update the coordinates in the global coordinate system
    mainhandles = calculateIntensityTraces(FRETpairwindowHandles.main,[filechoice pairchoice]);
    mainhandles.data(filechoice).FRETpairs(pairchoice).DD_avgimage = []; % This will force a molecule image re-calculation by updateFRETpairplots
    updatemainhandles(mainhandles)
    
    % Keep listbox selection if it has changed
    if mainhandles.settings.FRETpairplots.sortpairs>2
        listedPairs = getPairs(FRETpairwindowHandles.main,'listed',[],FRETpairwindowHandles.figure1); % Pairs listed
        idx = find( ismember(listedPairs,[filechoice pairchoice],'rows','legacy') ); % Find new idx
        set(FRETpairwindowHandles.PairListbox, 'Value',idx) % Set to new idx
    end
    
    % Update plots
    FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'all');
    FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1);
    
    % If histogram is open update the histogram
    if strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')
        mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
    end
    
end
