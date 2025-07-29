function [mainhandles, cancelled] = loadDataCallback(mainhandles, spot, file, ShowWaitbar)
% Callback for loading data
%
%    Input:
%     mainhandles    - handles structure of the main window
%     spot           - 0/1 whether loaded file is a spot profile
%     file           - file fullfilepath
%     ShowWaitbar    - 0/1
%
%    Output:
%     mainhandles    - handles structure of the main window
%     cancelled      - 0/1 whether used chose to cancel
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

mainhandles = turnofftoggles(mainhandles,'all'); % Turn off all interactive toggle buttons in the toolbar
cancelled = 0;

% 'spot' determines whether the load function was called by the load
% spot-profile or by the load data file.
if nargin<2 || isempty(spot)
    spot = 0; % Called by load-data file
end
if nargin<3 || isempty(file)
    file = [];
end
if nargin<4
    ShowWaitbar = 1;
end

% Supported file formats
[fileformats, imgformats, movformats, bioformats, specialformats] = supportedformatsImport();

% File path
if isempty(file)
    
    % Open file selection dialog
    [filenames, dir, chose] = uigetfile3(mainhandles,'data',fileformats,'Load files','','on');
    if chose == 0 % If cancel button was pressed
        return
    end
    
    % Update recent files list, yes
    updateRecent = 1;
    
else
    % Update recent files list, no
    updateRecent = 0;
    
    % Directory and name of file specified as input argument
    [dir,name,ext] = fileparts(file);
    filenames = [name ext];
    
end

% Number of files
if iscell(filenames) % If multiple files are selected
    nfiles = size(filenames,2);
    
else
    % If only one file is selected
    nfiles = 1;
    filenames = {filenames};
end

% For comments
offsetComment = [];

%% If first time data is loaded, prompt for some basic settings

[mainhandles cancelled] = initializeFirstrun(mainhandles);
if cancelled
    return
end

%% Turn on waitbar
if ShowWaitbar
    
    if nfiles==1
        hWaitbar = mywaitbar(0,'Loading 1 movie. Please wait...','name','iSMS');
    else
        hWaitbar = mywaitbar(0,sprintf('Loading %i movies. Please wait...',nfiles),'name','iSMS');
    end
    try setFigOnTop([]), end % Sets the waitbar so that it is always in front
    
end

%% Load data file

for i = 1:nfiles
    filename = filenames{i};
    filepath = fullfile(dir,filename);
    
    % Load data depending on filetype:
    [imageData, back] = loadfiles(mainhandles, filepath);
    
    % Continue if data is empty
    if isempty(imageData)
        continue
    end
    
    % Subtract camera background
    [imageData, cameraBackground] = subtractBackground(imageData);
    
    % Dim 1-2) The program was adapted for sif files which has inverted
    % rows and columns compared to most other formats. Dim 3-4) Set frames
    % as 3rd dimensions. This is opposed to MATLAB's internal frame
    % dimension being the 4th
    imageData = flipdata(imageData,filename);
    cameraBackground = flipdata(cameraBackground,filename);
    
    % Convert image data into unsigned 16-bit (2-byte) integers of class
    % uint16. This is done to minimize memory usage. If there are any
    % negative value they will be set to 0. If there are any values >65535
    % they will be set to 65535.
    if ~isa(imageData,'uint16')
        imageData = uint16(imageData);
    end
    
    % Make separate file for each color frame
    for c = 1:size(imageData,4)
        
        % Usually there is only one channel (intensity)
        img = imageData(:,:,:,c);
        
        % If default setting is to rotate or flip the movie, do it now
        [img, back, geoTransformations] = transformData(img, back);
        
        % Initialize data structure
        data.imageData = img;
        
        % Name
        if size(imageData,4)==1
            % Regular intensity data
            name = filename;
        elseif size(imageData,4)==3
            % RGB image is loaded
            cstr = {'Red' 'Green' 'Blue'};
            name = sprintf('%s (%s channel)',filename,cstr{c});
        else
            % More channels
            name = sprintf('%s (channel%i)',filename,c);
        end
        
        %------------- Load data into handles structure -----------%
        mainhandles = storeMovie(mainhandles,data,name,{filepath},spot); % Saves data information to handles structure
        mainhandles.data(end).back = back; % Store background information obtained from sif-reader
        mainhandles.data(end).cameraBackground = cameraBackground; % Store subtracted background so it can be subtracted if reloading the raw movie at a later time
        mainhandles.data(end).geoTransformations = {geoTransformations}; % Store geometrical transformations performed on the raw movie for reloading
        %----------------------------------------------------------%
        
        % Save ROI movie, if FRETpairwindow is open
        if strcmpi(get(mainhandles.Toolbar_FRETpairwindow,'State'),'on')
            [mainhandles,MBerror] = saveROImovies(mainhandles,length(mainhandles.data));
            if MBerror
                mymsgbox('You are out of memory. You will have to load fewer raw movie files at a time. After analysis, raw movie data can be deleted from the Memory menu.',...
                    'Need more RAM');
                return
            end
        end
        
        % Live-update files list
        updatemainhandles(mainhandles)
        updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle)
        
    end
    
    % Update waitbar
    if ShowWaitbar
        waitbar(i/nfiles)
    end
