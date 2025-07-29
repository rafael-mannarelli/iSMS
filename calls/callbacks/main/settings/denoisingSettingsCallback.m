function mainhandles = denoisingSettingsCallback(mainhandles)
% Callback for the denoising settings dialog
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ..
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

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar

%% Prepare dialog
prompt = {'waveletMultiFrame settings' '';...
    'Number of frames: ' 'nframes';...
    'k: ' 'k';...
    'p: ' 'p';...
    'r: ' 'r';...
    'maxLevel: ' 'maxLevel';...
    'weightMode (0-4): ' 'weightMode';...
    'windowSize: ' 'windowSize';...
    'basis: ' 'basis'};
name = 'Denoising settings';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Choices
% waveletMultiFrame parameters
formats(1,1).type = 'text';
formats(2,1).type = 'edit';
formats(2,1).size = 50;
formats(2,1).format = 'integer';
formats(4,1).type = 'edit';
formats(4,1).size = 50;
formats(4,1).format = 'float';
formats(5,1).type = 'edit';
formats(5,1).size = 50;
formats(5,1).format = 'float';
formats(6,1).type = 'edit';
formats(6,1).size = 50;
formats(6,1).format = 'float';
formats(7,1).type = 'edit';
formats(7,1).size = 50;
formats(7,1).format = 'integer';
formats(8,1).type = 'edit';
formats(8,1).size = 50;
formats(8,1).format = 'integer';
formats(9,1).type = 'edit';
formats(9,1).size = 50;
formats(9,1).format = 'integer';
% Basis
bases = {'haar'; 'dualTree'};
formats(10,1).type = 'list';
formats(10,1).style = 'listbox';
formats(10,1).items = bases;
formats(10,1).size = [100 50];
formats(10,1).limits = [0 1]; % multi-select

% Default choices
DefAns.nframes = mainhandles.settings.denoisingWaveletMultiframe.nframes;
DefAns.k = mainhandles.settings.denoisingWaveletMultiframe.k;
DefAns.p = mainhandles.settings.denoisingWaveletMultiframe.p;
DefAns.r = mainhandles.settings.denoisingWaveletMultiframe.r;
DefAns.maxLevel = mainhandles.settings.denoisingWaveletMultiframe.maxLevel;
DefAns.weightMode = mainhandles.settings.denoisingWaveletMultiframe.weightMode;
DefAns.windowSize = mainhandles.settings.denoisingWaveletMultiframe.windowSize;
DefAns.basis = mainhandles.settings.denoisingWaveletMultiframe.basis;

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1) || isequal(DefAns,answer)
    return
end

%% Chosen settings

mainhandles.settings.denoisingWaveletMultiframe.nframes = answer.nframes;
mainhandles.settings.denoisingWaveletMultiframe.k = answer.k;
mainhandles.settings.denoisingWaveletMultiframe.p = answer.p;
mainhandles.settings.denoisingWaveletMultiframe.r = answer.r;
mainhandles.settings.denoisingWaveletMultiframe.maxLevel = answer.maxLevel;
mainhandles.settings.denoisingWaveletMultiframe.weightMode = answer.weightMode;
mainhandles.settings.denoisingWaveletMultiframe.windowSize = answer.windowSize;
mainhandles.settings.denoisingWaveletMultiframe.basis = answer.basis;

%% Update

updatemainhandles(mainhandles)

if isempty(mainhandles.data)
    % Return here if no data is loaded
    return
end

%% Count number of files currently having denoised images

denoisedFiles = [];
for i = 1:length(mainhandles.data)
    if ~isempty(mainhandles.data(i).denimage)
        denoisedFiles = [denoisedFiles; i];
    end
end
if isempty(denoisedFiles)
    return
end

%% Re-calculate denoised images with new settings

choice = myquestdlg('Do you wish to re-calculate the denoised images with the new settings?',...
    'Denoising',...
    'Yes', 'No', 'Yes');

if isempty(choice) || strcmpi(choice,'No')
    return
else
    
    % Turn on waitbar
    hWaitbar = mywaitbar(0,'Denoising D+A frames. Please wait...','name','iSMS');
    setFigOnTop % Sets the waitbar so that it is always in front
    
    % Denoise images
    run = 1;
    for i = 1:length(denoisedFiles)
        filechoice = denoisedFiles(i);
        
        mainhandles = updateDenoisedImages(mainhandles,filechoice,'global'); % Calculate denoised global images
        waitbar(run/(3*length(denoisedFiles)),hWaitbar,'Denoising D frames. Please wait...') % Update waitbar
        run = run+1;
        
        mainhandles = updateDenoisedImages(mainhandles,filechoice,'donor'); % Calculate denoised D-exc images
        waitbar(run/(3*length(denoisedFiles)),hWaitbar,'Denoising A frames. Please wait...') % Update waitbar
        run = run+1;
        
        mainhandles = updateDenoisedImages(mainhandles,filechoice,'acceptor'); % Calculate denoised A-exc images
        waitbar(run/(3*length(denoisedFiles)),hWaitbar,'Denoising D+A frames. Please wait...') % Update waitbar
        run = run+1;
    end
    
    % Delete waitbar
    try delete(hWaitbar), end
end
