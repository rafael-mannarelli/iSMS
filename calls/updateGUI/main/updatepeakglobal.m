function mainhandles = updatepeakglobal(mainhandles,channel,files)
% Updates the peak coordinates within the global image frame from the peak
% coordinates in the ROI frame.
%
%    Input:
%     mainhandes  - handles structure of the main figure window
%     channel     - 'donor', 'acceptor', 'both', 'FRET', or 'all'
%     files       - movie files
%
%    Output:
%     mainhandles - ..
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

% If there is no data loaded
if isempty(mainhandles.data)
    return
end

% Default
if nargin<2 || isempty(channel)
    channel = 'both';
end
if nargin<3 || isempty(files)
    files = get(mainhandles.FilesListbox,'Value');
end

%% Update coordinates

% filesinUpdatePeakGlobal = files
for i = 1:length(files)
    file = files(i);
    
    % Get ROIs
    [mainhandles, Droi, Aroi] = getROI(mainhandles,file);
    
    % Update donor peaks
    if ((strcmpi(channel,'donor')) || (strcmpi(channel,'both')) || (strcmpi(channel,'all'))) && (~isempty(mainhandles.data(file).Dpeaks))
        Dpeaks = single( mainhandles.data(file).Dpeaks );
        mainhandles.data(file).DpeaksGlobal = [Dpeaks(:,1)+Droi(1) Dpeaks(:,2)+Droi(2)];
    elseif ((strcmpi(channel,'donor')) || (strcmpi(channel,'both')) || (strcmpi(channel,'all'))) && (isempty(mainhandles.data(file).Dpeaks))
        mainhandles.data(file).DpeaksGlobal = [];
    end
    
    % Update acceptor peaks
    if ((strcmpi(channel,'acceptor')) || (strcmpi(channel,'both')) || (strcmpi(channel,'all'))) && (~isempty(mainhandles.data(file).Apeaks))
        Apeaks = single( mainhandles.data(file).Apeaks );
        mainhandles.data(file).ApeaksGlobal = [Apeaks(:,1)+Aroi(1) Apeaks(:,2)+Aroi(2)];
    elseif ((strcmpi(channel,'acceptor')) || (strcmpi(channel,'both')) || (strcmpi(channel,'all'))) && (isempty(mainhandles.data(file).Apeaks))
        mainhandles.data(file).ApeaksGlobal = [];
    end
    
    % Update FRET pair peaks
    if ((strcmpi(channel,'FRET')) || (strcmpi(channel,'all'))) && (~isempty(mainhandles.data(file).FRETpairs))
        
        for j = 1:length(mainhandles.data(file).FRETpairs)
            Dxy = single( mainhandles.data(file).FRETpairs(j).Dxy );
            Axy = single( mainhandles.data(file).FRETpairs(j).Axy );
            
            mainhandles.data(file).FRETpairs(j).DxyGlobal = [Dxy(:,1)+Droi(1) Dxy(:,2)+Droi(2)];
            mainhandles.data(file).FRETpairs(j).AxyGlobal = [Axy(:,1)+Aroi(1) Axy(:,2)+Aroi(2)];
        end
        
    end
end

% Update handles structure
updatemainhandles(mainhandles)
