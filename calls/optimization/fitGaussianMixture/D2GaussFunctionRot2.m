function F = D2GaussFunctionRot2(x,xdata,pars)
%% x = [Amplitude, x0, Xwidth, y0, Ywidth, angle, background]
%[X,Y] = meshgrid(x,y) 
%  xdata(:,:,1) = X
%  xdata(:,:,2) = Y           
% Mrot = [cos(angle) -sin(angle); sin(angle) cos(angle)]
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

%%
% xdatarot(:,:,1)= xdata(:,:,1)*cos(x(6)) - xdata(:,:,2)*sin(x(6));
% xdatarot(:,:,2)= xdata(:,:,1)*sin(x(6)) + xdata(:,:,2)*cos(x(6));
% x0rot = x(2)*cos(x(6)) - x(4)*sin(x(6));
% y0rot = x(2)*sin(x(6)) + x(4)*cos(x(6));
% 
% F = x(1)*exp(   -((xdatarot(:,:,1)-x0rot).^2/(2*x(3)^2) + (xdatarot(:,:,2)-y0rot).^2/(2*x(5)^2) )    )    + x(7);
% res = (F-zdata).^2;
% res = sum(res(:));

xdatarot(:,:,1)= xdata(:,:,1)*cos(pars(5)) - xdata(:,:,2)*sin(pars(5));
xdatarot(:,:,2)= xdata(:,:,1)*sin(pars(5)) + xdata(:,:,2)*cos(pars(5));
x0rot = pars(1)*cos(pars(5)) - pars(3)*sin(pars(5));
y0rot = pars(1)*sin(pars(5)) + pars(3)*cos(pars(5));

% F = x(1)*exp(   -((xdatarot(:,:,1)-x0rot).^2/(2*pars(2)^2) + (xdatarot(:,:,2)-y0rot).^2/(2*pars(4)^2) )    )    + x(2);
F = x(1)*1/(2*pi*pars(2)*pars(4))*exp(   -((xdatarot(:,:,1)-x0rot).^2/(2*pars(2)^2) + (xdatarot(:,:,2)-y0rot).^2/(2*pars(4)^2) )    )    + x(2);

% figure(3)
% alpha(0)
% imagesc(F)
% colormap('gray')
% figure(gcf)%bring current figure to front
% drawnow
% beep
% pause %Wait for keystroke
