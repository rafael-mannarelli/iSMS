function plotDeepFRETConfidence(handles)
%plotDeepFRETConfidence Plot DeepFRET confidence for each FRET pair
%
%   plotDeepFRETConfidence(handles) gathers the DeepFRET classification
%   confidence stored in each FRET pair and displays them in a bar plot.
%
%   Input:
%       handles - structure or figure handle from which to obtain
%                 the mainhandles structure. If omitted the function
%                 will attempt to obtain it from the current figure.
%
%   The function expects that traces have already been classified using
%   classifyWithDeepFRET so that the fields 'DeepFRET_confidence' exist.
%
%   Example:
%       plotDeepFRETConfidence(gcf);
%
% --- Copyrights (C) ---
% iSMS - Single-molecule FRET microscopy software
% Copyright (C) Aarhus University, @ V. Birkedal Lab
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

if nargin < 1 || isempty(handles)
    handles = getappdata(0,'mainhandle');
end

mainhandles = getmainhandles(handles);
if isempty(mainhandles) || ~isfield(mainhandles,'data') || isempty(mainhandles.data)
    errordlg('No data available to plot DeepFRET confidence.', 'DeepFRET');
    return
end

conf = [];
labels = {};
for f = 1:numel(mainhandles.data)
    pairs = mainhandles.data(f).FRETpairs;
    for p = 1:numel(pairs)
        if isfield(pairs(p),'DeepFRET_confidence')
            conf(end+1) = pairs(p).DeepFRET_confidence * 100; %#ok<AGROW>
        else
            conf(end+1) = NaN; %#ok<AGROW>
        end
        labels{end+1} = sprintf('%d-%d', f, p); %#ok<AGROW>
    end
end

figure('Name','DeepFRET confidence per trace');
bar(conf);
ylabel('Confidence (%)');
xlabel('File-Pair');
title('DeepFRET classification confidence');
set(gca,'XTick',1:numel(labels),'XTickLabel',labels);
set(gca,'XTickLabelRotation',90);
end
