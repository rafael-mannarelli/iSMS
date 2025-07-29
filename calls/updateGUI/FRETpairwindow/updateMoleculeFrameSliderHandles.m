function [FRETpairwindowHandles, mainhandles] = updateMoleculeFrameSliderHandles(mainhandle,FRETpairwindowHandle)
% Updates/creates the handles for the imrect ROIs defining the
% frame-interval for the molecule images
% 
%    Input:
%     mainhandle           - handle to the main window
%     FRETpairwindowHandle - handle to the FRETpairwindow
%
%    Output:
%     FRETpairwindowHandles - handles structure of the FRETpairwindow
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

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(FRETpairwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(FRETpairwindowHandle))
    FRETpairwindowHandles = [];
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
FRETpairwindowHandles = guidata(FRETpairwindowHandle); % Handles to the FRET pair window

% Delete previous slider handles
warning off
try delete(FRETpairwindowHandles.DframeSliderHandle), end
try delete(FRETpairwindowHandles.AframeSliderHandle), end
try delete(FRETpairwindowHandles.AAframeSliderHandle), end
FRETpairwindowHandles.DframeSliderHandle = [];
FRETpairwindowHandles.AframeSliderHandle = [];
FRETpairwindowHandles.AAframeSliderHandle = [];
guidata(FRETpairwindowHandle,FRETpairwindowHandles)
warning on

% If frame-sliders are not activated, return
if ~mainhandles.settings.FRETpairplots.frameSliders
    return
end

% Get selected FRET-pairs
selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle); % Returns pair selection as [file pair;...]
if (isempty(mainhandles.data))  || (isempty(selectedPairs)) || size(selectedPairs,1)~=1
    return
end

% Selected file and FRET-pair
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% Scheme
alex = mainhandles.settings.excitation.alex;

% Check if movie has been deleted
if isempty(mainhandles.data(filechoice).DD_ROImovie) 
    
    % If raw movie has been deleted
    mymsgbox(sprintf('%s\n\n%s',...
        'The raw image data has been deleted for this file so I''ve turned off the frame sliders for you. ',...
        'You can reload the raw movie from the ''Memory -> Reload raw movie'' menu button.'),...
        'Raw data missing');
    
    % Turn off sliders
    mainhandles.settings.FRETpairplots.frameSliders = 0;
    updatemainhandles(mainhandles)
    updateFRETpairwindowGUImenus(mainhandles,FRETpairwindowHandles)
    return
end

%% Make sliders

% D slider
FRETpairwindowHandles.DframeSliderHandle = makeImgSlider(FRETpairwindowHandles,...
    'D',...
    'DDavgImageInterval',...
    FRETpairwindowHandles.DDtraceAxes,...
    @updateDDsliderImage);

% AD slider
FRETpairwindowHandles.AframeSliderHandle = makeImgSlider(FRETpairwindowHandles,...
    'D',...
    'ADavgImageInterval',...
    FRETpairwindowHandles.ADtraceAxes,...
    @updateADsliderImage);

% AA slider
if alex
    FRETpairwindowHandles.AAframeSliderHandle = makeImgSlider(FRETpairwindowHandles,...
        'A',...
        'AAavgImageInterval',...
        FRETpairwindowHandles.AAtraceAxes,...
        @updateAAsliderImage);
end

%% Update handles structure

guidata(FRETpairwindowHandle,FRETpairwindowHandles)

%% Nested

    function framesliderHandle = makeImgSlider(FRETpairwindowHandles,exc,intervalField,ax,posfcn)
        
        % Create interval if not existing already
        if isempty(mainhandles.data(filechoice).FRETpairs(pairchoice).(intervalField))
            temp = find(mainhandles.data(filechoice).excorder==exc);
            mainhandles.data(filechoice).FRETpairs(pairchoice).(intervalField) = [1 length(temp)];
        end
        
        % Slider interval
        idx = mainhandles.data(filechoice).FRETpairs(pairchoice).(intervalField); % Image interval
        frames = idxToTime(mainhandles,[filechoice pairchoice],exc,idx);
        
        % Initialize slider size
        xlims = get(ax,'xlim');
        ylims = get(ax,'ylim');
        yheight = diff(ylims)*4;
        ylow = ylims(1)-diff(ylims)/2;
        pos = [frames(1) ylow diff(frames) yheight]; % x y width height (-1 because the box is surrounding the ROI area)
        
        % Make roi
        framesliderHandle = imrect(ax,pos); % Create ROI handle
        
        % ROI properties
        set(framesliderHandle,'Interruptible', 'off')
        setColor(framesliderHandle,'blue') % Color
        
        % Position callback
        updatemainhandles(mainhandles) % Sends mainhandles to appdata
        addNewPositionCallback(framesliderHandle,@(p) posfcn(p));
        
        % Make constraint in imrect position
        fcn = makeConstrainToRectFcn('imrect',xlims,[ylow ylow+yheight]);
        setPositionConstraintFcn(framesliderHandle,fcn);
        
        % Set axis limits back to previous
