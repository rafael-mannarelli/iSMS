function mainhandles = mergeFrameByFrameCallback(mainhandles, defG, defR)
% Callback for merging movies frame by frame
%
%   Input:
%    mainhandles   - handles structure of the main window
%    defG          - default G selection
%    defR          - default R selection
%
%   Output:
%    mainhandles   - ..
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

if isempty(mainhandles.data)
    set(mainhandles.mboard,'String','No data loaded')
    return
end

if nargin<2
    defG = [];
end
if nargin<3
    defR = [];
end

% File selection dialog
name = 'Merge frame by frame';
prompt = {'Select files 1', 'Gchoices';...
    'Select files 2', 'Rchoices'};
formats  = prepareformats();

formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = {mainhandles.data(:).name}';
formats(2,1).limits = [0 2];
formats(2,1).size = [300 400];

formats(2,2).type = 'list';
formats(2,2).style = 'listbox';
formats(2,2).items = {mainhandles.data(:).name}';
formats(2,2).limits = [0 2];
formats(2,2).size = [300 400];

% Default selection
if isempty(defG)
    DefAns.Gchoices = get(mainhandles.FilesListbox,'Value');
else
    DefAns.Gchoices = defG;
end
if isempty(defR)
    if DefAns.Gchoices<length(mainhandles.data)
        DefAns.Rchoices = get(mainhandles.FilesListbox,'Value')+1;
    elseif DefAns.Gchoices>1
        DefAns.Rchoices = get(mainhandles.FilesListbox,'Value')-1;
    else
        DefAns.Rchoices = 1;
    end
else
    DefAns.Rchoices = defR;
end

% Open dialog
[answer,cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled || isempty(answer.Gchoices) || isempty(answer.Rchoices)
    return
end

% Check selection
Gchoices = answer.Gchoices;
Rchoices = answer.Rchoices;
if length(Gchoices)~=length(Rchoices)
    % If the number of G channels and R channels are not the same
    mymsgbox('Please select the same number of files in each listbox. The files will be combined in the same order as they appear in the listbox.')
    mainhandles = mergeFrameByFrameCallback(mainhandles, Gchoices, Rchoices);
    return
end

% Count number of files prior merging
n1 = length(mainhandles.data);

% Perform merging
message = sprintf('The movie dimensions must be equal in order to merge.\nThis is not the case for the following combinations:\n');
ok = 0;
for i = 1:length(Gchoices)
    fileG = Gchoices(i);
    fileR = Rchoices(i);
    
    % Image data
    imgG = mainhandles.data(fileG).imageData;
    imgR = mainhandles.data(fileR).imageData;
    if ~isequal( size(imgG,1),size(imgR,1)) || ~isequal( size(imgG,2),size(imgR,2))
        % If dimensions do not match
        message = sprintf('%s\n - %s & %s',message,mainhandles.data(fileG).name,mainhandles.data(fileR).name);
        ok = 1;
        continue
    end
    
    % Pre-allocate
    n = size(imgG,3)+size(imgR,3); % Total length of new movie
    newImage = zeros( size(imgG,1), size(imgG,2), n, 'uint16');
    run1 = 1;
    run2 = 1;
    temp = 1;
    for frame = 1:n
        
        % Check if one of the movies is depleted
        if temp==1 && run1>size(imgG,3)
            temp = 2;
        elseif temp==2 && run2>size(imgR,3)
            temp = 1;
        end
        
        % Insert frame
        if temp == 1
            newImage(:,:,frame) = imgG(:,:,run1);
            run1 = run1+1;
            temp = 2;
        else
            newImage(:,:,frame) = imgR(:,:,run2);
            run2 = run2+1;
            temp = 1;
        end
    end
    
    % Store image
    data.imageData = newImage;
    name = sprintf('Merged: [%s]-[%s]',mainhandles.data(fileG).name,mainhandles.data(fileR).name);
    mainhandles = storeMovie(mainhandles,data,name,{mainhandles.data(fileG).filepath mainhandles.data(fileR).filepath});
    
    % live update file listbox
    updatemainhandles(mainhandles)
    updatefileslist(mainhandles.figure1)
end

% Show message
if ok
    mymsgbox(message)
end

% Check that any new data has been made
if length(mainhandles.data)==n1
    return
end

% Update
set(mainhandles.FilesListbox,'Value',length(mainhandles.data))
updatefileslist(mainhandles.figure1)
set(mainhandles.FramesListbox,'Value',1)
updateframeslist(mainhandles)
mainhandles = updaterawimage(mainhandles);
mainhandles = updateROIhandles(mainhandles);
mainhandles = updateROIimage(mainhandles);
