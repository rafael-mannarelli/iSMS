function sure = mysuredlg(title, textstr)
% Creates a sure box 
%
%      Input:
%       title         - title of box
%       textstr       - info text string
%
%      Output:
%       sure          - 0: no. 1: yes
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

% Initialize
sure = 0;

% Prepare dialog
textstr = sprintf('%s\n\n     Are you sure?\n ',textstr);

% Open dialog
answer = myquestdlg(...
    textstr,...
    title,...
    ' Cancel ',...
    ' Continue ',...
    ' Continue ');

% Answer
if strcmpi(answer,' Continue ')
    sure = 1;
end
