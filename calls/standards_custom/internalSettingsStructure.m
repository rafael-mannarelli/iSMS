function settings = internalSettingsStructure(~)
% This file initializes the internal default settings. To add a new setting
% to the program, simply add the additional field below. The settings
% structure is stored and accessed in mainhandles.settings (the handles
% structure of the main window).
%
% When a setting field is defined below, the default settings structure in
% /settings/default.settings is automatically updated to include the new
% field.
%
%  OBS: Settings initialized below are overwritten on startup by a default
%  settings structure saved to the default.settings mat-file located in the
%  'settings' subfolder. To restore all settings to the internal defaults
%  below, simply delete the default.settings file (a new one will be
%  created on startup using the settings below).
%
%     Input:
%      (none)
%
%     Output:
%      settings   - all settings MUST be defined using two subfields. E.g.
%                   settings.startup.memoryMessage = 1, etc.
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

%% .startup.  Starting up the program
settings.startup = struct(...
    'firstrun', 1,... % Is the first time program is run
    'firstloaddata', 1,... % Is the first time raw data is being loaded
    'memoryMessage', 1,... % Choice of whether to display warning about MATLAB memory upon startup
    'javaMessage', 1,... % Choice of whether to display warning about Java memory upon startup
    'zoomMessage', 1,... % Choices of whether to display warning about screen resolution upon startup
    'DPI', 96,... % New DPI if previous was 116
    'setDPI', 1,... % Set new DPI upon startup
    'checkMATLAB', 1,... % Check for MATLAB version
    'checkToolbox', 1,... % Check for required toolboxes
    'checkforUpdates', 1); % Check for updates upon startup
%% .close.  Closing down the program
settings.close = struct(...
    'asktosave', 1); % Ask to save session
%% .infobox.  Displaying information message boxes
settings.infobox = struct(...
    'ROI', 1,... % Guide on ROIs
    'memory', 1,... % Info on RAM memory problems
    'copydatatoclipboard', 1,... % Guide on data copied to clipboard
    'copydatatoworkspace', 1,... % Guide on data saved to workspace
    'copydatatofile', 1,... % Guide on data saved to file
    'peakfinder', 1,... % Peakfinder guide
    'peaksliderWarning', 1,... % Warning on missing data when dragging sliders
    'addDApeaks', 1,... % Display guide about how to select D and A peaks manually in the main window
    'removeDApeaks', 1,... % Display guide box about how to remove D and A peaks manually in the main window
    'addEpeaks', 1,... % Display guide about how to select E pairs manually in the main window
    'autorun', 1,... % How auto-run works
    'removepair', 1,...% Info after deleting pair
    'fastbin', 1,... % Info on molecules moved to bin using menu shortcut
    'filterpairs', 1,... % Show info about pairs being removed by filter
    'lasso', 1,... % How lasso selection works in main window
    'SElasso', 1,... % How lasso selection works in histogram window
    'gaussprogress', 1,... % See progressbar of Gauss PSF parfor in workspace message
    'openFRETpairBin', 1,... % How the open recycle bin works
    'pixelhighlighting', 1,... % Info on pixel highlighting slowing down program
    'backgroundPixels', 1,... % How to select background pixels
    'framesliders', 1,...% How to use the molecule frame sliders in the FRETpairwindow
    'plotmolspec', 1,... % In
    'bleachfinder', 1,... % Info on bleachfinder
    'copySElassotoclipboard', 1,... % Lasso selection has been copied to clipboard
    'integrationROI', 1); % How to use the integration ROI in the FRETpairwindow
%% .settings.  Settings for settings
settings.settings = struct(...
    'askdefault', 1); % Ask to save settings as new default after settings dialogs
%% .performance.  Performance
settings.performance = struct(...
    'parallel', 0); % Use parallel computing whenever possible
