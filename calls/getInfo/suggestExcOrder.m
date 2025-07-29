function excorder = suggestExcOrder(mainhandles, imageData, Droi)
% Suggests an excorder based on the raw image data
%
%    Input:
%     mainhandles   - handles structure of the main window
%     imageData     - image data
%     Droi          - Donor ROI position
%
%    Output:
%     excorder      - excitation order, e.g. 'DADADA'
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

%% ALEX excitation scheme

if mainhandles.settings.excitation.alex && size(imageData,3)>1
    
    % If number of frames is odd
    ok = 0;
    if isodd(size(imageData,3))
        imageData = imageData(:,:,1:end-1);
        ok = 1;
    end
    
    % Sum every second image
    Droi = round(Droi);
    x = Droi(1):(Droi(1)+Droi(3))-1; % D ROI x range
    y = Droi(2):(Droi(2)+Droi(4))-1; % D ROI y range
    sumImage1 = sum(imageData(x , y, 1:2:end/2+1),3); % Sum image of uneven frames (only avg. half of the frames to save time)
    sumImage2 = sum(imageData(x , y, 2:2:end/2+1),3); % Sum image of even frames (only avg. half of the frames to save time)
    
    % Excorder
    if sum(sumImage1(:)) > sum(sumImage2(:)) 
        % Donor intensity in uneven frames is higher than in even frames
        excorder = repmat('DA',1,size(imageData,3)/2);
    else
        % Donor intensity in uneven frames is lower than in even frames
        excorder = repmat('AD',1,size(imageData,3)/2);
    end
    
    % Insert final odd frame
    if ok
        excorder = [excorder 'D'];
    end
    return
end

%% Single color excitation

excorder = repmat('D',1,size(imageData,3));

