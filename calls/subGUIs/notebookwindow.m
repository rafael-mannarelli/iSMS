function notebookHandle = notebookwindow(mainhandle)
% Opens a notebook
%
%    Input:
%     mainhandle      - handle to main window
%
%    Output:
%     notebookHandle  - handle to the notebook window
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

notebookHandle = []; % Handle to the notebook window

% Check number of input arguments
if (isempty(mainhandle)) || (~ishghandle(mainhandle))
    return
end

h.main = mainhandle;
mainhandles = guidata(h.main);

%--------- Create GUI window ---------%
if isempty(mainhandles.filename)
    title = 'iSMS Notebook';
else
    title = sprintf('iSMS Notebook - %s',mainhandles.filename);
end
h.figure1 = dialog(...
    'Name',     title,...
    'Visible',  'off',...
    'Resize', 'on',...
    'UserData', 'Cancel',...
    'WindowStyle', 'Normal');
%     'Units',    'normalized',...
%     'Position', [520  635  319  165],...
movegui(h.figure1,'northeast')

% Update figure logo
updatelogo(h.figure1)

% Output
notebookHandle = h.figure1;

%--------- Create GUI components ---------%
% Editbox
h.editbox = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'edit',...
    'String',   mainhandles.notes,...
    'Units',    'normalized',...
    'HorizontalAlignment', 'left',...
    'Position', [0.05 0.05 0.9 0.8],...
    'BackgroundColor',  'white',...
    'keypressfcn',@editbox_keypressFcn,...
    'Min',      0,...
    'Max',      2);
% Save and close button. Is only needed if: the user multiselects text,
% then presses delete and then directly presses the X-close window button.
% In this case the mainhandles structure is not updated with the new
% string.
h.button = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'Pushbutton',...
    'String',   'Save and close',...
    'Units',    'normalized',...
    'Position', [0.75 0.88 0.2 0.09]);

%--- Set callbacks ---%
set(h.editbox,'Callback',{@update, h}); % Assign callback
set(h.button,'Callback',{@closeRequestFcn, h})
set(h.figure1,'CloseRequestFcn',{@closeRequestFcn, h})

% h.STR stores the editbox string continously as the user types, which is
% used to update the mainhandles structure as the user types, and not just
% as the user presses Ctrl+Enter or presses outside the box.
h.STR = get(h.editbox,'String');
guidata(h.figure1,h)

set(h.figure1,'Visible','on')

function update(Object,eventdata,h)
% Check if mainhandle is still available
if isempty(h.main) || (~ishandle(h.main))
    choice = myquestdlg('The handle to the main window is lost. Do you wish to close this window?','Handle lost','Yes','No','Yes');
    if strcmpi(choice,'Yes')
        delete(h.figure1)
    end
    return
end

% Update string handles structure
h.STR = get(h.editbox,'String');
guidata(gcbf,h)

% Update mainhandles structure
mainhandles = guidata(h.main);
mainhandles.notes = get(h.editbox,'String');
guidata(h.main,mainhandles)

function [] = editbox_keypressFcn(hObject,event) % Keypressfcn for editbox
% (Slow alternative to simulate Ctrl+Enter keypress:)
% import java.awt.Robot;
% import java.awt.event.KeyEvent;
% robot = Robot;
% robot.keyPress(KeyEvent.VK_CONTROL);
% robot.keyPress(KeyEvent.VK_ENTER);
% % pause(1e-2)
% robot.keyRelease(KeyEvent.VK_ENTER);
% robot.keyRelease(KeyEvent.VK_CONTROL);

h = guidata(gcbf);  % Get the structure.
if strcmp(event.Key,'backspace')
    h.STR = sprintf('%s',h.STR(1:end-1));
elseif isempty(event.Character)
    return
else
    h.STR = sprintf('%s%s',h.STR, event.Character);
end
guidata(gcbf,h)

% Update mainhandles structure
mainhandles = guidata(h.main);
mainhandles.notes = h.STR;
guidata(h.main,mainhandles)

function closeRequestFcn(Object,event,h)
% (Slow alternative to simulate Ctrl+Enter keypress:) doesn't really work
% try
%     import java.awt.Robot;
%     import java.awt.event.KeyEvent;
%     robot = Robot;
%     robot.keyPress(KeyEvent.VK_CONTROL);
%     robot.keyPress(KeyEvent.VK_ENTER);
%     pause(1e-2)
%     robot.keyRelease(KeyEvent.VK_ENTER);
%     robot.keyRelease(KeyEvent.VK_CONTROL);
%
%     h = guidata(h.figure1);
%     update([],[],h)
% end

try delete(h.figure1), end
