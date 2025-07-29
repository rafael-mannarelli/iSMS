function answer = fileSettings(mainhandle)
% fileSettings creates a modal dialog box that returns user input for
% multiple prompts in the cell array ANSWER. fileSettings uses UIWAIT
% to suspend execution until the user responds.
%
%    Input:
%     mainhandle   - handle to the main figure window (sms)
%
%    Output:
%     answer       - structure with users answers
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

answer = [];

% Check number of input arguments
if (isempty(mainhandle)) || (~ishghandle(mainhandle))
    return
end
mainhandles = guidata(mainhandle); % Get mainhandles structure

%% Create GUI window

h.figure1 = dialog(...
    'Name',     'File settings',...
    'Units',    'pixels',...
    'Position', [520  380  560  420],...
    'Visible',  'off',...
    'UserData', 'Cancel');
movegui(h.figure1,'center')
updatelogo(h.figure1) % Update logo

h.main = mainhandle;

%--------- Create GUI components ---------%
% Textbox
h.FilesTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Files: ',...
    'HorizontalAlignment',   'left',...
    'units',    'pixels',...
    'position', [20 388 52 15]...
    );
% Listbox
h.FilesListbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'listbox',...
    'String',   {mainhandles.data(:).name}',...
    'Units',    'pixels',...
    'Position', [17  257  167  128],...
    'BackgroundColor',  'white',...
    'Value',    1);

% Textbox
h.integrationTimeTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Frame integration time (ms): ',...
    'HorizontalAlignment',   'left',...
    'units',    'pixels',...
    'position', [209  359  234  16]...
    );
% Editbox
h.integrationTimeEditbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'edit',...
    'Units',    'pixels',...
    'Position', [450  356  51  22],...
    'BackgroundColor',  'white'...
    );

% Textbox
h.grRatioTextbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'text',...
    'String',   'Green/red laser intensity ratio:',...
    'HorizontalAlignment',   'left',...
    'Units',    'pixels',...
    'position', [209  335  228  16]);
% Editbox
h.grRatioEditbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'edit',...
    'Units',    'pixels',...
    'Position', [450 332 51 22],...
    'BackgroundColor',  'white'...
    );

%-- OK pushbutton --%
h.OKpushbutton = uicontrol(...
    'Parent',   h.figure1,...
    'String',   'OK',...
    'Style',    'pushbutton',...
    'Units',    'pixels',...
    'Position', [408  21  93  32]...
    );

%-- Cancel pushbutton --%
h.CancelPushbutton = uicontrol(...
    'Parent',   h.figure1,...
    'String',   'Cancel',...
    'Style',    'pushbutton',...
    'Units',    'pixels',...
    'Position', [307 21 93 32]...
    );

%% Set callbacks

set(h.FilesListbox,'Callback',{@FilesListbox_Callback, h}); % Assign callback
set(h.grRatioEditbox,'Callback',{@grRatioEditbox_Callback,h});
set(h.integrationTimeEditbox,'Callback',{@integrationTimeEditbox_Callback,h});
set(h.OKpushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback
set(h.CancelPushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback

%% Update dialog

guidata(h.figure1,h)
FilesListbox_Callback([],[],h)
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
      answer.integrationTime = str2num(get(h.integrationTimeEditbox,'String')); % Default width in between integration area and background circler
      answer.grRatio = str2num(get(h.grRatioEditbox,'String')); % Default width of background ring /pixels
  end
  delete(h.figure1);
else
  answer = [];
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

function FilesListbox_Callback(Object,eventdata,h)
mainhandles = getmainhandles(h);
filechoice = get(h.FilesListbox,'Value');

% Update GUI:
set(h.grRatioEditbox,'String',mainhandles.data(filechoice).grRatio)
set(h.integrationTimeEditbox,'String',mainhandles.data(filechoice).integrationTime)

function grRatioEditbox_Callback(Object,eventdata,h)
mainhandles = getmainhandles(h);
filechoice = get(h.FilesListbox,'Value');

% Update GUI:
value = abs(str2num(get(h.grRatioEditbox,'String')));
if value == 0
    value = 1;
end
set(h.grRatioEditbox,'String',value)

% update mainhandles structure
mainhandles.data(filechoice).grRatio = value;
updatemainhandles(mainhandles)

function integrationTimeEditbox_Callback(Object,eventdata,h)
mainhandles = getmainhandles(h);
filechoice = get(h.FilesListbox,'Value');

% Update GUI:
value = abs(str2num(get(h.integrationTimeEditbox,'String')));
if value == 0
    value = 1;
end
set(h.integrationTimeEditbox,'String',value)

% update mainhandles structure
mainhandles.data(filechoice).integrationTime = value;
updatemainhandles(mainhandles)
