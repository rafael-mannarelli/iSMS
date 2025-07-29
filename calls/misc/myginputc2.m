function [x, y, button, ax] = myginputc(varargin)
%GINPUTC Graphical input from mouse.
%   GINPUTC behaves similarly to GINPUT, except you can customize the
%   cursor color, line width, and line style.
%
%   [X,Y] = GINPUTC(N) gets N points from the current axes and returns
%   the X- and Y-coordinates in length N vectors X and Y.  The cursor
%   can be positioned using a mouse.  Data points are entered by pressing
%   a mouse button or any key on the keyboard except carriage return,
%   which terminates the input before N points are entered.
%       Note: if there are multiple axes in the figure, use mouse clicks
%             instead of key presses. Key presses may not select the axes
%             where the cursor is.
%
%   [X,Y] = GINPUTC gathers an unlimited number of points until the return
%   key is pressed.
%
%   [X,Y] = GINPUTC(N, PARAM, VALUE) and [X,Y] = GINPUTC(PARAM, VALUE)
%   specifies additional parameters for customizing. Valid values for PARAM
%   are:
%       'ValidAxes'            : axes handle
%       'parent'        : parent panel
%       'FigHandle'     : Handle of the figure to activate. Default is gcf.
%       'Color'         : A three-element RGB vector, or one of the MATLAB
%                         predefined names, specifying the line color. See
%                         the ColorSpec reference page for more information
%                         on specifying color. Default is 'k' (black).
%       'LineWidth'     : A scalar number specifying the line width.
%                         Default is 0.5.
%       'LineStyle'     : '-', '--', '-.', ':'. Default is '-'.
%
%   [X,Y,BUTTON] = GINPUTC(...) returns a third result, BUTTON, that
%   contains a vector of integers specifying which mouse button was used
%   (1,2,3 from left) or ASCII numbers if a key on the keyboard was used.
%
%   [X,Y,BUTTON,AX] = GINPUTC(...) returns a fourth result, AX, that
%   contains a vector of axes handles for the data points collected.
%
%   Requires MATLAB R2007b or newer.
%
%   Examples:
%       [x, y] = ginputc;
%
%       [x, y] = ginputc(5, 'Color', 'r', 'LineWidth', 3);
%
%       [x, y, button] = ginputc(1, 'LineStyle', ':');
%
%       subplot(1, 2, 1); subplot(1, 2, 2);
%       [x, y, button, ax] = ginputc;
%
%       [x, y] = ginputc('ShowPoints', true, 'ConnectPoints', true);
%
%   See also GINPUT, GTEXT, WAITFORBUTTONPRESS.

% Jiro Doke
% October 19, 2012
% Copyright 2012 The MathWorks, Inc.
%
%
%    Modification by Søren Preus:
%      [...] = ginputc('ax',hAx...);
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


% Check input arguments
p = inputParser();

addOptional(p, 'N', inf, @(x) validateattributes(x, {'numeric'}, ...
    {'scalar', 'integer', 'positive'}));
% addParamValue(p, 'ValidAxes', [], @ishandle); % Added by SP
addParameter(p,'ValidAxes',[]);
addParamValue(p, 'parent', [], @(x) isprop(x,'BorderType')); % SP
addParamValue(p, 'FigHandle', [], @(x) numel(x)==1 && ishandle(x));
addParamValue(p, 'Color', 'k', @colorValidFcn);
addParamValue(p, 'LineWidth', 0.5 , @(x) validateattributes(x, ...
    {'numeric'}, {'scalar', 'positive'}));
addParamValue(p, 'LineStyle', '-' , @(x) validatestring(x, ...
    {'-', '--', '-.', ':'}));
addParamValue(p, 'ShowPoints', false, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));
addParamValue(p, 'ConnectPoints', true, @(x) validateattributes(x, ...
    {'logical'}, {'scalar'}));

parse(p, varargin{:});

N = p.Results.N;
hAx = p.Results.ValidAxes; % Add by SP
hFig = p.Results.FigHandle;
color = p.Results.Color;
linewidth = p.Results.LineWidth;
linestyle = p.Results.LineStyle;
hParent = p.Results.parent;

%--------------------------------------------------------------------------
    function tf = colorValidFcn(in)
        % This function validates the color input parameter
        
        validateattributes(in, {'char', 'double'}, {'nonempty'});
        if ischar(in)
            validatestring(in, {'b', 'g', 'r', 'c', 'm', 'y', 'k', 'w'});
        else
            assert(isequal(size(in), [1 3]) && all(in>=0 & in<=1), ...
                'ginputc:InvalidColorValues', ...
                'RGB values for "Color" must be a 1x3 vector between 0 and 1');
            % validateattributes(in, {'numeric'}, {'size', [1 3], '>=', 0, '<=', 1})
        end
        tf = true;
    end
%--------------------------------------------------------------------------

if isempty(hFig)
    hFig = gcf;
end

if isempty(hParent)
    hParent = hFig;
end

% Check if an instance of ginputc is running already
if ~isempty(getappdata(0,'hInvisibleAxes'))
    % If the invisible axes is still around, it means ginputc was not
    % terminated properly the last time it was run. Then do it now and
    % return

    resetginput()
    return
end

% Try to get the current axes even if it has a hidden handle.
if isempty(hAx)
    hAx = gca;
