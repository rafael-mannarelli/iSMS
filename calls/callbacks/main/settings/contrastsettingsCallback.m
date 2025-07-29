function mainhandles = contrastsettingsCallback(mainhandles)
% Callback for setting contrast slider settings in the main window
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

if nargin<1
    mainhandles = guidata(getappdata(0,'mainhandle'));
end

%% Dialog

% Initialize dialog
name = 'Contrast settings';
prompt = {'Low value: ' '';...
    'High value: ' '';...
    'Raw image: ' '';...
    'min. intensity      *' 'rawcontrast1';...
    'max intensity *' 'rawcontrast2';...
    'Red channel overlay: ' '';...
    'median intensity *' 'redcontrast1';...
    'max intensity *' 'redcontrast2';...
    'Green channel overlay: ' '';...
    'median intensity *' 'greencontrast1';...
    'max intensity *' 'greencontrast2'};

formats = prepareformats();
formats(2,2).type = 'text';
formats(2,3).type = 'text';
formats(3,1).type = 'text';
formats(3,2).type = 'edit';
formats(3,2).format = 'float';
formats(3,2).size = [40 21];
formats(3,3).type = 'edit';
formats(3,3).format = 'float';
formats(3,3).size = [40 21];
formats(4,1).type = 'text';
formats(4,2).type = 'edit';
formats(4,2).format = 'float';
formats(4,2).size = [40 21];
formats(4,3).type = 'edit';
formats(4,3).format = 'float';
formats(4,3).size = [40 21];
formats(5,1).type = 'text';
formats(5,2).type = 'edit';
formats(5,2).format = 'float';
formats(5,2).size = [40 21];
formats(5,3).type = 'edit';
formats(5,3).format = 'float';
formats(5,3).size = [40 21];

% Defaults
DefAns.rawcontrast1 = mainhandles.settings.view.rawcontrast1;
DefAns.rawcontrast2 = mainhandles.settings.view.rawcontrast2;
DefAns.redcontrast1 = mainhandles.settings.view.redcontrast1;
DefAns.redcontrast2 = mainhandles.settings.view.redcontrast2;
DefAns.greencontrast1 = mainhandles.settings.view.greencontrast1;
DefAns.greencontrast2 = mainhandles.settings.view.greencontrast2;

% Open dialog
[answer, cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled
    return
end

%% Update settings

% Check values
rawcontrast1 = checkcontrast(answer.rawcontrast1);
rawcontrast2 = checkcontrast(answer.rawcontrast2);
redcontrast1 = checkcontrast(answer.redcontrast1);
redcontrast2 = checkcontrast(answer.redcontrast2);
greencontrast1 = checkcontrast(answer.greencontrast1);
greencontrast2 = checkcontrast(answer.greencontrast2);

% Save setting
mainhandles = savesettingasDefaultDlg(mainhandles,...
    'view',...
    {'rawcontrast1' 'rawcontrast2' 'redcontrast1' 'redcontrast2' 'greencontrast1' 'greencontrast2'},...
    {rawcontrast1 rawcontrast2 redcontrast1 redcontrast2 greencontrast1 greencontrast2});

% Waitbar
hWaitbar = mywaitbar(0,'Updating. Please wait...','name','iSMS');

% Update contrast values of all files
for i = 1:length(mainhandles.data)
    [contrastLims rawcontrast redROIcontrast greenROIcontrast] = getContrast(mainhandles,i);
    
    mainhandles.data(i).rawcontrast = rawcontrast; % [min max] intensity in raw image /[rawMin rawMax];%mainhandles.data(end).rawcontrastMinMax
    mainhandles.data(i).redROIcontrast = redROIcontrast; % [min max] contast in red ROI channel
    mainhandles.data(i).greenROIcontrast = greenROIcontrast; % [min max] contrast in green ROI channel
    
    % Update waitbar
    waitbar(i/length(mainhandles.data))
    
end

% Update handles structure
updatemainhandles(mainhandles)

% Update contrast sliders and images
mainhandles = updaterawimage(mainhandles,[],1);
mainhandles = updateROIimage(mainhandles,0,0,1);

% Delete waitbar
try delete(hWaitbar), end

%% Nested

    function val = checkcontrast(val)
        if val<=0
            val = 1;
        end
    end

end