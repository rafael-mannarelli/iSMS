function varargout = export_fig_dlg(varargin)
% Dialog for specifying export settings associated with export_fig

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

% Last Modified by GUIDE v2.5 15-Mar-2013 13:10:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @export_fig_dlg_OpeningFcn, ...
                   'gui_OutputFcn',  @export_fig_dlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function export_fig_dlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to export_fig_dlg (see VARARGIN)

% Change name
set(handles.figure1,'name','Export figure','numbertitle','off')

updatelogo(handles.figure1) % Update logo

% Set popup menu strings
format = {...
    'png';...
    'tif';...
    'jpg';...
    'bmp';...
    'pdf';...
    'eps'};
renderer = {...
    'Default';...
    'opengl';...
    'painters';...
    'zbuffer'};
colorspace = {...
    'RGB';...
    'CMYK';...
    'gray'};

% Populate
% Set resolution range
min_ppi = get(0, 'ScreenPixelsPerInch'); % Minimum ppi is the screen resolution
max_ppi = round(8.3333333*min_ppi); % Maximum ppi

set(handles.FormatPopupmenu, 'String',format)
set(handles.RendererPopupmenu, 'String',renderer)
set(handles.ColorSpacePopupmenu, 'String',colorspace)
set(handles.ResolutionText, 'String', sprintf('Resolution (%i-%i ppi):',min_ppi,max_ppi)) % Change textbox string
set(handles.ResolutionText, 'UserData',[min_ppi max_ppi]) % Set the maximum allowed resolution
set(handles.ResolutionEditbox, 'String',min_ppi) % Set the minimum allowed resolution

% Set defaults
mainhandles = guidata(getappdata(0,'mainhandle'));
try    
    set(handles.FormatPopupmenu, 'Value',mainhandles.settings.export_fig.format)
    set(handles.ResolutionEditbox,'String',mainhandles.settings.export_fig.resolution) % Set the minimum allowed resolution
    set(handles.RendererPopupmenu, 'Value',mainhandles.settings.export_fig.renderer)
    set(handles.ColorSpacePopupmenu, 'Value',mainhandles.settings.export_fig.colorspace)
    set(handles.CroppedCheckbox, 'Value',mainhandles.settings.export_fig.cropped)
    set(handles.TransparentCheckbox, 'Value',mainhandles.settings.export_fig.transparent)
    set(handles.AntiAliasingSlider, 'Value',mainhandles.settings.export_fig.antialias)
    set(handles.CompressionSlider, 'Value',mainhandles.settings.export_fig.compression)
end

% Update textboxes
updateWindow(handles)

% Choose default command line output for export_fig_dlg
handles.output = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes export_fig_dlg wait for user response (see UIRESUME)
uiwait(handles.figure1);

function varargout = export_fig_dlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = [];
try 
    varargout{1} = handles.output;

    % The figure can be deleted now
    delete(handles.figure1);
end

%------------------------------------------------------------%
%------------------------------------------------------------%
%------------------------------------------------------------%

function FormatPopupmenu_Callback(hObject, ~, handles)
format = get(handles.FormatPopupmenu,'String');
format = format{get(handles.FormatPopupmenu,'Value')};

% If vector format, hide some handles
h = [handles.ResolutionEditbox handles.AntiAliasText handles.AntiAliasingSlider handles.AntiAliasTextbox...
    handles.CompressionText handles.CompressionSlider handles.CompressionFactorTextbox];
if (strcmp(format,'pdf')) || (strcmp(format,'eps'))
    set(h,'Visible','off')
    set(handles.ResolutionText,'String','Vector format.')
else
    ppi_range = get(handles.ResolutionText,'UserData'); % Set the maximum allowed resolution
    set(handles.ResolutionText, 'String', sprintf('Resolution (%i-%i ppi):', ppi_range(1), ppi_range(2))) % Change textbox string
    set(h,'Visible','on')
end

