function mainhandles = clearpeaksdata(mainhandles,files,choice) 
% Clears all peaks data in the file
%
%    Input:
%     mainhandles  - handles structure of the main window
%     files        - files to clear
%     choice       - 'D', 'A', ['all']
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

% Default
if nargin<3
    choice = 'all';
end

%% Clear

for i = 1:length(files)
    file = files(i);

    % Clear donor
    if strcmpi(choice,'D') || strcmpi(choice,'all')
        mainhandles.data(file).Dpeaks = [];
        mainhandles.data(file).DpeaksRaw = [];
        mainhandles.data(file).DpeaksGlobal = [];
        mainhandles.data(file).DpeaksMovie = [];
    end
    
    % Clear acceptor
    if strcmpi(choice,'A') || strcmpi(choice,'all')
        mainhandles.data(file).Apeaks = [];
        mainhandles.data(file).ApeaksRaw = [];
        mainhandles.data(file).ApeaksGlobal = [];
        mainhandles.data(file).ApeaksMovie = [];
    end
    
    % Clear all FRET pairs
    mainhandles.data(file).FRETpairs(:) = [];
    
    % Clear bin
    mainhandles.data(file).FRETpairsBin(:) = [];
end

%% Update handles

updatemainhandles(mainhandles)
