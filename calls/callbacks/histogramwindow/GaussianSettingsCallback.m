function mainhandles = GaussianSettingsCallback(histogramwindowHandles)
% Callback for Gaussians options in the histogramwindow
%
%    Input:
%     histogramwindowHandles   - handles structure of the histogramwindow
%
%    Output:
%     mainhandles              - handles structure of the main window
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

% Get handles structure of the main figure window (sms)
mainhandles = getmainhandles(histogramwindowHandles); 
if isempty(mainhandles)
    return
end

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Dialog

% Prepare dialog
name = 'Gaussian fit options';

if alex
prompt = {sprintf('Enter start guesses (prioritized left to right). Separate Gaussians by space.') '';...
    'Non-specified components will be assigned a default start guess.' '';...
    'E-components: ' '';...
    'Mean: ' 'Emean';...
    'Sigma: ' 'Esigma';...
    'Weight: ' 'Eweight';...
    'Use random start guess' 'EstartRandom';...
    'Show dialog everytime fit is performed' 'Eshowdlg';...
    'S-components: ' '';...
    'Mean: ' 'Smean';...
    'Sigma: ' 'Ssigma';...
    'Weight: ' 'Sweight';...
    'Use random start guess' 'SstartRandom';...
    'Show dialog everytime fit is performed' 'Sshowdlg';...
    'E data range fitted (inf no bound)', 'EdataGaussianFit';...
    'S range (type inf for no bound)', 'SdataGaussianFit';...
    'Gaussian colors (ordered according to weight): ' 'colorOrder';...
    'Color codes: (r)ed (g)reen (b)lue (c)yan (m)agenta blac(k), etc...' ''...
    };
else
    prompt =  {sprintf('Enter start guesses (prioritized left to right). Separate Gaussians by space.') '';...
    'Non-specified components will be assigned a default start guess.' '';...
    'E-components: ' '';...
    'Mean: ' 'Emean';...
    'Sigma: ' 'Esigma';...
    'Weight: ' 'Eweight';...
    'Use random start guess' 'EstartRandom';...
    'Show dialog everytime fit is performed' 'Eshowdlg';...
    'E range (type inf for no bound)', 'EdataGaussianFit';...
    'Gaussian colors (ordered according to weight): ' 'colorOrder';...
    'Color codes: (r)ed (g)reen (b)lue (c)yan (m)agenta blac(k), etc...' ''...
    };
end

% Formats structure
formats = prepareformats();
formats(1,1).type = 'text';
formats(2,1).type = 'text';
formats(4,1).type = 'text';
formats(5,1).type = 'edit';
formats(5,1).size = 300;
formats(6,1).type = 'edit';
formats(6,1).size = 300;
formats(7,1).type = 'edit';
formats(7,1).size = 300;
formats(8,1).type = 'check';
formats(9,1).type = 'check';

if alex
    formats(13,1).type = 'text';
    formats(14,1).type = 'edit';
    formats(14,1).size = 300;
    formats(15,1).type = 'edit';
    formats(15,1).size = 300;
    formats(16,1).type = 'edit';
    formats(16,1).size = 300;
    formats(17,1).type = 'check';
    formats(18,1).type = 'check';
    
    formats(21,1).type = 'edit';
    formats(21,1).size = 100;
    formats(22,1).type = 'edit';
    formats(22,1).size = 100;
    
    formats(24,1).type = 'edit';
    formats(24,1).size = 100;
    formats(25,1).type = 'text';
else
    formats(11,1).type = 'edit';
    formats(11,1).size = 100;

    formats(14,1).type = 'edit';
    formats(14,1).size = 100;
    formats(15,1).type = 'text';
end

% E start guesses
temp = mat2str( mainhandles.settings.SEplot.Estart_mu );
DefAns.Emean = temp(2:end-1);
temp = mat2str( mainhandles.settings.SEplot.Estart_sigma );
DefAns.Esigma = temp(2:end-1);
temp = mat2str( mainhandles.settings.SEplot.Estart_weight );
DefAns.Eweight = temp(2:end-1);
DefAns.EstartRandom = mainhandles.settings.SEplot.Estart_random;
DefAns.Eshowdlg = mainhandles.settings.SEplot.EGaussStartDlg;
temp = mat2str( mainhandles.settings.SEplot.EdataGaussianFit );
DefAns.EdataGaussianFit = temp(2:end-1);

