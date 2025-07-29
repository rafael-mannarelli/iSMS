function idx = getAssocSpotfile(mainhandles,file,choice)
% Returns the index of the spot profile associated with file
%
%    Input:
%     mainhandles   - handles structure of the main window
%     file          - data file
%     choice        - 'G','R'
%
%    Output:
%     idx           - file idx of choice profile associated with file
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

idx = [];

if isempty(mainhandles.data)
    return
end

%% Get associated green profile

if strcmpi(choice,'G')
    Gs = getFiles(mainhandles,'Gspot');
    
    % Green profile associated with file i
    spotProfile = mainhandles.data(file).GspotProfile; % Current spot profile image
    if (~isempty(spotProfile)) && ~isempty(Gs)
        for i = 1:length(Gs)
            profile = mainhandles.data(Gs(i)).avgimage; % Profile image of spot j
            if isequal(spotProfile,profile)
                idx = Gs(i);
                return
            end
        end
    end
    return
end

%% Get associated red profile

if strcmpi(choice,'R')
    Rs = getFiles(mainhandles,'Rspot');
    
    % Green profile associated with file i
    spotProfile = mainhandles.data(file).RspotProfile; % Current spot profile image
    if (~isempty(spotProfile)) && ~isempty(Rs)
        for i = 1:length(Rs)
            profile = mainhandles.data(Rs(i)).avgimage; % Profile image of spot j
            if isequal(spotProfile,profile)
                idx = Rs(i);
                return
            end
        end
    end
    return
end