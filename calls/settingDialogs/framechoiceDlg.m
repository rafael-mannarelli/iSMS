function frames = framechoiceDlg(mainhandles,filechoice)
% Dialog for selecting frames
%
%    Input:
%     mainhandles   - handles structure of the main window
%     filechoice    - movie file
%
%    Output:
%     frames        - selected frames
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

frames = [];

% Default
if isempty(filechoice)
    filechoice = get(mainhandles.FilesListbox,'Value');
end

% Check size of movie
imageData = mainhandles.data(filechoice).imageData;
if size(imageData,3)<2
    set(mainhandles.mboard,'String',sprintf('The selected file only contains %i frames.',size(imageData,3)))
    return
end

% Listbox string
liststr = cell(size(imageData,3),1);
for i = 1:size(imageData,3)
    liststr{i} = sprintf('%i - %s',i,mainhandles.data(filechoice).excorder(i));
end

% Usual window dimensions
GUIdimensions

%%  Open dialog

fh = dialog(...
    'name', 'Extract frames',...
    'Visible',  'off',...
    'UserData', 'Cancel');
updatelogo(fh)

% Initialize uicontrols
h.text = uicontrol('Parent', fh,...
    'style', 'text',...
    'String', 'Select frames to keep',...
    'HorizontalAlignment',   'left');
h.list = uicontrol('Parent',fh,...
    'Style', 'listbox',...
    'String', liststr,...
    'max', 2,...
    'BackgroundColor',  'white'...
    );
h.selectText = uicontrol('Parent', fh,...
    'style', 'text',...
    'String', 'Select every (starting from 1st of current): ',...
    'HorizontalAlignment',   'right');
h.edit = uicontrol('Parent', fh,...
    'style', 'edit',...
    'String', '3',...
    'BackgroundColor', [1 1 1],...
    'HorizontalAlignment',   'center');
h.updatebutton = uicontrol('Parent',fh,...
    'Style', 'Pushbutton',...
    'String', ' Update selection ');

h.okbutton = uicontrol('Parent',fh,...
    'Style', 'Pushbutton',...
    'String', ' OK ');
h.cancelbutton = uicontrol('Parent',fh,...
    'Style', 'Pushbutton',...
    'String', ' Cancel ');

h.fh = fh;
h.main = mainhandles.figure1;
guidata(h.fh,h)

%% Set uicontrol positions

textwidth = 160;
listheight = 300;
listwidth = 250;
checkwidth = listwidth;
GUIwidth = leftspace+rightspace+horspace+textwidth+listwidth;
GUIheight = bottomspace+topspace+10*verspace+2*buttonheight+listheight+5*checkheight;
textwidth2 = GUIwidth-rightspace-leftspace-3*horspace-editwidth-buttonwidth;

% Set positions
setpixelposition(h.fh,[100 100 GUIwidth GUIheight])
setpixelposition(h.text,[leftspace GUIheight-topspace-textheight textwidth textheight])
vpos = GUIheight-topspace-listheight;
setpixelposition(h.list,[leftspace+textwidth+horspace GUIheight-topspace-listheight listwidth listheight])

vpos = vpos-verspace-buttonheight;
setpixelposition(h.selectText,[leftspace vpos+2 textwidth2 textheight])
setpixelposition(h.edit,[leftspace+textwidth2+horspace vpos+2 editwidth editheight])
setpixelposition(h.updatebutton,[GUIwidth-rightspace-buttonwidth vpos buttonwidth buttonheight])

setpixelposition(h.cancelbutton,[GUIwidth-rightspace-buttonwidth bottomspace buttonwidth buttonheight])
setpixelposition(h.okbutton,[GUIwidth-rightspace-2*buttonwidth-horspace bottomspace buttonwidth buttonheight])
movegui(h.fh,'center')

%% Callbacks

set([h.okbutton h.cancelbutton],'Callback',@buttoncallback)
set([h.edit], 'Callback',{@editCallback,h})
set([h.updatebutton] ,'Callback',{@updatebuttonCallback, h})

%% Wait for button press

set(h.fh,'visible','on')
uiwait(h.fh)

%% This code hereafter is only run once uiresume is called

if ishghandle(h.fh) && strcmpi(get(h.fh,'UserData'),'OK')
    
    % Output data structure
    liststr = getliststr(h);
    frames = get(h.list,'Value');
    
    % Store as new data
    imageData = mainhandles.data(filechoice).imageData(:,:,frames);
    mainhandles = storeMovie(mainhandles,imageData,'cut',mainhandles.data(filechoice).filepath);
    mainhandles.data(end).excorder = mainhandles.data(filechoice).excorder(frames);
    
    % Update
    updatemainhandles(mainhandles)
    set(mainhandles.FilesListbox,'Value',length(mainhandles.data))
    mainhandles = filesListboxCallback([],[],mainhandles.figure1);
    
    try delete(h.fh); end
else
    try delete(h.fh); end
    return
end


end

function editCallback(hObject,event,h)
% Check entered value
try 
    val = round(abs( str2num(get(h.edit,'String')) ))
    set(h.edit, 'string',num2str(val))
catch err
    mymsgbox('Incorrect value, must be positive integer.')
    set(h.edit,'string','3')
    return
end
end

