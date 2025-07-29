function [mainhandles,FRETpairwindowHandles] = backgroundSettings(mainhandle)
% backgroundSettings creates a modal dialog box for setting molecule
% background settings
%
%    Input:
%     mainhandle   - handle to the main figure window (sms)
%
%    Output:
%     mainhandles  - handles structure of the main window
%     FRETpairwindowHandles - handles structure of the FRET pair window
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

if nargin<1
    mainhandle = getappdata(0,'mainhandle');
end

% Check number of input arguments
if (isempty(mainhandle)) || (~ishghandle(mainhandle))
    try
        mainhandle = getappdata(0,'mainhandle');
        mainhandles = guidata(mainhandle); % Get mainhandles structure
    catch err
        mainhandles = []; % Get mainhandles structure
        FRETpairwindowHandles = []; % Get mainhandles structure
        return
    end
end

% Get handles structures
mainhandles = guidata(mainhandle); % Get mainhandles structure
try FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
catch err
    FRETpairwindowHandles = [];
end

%% Set up default answers structure

DefAns.choice = mainhandles.settings.background.choice; % Use background subtraction
DefAns.backtype = mainhandles.settings.background.backtype; % How background is calculated. 1 = avg intensity just outside integration area. 2 = baseline from Gaussian fit. 3 = from spot-profile.
DefAns.prctile = mainhandles.settings.background.prctile; % Percentile used for LSP
DefAns.bleachchoice = mainhandles.settings.background.bleachchoice; % Whenever possible, use average intensity of user-specified trace time-interval (e.g. after bleaching)
DefAns.blinkchoice = mainhandles.settings.background.blinkchoice; % Whenever possible, use average intensity of user-specified trace time-interval (e.g. after bleaching)
DefAns.blinkbleachchoice = mainhandles.settings.background.blinkbleachchoice; % What to do if both blinking and bleaching is set
DefAns.minDarkFrames = mainhandles.settings.background.minDarkFrames; % Minimum number of frames needed for background if using a dark state (bleach/blink)
DefAns.avgchoice =  mainhandles.settings.background.avgchoice; % 1 = Don't use averaging. 2 = Use averaging of neighbouring frames in background calculation. 3 = Use background averaged from all frames
DefAns.avgneighbours = mainhandles.settings.background.avgneighbours; % How many neighbours to average (if avgchoice == 2)
DefAns.backspace = mainhandles.settings.background.backspace; % Space in between integration and background circle
DefAns.backwidth = mainhandles.settings.background.backwidth; % Width of background circle / pixels

%% Create GUI window

h.figure1 = dialog(...
    'Name',     'Background settings',...
    'Visible',  'off',...
    'UserData', 'Cancel');
movegui(h.figure1,'center')
updatelogo(h.figure1) % Update logo

%--------- Create GUI components ---------%
% Checkbox, apply background subtraction choice
h.ChoiceCheckbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'check',...
    'String',   'Use background subtraction',...
    'Value',    DefAns.choice);

% Textbox, background type
h.backgroundtypeTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Background:',...
    'HorizontalAlignment',   'left'...
    );
% Popupmenu, background type
% if mainhandles.ispublic
%     defStr = {'Mean intensity of background mask'};
%     if DefAns.backtype>1
%         DefAns.backtype = 1;
%     end
% else
    defStr = {'Mean intensity of background mask',...
    'Median intensity of background mask',...
    'Percentile of background mask (LSP)'};
% end
h.backgroundtypeListbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'popupmenu',...
    'String',   defStr,...
    'Value',    DefAns.backtype,...
    'BackgroundColor',  'white'...
    );

% if ~mainhandles.ispublic
    % Textbox, default background circle width
    h.percentileTextbox = uicontrol(...
        'Parent',   h.figure1,...
        'Style',    'text',...
        'String',   'Percentile of background pixel distribution (0-100%): ',...
        'HorizontalAlignment',   'left'...
        );
    % Editbox, default background circle width
    h.percentileEditbox = uicontrol(...
        'Parent',   h.figure1,...
        'String',   DefAns.prctile,...
        'Style',    'edit',...
        'BackgroundColor',  'white'...
        );
% end

% Checkbox, use intensity after bleaching
h.intensityAfterBleachingCheckbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'check',...
    'String',   'Use average intensity after bleaching whenever possible',...
    'Value',    DefAns.bleachchoice...
    );
% Textbox, use intensity after bleaching note
h.intensityAfterBleachingTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   '(applied to traces where bleaching time is defined)',...
    'HorizontalAlignment',   'left'...
    );

