function mainhandles = askforDenoisedImage(mainhandles)
% Prompts the user for the denoised image of the selected movie.
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

% Selected files
filechoices = get(mainhandles.FilesListbox,'Value');

if isempty(mainhandles.data(filechoices).imageData) % If raw movie has been deleted
    mymsgbox(sprintf('%s %s',...
        'The denoised images of this file have not been calculated yet and the raw movie data has been deleted.',...
        'In order to use denoising you will have to reload the raw movie from file and select the denoised image again.'));
    set(mainhandles.FramesListbox,'Value',1)
    return
end

% Show question dialog
choice = myquestdlg('The denoised images of this file have not been calculated yet. Would you like to do it now?',...
    'Denoised image',...
    'Yes, for selected file', 'Yes, for all files', 'No' ,'Yes, for selected file');

if isempty(choice) || strcmpi(choice,'No') % Don't calculate denoised image and set selection to avg. image instead
    set(mainhandles.FramesListbox,'Value',1)
    return
end
if strcmpi(choice,'Yes, for all files') % Calculate denoised images of all files
    filechoices = 1:length(mainhandles.data);

end

% Turn on waitbar
hWaitbar = mywaitbar(0,'Denoising D+A frames. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Denoise images
run = 1;
mb = 1;
mc = 1;
for i = 1:length(filechoices)
    filechoice = filechoices(i);
    
    % Check size of movie
    imsz = size(mainhandles.data(filechoice).imageData);
    if ~isequal(imsz(1:2),[512 512])

        if mb % Show messagebox
            mymsgbox('Sorry, image denoising is currently only available for 512x512 frames.',sprintf('File: %s',mainhandles.data(filechoice).name))
            setFigOnTop
            mb = 0;
        end
        
        if length(filechoices)==mc % If none of the movies are valid
            set(mainhandles.FramesListbox, 'Value', 1)
            mainhandles = guidata(mainhandles.figure1);
            try delete(hWaitbar), end
            return
        else
            continue
        end
        
        mc = mc+1; % Number of invalid movies
    end
    
    % D+A frames
    waitbar(run/(3*length(filechoices)),hWaitbar,'Denoising D+A frames. Please wait...') % Update waitbar
    mainhandles = updateDenoisedImages(mainhandles,filechoice,'global'); % Calculate denoised global images
    run = run+1;
    
    % D frames
    waitbar(run/(3*length(filechoices)),hWaitbar,'Denoising D frames. Please wait...') % Update waitbar
    mainhandles = updateDenoisedImages(mainhandles,filechoice,'donor'); % Calculate denoised D-exc images
    run = run+1;
    
    % A frames
    waitbar(run/(3*length(filechoices)),hWaitbar,'Denoising A frames. Please wait...') % Update waitbar
    mainhandles = updateDenoisedImages(mainhandles,filechoice,'acceptor'); % Calculate denoised A-exc images
    run = run+1;
end

% Delete waitbar
try delete(hWaitbar), end

