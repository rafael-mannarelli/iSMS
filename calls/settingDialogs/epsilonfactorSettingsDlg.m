function mainhandles = epsilonfactorSettingsDlg(mainhandles)
% Settings dialog for specifying correction factor settings in direct A
% method
%
%     Input:
%      mainhandles   - handles structure of the main window
%
%     Output:
%      mainhandles   - handles structure of the main window
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


%% Prepare dialog
formats = prepareformats();
prompt = {'Epsilon of D at D exc.: ' 'epsDD';...
    'Epsilon of A at A exc.: ' 'epsAA';...
    'Donor leakage: ' 'Dleakage';...
    'Direct acceptor: ' 'Adirect'};
name = 'Correction factor settings';

formats(3,1).type = 'edit';
formats(3,1).size = 50;
formats(3,1).format = 'float';
formats(4,1).type = 'edit';
formats(4,1).size = 50;
formats(4,1).format = 'float';
formats(5,1).type = 'edit';
formats(5,1).size = 50;
formats(5,1).format = 'float';
formats(6,1).type = 'edit';
formats(6,1).size = 50;
formats(6,1).format = 'float';

% Dialog
[answer,cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled || isequal(DefAns,answer)
    return
end

%% Update

%% Nested

    function [val note] = correctValue(val,note)
        if val < 0
            val = 0;
            note = 1;
        end
    end

end