function [mainhandles, hasRaw, hasROI] = checkRawData(mainhandles,filechoice)
% Checks existance of imageData and asks to reload if empty
%
%    Input:
%     mainhandles   - handles structure of the main window
%     filechoice    - selected movie file
%
%    Output:
%     mainhandles   - ..
%     hasRaw        - 0/1 raw image data is loaded
%     hasROI        - 0/1 ROI movies is saved
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

% Default
hasRaw = 1;
hasROI = 1;

%% Check raw image data

if isempty(mainhandles.data(filechoice).imageData)
    % If image data has been deleted
    hasRaw = 0;
    
    % Dialog
    answer = myquestdlg(sprintf('The raw movie has been deleted for file (%s). Do you want to reload the movie?',mainhandles.data(filechoice).name),...
        'Movie deleted',...
        'Yes','No','No');
    
    % Reload
    if strcmp(answer,'Yes')
        mainhandles = reloadMovieCallback(mainhandles);
        if ~isempty(mainhandles.data(filechoice).imageData)
            hasRaw = 1;
        end
    end
end

%% Check ROI data

% Don't check if not necessary
if nargout<3
    return
end

if isempty(mainhandles.data(filechoice).DD_ROImovie)
    
    % ROI data not present
    hasROI = 0;
    if isempty(mainhandles.data(filechoice).imageData)
        % Raw data is missing so ROI data can't be made
        return
    end
    
    % Save ROI movie
    mainhandles = saveROImovies(mainhandles,filechoice);
    if ~isempty(mainhandles.data(filechoice).DD_ROImovie)
        hasROI = 1;
    end
    
end