%% .ROIs.  Default ROI positions
settings.ROIs = struct(...
    'Droi', [2, 5, 200, 500],... % Default green ROI position
    'Aroi', [312,  2,  200,  500]); % Default red ROI position
%% .import.  Import
settings.import = struct(...
    'askforframes', 0,... % Ask for number of frames to import
    'reloadROIonly', 1,... % Whether to only reload ROI movies when reloading into RAM from file
    'importRaw', 1); % Import raw data too when importing from another session
%% .excitation.  Excitation scheme
settings.excitation = struct(...
    'alex', 1); % Alex is default excitation scheme
%% .peakfinder.  Finding peaks and FRET-pairs
settings.peakfinder = struct(...
    'choice', 1,... % Algorithm choice: 1) find in selected frame, 2) scan movie
    'subpixel', 0,... % Use sub-pixel localization
    'liveupdateFRETpairs', 1,... % Find new FRET pairs every time the peak sliders are changed
    'DsliderValue', 0.3,... % Default D peak slider value
    'AsliderValue', 0.3,... % Default A peak slider value
    'Dthreshold', 0.5,... % Threshold of D peak finder algorithm (percent of most intense pixels)
    'Athreshold', 0.5,... % Threshold of D peak finder algorithm (percent of most intense pixels)
    'DpeakIntensityThreshold', 15,... % Peak intensity treshold for automated peakfinder
    'ApeakIntensityThreshold', 15,... % Peak intensity treshold for automated peakfinder
    'maxpeaks', 500,... % Maximum number of peaks
    'DatA', 0,... % Put a D at every A position (good for high FRET)
    'AatD', 0,... % Put an A at every D position (good for low FRET)
    'useSpot', 1,... % Apply excitation spot intensity correction when sorting peaks according to intensity
    'useBack', 1,... % Apply background subtraction when sorting peaks according to intensity
    'avgFrames', 50,... % Number of frames to avg at each step when 'choice' is 2
    'stepsize', 1,... % Frame step size when 'choice' is 2
    'scanperc', 1,... % Scan percentage of full movie when 'choice' is 2
    'distCriteria', 4,... % Distance criteria for defining two peaks as being identical when using 'choice' 2 /#frames
    'DsliderInternal', 0.2,... % "D-slider value" used for extracting the most intense peaks at each iteration of 'choice' 2
    'AsliderInternal', 0.2,... % "A-slider value" used for extracting the most intense peaks at each iteration of 'choice' 2
    'Ecriteria', 5); % Criteria for a FRET-pair in the FRET-finder (pixel separation of D and A peak)
%% .view.  Movie orientation
settings.view = struct(...
    'rotate', 0,... % Rotate movie 90 degrees
    'flipud', 0,... % Flip movie up/down
    'fliplr', 0,... % Flip movie left/right
    'rawlogscale', 1,... % Plot raw image in logscale
    'rawcolormap', 'jet',... % Colormap for the raw image plot
    'imagesc', 1,... % Auto scale raw image
    'ROIsqrt', 0,... % Square-root ROI image intensities
    'ROIgreen', 1,... % Show green channel in ROI image
    'ROIred', 1,... % Show red channel in ROI image
    'ROIimage', 1,... % Plot in ROI image: Green-red overlay (1), green only (2), red only (3)
    'colorblind', 0,... % 0/1 whether to use colors optimized for colorblindness
    'rawcontrast1', 1,... % Default value of raw contrast (min)
    'rawcontrast2', 0.9,... % Default value of raw contrast (max)
    'redcontrast1', 1,... % Default value of red contrast (min)
    'redcontrast2', 0.25,... % Default value of red contrast (max)
    'greencontrast1', 1,... % Default value of green contrast (min)
    'greencontrast2', 0.3,... % Default value of green contrast (max)
    'framesliders', 1,... % Activate frame sliders
    'contrastsliders', 1); % Activate contrast sliders
