function mainhandles = storeROIposition(mainhandles,file,Droi,Aroi,updateImgChoice)
% Applies ROI position to filechoice and updates GUI accordingly
%
%   Input:
%    mainhandles     - handles structure of the main window
%    file            - file to update
%    Droi            - Donor roi
%    Aroi            - acceptor roi
%    updateImgChoice - 0/1 whether to update ROI ax in main window
%
%   Output:
%    mainhandles     - ..
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

if nargin<5 || isempty(updateImgChoice)
    updateImgChoice = 1;
end

%% Update structure

mainhandles.data(file).Droi = Droi; %  [x y width height] (+1 because the ROI imrect follows the ROI outer boundaries)
mainhandles.data(file).Aroi = Aroi; %  [x y width height]
mainhandles.data(file).DD_ROImovie = [];
mainhandles.data(file).AD_ROImovie = [];
mainhandles.data(file).AA_ROImovie = [];
mainhandles.data(file).DD_ROImovieDriftCorr = [];
mainhandles.data(file).AD_ROImovieDriftCorr = [];
mainhandles.data(file).AA_ROImovieDriftCorr = [];
mainhandles = updatepeaklocal(mainhandles,'all',file);

% Update pairs and detect if any has been deleted
npairs1 = length(mainhandles.data(file).FRETpairs);
mainhandles = updateFRETpairs(mainhandles,file); % Deletes FRET pairs outside ROI
npairs2 = length(mainhandles.data(file).FRETpairs);

%% Update GUI

% Update ROI image
if updateImgChoice
    mainhandles = updateROIimage(mainhandles,1,0);
    
    % Update peak plot and FRET pair window
    if npairs2~=npairs1
        updateFRETpairwindowChoice = 1;
    else
        updateFRETpairwindowChoice = 0;
    end
    mainhandles = updatepeakplot(mainhandles,'all',0,updateFRETpairwindowChoice);

end

% Reset raw peaks, this will force a new peak run on the selected frame
mainhandles.data(file).DpeaksRaw = [];
mainhandles.data(file).ApeaksRaw = [];

% Update handles
updatemainhandles(mainhandles)

% Update fine-adjust window if its open
if updateImgChoice ...
        && ~isempty(mainhandles.adjustROIswindowHandle) ...
        && ishandle(mainhandles.adjustROIswindowHandle)
    updateROItextbox(mainhandles.adjustROIswindowHandle)
end
