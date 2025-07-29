function mainhandles = parallelchoiceCallback(mainhandles)
% Callback for choosing whether to use parallel computing whenever possible
%
%   Input:;
%    mainhandles  - handles structure of the main window. Must contain setting
%                   with field .performance.parallel
%
%   Output:
%    mainhandles  - ...
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

% Check if parallel processing is possible
if ~mainhandles.settings.performance.parallel && ~checkforParTB()
    % Show dialog
    message = sprintf('Sorry, you can''t use parallel computing without the Parallel Computing Toolbox for MATLAB.');
    mymsgbox(message)
    return
end

% Update settings
mainhandles.settings.performance.parallel = abs(mainhandles.settings.performance.parallel-1);
updatemainhandles(mainhandles)
updatemainGUImenus(mainhandles)
