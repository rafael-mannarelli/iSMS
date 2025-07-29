function mainhandles = storeMovie(mainhandles,data,filename,filepath,spot,excorder)
% Creates new data field in mainhandles structure with all the necessary
% subfields defining a movie data set
%
%      Input:
%       mainhandles - handles structure of the main window
%       data        - data structure with, at minimum, field data.imageData
%       filename    - name of file to be stored in iSMS
%       filepath    - full path to file, including filename. Default: [pwd]
%       spot        - binary parameter being 1 for green profiles and 2 for
%                     red. [0]
%       excorder    - excorder of file. Default: [auto], assuming D/A ALEX
%
%      Output:
%       mainhandles - ..
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

% Default
if nargin<4 || isempty(filepath)
    filepath = pwd;
end
if nargin<5 || isempty(spot)
    spot = 0;
end
if nargin<6
    excorder = [];
end

% Insert data structure into mainhandles

if isempty(mainhandles.data)
    mainhandles.data = data;
else
    fnames = fieldnames(data);
    for j = 1:length(fnames)
        if j == 1
            mainhandles.data(end+1) = setfield(mainhandles.data(end),fnames{j},data.(fnames{j}));
        else
            mainhandles.data(end) = setfield(mainhandles.data(end),fnames{j},data.(fnames{j}));
        end
    end
end

% Name
if spot==1
    mainhandles.data(end).name = sprintf('%s (green profile)',filename);
elseif spot==2
    mainhandles.data(end).name = sprintf('%s (red profile)',filename);
else
    mainhandles.data(end).name = filename;
end
mainhandles.data(end).filepath = filepath;

%% ROIs

% Default ROIs
Droi = mainhandles.settings.ROIs.Droi; % [x y width height]
Aroi = mainhandles.settings.ROIs.Aroi;
message = 0;

% Check if default ROIs exceeds image
imwidth = size(data.imageData,1);
imheight = size(data.imageData,2);

% If ROI is positioned outside axis, set them to left and right hand side
if Droi(1)>=imwidth || Aroi(1)>=imwidth || Droi(2)>=imheight || Aroi(2)>=imheight
    Droi = [.5 .5 imwidth/2 imheight];
    Aroi = [imwidth/2+.5 .5 imwidth/2 imheight];
    message = 1;
end

% If ROI exceeds axis limits
if sum(Droi([1 3]))>=imwidth+.5 || sum(Aroi([1 3]))>=imwidth+.5
    outside = [sum(Droi([1 3]))-imwidth-.4  sum(Aroi([1 3]))-imwidth-.4]; % Number of ROI pixels outside movie in x direction [DROI AROI]
    Droi(3) = Droi(3)-max(outside); % Make ROI smaller but keep position
    Aroi(3) = Droi(3); % Make ROI smaller but keep position
    message = 1;
end
if sum(Droi([2 4]))>=imheight+.5 || sum(Aroi([2 4]))>=imheight+.5
    outside = [sum(Droi([2 4]))-imheight-.4  sum(Aroi([2 4]))-imheight-.4]; % Number of ROI pixels outside movie in x direction [DROI AROI]
    Droi(4) = Droi(4)-max(outside); % Make ROI smaller but keep position
    Aroi(4) = Droi(4); % Make ROI smaller but keep position
    message = 1;
end

% Show message
if message
    set(mainhandles.mboard,'String',sprintf(...
        'Note that the default ROI positions exceeded the image limits in %s.',filename))
end

% Store ROI
mainhandles.data(end).Droi = Droi; % Donor ROI  [x y width height]
mainhandles.data(end).Aroi = Aroi; % Acceptor ROI  [x y width height]
mainhandles.data(end).liveROIpos = [];
mainhandles.data(end).DD_ROImovie = []; % Movie frames of D_em D_exc within the D-ROI
mainhandles.data(end).AD_ROImovie = []; % Movie frames of A_em D_exc within the A-ROI
mainhandles.data(end).DA_ROImovie = []; % Movie frames of D_em A_exc within the D-ROI
mainhandles.data(end).AA_ROImovie = []; % Movie frames of A_em A_exc within the A-ROI
mainhandles.data(end).DD_ROImovieDriftCorr = []; % Movie frames of D_em D_exc within the D-ROI compensated for drift
mainhandles.data(end).AD_ROImovieDriftCorr = []; % Movie frames of A_em D_exc within the A-ROI compensated for drift
mainhandles.data(end).DA_ROImovieDriftCorr = []; % Movie frames of D_em A_exc within the D-ROI compensated for drift
mainhandles.data(end).AA_ROImovieDriftCorr = []; % Movie frames of A_em A_exc within the A-ROI compensated for drift

