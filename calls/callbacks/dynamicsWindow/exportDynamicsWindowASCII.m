function exportDynamicsWindowASCII(dynamicswindowHandles)
% Callback for exporting dynamics traces in the dynamics window
%
%     Input:
%      dynamicswindowHandles   - handles structure of the dynamicswindow
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

mainhandles = getmainhandles(dynamicswindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
elseif isempty(mainhandles.data)
    mymsgbox('There is no loaded data');
    return
end

% File and pair choice
dynamicsPairs = getPairs(dynamicswindowHandles.main, 'Dynamics');
if isempty(dynamicsPairs)
    return
end

%% Update trace plot

selectedPairs = get(dynamicswindowHandles.PairListbox,'Value');
if isempty(selectedPairs)
    mymsgbox('There are no selected FRET pairs');
    return
end
selectedPairs = dynamicsPairs(selectedPairs,:);

% Open save file dialogue
[file, path, chose] = uiputfile3(mainhandles,'results','*.txt','Specify filename prefix','Traces');
if chose == 0
    return
end

%% Start exporting FRET pairs one by one

for i = 1:size(selectedPairs,1)
    filechoice = selectedPairs(i,1);
    pairchoice = selectedPairs(i,2);
    pair = mainhandles.data(filechoice).FRETpairs(pairchoice);
    
    filename = sprintf('%s_%s_pair%i.txt',file(1:end-4),mainhandles.data(filechoice).name,pairchoice);
    datafile = fullfile(path,filename);
    
    % Start writing to file
    fileID = fopen(datafile,'w');
    fprintf(fileID,'Exported by iSMS\n');
    fprintf(fileID,'Date: %s\n',date);
    fprintf(fileID,'Movie filename: %s\n',mainhandles.data(filechoice).name);
    fprintf(fileID,'FRET pair #%i\n',pairchoice);
    
    % Prepare data to export
    raw = mainhandles.data(filechoice).FRETpairs(pairchoice).Etrace;
    fit = mainhandles.data(filechoice).FRETpairs(pairchoice).vbfitE_fit(:,1);
    
    % Write to file
    fprintf(fileID,sprintf('%s\n','   E   '));
    dlmwrite(datafile,raw,'-append','delimiter', '\t','precision','%.4f');
    fprintf(fileID,sprintf('\n\n%s\n','   Fit   '));
    dlmwrite(datafile,fit,'-append','delimiter', '\t','precision','%.4f');
    fclose(fileID);
end

%% Mesage box

mymsgbox(sprintf('Traces from %i FRET-pairs were exported. You may want to view them in Wordpad rather than Notepad.',size(selectedPairs,1)),'Great success!');
