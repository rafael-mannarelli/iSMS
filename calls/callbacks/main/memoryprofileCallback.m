function memoryprofileCallback(mainhandles)
% Callback for the memory profiler in the main memory menu
%
%      Input:
%       mainhandles   - handles structure of the main window
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

% Not supported for macs
if ismac
    mymsgbox('Sorry, this function is not supported for Mac platforms.')
    return
end

% Selected file
filechoice = get(mainhandles.FilesListbox,'Value');

%% Get memory profile

[userview systemview] = memory;
dataTotal = mainhandles.data;
dataTotal = whos('dataTotal');
dataTotal = dataTotal.bytes;
if ~isempty(mainhandles.data)
    dataSelected = mainhandles.data(filechoice);
    dataSelected = whos('dataSelected');
    dataSelected = dataSelected.bytes;
else
    dataSelected = 0;
end

rawMovies = 0;
ROImovies = 0;
ROImoviesDriftCorr = 0;
avgimages = 0;
for i = 1:length(mainhandles.data)
    % Count memory used for storing raw movies
    temp = mainhandles.data(i).imageData;
    temp = whos('temp');
    rawMovies = rawMovies+temp.bytes;
    
    % Count memory used for storing ROI movies
    temp = mainhandles.data(i).DD_ROImovie;
    temp = whos('temp');
    ROImovies = ROImovies+temp.bytes;
    temp = mainhandles.data(i).AD_ROImovie;
    temp = whos('temp');
    ROImovies = ROImovies+temp.bytes;
    temp = mainhandles.data(i).DA_ROImovie;
    temp = whos('temp');
    ROImovies = ROImovies+temp.bytes;
    temp = mainhandles.data(i).AA_ROImovie;
    temp = whos('temp');
    ROImovies = ROImovies+temp.bytes;
    
    % Count memory used for storing drift-corrected ROI movies
    temp = mainhandles.data(i).DD_ROImovieDriftCorr;
    temp = whos('temp');
    ROImoviesDriftCorr = ROImoviesDriftCorr+temp.bytes;
    temp = mainhandles.data(i).AD_ROImovieDriftCorr;
    temp = whos('temp');
    ROImoviesDriftCorr = ROImoviesDriftCorr+temp.bytes;
    temp = mainhandles.data(i).DA_ROImovieDriftCorr;
    temp = whos('temp');
    ROImoviesDriftCorr = ROImoviesDriftCorr+temp.bytes;
    temp = mainhandles.data(i).AA_ROImovieDriftCorr;
    temp = whos('temp');
    ROImoviesDriftCorr = ROImoviesDriftCorr+temp.bytes;
    
    % Count memory used for storing average images
    temp = mainhandles.data(i).avgimage;
    temp = whos('temp');
    avgimages = avgimages+temp.bytes;
    temp = mainhandles.data(i).avgDimage;
    temp = whos('temp');
    avgimages = avgimages+temp.bytes;
    temp = mainhandles.data(i).avgAimage;
    temp = whos('temp');
    avgimages = avgimages+temp.bytes;
end
h = whos('mainhandles');
h = h.bytes;

%% Prepare messagebox

prompt = {'Memory used by MATLAB:' ''; sprintf('%.0f MB',userview.MemUsedMATLAB*9.53674316*10^-7) '';...
    'Memory available for all arrays:' ''; sprintf('%.0f MB',userview.MemAvailableAllArrays*9.53674316*10^-7) '';...
    'Maximum possible array:' ''; sprintf('%.0f MB',userview.MaxPossibleArrayBytes*9.53674316*10^-7) '';...
    
    'Physical memory available (RAM):' ''; sprintf('%.0f MB',systemview.PhysicalMemory.Available*9.53674316*10^-7) '';...
    'Physical memory in total (RAM):' ''; sprintf('%.0f MB',systemview.PhysicalMemory.Total*9.53674316*10^-7) '';...
    'System memory available:' ''; sprintf('%.0f MB',systemview.SystemMemory.Available*9.53674316*10^-7) '';...
    
    'Memory used for data (selected file):' ''; sprintf('%.0f MB',dataSelected*9.53674316*10^-7) '';...
    'Memory used for data (total):' ''; sprintf('%.0f MB',dataTotal*9.53674316*10^-7) '';...
    'Memory used for raw movies:' ''; sprintf('%.0f MB',rawMovies*9.53674316*10^-7) '';...
    'Memory used for ROI movies:' ''; sprintf('%.0f MB',ROImovies*9.53674316*10^-7) '';...
    'Memory used for drift-corrected ROI movies:' ''; sprintf('%.0f MB',ROImoviesDriftCorr*9.53674316*10^-7) '';...
    'Memory used for average images:' ''; sprintf('%.0f MB',avgimages*9.53674316*10^-7) '';...
    'Total memory used by handles structure:' ''; sprintf('%.0f MB',h*9.53674316*10^-7) ''};

name = 'Memory profile';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Choices
formats(2,1).type = 'text';
formats(2,2).type = 'text';
formats(3,1).type = 'text';
formats(3,2).type = 'text';
formats(4,1).type = 'text';
formats(4,2).type = 'text';

formats(6,1).type = 'text';
formats(6,2).type = 'text';
formats(7,1).type = 'text';
formats(7,2).type = 'text';
formats(8,1).type = 'text';
formats(8,2).type = 'text';

formats(10,1).type = 'text';
formats(10,2).type = 'text';
formats(11,1).type = 'text';
formats(11,2).type = 'text';
formats(12,1).type = 'text';
formats(12,2).type = 'text';
formats(13,1).type = 'text';
formats(13,2).type = 'text';
formats(14,1).type = 'text';
formats(14,2).type = 'text';
formats(15,1).type = 'text';
formats(15,2).type = 'text';

formats(17,1).type = 'text';
formats(17,2).type = 'text';

options.CancelButton = 'off';

%% Open dialog box

inputsdlg(prompt, name, formats, [], options); % Open dialog box
