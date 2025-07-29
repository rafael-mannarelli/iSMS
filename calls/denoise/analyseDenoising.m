function analyseDenoising(mainhandles)
% Function that is used to evaluate image denoising algorithms in iSMS
%
%     Input:
%      handles - handles structure of the main window
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

filechoice = get(mainhandles.FilesListbox,'Value');

%% Initialize

%------------------------ Prepare analysis -----------------------%

%----- Prepare dialog -----%
prompt = {'Denoising algorithm' 'algorithm';...
    'Analyze D-ROI for D-exc frames' 'runDD';...
    'Analyze A-ROI for D-exc frames' 'runAD';...
    'Analyze A-ROI for A-exc frames' 'runAA';...
    'Run peakfinder on final images' 'runpeakfinder';...
    'Avg. consecutive frames' 'avgFrames';...
    'No. of averaging events' 'numFrames';...
    '(Total no. of frames analysed = 1:Avg.*No.)' '';...
    'Run frame-interval analysis' 'runanalysis';...
    'Frame step-size in analysis' 'stepsize';...
    'Peakfinder threshold (avg. of x% weakest pixels)' 'peakthreshold'};

name = 'Compare image averaging with denoising';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Interpolation choices
% Algorithm
algorithms = {'waveletMultiFrame'};
formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = algorithms;
formats(2,1).size = [150 50];
formats(2,1).limits = [0 1]; % multi-select
% Checkboxes
formats(3,1).type = 'check';
formats(4,1).type = 'check';
formats(5,1).type = 'check';
formats(6,1).type = 'check';
% Edit boxes
formats(7,1).type = 'edit';
formats(7,1).size = 50;
formats(7,1).format = 'integer';
formats(8,1).type = 'edit';
formats(8,1).size = 50;
formats(8,1).format = 'integer';
% Test strings
formats(9,1).type = 'text';
% Run analysis
formats(10,1).type = 'check';
formats(11,1).type = 'edit';
formats(11,1).size = 50;
formats(11,1).format = 'integer';
formats(12,1).type = 'edit';
formats(12,1).size = 50;
formats(12,1).format = 'float';

% Default choices
DefAns.algorithm = 1;
DefAns.runDD = 1;
DefAns.runAD = 0;
DefAns.runAA = 1;
DefAns.runpeakfinder = 1;
DefAns.avgFrames = 1;
DefAns.numFrames = 22;
DefAns.runanalysis = 1;
DefAns.stepsize = 4;
DefAns.peakthreshold = 99;

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)
    return
end

%-- Chosen settings --%
algorithm = algorithms{answer.algorithm}; % Chosen algorithm
runDD = answer.runDD; % Run Dem Dexc?
runAD = answer.runAD; % Run Aem Dexc?
runAA = answer.runAA; % Run Aem Aexc?
runpeakfinder = answer.runpeakfinder; % Run peakfinder on analysed images?
avgFrames = answer.avgFrames; % Number of consecutive frames to mean
numFrames = answer.numFrames; % Number of averaged frames in movie sent to denoising algorithm
runanalysis = answer.runanalysis; % Run analysis of number of frames effect
stepsize = answer.stepsize; % Step size in analysis
if answer.peakthreshold > 99.9
    peakthreshold = 99.9;
else
    peakthreshold = abs(answer.peakthreshold); % Peakfinder threshold (threshold is avg. of peakthreshold% least intense pixels)
end
if runanalysis
    runpeakfinder = 1;
end

