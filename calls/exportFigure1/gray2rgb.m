function imageData = gray2rgb(imageData,imgclass)
% Adds three colorchannels for grayscale image
%
%    Input:
%     imageData    - input image
%     imgclass     - optional output image class. Default: class(imageData)

% Check input
if size(imageData,3)>1 && size(imageData,4)>1
    error('Input for gray2rgb is not a grayscale image')
    return
elseif size(imageData,3)>1 && size(imageData,4)==1
    % Interpret 3rd dimension as frames
    imageData = permute(imageData,[1 2 4 3]);
end

% Default
if nargin<2 || isempty(imgclass)
    imgclass = class(imageData);
end

% [m n] = size(Image);
% Pre-allocate
inpClass = class(imageData);
if strcmp(inpClass,'logical')
    inpClass = 'double';
end

rgb = zeros(size(imageData,1),size(imageData,2),3,size(imageData,4), inpClass);

% Insert image into all colorchannels
for frame = 1:size(imageData,4)
    rgb(:,:,1,frame) = imageData(:,:,:,frame);
    rgb(:,:,2,frame) = imageData(:,:,:,frame);
    rgb(:,:,3,frame) = imageData(:,:,:,frame);
end

imageData = rgb;

% Class
% if strcmpi(imgclass,'int16') && size(imageData,3)==1
%     % RGBs can't be int 16
%     imageData = im2int16(imageData);

if strcmpi(imgclass,'uint16')
    
    imageData = im2uint16(imageData);
    
elseif strcmpi(imgclass,'uint8')
    
    imageData = im2uint8(imageData);
    
elseif strcmpi(imgclass,'single')
    
    imageData = im2single(imageData);
    
elseif strcmpi(imgclass,'double')
    
    imageData = im2double(imageData);
end


% if strcmpi(imgclass,'uint8')
%     imageData = rgb/255;
% end
