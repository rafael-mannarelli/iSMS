function updateframesliderImage(pos,choice)
% Callback when the image frame-slider is changed above the ROI image
%
%   Input:
%    pos     - [x y width height]
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

if ~isempty(getappdata(0,'dontupdate')) % If its being called from
    return
end
mainhandle = getappdata(0,'mainhandle');
mainhandles = guidata(mainhandle);

file = get(mainhandles.FilesListbox,'Value');

if choice==1
    ax = 'ROIframesliderAxes';
    sliderHandle = 'ROIframesliderHandle';
    avgFrames = 'avgimageFrames';
else
    ax = 'rawframesliderAxes';
    sliderHandle = 'rawframesliderHandle';
    avgFrames = 'avgimageFramesRaw';
end

% Delete possible ROI handles if no data is loaded
if isempty(mainhandles.data) || isempty(mainhandles.data(file).imageData) ...
        || get(mainhandles.FramesListbox,'Value')~=1
    warning off
    try
        h = findobj(mainhandles.(ax),'type','rectangle')
        delete(h)
        delete(mainhandles.(sliderHandle))
        mainhandles.(sliderHandle) = [];
        updatemainhandles(mainhandles)
    end
    warning on
    return
end

% Turn off peak plot
mainhandles = turnofftoggles(mainhandles,'all',0);

%% Get position

% Position of frame slider ROI
pos = getPosition(mainhandles.(sliderHandle)); % [xPos yPos width height]
if pos(2)>-1 || pos(4)~=15 || pos(2)+pos(4)<=2
    pos(2) = -5;
    pos(4) = 15;
    setPosition(mainhandles.(sliderHandle),pos) % [x y width height]. This will re-run this function
    return
end
if pos(3)==0 % If width has been squeezed to zero
    pos(3) = 1;
    setPosition(mainhandles.(sliderHandle),pos) % [x y width height]. This will re-run this function
    return
end

% Set pointer to thinking (TOO SLOW)
% pointer = setpointer(handles.figure1,'watch');

%% Update according to position

% Interpret slider positions
x1 = round(pos(1));
x2 = round(pos(1)+round(pos(3)));
x1 = checkPos(x1);
x2 = checkPos(x2);

% Update handles structure with new interval
mainhandles.data(file).(avgFrames) = [x1 x2];
updatemainhandles(mainhandles)

% Update plot
if isempty(mainhandles.data(file).imageData) % If raw movie has been deleted
    set(mainhandles.mboard,'String',sprintf('%s%s',...
        'The raw movie has been deleted for this file so nothing happens when changing avg. image slider. ',...
        'You can reload the raw movie from the ''Memory -> Reload raw movie'' menu button.'))
    
elseif choice==1
    
    % Always update donor image
    mainhandles = updateavgimages(mainhandles,'donor',file);
    
    % Update acceptor image if ALEX
    if mainhandles.settings.excitation.alex
        
        % Update A image depending on averaging choice
        Achoice = mainhandles.settings.averaging.avgAchoice;
        if strcmp(Achoice,'all')
            mainhandles = updateavgimages(mainhandles,'global',file);
        elseif strcmp(Achoice,'Aexc')
            mainhandles = updateavgimages(mainhandles,'acceptor',file);
        end
        
    end
    
    % Update image plot
    mainhandles = updateROIimage(mainhandles);
    
    % Update contrast histogram
    %     mainhandles = updatecontrastSliders(mainhandles,1,0,0,1,1);
    % Too slow, so don't:
    % handles = updatepeakplot(handles,'all');
    
elseif choice==2
    
    mainhandles = updateavgimages(mainhandles,'global',file);
    
    % New image to plot
    img = mainhandles.data(file).avgimage';
    if mainhandles.settings.view.rawlogscale
        img = real(log10(img));
    end
    
    % Set imagedata
    imgHandle = findobj(get(mainhandles.rawimage,'children'),'type','image');
    set(imgHandle,'CData',img)
    %     mainhandles = updaterawimage(mainhandles); % Slower
    
    % Update contrast histogram
    mainhandles = updatecontrastSliders(mainhandles,1,0,1,0,0);
end

% Update text string about avg. frames
updatemainframesliderTextbox(mainhandles,choice)

%% NEsted

    function x = checkPos(x)
        if x<1
            x = 1;
        end
        if x>mainhandles.data(file).rawmovieLength
            x = mainhandles.data(file).rawmovieLength;
        end
    end
end