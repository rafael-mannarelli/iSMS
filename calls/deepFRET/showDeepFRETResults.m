function showDeepFRETResults(probs)
%showDeepFRETResults Display DeepFRET classification results in separate window
%
%   showDeepFRETResults(probs) creates or updates a figure showing the
%   classification confidence and percentage for each DeepFRET label. The
%   information is displayed in a standalone window so that the FRET traces
%   window remains uncluttered.

figTag = 'DeepFRETResultsWindow';
hFig = findall(0, 'Type', 'figure', 'Tag', figTag);
if isempty(hFig) || ~ishandle(hFig)
    hFig = figure('Name', 'DeepFRET classification', ...
        'Tag', figTag, 'NumberTitle', 'off');
    hAx = axes('Parent', hFig, 'Position', [0.1 0.3 0.8 0.6], ...
        'Tag', 'DeepFRETResultsAxes');
    ylabel(hAx, 'Percentage');
    hTxt = uicontrol('Parent', hFig, 'Style', 'text', ...
        'Units', 'normalized', 'Position', [0.1 0.05 0.8 0.1], ...
        'HorizontalAlignment', 'center', 'Tag', 'DeepFRETConfidenceText');
    setappdata(hFig, 'DeepFRETResultsAxes', hAx);
    setappdata(hFig, 'DeepFRETConfidenceText', hTxt);
else
    hAx = getappdata(hFig, 'DeepFRETResultsAxes');
    hTxt = getappdata(hFig, 'DeepFRETConfidenceText');
end

if isempty(probs)
    cla(hAx);
    set(hTxt, 'String', 'No DeepFRET classification available');
    return
end

labels = {'Aggregated', 'Noisy', 'Scrambled', 'Static', 'Dynamic'};
values = [probs.aggregated, probs.noisy, probs.scrambled, ...
    probs.static, probs.dynamic] * 100;
bar(hAx, values);
set(hAx, 'XTick', 1:numel(labels), 'XTickLabel', labels, 'YLim', [0 100]);
set(hTxt, 'String', sprintf('Confidence: %.1f %%', 100 * probs.confidence));

end

