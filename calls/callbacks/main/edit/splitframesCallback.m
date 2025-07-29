function mainhandles = splitframesCallback(mainhandles)
% Callback for splitting movie into individual frames
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ...
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

if isempty(mainhandles.data)
    set(mainhandles.mboard,'String','No data loaded.')
    return
end

% Default
file = get(mainhandles.FilesListbox,'Value');

% Check length of movie
imageData = mainhandles.data(file).imageData;
if size(imageData,3)<2
    set(mainhandles.mboard,'String',sprintf('The selected file only contains %i frames.',size(imageData,3)))
    return
end

% Listbox string
liststr = cell(size(imageData,3),1);
for i = 1:size(imageData,3)
    liststr{i} = sprintf('%i - %s',i,mainhandles.data(file).excorder(i));
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
    'String', '2',...
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
    frames = get(h.list,'Value');
    
    % Check that an even number of frames have been selected
    if mainhandles.settings.excitation.alex && isodd(length(frames))
        ok = myquestdlg('In ALEX, you must select an even number of frames.', 'Odd number','OK','OK');
        try delete(h.fh); end
        mainhandles = splitframesCallback(mainhandles);
        return
    end
    
    % Store as new data
    data.imageData = mainhandles.data(file).imageData(:,:,frames);
    name = sprintf('Cut: %s',mainhandles.data(file).name);
    mainhandles = storeMovie(mainhandles,data,name,mainhandles.data(file).filepath,0, ...
        mainhandles.data(file).excorder(frames));
    
    % Store transformation
    mainhandles = storeGeoTransformAfterCut(mainhandles,file,frames);
    
    % Update
    updatemainhandles(mainhandles)
    updatefileslist(mainhandles.figure1)
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
    val = round(abs( str2num(get(h.edit,'String')) ));
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