% Check color space
colorspace = get(handles.ColorSpacePopupmenu,'String');
colorspace = colorspace(get(handles.ColorSpacePopupmenu,'Value'));
if strcmp(colorspace,'CMYK') % CMYK is only supported in pdf, eps and tiff output.
    if (~strcmp(format,'pdf')) && (~strcmp(format,'eps')) && (~strcmp(format,'tif'))
        set(handles.ColorSpacePopupmenu,'Value',1)
    end
end

% Check background transparency option
if get(handles.TransparentCheckbox,'Value')==1
    if (~strcmp(format,'pdf')) && (~strcmp(format,'eps')) && (~strcmp(format,'png'))
        set(handles.TransparentCheckbox,'Value',0)
    end
end
function FormatPopupmenu_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ResolutionEditbox_Callback(hObject, ~, handles)
% Check that specified value is not outside limits
ppi_range = get(handles.ResolutionText,'UserData');
if str2num(get(handles.ResolutionEditbox,'String')) < ppi_range(1)
    set(handles.ResolutionEditbox,'String',ppi_range(1))
elseif str2num(get(handles.ResolutionEditbox,'String')) > ppi_range(2)
    set(handles.ResolutionEditbox,'String',ppi_range(2))
end
function ResolutionEditbox_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CroppedCheckbox_Callback(hObject, ~, handles)

function TransparentCheckbox_Callback(hObject, ~, handles)
if get(handles.TransparentCheckbox,'Value')==1
    format = get(handles.FormatPopupmenu,'String');
    format = format{get(handles.FormatPopupmenu,'Value')};
    if (~strcmp(format,'pdf')) && (~strcmp(format,'eps')) && (~strcmp(format,'png'))
        mymsgbox('Transparent background can only be chosen for pdf, eps and png outputs','Background transparency')
        set(handles.TransparentCheckbox,'Value',0)
    end
end

