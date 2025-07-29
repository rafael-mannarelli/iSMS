function mainhandles = syntheticdriftCallback(dwHandles)
% Callback for applying a synthetic drift in the drift analysis window
%
%    Input:
%     dwHandles    - handles structure of the drift window
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

mainhandles = getmainhandles(dwHandles);
if isempty(mainhandles)
    return
end

% Return if there is no data
if isempty(mainhandles.data)
    set(CompensateCheckbox,'Value',0)
    mainhandles = compensatedriftCheckboxCallback(dwHandles);
    return
end

% Selected movie file
file = get(dwHandles.FilesListbox,'Value');

% Check if raw movie has been deleted
if isempty(mainhandles.data(file).imageData)
    mymsgbox(sprintf('The raw movie has been deleted for this file (%s).',mainhandles.data(file).name));
    return
end

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Dialog box

prompt = {...
    'Shift in x (pixels/frame): ' 'shiftX';...
    'Shift in y (pixels/frame): ' 'shiftY';...
    'Run drift analysis afterwards' 'runanalysis'};

name = 'Simulate';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type   = 'edit';
formats(2,1).size   = 50;
formats(2,1).format = 'float';
formats(3,1).type   = 'edit';
formats(3,1).size   = 50;
formats(3,1).format = 'float';
formats(6,1).type   = 'check';

% Default choices
DefAns.shiftX = 0.004;
DefAns.shiftY = -0.004;
DefAns.runanalysis = 1;

options.CancelButton = 'on';

% Open dialog box
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if cancelled == 1
    return
end
shiftX = answer.shiftX;
shiftY = answer.shiftY;

%% Initialize drift

msg = 0;

% Raw movies
imageData = mainhandles.data(file).imageData;

% Get ROI
[mainhandles, Droi, Aroi] = getROI(mainhandles,file,imageData,0);

% D and A data ranges
Dx = Droi(1):(Droi(1)+Droi(3))-1;
Dy = Droi(2):(Droi(2)+Droi(4))-1;
Ax = Aroi(1):(Aroi(1)+Aroi(3))-1;
Ay = Aroi(2):(Aroi(2)+Aroi(4))-1;

Dframes = find(mainhandles.data(file).excorder=='D'); % Indices of all F frames
Dimagedata = imageData(:,:,Dframes);

% Preallocate
mainhandles.data(file).DD_ROImovie = zeros(length(Dx),length(Dy),length(Dframes));
mainhandles.data(file).AD_ROImovie = zeros(length(Ax),length(Ay),length(Dframes));

if mainhandles.settings.excitation.alex
    Aframes = find(mainhandles.data(file).excorder=='A'); % Indices of all A frames
    Aimagedata = imageData(:,:,Aframes);
    
    mainhandles.data(file).AA_ROImovie = zeros(length(Ax),length(Ay),length(Aframes));
end

%% Start shifting

myprogressbar('Applying synthetic drift to ROI movies')
msg = 0;
for i = 1:length(Dframes)
    
    % Shifted ROI image grids
    [Dxi Dyi] = getshiftedGrid(Dx,Dy);
    [Axi Ayi] = getshiftedGrid(Ax,Ay);
    
    % Correct if new ROI exceeds raw movie limits
    [Dxi Dyi msg] = checknewROI(Dxi, Dyi, Dimagedata, msg);
    [Axi Ayi msg] = checknewROI(Axi, Ayi, Dimagedata, msg);
    
    % Make shifted movies using interp2
    mainhandles.data(file).DD_ROImovie(:,:,i) = uint16(interp2(single(Dimagedata(Dx,Dy,i)),Dxi,Dyi,'*linear',0));
    mainhandles.data(file).AD_ROImovie(:,:,i) = uint16(interp2(single(Dimagedata(Ax,Ay,i)),Axi,Ayi,'*linear',0));
    
    if alex
        mainhandles.data(file).AA_ROImovie(:,:,i) = uint16(interp2(single(Aimagedata(Ax,Ay,i)),Axi,Ayi,'*linear',0));
    end
    
    % Update progressbar
    progressbar(i/length(Dframes))
end

%% Update

updatemainhandles(mainhandles)

if msg
%     mymsgbox('Note that the ROI drift you specified made the ROIs exceed the boundaries of the raw movie. This means that drift may not have been simulated for all frames.',...
%         'Exceeded movie limits');
end

%% Analyse drift

if answer.runanalysis
    mainhandles = analysedriftCallback(dwHandles);
end

%% Nested

    function [xi yi] = getshiftedGrid(xs,ys)
        
        % Range
        x = round(xs);
        y = round(ys);
        xi = (1:length(x))' - i*shiftX;
        yi = (1:length(y)) - i*shiftY;
        
        % Create grid
        [xi yi] = meshgrid(yi,xi);
    end

    function [xi yi msg] = checknewROI(xi,yi,imageData,msg)
        % Difference
        d = [1-min(xi),   max(xi)-size(imageData,1),  1-min(yi),  max(yi)-size(imageData,2)];
        
        % Check x
        if max(xi) > size(imageData,1)
            xi = xi-d(2);
            msg = 1;
        elseif min(xi) < 1
            xi = xi+d(1);
            msg = 1;
        end
        
        % Check y
        if max(yi) > size(imageData,2)
            yi = yi-d(4);
            msg = 1;
        elseif min(yi) < 1
            yi = yi+d(3);
            msg = 1;
        end
        
    end
end