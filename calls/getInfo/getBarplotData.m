function data = getBarplotData(ax)
% Returns x,y data from bar graph in ax
%
%    Input:
%     ax    - handle to axes containing bar plot
%
%    Output:
%     data  - bar data in ax (cell)
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

data = {};
if nargin<1
    ax = gca;
end

% Find bar plots
children = findobj(ax,'-property','FaceVertexCData');
if isempty(children)
    return
end

%% Extract relevant data coordinates

for i = 1:length(children)
    
    % Get x and y data. These are the four corners of the bars.
    x = get(children(i),'XData');
    y = get(children(i),'YData');
    temp = [x(:) y(:)];
    
    % Interpret x and y coordinates
    temp(temp(:,2)==0,:) = []; % Remove all bottom coordinates
    
    % y is every second element
    y = temp(1:2:end,2);
    
    % x is the average of every two consecutive elements
    x = temp(:,1);
    x = reshape(x,2,length(x)/2);
    x = mean(x);
    
    % All coordinates
    data{i} = [x(:) y(:)];

end

