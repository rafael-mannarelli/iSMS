function [DROImovie,AROImovie] = getROItraces(mainhandles) 
% Returns the full movie of the donor and acceptor ROI data
%
%     Input:
%      mainhandles   - handle structure of the main window
%
%     Output:
%      DROImovie     - Donor ROI movie
%      AROImovie     - Acceptor ROI movie
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

DROImovie = [];
AROImovie = [];
filechoice = get(mainhandles.FilesListbox,'Value');

% Check if raw movie has been deleted
if isempty(mainhandles.data(filechoice).imageData)
    choice = myquestdlg(sprintf('The raw movie has been deleted for this file (%s). Do you want to reload the movie from file?',mainhandles.data(filechoice).name),...
        'Movie deleted',...
        'Yes','No','No');
    if strcmp(choice,'Yes')
        mainhandles = reloadMovieCallback(mainhandles);
        return
    else
        return
    end
end

% Selected image
imagedata = mainhandles.data(filechoice).imageData;

%% Get ROI

Droi = round(mainhandles.data(filechoice).Droi); %  [x y width height]
Aroi = round(mainhandles.data(filechoice).Aroi); %  [x y width height]
if (Droi(3)==0) || (Droi(4)==0) % If ROI has been squeezed to zero
    return
end
if ~isequal(Droi(3:4),Aroi(3:4))
    display('Donor-ROI and acceptor-ROI are not of equal size!')
    return
end

% D and A data ranges
Dx = Droi(1):(Droi(1)+Droi(3))-1;
Dy = Droi(2):(Droi(2)+Droi(4))-1;
Ax = Aroi(1):(Aroi(1)+Aroi(3))-1;
Ay = Aroi(2):(Aroi(2)+Aroi(4))-1;

%% Cut D and A ROIs from avgimage

DROImovie = imagedata(Dx , Dy, :);
AROImovie = imagedata(Ax , Ay, :);

