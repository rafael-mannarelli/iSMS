function exportMoleculesCallback(mainhandle, type, defChoice)
% Callback for exporting molecule data to workspace
%
%     Input:
%      mainhandle   - handles structure of the main window
%      type          - 'smd', 'ascii', 'workspace'
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

if nargin<3 || isempty(defChoice)
    defChoice = '';
end

mainhandles = guidata(mainhandle);
alex = mainhandles.settings.excitation.alex;

defVal = 1;

%% Get all pairs

allPairs = getPairs(mainhandle,'all');
if isempty(allPairs)
    mymsgbox('There are no molecules in the current session.')
    return
end

%% Prepare molecule choice list

% Choices
choicetypes = 1; % Type of choice: 1) all. 2) A file. 3) A group. 4) Currently plotted.

% Choice 1:
choices = {sprintf('All molecules (%i)',size(allPairs,1))};

% Choice 2:
if length(mainhandles.data)>1
    for i = 1:length(mainhandles.data)
        choices{end+1} = sprintf('All molecules (%i) in file: %i) %s',length(mainhandles.data(i).FRETpairs), i,mainhandles.data(i).name);
    end
    choicetypes = [choicetypes; 2*ones(length(mainhandles.data),1)];
end

% Choice 3:
if length(mainhandles.groups)>1
    for i = 1:length(mainhandles.groups)
        groupPairs = getPairs(mainhandle, 'Group', mainhandles.groups(i).name);
        choices{end+1} = sprintf('All molecules (%i) in group: %i) %s',size(groupPairs,1), i,mainhandles.groups(i).name);
    end
    choicetypes = [choicetypes; 3*ones(length(mainhandles.groups),1)];
end

% Choice 4:
plottedPairs = getPairs(mainhandle,'plotted');
if ~isempty(plottedPairs)
    choices{end+1} = sprintf('All molecules (%i) in the current E-S plot',size(plottedPairs,1));
    choicetypes = [choicetypes; 4];
    if strcmpi(defChoice,'plotted')
        defVal = length(choices);
    end
end

% Choice 5:
selectedPairs = getPairs(mainhandle,'selected');
if ~isempty(selectedPairs)
    choices{end+1} = sprintf('All molecules (%i) selected in the FRET-pair traces window',size(selectedPairs,1));
    choicetypes = [choicetypes; 5];
    if strcmpi(defChoice,'selected')
        defVal = length(choices);
    end
end

% Choice 6:
hmmPairs = getPairs(mainhandle,'Dynamics');
if ~isempty(hmmPairs)
    choices{end+1} = sprintf('All molecules (%i) analysed by HMM/vbFRET',size(hmmPairs,1));
    choicetypes = [choicetypes; 6];
    if strcmpi(defChoice,'dynamics')
        defVal = length(choices);
    end
end

% Choice 7:
selectedHMMPairs = getPairs(mainhandle,'dynamicsSelected');
if ~isempty(selectedHMMPairs)
    choices{end+1} = sprintf('All molecules (%i) selected in HMM/dynamics window',size(selectedHMMPairs,1));
    choicetypes = [choicetypes; 7];
    if strcmpi(defChoice,'dynamicsSelected')
        defVal = length(choices);
    end
end

% Choice 8:
selectedCorrPairs = getPairs(mainhandle,'correctionSelected');
if ~isempty(selectedCorrPairs)
    choices{end+1} = sprintf('All molecules (%i) selected in correction factor window',size(selectedCorrPairs,1));
    choicetypes = [choicetypes; 8];
    if strcmpi(defChoice,'correctionSelected')
        defVal = length(choices);
    end
end

%% Molecule selection dialog
if isempty(choices)
    return
end

% Default
if defVal>length(choices)
    defVal = 1;
end

[fileType,ok] = mylistdlg('PromptString','Select molecules to export: ',...
    'Name', 'Export molecules',...
    'SelectionMode', 'multiple',...
    'ListString', choices,...
    'InitialValue', defVal,...
    'ListSize', [400 500],...
    'OKstring', ' Export ');