% Checkbox, use blinking
h.intensityDuringBlinkingCheckbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'check',...
    'String',   'Use average intensity during blinking whenever possible',...
    'Value',    DefAns.blinkchoice...
    );
% Textbox, use intensity after bleaching note
h.intensityDuringBlinkingTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   '(applied to traces where blinking interval is defined)',...
    'HorizontalAlignment',   'left'...
    );

% Textbox, default background circle width
h.minDarkFramesTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Min. number of dark frames needed for background: ',...
    'HorizontalAlignment',   'left'...
    );
% Editbox, default background circle width
h.minDarkFramesEditbox = uicontrol(...
    'Parent',   h.figure1,...
    'String',   DefAns.minDarkFrames,...
    'Style',    'edit',...
    'BackgroundColor',  'white'...
    );

% Textbox, blinking%bleaching
h.blinkbleachchoiceTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'If both blinking and bleaching is set, use: ',...
    'HorizontalAlignment',   'left'...
    );
% Popupmenu, blinking & bleaching
h.blinkbleachchoiceListbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'popupmenu',...
    'String',   {'Min. of the two',...
    'Avg. of the two',...
    'Only bleaching',...
    'Only blinking'},...
    'Value',    DefAns.blinkbleachchoice,...
    'BackgroundColor',  'white'...
    );

% Textbox, frame averaging
h.frameAveragingTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Frame averaging:',...
    'HorizontalAlignment',   'left'...
    );
% Popupmenu, frame averaging
h.frameAveragingListbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'popupmenu',...
    'String',   {'No averaging',...
    'Average background of neighbouring frames',...
    'Average background over all frames'},...
    'Value',    DefAns.avgchoice,...
    'BackgroundColor',  'white'...
    );

% Textbox, number of neighbouring frames averaged
h.avgneighboursTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Number of neighbouring frames averaged:',...
    'HorizontalAlignment',   'left'...
    );
% Editbox, number of neighbouring frames to average
h.avgneighboursEditbox = uicontrol(...
    'Parent',   h.figure1,...
    'String',   DefAns.avgneighbours,...
    'Style',    'edit',...
    'BackgroundColor',  'white'...
    );

% Textbox, default space width
h.backspaceTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Default empty space from integration to background (pixels):',...
    'HorizontalAlignment',   'left'...
    );
% Editbox, default space width
h.backspaceEditbox = uicontrol(...
    'Parent',   h.figure1,...
    'String',   DefAns.backspace,...
    'Style',    'edit',...
    'BackgroundColor',  'white'...
    );

% Textbox, default background circle width
h.backwidthTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Default width of background circle (pixels):',...
    'HorizontalAlignment',   'left'...
    );
% Editbox, default background circle width
h.backwidthEditbox = uicontrol(...
    'Parent',   h.figure1,...
    'String',   DefAns.backwidth,...
    'Style',    'edit',...
    'BackgroundColor',  'white'...
    );

%-- OK pushbutton --%
h.OKpushbutton = uicontrol(...
    'Parent',   h.figure1,...
    'String',   'OK',...
    'Style',    'pushbutton'...
    );

%-- Cancel pushbutton --%
h.CancelPushbutton = uicontrol(...
    'Parent',   h.figure1,...
    'String',   'Cancel',...
    'Style',    'pushbutton'...
    );

%% Set positions

GUIdimensions
figW = 403;
vpos = bottomspace;
verspace = 4;
vergap = 12;
setpixelposition(h.OKpushbutton, [figW-rightspace-2*buttonwidth-horspace  vpos  buttonwidth  buttonheight]);
setpixelposition(h.CancelPushbutton, [figW-rightspace-buttonwidth  vpos  buttonwidth  buttonheight]);

vpos = vpos+buttonheight+vergap;
setpixelposition(h.backwidthEditbox, [357  vpos  31  editH]);
setpixelposition(h.backwidthTextbox, [34  vpos  313  textH]);
vpos = vpos+editH+verspace;
setpixelposition(h.backspaceEditbox, [357  vpos  31  editH]);
setpixelposition(h.backspaceTextbox, [34  vpos  313  textH]);

vpos = vpos+editH+vergap;
setpixelposition(h.avgneighboursEditbox, [357  vpos  31  editH]);
setpixelposition(h.avgneighboursTextbox, [135  vpos  211  textH]);
vpos = vpos+editH+verspace;
setpixelposition(h.frameAveragingListbox, [128  vpos  260  editH]);
setpixelposition(h.frameAveragingTextbox, [34  vpos  93  textH]);