%% .averaging.  Frame averaging
settings.averaging = struct(...
    'avgDchoice', 'Dexc',... % Frames used to average donor ROI image. 'all' or 'Dexc' (default: avg. from D-excitation frames only)
    'avgAchoice', 'Aexc',... % Frames used to average acceptor ROI image. 'all', 'Dexc' or 'Aexc'
    'avgrawchoice' , 'all',... % Frames used to average raw image
    'firstFrames', 100); % First frames used in averaged image
%% .denoisingWaveletMultiframe.  Image denoising using wavelet multiframe:
settings.denoisingWaveletMultiframe = struct(...
    'nframes', 10,... % Number of frames used for analysis
    'k', 1,...
    'p', 5,...
    'r', 2,...
    'maxLevel', 1,...
    'weightMode', 4,...
    'windowSize', 2,...
    'basis', 1); % 1: 'Haar'. 2: 'dualTree'
%% .integration.  Intensity integration:
settings.integration = struct(...
    'wh', [5 5],... % Default width and height of D and A elliptical integration areas
    'type', 1,... % How intensity is calculated: 1) sum pixel values, 2) fit 2D Gaussian MELwG, 3) fit 2D Gaussian by LSQ (GME)
    'equalPixels', 0,... % Use the same number of intensity pixels for both D and A
    'posLim', 1,...% Allowed shift radius of initial peak position /pixels
    'sigmaLim', [0 2],... % Min and max of Gaussian width /pixels
    'thetaLim', [0 360],... % Min and max of Gaussian rotation angle
    'constrainGaussianCenter', 0,... % If using 2D Gaussian, constrain its center based on average image?
    'constrainGaussianFWHM', 0,... % If using 2D Gaussian, constrain its FWHM based on average image?
    'threshold', 0.3); % Value between 0 and 1 determining when to stop Gaussian fitting algorithm (0 is for speed, 1 is for accuracy)
%% .background.  Background subtraction:
settings.background = struct(...
    'choice', 1,... % Use background subtraction
    'cameraBackgroundChoice', 4,... % 1) mean backgr. image, 2) subtr. backgr.image from each frame, 3) subtr. smoothed backg.image from each frame 4) subtr. manual value, 5) No
    'cameraOffset', 90,... % Camera offset (minimum counts on the detector)
    'checkOffset', 0,... % Check if the offset value exceeds 50 % of the pixels in the movie
    'smthKernel', 2,... % Kernel size if using smoothed background image as camera background (1:3x3; 2:5x5; 3:7x7; 4:9x9; 5:15x15)
    'backtype', 1,... % How background is calculated. 1 = avg intensity just outside integration area. 2 = median of background ring. 3 = Percentile (LSP)
    'prctile', 57,... % Percentile value for the LSP estimator
    'minDarkFrames', 5,... % Minimum number of frames needed in order to use dark state as background (dark state = bleaching or blinking)
    'bleachchoice', 0,... % Whenever possible, use average intensity after bleaching
    'blinkchoice', 0,... % Whenever possible, use average intensity during blinking
    'blinkbleachchoice', 1,... % If both blinking and bleaching is defined use 1)lowest of the two 2)avg of the two 3)bleach 4) blink
    'avgchoice', 2,... % 1 = Don't use averaging. 2 = Use averaging of neighbouring frames in background calculation. 3 = Use background averaged from all frames
    'avgneighbours', 3,... % How many neighbours to average (if avgchoice == 2)
    'backspace', 2,... % Empty space in between integration ring and background ring [/pixels]
    'backwidth', 1); % Width of background elliptical line around the intensity spot [/pixels]
%% .multisignature.  Multi-aperture signature plot
settings.multisignature = struct(...
    'minAperture', 1,...
    'maxAperture', 10,...
    'backspace', 2,...
    'backwidth', 1,...
    'backtype', 1);