if ok==0 || isempty(fileType)
    return
end

%% Export

% Act to all selections
for ii = 1:length(fileType)
    
    %% Prepare structure
    
    % Selected pairs
    choice = fileType(ii);
    if choicetypes(choice)==1
        exportPairs = getPairs(mainhandle,'all');
        
    elseif choicetypes(choice)==2
        exportPairs = getPairs(mainhandle, 'file',choice-1);
        
    elseif choicetypes(choice)==3
        exportPairs = getPairs(mainhandle, 'group', choice-1-length(mainhandles.data));
        
    elseif choicetypes(choice)==4
        exportPairs = getPairs(mainhandle, 'plotted');
        
    elseif choicetypes(choice)==5
        exportPairs = getPairs(mainhandle, 'selected');
        
    elseif choicetypes(choice)==6
        exportPairs = getPairs(mainhandle, 'Dynamics');
        
    elseif choicetypes(choice)==7
        exportPairs = getPairs(mainhandle, 'dynamicsSelected');
        
    elseif choicetypes(choice)==8
        exportPairs = getPairs(mainhandle, 'correctionSelected');
    end
    
    %% Export
    
    boxName = [];
    if strcmpi(type,'workspace')
        msg = exportToWorkspace();
        
    elseif strcmpi(type,'smd')
        msg = exportToSMD();
        
    elseif strcmpi(type,'ascii')
        msg = exportToASCII();
        
    elseif strcmpi(type,'molmovie')
        [msg,boxName] = exportMoleculeMovie();
        
    elseif strcmpi(type,'boba')
        msg = exportToHist2();
        
    elseif strcmpi(type,'vbFRET')
        msg = exportToVBFRET();
        
    elseif strcmpi(type,'hammy')
        msg = exportToHaMMy();
    end
end

% Display message
if ~isempty(msg)
    if isempty(boxName)
        boxName = 'Great success!';
    end
    mymsgbox(msg,boxName) % Display message
end

