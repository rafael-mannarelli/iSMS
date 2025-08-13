function correctionfactorwindowResizeFcn(~)
%CORRECTIONFACTORWINDOWRESIZEFCN Keep correction factor window layout.
%   This function previously contained extensive code that manually
%   resized and repositioned the user interface controls each time the
%   correction factor window was resized. The dynamic layout caused the
%   window to deviate from the original arrangement stored in
%   ``correctionfactorWindow.fig``. To restore the classic appearance, the
%   implementation has been reduced to a no-op so that the layout defined
%   in the FIG file is preserved.
%
%   Input:
%     ~ - Handle structure (unused, kept for backwards compatibility)
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

% Intentionally left blank.

end

