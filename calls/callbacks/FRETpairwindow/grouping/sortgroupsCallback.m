function mainhandles = sortgroupsCallback(fpHandles)
% Callback for setting group order (sorting)
%
%    Input:
%     fpHandles    - handles structure of the FRETpairwindow
%     
%    Output:
%     mainhandles  - handles structure of the main window
%     fpHandles    - ..
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
    mainhandles = guidata(getappdata(0,'mainhandle'));
    fpHandles = guidata(mainhandles.FRETpairwindowHandle);
end

% Get mainhandles
mainhandles = getmainhandles(fpHandles);

%% Create GUI window

h.figure1 = dialog(...
    'Name',     'Sort groups',...
    'Visible',  'off',...
    'UserData', 'Cancel');
updatelogo(h.figure1) % Update logo

%--------- Create GUI components ---------%

% Listbox
namestr = getgroupString(mainhandles);
h.list = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'listbox',...
    'String',   namestr,...
    'Value',    1,...
    'Max',      2,...
    'BackgroundColor',  'white'...
    );

% Pushbuttons
h.UPbutton = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'pushbutton',...
    'FontName', 'Symbol',...
    'String',   char(173),...
    'FontSize', 12);
    
h.DOWNbutton = uicontrol(...
    'Parent',   h.figure1,...
    'Style',    'pushbutton',...
    'FontName', 'Symbol',...
    'String',   char(175),...
    'FontSize', 12);

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

%% Set position

GUIdimensions

figW = 300;
figH = 300;
butW = 35;
butH = butW;
listW = figW-horspace-leftspace-rightspace-butW;
listH = figH-topspace-bottomspace-vergap-butH;

setpixelposition(h.OKpushbutton, [figW-rightspace-buttonwidth bottomspace buttonwidth buttonheight])
setpixelposition(h.CancelPushbutton, [figW-2*rightspace-2*buttonwidth bottomspace buttonwidth buttonheight])

vpos = figH-2*topspace-butH;
setpixelposition(h.UPbutton, [leftspace vpos butW butH])
vpos = vpos-vergap-butH;
setpixelposition(h.DOWNbutton, [leftspace vpos butW butH])

vpos = bottomspace+buttonheight+vergap;
setpixelposition(h.list, [leftspace+horspace+butW vpos listW listH])

setpixelposition(h.figure1,[10 10 figW figH])
movegui(h.figure1,'center')

%% Groups structure

groups = mainhandles.groups;
for i = 1:length(groups)
    groups(i).liststr = namestr{i};
    groups(i).idx1 = i;
end
set(h.list,'userdata',groups)

%% Set callbacks

set(h.UPbutton,'Callback',{@upcallback, h}); % Assign callback
set(h.DOWNbutton,'Callback',{@downcallback, h}); % Assign callback
set(h.OKpushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback
set(h.CancelPushbutton,'Callback',{@pushbutton_Callback, h}); % Assign callback

%% Update dialog ---%
guidata(h.figure1,h)
set(h.figure1,'Visible','on')

% For closing the figure
if ishghandle(h.figure1)
  % Go into uiwait if the figure handle is still valid.
  % This is mostly the case during regular use.
  uiwait(h.figure1);
end

%% This code hereafter is only run once uiresume is called -----%
% Check handle validity again since we may be out of uiwait because the
% figure was deleted.

if ishghandle(h.figure1)
    
    if strcmp(get(h.figure1,'UserData'),'OK')
        % Get new group numbering
        groups = get(h.list,'userdata');
        idx = [groups(:).idx1];
        mainhandles.groups = mainhandles.groups(idx);
        
        % Correct all FRETpairs group numbering
        allPairs = getPairs(mainhandles.figure1,'all');
        for i = 1:size(allPairs,1)
            file = allPairs(i,1);
            pair = allPairs(i,2);
            
            % New group number
            [~,ng] = ismember(mainhandles.data(file).FRETpairs(pair).group,idx);
            
            % Update
            mainhandles.data(file).FRETpairs(pair).group = ng;
        end
        
        % Update GUI
        updatemainhandles(mainhandles)
        mainhandles = updateGUIafterNewGroup(mainhandles.figure1);
    end
    delete(h.figure1);
    
else
  answer = [];
end
end

%-----------------------------------------------------------%
%-----------------------------------------------------------%
%-----------------------------------------------------------%

function pushbutton_Callback(hObject,eventdata,h) %% Callback for pressing either 'Cancel' or 'OK'
if ~strcmp(get(hObject,'String'),'Cancel')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end
end

function upcallback(Object,eventdata,h) %% Updates the visibility of the individual GUI components depending on the selection choices
% Groups
groups = get(h.list,'userdata');

% Selection
selectedGroups = get(h.list,'Value');

% Interchange selection with the one above:
for i = 1:length(selectedGroups)
    choice = selectedGroups(i);
    if choice==1
        return
    end
    temp = groups(choice);
    groups(choice) = groups(choice-1);
    groups(choice-1) = temp;
end

% Update list
set(h.list,'userdata',groups)
set(h.list,'String',{groups(:).liststr}')
set(h.list,'Value',selectedGroups-1)

end

function downcallback(Object,eventdata,h)
% Groups
groups = get(h.list,'userdata');

% Selection
selectedGroups = get(h.list,'Value');

% Interchange selection with the one below:
for i = length(selectedGroups):-1:1
    choice = selectedGroups(i);
    if choice==length(groups)
        return
    end
    
    temp = groups(choice);
    groups(choice) = groups(choice+1);
    groups(choice+1) = temp;
end

% Update list
set(h.list,'userdata',groups)
set(h.list,'String',{groups(:).liststr}')
set(h.list,'Value',selectedGroups+1)

end