vpos = vpos+editH+vergap;
setpixelposition(h.blinkbleachchoiceListbox, [269 vpos 120 editH]);
setpixelposition(h.blinkbleachchoiceTextbox, [65 vpos  203 textH]);
vpos = vpos+editH+verspace;
setpixelposition(h.minDarkFramesEditbox, [358 vpos 31 editH]);
setpixelposition(h.minDarkFramesTextbox, [65 vpos 282 textH]);
vpos = vpos+editH+verspace;
setpixelposition(h.intensityDuringBlinkingTextbox, [81  vpos  300  textH]);
vpos = vpos+textH+verspace;
setpixelposition(h.intensityDuringBlinkingCheckbox, [65  vpos  330  checkH]);
vpos = vpos+checkH+verspace;
setpixelposition(h.intensityAfterBleachingTextbox, [81  vpos  300  textH]);
vpos = vpos+textH+verspace;
setpixelposition(h.intensityAfterBleachingCheckbox, [65  vpos  330  checkH]);

% if ~mainhandles.ispublic
    vpos = vpos+textH+vergap;
    setpixelposition(h.percentileEditbox, [357  vpos  31  editH]);
    setpixelposition(h.percentileTextbox, [65  vpos  313  textH]);
% end

vpos = vpos+editH+vergap;
setpixelposition(h.backgroundtypeListbox, [103  vpos  285  editH]);
setpixelposition(h.backgroundtypeTextbox, [34  vpos  70  textH])

vpos = vpos+editH+vergap;
setpixelposition(h.ChoiceCheckbox, [17  vpos  250  checkH])

figH = vpos+checkH+topspace;
setpixelposition(h.figure1, [10 10 figW figH])
movegui(h.figure1,'center')

%% Set callbacks