%         if ~mainhandles.settings.FRETpairplots.autozoom
            set(ax,'ylim',ylims)
%         end

    end

end

function updateDDsliderImage(pos,mainhandle,FRETpairwindowHandle) %% Runs when the avg image-slider is changed
mainhandle = getappdata(0,'mainhandle');
mainhandles = guidata(mainhandle);
FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

% Turn off all toggled buttons
FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'all');

% Selected FRET pairs
selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle);

% Check input
if size(selectedPairs,1)~=1 ...
        || ~mainhandles.settings.FRETpairplots.frameSliders ...
        || (isempty(mainhandles.data(selectedPairs(1,1)).imageData) ...
        && isempty(mainhandles.data(selectedPairs(1,1)).DD_ROImovie))
    
    warning off
    try delete(FRETpairwindowHandles.DframeSliderHandle), end
    warning on
    FRETpairwindowHandles.DframeSliderHandle = [];
    guidata(FRETpairwindowHandle,FRETpairwindowHandles)
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% % Delete previous rectangle
% h = findobj(mainhandles.framesliderAxes,'type','rectangle');
% delete(h)

if isempty(mainhandles.data(filechoice).DD_ROImovie)
    return
end

% Position of frame slider ROI
pos = getPosition(FRETpairwindowHandles.DframeSliderHandle); % [xPos yPos width height]
if pos(3)==0 % If width has been squeezed to zero
    pos(3) = 1;
    setPosition(FRETpairwindowHandles.DframeSliderHandle,pos) % [x y width height]. This will re-run this function
    return
end

% % Make new rectangle plot inside ROI
% axes(FRETpairwindowHandles.framesliderAxes)
% h = rectangle('Position',pos,'FaceColor',[1 1 1]); % Plot rectangular area [x y width height]
% uistack(h,'bottom')

% Update handles structure with new interval
% pos = floor(pos); % Round it

% Convert from time to index
idx = timeToIdx(mainhandles,[filechoice pairchoice],'D',[pos(1) pos(1)+pos(3)]);

mainhandles.data(filechoice).FRETpairs(pairchoice).DDavgImageInterval = idx;
updatemainhandles(mainhandles)

% Calculate new molecule image
mainhandles = calculateMoleculeImages(mainhandle,selectedPairs,'DD');

% Update plot
[FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandle,FRETpairwindowHandle,'images',[],'DD');

% Update other images too
if mainhandles.settings.FRETpairplots.linkFrameSliders
    % New A and AA positions
    Apos = getPosition(FRETpairwindowHandles.AframeSliderHandle);
    Apos([1 3]) = pos([1 3]);
    setPosition(FRETpairwindowHandles.AframeSliderHandle,Apos) % [x y width height]. This will re-run this function

    if mainhandles.settings.excitation.alex
        AApos = getPosition(FRETpairwindowHandles.AAframeSliderHandle);
        AApos([1 3]) = pos([1 3]);
        setPosition(FRETpairwindowHandles.AAframeSliderHandle,AApos) % [x y width height]. This will re-run this function
    end
    
    % Set A and AA positions
    mainhandles = guidata(mainhandle);
end
end

function updateADsliderImage(pos) %% Runs when the avg image-slider is changed
mainhandle = getappdata(0,'mainhandle');
mainhandles = guidata(mainhandle);
FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

% Turn off all toggled buttons
FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'all');

% Selected FRET pairs
selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle);

% Check input
if size(selectedPairs,1)~=1 || ~mainhandles.settings.FRETpairplots.frameSliders ||(isempty(mainhandles.data(selectedPairs(1,1)).imageData) && isempty(mainhandles.data(selectedPairs(1,1)).AD_ROImovie))
    warning off
    try delete(FRETpairwindowHandles.AframeSliderHandle), end
    warning on
    FRETpairwindowHandles.AframeSliderHandle = [];
    guidata(FRETpairwindowHandle,FRETpairwindowHandles)
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% % Delete previous rectangle
% h = findobj(mainhandles.framesliderAxes,'type','rectangle');
% delete(h)

if isempty(mainhandles.data(filechoice).AD_ROImovie)
    return
end

% Position of frame slider ROI
pos = getPosition(FRETpairwindowHandles.AframeSliderHandle); % [xPos yPos width height]
if pos(3)==0 % If width has been squeezed to zero
    pos(3) = 1;
    setPosition(FRETpairwindowHandles.AframeSliderHandle,pos) % [x y width height]. This will re-run this function
    return
