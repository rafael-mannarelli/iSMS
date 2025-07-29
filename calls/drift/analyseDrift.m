function mainhandles = analyseDrift(mainhandle, file)
% Runs a drift analysis of the ROIs of the selected movie file and saves
% the drift to the handles structure
%
%    Input:
%     mainhandle   - handle to the main figure window
%     file         - file to analyse
%
%    Output:
%     mainhandles  - handles structure of the main window
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
    
    % Return if raw data is missing
    if isempty(mainhandles.data(file).imageData)
        mymsgbox('The raw movie data has been removed for this file. Reload the raw data from the Performance-Memory menu in the main window and try again.')
        return
    end
    
    % Make new ROI movies
    [mainhandles,MBerror] = saveROImovies(mainhandles,file);
    if MBerror
        return
    end
end

% Get average movie image
imageData = mainhandles.data(file).avgimage;

% Get ROI data
[mainhandles, Droi, Aroi] = getROI(mainhandles,file,imageData);
donx = Droi(1):(Droi(1)+Droi(3))-1;
dony = Droi(2):(Droi(2)+Droi(4))-1;
accx = Aroi(1):(Aroi(1)+Aroi(3))-1;
accy = Aroi(2):(Aroi(2)+Aroi(4))-1;

%% Detect acceptor shift

if mainhandles.settings.excitation.alex
    
    % In ALEX, use direct acceptor
    driftMovie = mainhandles.data(file).AA_ROImovie;
    
    % Reference image relative to which all frame shifts are calculated
    if size(driftMovie,3)>=50
        refimg = sum(driftMovie(:,:,1:50),3)/50; % Avg of 50 first frames
    else
        refimg = sum(driftMovie,3)/size(driftMovie,3); % Avg of 50 first frames
    end
    
else
    % In single-color excitation, use sum of D and A
    driftMovie = mainhandles.data(file).AD_ROImovie+mainhandles.data(file).DD_ROImovie;
    
    % Reference image relative to which all frame shifts are calculated
    refimg = imageData(accx,accy);
end

% Initialize drift vector [x y]
drft = zeros(size(driftMovie,3), 2);

% Detect shifts between ref image and movie frame images
run = 2; % Start indexing drift in row 2 since first row (0,0) is the reference image
myprogressbar(sprintf('Drift analysis of file %i: Calculating frame shifts',file))

for i = 1:size(driftMovie,3);
    
    % Get image of frame i
    if mainhandles.data(file).drifting.avgchoice % If using averaging between neighbouring frames
        
        % Neighbours on either side
        nb = ceil((mainhandles.data(file).drifting.avgneighbours-1)/2);
        
        % Frame interval to avg
        if i <= nb % If neighbours exceed movie start for frame i
            z = 1:i+nb;
        elseif i+nb > size(driftMovie,3) % If neighbours exceed movie end
            z = i-nb:size(driftMovie,3);
        else
            z = i-nb:i+nb;
        end
        
        % Take average
        frameimg = sum(driftMovie(:,:,z),3)/length(z);
        
    else
        
        % Don't using averaging
        frameimg = driftMovie(:,:,i); % Image frame i
    end
    
    output   = dftregistration(fft2(frameimg), fft2(refimg), mainhandles.data(file).drifting.upscale); % Detect shift between fixed reference image and image i
    drft(run,:) = output(3:4);
    run = run+1;
    
    % Update progressbar
    progressbar(i/size(driftMovie,3))
end

% Set first frame as reference
if nb>0 && size(drft,1)>nb
    drft(1:nb,:) = drft(nb+1,:);
end
drft(:,1) = drft(:,1)-drft(1,1);
drft(:,2) = drft(:,2)-drft(1,2);

%% Update mainhandles structure

mainhandles.data(file).drifting.drift = drft;
updatemainhandles(mainhandles)
