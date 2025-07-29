function [x ms mainhandles] = getTimeVector(mainhandles,selectedPair,exc)
% Returns the time vector with a time stamp for each raw frame in the movie
%
%    Input:
%     mainhandles    - handles structure of the main window
%     filechoice     - file
%     pairchoice     - pair
%     exc            - 'D', 'A'
%
%    Output:
%     x              - time vector
%     ms             - avg. integration time
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

x = [];

if nargin<3 || isempty(exc)
    exc = 'D';
end

file = selectedPair(1,1);

% Frame indices in raw movie
frames = find(mainhandles.data(file).excorder==exc);

% Check that time vector exists
if isempty(mainhandles.data(file).time) ...
        || length(mainhandles.data(file).excorder)~=length(mainhandles.data(file).time)
    mainhandles = createTimeVector(mainhandles,file);
end

%% Return time stamps of channel

% try 
    x = mainhandles.data(file).time(frames);
    
    % Return mean step time
    if nargout>1
        ms = mean(diff(x(:)));
    end
% end