end

%% Save default data structure format to file
% (for software version compatibility)

try 
    % Delete file specific data
    dataTemplate = mainhandles.data(end);
    dataTemplate.back = [];
    dataTemplate.imageData = [];
    dataTemplate.DD_ROImovie = [];
    dataTemplate.AD_ROImovie = [];
    dataTemplate.AA_ROImovie = [];
    dataTemplate.DA_ROImovie = [];
    dataTemplate.avgimageFrames = [];
    dataTemplate.avgimageFramesRaw = [];
    dataTemplate.excorder = [];
    dataTemplate.spot = [];
    dataTemplate.Droi = [];
    dataTemplate.Aroi = [];
    dataTemplate.avgimage = [];
    dataTemplate.avgDimage = [];
    dataTemplate.avgAimage = [];
    dataTemplate.drifting.drift = [];
    dataTemplate.name = [];
    dataTemplate.spotMeasured = [];
    dataTemplate.rawcontrast = [];
    dataTemplate.redROIcontrast = [];
    dataTemplate.greenROIcontrast = [];
    dataTemplate.contrastLims = [];
    dataTemplate.acceptors(:) = [];
    dataTemplate.donors(:) = [];
    dataTemplate.rawmovieLength = [];
    dataTemplate.time = [];
end

try
    % Save file with settings structure
    dataTemplateFile = fullfile(mainhandles.settingsdir,'data.template');
    save(dataTemplateFile,'dataTemplate');
catch err
    fprintf('Error when trying to save default data template:\n\n %s',err.message)
end

%% Update GUI and finish

% Update mainhandles structure
updatemainhandles(mainhandles)

% Update listboxes
set(mainhandles.FilesListbox,'Value',length(mainhandles.data))
set(mainhandles.FramesListbox,'Value',1)
updatefileslist(mainhandles.figure1,mainhandles.histogramwindowHandle)

% Imitate click in listbox
mainhandles = filesListboxCallback(mainhandles.FilesListbox);

% Comment in message board
if ~isempty(offsetComment)
    set(mainhandles.mboard,'String',offsetComment)
end

%% Check memory:

if ~ismac
    [userview systemview] = memory;
    MB = userview.MemAvailableAllArrays*9.53674316*10^-7;
    if MB<1000
        set(mainhandles.mboard,'String',sprintf(...
            '%s\n%s %.0f %s\n%s',...
            'Warning: More RAM needed!',...
            'There is currently only',MB,'MB of memory available for iSMS.',...
            'You may experience slowness and other memory-related problems if not deleting some raw data.'))
    end
end

% Save recent files list
if updateRecent
    updateRecentFiles(mainhandles, dir, filenames, 'movie');
end

% Delete waitbar
try delete(hWaitbar), end

