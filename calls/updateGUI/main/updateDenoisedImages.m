function mainhandles = updateDenoisedImages(mainhandles,filechoice,channel) 
% Updates the denoised images 
%
%      Input:
%       mainhandles - handles structure of the main window (sms)
%       filechoice  - movie file to denoise
%       channel     - 'donor', 'acceptor', 'all'
%
%      Output:
%       mainhandles - ..
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

% Check if raw movie has been deleted
if isempty(mainhandles.data(filechoice).imageData)
    % Display question dialog
    choice = myquestdlg(sprintf('The raw movie has been deleted for this file (%s). Do you want to reload the movie from file?',mainhandles.data(filechoice).name),...
        'Movie deleted',...
        'Yes','No','No');

    if strcmp(choice,'Yes')
        % Reload movie
        mainhandles = reloadMovieCallback(mainhandles);        
        % Re-select denoised image
        mainhandles = filesListboxCallback(mainhandles.FilesListbox); % Imitate click in files listbox
        return
    else
        return
    end
end

% Don't do anything if its an intensity profile
if mainhandles.data(filechoice).spot
    return
end

% Parameters
k = mainhandles.settings.denoisingWaveletMultiframe.k;
p = mainhandles.settings.denoisingWaveletMultiframe.p;
r = mainhandles.settings.denoisingWaveletMultiframe.r;
maxLevel = mainhandles.settings.denoisingWaveletMultiframe.maxLevel;
weightMode = mainhandles.settings.denoisingWaveletMultiframe.weightMode;
windowSize = mainhandles.settings.denoisingWaveletMultiframe.windowSize;
if mainhandles.settings.denoisingWaveletMultiframe.basis==1
    basis = 'haar';
else
    basis = 'dualTree';
end
nframes = mainhandles.settings.denoisingWaveletMultiframe.nframes;

% Check size
imsz = size(mainhandles.data(filechoice).imageData);
if ~isequal(imsz(1:2),[512 512])
    mymsgbox('Sorry, image denoising is currently only available for 512x512 frames')
    return    
end

%% Denoise (global) image of all frames

interval = [1 nframes]; % Interval of denoising
if (strcmp(channel,'global')) || (strcmp(channel,'all'))
    denimage = waveletMultiFrame(mainhandles.data(filechoice).imageData(:,:,interval(1):interval(2)),...
        'k',k, 'p',p, 'r',r, 'maxLevel',maxLevel, 'weightMode',weightMode, 'windowSize',windowSize, 'basis',basis);
    mainhandles.data(filechoice).denimage = single( sum(denimage,3) );
end

%% Denoise (global) image of all donor excitation frames

if (strcmp(channel,'donor')) || (strcmp(channel,'all'))
    Dframes = find(mainhandles.data(filechoice).excorder=='D'); % Indices of all donor exc frames
    denDimage = waveletMultiFrame(mainhandles.data(filechoice).imageData(:,:,Dframes(interval(1):interval(2))),...
        'k',k, 'p',p, 'r',r, 'maxLevel',maxLevel, 'weightMode',weightMode, 'windowSize',windowSize, 'basis',basis);
    mainhandles.data(filechoice).denDimage = single( sum(denDimage,3));
end

%% Denoise (global) image of all acceptor excitation frames

if (strcmp(channel,'acceptor')) || (strcmp(channel,'all'))
    Aframes = find(mainhandles.data(filechoice).excorder=='A'); % Indices of all donor exc frames
    denAimage = waveletMultiFrame(mainhandles.data(filechoice).imageData(:,:,Aframes(interval(1):interval(2))),...
        'k',k, 'p',p, 'r',r, 'maxLevel',maxLevel, 'weightMode',weightMode, 'windowSize',windowSize, 'basis',basis);
    mainhandles.data(filechoice).denAimage = single( sum(denAimage,3) ); % Convert to single type
end

%% Update

updatemainhandles(mainhandles)
