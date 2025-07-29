function mainhandles = deleteframesCallback(mainhandles)
% Callback for deleting frames in the main window
%
%     Input:
%      mainhandles   - handles structure of the main window
%
%     Output:
%      mainhandles   - ..
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
if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end
file = get(mainhandles.FilesListbox,'Value'); % Selected movie file

% Before opening dialog box, open a guiding plot of the relative intensities
windowhandle = plotmovietraces(mainhandles,'all');

%% Prepare dialog box

movLength = length(mainhandles.data(file).excorder);
if mainhandles.settings.excitation.alex
    movLength = movLength/2;
    Text = sprintf('Keep frame interval (currently %ix2 frames in total):  ',movLength);
else
    Text = sprintf('Keep frame interval (currently %i frames in total):  ',movLength);
end
prompt = {Text '';'' 'first';'' 'last'};
name = 'Cut movie';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Global setting
formats(2,1).type   = 'text';
formats(2,2).type   = 'edit';
formats(2,2).size   = 50;
formats(2,2).format = 'integer';
formats(2,3).type   = 'edit';
formats(2,3).size   = 50;
formats(2,3).format = 'integer';

% Default choices
DefAns.first = 1;
DefAns.last = movLength;

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
try delete(windowhandle), end % Close opened figure
if cancelled == 1
    return
end

% Answer
temp = sort([answer.first answer.last]); % In case a lower value was set as last frame than first frame, flip the values
first = temp(1); % Choice of first frame
last = temp(2); % Choice of last frame

%% Check choices

if first < 1 % If first was a negative number, set it to 1
    first = 1;
end
if last < 1 % If last was a negative number, set it to 1
    last = 1;
end
if last > movLength % If last is higher than no. of frames, set it to no. of frames
    last = movLength;
end
if first > movLength % If first is higher than no. of frames, set it to no. of frames
    first = movLength;
end
if isequal([first last],[DefAns.first DefAns.last]) % If no changes were made, return
    return
end

% Make sure? dialogue
n = movLength-(last-first+1);
if mainhandles.settings.excitation.alex
    mess = sprintf('This will delete %ix2 frames. You can''t restore the deleted frames later - unless reloading the movie.', n);
else
    mess = sprintf('This will delete %i frames. You can''t restore the deleted frames later - unless reloading the movie.', n);
end

% Check analysed traces
dynamicPairs = getPairs(mainhandles.figure1,'dynamics');
if ~isempty(dynamicPairs)
    mess = sprintf('%s\n\nYou will also reset all analysed dynamic traces.',mess);
end

% Dialog
choice = myquestdlg(mess, ... % Message
    'Are you sure?', ... % Title
    'OK','Cancel', ... % Choice buttons
    'OK'); % Default

% Return of cancel was pressed
if isempty(choice) || strcmp(choice,'Cancel')
    return
end

% Waitbar
hWaitbar = mywaitbar(0,'Deleting frames...','name','iSMS');

size1 = whos('mainhandles'); % For calculating freed RAM

%% Put new choice in handles.data structure

% Intervals to keep
if mainhandles.settings.excitation.alex
    rawInterval = first*2-1:last*2;
else
    rawInterval = first:last;
end
Iinterval = first:last;

% Cut time vector
if length(mainhandles.data(file).time)>max(rawInterval)
    mainhandles.data(file).time = mainhandles.data(file).time(rawInterval);
end
    
% Cut intensity traces
exc = mainhandles.data(file).excorder;
for pair = 1:length(mainhandles.data(file).FRETpairs)
    
    % Cut traces
    mainhandles = cutTrace(mainhandles,'DDtrace');
    mainhandles = cutTrace(mainhandles,'DDback');
    mainhandles = cutTrace(mainhandles,'ADtrace');
    mainhandles = cutTrace(mainhandles,'ADback');
    mainhandles = cutTrace(mainhandles,'ADtraceCorr');
    mainhandles = cutTrace(mainhandles,'Etrace');
    mainhandles = cutTrace(mainhandles,'Strace');
    mainhandles = cutTrace(mainhandles,'PRtrace');
    mainhandles = cutTrace(mainhandles,'StraceCorr');
    mainhandles = cutTrace(mainhandles,'AAtrace');
    mainhandles = cutTrace(mainhandles,'AAback');

    % Cut Gaussian trace
    mainhandles = cutGaussianTrace(mainhandles,'DDGaussianTrace');
    mainhandles = cutGaussianTrace(mainhandles,'ADGaussianTrace');
    mainhandles = cutGaussianTrace(mainhandles,'AAGaussianTrace');
    
    % Check specified bleaching and blinking times
    mainhandles = correctBleaching(mainhandles,'DbleachingTime');
    mainhandles = correctBleaching(mainhandles,'AbleachingTime');
    mainhandles = correctBlinking(mainhandles,'DblinkingInterval');
    mainhandles = correctBlinking(mainhandles,'AblinkingInterval');
    mainhandles = correctBlinking(mainhandles,'timeInterval');
    
    % Reset molecule images
    mainhandles = checkImage(mainhandles,'DDavgImageInterval','DD_avgimage');
    mainhandles = checkImage(mainhandles,'ADavgImageInterval','AD_avgimage');
    mainhandles = checkImage(mainhandles,'AAavgImageInterval','AA_avgimage');
        
    % Remove information on dynamics
    mainhandles = deleteIdealizedTrace(mainhandles,[file pair]);

