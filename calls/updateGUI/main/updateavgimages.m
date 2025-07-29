function mainhandles = updateavgimages(mainhandles,channel,files,rawdlg)
% Update avg. image of all frames and frames based on donor and acceptor
% excitation, respectively
%
%    Input:
%     mainhandles   - handles structure of the main window (sms)
%     channel       - 'donor', 'acceptor', 'global', 'all'
%     files         - files to calculate
%     rawdlg        - 0/1 show dialog on missing raw data
%
%    Output:
%     mainhandles   - handles structure of the main window
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

if nargin<3 || isempty(files)
    files = get(mainhandles.FilesListbox,'Value'); % Selected movie file
end
if nargin<4 || isempty(rawdlg)
    rawdlg = 1;
end

if isempty(files)
    return
end

%% Calculate avg. images

for i = 1:length(files)
    file = files(i);
    %     imageData = single( mainhandles.data(file).imageData );
    imageData = mainhandles.data(file).imageData;
    
    % Check if raw movie has been deleted
    if isempty(mainhandles.data(file).imageData)
        if rawdlg
            
            % Reload dialog
            choice = myquestdlg(...
                sprintf('The raw movie has been deleted for this file (%s). Do you want to reload the movie from file?',mainhandles.data(file).name),...
                'Movie deleted',...
                'Yes','No','Cancel','No');
            
            if strcmpi(choice,'Yes')
                mainhandles = reloadMovieCallback(mainhandles);
                
            elseif strcmpi(choice,'No')
                continue
                
            elseif isempty(choice) || strcmpi(choice,'Cancel')
                return
            end
            
        else
            continue
        end
    end
    
    % Don't do anything if its an intensity profile
    if mainhandles.data(file).spot
        img = mean(imageData,3);
        mainhandles.data(file).avgimage = img;
        mainhandles.data(file).avgDimage = img;
        mainhandles.data(file).avgAimage = img;
        continue
    end
    
    % If it's just one frame
    if size(imageData,3)==1
        mainhandles.data(file).avgimage = imageData;
        mainhandles.data(file).avgDimage = imageData;
        mainhandles.data(file).avgAimage = imageData;
        continue
    end
    
    % Movie interval used for the average images [first last] of D/A frames
    x1 = mainhandles.data(file).avgimageFrames(1); % Start frame of averaging
    x2 = mainhandles.data(file).avgimageFrames(2); % End of averaging
    
    % Average of all donor excitation frames
    if (strcmpi(channel,'donor')) || (strcmpi(channel,'all'))
        Dframes = getDframes(); % Frames used
        if ~isempty(Dframes)
            mainhandles.data(file).avgDimage = sum( imageData(:,:,Dframes) ,3)/length(Dframes);
        end
    end
    
    % Average of all acceptor excitation frames
    if strcmpi(channel,'acceptor') || strcmpi(channel,'all')
        if mainhandles.settings.excitation.alex
            Aframes = getALEXframes(mainhandles.settings.averaging.avgAchoice); % Frames used
            if ~isempty(Aframes)
                mainhandles.data(file).avgAimage = sum( imageData(:,:,Aframes) ,3)/length(Aframes);
            end
        else
            mainhandles.data(file).avgAimage = mainhandles.data(file).avgDimage;
        end
    end
    
    % Average (raw/global) image
    if strcmpi(channel,'global') || strcmpi(channel,'all')
        
        % Frames
        x1 = mainhandles.data(file).avgimageFramesRaw(1); % Start frame of averaging
        x2 = mainhandles.data(file).avgimageFramesRaw(2); % End of averaging
        
        if mainhandles.settings.excitation.alex
            
            % Avg.
            rawframes = getALEXframes(mainhandles.settings.averaging.avgrawchoice); % Frames used
            if ~isempty(rawframes)
                mainhandles.data(file).avgimage = sum( imageData(:,:,rawframes) ,3)/length(rawframes);
            end
            
        else
            
            if strcmpi(channel,'global')
                % Calculate D image
                Dframes = getDframes(); % Frames used
                if ~isempty(Dframes)
                    mainhandles.data(file).avgimage = sum( imageData(:,:,Dframes) ,3)/length(Dframes);
                end
                
            else
                mainhandles.data(file).avgimage =  mainhandles.data(file).avgDimage; % Avg. image
            end
        end
    end
    
    % Reset raw peaks, this will force a new peak finder run
    mainhandles.data(file).DpeaksRaw = [];
    mainhandles.data(file).ApeaksRaw = [];
    
end

% Update handles structure
updatemainhandles(mainhandles)

%% Nested

    function frames = getALEXframes(choice)
        % Get D or A excitation frame indices in ALEX
        if strcmpi(choice,'all')
            
            % Use all excitation frames
            frames = 1:size(imageData,3);
            frames(frames<x1) = [];
            frames(frames>x2) = [];
            
        elseif strcmpi(choice,'Dexc')
            
            % Use D excitation frames
            if strcmpi(channel,'all')
                frames = Dframes; % Dframes has already been calculated
            else
                frames = getDframes();
            end
            
        elseif strcmpi(choice,'Aexc')
            
            % Use A excitation frames (ALEX choice)
            frames = getAframes();
            if isempty(frames)
                frames = getDframes();
            end
            
        end
    end

    function frames = getDframes()
        frames = find(mainhandles.data(file).excorder=='D'); % Indices of all donor exc frames
        frames(frames<x1) = [];
        frames(frames>x2) = [];
    end

    function frames = getAframes()
        frames = find(mainhandles.data(file).excorder=='A');
        frames(frames<x1) = [];
        frames(frames>x2) = [];
    end

end