function updatebuttonCallback(hObject,event,h)
% Selection
val = str2num(get(h.edit,'String'));
s = get(h.list,'Value');
liststr = get(h.list,'String');
if isempty(s)
    s = 1;
else
    s = s(1);
end

% New selection
newSelection = [s:val:size(liststr,1)];

% Update selection
set(h.list,'Value',newSelection)
end

function buttoncallback(hObject,event,h)
if ~strcmp(get(hObject,'String'),' Cancel ')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end
end


% 
% function framechoices = framechoiceDlg(handles,filechoice)
% % Prompt a dialog for selecting a subset of frames
% %
% %    Input:
% %     handles     - handles structure of the main window
% %     filechoice  - file to select frames from
% 
% %% Initialize
% 
% framechoices = [];
% 
% % Default
% if isempty(filechoice)
%     filechoice = get(handles.FilesListbox,'Value');
% end
% 
% % Check size of movie
% imageData = handles.data(filechoice).imageData;
% if size(imageData,3)<2
%     set(handles.mboard,'String',sprintf('The selected file only contains %i frames.',size(imageData,3)))
%     return
% end
% 
% % Listbox string
% liststr = cell(size(imageData,3),1);
% for i = 1:size(imageData,3)
%     liststr{i} = sprintf('%i - %s',i,handles.data(filechoice).excorder(i));
% end
% 
% % Usual window dimensions
% GUIdimensions
% 
% % Open border selection dialog
% fh = dialog(...
%     'name', 'Extract frames',...
%     'Visible',  'off',...
%     'UserData', 'Cancel');
% updatelogo(fh)
% 
% % Initialize uicontrols
% h.htext = uicontrol('Parent', fh,...
%     'style', 'text',...
%     'String', 'Select frames: ',...
%     'HorizontalAlignment',   'left');
% 
% h.hlist = uicontrol('Parent',fh,...
%     'Style', 'listbox',...
%     'String', liststr,...
%     'BackgroundColor',  'white'...
%     );
% 
% h.text2 = uicontrol('Parent', fh,...
%     'style', 'text',...
%     'String', 'Select every: ',...
%     'HorizontalAlignment',   'left');
% h.edit = uicontrol('Parent',fh,...
%     'Style','edit',...
%     'String', '2',...
%     'BackgroundColor', 'white');
% h.button = uicontrol('Parent',fh,...
%     'Style', 'Pushbutton',...
%     'String', ' Update ');
% 
% h.okbutton = uicontrol('Parent',fh,...
%     'Style', 'Pushbutton',...
%     'String', ' OK ');
% 
% h.cancelbutton = uicontrol('Parent',fh,...
%     'Style', 'Pushbutton',...
%     'String', ' Cancel ');
% 
% h.fh = fh;
% h.main = handles.figure1;
% 
% % Set uicontrol positions
% textwidth = 100;
% listheight = 300;
% listwidth = 250;
% GUIwidth = leftspace+rightspace+horspace+textwidth+listwidth;
% GUIheight = bottomspace+topspace+5*verspace+2*buttonheight+listheight;
% 
% % Set positions
% setpixelposition(h.fh,[100 100 GUIwidth GUIheight])
% setpixelposition(h.htext,[leftspace GUIheight-topspace-textheight textwidth textheight])
% setpixelposition(h.hlist,[leftspace+textwidth+horspace bottomspace+2*buttonheight+2*verspace listwidth listheight])
% setpixelposition(h.cancelbutton,[GUIwidth-rightspace-buttonwidth bottomspace buttonwidth buttonheight])
% setpixelposition(h.okbutton,[GUIwidth-rightspace-2*buttonwidth-horspace bottomspace buttonwidth buttonheight])
% movegui(h.fh,'center')
% 
% % Callbacks
% set([h.okbutton h.cancelbutton],'Callback',@buttoncallback)
% 
% % Wait for button press
% set(h.fh,'visible','on')
% handles = listcallback(h.hlist,[],h);
% uiwait(h.fh)
% 
% %----- This code hereafter is only run once uiresume is called -----%
% delete(handles.previewWindowHandle)
% handles.previewWindowHandle = [];
% updatemainhandles(handles)
% 
% if ishghandle(h.fh) && strcmpi(get(h.fh,'UserData'),'OK')
%     % Get name of border
%     liststr = get(h.hlist,'String');
%     bordername = liststr{get(h.hlist,'Value')};
%     filepath = fullfile(handles.workdir,'borders',bordername);
%     try delete(h.fh); end
% else
%     try delete(h.fh); end
%     return
% end
% 
% 
% for i = 1:length(filechoices)
%     imageData = handles.data(filechoices(i)).imageData;
%     newImage = addImageBorder(imageData, filepath);
%     
%     % Store
%     handles = storeData(handles,...
%         newImage,...
%         [],...
%         sprintf('Framed: %s',handles.data(filechoices(i)).name),...
%         pwd);
% end
% 
% % Update
% updateFilesListbox(handles.figure1)
% set(handles.FilesListbox,'Value',length(handles.data)+1-length(filechoices))
% handles = updateImageAxes(handles.figure1);
% end
% 
% function buttoncallback(hObject,event,h)
% if ~strcmp(get(hObject,'String'),' Cancel ')
%     set(gcbf,'UserData','OK');
%     uiresume(gcbf);
% else
%     delete(gcbf)
% end
% end