end

% Update handles
updatemainhandles(mainhandles)

% Reset correction factor traces
mainhandles = calculateCorrectionFactors(mainhandles.figure1,getPairs(mainhandles.figure1,'file',file),'all',1);

% Excorder
mainhandles.data(file).excorder = mainhandles.data(file).excorder(rawInterval);

% Delete raw data
if ~isempty(mainhandles.data(file).imageData)
    mainhandles.data(file).imageData = mainhandles.data(file).imageData(:,:,rawInterval); % Times 2 because choice was set for D/A excitation frames (= ½ of total frames)
    mainhandles = saveROImovies(mainhandles,file); % Cuts ROI movies
    
    updatemainhandles(mainhandles)
    mainhandles = updateavgimages(mainhandles,'all',file);
    mainhandles = updaterawimage(mainhandles);

else
    % Delete existing ROI data
    mainhandles.data(file).DD_ROImovie = [];
    mainhandles.data(file).AD_ROImovie = [];
    mainhandles.data(file).AA_ROImovie = [];
end

% Store cutting for reloading raw data
mainhandles = storeGeoTransformAfterCut(mainhandles,file,rawInterval);

% Update avg. image if new frame interval changes the avg. image
mainhandles = checkavgFrames(mainhandles,'avgimageFrames');
mainhandles = checkavgFrames(mainhandles,'avgimageFramesRaw');

%% Update GUI

updatemainhandles(mainhandles)
mainhandles = createTimeVector(mainhandles,file);

% Update
updatemainhandles(mainhandles)
mainhandles = updateframesliderHandle(mainhandles);
mainhandles = updatecontrastSliders(mainhandles);
mainhandles = updateROIhandles(mainhandles);
mainhandles = updateROIimage(mainhandles);
mainhandles = updatepeakplot(mainhandles,'both');
updateframeslist(mainhandles)

% Close other windows
mainhandles = closeWindows(mainhandles,'all');

% Update memory statusbar
mainhandles = updateMemorybar(mainhandles);

% Show energy freed
size2 = whos('mainhandles');
saved = (size1.bytes-size2.bytes)*9.53674316*10^-7; % Memory difference before and after deletion /MB
set(mainhandles.mboard,'String',sprintf('%.1f MB of memory was released.',saved))

% Waitbar
try delete(hWaitbar), end

%% Nested

    function mainhandles = cutTrace(mainhandles,fname)
        if max(Iinterval)>length(mainhandles.data(file).FRETpairs(pair).(fname))
            return
        end
        
        mainhandles.data(file).FRETpairs(pair).(fname) = mainhandles.data(file).FRETpairs(pair).(fname)(Iinterval);        
    end

    function mainhandles = cutGaussianTrace(mainhandles,fname)
        if max(Iinterval)>size(mainhandles.data(file).FRETpairs(pair).(fname),1)
            return
        end
        
        mainhandles.data(file).FRETpairs(pair).(fname) = mainhandles.data(file).FRETpairs(pair).(fname)(Iinterval,:);
    end

    function mainhandles = correctBleaching(mainhandles,field)
        if mainhandles.data(file).FRETpairs(pair).(field)>last
            mainhandles.data(file).FRETpairs(pair).(field) = [];
        end
    end

    function mainhandles = correctBlinking(mainhandles,field)
        % Check blinking
        for j = size(mainhandles.data(file).FRETpairs(pair).(field),1):-1:1
            if max( mainhandles.data(file).FRETpairs(pair).(field)(j,:) )>last
                mainhandles.data(file).FRETpairs(pair).(field)(j,:) = [];
            end
        end
    end

    function mainhandles = checkImage(mainhandles,field1,field2)
        if isempty(mainhandles.data(file).FRETpairs(pair).(field1))
            return
        end
        
        % Reset molecule image
        if max(mainhandles.data(file).FRETpairs(pair).(field1))>last
            mainhandles.data(file).FRETpairs(pair).(field1) = [];
            mainhandles.data(file).FRETpairs(pair).(field2) = [];
        end
    end

    function mainhandles = checkavgFrames(mainhandles,field)
        if mainhandles.data(file).(field)(1) < first
            mainhandles.data(file).(field)(1) = 1;
        end
        if mainhandles.data(file).(field)(2) > last
            mainhandles.data(file).(field)(2) = length(mainhandles.data(file).excorder);
        end
    end

end
