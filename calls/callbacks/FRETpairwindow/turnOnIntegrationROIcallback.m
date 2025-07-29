function [mainhandles, FRETpairwindowHandles] = turnOnIntegrationROIcallback(FRETpairwindowHandles)
% Callback for turning on integration ROI from the FRETpairwindow toolbar
%
%     Input:
%      FRETpairwindowHandles   - handles structure of the FRETpair window
%
%     Output:
%      mainhandles             - handles structure of the main window
%      FRETpairwindowHandles   - ...
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

% DintROIhandle = handle to the D_em D_exc integration area ROI
% AintROIhandle = handle to the A_em D_exc integration area ROI
% AAintROIhandle = handle to the A_em A_exc integration area ROI

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'intROI');
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles) || isempty(mainhandles.data) % If no data is loaded, return
    set(hObject,'State','off')
    return
end

% If some ROIs already exists try to delete them
if (~isempty(FRETpairwindowHandles.DintROIhandle)) && (ishandle(FRETpairwindowHandles.DintROIhandle))
    try delete(FRETpairwindowHandles.DintROIhandle),  end
end
if (~isempty(FRETpairwindowHandles.AintROIhandle)) && (ishandle(FRETpairwindowHandles.AintROIhandle))
    try delete(FRETpairwindowHandles.AintROIhandle),  end
end

% File and pair choice
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single FRET-pair only','Integration area');
    set(FRETpairwindowHandles.Toolbar_IntegrationROI,'state','off')
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% Scheme
alex = mainhandles.settings.excitation.alex;

% Check if raw movie is still there
% [mainhandles, hasRaw, hasROI] = checkRawData(mainhandles,filechoice);

%% Display userguide info box

textstr = sprintf(['How to set pixel integration region:\n\n'...
    '  1) Move the activated ROI tools within the molecule images so that they cover the molecule.\n'...
    '  2) Resize the ROI by dragging in the corners of the tool.\n'...
    '  3) To FINISH, deactivate the ROI toggle button in the toolbar.\n\n'...
    'The intensity and FRET traces are automatically updated according to the new ROI.\n\n ']);
set(mainhandles.mboard, 'String',textstr)
mainhandles = myguidebox(mainhandles, 'Set integration ROI', textstr, 'integrationROI',1,'http://isms.au.dk/documentation/intensities-and-background/');

%% Initialize integration ROIs

% Get the start position of the integration-area ROIs
xlimD = get(FRETpairwindowHandles.DDimageAxes,'xlim');
ylimD = get(FRETpairwindowHandles.DDimageAxes,'ylim');
xlimA = get(FRETpairwindowHandles.ADimageAxes,'xlim');
ylimA = get(FRETpairwindowHandles.ADimageAxes,'ylim');

% Center and width of integration areas
Dxy = [median(xlimD) median(ylimD)]; % [x y] Position of the donor is in the center of the molecule image
Axy = [median(xlimA) median(ylimA)]; % [x y] Position of the acceptor is in the center of the molecule image
Dwh = mainhandles.data(filechoice).FRETpairs(pairchoice).Dwh; % Width and height of the donor integration area [w h] /pixels
Awh = mainhandles.data(filechoice).FRETpairs(pairchoice).Awh; % Width and height of the acceptor integration area [w h] /pixels

% ROI positions
pD = [Dxy(1)-Dwh(1)/2+0.5,  Dxy(2)-Dwh(2)/2+0.5,  Dwh(1),  Dwh(2)]; % Donor position area [xmin ymin width height]
pA = [Axy(1)-Awh(1)/2+0.5,  Axy(2)-Awh(2)/2+0.5,  Awh(1),  Awh(2)]; % Acceptor position area [xmin ymin width height]

%% Make ROIs

try
    %     delete(handles.DbackMaskHandle)
    %     delete(handles.DintMaskHandle)
    %     delete(handles.AbackMaskHandle)
    %     delete(handles.AintMaskHandle)
    %     delete(handles.AAbackMaskHandle)
    %     delete(handles.AAintMaskHandle)
end

% Make DD-integration ROI handle and define its position callback
DintROIhandle = imellipse(FRETpairwindowHandles.DDimageAxes,pD); % [xmin ymin width height]
setColor(DintROIhandle,'green')

% Make AD-integration ROI handle and define its position callback
AintROIhandle = imellipse(FRETpairwindowHandles.ADimageAxes,pA); % [xmin ymin width height]
setColor(AintROIhandle,'red')
addNewPositionCallback(AintROIhandle,@(p) updateAintROI(p)); % Position callback, to make sure AD and AA ROIs are the same

% Make constraints in ROI position:
fcn = makeConstrainToRectFcn('imrect',xlimD,ylimD);
setPositionConstraintFcn(DintROIhandle,fcn);
fcn = makeConstrainToRectFcn('imrect',xlimA,ylimA);
setPositionConstraintFcn(AintROIhandle,fcn);

% Make AA-integration ROI handle and define its position callback
if alex
    AAintROIhandle = imellipse(FRETpairwindowHandles.AAimageAxes,pA); % [xmin ymin width height]
    setColor(AAintROIhandle,'red')
    addNewPositionCallback(AAintROIhandle,@(p) updateAAintROI(p)); % Position callback, to make sure AD and AA ROIs are the same
    setPositionConstraintFcn(AAintROIhandle,fcn);
else
    AAintROIhandle = [];
end

%% Update

setappdata(0,'PairSelection',[filechoice pairchoice]) % Send the selected pair to appdata. Extracted when updating the handles structure
FRETpairwindowHandles.DintROIhandle = DintROIhandle;
FRETpairwindowHandles.AintROIhandle = AintROIhandle;
FRETpairwindowHandles.AAintROIhandle = AAintROIhandle;
guidata(FRETpairwindowHandles.figure1,FRETpairwindowHandles)
% updateDintROI(pD)
updateAintROI(pA)
updateAAintROI(pA)
