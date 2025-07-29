function varargout = TDSplot_TimefilterDialog(varargin)
% TDSPLOT_TIMEFILTERDIALOG MATLAB code for TDSplot_TimefilterDialog.fig
%      TDSPLOT_TIMEFILTERDIALOG, by itself, creates a new TDSPLOT_TIMEFILTERDIALOG or raises the existing
%      singleton*.
%
%      H = TDSPLOT_TIMEFILTERDIALOG returns the handle to a new TDSPLOT_TIMEFILTERDIALOG or the handle to
%      the existing singleton*.
%
%      TDSPLOT_TIMEFILTERDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TDSPLOT_TIMEFILTERDIALOG.M with the given input arguments.
%
%      TDSPLOT_TIMEFILTERDIALOG('Property','Value',...) creates a new TDSPLOT_TIMEFILTERDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TDSplot_TimefilterDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TDSplot_TimefilterDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TDSplot_TimefilterDialog

% Last Modified by GUIDE v2.5 25-Sep-2014 16:46:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TDSplot_TimefilterDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @TDSplot_TimefilterDialog_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before TDSplot_TimefilterDialog is made visible.
function TDSplot_TimefilterDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TDSplot_TimefilterDialog (see VARARGIN)

% Choose default command line output for TDSplot_TimefilterDialog
handles.output = hObject;

% Get mainhandles
handles.main = getappdata(0,'mainhandle');                                  
mainhandles = guidata(handles.main);
handles.main=handles.main;

% Logo
updatelogo(handles.figure1);

% Extract data
vbset=mainhandles.settings.vbFRET;

% Error catching
if isempty(vbset) %If no vbFRET calculation is available
    lowerbound=[]; higherbound=[];
end

if any(strcmp('bounds',fieldnames(vbset)))==1 %See if bounds exists
    bounds=vbset.bounds;
    if numel(bounds)==2 %See if empty
        lowbound=vbset.bounds(1); highbound=vbset.bounds(2);
    else
        lowbound=[]; highbound=[];
    end
else
    mainhandles.settings.vbFRET.bounds=[]; %Create bounds, if it doesn't exist
    lowbound=[]; highbound=[];
    
    updatemainhandles(mainhandles);
end

% Update text
set(handles.Edit_Low,'String',num2str(lowbound))
set(handles.Edit_High,'String',num2str(highbound))

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = TDSplot_TimefilterDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function Edit_Low_Callback(hObject, eventdata, handles)


function Edit_Low_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Edit_High_Callback(hObject, eventdata, handles)


function Edit_High_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Push_Ok_Callback(hObject, eventdata, handles)
% Extract higher limit
highbound=str2double(get(handles.Edit_High,'String'));

% Extract lower limit
lowbound=str2double(get(handles.Edit_Low,'String'));

% Error catching
if isnan(lowbound)
   lowbound=[]; 
end
if lowbound < 0
    lowbound=[];
end

if isnan(highbound)
   highbound=[]; 
end
if highbound < 0
    highbound=[];
end

if highbound<lowbound
    highbound=[]; lowbound=[];
end

% Update mainhandles
mainhandles=guidata(handles.main);
mainhandles.settings.vbFRET.bounds=[lowbound, highbound];
updatemainhandles(mainhandles)

% Close window
close TDSplot_TimefilterDialog
