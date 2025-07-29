function handles = clearROIpeaks(handles,choice)
% Clears peaks in ROI image in main window
%
%    Input:
%     mainhandles     - handles structure of the main window
%     choice          - 'donor','acceptor','fret','all'
%

if nargin<2
    choice = 'all';
end

% Color of peaks dependent on color settings
[Dcolor,Acolor,Ecolor] = getColors(handles); 

% Hide peaks
if strcmpi(choice,'donor') || strcmpi(choice,'all')
    
    h = findobj(handles.ROIimage,'Marker','o','MarkerEdgeColor',Dcolor);
    delete(h)
    handles.DpeaksHandle = [];
    
elseif strcmpi(choice,'acceptor') || strcmpi(choice,'all')
    
    h = findobj(handles.ROIimage,'Marker','o','MarkerEdgeColor',Acolor);
    delete(h)
    handles.ApeaksHandle = [];
    
elseif strcmpi(choice,'fret') || strcmpi(choice,'all')
    
    h = findobj(handles.ROIimage,'Marker','o','MarkerEdgeColor',Ecolor);
    delete(h)
    h = findobj(handles.ROIimage,'type','text');
    delete(h)
    handles.EpeaksHandle = [];
    
end

% Update mainhandles
updatemainhandles(handles)
