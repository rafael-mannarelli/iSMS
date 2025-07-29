function mainhandles = createTimeVector(mainhandles,files)
% Returns the time vector with a time stamp for each raw frame in the movie
%
%    Input:
%     mainhandles    - handles structure of the main window
%     files          - [file1 file2...] files to update
%
%    Output:
%     mainhandles    - ..
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

% Check
if isempty(mainhandles.data) || isempty(files)
    return
end

%% Create vectors

for i = 1:length(files)
    
    data = mainhandles.data(files(i));
    
    % Register raw movie length
    if isempty(data.rawmovieLength) || ~isequal(data.rawmovieLength,length(data.excorder))
        
        if ~isempty(data.excorder)
            data.rawmovieLength = length(data.excorder);
            
        elseif ~isempty(data.FRETpairs) && ~isempty(data.FRETpairs(1).DDtrace)
            data.rawmovieLength = length(data.FRETpairs(1).DDtrace)+length(data.FRETpairs(1).AAtrace);
            
        elseif ~isempty(data.imageData)
            data.rawmovieLength = size(data.imageData,3);
            
        elseif ~isempty(data.DD_ROImovie)
            data.rawmovieLength = size(data.DD_ROImovie,3)+size(data.AA_ROImovie,3);
        end
    end
    
    % Time vector
    if isempty(data.integrationTime)
        data.time = 1:data.rawmovieLength;
    else
        % Convert to seconds
        data.time = [1:data.rawmovieLength]*(data.integrationTime/1000);
    end
    
    % Store
    mainhandles.data(files(i)) = data;
    
end

%% Update handles structure

updatemainhandles(mainhandles)