%% Nested
    function msg = exportToWorkspace()
        
        % Populate data structure
        for j = 1:size(exportPairs,1)
            file = exportPairs(j,1);
            pair = exportPairs(j,2);
            thispair = mainhandles.data(file).FRETpairs(pair);
            thispair.id = sprintf('File %i. Pair %i.',file,pair);
            thispair.file = mainhandles.data(file).name;
            thispair.pair = pair;
            if j==1
                molecules = thispair;
            else
                molecules(j) = thispair;
            end
            %             molStructure(j).Dxy = mainhandles.data(file).FRETpairs(pair).Dxy;
            %             molStructure(j).Axy = mainhandles.data(file).FRETpairs(pair).Axy;
            %             molStructure(j).DxyGlobal = mainhandles.data(file).FRETpairs(pair).DxyGlobal;
            %             molStructure(j).AxyGlobal = mainhandles.data(file).FRETpairs(pair).AxyGlobal;
            %             molStructure(j).Dimage = mainhandles.data(file).FRETpairs(pair).DD_avgimage;
            %             molStructure(j).Aimage = mainhandles.data(file).FRETpairs(pair).AD_avgimage;
            %             molStructure(j).AAimage = mainhandles.data(file).FRETpairs(pair).AA_avgimage;
            %             molStructure(j).Dtrace = mainhandles.data(file).FRETpairs(pair).DDtrace;
            %             molStructure(j).Atrace = mainhandles.data(file).FRETpairs(pair).ADtrace;
            %             molStructure(j).AAtrace = mainhandles.data(file).FRETpairs(pair).AAtrace;
            %             molStructure(j).Etrace = mainhandles.data(file).FRETpairs(pair).Etrace;
            %             molStructure(j).Strace = mainhandles.data(file).FRETpairs(pair).StraceCorr;
            %             molStructure(j).Dbackground = mainhandles.data(file).FRETpairs(pair).DDback;
            %             molStructure(j).Abackground = mainhandles.data(file).FRETpairs(pair).ADback;
            %             molStructure(j).AAbackground = mainhandles.data(file).FRETpairs(pair).AAback;
            %             molStructure(j).avgE = mainhandles.data(file).FRETpairs(pair).avgE;
            %             molStructure(j).avgS = mainhandles.data(file).FRETpairs(pair).avgS;
            %             molStructure(j).vbFRET_fit = mainhandles.data(file).FRETpairs(pair).vbfitE_fit;
            %             molStructure(j).vbFRET_bestLP = mainhandles.data(file).FRETpairs(pair).vbfitE_bestLP;
            %             molStructure(j).vbFRET_out = mainhandles.data(file).FRETpairs(pair).vbfitE_out;
            %             molStructure(j).vbFRET_mix = mainhandles.data(file).FRETpairs(pair).vbfitE_mix;
            %             molStructure(j).vbFRET_idx = mainhandles.data(file).FRETpairs(pair).vbfitE_idx;
            %             molStructure(j).groups = mainhandles.data(file).FRETpairs(pair).group;
            %             molStructure(j).Dbleaching = mainhandles.data(file).FRETpairs(pair).DbleachingTime;
            %             molStructure(j).Ableaching = mainhandles.data(file).FRETpairs(pair).AbleachingTime;
            %             molStructure(j).Dblinking = mainhandles.data(file).FRETpairs(pair).DblinkingInterval;
            %             molStructure(j).Ablinking = mainhandles.data(file).FRETpairs(pair).AblinkingInterval;
            %             molStructure(j).timeInterval = mainhandles.data(file).FRETpairs(pair).timeInterval;
        end
        
        % Export to workspace
        if choicetypes(choice)==1
            varname = 'all_molecules';
            
        elseif choicetypes(choice)==2
            varname = sprintf('file%i_molecules',choice-1); % Send to workspace
            
        elseif choicetypes(choice)==3
            varname = sprintf('group%i_molecules',choice-1-length(mainhandles.data)); % Send to workspace
            
        elseif choicetypes(choice)==4
            varname = 'plotted_molecules'; % Send to workspace
            
        elseif choicetypes(choice)==6
            varname = 'dynamic_molecules'; % Send to workspace
            
        else
            varname = 'selected_molecules'; % Send to workspace
        end
        
        assignin('base', varname, molecules) % Send to workspace
        
        % Msg
        msg = sprintf('Data structure named ''%s'' with %i FRET-pairs was created in the MATLAB workspace.',varname,size(exportPairs,1));
    end

    function msg = exportToSMD()
        msg = '';
        
        % File dialog
        filterSpec = {'*.mat', 'iSMS SMD export (.mat)'; ...
            '*.json', 'iSMS SMD export (.json)'; ...
            '*.json.gz', 'iSMS SMD export (.json.gz)';};
        [filename, folder, filetype] = uiputfile3(mainhandles,'smdexport',filterSpec,'Export SMD file','exportedSMD');
        if filename == 0
            return
        end
        
        % Filetype
        filepath = fullfile(folder, filename);
        switch filetype
            case 1
                filetype = 'mat';
            case 2
                filetype = 'json';
            case 3
                filetype = 'gz';
        end
        if isempty(filetype)
            [~,~,filetype] = fileparts(filepath);
        end
        
        % Initialize smd data structure
        % Fields: type,columns,id,data,attr
        % data.index, data.values, data.attr
        [~,id] = fileparts(tempname);
        smd.type = 'iSMS_timeseries_export';
        smd.id = id;
        
        % Global attributes
        smd.attr.session = mainhandles.filename;
        
        % Data
        smd.columns = {'donor','acceptor','fret'};%, 'viterbi_state', 'viterbi_mean'};
        smd.data = struct([]);
        for n = 1:size(exportPairs,1)
            file = exportPairs(n,1);
            pair = exportPairs(n,2);
            
            % ID
            [~,id] = fileparts(tempname);
            smd.data(n).id = id;
            
            % Time vector
            xD = getTimeVector(mainhandles,[file pair],'D');
            if isempty(xD)
                xD = 1:length(Etrace);
            end
            smd.data(n).index = xD(:);%series(n).time(range);
            
            % store time series data
            Etrace = mainhandles.data(file).FRETpairs(pair).Etrace(:);
            smd.data(n).values = zeros(length(Etrace), length(smd.columns));
            smd.data(n).values(:, 1) = mainhandles.data(file).FRETpairs(pair).DDtrace(:);
            smd.data(n).values(:, 2) = mainhandles.data(file).FRETpairs(pair).ADtrace(:);
            smd.data(n).values(:, 3) = Etrace;
            
            % store other analysis properties in attributes
            smd.data(n).attr.file = mainhandles.data(file).name;%series(n).file;
            smd.data(n).attr.group = mainhandles.data(file).FRETpairs(pair).group;
            [gamma, Dleakage, Adirect] = getGamma(mainhandles,[file pair]);
            smd.data(n).attr.GammaFactor = gamma;
            smd.data(n).attr.DonorLeakageFactor = Dleakage;
            smd.data(n).attr.AcceptorDirectFactor = Adirect;
            smd.data(n).attr.DonorBleachingTime = mainhandles.data(file).FRETpairs(pair).DbleachingTime;
            smd.data(n).attr.AcceptorBleachingTime = mainhandles.data(file).FRETpairs(pair).AbleachingTime;
            smd.data(n).attr.DonorBlinkingIntervals = mainhandles.data(file).FRETpairs(pair).DblinkingInterval;
            smd.data(n).attr.AcceptorBlinkingIntervals = mainhandles.data(file).FRETpairs(pair).AblinkingInterval;
        end
        
        % Save to disk
        if strcmpi(filetype,'mat')            
            save(filepath, '-struct', 'smd');
            
        else
            % JSON and JSON.GZ
            
            % convert data to json
            json = savejson('', smd);
            
            % write to disk (use Java)
            import java.io.*;
            out = FileOutputStream(filepath);
            if strcmpi(filetype,'gz')
                % Use gzip
                import java.util.zip.GZIPOutputStream;
                writer = OutputStreamWriter(GZIPOutputStream(out));
            else
                writer = OutputStreamWriter(out);
            end
            writer.write(json);
            writer.close();
            out.close();
        end
        
        % Message
        msg = sprintf('Exported %i molecules to SMD file:\n %s',size(exportPairs,1),filepath);
    end

    function msg = exportToASCII()
        msg = '';
        
        % Scheme
        alex = mainhandles.settings.excitation.alex;
        
        %% Prepare dialog box
        
        if alex
            prompt = {'Export traces:' '';...
                'D emission - D excitation' 'DD';...
                'A emission - D excitation' 'AD';...
                'A emission - A excitation' 'AA';...
                'Stoichiometry (S)' 'S';...
                'FRET (E)' 'E';...
                'Background: D em. D exc.' 'DDback';...
                'Background: A em. D exc.' 'ADback';...
                'Background: A em. A exc.' 'AAback';...
                'Raw: D em. D exc.' 'DDraw';...
                'Raw: A em. D exc.' 'ADraw';...
                'Raw: A em. A exc.' 'AAraw';...
                'D emission - A excitation' 'DA';...
                'S uncorrected' 'Su';...
                'E uncorrected (PR)' 'PR';...
                'Idealized E trace (if calculated by HMM)' 'fitE'};%...
            %                 'Export: ' 'ExportChoice';...
            %                 'Export to: ' 'ExportTo'};
        else
            prompt = {'Export traces:' '';...
                'D emission - D excitation' 'DD';...
                'A emission - D excitation' 'AD';...
                'FRET (E)' 'E';...
                'Background: D em. D exc.' 'DDback';...
                'Background: A em. D exc.' 'ADback';...
                'Raw: D em. D exc.' 'DDraw';...
                'Raw: A em. D exc.' 'ADraw';...
                'E uncorrected (PR)' 'PR';...
                'Idealized E trace (if calculated by HMM)' 'fitE'};%...
            %                 'Export: ' 'ExportChoice';...
            %                 'Export to: ' 'ExportTo'};
        end
        name = 'Export traces';
        
        % Formats structure:
        formats = struct('type', {}, 'style', {}, 'items', {}, ...
            'format', {}, 'limits', {}, 'size', {});
        
        % Interpolation choices
        formats(2,1).type = 'text';
        formats(3,1).type = 'check';
        formats(4,1).type = 'check';
        formats(5,1).type = 'check';
        formats(6,1).type = 'check';
        formats(7,1).type = 'check';
        formats(9,1).type = 'check';
        formats(10,1).type = 'check';
        formats(11,1).type = 'check';
        formats(12,1).type = 'check';
        if alex
            formats(13,1).type = 'check';
            formats(14,1).type = 'check';
            formats(15,1).type = 'check';
            formats(16,1).type = 'check';
            formats(17,1).type = 'check';
            formats(18,1).type = 'check';
        end
        
        % Default choices
        DefAns.DD = 1;
        DefAns.AD = 1;
        DefAns.E = 1;
        DefAns.DDback = 0;
        DefAns.ADback = 0;
        DefAns.DDraw = 0;
        DefAns.ADraw = 0;
        DefAns.PR = 0;
        DefAns.fitE = 0;
        
        if alex
            DefAns.AA = 1;
            DefAns.S = 1;
            DefAns.AAback = 0;
            DefAns.AAraw = 0;
            DefAns.DA = 0;
            DefAns.Su = 0;
        end
        
        options.CancelButton = 'on';
        
        %% Open dialog box
        
        [fileType, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
        if (cancelled==1)
            return
        end
        
        %% Export traces
        
        if ~alex
            fileType.AA = 0;
            fileType.S = 0;
            fileType.AAback = 0;
            fileType.AAraw = 0;
            fileType.DA = 0;
            fileType.Su = 0;
        end
        
        % Open save file dialogue
        fileformats = {'*.txt;*.csv;*.asc;*.dat', 'ASCII files'; '*.*', 'All files'};
        [filenamePrefix, path, chose] = uiputfile3(mainhandles,'results',fileformats,'Specify filename prefix','Traces');
        if chose == 0
            return
        end
        
        % Waitbar
        hWaitbar = mywaitbar(0,'Exporting...','name','iSMS');
        
        % Start exporting FRET pairs one by one
        for jj = 1:size(exportPairs,1)
            file = exportPairs(jj,1);
            pair = exportPairs(jj,2);
            
            % Filename
            validMovFilename = mainhandles.data(file).name;
            validMovFilename = matlab.lang.makeValidName( strrep(validMovFilename,'.','_') );
            filename = sprintf('%s_%s_pair%i.txt',matlab.lang.makeValidName(filenamePrefix(1:end-4)),validMovFilename,pair);
            datafile = fullfile(path,filename);
            
            % Start writing to file
            fileID = fopen(datafile,'w');
            fprintf(fileID,'Exported by iSMS\n');
            fprintf(fileID,'Date: %s\n',date);
            fprintf(fileID,'Movie filename: %s\n',mainhandles.data(file).name);
            fprintf(fileID,'FRET pair #%i\n',pair);
            if fileType.fitE && ~isempty(mainhandles.data(file).FRETpairs(pair).vbfitE_fit)
                fprintf(fileID,'Scroll to bottom to get the idealized trace...\n');
            end
            
            % Prepare data to export
            labels = '';
            data = [];
            if fileType.DD % Dem-Dexc trace
                labels = sprintf('%s%s',labels,'Dem-Dexc   ');
                data = [data  mainhandles.data(file).FRETpairs(pair).DDtrace];
            end
            if fileType.AD % Aem-Dexc trace
                labels = sprintf('%s%s',labels,'Aem-Dexc   ');
                data = [data  mainhandles.data(file).FRETpairs(pair).ADtrace];
            end
            if fileType.AA % Aem-Aexc trace
                labels = sprintf('%s%s',labels,'Aem-Aexc   ');
                data = [data  mainhandles.data(file).FRETpairs(pair).AAtrace];
            end
            if fileType.DDback % Dem-Dexc background trace
                labels = sprintf('%s%s',labels,'D-Dexc-bg. ');
                data = [data  mainhandles.data(file).FRETpairs(pair).DDback];
            end
            if fileType.ADback % Aem-Dexc background trace
                labels = sprintf('%s%s',labels,'A-Dexc-bg. ');
                data = [data  mainhandles.data(file).FRETpairs(pair).ADback];
            end
            if fileType.AAback % Aem-Aexc background trace
                labels = sprintf('%s%s',labels,'A-Aexc-bg. ');
                data = [data  mainhandles.data(file).FRETpairs(pair).AAback];
            end
            if fileType.DDraw % Dem-Dexc raw trace
                labels = sprintf('%s%s',labels,'D-Dexc-rw. ');
                data = [data  mainhandles.data(file).FRETpairs(pair).DDtrace+mainhandles.data(file).FRETpairs(pair).DDback];
            end
            if fileType.ADraw % Aem-Dexc raw trace
                labels = sprintf('%s%s',labels,'A-Dexc-rw. ');
                data = [data  mainhandles.data(file).FRETpairs(pair).ADtrace+mainhandles.data(file).FRETpairs(pair).ADback];
            end
            if fileType.AAraw % Aem-Aexc raw trace
                labels = sprintf('%s%s',labels,'A-Aexc-rw. ');
                data = [data  mainhandles.data(file).FRETpairs(pair).AAtrace+mainhandles.data(file).FRETpairs(pair).AAback];
            end
            if fileType.DA % Dem-Aexc trace
                if ~isempty(mainhandles.data(file).FRETpairs(pair).DAtrace)
                    labels = sprintf('%s%s',labels,'Dem-Aexc   ');
                    data = [data  mainhandles.data(file).FRETpairs(pair).DAtrace];
                end
            end
            if fileType.S % Stoichiometry trace
                if ~isempty(mainhandles.data(file).FRETpairs(pair).StraceCorr)
                    labels = sprintf('%s%s',labels,'   S     ');
                    data = [data  mainhandles.data(file).FRETpairs(pair).StraceCorr];
                end
            end
            if fileType.E % FRET trace
                if ~isempty(mainhandles.data(file).FRETpairs(pair).Etrace)
                    labels = sprintf('%s%s',labels,'    E      ');
                    data = [data  mainhandles.data(file).FRETpairs(pair).Etrace];
                end
            end
            if fileType.Su % Uncorrected stoichiometry trace
                labels = sprintf('%s%s',labels,'S-uncorr.  ');
                data = [data  mainhandles.data(file).FRETpairs(pair).Strace];
            end
            if fileType.PR % Uncorrected E trace (i.e. the PR trace)
                labels = sprintf('%s%s',labels,'PR-uncorr. ');
                data = [data  mainhandles.data(file).FRETpairs(pair).PRtrace];
            end
            
            % Write data to file
            fprintf(fileID,sprintf('%s\n',labels));
            dlmwrite(datafile,data,'-append','delimiter', '\t','precision','%.4f');
            fclose(fileID);
            
            % Write fit below rest of data
            if fileType.fitE && ~isempty(mainhandles.data(file).FRETpairs(pair).vbfitE_fit)
                fileID = fopen(datafile,'a');
                fit = mainhandles.data(file).FRETpairs(pair).vbfitE_fit(:,1);
                fprintf(fileID,sprintf('\n\n%s\n','   Fit   '));
                dlmwrite(datafile,fit,'-append','delimiter', '\t','precision','%.4f');
                fclose(fileID);
            end
            
            % Waitbar
            waitbar(jj/size(exportPairs,1),hWaitbar)
        end
        
        try delete(hWaitbar), end
        
        % Mesage box
        msg = sprintf('Traces from %i FRET-pairs were exported to ASCII. You may want to view them in Wordpad rather than Notepad.',size(exportPairs,1));
    end

    function [msg,boxName] = exportMoleculeMovie()
        
        boxName = [];
        
        % Check existence of raw data
        missingRaw = [];
        for file = 1:length(unique(exportPairs(:,1)))
            if isempty(mainhandles.data(file).DD_ROImovie)
                missingRaw = [missingRaw file];
            end
        end
        
        % Default filename
        [~, sessionname] = fileparts(mainhandles.filename);
        if size(exportPairs,1)>1
            defname = sprintf('Session %s - %i molecules',sessionname, size(exportPairs,1));
        else
            filename = mainhandles.data(exportPairs(1,1)).name;
            defname = sprintf('Session %s - File %s - Mol %i',sessionname, filename, exportPairs(1,2));
        end
        
        % Open save file dialogue
        fileformats = {'*.mat', 'MATLAB files'; '*.*', 'All files'};
        [filename, path, chose] = uiputfile3(mainhandles,'moleculeMovie',fileformats,'Select filepath',defname);
        if chose == 0
            return
        end
        
        % Start exporting
        for n = 1:size(exportPairs,1)
            file = exportPairs(n,1);
            pair = exportPairs(n,2);
            
            [DD_molmovie, AD_molmovie, AA_molmovie] = getmoleculemovie(mainhandle,[file pair]);
            thispair = mainhandles.data(file).FRETpairs(pair);
            thispair.file = mainhandles.data(file).name;
            thispair.pair = pair;
            thispair.DD_molmovie = DD_molmovie;
            thispair.AD_molmovie = AD_molmovie;
            thispair.AA_molmovie = AA_molmovie;
            if n==1
                pairs = thispair;
            else
                pairs(end+1) = thispair;
            end
            
        end
        
        % Save file
        filepath = fullfile(path,filename);
        save(filepath,'pairs');
        
        % Msg
        if isempty(missingRaw)
            msg = sprintf('Exported processed + raw image data of %i molecules to:\n %s',size(exportPairs,1),filepath);
        else
            msg = sprintf('Unable to export raw data of files missing raw data. Reload raw data from the memory menu and redo the export.');
            boxName = 'Obs!';
        end
    end

    function msg = exportToHist2()
        msg = '';
        
        % Output format
        prompt = {'Export single-molecule FRET histograms: ' '';...
            'Bin size (E): ' 'binsize';...
            'Lower E bound: ' 'Emin';...
            'Upper E bound: ' 'Emax'};
        formats = prepareformats();
        formats(2,1).type = 'text';
        formats(4,1).type = 'edit';
        formats(4,1).format = 'float';
        formats(5,1).type = 'edit';
        formats(5,1).format = 'float';
        formats(6,1).type = 'edit';
        formats(6,1).format = 'float';
        name = 'iSMS export: hist2';
        DefAns.binsize = 0.01;
        DefAns.Emin = -0.2;
        DefAns.Emax = 1.2;
        
        [answer,cancelled] = myinputsdlg(prompt,name,formats,DefAns);
        if cancelled
            return
        end
        binSize = abs(answer.binsize);
        if binSize==0
            binSize = 0.02;
        end
        Emin = answer.Emin;
        Emax = answer.Emax;
        
        % Open save file dialogue
        fileformats = {'*.hist2', 'Single-molecule histogram files'; '*.*', 'All files'};
        [filenamePrefix, path, chose] = uiputfile3(mainhandles,'results',fileformats,sprintf('Specify filename prefix for %i files',size(exportPairs,1)),'bobafret');
        if chose == 0
            return
        end
        
        % Waitbar
        hWaitbar = mywaitbar(0,'Exporting...','name','iSMS');
        
        traces = getTraces(mainhandle,exportPairs,'noDarkStates');
        bins = Emin:binSize:Emax;
        for n = 1:size(exportPairs,1)
            file = exportPairs(n,1);
            pair = exportPairs(n,2);
            
            % Filename
            validMovFilename = mainhandles.data(file).name;
            validMovFilename = matlab.lang.makeValidName( strrep(validMovFilename,'.','_') );
            filename = sprintf('%s_%s_pair%i.hist2',matlab.lang.makeValidName(filenamePrefix(1:end-4)),validMovFilename,pair);
            datafile = fullfile(path,filename);
            
            % Write
            M = hist(traces(n).E(:),bins);
            dlmwrite(datafile,[bins(:) M(:)])
            
            % Waitbar
            waitbar(n/size(exportPairs,1),hWaitbar)
        end
        
        % Delete waitbar
        try delete(hWaitbar), end
        
        % Output
        msg = sprintf('Exported %i molecules to hist2.',size(exportPairs,1));
    end

    function msg = exportToVBFRET()
        msg = '';
        
        % File dialog
        filterSpec = {'*.mat', 'Multi-trace vbFRET input file'; '*.*', 'All files'};
        [filename, folder, filetype] = uiputfile3(mainhandles,'results',filterSpec,'Export vbFRET input file','vbFRETinput');
        if filename == 0
            return
        end
        
        % Filetype
        filepath = fullfile(folder, filename);
        
        % Data
        npairs = size(exportPairs,1);
        labels = cell(1,npairs);
        data = cell(1,npairs);
        FRET = cell(1,npairs);
        for n = 1:size(exportPairs,1)
            file = exportPairs(n,1);
            pair = exportPairs(n,2);
            
            labels{1,n} = sprintf('File_%s_pair%i',mainhandles.data(file).name,pair);
            data{1,n} = [mainhandles.data(file).FRETpairs(pair).DDtrace(:) mainhandles.data(file).FRETpairs(pair).ADtrace(:)];
            FRET{1,n} = mainhandles.data(file).FRETpairs(pair).Etrace(:);
            
        end
        
        % Save to disk
        save(filepath, 'labels','data','FRET');
        
        % Message
        msg = sprintf('Exported %i molecules to vbFRET-compatible file:\n %s',size(exportPairs,1),filepath);
    end

    function msg = exportToHaMMy()
        msg = '';
        
        % Open save file dialogue
        fileformats = {'*.dat', 'HaMMy input files'; '*.*', 'All files'};
        [filenamePrefix, path, chose] = uiputfile3(mainhandles,'results',fileformats,sprintf('Specify filename prefix for %i files',size(exportPairs,1)),'HaMMy');
        if chose == 0
            return
        end
        
        % Waitbar
        hWaitbar = mywaitbar(0,'Exporting...','name','iSMS');
        
        for n = 1:size(exportPairs,1)
            file = exportPairs(n,1);
            pair = exportPairs(n,2);
            
            % Filename
            validMovFilename = mainhandles.data(file).name;
            validMovFilename = matlab.lang.makeValidName( strrep(validMovFilename,'.','_') );
            filename = sprintf('%s_%s_pair%i.dat',matlab.lang.makeValidName(filenamePrefix(1:end-4)),validMovFilename,pair);
            datafile = fullfile(path,filename);
            
            % Write
            t = getTimeVector(mainhandles,[file pair]);
            D = mainhandles.data(file).FRETpairs(pair).DDtrace;
            A = mainhandles.data(file).FRETpairs(pair).ADtrace;
            dlmwrite(datafile,[t(:) D(:) A(:)],'\t')
            
            % Waitbar
            waitbar(n/size(exportPairs,1),hWaitbar)
        end
        
        % Delete waitbar
        try delete(hWaitbar), end
        
        % Output
        msg = sprintf('Exported %i molecules to HaMMy input files.',size(exportPairs,1));
    end

end