%% Spot profile or not

mainhandles.data(end).spot = spot; % Is 0 if it is a regular data movie file, 1 if the file is a green spot-profile, 2 if its a red profile

%% Excitation order

% Suggest an excitation order based on the D ROI intensity trace
if isempty(excorder)
    
    % Returns all D's for single-color, and suggest AD order for ALEX
    excorder = suggestExcOrder(mainhandles,data.imageData,Droi);    
end

% Excorder
mainhandles.data(end).excorder = excorder;

%% Avg. image

% Frames used for average images
if spot
    mainhandles.data(end).avgimageFrames = [1 size(data.imageData,3)]; % First and last frame in the avg. image generation [first last]

else
    % Default frames
    firstFrames = mainhandles.settings.averaging.firstFrames;
    
    if firstFrames<1
        % Old setting (% of movie, kept for old sessions)
        avgimageFrames = [1 ceil(firstFrames*length(excorder))]; % First and last frame in the avg. image
        
    else    
        % New, current setting
        if firstFrames<=length(excorder)
            avgimageFrames = [1 firstFrames];
        else
            avgimageFrames = [1 length(excorder)];
        end
    end
    
    % Store
    mainhandles.data(end).avgimageFrames = avgimageFrames;
end
mainhandles.data(end).avgimageFramesRaw = mainhandles.data(end).avgimageFrames; % Frames used for raw image

% Calculate avg. images
mainhandles = updateavgimages(mainhandles,'all',length(mainhandles.data));

%% Peaks

% Donors:
mainhandles.data(end).DpeaksRaw = []; % All peaks found by FastPeakFind
mainhandles.data(end).DpeaksMovie = []; % All peaks found by scanning the movie: cell(1,nscans)
mainhandles.data(end).Dpeaks = []; % Most intense peaks in DpeaksRaw defined by the D peak slider value
mainhandles.data(end).DpeaksGlobal = []; % Coordinates in the global image
% mainhandles.data(end).donors = struct(...
%     'xy', mainhandles.data(end).Dpeaks,...
%     'xyGlobal', mainhandles.data(end).DpeaksGlobal,...
%     'Itrace', []);

% Acceptors:
mainhandles.data(end).ApeaksRaw = [];
mainhandles.data(end).ApeaksMovie = []; % All peaks found by scanning the movie: cell(1,nscans)
mainhandles.data(end).Apeaks = [];
mainhandles.data(end).ApeaksGlobal = [];
% mainhandles.data(end).acceptors = struct(...
%     'xy', mainhandles.data(end).Apeaks,...
%     'xyGlobal', mainhandles.data(end).ApeaksGlobal,...
%     'Itrace', []);

%% FRET pairs
% NOTE: The FRETpairs field must be a single-level structure - i.e. no
% sub-sub-fields. This is required for fixing data imported from previous
% software versions.