%% .corrections.  Correction factors
settings.corrections = struct(...
    'Dleakage', 0.0,... % Leakage factor taking into account donor emission in acceptor channel. l = f_Aem_Dexc / f_Dem_Dexc (ratio between D emission spectrum at lambdaA and D)
    'Adirect', 0.0,... % Direct acceptor excitation factor at donor excitation wavelength. d = f_Aem_Dexc / f_Aem_Aexc (ratio between D and A epsilons at lambaD)
    'gamma', 1,... % Gamma factor: QY_A/QY_D * (n_A/n_D), where n is detection efficiency
    'spacer', 5,... % Default number of frames after/before bleaching not used for correction factor calculation
    'gammaframes', 25,... % Default number of frames on either side of A bleaching used for calculating the gamma factor
    'minframes', 5,... % Minimum number of frames for correction factor calculation
    'Eframes', 10,... % Frames used for calculating FRET at bleaching time
    'molspec', 0,...% Molecule-specific correction factors
    'medianI', 0,... % 1) Use median intensities. 0) Use mean intensities
    'globalavgChoice', 2,... % Average correction factor value: 1) Mean; 2) Weighted mean; 3) Median
    'FRETmethod', 0,... % How to calculate FRET: 0) traditional ratiometric. 1) Direct A ref
    'epsAA', 83000,... % Epsilon of A at A wvl (for FRETmethod=1)
    'epsAD', 5400,... % Epsilon of A at D wvl
    'epsDD', 70000); % Epsilon of D at D wvl
%% .FRETpairplots.  Time-trace plots
settings.FRETpairplots = struct(...
    'time', 1,... % Plot traces in units of time (s)
    'DAtraceColor', 1,... % Plot donor in green and A in red (1), or plot both in blue (0)
    'plotADcorr', 0,... % Plot AD trace corrected for cross-talk
    'plotDgamma', 0,... % Plot D intensity multiplied by gamma
    'zeroline', 1,... % Add zero line to trace plot. 1 or 0
    'plotBackground', 1,... % Plot just the corrected intensities (0), the raw intensities+background traces (1) or just the background traces (2)
    'backgroundColor', [0 0 0],... % Color of background traces. Default: black
    'showIntPixels', 0,... % Show/highlight pixels used for calculating intensities in molecule image Axes
    'showBackPixels', 0,... % Show/highlight pixels used for calculating background in molecule image Axes
    'intMaskTransparency', 0.4,... % Transparency level (alpha) of pixels highlighted by the showIntPixels feature [0:1]
    'backMaskTransparency', 0.4,... % Transparency level (alpha) of pixels highlighted by the showBackPixels feature [0:1]
    'intMaskColor', 'white',... % Color of pixels highlighted by the showIntPixels feature. 'white' or 'gray'
    'backMaskColor', 'gray',... % Color of pixels highlighted by the showBackPixels feature. 'white' or 'gray'
    'exPixels', 3,... % Extra pixels inserted in each side of molecule image axes (zoom out effect)
    'liveupdateTrace', 0,... % Live-update trace when selecting pixels
    'linkaxes', 1,... % Link x-axes of the trace-plots. 1 or 0
    'autozoom', 1,... % Auto-zoom the y-axis of the trace plots
    'Sylim', [0 1],... % y-limits in S trace
    'Eylim', [0 1],... % y-limits in E trace
    'logImage', 0,... % Plot molecule images on logscale
    'contrastslider', 1,... % Default contrast in molecule images (max intensity is: max(image)*contrast)
    'frameSliders', 0,... % Show averaging interval sliders for molecule images (0/1)
    'linkFrameSliders', 0,... % Choice of whether the image sliders should be linked (0/1)
    'sortpairs', 1,... % How to sort FRET pairs in the FRETpair window: 1) according to file. 2) According to group. 3) avg. FRET...
    'avgFRET', 0,... % Show avg. FRET value in brackets after the FRET pair in the FRETpairwindow
    'filterchoice', 0);
