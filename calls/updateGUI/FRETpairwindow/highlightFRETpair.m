function highlightFRETpair(mainhandle, FRETpairwindowHandle)
% Highlights the selected FRET pair in the ROI image
% 
%    Input:
%     mainhandles           - handle to the main figure window (sms)
%     FRETpairWindowHandles - handle to the FRETpairGUI window
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

% If one of the windows is closed
if (isempty(mainhandle)) || (isempty(FRETpairwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(FRETpairwindowHandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

% Color setting
[Dcolor,Acolor,Ecolor] = getColors(mainhandles);

% Remove previous markers
% VERSION DEPENDENT SYNTAX
if mainhandles.matver>8.3
    h = findobj(mainhandles.ROIimage,'MarkerFaceColor','flat');
    delete(h)
else
    h = findobj(mainhandles.ROIimage,'MarkerFaceColor',Dcolor);
    delete(h)
    h = findobj(mainhandles.ROIimage,'MarkerFaceColor',Acolor);
    delete(h)
    h = findobj(mainhandles.ROIimage,'MarkerFaceColor',Ecolor);
    delete(h)
end

% Get selected FRET-pairs
selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle); % Returns pair selection as [file pair;...]
if (isempty(mainhandles.data))  || (isempty(selectedPairs))
    set(FRETpairwindowHandles.figure1,'name','FRET Pairs Window')
    return
end

% Return if E-peaks is not toggled
if strcmpi(get(mainhandles.Toolbar_EPeaksToggle,'State'),'off')
    set(FRETpairwindowHandles.figure1,'name','FRET Pairs Window')
    return
end

% Update FRETpair window name
ufiles = unique(selectedPairs(:,1));
name = sprintf('FRET Pairs Window -');
for i = 1:length(ufiles)
    if i > 1
        name = sprintf('%s,',name);
    end
    name = sprintf('%s %s',name,mainhandles.data(ufiles(i)).name);
end
set(FRETpairwindowHandles.figure1,'name',name)

% Selected FRET-pairs in selected movie file
filechoice = get(mainhandles.FilesListbox,'Value');
selectedPairs(selectedPairs(:,1)~=filechoice, :) = []; % Remove all pair selections in files not selected the sms window
if isempty(selectedPairs) % If no pair has been selected
    return
end
filechoice = selectedPairs(1,1);
pairchoices = selectedPairs(:,2);

%% Highlight selected pair on ROI image

if length(pairchoices)<=2
    hold(mainhandles.ROIimage,'on')
    for i = 1:length(pairchoices) % Loop over all selected FRET-pairs
        pairchoice = pairchoices(i);
        Dxy = mainhandles.data(filechoice).FRETpairs(pairchoice).Dxy;
        Axy = mainhandles.data(filechoice).FRETpairs(pairchoice).Axy;
        scatter(mainhandles.ROIimage,Axy(1),Axy(2),'filled', 'MarkerFaceColor',Acolor)
        scatter(mainhandles.ROIimage,Dxy(1),Dxy(2),'filled', 'MarkerFaceColor',Dcolor)
        scatter(mainhandles.ROIimage,(Dxy(1)+Axy(1))/2,(Dxy(2)+Axy(2))/2,'filled', 'MarkerFaceColor',Ecolor)
    end
    hold(mainhandles.ROIimage,'off')
end