mainhandles.data(end).FRETpairs = struct(...
    'Dxy', [],... % Donor xy coordinates in ROI (pixels)
    'Axy', [],... % Acceptor xy coordinates in ROI (pixels)
    'Dwh', [],... % Donor width and height of integration area (pixels)
    'Awh', [],... % Acceptor width and height of integration area (pixels)
    'DxyGlobal', [],... % Donor xy coordinates in global image
    'AxyGlobal', [],... % Acceptor xy coordinates in global image
    'DD_avgimage', [],... % Molecule image using D emission and D excitations
    'AD_avgimage', [],... % Molecule image using A emission and D excitations
    'AA_avgimage', [],... % Molecule image using A emission and A excitations
    'DDavgImageInterval', [],... % Frame interval used for DD molecule image [start end]
    'ADavgImageInterval', [],... % Frame interval used for AD molecule image [start end]
    'AAavgImageInterval', [],... % Frame interval used for AA molecule image [start end]
    'contrastslider', [],... % Contrast in molecule images (max intensity is: max(image)*contrast)
    'limcorrect', [],... % Round off corrections of center position used when plotting molecule images: [xlimDcorrect ylimDcorrect xlimAcorrect ylimAcorrect]
    'edges', [],... % Pixels outside ROI in order [Dedge; Aedge] where each is [left right bottom top]. Used for centering molecule in images when molecule is close to the edge of the movie
    'Dxrange', [],... % D molecule image x data range in ROImovie
    'Dyrange', [],... % D molecule image y data range in ROImovie
    'Axrange', [],... % A molecule image x data range in ROImovie
    'Ayrange', [],... % A molecule image y data range in ROImovie
    'DintMask', [],... % Mask of pixels used for calculating donor intensity. 0/1 array where 1 denotes pixels used for summing intensity
    'AintMask', [],... % Mask of pixels used for calculating acceptor intensity. 0/1 array where 1 denotes pixels used for summing intensity
    'DbackMask', [],... % Mask of pixels used for calculating donor background. [m x n] array with 0's and 1's, where 1 denotes pixels used for averaging background
    'AbackMask', [],... % Mask of pixels used for calculating acceptor background. [m x n] array with 0's and 1's, where 1 denotes pixels used for averaging background
    'backspace', [],... % Empty space in between integration ring and background ring [/pixels]
    'backwidth', [],...% Width of background elliptical line around the intensity spot [/pixels]
    'DbleachingTime', [],... % Time of donor bleaching (frame)
    'AbleachingTime', [],... % Time of acceptor bleaching (frame)
    'DblinkingInterval', [],... % Blinking intervals in donor trace
    'AblinkingInterval', [],... % Blinking intervals in acceptor trace
    'timeInterval', [],... % Time intervals in the intensity traces used for the FRET analysis [t1 t2; t1 t2; ...]. Default: [1 end]
    'DDGaussianTrace', [],... % Center, width & baseline of fitted DD Gaussian as a function of frame. [x0 y0 sx sy theta background amplitude]
    'ADGaussianTrace', [],... % Center, width & baseline of fitted AD Gaussian as a function of frame. Size [3x2xframes] with each frame being [x0 y0 sx sy theta background amplitude]
    'AAGaussianTrace', [],... % Center, width & baseline of fitted AA Gaussian as a function of frame. Size [3x2xframes] with each frame being [x0 y0 sx sy theta background amplitude]
    'DDtrace', [],... % Donor intensity trace for donor excitation
    'ADtrace', [],... % Acceptor intensity trace for donor excitation
    'ADtraceCorr', [],... % Acceptor intensity trace for donor excitation corrected for donor leakage and direct acceptor excitation (e.g. intensity due to FRET only)
    'DAtrace', [],... % Donor intensity trace for acceptor excitation
    'AAtrace', [],... % Acceptor intensity trace for acceptor excitation
    'Strace', [],... % Stoichiometry trace calculated using ADtrace and not ADtraceCorr
    'StraceCorr', [],... % Stoichiometry trace calculated using corrected acceptor emission ADtraceCorr
    'PRtrace', [],... % Proximity Ratio trace calculated using ADtrace and not ADtraceCorr
    'Etrace', [],... % FRET efficiency trace calculated using corrected acceptor emission ADtraceCorr
    'DDback', [],... % Donor background trace for donor excitation
    'ADback',[],... % Acceptor background trace for donor excitation
    'DAback', [],... % Donor background trace for acceptor excitation
    'AAback', [],... % Acceptor background trace for acceptor excitation
    'group', [],... % The (molecule) group the FRET-pair is put into by the user
    'vbfitPars', [],... % Fitted parameters from vbFRET analysis
    'vbfitE_fit', [],...
    'vbfitE_bestLP', [],...
    'vbfitE_out', [],...
    'vbfitE_mix', [],...
    'vbfitE_idx', [],...
    'vbfitE', [],... % Output structure from vbFRET analysis struct('fit','bestLP','out','mix')
    'vbfitS', [],... % Fitted S trace from vbFRET analysis. [x_hat z_hat;...] of size(length(DDtrace),2), where x_hat denotes mean S of state k and z_hat denotes state k.
    'vbfitD', [],... % Fitted DD trace from vbFRET analysis
    'vbfitA', [],... % Fitted AD trace from vbFRET analysis
    'vbfitAA', [],... % Fitted AA trace from vbFRET analysis
    'avgE', [],... % Average FRET efficiency of pair
    'avgS', [],... % Average S factor of pair
    'medianE', [],... % Median FRET efficiency of pair
    'medianS', [],... % Medien S of pair
    'maxDD', [],... % Max DD intensity
    'maxAD', [],... % Max AD intensity
    'maxAA', [],... % Max AA intensity
    'maxDAsum', [],... % Max DD+AD intensity
    'Dleakage', [],... % Donor leakage factor of this pair
    'Adirect', [],...% Direct acceptor excitation factor of this pair
    'gamma', [],... % Gamma factor of this pair
    'DleakageVar', [],... % D leakage variance
    'AdirectVar', [],... % A direct variance
    'gammaVar', [],... % Gamma variance
    'DleakageTrace', [],... % D leakage trace
    'AdirectTrace', [],... % A direct trace
    'gammaTrace', [],...% Gamma factor trace (constant)
    'DleakageIdx', [],... % Trace indices used to calculate the D leakage factor [idx(1):idx(2)]
    'AdirectIdx', [],... % Trace indices used to calculate the A direct factor [idx(1):idx(2)]
    'gammaIdx', [],... % Trace indices used to calculate the gamma factor [Aidx1 Aidx2 Aidx3 Aidx4; Didx1 Didx2 Didx3 Didx4]
    'DleakageRemoved', [],... % ~isempty when this pair was removed from correction factor trace listbox, and thus should not be returned by getPairs('Dleakage')
    'AdirectRemoved', [],... % ~isempty when this pair was removed from correction factor trace listbox, and thus should not be returned by getPairs('Adirect')
    'gammaRemoved', []); % ~isempty when this pair was removed from correction factor trace listbox, and thus should not be returned by getPairs('gamma')