%     hAx = get(hFig, 'CurrentAxes');
%     if isempty(hAx)
%         allAx = findall(hFig, 'Type', 'axes');
%         if ~isempty(allAx)
%             hAx = allAx(1);
%         else
%             hAx = axes('Parent', hFig);
%         end
%     end
end

% Save current properties so they can be restored
curWBDF = get(hFig,'WindowButtonDownFcn');
curWBMF = get(hFig,'WindowButtonMotionFcn');

% Change window functions
set(hFig, ...
    'WindowButtonDownFcn', @mouseClickFcn, ...
    'WindowButtonMotionFcn', @mouseMoveFcn);

% New pointer
set(hFig, 'Pointer','crosshair') % There is a delay between pointer and
% set(hFig, 'Pointer', 'custom', 'PointerShapeCData', nan(16, 16)) % No shape (empty)

% Create an invisible axes for displaying the full crosshair cursor
hInvisibleAxes = axes(...
    'Parent', hParent, ...
    'Units', 'normalized', ...
    'Position', [0 0 1 1], ...
    'XLim', [0 1], ...
    'YLim', [0 1], ...
    'HitTest', 'off', ...
    'HandleVisibility', 'off', ...
    'Visible', 'off');

% Export handle to objects so they can be accessed at will
setappdata(0,'hInvisibleAxes',hInvisibleAxes)
setappdata(0,'curWBDF',curWBDF)
setappdata(0,'curWBMF',curWBMF)
setappdata(0,'hAx',hAx)
setappdata(0,'hParent',hParent)

% Initialize full crosshair lines

% VERSION DEPENDENT SYNTAX
if getmatlabversion()>8.3
    hCursor = line(nan, nan, ...
        'Parent', hInvisibleAxes, ...
        'Color', color, ...
        'LineWidth', linewidth, ...
        'LineStyle', linestyle, ...
        'HandleVisibility', 'off', ...
        'PickableParts', 'none');
else
    hCursor = line(nan, nan, ...
        'Parent', hInvisibleAxes, ...
        'Color', color, ...
        'LineWidth', linewidth, ...
        'LineStyle', linestyle, ...
        'HandleVisibility', 'off', ...
        'HitTest', 'off');
end

% Prepare results
x = [];
y = [];
button = [];
ax = [];

% Wait until enter is pressed.
uiwait(hFig);

%--------------------------------------------------------------------------
    function mouseMoveFcn(varargin)
        % This function updates cursor location based on pointer location
        
        cursorPt = get(hInvisibleAxes, 'CurrentPoint');
        
        set(hCursor, ...
            'XData', [0 1 nan cursorPt(1) cursorPt(1)], ...
            'YData', [cursorPt(3) cursorPt(3) nan 0 1]);
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function mouseClickFcn(varargin)
        % This function captures mouse clicks and captures the information
        % for the selected point
        
        % Check if click was made inside invisible axes
        ptInv = get(hInvisibleAxes, 'CurrentPoint');
        if ptInv(1)<0 || ptInv(3)<0 || ptInv(1)>1 || ptInv(3)>1
            exitFcn();
            return
        end
        
        % Check if selection was made inside axes
        hAx = getappdata(0,'hAx');
        for i = 1:length(hAx)
            hAxi = hAx(i);
            
            % Check if selection was made in axi
            if ~isequal(gca,hAxi)
                continue
            end
            
            % Get coordinates
            pt = get(hAxi, 'CurrentPoint');
            if size(pt,1)>1
                pt = pt(1,:);
            end
            
            % Check that selection was made inside axis
            axlims = get(hAxi,'xlim');
            aylims = get(hAxi,'ylim');
            if (pt(1)<axlims(1) || pt(1)>axlims(2)) || ...
                    (pt(2)<aylims(1) || pt(2)>aylims(2))% || ...
                continue
            end
            
            % Return position inside axes
            x = [x; pt(1)];
            y = [y; pt(2)];
            ax = [ax; hAxi];
            
            break % We are finished when ax has been found
        end
        
        if isempty(x)
            exitFcn()
            return
        end
        
        clickType = get(hFig, 'SelectionType');
        if ischar(clickType)   % Mouse click
            switch lower(clickType)
                case 'open'
                    clickType = 1;
                case 'normal'
                    clickType = 1;
                case 'extend'
                    clickType = 2;
                case 'alt'
                    clickType = 3;
            end
        end
        button = [button; clickType];
        
        % If captured all points, exit
        if length(x) == N
            exitFcn();
        end
    end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
    function exitFcn()
        % This function exits GINPUTC and restores previous figure settings
        warning off
        
        % Restore window functions and pointer
        set(hFig, 'Pointer', 'arrow');
        try
            set(hFig, 'WindowButtonDownFcn', curWBDF)
            set(hFig, 'WindowButtonMotionFcn', curWBMF)
        end
        
        % Delete invisible axes
        try delete(hInvisibleAxes); end
        
        % return control
        warning on
        uiresume(hFig);
    end
%--------------------------------------------------------------------------

    function resetginput()
        % Reset properties from previuos ginputc and shut down
         
        % Saved window settings
        curWBDF = getappdata(0,'curWBDF');
        curWBMF = getappdata(0,'curWBMF');
        hInvisibleAxes = getappdata(0,'hInvisibleAxes');
        rmappdata(0,'hInvisibleAxes') % Clean up
        
        % Output that tells ginputc was not activated this time
        x = [];
        y = [];
        button = 30;
        ax = [];
        
        % Exit and return
        try
            exitFcn()
        end 
    end
end