set(h.ChoiceCheckbox,'Callback',{@updateGUI, h}); % Assign callback
set(h.backgroundtypeListbox,'Callback',{@updateGUI, h}); % Assign callback
set(h.intensityAfterBleachingCheckbox,'Callback',{@updateGUI, h})
set(h.intensityDuringBlinkingCheckbox,'Callback',{@updateGUI, h})
set(h.frameAveragingListbox,'Callback',{@updateGUI, h}); % Assign callback
set(h.backspaceEditbox,'Callback',{@updateGUI, h}); % Assign callback
set(h.backwidthEditbox,'Callback',{@updateGUI, h}); % Assign callback
set(h.frameAveragingListbox,'Callback',{@updateGUI, h}); % Assign callback
set(h.avgneighboursEditbox,'Callback',{@avgneighboursEditbox_Callback, h}); % Assign callback
set(h.OKpushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback
set(h.CancelPushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback
% if ~mainhandles.ispublic
    set(h.percentileEditbox,'Callback',{@prctileEditbox_Callback, h});
% end

%% Update dialog

guidata(h.figure1,h)
updateGUI([],[],h)
set(h.figure1,'Visible','on')

% For closing the figure
if ishghandle(h.figure1)
    % Go into uiwait if the figure handle is still valid.
    % This is mostly the case during regular use.
    uiwait(h.figure1);
end

%% This code hereafter is only run once uiresume is called

% Check handle validity again since we may be out of uiwait because the
% figure was deleted.
if ishghandle(h.figure1)
    if strcmp(get(h.figure1,'UserData'),'OK')
        answer.choice = get(h.ChoiceCheckbox,'Value'); % Use background subtraction
        answer.backtype = get(h.backgroundtypeListbox,'Value'); % How background is calculated. 1 = avg intensity just outside integration area. 2 = baseline from Gaussian fit. 3 = from spot-profile.
        answer.prctile = str2num(get(h.percentileEditbox,'String'));
        answer.bleachchoice = get(h.intensityAfterBleachingCheckbox,'Value'); % Whenever possible, use average intensity of user-specified trace time-interval (e.g. after bleaching)
        answer.blinkchoice = get(h.intensityDuringBlinkingCheckbox,'Value');
        answer.blinkbleachchoice = get(h.blinkbleachchoiceListbox,'Value');
        answer.minDarkFrames = str2num(get(h.minDarkFramesEditbox,'String'));
        answer.avgchoice = get(h.frameAveragingListbox,'Value'); % 1 = Don't use averaging. 2 = Use averaging of neighbouring frames in background calculation. 3 = Use background averaged from all frames
        answer.avgneighbours = str2num(get(h.avgneighboursEditbox,'String')); % How many neighbours to average (if avgchoice == 2)
        answer.backspace = str2num(get(h.backspaceEditbox,'String')); % Default width in between integration area and background circler
        answer.backwidth = str2num(get(h.backwidthEditbox,'String')); % Default width of background ring /pixels
    end
    delete(h.figure1);
else
    answer = [];
end

% User pressed Cancel
if isempty(answer)
    return
end

% No settings changed
ok = 0;
if isequal(DefAns,answer)
    choice = myquestdlg('You have not changed any settings. Do you wish to recalculate traces anyway?','Calculate',...
        'Yes','No','No');
    if strcmpi(choice,'No')
        return
    end
    ok = 1;
end

%% Pairs that must be updated

calcPairs1 = [];
if ~isempty(getPairs(mainhandle,'all'))
    
    % Dialog
    choice = myquestdlg(sprintf('%s%s',...
        'Do you wish to update backgrounds according to the new settings?'),...
        'Update background according to new settings',...
        'Apply to all molecules','Apply to selected molecules','No','Apply to all molecules');
    
    % User pressed close
    if isempty(choice)
        return
    end
    
    % Reset
    if strcmpi(choice,'Apply to all molecules')
        calcPairs1 = getPairs(mainhandle,'all');
    elseif strcmpi(choice,'Apply to selected molecules')
        calcPairs1 = getPairs(mainhandle,'Selected');
    end
end

% Determine what pairs to re-calculate based on bleaching and blinking
calcPairs2 = [];
if ok ...
        || ~isequal(answer.choice, DefAns.choice) ...
        || ~isequal(answer.backtype, DefAns.backtype)...
        || ~isequal(answer.avgchoice,DefAns.avgchoice)...
        || ~isequal(answer.prctile,DefAns.prctile)...
        || (~isequal(answer.avgneighbours, DefAns.avgneighbours) && answer.avgchoice==2)
    
    % Settings are changed so that not just pairs with bleach blink must be
    % updated
    calcPairs2 = getPairs(mainhandle,'all');
    
else
    
    % Only calculate a subset of molecules that has bleach or blink defined
    bleachPairs = getPairs(mainhandle,'bleach');
    blinkPairs = getPairs(mainhandle,'blink');
    blinkbleachPairs = getPairs(mainhandle,'blinkbleach');
    
    if ~isequal(answer.bleachchoice, DefAns.bleachchoice) || ~isequal(answer.minDarkFrames, DefAns.minDarkFrames)
        calcPairs2 = [calcPairs2; bleachPairs];
    end
    if ~isequal(answer.blinkchoice, DefAns.blinkchoice) || ~isequal(answer.minDarkFrames, DefAns.minDarkFrames)
        calcPairs2 = [calcPairs2; blinkPairs];
    end
    if ~isequal(answer.blinkbleachchoice, DefAns.blinkbleachchoice)
        calcPairs2 = [calcPairs2; blinkbleachPairs];
    end
    
end

%% Set new settings

prevback = [mainhandles.settings.background.backspace  mainhandles.settings.background.backwidth];

if answer.avgneighbours < 1
    answer.avgneighbours = 1;
else
    answer.avgneighbours = abs(answer.avgneighbours); % How many neighbours to average (if avgchoice == 2)
end

% Save as default dialog
mainhandles = savesettingasDefaultDlg(mainhandles,...
    'background',...
    {'choice' 'backtype' 'prctile' 'bleachchoice' 'blinkchoice' 'blinkbleachchoice'...
    'minDarkFrames' 'avgchoice' 'avgneighbours' 'backspace' 'backwidth'},...
    {answer.choice, answer.backtype, answer.prctile, answer.bleachchoice, answer.blinkchoice, answer.blinkbleachchoice,...
    answer.minDarkFrames answer.avgchoice answer.avgneighbours answer.backspace answer.backwidth });

%% Update pairs

% Return
if isempty(calcPairs2) || isempty(calcPairs1)
    return
end

% Combined pairs to calculate
calcPairs = [];
try calcPairs = calcPairs1( find(ismember(calcPairs1,calcPairs2,'rows')),: );
end

if isempty(calcPairs)
    return
end

% Reset pairs
for i = 1:size(calcPairs,1)
    file = calcPairs(i,1);
    pair = calcPairs(i,2);
    if ~isempty(mainhandles.data(file).DD_ROImovie)
        mainhandles.data(file).FRETpairs(pair).DbackMask = [];
        mainhandles.data(file).FRETpairs(pair).AbackMask = [];
        mainhandles.data(file).FRETpairs(pair).backspace = mainhandles.settings.background.backspace;
        mainhandles.data(file).FRETpairs(pair).backwidth = mainhandles.settings.background.backwidth;
        mainhandles.data(file).FRETpairs(pair).DD_avgimage = []; % This will force a molecule image re-calculation by updateFRETpairplots
    end
end

% Update
updatemainhandles(mainhandles)

%% Calculate intensity traces and update plots

mainhandles = calculateIntensityTraces(mainhandle,calcPairs);
FRETpairwindowHandles = updateFRETpairplots(mainhandle,mainhandles.FRETpairwindowHandle,'all');
FRETpairwindowHandles = updateMoleculeFrameSliderHandles(mainhandle,mainhandles.FRETpairwindowHandle);

% If histogram is open update the histogram
if strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')
    mainhandles = updateSEplot(mainhandle,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
end

end

%-----------------------------------------------------------%
%-----------------------------------------------------------%
%-----------------------------------------------------------%

function pushbutton_Callback(hObject,eventdata,h) %%
if ~strcmp(get(hObject,'String'),'Cancel')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end
end

function updateGUI(Object,eventdata,h) %% Updates the visibility of the individual GUI components depending on the selection choices
h_temp = [h.backgroundtypeTextbox  h.backgroundtypeListbox...
    h.intensityAfterBleachingCheckbox  h.intensityAfterBleachingTextbox...
    h.intensityDuringBlinkingCheckbox  h.intensityDuringBlinkingTextbox...
    h.blinkbleachchoiceListbox  h.blinkbleachchoiceTextbox...
    h.minDarkFramesTextbox  h.minDarkFramesEditbox...
    h.frameAveragingTextbox  h.frameAveragingListbox...
    h.avgneighboursTextbox  h.avgneighboursEditbox...
    h.backspaceTextbox h.backspaceEditbox...
    h.backwidthTextbox h.backwidthEditbox...
    ];

% Only part of internal versio
try h_temp = [h_temp h.percentileTextbox h.percentileEditbox]; end

% Check use background
if get(h.ChoiceCheckbox,'Value')==1
    set(h_temp,'Enable','on')
elseif get(h.ChoiceCheckbox,'Value')==0
    set(h_temp,'Enable','off')
    return
end

% Check background type, only part of internal version
try
    typechoice = get(h.backgroundtypeListbox,'Value');
    h_temp = [h.percentileEditbox h.percentileTextbox];
    if typechoice==3
        set(h_temp,'Enable','on')
    else
        set(h_temp,'Enable','off')
    end
end

% Check use dark state
usebleach = get(h.intensityAfterBleachingCheckbox,'Value');
useblink = get(h.intensityDuringBlinkingCheckbox,'Value');
if usebleach && useblink
    set([h.blinkbleachchoiceListbox  h.blinkbleachchoiceTextbox...
        h.minDarkFramesTextbox  h.minDarkFramesEditbox],'Enable','on')
elseif usebleach || useblink
    set([h.minDarkFramesTextbox  h.minDarkFramesEditbox],'Enable','on')
    set([h.blinkbleachchoiceListbox  h.blinkbleachchoiceTextbox],'Enable','off')
else
    set([h.blinkbleachchoiceListbox  h.blinkbleachchoiceTextbox...
        h.minDarkFramesTextbox  h.minDarkFramesEditbox],'Enable','off')
end

% Check frame averaging
avgchoice = get(h.frameAveragingListbox,'Value');
h_temp = [h.avgneighboursTextbox  h.avgneighboursEditbox];
if ((typechoice==1) || (typechoice==2)) && (avgchoice==2)
    set(h_temp,'Enable','on')
elseif (avgchoice==1) || (avgchoice==3)
    set(h_temp,'Enable','off')
end

% Check default backspace and backwidth values
backspace = str2num(get(h.backspaceEditbox,'String'));
backwidth = str2num(get(h.backwidthEditbox,'String'));
if backspace<0
    set(h.backspaceEditbox,'String', 0);
end
if backwidth<1
    set(h.backwidthEditbox,'String', 1);
end
end

function avgneighboursEditbox_Callback(Object,event,h)
value = round(abs(str2num(get(Object,'String'))));
if ~isodd(value)
    value = value+1;
end
set(Object,'String',value)
end

function prctileEditbox_Callback(Object,event,h)
value = round(abs(str2num(get(Object,'String'))));
if value>100
    value = 100;
end
set(Object,'String',value)
end
