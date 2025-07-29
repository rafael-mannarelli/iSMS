function formats = prepareformats(~)
% Initializes formats structure for inputsdlg
%
%   type     - Type of control ['check',{'edit'},'list','range','text',
%                               'color','table','button','none']
%   style    - UI control type used. One of:
%               {'checkbox'},                for 'check' type
%               {'edit'}                     for 'edit' type
%               {'listbox','popupmenu','radiobutton','togglebutton'}
%                                            for 'list' type
%               {'slider'}                   for 'range' type
%               {'text'}                     for 'text' type
%               {'edit'}                     for 'color' type
%               {'pushbutton'}               for 'button' and 'color' types
%               {'table'}                    for 'table' type
%   format   - Data format: ['string','date','float','integer','logical',
%                            'vector','file','dir']
%   limits   - [min max] (see below for details)
%   required -  'on'   - control must have an answer
%              {'off'} - control may return empty answer
%   items    - Type 'edit', Format 'file': File flter spec
%              Type 'list': Selection items (cell of strings)
%              Type 'table': Names of columns (cell of strings)
%              Type 'range': Slider step size spec [minor major]
%   size     - [width height] in pixels. Set to <=0 to auto-size.
%   enable   - Defines how to respond to mouse button clicks, including which
%              callback routines execute. One of:
%               {'on'}      - UI control is operational.
%                'inactive' ?UI control is not operational, but looks the
%                             same as when Enable is on.
%                'off'      ?UI uicontrol is not operational and its image
%                             is grayed out.
%   margin  -  A scalar or 2-element vector specifying the margin between control
%              and its labels in pixels.
%   labelloc - Prompt label location:
%               {'lefttop'}   - left of control, aligned to top
%                'leftmiddle' - left of control, aligned to middle
%                'leftbottom' - left of control, aligned to bottom
%                'topleft'    - above control, aligned left
%                'topcenter'  - above control, aligned center
%                'topright'   - above control, aligned right
%   unitsloc - Units label location:
%               {'righttop'}     - right of control, aligned to top
%                'rightmiddle'   - right of control, aligned to middle
%                'rightbottom'   - right of control, aligned to bottom
%                'bottomleft'    - below control, aligned left
%                'bottomcenter'  - below control, aligned center
%                'bottomright'   - below control, aligned right
%   callback - Defines callback funcion, a routine that executes whenever
%              you activate the uicontrol object. For the controls with
%              separate dialog, their callback functions are executed after
%              the dialog is closed. The callback function must be given as
%              a function handle with following syntax:
%
%                 my_callbackfcn(hobj,evt,handles,k)
%
%              where hobj and evt are the passed-through standard MATLAB
%              callback arguments, handles is a Nx3 array of dialog
%              objects. Here, the n-th row corresponds to the n-th PROMPT,
%              and handles(n,1) is the calling object handle (i.e., same as
%              hobj). handles(n,2) are the prompt texts and handles(n,3)
%              are the prompt unit texts.
%
%              For example, Formats(n,m).callback.ButtonDownFcn sets the
%              the button-press callback function.
%   span     - Defines size of objects in fields [rows columns]

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

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
