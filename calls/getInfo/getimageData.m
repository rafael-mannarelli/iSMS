function imagedata = getimageData(mainhandles,file,framechoice)
% Returns the D and A images to be plotted in the window. Use
% getrawImage to get raw image
%
%    Input:
%     mainhandles  - handles structure of the main window
%     file         - movie file
%     framechoice  - optional for forced frame listbox selection
%
%    Output:
%     imageData    - image
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

if nargin<2 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value')
end
if nargin<3 || isempty(framechoice)
    framechoice = get(mainhandles.FramesListbox,'Value')-2;
end

%% Images

if framechoice == -1 % If average image is selected from the frames listbox
    
    Dchoice = mainhandles.settings.averaging.avgDchoice;
    Achoice = mainhandles.settings.averaging.avgAchoice;
    
    % Averaging choice
    if (strcmp(Dchoice,'all')) && (strcmp(Achoice,'all'))
        imagedata = mainhandles.data(file).avgimage; % If using all frames for averaging
    elseif (strcmp(Dchoice,'Dexc')) && (strcmp(Achoice,'Dexc'))
        imagedata = mainhandles.data(file).avgDimage;
    elseif (strcmp(Dchoice,'all')) && (strcmp(Achoice,'Dexc'))
        imagedata = mainhandles.data(file).avgimage;
        imagedata(:,:,2) = mainhandles.data(file).avgDimage;
    elseif (strcmp(Dchoice,'Dexc')) && (strcmp(Achoice,'all'))
        imagedata = mainhandles.data(file).avgDimage;
        imagedata(:,:,2) = mainhandles.data(file).avgimage;
    elseif (strcmp(Dchoice,'all')) && (strcmp(Achoice,'Aexc'))
        imagedata = mainhandles.data(file).avgimage;
        imagedata(:,:,2) = mainhandles.data(file).avgAimage;
    elseif (strcmp(Dchoice,'Dexc')) && (strcmp(Achoice,'Aexc'))
        imagedata = mainhandles.data(file).avgDimage;
        imagedata(:,:,2) = mainhandles.data(file).avgAimage;
    end
        
elseif framechoice == 0 % If background image is selected from the frames listbox
    imagedata = double(mainhandles.data(file).back);
    
else
    % If a frame is selected from the frames listbox
    
    % Check selection does not exceed movie
    if framechoice>size(mainhandles.data(file).imageData,3)
        set(mainhandles.FramesListbox,'Value',1)
        imagedata = getimageData(mainhandles,file);
        return
    end
    
    imagedata = mainhandles.data(file).imageData(:,:,framechoice);
end
