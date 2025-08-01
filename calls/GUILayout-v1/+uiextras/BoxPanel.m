classdef BoxPanel < uiextras.CardPanel & uiextras.DecoratedPanel
    %BoxPanel  Show one element inside a box panel
    %
    %   obj = uiextras.BoxPanel() creates a box-styled panel object with
    %   automatic management of the contained widget or layout. The
    %   properties available are largely the same as the builtin UIPANEL
    %   object. Where more than one child is added, the currently visible
    %   child is determined using the SelectedChild property.
    %
    %   obj = uiextras.BoxPanel(param,value,...) also sets one or more
    %   property values.
    %
    %   See the <a href="matlab:doc uiextras.BoxPanel">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> p = uiextras.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'r' )
    %
    %   >> f = figure();
    %   >> p = uiextras.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
    %   >> b = uiextras.HBox( 'Parent', p, 'Spacing', 5 );
    %   >> uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} );
    %   >> uicontrol( 'Style', 'frame', 'Parent', b, 'Background', 'b' );
    %   >> set( b, 'Sizes', [100 -1] );
    %   >> p.FontSize = 12;
    %   >> p.FontWeight = 'bold';
    %   >> p.HelpFcn = @(x,y) disp('Help me!');
    %
    %   See also: uiextras.Panel
    %             uiextras.TabPanel
    %             uiextras.HBoxFlex
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 383 $
    %   $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties
        IsMinimized = false
        IsDocked = true
    end % public properties
    
    properties( Dependent = true )
        CloseRequestFcn
        MenuFcn
        Menu2Fcn
        Menu3Fcn
        SaveFcn
        ROIchannelFcn
        RunFcn
        HelpFcn
        MinimizeFcn
        DockFcn
        BorderType
        Title
        TitleColor
        TooltipString
    end % dependent properties
    
    properties( SetAccess = private, GetAccess = private, Hidden = true )
        HGWidgets_ = struct()
    end % private properties
    
    methods
        
        function obj = BoxPanel(varargin)
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj = obj@uiextras.CardPanel( varargin{:} );
            obj = obj@uiextras.DecoratedPanel( varargin{:} );
            
            % For this container we need the border on
            set( obj.UIContainer, 'BorderType', 'etchedin' );
            
            % Path to icons
            mainhandles = guidata(getappdata(0,'mainhandle'));
            icondir = [mainhandles.workdir filesep 'resources' filesep]; % This is the same as mainhandles.resourcedir on MATLAB versions only
            
            % Text control for title
            figh = ancestor( obj.UIContainer, 'figure' );
            contextmenu = uicontextmenu( 'Parent', figh );
            titleColor = [0.75 0.9 1.0];
            obj.HGWidgets_.TitleText = uicontrol('parent', obj.UIContainer, ...
                'Visible', obj.Visible, ...
                'units', 'pixels', ...
                'HitTest', 'off', ...
                'style', 'text', ...
                'string', '', ...
                'horizontalalignment', 'left',...
                'BackgroundColor', titleColor, ...
                'ForegroundColor', obj.ForegroundColor, ...
                'FontSize', obj.FontSize, ...
                'FontName', obj.FontName, ...
                'FontAngle', obj.FontAngle, ...
                'FontWeight', obj.FontWeight, ...
                'FontUnits', obj.FontUnits, ...
                'UIContextMenu', contextmenu, ...
                'HandleVisibility', 'off', ...
                'Tag', 'uiextras:BoxPanel:TitleText');
            
            % Panel for title
            obj.HGWidgets_.TitlePanel = uipanel('parent', obj.UIContainer, ...
                'Visible', obj.Visible, ...
                'units', 'pixels', ...
                'HitTest', 'off', ...
                'bordertype', 'etchedin', ...
                'BackgroundColor', titleColor, ...
                'Tag', 'uiextras:BoxPanel:TitlePanel', ...
                'HandleVisibility', 'off', ...
                'UIContextMenu', contextmenu);
            
            % Create the buttons
            obj.HGWidgets_.HelpButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelHelp.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:HelpButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', 'Get help on this panel' );
            
            tooltipString = getappdata(0,'tooltipMenuString'); % Tool tip string
            if isempty(tooltipString)
                tooltipString = 'Settings for this panel';
            end
            obj.HGWidgets_.MenuButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelMenu2.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:MenuButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', tooltipString );

            % Menu2
            tooltipString = getappdata(0,'tooltipMenu2String'); % Tool tip string
            if isempty(tooltipString)
                tooltipString = 'Advanced settings for this panel';
            end
            obj.HGWidgets_.Menu2Button = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelMenu3.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:Menu2Button', ...
                'HandleVisibility', 'off', ...
                'tooltip', tooltipString );

            % Menu3
            tooltipString = getappdata(0,'tooltipMenu3String'); % Tool tip string
            if isempty(tooltipString)
                tooltipString = 'Advanced settings 3';
            end
            obj.HGWidgets_.Menu3Button = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelMenu2.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:Menu3Button', ...
                'HandleVisibility', 'off', ...
                'tooltip', tooltipString );

            % Save menu fcn
            tooltipString = getappdata(0,'saveMenuString'); % Tool tip string
            if isempty(tooltipString)
                tooltipString = 'Save';
            end
            obj.HGWidgets_.SaveButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'saveIcon.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:SaveButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', tooltipString );

            % ROI channel
            tooltipString = getappdata(0,'tooltipROIchannelString'); % Tool tip string
            if isempty(tooltipString)
                tooltipString = 'Shift emission channel';
            end
            obj.HGWidgets_.ROIchannelButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'ROIchannel.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:ROIchannelButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', tooltipString );

            % Run
            tooltipString = getappdata(0,'tooltipRunString'); % Tool tip string
            if isempty(tooltipString)
                tooltipString = 'Run';
            end
            obj.HGWidgets_.RunButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelRun.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:RunButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', tooltipString );

            tooltipString = getappdata(0,'tooltipCloseString'); % Tool tip string
            if isempty(tooltipString)
                tooltipString = 'Run';
            end            
            obj.HGWidgets_.CloseButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelClose.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:CloseButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', tooltipString );
            
            obj.HGWidgets_.DockButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelUndock.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:DockButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', 'Undock this panel' );
            
            obj.HGWidgets_.MinimizeButton = uicontrol('parent', obj.UIContainer, ...
                'style', 'checkbox', ...
                'cdata', uiextras.loadLayoutIcon( [icondir 'panelMinimize.png'] ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Tag', 'uiextras:BoxPanel:MinimizeButton', ...
                'HandleVisibility', 'off', ...
                'tooltip', 'Minimize this panel' );
            
            % Get some defaults
            obj.setPropertyFromDefault( 'TitleColor' );
            obj.setPropertyFromDefault( 'BorderType' );
            
            % Parse any input arguments
            if nargin>0
                set( obj, varargin{:} );
            end
            % Redraw both contents and styling
            obj.redraw();
        end % constructor
    end % public methods
    
    methods
        
        function set.BorderType( obj, value )
            set( obj.UIContainer, 'BorderType', value );
            set( obj.HGWidgets_.TitlePanel, 'BorderType', value );
        end % set.BorderType
        
        function value = get.BorderType( obj )
            value = get( obj.UIContainer, 'BorderType' );
        end % get.BorderType
        
        function set.Title( obj, value )
            set( obj.HGWidgets_.TitleText, 'String', value );
        end % set.Title
        
        function value = get.Title( obj )
            value = get( obj.HGWidgets_.TitleText, 'String' );
        end % get.Title
        
        function set.HelpFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.HelpButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.HelpButton, 'Visible', obj.Visible, 'Callback', value );
            end
        end % set.HelpFcn
        
        function set.MenuFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.MenuButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.MenuButton, 'Visible', obj.Visible, 'Callback', value);
            end
        end % set.MenuFcn

        function set.Menu2Fcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.Menu2Button, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.Menu2Button, 'Visible', obj.Visible, 'Callback', value);
            end
        end % set.MenuFcn

        function set.Menu3Fcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.Menu3Button, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.Menu3Button, 'Visible', obj.Visible, 'Callback', value);
            end
        end % set.MenuFcn

        function set.SaveFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.SaveButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.SaveButton, 'Visible', obj.Visible, 'Callback', value);
            end
        end % set.MenuFcn

        function set.ROIchannelFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.ROIchannelButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.ROIchannelButton, 'Visible', obj.Visible, 'Callback', value);
            end
        end % set.MenuFcn

        function set.RunFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.RunButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.RunButton, 'Visible', obj.Visible, 'Callback', value );
            end
        end % set.RunFcn

        function set.CloseRequestFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.CloseButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.CloseButton, 'Visible', obj.Visible, 'Callback', value );
            end
        end % set.CloseRequestFcn
        
        function set.MinimizeFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.MinimizeButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.MinimizeButton, 'Visible', obj.Visible, 'Callback', value );
            end
        end % set.MinimizeFcn
        
        function set.IsMinimized( obj, value )
            % Path to icons
            mainhandles = guidata(getappdata(0,'mainhandle'));
            icondir = [mainhandles.resourcedir filesep];
            
            obj.IsMinimized = (value(1) == true);
            if value( obj.IsMinimized )
                set( obj.HGWidgets_.MinimizeButton, ...
                    'cdata', uiextras.loadLayoutIcon( [icondir 'panelMaximize.png'] ), ...
                    'tooltip', 'Maximize this panel' ); %#ok<MCSUP>
            else
                set( obj.HGWidgets_.MinimizeButton, ...
                    'cdata', uiextras.loadLayoutIcon( [icondir 'panelMinimize.png'] ), ...
                    'tooltip', 'Minimize this panel' ); %#ok<MCSUP>
            end
        end % set.IsMinimized
        
        function set.DockFcn( obj, value )
            if isempty( value )
                set( obj.HGWidgets_.DockButton, 'Visible', 'off', 'Callback', [] );
            else
                set( obj.HGWidgets_.DockButton, 'Visible', obj.Visible, 'Callback', value );
            end
        end % set.DockFcn
        
        function set.IsDocked( obj, value )
            % Path to icons
            mainhandles = guidata(getappdata(0,'mainhandle'));
            icondir = [mainhandles.resourcedir filesep];

            obj.IsDocked = (value(1) == true);
            if value( obj.IsDocked )
                set( obj.HGWidgets_.DockButton, ...
                    'cdata', uiextras.loadLayoutIcon( [icondir 'panelUndock.png'] ), ...
                    'tooltip', 'Undock this panel' ); %#ok<MCSUP>
            else
                set( obj.HGWidgets_.DockButton, ...
                    'cdata', uiextras.loadLayoutIcon( [icondir 'panelDock.png'] ), ...
                    'tooltip', 'Dock this panel' ); %#ok<MCSUP>
            end
        end % set.IsMinimized
        
        function value = get.CloseRequestFcn( obj )
            value = get( obj.HGWidgets_.CloseButton, 'Callback' );
        end % get.CloseRequestFcn
        
        function value = get.HelpFcn( obj )
            value = get( obj.HGWidgets_.HelpButton, 'Callback' );
        end % get.HelpFcn
        
        function value = get.MenuFcn( obj )
            value = get( obj.HGWidgets_.MenuButton, 'Callback' );
        end % get.MenuFcn

        function value = get.Menu2Fcn( obj )
            value = get( obj.HGWidgets_.Menu2Button, 'Callback' );
        end % get.MenuFcn

        function value = get.Menu3Fcn( obj )
            value = get( obj.HGWidgets_.Menu3Button, 'Callback' );
        end % get.MenuFcn

        function value = get.SaveFcn( obj )
            value = get( obj.HGWidgets_.SaveButton, 'Callback' );
        end % get.MenuFcn

        function value = get.ROIchannelFcn( obj )
            value = get( obj.HGWidgets_.ROIchannelButton, 'Callback' );
        end % get.MenuFcn

        function value = get.RunFcn( obj )
            value = get( obj.HGWidgets_.RunButton, 'Callback' );
        end % get.RunFcn

        function value = get.MinimizeFcn( obj )
            value = get( obj.HGWidgets_.MinimizeButton, 'Callback' );
        end % get.MinimizeFcn
        
        function value = get.DockFcn( obj )
            value = get( obj.HGWidgets_.DockButton, 'Callback' );
        end % get.DockFcn
        
        function set.TitleColor( obj, value )
            widgets = {
                'TitleText'
                'TitlePanel'
                'MenuButton'
                'Menu2Button'
                'Menu3Button'
                'SaveButton'
                'ROIchannelButton'
                'RunButton'
                'HelpButton'
                'CloseButton'
                'MinimizeButton'
                'DockButton'
                };
            for ww=1:numel(widgets)
                if isfield( obj.HGWidgets_, widgets{ww} )
                    set( obj.HGWidgets_.(widgets{ww}), 'BackgroundColor', value );
                end
            end
        end % set.TitleColor
        
        function value = get.TitleColor( obj )
            value = get( obj.HGWidgets_.TitleText, 'BackgroundColor' );
        end % get.TitleColor
        
        function set.TooltipString( obj, value )
            set( obj.HGWidgets_.TitleText, 'TooltipString', value );
        end % set.TooltipString
        
        function value = get.TooltipString( obj )
            value = get( obj.HGWidgets_.TitleText, 'TooltipString' );
        end % get.TooltipString
        
        
    end % accessor methods
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw this widget and its contents
            pos = getpixelposition( obj.UIContainer );
            decor = obj.HGWidgets_;
            
            % If size is too small, ignore
            if (pos(3)<12) || (pos(4)<18)
                return
            end
            
            % If decorations not yet constructed, ignore
            if ~isstruct( decor ) ...
                    || isempty(fieldnames(decor)) ...
                    || ~isfield( decor, 'MinimizeButton' ) % this is the last widget constructed
                return
            end
            
            % Work out the title height
            if isempty( obj.Title )
                titleSize = 14;
            else
                % Work out how much extra space to leave for the title
                oldunits = get( decor.TitleText, 'FontUnits' );
                set( decor.TitleText, 'FontUnits', 'Pixels' );
                % Get the height of the title (in pixels) and add a bit to
                % cope with letters below the baseline (e.g. 'g')
                titleSize = ceil( get( decor.TitleText, 'FontSize' )*1.2 );
                % Put the old units back
                set( decor.TitleText, 'FontUnits', oldunits );
            end
            
            % Set position of close button
            buttonXPos = pos(3)-2;
            buttonWidth = titleSize;
            if ~isempty(decor.CloseButton)
                set(decor.CloseButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.CloseRequestFcn )
                    set(decor.CloseButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.CloseButton,'Visible', 'off' );
                end
            end
            
            % Set position of dock button
            if ~isempty(decor.DockButton)
                set(decor.DockButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.DockFcn )
                    set(decor.DockButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.DockButton,'Visible', 'off' );
                end
            end
            
            % Set position of minimise button
            if ~isempty(decor.MinimizeButton)
                set(decor.MinimizeButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.MinimizeFcn )
                    set(decor.MinimizeButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.MinimizeButton,'Visible', 'off' );
                end
            end
            
            % Set position of help button
            if ~isempty(decor.HelpButton)
                set(decor.HelpButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.HelpFcn)
                    set(decor.HelpButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.HelpButton,'Visible', 'off' );
                end
            end
            
            % Set position of menu button
            if ~isempty(decor.MenuButton)
                set(decor.MenuButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.MenuFcn)
                    set(decor.MenuButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.MenuButton,'Visible', 'off' );
                end
            end
            
            % Set position of menu button
            if ~isempty(decor.Menu3Button)
                set(decor.Menu3Button, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.Menu3Fcn)
                    set(decor.Menu3Button,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.Menu3Button,'Visible', 'off' );
                end
            end
            
            % Set position of ROIchannel button
            if ~isempty(decor.ROIchannelButton)
                set(decor.ROIchannelButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.ROIchannelFcn)
                    set(decor.ROIchannelButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.ROIchannelButton,'Visible', 'off' );
                end
            end
            
            % Set position of run button
            if ~isempty(decor.RunButton)
                set(decor.RunButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.RunFcn)
                    set(decor.RunButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.RunButton,'Visible', 'off' );
                end
            end
                        
            % Set position of menu2 button
            if ~isempty(decor.Menu2Button)
                set(decor.Menu2Button, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.Menu2Fcn)
                    set(decor.Menu2Button,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.Menu2Button,'Visible', 'off' );
                end
            end
            
            % Set position of save button
            if ~isempty(decor.SaveButton)
                set(decor.SaveButton, 'Position', [buttonXPos-buttonWidth, pos(4)-titleSize, buttonWidth-1, buttonWidth-2]);
                if ~isempty( obj.SaveFcn)
                    set(decor.SaveButton,'Visible', 'on' );
                    buttonXPos = buttonXPos - buttonWidth;
                else
                    set(decor.SaveButton,'Visible', 'off' );
                end
            end
            
            % Set position of title
            posText = [2, pos(4)-titleSize-1, buttonXPos-3, titleSize];
            set(decor.TitleText, 'Position', posText, 'string', obj.Title );
            
            % Set position of panel for title
            posTitle = [-1, pos(4)-titleSize-3, pos(3), titleSize+4];
            set(decor.TitlePanel, 'Position', posTitle);
            
            % Work out where to put the contents
            panelborder = 2;
            x0 = obj.Padding+1;
            y0 = obj.Padding+1;
            w = pos(3) - 2*panelborder - 2*obj.Padding;
            h = pos(4) - titleSize - 2*panelborder - 2*obj.Padding;
            contentPos = [x0 y0 w h];
            
            % Use the CardLayout function to put the right child onscreen
            obj.showSelectedChild( contentPos )
            
        end % redraw
        
        function onChildAdded( obj, source, eventData ) %#ok<INUSD>
            %onChildAdded  A child has been added to a container
            % Select the new addition
            obj.SelectedChild = numel( obj.Children );
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData ) %#ok<INUSL>
            %onChildAdded  A container child has been destroyed or reparented
            %
            % If the missing child is the selected one, select something else
            if eventData.ChildIndex == obj.SelectedChild
                if isempty( obj.Children )
                    obj.SelectedChild = [];
                else
                    obj.SelectedChild = max( 1, obj.SelectedChild - 1 );
                end
            end
        end % onChildRemoved
        
        function onEnable(obj, source, eventData ) %#ok<INUSL>
            %onEnable  Enable state has been changed, so update
            set( obj.HGWidgets_.TitleText, 'Enable', eventData );
        end % onEnable
        
        function onPanelColorChanged( obj, source, eventData ) %#ok<INUSD>
            %onPanelColorChanged  Colors have been changed, so update
            if isfield( obj.HGWidgets_, 'TitleText' )
                set( obj.HGWidgets_.TitleText, 'ForegroundColor', obj.ForegroundColor );
                set( obj.HGWidgets_.TitlePanel, ...
                    'HighlightColor', obj.HighlightColor, ...
                    'ShadowColor', obj.ShadowColor );
                set( obj.UIContainer, ...
                    'HighlightColor', obj.HighlightColor, ...
                    'ShadowColor', obj.ShadowColor );
            end
        end % onPanelColorChanged
        
        function onPanelFontChanged( obj, source, eventData ) %#ok<INUSL>
            % Font has changed. Since the font size and shape affects the
            % space available for the contents, we need to redraw.
            if isfield( obj.HGWidgets_, 'TitleText' )
                set( obj.HGWidgets_.TitleText, eventData.Property, eventData.Value );
                obj.redraw();
            end
        end % onPanelFontChanged
        
    end % protected methods
    
end % classdef