%% .SEplot.  E-S histogram plot window:
settings.SEplot = struct(...
    'xlim', [-.1 1.1],... % X-limits in SE-plot
    'ylim', [-.1 1.1],... % Y-limits in SE plot
    'EhistTicks', 3,... % Number of y-ticks in E histogram
    'ShistTicks', 3,... % Number of y-ticks in S histogram
    'markersize', 3,... % Size of markers in SE-plot
    'SEplotType', 1,... % Type of E-S scatter plot. 1) regular. 2) scatdensity. 3) image density
    'exceptchoice', 3,... % Plot all except 1) selected pairs, 2) selected files, 3) selected groups
    'onlytinterest', 1,... % Plot only time-interval of interest whenever this has been defined
    'excludeBlinking', 1,... % Exclude blinking intervals from plot
    'framespacer', 2,... % Spacer from bleaching/blinking not included in plot
    'valuesplotted', 1,... % 1) all frames. 2) avg values. 3) median values
    'maxframes', 0,... % Max number of frames included from each molecule. 0 is all
    'plotgammaspec', 0,...% If using molecule-specific correction factors, plot only molecules with correction factors determined: gamma
    'plotdleakspec', 0,...% If using molecule-specific correction factors, plot only molecules with correction factors determined: d leakage
    'plotadirectspec', 0,...% If using molecule-specific correction factors, plot only molecules with correction factors determined: a direct
    'inverseS' , 0,... % Plot 1/S vs. E
    'colormap', 'jet',... % Colormap of SE density plot: []
    'colorinversion', 0,... % Use color inversion for colormaps so that black becomes white and white becomes black
    'colorOrder', 'rgbcykmrgbc',... % Order of Gaussian components color
    'traces', struct(... % Data points plotted
    'S', [],...
    'E', []),...
    'GaussianType', 1,... % 1) 1D Gaussian to E-hist. 2) 2D Gaussian to ES-hist
    'nGaussians', 1,... % Number of Gaussian components used to fit SE scatter plot
    'EdataGaussianFit', [-inf inf],...
    'SdataGaussianFit', [-inf inf],...
    'maxGaussians2D', 7,... % Max number of Gaussians in SE 2D plot
    'maxGaussians1D', 5,... % Max number of Gaussians in SE 1D plot
    'Gaussians', struct(... % Gaussian components in SE scatter plot (2D)
    'mu', [],... % Mean of this component
    'sigma', [],... % Width of this component
    'weight', [],... % Weight of this component
    'amplitude', [],... % Weight of this component
    'color', []),... % Color assigned to this component
    'EGaussians', struct(... % Gaussian components in E hist plot (1D)
    'mu', [],... % Mean of this component
    'sigma', [],... % Width of this component
    'weight', [],... % Weight of this component
    'amplitude', [],... % Amplitude in histogram plot
    'x', [],... % x vector
    'y', [],... % y-vector
    'color', []),... % Color assigned to this component
    'SGaussians', struct(... % Gaussian components in E hist plot (1D)
    'mu', [],... % Mean of this component
    'sigma', [],... % Width of this component
    'weight', [],... % Weight of this component
    'amplitude', [],... % Amplitude in histogram plot
    'x', [],... % x vector
    'y', [],... % y-vector
    'color', []),... % Color assigned to this component
    'EGaussStartDlg', 1,...% Show start guess dialog when fitting Gaussians
    'SGaussStartDlg', 1,...% Show start guess dialog when fitting Gaussians
    'ESGaussStartDlg', 1,...% Show start guess dialog when fitting Gaussians
    'Estart_random', 0,... % How to start guess. 1) random. 0) manual
    'Estart_mu', [0.2 0.8 0.4 0.6 0.3 0.7 0.5 0.1 0.9 0 1],... % Start mean guess for E
    'Estart_sigma', ones(1,11)*0.01,... % Start sigma guess for E
    'Estart_weight', ones(1,11),... % Start weith guess for E
    'Sstart_random', 0,... % How to start guess. 1) random. 0) manual
    'Sstart_mu', [0.5 0 1 0.2 0.8 0.4 0.6 0.3 0.7  0.1 0.9],... % Start mean guess for S
    'Sstart_sigma', ones(1,11)*0.01,... % Start sigma guess for S
    'Sstart_weight', ones(1,11),... % Start weith guess for S
    'EGaussTot', [],... % Summed E-gauss
    'SGaussTot', [],... % Summed E-gauss
    'GaussColorChoiceHist', 1,... % Choice of whether to plot different Gaussian components in different colors. 1 or 0
    'GaussColorChoiceSE', 0,... % Choice of whether to plot different Gaussian components in different colors. 1 or 0
    'ScatOrSurf', 'scat',... % Choice of whether to plot scatter data and/or smoothed surface: 'scat': scatter only, 'surf': surface only, 'both': both
    'binFaceColor', [0.043137  0.51765  0.78039],... % Histogram face color
    'binEdgeColor', [0.25  0.25  0.25],... % Histogram edge color
    'plotBins', 1,... % Plot binned E and S histograms
    'plotEfit', 1,... % Plot fitted E histograms (full-drawn lines)
    'plotSfit', 0,... % Plot fitted S histograms (full-drawn lines)
    'plotEfitTot', 1,... % Plot summed E-fit
    'plotSfitTot', 0,... % Plot summed S-fit
    'plotBleaching', 2,... % (1)Plot all data , (2)before 1st bleach , (3)after 1st bleach , (4)before 2nd bleach , (5)after 2nd bleach , (6)D only , (7)A only , (8)D only and A only 
    'GaussianComponentsTable', 0,... % Show table window with Gaussian components specifications (mu, and sigmas)
    'lockEbinsize', [],... % locked bin size. isempty if don't lock.
    'lockSbinsize', [],... % locked bin size. isempty if don't lock.
    'showbins', 1,... % Show bin info text boxes in SE window
    'showbinsType', 2,... % Show number of bins (1) or bin size (2)
    'xlimEexport', [0 1],... % Default E limits for exporting new E hist window
    'ylimEexport', [0.25 0.75],... % Default S limits for exporting new E hist window
    'nGaussiansEexport', 0,... % Number of Gaussians used to fit histogram when making new window
    'lassoCopy', 1,... % Copy lasso selection to clipboard
    'lassoOrigin', 1,... % Plot infor on where lasso selection originate from
    'lassoNewgroup', 0,... % Create new group of selected points
    'lassoPairlabelThreshold', 0.2); % Percent of most intense pairs from lasso selection tool that are labeled with a text label