function AntiAliasingSlider_Callback(hObject, ~, handles)
updateWindow(handles)
function AntiAliasingSlider_CreateFcn(hObject, ~, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function RendererPopupmenu_Callback(hObject, ~, handles)
renderer = get(handles.RendererPopupmenu,'String');
renderer = renderer{get(handles.RendererPopupmenu,'Value')};
if strcmp(renderer,'painters')
    mymsgbox(sprintf('%s%s%s',...
        'The painters renderer requires that ghostscript is installed on your system. You can download this from: http://www.ghostscript.com. ',...
        'When exporting to eps it additionally requires pdftops, from the Xpdf suite of functions. You can download this from: ',...
        'http://www.foolabs.com/xpdf'),'Painters renderer')
end
function RendererPopupmenu_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ColorSpacePopupmenu_Callback(hObject, ~, handles)
colorspace = get(handles.ColorSpacePopupmenu,'String');
colorspace = colorspace(get(handles.ColorSpacePopupmenu,'Value'));
if strcmp(colorspace,'CMYK') % CMYK is only supported in pdf, eps and tiff output.
    format = get(handles.FormatPopupmenu,'String');
    format = format{get(handles.FormatPopupmenu,'Value')};
    if (~strcmp(format,'pdf')) && (~strcmp(format,'eps')) && (~strcmp(format,'tif'))
        mymsgbox('CMYK can only be chosen for pdf, eps and tiff outputs','CMYK color space')
        set(handles.ColorSpacePopupmenu,'Value',1)
    end
end
function ColorSpacePopupmenu_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CompressionSlider_Callback(hObject, ~, handles)
updateWindow(handles)
function CompressionSlider_CreateFcn(hObject, ~, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function updateWindow(handles)
% Anti aliasing
antialias = round(get(handles.AntiAliasingSlider,'Value'));
if antialias==1
    set(handles.AntiAliasTextbox,'String','none')
elseif antialias==2
    set(handles.AntiAliasTextbox,'String','little')
elseif antialias==3
    set(handles.AntiAliasTextbox,'String','medium')
elseif antialias==4
    set(handles.AntiAliasTextbox,'String','high')
end

% Compression
compression = get(handles.CompressionSlider,'Value');
set(handles.CompressionFactorTextbox,'String',sprintf('%i%%',compression))

function CancelPushbutton_Callback(hObject, ~, handles)
handles.output = []; % If cancelling, return empty array
guidata(handles.figure1,handles) % Update handles.output
uiresume(handles.figure1) % Close GUI

function SavePushbutton_Callback(hObject, ~, handles)
% Get choices
format = get(handles.FormatPopupmenu,'String');
format = format{get(handles.FormatPopupmenu,'Value')};
resolution = str2num(get(handles.ResolutionEditbox,'String'));
cropped = get(handles.CroppedCheckbox,'Value');
transparent = get(handles.TransparentCheckbox,'Value');
antiAlias = round(get(handles.AntiAliasingSlider,'Value'));
renderer = get(handles.RendererPopupmenu,'String');
renderer = renderer{get(handles.RendererPopupmenu,'Value')};
colorspace = get(handles.ColorSpacePopupmenu,'String');
colorspace = colorspace{get(handles.ColorSpacePopupmenu,'Value')};
compression = 100-get(handles.CompressionSlider,'Value');

% Open a save as dialog
mainhandle = getappdata(0,'mainhandle');
mainhandles = guidata(mainhandle);

[filename, path, chose] = uiputfile3(mainhandles,'results',sprintf('*.%s',format),'Save figure as','figure');
if chose == 0
    return
end

% Make command line for export_fig
command = sprintf('export_fig ''%s''',fullfile(path,filename)); % Filename
if (~strcmp(format,'pdf')) && (~strcmp(format,'eps'))
    command = sprintf('%s -r%i',command,resolution); % Resolution
    command = sprintf('%s -a%i',command,antiAlias); % Anti-aliasing
end
if ~cropped
    command = sprintf('%s -nocrop',command); % Don't crop borders
end
if ((strcmp(format,'png')) || (strcmp(format,'pdf')) || (strcmp(format,'eps'))) && (transparent)
    command = sprintf('%s -transparent',command); % Make background transparent
end
if ~strcmp(renderer,'Default')
    command = sprintf('%s -%s',command,renderer);
end
if (strcmp(format,'pdf')) || (strcmp(format,'eps')) || (strcmp(format,'jpg'))
    command = sprintf('%s -q%i',command, compression);
end
command = sprintf('%s -%s',command, colorspace);

% Default renderers
if strcmp(renderer,'Default')
    if (strcmp(format,'pdf')) || (strcmp(format,'eps'))
        renderer = 'painters';
    else
        renderer = 'opengl';
    end
end

% Output structure
output = struct(...
    'format', format,... % File format
    'cropped', cropped,... % Cropped or not cropped
    'transparent', transparent,... % Transparent
    'resolution', resolution,... % Resolution
    'antiAlias', antiAlias,... % Anti alias
    'renderer', renderer,... % Renderer
    'colorspace', colorspace,... % RGB or CMYK
    'compression', compression,... % Compression
    'filename', filename,... % Filename
    'path', path,... % Directory
    'command', command); % Command for saving figure


% Update handles.output
handles.output = output;
guidata(handles.figure1,handles)    

% Update default settings
mainhandle = getappdata(0,'mainhandle');
try
    mainhandles = guidata(mainhandle);
    mainhandles.settings.export_fig.format = get(handles.FormatPopupmenu, 'Value');
    mainhandles.settings.export_fig.resolution = get(handles.ResolutionEditbox,'String'); % Set the minimum allowed resolution
    mainhandles.settings.export_fig.renderer = get(handles.RendererPopupmenu, 'Value');
    mainhandles.settings.export_fig.colorspace = get(handles.ColorSpacePopupmenu, 'Value');
    mainhandles.settings.export_fig.cropped = get(handles.CroppedCheckbox, 'Value');
    mainhandles.settings.export_fig.transparent = get(handles.TransparentCheckbox, 'Value');
    mainhandles.settings.export_fig.antialias = get(handles.AntiAliasingSlider, 'Value');
    mainhandles.settings.export_fig.compression = get(handles.CompressionSlider, 'Value');
    updatemainhandles(mainhandles)
end

% Close GUI
uiresume(handles.figure1);
