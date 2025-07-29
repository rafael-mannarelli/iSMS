function mainhandles = updateDApeaks(mainhandles)
% Removes donor or acceptor peaks specified at the same site twice or more
%
%    Input:
%     mainhandles  - handles structure of the main figure window (sms)
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

if isempty(mainhandles.data)
    return
end
filechoice = get(mainhandles.FilesListbox,'Value'); % Selected movie file

%% Check donor peaks

if ~isempty(mainhandles.data(filechoice).Dpeaks)
    Dpeaks = round(mainhandles.data(filechoice).Dpeaks); % All donor peaks pixel locations
    [u,I,J] = unique(Dpeaks, 'rows', 'first');
    ixDupRows = setdiff(1:size(Dpeaks,1), I); % Indices of duplex rows minus the first

    mainhandles.data(filechoice).Dpeaks(ixDupRows,:) = [];
end

%% Check acceptor peaks

if ~isempty(mainhandles.data(filechoice).Apeaks)
    Apeaks = round(mainhandles.data(filechoice).Apeaks); % All acceptor peaks pixel locations
    [u,I,J] = unique(Apeaks, 'rows', 'first');
    ixDupRows = setdiff(1:size(Apeaks,1), I); % Indices of duplex rows minus the first
    
    mainhandles.data(filechoice).Apeaks(ixDupRows,:) = [];
end

%% Update

updatemainhandles(mainhandles)