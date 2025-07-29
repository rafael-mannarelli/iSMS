function [mainhandles ok] = savesettingasDefault(mainhandles,field1,field2,val)
% Save setting as default
%
%     Input:
%      mainhandles    - handles structure of the main window
%      field1/field2  - mainhandles.settings.'field1'.'field2'
%      val            - value of mainhandles.settings.field1.field2
%
%     Output:
%      mainhandles    - ..
%      ok             - 0/1 whether disk write was succesful
%

% --- Copyrights (C) ---
%
% Copyright (C)  Søren Preus, FluorTools.com
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

% Update current settings structure
mainhandles.settings.(field1).(field2) = val;
updatemainhandles(mainhandles)

% Save as default
defSettings = loadDefaultSettings(mainhandles, mainhandles.settings);
defSettings.(field1).(field2) = val;
ok = saveDefaultSettings(mainhandles,defSettings);
