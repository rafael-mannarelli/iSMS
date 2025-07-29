function spread(X, label)
% Plot samples of different labels with different colors.
% Written by Michael Chen (sth4nth@gmail.com).
%
%    Input:
%     X      - data
%     label  - label vector
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

[d,n] = size(X);
if nargin == 1
    label = ones(n,1);
end
assert(n == length(label));

color = 'brgmcyk';
m = length(color);
c = max(label);

figure(gcf);
clf;
hold on;
switch d
    case 2
        view(2);
        for i = 1:c
            idc = label==i;
%             plot(X(1,label==i),X(2,label==i),['.' color(i)],'MarkerSize',15);
            scatter(X(1,idc),X(2,idc),36,color(mod(i-1,m)+1));
        end
    case 3
        view(3);
        for i = 1:c
            idc = label==i;
%             plot3(X(1,idc),X(2,idci),X(3,idc),['.' idc],'MarkerSize',15);
            scatter3(X(1,idc),X(2,idc),X(3,idc),36,color(mod(i-1,m)+1));
        end
    otherwise
        error('ERROR: only support data of 2D or 3D.');
end
axis equal
grid on
hold off