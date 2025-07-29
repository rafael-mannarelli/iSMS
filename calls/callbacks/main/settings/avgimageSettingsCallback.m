function mainhandles = avgimageSettingsCallback(mainhandles)
% Callback for average image settings dialog
%
%     Input:
%      mainhandles   - handles structure of the main window
%
%     Output:
%      mainhandles   - ...
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

if nargin<1
    mainhandles = guidata(getappdata(0,'mainhandle'));
end

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
if ~isempty(mainhandles.data) % If no data is loaded, return
    
    for i = 1:length(mainhandles.data)

        if isempty(mainhandles.data(i).imageData)
            choice = myquestdlg(sprintf('Note: The raw movie data is needed in order to update the average images.\n\nDo you want to reload the raw data from file?\n'),...
                'Raw data deleted',...
                ' Yes ',' No, just skip files with missing data ',' Cancel ',' Cancel ');
            
            if strcmp(choice,' Yes ')
                mainhandles = reloadMovieCallback(mainhandles);
            elseif isempty(choice) || strcmp(choice,' Cancel ')
                return
            end
            
            break
        end
    end
    
end

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Prepare dialog box

if alex
    prompt = {...
        'Frames used in ALEX: ' '';...
        'Red channel: ' 'avgAchoice';...
        'Raw image:   ' 'avgrawchoice';...
        'Initial value: ' '';...
        'Default, avg. the first frames: ' 'firstFrames'};
else
    prompt = {...
        'Default number of frames to average: ' 'firstFrames'};
end

name = 'Average image';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Donor panel
if alex
    formats(2,1).type = 'text';
    formats(2,2).type = 'list';
    formats(2,2).style = 'popupmenu';
    formats(2,2).items = {'All frames '; 'D frames '; 'A frames '};
    formats(3,2).type = 'list';
    formats(3,2).style = 'popupmenu';
    formats(3,2).items = {'All frames '; 'D frames '; 'A frames '};
    
    formats(5,1).type   = 'text';
    formats(5,2).type   = 'edit';
    formats(5,2).size   = 50;
    formats(5,2).format = 'integer';
    
else
    formats(2,1).type   = 'edit';
    formats(2,1).size   = 50;
    formats(2,1).format = 'integer';
end

% Default choices
if alex
    DefAns.avgAchoice = defaultPopupVal(mainhandles.settings.averaging.avgAchoice);
    DefAns.avgrawchoice = defaultPopupVal(mainhandles.settings.averaging.avgrawchoice);
end
DefAns.firstFrames = round(mainhandles.settings.averaging.firstFrames);

options.CancelButton = 'on';

% Open dialog box
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if cancelled || isequal(answer,DefAns)
    return
end

%% Update settings

if answer.firstFrames<1
    answer.firstFrames = 1;
end

% Save settings
if alex
    % Prompts a dialog for saving as default
    mainhandles = savesettingasDefaultDlg(mainhandles,...
        'averaging',...
        {'avgAchoice' 'avgrawchoice' 'firstFrames'},...
        {popupChoice(answer.avgAchoice) popupChoice(answer.avgrawchoice) answer.firstFrames});
else
    
    % Prompts a dialog for saving as default
    mainhandles = savesettingasDefaultDlg(mainhandles,...
        'averaging',...
        {'firstFrames'},...
        {answer.firstFrames});
end

%% Update GUI

if alex
    mainhandles = updateavgimages(mainhandles,'all',1:length(mainhandles.data),0);
    mainhandles = updaterawimage(mainhandles);
    mainhandles = updateframesliderHandle(mainhandles);
    mainhandles = updateROIhandles(mainhandles);
    mainhandles = updateROIimage(mainhandles);
    mainhandles = updatepeakplot(mainhandles,'both');
end

end

% Functions for shortening code
function val = defaultPopupVal(choice)
if strcmp(choice,'all')
    val = 1;
elseif strcmp(choice,'Dexc')
    val = 2;
elseif strcmp(choice,'Aexc')
    val = 3;
end
end

function choice = popupChoice(val)
if val == 1
    choice = 'all';
elseif val == 2
    choice = 'Dexc';
elseif val == 3
    choice = 'Aexc';
end
end