%% Nested

    function [imageData, cameraBackground] = subtractBackground(imageData)
        % Initialize
        offset = [];
        cameraBackground = {};
        
        % Subtract camera background
        if mainhandles.settings.background.cameraBackgroundChoice ~= 5 % If camera background is to be subtracted
            if mainhandles.settings.background.cameraBackgroundChoice ==  4 % Subtracting a user-defined off-set value
                offset = mainhandles.settings.background.cameraOffset;
                
            elseif ~isempty(back)
                
                % Use stored background image
                movsize = size(imageData); % Frame size of movie data
                backsize = size(back); % Frame size of background image
                if isequal(backsize,movsize(1:2))
                    if mainhandles.settings.background.cameraBackgroundChoice == 1 
                        
                        % Subtract raw background image from each frame
                        for j = 1:size(imageData,3)
                            for jj = 1:size(imageData,4)
                                imageData(:,:,j,jj) = imageData(:,:,j,jj)-back;
                            end
                        end
                        cameraBackground = {back}; % Save subtracted background
                        
                    elseif mainhandles.settings.background.cameraBackgroundChoice == 2 
                        
                        % Subtract smoothened background image from each frame
                        if mainhandles.settings.background.smthKernel==1 % Kernel size to be used
                            s = 3; % Kernel width
                        elseif mainhandles.settings.background.smthKernel==2
                            s = 5; % Kernel width
                        elseif mainhandles.settings.background.smthKernel==3
                            s = 7; % Kernel width
                        elseif mainhandles.settings.background.smthKernel==4
                            s = 9; % Kernel width
                        elseif mainhandles.settings.background.smthKernel==5
                            s = 15; % Kernel width
                        end
                        
                        % Filter using specified kernel
                        h = 1/s^2*ones(s); % Kernel
                        temp = uint16( filter2(h,back,'valid') ); % Filtered image in valid region
                        back(ceil(s/2):end-floor(s/2),ceil(s/2):end-floor(s/2)) = temp; % Insert filtered region into full image
                        
                        % Subtract smoothened image
                        for j = 1:size(imageData,3)
                            for jj = 1:size(imageData,4)
                                imageData(:,:,j,jj) = imageData(:,:,j,jj)-back;
                            end
                        end
                        cameraBackground = {back}; % Save subtracted background
                        
                    elseif mainhandles.settings.background.cameraBackgroundChoice == 3 % Subtract the averaged background image value
                        offset = mean(back(:));
                    end
                end
            end
        end
        
        % Subtract constant offset value
        if ~isempty(offset) && offset~=0
            ok = 1;
            if mainhandles.settings.background.checkOffset 
                % Check if offset value is larger than 50% of the pixels

                if length(find(imageData(:)<offset)) >= numel(imageData)/2
                    choice = myquestdlg(sprintf('%s %.1f %s (%s). %s\n\n%s',...
                        'The camera background offset value of',...
                        offset,...
                        'counts exceeds more than 50% of the pixels in ',...
                        filename,...
                        'Are you sure you want to subtract the camera background?',...
                        'You can set the camera background settings under Settings->Camera Background.'),'Suspicious camera background',...
                        'Yes', 'No', 'No');
                    if strcmpi(choice,'No')
                        ok = 0;
                    end
                end
                
            end
            
            if ok 
                % Subtract offset from movie
                imageData = imageData-offset;
                cameraBackground = {offset};
            end
        end
        
    end

    function imageData = flipdata(imageData,filename)
        % Flip and rotate data that is not in sif format
        if isempty(imageData)
            return
        end
        
        if ~strcmpi(filename(end-2:end),'sif') && size(imageData,4)>1
            
            % Frames in 4th dimension
            for frame = 1:size(imageData,4)
                for ch = 1:size(imageData,3)
                    imageData(:,:,ch,frame) = flipud(imageData(:,:,ch,frame));
                end
            end
            imageData = permute(imageData,[2 1 4 3]);
            
        elseif ~strcmpi(filename(end-2:end),'sif') && size(imageData,4)==1
            
            % Frames in 3rd dimension
            for frame = 1:size(imageData,3)
                imageData(:,:,frame) = flipud(imageData(:,:,frame));
            end
            imageData = permute(imageData,[2 1 3 4]);
            
        elseif size(imageData,4)>1
            imageData = permute(imageData,[1 2 4 3]);
        end
        
    end

    function [imageData, back, geoTransformations] = transformData(imageData, back)
        
        geoTransformations = {}; % Save order of geometry transformations performed on the raw movie data
        if mainhandles.settings.view.rotate
            % Rotate 90 deg.
            imageData = permute(imageData,[2 1 3]); % Flip movie
            if ~isempty(back)
                back = permute(back,[2 1 3]); % Flip background
            end
            geoTransformations{end+1,1} = 'rotate'; % Update transformation cell
        end
        
        if mainhandles.settings.view.flipud
            % Flip up down
            for j = 1:size(imageData,3) % Flip movie
                imageData(:,:,j) = fliplr(imageData(:,:,j));
                ok = 1;
            end
            if ~isempty(back) % Flip background
                for j = 1:size(back,3)
                    back(:,:,j) = fliplr(back(:,:,j));
                end
            end
            geoTransformations{end+1,1} = 'flipud'; % Update transformation cell
        end
        
        if mainhandles.settings.view.fliplr
            % Flip left right
            for j = 1:size(imageData,3)
                imageData(:,:,j) = flipud(imageData(:,:,j));  % Flip movie
            end
            if ~isempty(back) % Flip background
                for j = 1:size(back,3)
                    back(:,:,j) = flipud(back(:,:,j)); % Flip background
                end
            end
            geoTransformations{end+1,1} = 'fliplr'; % Update transformation cell
        end
        
    end

end