end

% % Make new rectangle plot inside ROI
% axes(FRETpairwindowHandles.framesliderAxes)
% h = rectangle('Position',pos,'FaceColor',[1 1 1]); % Plot rectangular area [x y width height]
% uistack(h,'bottom')

% Update handles structure with new interval
% pos = floor(pos); % Round it because we want it in pixels

% Convert from time to index
idx = timeToIdx(mainhandles,[filechoice pairchoice],'D',[pos(1) pos(1)+pos(3)]);

mainhandles.data(filechoice).FRETpairs(pairchoice).ADavgImageInterval = idx;
updatemainhandles(mainhandles)

% Calculate new molecule image
mainhandles = calculateMoleculeImages(mainhandle,selectedPairs,'AD');

% Update plot
[FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandle,FRETpairwindowHandle,'images',[],'AD');

% Update other images too
if mainhandles.settings.FRETpairplots.linkFrameSliders
    % New D and AA positions
    Dpos = getPosition(FRETpairwindowHandles.DframeSliderHandle);
    Dpos([1 3]) = pos([1 3]);
    setPosition(FRETpairwindowHandles.DframeSliderHandle,Dpos) % [x y width height]. This will re-run this function

    if mainhandles.settings.excitation.alex
        AApos = getPosition(FRETpairwindowHandles.AAframeSliderHandle);
        AApos([1 3]) = pos([1 3]);
        setPosition(FRETpairwindowHandles.AAframeSliderHandle,AApos) % [x y width height]. This will re-run this function
    end
    
    % Set D and AA positions
    mainhandles = guidata(mainhandle);
end
end

function updateAAsliderImage(pos) %% Runs when the avg image-slider is changed
mainhandle = getappdata(0,'mainhandle');
mainhandles = guidata(mainhandle);
FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

% Turn off all toggled buttons
FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'all');

% Selected FRET pairs
selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle);

% Check input
if size(selectedPairs,1)~=1 || ~mainhandles.settings.FRETpairplots.frameSliders ||(isempty(mainhandles.data(selectedPairs(1,1)).imageData) && isempty(mainhandles.data(selectedPairs(1,1)).AA_ROImovie))
    warning off
    try delete(FRETpairwindowHandles.AAframeSliderHandle), end
    warning on
    FRETpairwindowHandles.AAframeSliderHandle = [];
    guidata(FRETpairwindowHandle,FRETpairwindowHandles)
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% % Delete previous rectangle
% h = findobj(mainhandles.framesliderAxes,'type','rectangle');
% delete(h)

if isempty(mainhandles.data(filechoice).AA_ROImovie)
    return
end

% Get ROI limits
% ROIlims = get(FRETpairwindowHandles.AAframeSliderHandle,'UserData'); % [xlim(1) xlim(2) ylim(1) ylim(2)]

% Position of frame slider ROI
pos = getPosition(FRETpairwindowHandles.AAframeSliderHandle); % [xPos yPos width height]
if pos(3)==0 % If width has been squeezed to zero
    pos(3) = 1;
    setPosition(FRETpairwindowHandles.AAframeSliderHandle,pos) % [x y width height]. This will re-run this function
    return
end

% % Make new rectangle plot inside ROI
% axes(FRETpairwindowHandles.framesliderAxes)
% h = rectangle('Position',pos,'FaceColor',[1 1 1]); % Plot rectangular area [x y width height]
% uistack(h,'bottom')

% Update handles structure with new interval
% pos = floor(pos); % Round it because we want it in pixels

% Convert from time to index
idx = timeToIdx(mainhandles,[filechoice pairchoice],'D',[pos(1) pos(1)+pos(3)]);

mainhandles.data(filechoice).FRETpairs(pairchoice).AAavgImageInterval = idx;
updatemainhandles(mainhandles)

% Calculate new molecule image
mainhandles = calculateMoleculeImages(mainhandle,selectedPairs,'AA');

% Update plot
[FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandle,FRETpairwindowHandle,'images',[],'AA');

% Update other images too
if mainhandles.settings.FRETpairplots.linkFrameSliders
    % New D and A positions
    Dpos = getPosition(FRETpairwindowHandles.DframeSliderHandle);
    Apos = getPosition(FRETpairwindowHandles.AframeSliderHandle);
    Dpos([1 3]) = pos([1 3]);
    Apos([1 3]) = pos([1 3]);
    
    % Set A and AA positions
    setPosition(FRETpairwindowHandles.DframeSliderHandle,Dpos) % [x y width height]. This will re-run this function
    setPosition(FRETpairwindowHandles.AframeSliderHandle,Apos) % [x y width height]. This will re-run this function
    mainhandles = guidata(mainhandle);
end
end
