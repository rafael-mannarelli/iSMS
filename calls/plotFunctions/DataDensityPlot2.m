function [ f1 ] = DataDensityPlot2( x, y )
%DATADENSITYPLOT Plot the data density 
%   Makes a contour map of data density
%   x, y - data x and y coordinates
%   levels - number of contours to show
%
% Originally by Malcolm Mclean
%
% modified for speed using hist3 by Jeremy Koether April-2013
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

    levels=256;

    screen_size = get(0, 'ScreenSize');
    f1=figure;
    set(f1, 'Position', [50 50 screen_size(4)*.8 screen_size(4)*.8 ] );

    axis;
    lim=double(max(abs([x; y])));  %plot will be square, centered about origin.

	lim=lim*1.05;
    xlim([-lim lim]);
    ylim([-lim lim]);

    set(gca,'units','pixels');
    ap=get(gca,'position');
    ap([2 4])=ap([1 3]); %square
    set(gca,'position',ap,'units','pixels');
    numPixels=ap(3)-ap(1)+1;

    edges(1)={-lim:lim*2/numPixels:lim};
    edges(2)=edges(1);
    map=hist3([y x],'Edges',edges);
    %map=log10(map); %log scale seems to best for some data
    
    %these lines will ignore top 10 outliers if there a lot of data in a
    %few specific bins
    
    %s=sort(reshape(map,1,[]),'descend');
    %maxVal=s(11);
    %map(map>maxVal)=maxVal;
    
    maxVal=max(reshape(map,1,[]));
    map = floor(map ./ maxVal * (levels-1));
    
    image(map);
    colormap(jet(levels));
    
    F=getframe(gca);
    cla;

    imagesc([-lim lim], [-lim lim],F.cdata); %
    set(gca,'ydir','normal','TickDir','out','units','normalized');
end