% Algorithm settings
if strcmp(algorithm,'waveletMultiFrame')
    % defaults:
    k = 1;
    p = 5;
    r = 2;
    maxLevel = 3;
    weightMode = 4;
    windowSize = 2;
    basis = 'haar';
    
    %----- Prepare dialog -----%
    prompt = {'waveletMultiFrame settings' '';...
        'k' 'k';...
        'p' 'p';...
        'r' 'r';...
        'maxLevel' 'maxLevel';...
        'weightMode (0-4)' 'weightMode';...
        'windowSize' 'windowSize';...
        'basis' 'basis'};
    name = 'waveletMultiFrame settings';
    
    % Formats structure:
    formats = struct('type', {}, 'style', {}, 'items', {}, ...
        'format', {}, 'limits', {}, 'size', {});
    
    % Choices
    % waveletMultiFrame parameters
    formats(1,1).type = 'text';
    formats(2,1).type = 'edit';
    formats(2,1).size = 50;
    formats(2,1).format = 'float';
    formats(3,1).type = 'edit';
    formats(3,1).size = 50;
    formats(3,1).format = 'float';
    formats(4,1).type = 'edit';
    formats(4,1).size = 50;
    formats(4,1).format = 'float';
    formats(5,1).type = 'edit';
    formats(5,1).size = 50;
    formats(5,1).format = 'integer';
    formats(6,1).type = 'edit';
    formats(6,1).size = 50;
    formats(6,1).format = 'integer';
    formats(7,1).type = 'edit';
    formats(7,1).size = 50;
    formats(7,1).format = 'integer';
    % Basis
    bases = {'haar'; 'dualTree'};
    formats(8,1).type = 'list';
    formats(8,1).style = 'listbox';
    formats(8,1).items = bases;
    formats(8,1).size = [100 50];
    formats(8,1).limits = [0 1]; % multi-select
    
    % Default choices
    DefAns.k = k;
    DefAns.p = p;
    DefAns.r = r;
    DefAns.maxLevel = maxLevel;
    DefAns.weightMode = weightMode;
    DefAns.windowSize = windowSize;
    DefAns.basis = 1;
    
    options.CancelButton = 'on';
    
    %------- Open dialog box -------%
    [answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
    if (cancelled==1)
        return
    end
    
    %-- Chosen settings --%
    k = answer.k;
    p = answer.p;
    r = answer.r;
    maxLevel = answer.maxLevel;
    weightMode = answer.weightMode;
    windowSize = answer.windowSize;
    basis = bases{answer.basis};
    
else
    display('algorithm not implemented correctly')
    return
end

%--- Get data ---%
% Get ROI movies
[DROImovie,AROImovie] = getROItraces(mainhandles);

if (maxLevel == 5) && (size(img,1) == 496)
    imgTemp = zeros(512, size(img,2), numFrames);
    imgTemp(1:496,:,:) = img;
    img = imgTemp;
    clear imgTemp;
    cutBack = 1;
end

% D-exc and A-exc frames
Dframes = find(mainhandles.data(filechoice).excorder=='D'); % Indices of all F frames
Aframes = find(mainhandles.data(filechoice).excorder=='A'); % Indices of all A frames

%% Run analysis

% Analyse Dem Dexc ROI
if runDD
    DDmovie = DROImovie(:,:,Dframes);  % All D-ROI D-exc frames
    
    if runanalysis % If running analysis, make a number of images
        runFrames = 2:stepsize:numFrames;
    else % If not running analysis, only make a single image
        runFrames = numFrames;
    end
    
    if runpeakfinder % If running peakfinder, preallocate
        allpeaksDavg = cell(1,length(runFrames));
        allpeaksDden = cell(1,length(runFrames));
        numpeaksDavg = zeros(1,length(runFrames));
        numpeaksDden = zeros(1,length(runFrames));
        totalNoFramesAnalysed = zeros(1,length(runFrames));
        tocsavg = zeros(1,length(runFrames));
        tocsden = zeros(1,length(runFrames));
    end
    for i = 1:length(runFrames) % Run over runFrames (length=1 if it is not an analysis)
        numFrames = runFrames(i); % Number of frames sent to denoising algorithm
        
        DD = zeros(size(DDmovie,1),size(DDmovie,2),numFrames);
        run = 1;
        % Average consecutive frames in DD
        for j = 1:avgFrames:numFrames*avgFrames
            DD(:,:,run) = mean(DDmovie(:,:,j:j+avgFrames),3);
            run = run+1;
        end
        
        % Denoising algorithm
        tic % Take time of making denoised image
        if strcmp(algorithm,'waveletMultiFrame')
            DDden = waveletMultiFrame(DD,...
                'k',k, 'p',p, 'r',r, 'maxLevel',maxLevel, 'weightMode',weightMode, 'windowSize',windowSize, 'basis',basis);
        else
            display('algorithm not implemented correctly')
            return
        end
        if size(DDden,3)>1 % If denoised image is rgb based
            DDden = sum(DDden,3);
        end
        tocden = toc;
        
        % Averaged image
        tic % Take time of making avg image
        DDavg = mean(DD,3);
        tocavg = toc;
        
        % Store times
        tocsavg(i) = tocavg;
        tocsden(i) = tocden;
        
        % If finding peaks in image
        if runpeakfinder
            % Avg
            temp = sort(DDavg(:)); % Image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*peakthreshold/100))); % Threshold for peakfinder is the mean of the 90% least-bright pixels
            peaksDavg = FastPeakFind(DDavg,threshold); % Peaks in [x; y; x; y]
            peaksDavg = [peaksDavg(1:2:end-1) peaksDavg(2:2:end)]; % Peaks in [x y; x y]
            
            % Denoised
            temp = sort(DDden(:)); % image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*peakthreshold/100))); % threshold for peakfinder is the mean of the 90% least-bright pixels
            peaksDden = FastPeakFind(DDden,threshold); % peaks in [x; y; x; y]
            peaksDden = [peaksDden(1:2:end-1) peaksDden(2:2:end)]; % peaks in [x y; x y]
            
            % Collect data for this numFrames
            allpeaksDavg{i} = peaksDavg;
            allpeaksDden{i} = peaksDden;
            numpeaksDavg(i) = size(peaksDavg,1);
            numpeaksDden(i) = size(peaksDden,1);
            totalNoFramesAnalysed(i) = numFrames*avgFrames; % Total frame interval analysed in movie (frames analysed: 1:totalNoFramesAnalysed)
        end
        
        % Update images
        figure(2)
        set(gcf,'name',sprintf('Number of frames sent: %i',numFrames),'numbertitle','off')
        ax1 = subplot(1,2,1);
        imagesc(DDavg')
        axis(gca,'image')
        set(gca,'YDir','normal')
        title('D_e_mD_e_x_c averaged')
        
        ax2 = subplot(1,2,2);
        imagesc(DDden')
        axis(gca,'image')
        set(gca,'YDir','normal')
        title('D_e_mD_e_x_c denoised')
        linkaxes([ax1 ax2],'xy')
        
    end
    
    % Plot results from analysis
    if runanalysis
        figure
        set(gcf,'name',sprintf('Analysis: Dem-Dexc movie'),'numbertitle','off')
        
        ax1 = subplot(2,2,1);
        plot(totalNoFramesAnalysed,numpeaksDavg,'-b')
        title('Peaks - averaged image')
        ylabel('Peaks found')
        
        ax2 = subplot(2,2,2);
        plot(totalNoFramesAnalysed,numpeaksDden,'-r')
        title('Peaks - denoised image')
        
        ax3 = subplot(2,2,3);
        plot(totalNoFramesAnalysed,tocsavg,'-b')
        xlabel('Frames analysed')
        ylabel('Computation time /s')
        
        ax4 = subplot(2,2,4);
        plot(totalNoFramesAnalysed,tocsden,'-r')
        xlabel('Frames analysed')
        
        linkaxes([ax1 ax2],'xy')
        linkaxes([ax4 ax3],'xy')
    end
end

% Analyse Aem Dexc ROI
if runAD
    ADmovie = AROImovie(:,:,Dframes);  % All A-ROI D-exc frames
    
    if runanalysis % If running analysis, make a number of images
        runFrames = 2:stepsize:numFrames;
    else % If not running analysis, only make a single image
        runFrames = numFrames;
    end
    
    if runpeakfinder % If running peakfinder, preallocate
        allpeaksADavg = cell(1,length(runFrames));
        allpeaksADden = cell(1,length(runFrames));
        numpeaksADavg = zeros(1,length(runFrames));
        numpeaksADden = zeros(1,length(runFrames));
        totalNoFramesAnalysed = zeros(1,length(runFrames));
        tocsavg = zeros(1,length(runFrames));
        tocsden = zeros(1,length(runFrames));
    end
    for i = 1:length(runFrames) % Run over runFrames (length=1 if it is not an analysis)
        numFrames = runFrames(i); % Number of frames sent to denoising algorithm
        
        AD = zeros(size(ADmovie,1),size(ADmovie,2),numFrames);
        run = 1;
        % Average consecutive frames in DD
        for j = 1:avgFrames:numFrames*avgFrames
            AD(:,:,run) = mean(ADmovie(:,:,j:j+avgFrames),3);
            run = run+1;
        end
        
        % Denoising algorithm
        tic % Take time of making denoised image
        if strcmp(algorithm,'waveletMultiFrame')
            ADden = waveletMultiFrame(AD,...
                'k',k, 'p',p, 'r',r, 'maxLevel',maxLevel, 'weightMode',weightMode, 'windowSize',windowSize, 'basis',basis);
        else
            display('algorithm not implemented correctly')
            return
        end
        if size(ADden,3)>1 % If denoised image is rgb based
            ADden = sum(ADden,3);
        end
        tocden = toc;
        
        % Averaged image
        tic % Take time of making avg image
        ADavg = mean(AD,3);
        tocavg = toc;
        
        % Store times
        tocsavg(i) = tocavg;
        tocsden(i) = tocden;
        
        % If finding peaks in image
        if runpeakfinder
            % Avg
            temp = sort(ADavg(:)); % Image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*peakthreshold/100))); % Threshold for peakfinder is the mean of the 90% least-bright pixels
            peaksADavg = FastPeakFind(ADavg,threshold); % Peaks in [x; y; x; y]
            peaksADavg = [peaksADavg(1:2:end-1) peaksADavg(2:2:end)]; % Peaks in [x y; x y]
            
            % Denoised
            temp = sort(ADden(:)); % image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*peakthreshold/100))); % threshold for peakfinder is the mean of the 90% least-bright pixels
            peaksADden = FastPeakFind(ADden,threshold); % peaks in [x; y; x; y]
            peaksADden = [peaksADden(1:2:end-1) peaksADden(2:2:end)]; % peaks in [x y; x y]
            
            % Collect data for this numFrames
            allpeaksADavg{i} = peaksADavg;
            allpeaksADden{i} = peaksADden;
            numpeaksADavg(i) = size(peaksADavg,1);
            numpeaksADden(i) = size(peaksADden,1);
            totalNoFramesAnalysed(i) = numFrames*avgFrames; % Total frame interval analysed in movie (frames analysed: 1:totalNoFramesAnalysed)
        end
        
        % Update images
        figure(2)
        set(gcf,'name',sprintf('Number of frames sent: %i',numFrames),'numbertitle','off')
        ax1 = subplot(1,2,1);
        imagesc(ADavg')
        axis(gca,'image')
        set(gca,'YDir','normal')
        title('A_e_mD_e_x_c averaged')
        
        ax2 = subplot(1,2,2);
        imagesc(ADden')
        axis(gca,'image')
        set(gca,'YDir','normal')
        title('A_e_mD_e_x_c denoised')
        linkaxes([ax1 ax2],'xy')
        
    end
    
    % Plot results from analysis
    if runanalysis
        figure
        set(gcf,'name',sprintf('Analysis: Aem-Dexc movie'),'numbertitle','off')
        
        ax1 = subplot(2,2,1);
        plot(totalNoFramesAnalysed,numpeaksADavg,'-b')
        title('Peaks - averaged image')
        ylabel('Peaks found')
        
        ax2 = subplot(2,2,2);
        plot(totalNoFramesAnalysed,numpeaksADden,'-r')
        title('Peaks - denoised image')
        
        ax3 = subplot(2,2,3);
        plot(totalNoFramesAnalysed,tocsavg,'-b')
        xlabel('Frames analysed')
        ylabel('Computation time /s')
        
        ax4 = subplot(2,2,4);
        plot(totalNoFramesAnalysed,tocsden,'-r')
        xlabel('Frames analysed')
        
        linkaxes([ax1 ax2],'xy')
        linkaxes([ax4 ax3],'xy')
    end
end

% Analyse Aem Aexc ROI
if runAA
    AAmovie = AROImovie(:,:,Aframes);  % All A-ROI D-exc frames
    
    if runanalysis % If running analysis, make a number of images
        runFrames = 2:stepsize:numFrames;
    else % If not running analysis, only make a single image
        runFrames = numFrames;
    end
    
    if runpeakfinder % If running peakfinder, preallocate
        allpeaksAAavg = cell(1,length(runFrames));
        allpeaksAAden = cell(1,length(runFrames));
        numpeaksAAavg = zeros(1,length(runFrames));
        numpeaksAAden = zeros(1,length(runFrames));
        totalNoFramesAnalysed = zeros(1,length(runFrames));
        tocsavg = zeros(1,length(runFrames));
        tocsden = zeros(1,length(runFrames));
    end
    for i = 1:length(runFrames) % Run over runFrames (length=1 if it is not an analysis)
        numFrames = runFrames(i); % Number of frames sent to denoising algorithm
        
        AA = zeros(size(AAmovie,1),size(AAmovie,2),numFrames);
        run = 1;
        % Average consecutive frames in DD
        for j = 1:avgFrames:numFrames*avgFrames
            AA(:,:,run) = mean(AAmovie(:,:,j:j+avgFrames),3);
            run = run+1;
        end
        
        % Denoising algorithm
        tic % Take time of making denoised image
        if strcmp(algorithm,'waveletMultiFrame')
            AAden = waveletMultiFrame(AA,...
                'k',k, 'p',p, 'r',r, 'maxLevel',maxLevel, 'weightMode',weightMode, 'windowSize',windowSize, 'basis',basis);
        else
            display('algorithm not implemented correctly')
            return
        end
        if size(AAden,3)>1 % If denoised image is rgb based
            AAden = sum(AAden,3);
        end
        tocden = toc;
        
        % Averaged image
        tic % Take time of making avg image
        AAavg = mean(AA,3);
        tocavg = toc;
        
        % Store times
        tocsavg(i) = tocavg;
        tocsden(i) = tocden;
        
        % If finding peaks in image
        if runpeakfinder
            % Avg
            temp = sort(AAavg(:)); % Image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*peakthreshold/100))); % Threshold for peakfinder is the mean of the 90% least-bright pixels
            peaksAAavg = FastPeakFind(AAavg,threshold); % Peaks in [x; y; x; y]
            peaksAAavg = [peaksAAavg(1:2:end-1) peaksAAavg(2:2:end)]; % Peaks in [x y; x y]
            
            % Denoised
            temp = sort(AAden(:)); % image pixels sorted according to brightness
            threshold = mean(temp(1:round(end*peakthreshold/100))); % threshold for peakfinder is the mean of the 90% least-bright pixels
            peaksAAden = FastPeakFind(AAden,threshold); % peaks in [x; y; x; y]
            peaksAAden = [peaksAAden(1:2:end-1) peaksAAden(2:2:end)]; % peaks in [x y; x y]
            
            % Collect data for this numFrames
            allpeaksAAavg{i} = peaksAAavg;
            allpeaksAAden{i} = peaksAAden;
            numpeaksAAavg(i) = size(peaksAAavg,1);
            numpeaksAAden(i) = size(peaksAAden,1);
            totalNoFramesAnalysed(i) = numFrames*avgFrames; % Total frame interval analysed in movie (frames analysed: 1:totalNoFramesAnalysed)
        end
        
        % Update images
        figure(2)
        set(gcf,'name',sprintf('Number of frames sent: %i',numFrames),'numbertitle','off')
        ax1 = subplot(1,2,1);
        imagesc(AAavg')
        axis(gca,'image')
        set(gca,'YDir','normal')
        title('A_e_mA_e_x_c averaged')
        
        ax2 = subplot(1,2,2);
        imagesc(AAden')
        axis(gca,'image')
        set(gca,'YDir','normal')
        title('A_e_mA_e_x_c denoised')
        linkaxes([ax1 ax2],'xy')
        
    end
    
    % Plot results from analysis
    if runanalysis
        figure
        set(gcf,'name',sprintf('Analysis: Aem-Aexc movie'),'numbertitle','off')
        
        ax1 = subplot(2,2,1);
        plot(totalNoFramesAnalysed,numpeaksAAavg,'-b')
        title('Peaks - averaged image')
        ylabel('Peaks found')
        
        ax2 = subplot(2,2,2);
        plot(totalNoFramesAnalysed,numpeaksAAden,'-r')
        title('Peaks - denoised image')
        
        ax3 = subplot(2,2,3);
        plot(totalNoFramesAnalysed,tocsavg,'-b')
        xlabel('Frames analysed')
        ylabel('Computation time /s')
        
        ax4 = subplot(2,2,4);
        plot(totalNoFramesAnalysed,tocsden,'-r')
        xlabel('Frames analysed')
        
        linkaxes([ax1 ax2],'xy')
        linkaxes([ax4 ax3],'xy')
    end
end

%% If both D and A is run in analysis, find FRET-pairs

if runanalysis && runDD && (runAA || runAD)
    criteria = mainhandles.settings.peakfinder.Ecriteria; % Donor-acceptor distance criteria /pixel separation
    
    Epairs_avg = zeros(1,length(runFrames)); % Preallocate
    Epairs_den = zeros(1,length(runFrames));
    for i = 1:length(runFrames)
        Dpeaks_avg = allpeaksDavg{i}; % Donor peaks found in average image by numFrames = runFrames(i)
        Dpeaks_den = allpeaksDden{i}; % Donor peaks found in denoised image by numFrames = runFrames(i)
        if runAA % If AA has been run, use A peaks found in AA
            Apeaks_avg = allpeaksAAavg{i}; % Acceptors peaks found in average image by numFrames = runFrames(i)
            Apeaks_den = allpeaksAAden{i}; % Acceptors peaks found in denoised image by numFrames = runFrames(i)
        else % If AD and not AA has been run, use A peaks found in AD
            Apeaks_avg = allpeaksADavg{i};
            Apeaks_den = allpeaksADden{i};
        end
        
        %--- Find FRET-pairs in averaged image
        % Distance between all donor and acceptor peaks [size(Dpeaks)]
        [x1 x2] = meshgrid(Apeaks_avg(:,1),Dpeaks_avg(:,1));
        [y1 y2] = meshgrid(Apeaks_avg(:,2),Dpeaks_avg(:,2));
        alldist = sqrt((x2-x1).^2+(y2-y1).^2);
        
        % All donor acceptor pairs separated within the distance criteria
        [Ds,As] = find(alldist<criteria);
        Epairs_avg(i) = length(Ds);
        
        %--- Find FRET-pairs in denoised image
        % Distance between all donor and acceptor peaks [size(Dpeaks)]
        [x1 x2] = meshgrid(Apeaks_den(:,1),Dpeaks_den(:,1));
        [y1 y2] = meshgrid(Apeaks_den(:,2),Dpeaks_den(:,2));
        alldist = sqrt((x2-x1).^2+(y2-y1).^2);
        
        % All donor acceptor pairs separated within the distance criteria
        [Ds,As] = find(alldist<criteria);
        Epairs_den(i) = length(Ds);
    end
    
    figure
    plot(totalNoFramesAnalysed,Epairs_avg,'-b'), hold on
    plot(totalNoFramesAnalysed,Epairs_den,'-r')
    xlabel('Frames analysed')
    ylabel('FRET-pairs found')
    legend('On average image','On denoised image')
    
end
