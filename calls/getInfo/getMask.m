function [intMask, backMask] = getMask(imgSize, x0,y0,width,height, type,backwidth,backspace)
% Returns: 1) intMask, an [imgSize(1) x imgSize(2)] array being 1 inside
% and 0 outside the ellipse specified by center = (x0,y0) and x-width &
% y-height, 2) backMask, similar mask of a ring outside the ellipse.
% 
%     Input:
%      imgSize      - size of image [rows x cols] (x * y)
%      x0,y0        - Center of ellipse in pixels (can be fractional).
%      width,height - Width (x-direction) and height (y-direction) of
%                     ellipse. 
%      type         - 'intMask', 'backMask' or 'both'. 
%      backwidth    - width in pixels of the background line around the
%                     ellipse 
%      backspace    - space of zeros in between integration region and
%                     background region [pixels]
%
%     Output:
%      intMask      - mask of size(image) for integration pixels
%      backMask     - mask of size(image) for background pixels
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

if nargin<6
    type = 'both';
end
if nargin<7
    backwidth = 1;
end
if nargin<8
    backspace = 1;
end

% Preallocate mask array
% intMask = zeros(imgSize);
% backMask = zeros(imgSize);
% intMask = zeros(imgSize(1),imgSize(2),'uint16');
% backMask = zeros(imgSize(1),imgSize(2),'uint16');
intMask = false(imgSize(1),imgSize(2));
backMask = false(imgSize(1),imgSize(2));

% Ellipse parameters
% x0: array coordinate corresponding to 1->end row direction (right) (this is the terminology used by imroi)
% y0: array coordinate corresponding to 1->end column direction (down)
a = width/2; % Ellipse parameter
b = height/2; % Ellipse parameter

%% Calculate ellipse mask

if (strcmp(type,'intMask')) || (strcmp(type,'both'))
%     % Old, slower way
%     temp = intMask;
%     for x = 1:imgSize(1)
%         for y = 1:imgSize(2)
%             if (x-x0).^2/a^2+(y-y0).^2/b^2 < 1 % If pixel (x,y) is within ellipse, set its value to 1
%                 temp(x,y) = 1;
%             end
%         end
%     end    

    % New hotness:
    for x = floor(x0-a+1):ceil(x0+a-1)
%         if x<1 || x>imgSize(1)
%             continue
%         end
        for y = floor(y0-b+1):ceil(y0+b-1)
%             if y<1 || y>imgSize(2)
%                 continue
%             end
            if (x-x0).^2/a^2+(y-y0).^2/b^2 < 1 % If pixel (x,y) is within ellipse, set its value to 1
                if x>=1 && x<=imgSize(1) && y>=1 && y<=imgSize(2)
                    intMask(x,y) = true;
                end
            end
        end
    end
    
end

%% Calculate background ring mask

if (strcmp(type,'backMask')) || (strcmp(type,'both'))
    % Background ring
    a1 = a+backspace;
    b1 = b+backspace;
    a2 = a+backspace+backwidth;
    b2 = b+backspace+backwidth;
%     % Old, slower way
%     temp = backMask;
%     for x = 1:imgSize(1)
%         for y = 1:imgSize(2)
%             if ((x-x0).^2/a1^2+(y-y0).^2/b1^2 >= 1) && ((x-x0).^2/a2^2+(y-y0).^2/b2^2 < 1) % If pixel (x,y) is in between inner and outer ellipse, set its value to 1
%                 temp(x,y) = 1;
%             end
%         end
%     end
    
    % New hotness
    for x = floor(x0-a2+1):ceil(x0+a2-1)
%         if x<1 || x>imgSize(1)
%             continue
%         end
        for y = floor(y0-b2+1):ceil(y0+b2-1)
%             if y<1 || y>imgSize(2)
%                 continue
%             end
            if ((x-x0).^2/a1^2+(y-y0).^2/b1^2 >= 1) && ((x-x0).^2/a2^2+(y-y0).^2/b2^2 < 1) % If pixel (x,y) is in between inner and outer ellipse, set its value to 1
                if x>=1 && x<=imgSize(1) && y>=1 && y<=imgSize(2)
                    backMask(x,y) = true;
                end
            end
        end
    end
end

% Convert to uint16
% intMask = uint16(intMask);
% backMask = uint16(backMask);