%% .correctionfactorplot.  Correction factor plots
settings.correctionfactorplot = struct(...
    'factorchoice', 3,... % Chosen factor in the correction factor window. 1: D leakage. 2: A direct. 3: gamma.
    'sortpairs', 1,... % How to sort pairs in listbox
    'showBleaching', 0,... % Show bleaching times in trace plots
    'showInterval', 1,... % Show time-interval used calculating the correction factor in the trace plots
    'histogramplot', 1,... % What to plot in correction factor histogram: 1) regular histogram. 2) Factor vs. FRET
    'exportTracePlots', 1,... % Default choice of whether to export trace plots when exporting figure
    'exportHistPlot', 1,... % Default choice of whether to export histogram plot when exporting figure
    'ax4', 1,... % What to plot in 4th axes in correction factor window
    'plotfactorvalue', 1,... % Plot correction factor value along with correction factor trace in ax4
    'surflabels', 0); % Show text label in correction factor surface plot
%% .grouping.  Molecule grouping:
settings.grouping = struct(...
    'colorList', 1,... % Use color-codes for individual groups? Default: yes
    'nameList', 1,... % Show group-name in FRET-pair listbox
    'highlight', 0,... % Use bold highlighting of selected groupmembers in the FRETpair listbox
    'removefromPrevious', 1,... % Remove molecules from previous group when adding them to an existing group group
    'checkforemptyGroups', 1,... % Show dialog on empty groups
    'distplottype', 1,... % Default plot type of distribution plot
    'distplotShowvalues', 1,... % Show percentage values in distribution plot
    'distplotColor', 1,... % Color distribution plot according to group colors
    'showNoGroup', 0); % Show string (no group) for pairs with no group
