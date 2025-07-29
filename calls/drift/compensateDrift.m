function mainhandles = compensateDrift(mainhandle,file)
% Produces a drift-compensated movie of movie file filechoice and stores it
% in the mainhandles structure
%
%    Input:
%     mainhandle   - handle to the main figure window
%     file         - choice of moviefile
%
%    Output:
%     mainhandles  - ..
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

% Get handles structure of the main figure window (sms)
mainhandles = guidata(mainhandle);
if isempty(mainhandles.data)
    return
end

% Scheme
alex = mainhandles.settings.excitation.alex;

% Make ROI movies, if not already made
if isempty(mainhandles.data(file).DD_ROImovie) || (alex && isempty(mainhandles.data(file).AA_ROImovie))
    [mainhandles,MBerror] = saveROImovies(mainhandles);
    if MBerror
        return
    end
end

%% Make drift correction

if numel(unique(mainhandles.data(file).drifting.drift))==1
    
    % Drift is all zeros - show dialog
    mymsgbox(sprintf('%s(%s). %s',...
        'There is no drift, or zero-drift, stored for this file ',...
        mainhandles.data(file).name,...
        'Run drift analysis to calculate the drift.'));
    
else
    
    % Initialize progressbar
    myprogressbar(sprintf('Compensating drift in file %i: Calculating new ROI movies',file))
    
    % Movies
    DD_ROImovieDriftCorr = mainhandles.data(file).DD_ROImovie;
    AD_ROImovieDriftCorr = mainhandles.data(file).AD_ROImovie;
    AA_ROImovieDriftCorr = mainhandles.data(file).AA_ROImovie;
    
    % Make drift compensation for each frame
    for j = 1:size(DD_ROImovieDriftCorr,3)
        xi = (1:size(DD_ROImovieDriftCorr,1))'+mainhandles.data(file).drifting.drift(j,1);
        yi = (1:size(DD_ROImovieDriftCorr,2))+mainhandles.data(file).drifting.drift(j,2);
        [xi yi] = meshgrid(yi,xi);
        
        DD_ROImovieDriftCorr(:,:,j) = interp2(single(DD_ROImovieDriftCorr(:,:,j)),xi,yi,'*linear',0);
        AD_ROImovieDriftCorr(:,:,j) = interp2(single(AD_ROImovieDriftCorr(:,:,j)),xi,yi,'*linear',0);
        
        if alex
            AA_ROImovieDriftCorr(:,:,j) = interp2(single(AA_ROImovieDriftCorr(:,:,j)),xi,yi,'*linear',0);
        end
        
        % Update progressbar
        progressbar(j/size(DD_ROImovieDriftCorr,3))
    end
    
    % Store in mainhandles structure
    mainhandles.data(file).DD_ROImovieDriftCorr = DD_ROImovieDriftCorr;
    mainhandles.data(file).AD_ROImovieDriftCorr = AD_ROImovieDriftCorr;
    mainhandles.data(file).AA_ROImovieDriftCorr = AA_ROImovieDriftCorr;
    
    % Calculate drift compensated intensity traces and update plots
    filePairs = getPairs(mainhandle, 'File',file);
    if ~isempty(filePairs)
        
        % Calculate intensity traces
        updatemainhandles(mainhandles)
        [mainhandles FRETpairwindowHandles] = calculateIntensityTraces(mainhandle,filePairs);
        
    end
end

% Update
updatemainhandles(mainhandles)
