function mainhandles = setHistLimitsCallback(hwHandles)
% Callback for setting axes limits in the histogram window
%
%    Input:
%     hwHandles   - handles structure of the histogram window
%
%    Output:
%     mainhandles - handles structure of the main window
%

%% Initialize

% Get mainhandles
mainhandles = getmainhandles(hwHandles);
if isempty( mainhandles)
    return
end

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Dialog

if alex
    prompt = {'E-S histogram: ' '';...
        'x min: ' 'xmin';...
        'x max: ' 'xmax';...
        'y min: ' 'ymin';...
        'y max: ' 'ymax';...
        'E histogram: ' '';...
        'y min: ' 'Eymin';...
        'y max: ' 'Eymax';...
        'S histogram: ' '';...
        'y min: ' 'Symin';...
        'y max: ' 'Symax'};
else
    prompt = {'x min: ' 'xmin';...
        'x max: ' 'xmax';...
        'y min: ' 'Eymin';...
        'y max: ' 'Eymax'};
end
name = 'Set axes scale';

% Handles formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(3,1).type   = 'edit';
formats(3,1).format = 'float';
formats(3,1).size = 80;
formats(3,2).type   = 'edit';
formats(3,2).format = 'float';
formats(3,2).size = 80;
formats(4,1).type   = 'edit';
formats(4,1).format = 'float';
formats(4,1).size = 80;
formats(4,2).type   = 'edit';
formats(4,2).format = 'float';
formats(4,2).size = 80;

if alex
    formats(2,1).type   = 'text';
    formats(6,1).type   = 'text';
    formats(7,1).type   = 'edit';
    formats(7,1).format = 'float';
    formats(7,1).size = 80;
    formats(7,2).type   = 'edit';
    formats(7,2).format = 'float';
    formats(7,2).size = 80;
    formats(9,1).type   = 'text';
    formats(10,1).type   = 'edit';
    formats(10,1).format = 'float';
    formats(10,1).size = 80;
    formats(10,2).type   = 'edit';
    formats(10,2).format = 'float';
    formats(10,2).size = 80;
end

% Default answers:
ylimEhist = get(hwHandles.Ehist,'ylim');
DefAns.Eymin = ylimEhist(1);
DefAns.Eymax = ylimEhist(2);
DefAns.xmin = mainhandles.settings.SEplot.xlim(1);
DefAns.xmax = mainhandles.settings.SEplot.xlim(2);

if alex
    DefAns.ymin = mainhandles.settings.SEplot.ylim(1);
    DefAns.ymax = mainhandles.settings.SEplot.ylim(2);
    
    ylimShist = get(hwHandles.Shist,'ylim');
    DefAns.Symin = ylimShist(1);
    DefAns.Symax = ylimShist(2);
end

% Open input dialogue and get answer
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns); % Open dialog box
if cancelled == 1
    return
end

mainhandles.settings.SEplot.xlim = sort([answer.xmin answer.xmax]);
updatemainhandles(mainhandles)

if alex
    % ALEX callback
    
    mainhandles.settings.SEplot.ylim = sort([answer.ymin answer.ymax]);
    updatemainhandles(mainhandles)
    
    % Set axis limits
    xlim(hwHandles.SEplot, mainhandles.settings.SEplot.xlim)
    ylim(hwHandles.SEplot, mainhandles.settings.SEplot.ylim)
    xlim(hwHandles.Shist, mainhandles.settings.SEplot.ylim) % Set x-limits of S-histogram equal y-limits of SE-plot (they are not directly linked as the SEplot-x and E-hist-x)
    
    % E-hist ticks and lower limit
    if mainhandles.settings.SEplot.ylim(2)<=1 && ylimEhist(2)>1
        ylim(hwHandles.Ehist,[1 ylimEhist(2)])
    end
    set(hwHandles.Ehist, 'YTick', linspace(ylimEhist(1),ylimEhist(2),mainhandles.settings.SEplot.EhistTicks)) % Number of tick marks
    
    % S-hist ticks and lower limit
    if mainhandles.settings.SEplot.xlim(2)<=1 && ylimShist(2)>1
        ylim(hwHandles.Shist,[1 ylimShist(2)])
    end
    set(hwHandles.Shist, 'YTick', linspace(ylimShist(1),ylimShist(2),mainhandles.settings.SEplot.ShistTicks)) % Number of tick marks
    
    % E hist
    if ~isequal(ylimEhist,[answer.Eymin answer.Eymax])
        ylim(hwHandles.Ehist,[answer.Eymin answer.Eymax])
    end
    
    % S hist
    if ~isequal(ylimShist,[answer.Symin answer.Symax])
        ylim(hwHandles.Shist,[answer.Symin answer.Symax])
    end
    
else
    
    % Single-color callbask
    updateSEplot(mainhandles.figure1);
%     xlim(hwHandles.Ehist,[answer.xmin answer.xmax])
    ylim(hwHandles.Ehist,[answer.Eymin answer.Eymax])
end
