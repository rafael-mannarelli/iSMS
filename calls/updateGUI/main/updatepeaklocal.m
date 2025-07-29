function mainhandles = updatepeaklocal(mainhandles,channel,files) 
% Updates the peak coordinates within the local ROI image frames
%
%    Input:
%     mainhandles  - handles structure of the main figure window
%     channel      - 'acceptor', 'donor', 'both', 'all', or 'FRET'
%     files        - movie files
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

% Default
if nargin<2 || isempty(channel)
    channel = 'all';
end
if nargin<3 || isempty(files)
    files = get(mainhandles.FilesListbox,'Value');
end

if isempty(mainhandles.data)
    return
end

%% Update coordinates
% fileinUpdatePeakLocal=files
for i = 1:length(files)
    
    file = files(i);
    
    % Donor
    if ((strcmpi(channel,'donor')) || (strcmpi(channel,'both')) || (strcmpi(channel,'all'))) && (~isempty(mainhandles.data(file).DpeaksGlobal))
        Droi = round(mainhandles.data(file).Droi);
        DpeaksGlobal = mainhandles.data(file).DpeaksGlobal;
        mainhandles.data(file).Dpeaks = [DpeaksGlobal(:,1)-Droi(1) DpeaksGlobal(:,2)-Droi(2)];
    end
    
    % Acceptor
    if ((strcmpi(channel,'acceptor')) || (strcmpi(channel,'both')) || (strcmpi(channel,'all'))) && (~isempty(mainhandles.data(file).ApeaksGlobal))
        Aroi = round(mainhandles.data(file).Aroi);
        ApeaksGlobal = mainhandles.data(file).ApeaksGlobal;
        mainhandles.data(file).Apeaks = [ApeaksGlobal(:,1)-Aroi(1) ApeaksGlobal(:,2)-Aroi(2)];
    end
    
    % FRET pairs
    if ((strcmpi(channel,'FRET')) || (strcmpi(channel,'all'))) && (~isempty(mainhandles.data(file).FRETpairs))
        Droi = round(mainhandles.data(file).Droi);
        Aroi = round(mainhandles.data(file).Aroi);
        for j = 1:length(mainhandles.data(file).FRETpairs)
            DxyGlobal = mainhandles.data(file).FRETpairs(j).DxyGlobal;
            AxyGlobal = mainhandles.data(file).FRETpairs(j).AxyGlobal;
            mainhandles.data(file).FRETpairs(j).Dxy = [DxyGlobal(1)-Droi(1) DxyGlobal(2)-Droi(2)];
            mainhandles.data(file).FRETpairs(j).Axy = [AxyGlobal(1)-Aroi(1) AxyGlobal(2)-Aroi(2)];
        end
    end
end

updatemainhandles(mainhandles)