%% .bin.  Recycle bin
settings.bin = struct(...
    'open', 0,... % Choice of whether the recycle bin is open
    'lastpair', []); % Last binned pairs: [file pair]
%% .autoROI.  Auto-ROI alignment function:
settings.autoROI = struct(...
    'npeaks', 40,... % Number of peaks (max) used for aligning D and A ROIs automatically
    'showpeaks', 0,... % Show the peaks used for aligning D and A ROIs automatically. 0 = no, 1 = yes
    'refframe', 1,... % Fixed frame in alignment. 1 = D-ROI. 2 = A-ROI.
    'autoResize', 1,... % Use auto-resizing for aligning ROIs
    'lowerSize', 20); % Lower ROI size in the auto-resize process
%% .autorun.  Autorun button
settings.autorun = struct(...
    'AllFiles', 1,... % Choice of whether to run auto analysis of all files (1) or just selected (2), when pressing the green play button in the toolbar
    'autoROI', 0,... % Choice of whether to auto-align ROIs as a first step in the auto-run
    'autoBleach', 1,... % Choice of whether to run bleach finder as a final step
    'filter1', 0,... % Apply molecule filter 1
    'filter2', 0,... % Apply molecule filter 2
    'filter3', 0,... % Apply molecule filter 3
    'groupbleach', 0); % Molecules with bleaching
%% .drifting.  Drift analysis:
settings.drifting = struct(...
    'avgchoice', 1,... % Choose to average neighbouring images when detecting drift
    'avgneighbours', 3,... % How many neighbours to average
    'driftmovie', 1,... % Apply the drift calculated of AA movie (1) or DD movie (2)
    'upscale', 100); % Resolution/Upsampling factor (integer). F.ex. 20 means the images will be registered within 1/20 of a pixel.
%% .filterPairs.  Filtering FRET pairs according to criteria
settings.filterPairs = struct(...
    'permanentfilters', 0,... % Keep filters permanent, so that molecules are automatically filtered all the time
    'filterselected', 0,... % Only filter pairs in the selected movie file
    'filter1', 0,... % Default choice of whether to use filter1
    'filter1frames', 50,... % Most intense frames used for filter 1
    'filter1counts', 500,... % Minimum counts of the average intensity of the 'filter1frames' most intense frames
    'filter2', 0,... %  Default choice of whether to use filter2
    'filter2dist', 10,... % Closest distance to a neighbouring peak (pixels)
    'filter3', 0,... % Default choice of whether to use filter3
    'filter3frames', 10,... % Remove pairs with bleaching occuring within the first x frames
    'filter4', 0,... % Use filter 4
    'filter4frames', 50,...
    'filter4counts', 1500);
%% .spot.  Laser spot profiles
settings.spot = struct(...
    'choice', 0,... % Choice of whether to use spot-profile corrections
    'kernelsize', 50,... % Median filter kernal size
    'grRatio', 1); % Default ratio between green and red laser intensity
%% .vbFRET.  vbFRET time-trace analysis
settings.vbFRET = struct(...
    'minStates', 1,... % Minimum number of FRET states
    'maxStates', 4,... % Max number of FRET states
    'startGuess', [],... % Start guesses for FRET states [E1,E2,...]
    'useStartGuess', 1,... % Use the user-defined start guesses
    'upi', 1,... % Probability of first state being state k
    'mu', 0.5,... % Mean of FRET Gaussian distribution of state k
    'beta', 0.25,... % Spread of Gaussian of state k
    'W', 50,... % Gamma-distribution parameter of state k
    'v', 5,... % Gamma-distribution parameter of state k
    'ua', 1,... % Related to transition probability between states
    'uad', 0,... % Related to transition probability between state
    'attempts', 5,... % Fitting attempts per trace
    'maxIter', 100,... % Stop after maxIter iterations if program has not yet converged
    'threshold', 1e-5,... % Stop when two iterations have the same evidence to within this
    'cutBleach', 1); % Choice of whether to cut traces at first bleaching event in the analysis (1 yes, 0 no)
