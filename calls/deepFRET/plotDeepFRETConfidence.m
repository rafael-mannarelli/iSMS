function plotDeepFRETConfidence(mainhandles)
%PLOTDEEPFRETCONFIDENCE Plot DeepFRET confidence for all traces
%
%   PLOTDEEPFRETCONFIDENCE(mainhandles) will create a bar chart of the
%   DeepFRET classification confidence for each FRET pair in the session.
%   The input can be the handles structure or the handle to the main
%   iSMS window.
%
%   Example:
%       mainhandles = guidata(mainWindowHandle);
%       plotDeepFRETConfidence(mainhandles);
%
%   The function expects that DeepFRET classification has already been
%   performed so that each FRET pair contains the field
%   'DeepFRET_confidence'.

if nargin < 1 || isempty(mainhandles)
    error('mainhandles structure or handle is required');
end

if ishandle(mainhandles)
    mainhandles = guidata(mainhandles);
end
if isempty(mainhandles) || ~isstruct(mainhandles)
    error('Invalid handles structure');
end

confValues = [];
labels = {};

for f = 1:numel(mainhandles.data)
    pairs = mainhandles.data(f).FRETpairs;
    for p = 1:numel(pairs)
        if isfield(pairs(p),'DeepFRET_confidence') && ~isempty(pairs(p).DeepFRET_confidence)
            confValues(end+1) = pairs(p).DeepFRET_confidence; %#ok<AGROW>
            labels{end+1} = sprintf('(%d,%d)', f, p); %#ok<AGROW>
        end
    end
end

if isempty(confValues)
    warning('No DeepFRET confidence values found');
    return
end

figure('Name','DeepFRET Confidence');
bar(confValues*100);
set(gca,'XTick',1:numel(confValues));
set(gca,'XTickLabel',labels);
set(gca,'XTickLabelRotation',45);
ylabel('Confidence (%)');
title('DeepFRET classification confidence per trace');
end