% S start guesses
if alex
    temp = mat2str( mainhandles.settings.SEplot.Sstart_mu );
    DefAns.Smean = temp(2:end-1);
    temp = mat2str( mainhandles.settings.SEplot.Sstart_sigma );
    DefAns.Ssigma = temp(2:end-1);
    temp = mat2str( mainhandles.settings.SEplot.Sstart_weight );
    DefAns.Sweight = temp(2:end-1);
    DefAns.SstartRandom = mainhandles.settings.SEplot.Sstart_random;
    DefAns.Sshowdlg = mainhandles.settings.SEplot.SGaussStartDlg;
    temp = mat2str( mainhandles.settings.SEplot.SdataGaussianFit );
    DefAns.SdataGaussianFit = temp(2:end-1);
end

DefAns.colorOrder = mainhandles.settings.SEplot.colorOrder;

% Dialog
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns); % Open dialog box
if cancelled == 1
    return
end

%% Interpret answer

Emu = str2num( answer.Emean) ;
Esigma = abs(str2num( answer.Esigma ));
Eweight = abs(str2num( answer.Eweight ));
if length(Emu)>10
    Emu = Emu(1:10);
end
if length(Esigma)>10
    Esigma = Esigma(1:10);
end
if length(Eweight)>10
    Eweight = Eweight(1:10);
end

if alex
    Smu = str2num( answer.Smean) ;
    Ssigma = abs(str2num( answer.Ssigma ));
    Sweight = abs(str2num( answer.Sweight ));
    if length(Smu)>10
        Smu = Smu(1:10);
    end
    if length(Ssigma)>10
        Ssigma = Ssigma(1:10);
    end
    if length(Sweight)>10
        Sweight = Sweight(1:10);
    end
end

% E
if ~isempty(Emu)
    mainhandles.settings.SEplot.Estart_mu(1:length(Emu)) = Emu;
end
if ~isempty(Esigma)
    mainhandles.settings.SEplot.Estart_sigma(1:length(Esigma)) = Esigma;
end
if ~isempty(Eweight)
    mainhandles.settings.SEplot.Estart_weight(1:length(Eweight)) = Eweight;
end
mainhandles.settings.SEplot.Estart_random = answer.EstartRandom;
Erange = str2num( answer.EdataGaussianFit );
if isempty(Erange)
    Erange = [-inf inf];
elseif length(Erange)==1
    Erange = [Erange Erange];
end
mainhandles.settings.SEplot.EdataGaussianFit = Erange;
mainhandles.settings.SEplot.EGaussStartDlg =  answer.Eshowdlg;

% S
if alex
    if ~isempty(Smu)
        mainhandles.settings.SEplot.Sstart_mu(1:length(Smu)) = Smu;
    end
    if ~isempty(Ssigma)
        mainhandles.settings.SEplot.Sstart_sigma(1:length(Ssigma)) = Ssigma;
    end
    if ~isempty(Sweight)
        mainhandles.settings.SEplot.Sstart_weight(1:length(Sweight)) = Sweight;
    end
    mainhandles.settings.SEplot.Sstart_random = answer.SstartRandom;
    Srange = str2num( answer.SdataGaussianFit );
    if isempty(Srange)
        Srange = [-inf inf];
    elseif length(Srange)==1
        Srange = [Srange Srange];
    end
    mainhandles.settings.SEplot.SdataGaussianFit = Srange;
    mainhandles.settings.SEplot.SGaussStartDlg = answer.Sshowdlg;
end

% Color
colorOrder = lower(answer.colorOrder);
colorOrder = strrep(colorOrder,' ','');
colorOrder = strrep(colorOrder,'_','');
colorOrder = strrep(colorOrder,'*','');
colorOrder = strrep(colorOrder,'.','');
colorOrder = strrep(colorOrder,',','');
colorOrder = strrep(colorOrder,';','');
colorOrder = strrep(colorOrder,':','');
mainhandles.settings.SEplot.colorOrder(1:length(colorOrder)) = colorOrder;

%% Update handles structure

updatemainhandles(mainhandles)
