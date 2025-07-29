function [imageData, back] = loadfiles(mainhandles, filepath)
% Call different function for loading image data depending on file type
%
%    Input:
%     mainhandles  - handles structure of the main window
%     filepath     - fullfilepath
%
%    Output:
%     imageData    - raw image data
%     back         - background image
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

back = [];
imageData = [];

[pathstr, name, ext] = fileparts(filepath); % Break to determine suffix
filename = [name ext];

% Supported file formats
[fileformats, imgformats, movformats, bioformats, specialformats] = supportedformatsImport();

%% Load

try
    if length(filename)>=4 && ...
            (ismember( lower(filename(end-1:end)) ,specialformats) || ...
            ismember( lower(filename(end-2:end)) ,specialformats) || ...
            ismember( lower(filename(end-3:end)),specialformats) )
        
        % Specialized formats
        [imageData, back] = importSpecializedFormat(filepath);
        
    elseif length(filename)>=4 ...
            && (ismember( lower(filename(end-2:end)) ,movformats) ...
            || ismember( lower(filename(end-3:end)) ,movformats) )
        
        % Standard movie
        [imageData, frameRate, mainhandles] = loadMovie(filepath,mainhandles);
        
    elseif length(filename)>=4 && ...
            (ismember( lower(filename(end-1:end)) ,bioformats) || ...
            ismember( lower(filename(end-2:end)) ,bioformats) || ...
            ismember( lower(filename(end-3:end)),bioformats) )
        
        % Bioformats opened by bfopen
        imageData = importBioformat(filepath);
        
    else
        
        % Try bioformats anyway
        imageData = importBioformat(filepath);
        
    end
    
catch err
    
    % Unable to import
    str = sprintf('Unable to load file:\n %s\n\nError message:\n%s',filepath,err.message);
    myerrordlg(str,'iSMS');
    return
end