mainhandles.data(end).FRETpairs(1) = [];

% Recycle bin
mainhandles.data(end).FRETpairsBin = mainhandles.data(end).FRETpairs;

%% Various

% Drift
mainhandles.data(end).drifting = struct(...
    'choice', 0,... % Choice of whether to account for drifting
    'driftmovie', mainhandles.settings.drifting.driftmovie,... % In drift compensation, use drift calculated for AA (1) or DD (2)
    'avgchoice', mainhandles.settings.drifting.avgchoice,... % Choose to average neighbouring images when detecting drift
    'avgneighbours', mainhandles.settings.drifting.avgneighbours,... % How many neighbours on either side to average
    'drift', zeros(length(find(excorder=='D')),2),... % Drift: [x y]-shift of frame i relative to fixed ref frame (usually the first)
    'upscale', mainhandles.settings.drifting.upscale); % Upsampling factor (integer). F.ex. 20 means the images will be registered within 1/20 of a pixel.

% Peaks
mainhandles.data(end).peakslider = struct(...
    'Dslider', 0,... % Value of donor peaks slider
    'Aslider', 0); % Value of acceptor peak slider

% Correction factors
mainhandles.data(end).Dleakages = []; % Collected values of donor leakage factors calculated using bleaching times of the individual molecules [molecule Dleakage;...]
mainhandles.data(end).Adirects = []; % Collected values of direct acceptor excitation factors calculated using bleaching times of the individual molecules [molecule Adirect;...]
mainhandles.data(end).gammas = []; % Collected values of gamma factors calculated using bleaching times of the individual molecules [molecule gamma;...]

% Spot profiles
mainhandles.data(end).GspotProfile = []; % Image of the green laser spot profile of this movie
mainhandles.data(end).RspotProfile = []; % Image of the red laser spot profile of this movie
mainhandles.data(end).GRspotProfile = []; % Ratio between spot profile intensities: GspotProfile./RspotProfile
mainhandles.data(end).grRatio = []; % Ratio between green and red laser intensities
mainhandles.data(end).spotMeasured = 1; % 1 if its a measured spot profile. 0 if its a Gaussian profile

% Contrast Slider
[contrastLims rawcontrast redROIcontrast greenROIcontrast] = getContrast(mainhandles,length(mainhandles.data));
mainhandles.data(end).rawcontrast = rawcontrast; % [min max] intensity in raw image /[rawMin rawMax];%mainhandles.data(end).rawcontrastMinMax
mainhandles.data(end).contrastLims = contrastLims;
mainhandles.data(end).redROIcontrast = redROIcontrast; % [min max] contast in red ROI channel
mainhandles.data(end).greenROIcontrast = greenROIcontrast; % [min max] contrast in green ROI channel

% Integration time and movie length
mainhandles.data(end).integrationTime = [];
mainhandles.data(end).rawmovieLength = size(mainhandles.data(end).imageData,3);
mainhandles.data(end).time = [];
mainhandles = createTimeVector(mainhandles,length(mainhandles.data));

% Background
mainhandles.data(end).back = []; % Store background information obtained from sif-reader
mainhandles.data(end).cameraBackground = []; % Store subtracted background so it can be subtracted if reloading the raw movie at a later time

% Transformations
mainhandles.data(end).geoTransformations = []; % Store geometrical transformations performed on the raw movie

%-----------------------------
% Update memory statusbar
mainhandles = updateMemorybar(mainhandles);

