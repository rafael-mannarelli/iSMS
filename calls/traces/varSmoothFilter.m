function I = varSmoothFilter(I,nf)
% Varians based running filter
%
%    Input:
%     I       - time trace
%     nf      - total number of frames analysed at each step
%
%    Output:
%     I       - filtered trace
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

nb = round((nf-1)/2); % Number of frames on either side
if nb<=0
    return
end

%% Filter

temp = I;
L = length(I);
for k = 1:L
    if k < 1+nb
        
        % The beginning of the trace
        if k+nb<=L
            I(k) = var(temp(1:k+nb));
        else
            I(k) = var(temp(1:end));
        end
        
    elseif k > L-nb
        
        % The end of the trace
        if k-nb<1
            I(k) = var(temp(1:end));
        else
            I(k) = var(temp(k-nb:end));
        end
        
    else
        % The middle of the trace
        I(k) = var(temp(k-nb:k+nb));
    end
end
