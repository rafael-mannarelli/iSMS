function mainhandles = reloadMovies(mainhandle,files,openFileDlg)
% Reloads raw movie data into handles structure
%
%     Input:
%      mainhandle   - handle to the main figure window (sms)
%      filechoices  - files reload [file1 file2...]
%      openFileDlg  - binary parameter determining whether to show a dialog
%                     for specifying the files to reload
%
%     Output:
%      mainhandles  - handles structure of the main window
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

% Get handles structure
mainhandles = guidata(mainhandle);
if isempty(mainhandles.data) || (isempty(files) && ~openFileDlg)
    % If there are no files
    return
end

%% Open a file selection modal dialog

if openFileDlg
    
    %--------- Prepare dialog box ---------%
    name = 'Reload raw movies';
    
    % Make files listbox string
    fileslist = {};
    for i = 1:length(mainhandles.data)
        filestring = sprintf('%i) %s',i,mainhandles.data(i).name);
        if ~isempty(mainhandles.data(i).imageData) && isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
            filestring = sprintf('<HTML>%s <b>(raw)</b></HTML>', filestring); % Change string to HTML code
        elseif ~isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
            filestring = sprintf('<HTML>%s <b>(raw,ROI)</b></HTML>',filestring);
        elseif ~isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && ~isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
            filestring = sprintf('<HTML>%s <b>(raw,ROI,drift)</b></HTML>',filestring);
        elseif isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
            filestring = sprintf('<HTML>%s <b>(ROI)</b></HTML>',filestring);
        elseif isempty(mainhandles.data(i).imageData) && ~isempty(mainhandles.data(i).DD_ROImovie) && ~isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
            filestring = sprintf('<HTML>%s <b>(ROI,drift)</b></HTML>',filestring);
        elseif isempty(mainhandles.data(i).imageData) && isempty(mainhandles.data(i).DD_ROImovie) && ~isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
            filestring = sprintf('<HTML>%s <b>(drift)</b></HTML>',filestring);
        elseif isempty(mainhandles.data(i).imageData) && isempty(mainhandles.data(i).DD_ROImovie) && isempty(mainhandles.data(i).DD_ROImovieDriftCorr)
            filestring = sprintf('<HTML>%s <b>(empty)</b></HTML>',filestring);
        end
        
        fileslist{i,1} = filestring;
    end
    
    % Make prompt structure
    prompt = {...
        'Select files (brackets denote currently loaded data):   ' 'filechoices';...
        'Force opening a file-path selection dialog   ' 'forceDlg';...
        'Reload only ROI-movies (check if ROI positions are not going to be changed) ' 'reloadROIonly'};
    
    % formats
    formats = struct('type', {}, 'style', {}, 'items', {}, ...
        'format', {}, 'limits', {}, 'size', {});
    formats(1,1).type = 'list';
    formats(1,1).style = 'listbox';
    formats(1,1).items = fileslist;
    formats(1,1).size = [500 300];
    formats(1,1).limits = [0 2]; % multi-select
    formats(3,1).type   = 'check';
    formats(4,1).type = 'check';
    
    % Make DefAns structure
    DefAns.filechoices = get(mainhandles.FilesListbox,'Value');
    DefAns.forceDlg = 0;
    DefAns.reloadROIonly = mainhandles.settings.import.reloadROIonly;
    
    %-------- Open dialog box -------%
    [answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
    if cancelled==1
        return
    end
    files = answer.filechoices;
    forceDlg = answer.forceDlg;
    mainhandles = savesettingasDefault(mainhandles,'import','reloadROIonly',answer.reloadROIonly);
    
else
    % Force filepath dialog
    forceDlg = 0;
end

% Turn on waitbar
if length(files)==1
    hWaitbar = mywaitbar(0,'Loading movie. Please wait...','name','iSMS');
else
    hWaitbar = mywaitbar(0,sprintf('Loading %i movies. Please wait...',length(files)),'name','iSMS');
end
setFigOnTop % Sets the waitbar so that it is always in front

% Supported file formats
[fileformats, imgformats, movformats, bioformats, specialformats] = supportedformatsImport();

%% Load all selected movie files

% Initialize
newdir = [];
asknewdir = 1;

% Save current dir to restore after loading
currdir = pwd;

for i = 1:length(files)
    
    % Selected file
    file = files(i);
    filepaths = mainhandles.data(file).filepath; % Previously saved movie path
    if isempty(filepaths)
        filepaths = {pwd};
    end
    
    % Expected size
    avgimgSz = size(mainhandles.data(file).avgimage);
    
    ok = 0;
    while ~ok
        
        % Get raw file data
        imageDataTot = getimageDataTot();
        if isempty(imageDataTot)
            try delete(hWaitbar), end
            return
        end

        % If dimensions are swapped, rotate to match stored orientation
        if ~isequal(size(imageDataTot(:,:,1)),avgimgSz(1:2)) && ...
                isequal(size(imageDataTot(:,:,1)),avgimgSz([2 1]))
            imageDataTot = permute(imageDataTot,[2 1 3]);
        end

        % Check dimensions
        if ~isequal(size(imageDataTot(:,:,1)),avgimgSz(1:2))
            
            % Dialog
            answer = myquestdlg('The image dimensions of the selected movie does match the selected file. Are you sure the filepath is the correct?',...
                'OBS',...
                ' Yes, continue at own risk ',' No, select new file ',' Cancel ', ' No, select new file ');
            
            % Answer
            if isempty(answer) || strcmpi(answer,' Cancel ')
                try delete(hWaitbar), end
                return
                
            elseif strcmpi(answer,' No, select new file ')
                continue
            end
        end
        
        % Now is ok to continue
        ok = 1;
    end
    
    %------------- Load data into handles structure -----------%
    mainhandles.data(file).filepath = filepaths;
    mainhandles.data(file).imageData = imageDataTot;%= storeMovie(handles,data,filename,filepath,0);
    %----------------------------------------------------------%
    
    % Save ROI movie
    [mainhandles,MBerror] = saveROImovies(mainhandles,file);
    if MBerror
        mymsgbox('You are out of memory. You will have to load fewer raw movie files at a time. After analysis, raw movie data can be deleted from the Memory menu.',...
            'Need more RAM')
        return
    end
    
    % Delete raw data
    if mainhandles.settings.import.reloadROIonly
        mainhandles.data(file).imageData = [];
    end
    
    % Live-update fileslist
    updatemainhandles(mainhandles)
    updatefileslist(mainhandles.figure1)
    
    % Update waitbar
    waitbar(i/length(files))
    
end

% Return to previous dir
try cd(currdir), end

%% Update

% Update GUI
updateframeslist(mainhandles)

try delete(hWaitbar), end % Delete the waitbar

%% Nested

    function imageDataTot = getimageDataTot()
        
        % Initialize
        imageDataTot = [];
        cutmerged = 0;
        
        nFilepaths = numel(filepaths);
        for f = 1:nFilepaths
            
            % Load all files (>1 if merged movie)
            filepath = filepaths{f};
            
            % Apply new directory
            if ~isempty(newdir) && exist(newdir,'dir')
                [pathstr, name, ext] = fileparts(filepath); % Break to determine suffix
                filepath = fullfile(newdir,[name ext]);
            end
            
            % R2014b fix for reading data on server path
            try cd(fileparts(filepath)), end
            
            if forceDlg || exist(filepath)~=2
                
                % Open dialog
                if nFilepaths>1
                    [filename, dir, chose] = uigetfile3(mainhandles,'data',fileformats,sprintf('Locate file %i of: %s',f,mainhandles.data(file).name),'','off');
                else
                    [filename, dir, chose] = uigetfile3(mainhandles,'data',fileformats,sprintf('Locate: %s',mainhandles.data(file).name),'','off');
                end
                if chose == 0 % If cancel button was pressed
                    return
                end
                filepath = fullfile(dir,filename);
                
                % Use selected directory for all files?
                if (length(files)>1 || nFilepaths>1) && asknewdir
                    
                    % Question dialog
                    choice = myquestdlg('Load data from this directory for all selected files?', 'Path',...
                        ' Yes, apply to all ', ' No, specify individual paths ', ' Cancel ', ' Yes, apply to all ');
                    
                    if strcmpi(choice, ' Yes, apply to all ')
                        newdir = dir;
                    elseif strcmpi(choice, ' Cancel ')
                        return
                    end
                    
                    % Don't ask again
                    asknewdir = 0;
                end
                
            else
                % If stored filepath still exists
                [pathstr, name, ext] = fileparts(filepath); % Break to determine suffix
                filename = [name ext];
                
            end
            
            % Load data depending on filetype:
            [imageData, back] = loadfiles(mainhandles, filepath);
            imageData = flipdata(imageData, filename);
            if ~isempty(back)
                back = flipdata(back, filename);
            end
            
            if isempty(imageData)
                continue
            end
            
            % Check memory available before loading movie
            if ~ismac && i<length(files)
                [userview systemview] = memory;
                MBall = userview.MemAvailableAllArrays*9.53674316*10^-7; % MB available for all arrays
                MBmovie = whos('imageData');
                MBmovie = MBmovie.bytes*9.53674316*10^-7; % MB of movie
                
                if MBall<=MBmovie
                    % Insufficient RAM
                    message = sprintf('%s %i. movie. %s\n\n%s %s',...
                        'Not enough memory to load the',i+1,...
                        'You have to load and analyse fewer movies at a time.',...
                        'Note that after analysing a movie file, memory can be released for new movies by deleting raw data from the RAM.',...
                        'This is achieved from the Memory menu.');
                    mymsgbox(message,'More RAM needed');
                    set(mainhandles.mboard,'String',message)
                    
                    try delete(hWaitbar), end
                    return
                end
            end
            
            % Subtract camera background
            if ~isempty(mainhandles.data(file).cameraBackground)
                
                cameraBackgrounds = mainhandles.data(file).cameraBackground;
                if isequal(size(cameraBackgrounds,1),nFilepaths)
                    
                    % The same number of backgrounds as filepaths must be registered
                    cameraBackground = cameraBackgrounds{f,1}; % Registered camera background of file f in movie i
                    if isequal(size(cameraBackground),[1 1]) && cameraBackground~=0
                        
                        % If background is a constant offset value
                        imageData = imageData-cameraBackground; % Subtract offset from movie
                        
                    elseif isequal(size(cameraBackground),size(imageData(:,:,1)))
                        
                        % If background is an image
                        for j = 1:size(imageData,3) % Subtract background image from all frames
                            imageData(:,:,j) = imageData(:,:,j)-cameraBackground;
                        end
                    end
                    
                end
            end
            
            % Redo history of geometry transformations to movie data
            if ~isempty(mainhandles.data(file).geoTransformations)
                
                geoTransformations = mainhandles.data(file).geoTransformations;
                if isequal(size(geoTransformations,2),nFilepaths)
                    
                    % The same number of geoTransformations as filepaths must be registered
                    Ts = geoTransformations{1,f}; % Registered geometry transformations of file f in movie i
                    for j = 1:size(Ts,1) % Perform transformation in chronological order
                        T = Ts{j,1}; % Transformation j of file f in movie i
                        
                        if strcmpi(T,'rotate')
                            % Rotate movie
                            imageData = permute(imageData,[2 1 3]);
                            if ~isempty(back)
                                % Rotate background
                                back = permute(back,[2 1 3]);
                            end
                            
                        elseif strcmpi(T,'flipud')
                            % Flip movie vertically
                            for k = 1:size(imageData,3) % Perform operation on all frames
                                imageData(:,:,k) = fliplr(imageData(:,:,k));
                            end
                            if ~isempty(back)
                                % Flip background
                                for k = 1:size(back,3) % Perform operation on all frames
                                    back(:,:,k) = fliplr(back(:,:,k));
                                end
                            end
                            
                        elseif strcmpi(T,'fliplr')
                            % Flip movie horizontally
                            for k = 1:size(imageData,3) % Perform operation on all frames
                                imageData(:,:,k) = flipud(imageData(:,:,k));
                            end
                            if ~isempty(back)
                                % Flip background
                                for k = 1:size(back,3) % Perform operation on all frames
                                    back(:,:,k) = flipud(back(:,:,k));
                                end
                            end
                            
                        elseif strcmpi(T,'cuttime')
                            % Remove some frames
                            frames = Ts{j,2};
                            imageData = imageData(:,:,frames);

                        elseif strcmpi(T,'cuttimeMerged')
                            % Remove some frames
                            cutmerged = 1;
                            cutmergedframes = Ts{j,2};
                        end
                    end
                end
            end
            
            % Convert image data into unsigned integers 16-bit, uint16
            imageData = uint16(imageData);
            
            % Merge files
            if f>1 && isequal(size(imageDataTot(:,:,1)),size(imageData(:,:,1))) % If merged file
                imageDataTot =  cat(3, imageDataTot, imageData);
            elseif f>1
                mymsgbox('Selected movies must have equal image dimensions.')
                imageDataTot = [];
                break
            else
                imageDataTot = imageData;
            end
            
        end
        
        % Now cut merged movie
        if cutmerged
            imageDataTot = imageDataTot(:,:,cutmergedframes);
        end
        
    end

    function imageData = flipdata(imageData, filename)
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

end