%% .dynamicsplot.  Dynamics window
settings.dynamicsplot = struct(...
    'fit', 1,... % Choice of whether to fit the dwell time histogram using an exponential rate equation
    'histtype', 1,... % 1) Cumulative sum. 2) Binned histogram
    'exponentials', 1,... % Number of exponentials used in fitting reaction rate from dwell time histogram
    'includeEnds', 0,... % Choice of whether to include the first and final state in the trace in the histogram plot
    'colorEnds', 2,... % Color of end dwell times: 1) Same as rest. 2) Red. 3) Green. 4) Blue.
    'exportTracePlot', 1,... % Default choice of whether to export trace plot when exporting figure from dynamicswindow
    'exportHistPlot', 1); % Default choice of whether to export histogram plot when exporting figure from dynamicswindow
%% .psfWindow.  PSF parameter window
settings.psfWindow = struct(...
    'type' , 1,... % 1: MLEwG. 2: GME.
    'avgneighbours', 1,...
    'showBleaching', 1,... % Choice of whether to highlight bleaching time in trace plots
    'axes1color', [0 0 1],... % Color of trace in axes 1
    'axes2color', [0 0 0]); % Color of trace in axes 2
%% .bleachfinder.  Bleach finder
settings.bleachfinder = struct(...
    'findD', 1,...
    'findA', 1,...
    'Athreshold', 200,... % AA intensity threshold
    'Dthreshold', 750,... % DD intensity threshold for D bleaching
    'allow', 10); % Consecutive frames allowed to deviate above threshold
%% .contrastslider.  Contrast slider
settings.contrastslider = struct(...
    'rawcontrast', [0.2 0.6],... % Default raw contrast values
    'redROIcontrast', [0.25 0.6],... % Default ROI contrast red channel
    'greenROIcontrast', [0.35 0.6],... % Default ROI contrast green channel
    'defaultValue', 0.3,... % Default value of the contrast slider
    'constrain', 0); % Constrain the slider value interval so that it does not change when moving the ROI frame slider
%% .save.  Saving sessions
settings.save = struct(...
    'saveROImovies', 0,... % Save ROI movies to session file
    'opensubGUIs', 0,... % Open sub windows when loading session
    'askforraw', 1,... % Ask to load raw data upon opening session
    'setwindowSize', 0); % Adjust window size when loading sessions
%% .export_fig.  Exporting figures
settings.export_fig = struct(...
    'format', 2,... % 1)png 2)tif 3)jpg 4)bmp 5)pdf 6)eps
    'renderer', 1,... % 'Default' 'opengl' 'painters' 'zbuffer'
    'colorspace', 1,... % 'RGB' 'CMYK' 'gray'
    'resolution', 300,... % ppi
    'cropped', 1,... % Cropped borders
    'transparent', 0,... % Transparent background
    'antialias', 4,... % anti-aliasing 0-4
    'compression', 5); % Compression 0-100
%% .coordinatecorrelationPlot.  Coordinate correlation plots
settings.coordinatecorrelationPlot = struct(...
    'showtext', 1,... % Show text labels
    'showmarker', 1); % Show markers
%% .filtering.  Filtering traces
settings.filtering = struct(...
    'plotraw', 1,...
    'type', 1,...
    'medianFrames', 3,...
    'filterorder', 12,... % Filter order
    'hpf', 0.15); % Half-power frequency
