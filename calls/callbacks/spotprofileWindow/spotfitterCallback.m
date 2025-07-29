function spHandles = spotfitterCallback(spHandles)
% Callback of the spot profile fitter in the spot profile window
%
%    Input:
%     spHandles   - handles structure of the spot profile window
%
%    Output:
%     spHandles   - ..
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

mainhandles = getmainhandles(spHandles);
if isempty(mainhandles)
    return
end

if nargin<1
    mainhandles = guidata(getappdata(0,'mainhandle'));
end

% Waitbar
hWaitbar = mywaitbar(0,'Please wait...','name','iSMS');

% Get data
if get(spHandles.greenRadiobutton,'Value') && (~isempty(spHandles.green))
    choice = get(spHandles.greenListbox,'Value');
    img = double(spHandles.green(choice).image);
    ROI = round(double(spHandles.green(choice).spotROI));
    spot = 1;
    
elseif get(spHandles.redRadiobutton,'Value') && (~isempty(spHandles.red))
    choice = get(spHandles.redListbox,'Value');
    img = double(spHandles.red(choice).image);
    ROI = round(double(spHandles.red(choice).spotROI));
    spot = 2;
else return
end

imgSpot = getProfile(img, ROI);
if isempty(imgSpot)
    try delete(hWaitbar), end
    return
end

imgSpot = imgSpot';
% filechoice = 3;
% 
% forcenew = 1;
% 
% if forcenew || isempty(getappdata(0,'I1'))
%     I1 = getProfile('D');
%     I2 = getProfile('A');
%     setappdata(0,'I1',I1)
%     setappdata(0,'I2',I2)
% else
%     I1 = getappdata(0,'I1');
%     I2 = getappdata(0,'I2');
% end

% imgSpot(isnan(imgSpot)) = 0;
% I2(isnan(I2)) = 0;
% 
% spot = zeros(size(I1,1),size(I1,2),3);
% spot(:,:,1) = mat2gray(I2);
% spot(:,:,2) = mat2gray(I1);

% figure
% imagesc(I1)
% figure
% imagesc(I2)
% figure
% img(spot)
% axis image
% figure
% imtool(imgSpot)

%% Store
% Store result
if get(spHandles.greenRadiobutton,'Value') && (~isempty(spHandles.green))
    spHandles.green = storeSpot(spHandles.green, ...
        sprintf('Backspot: %s',spHandles.green(choice).name), ...
        imgSpot, ...
        spHandles.green(choice).ROI, ...
        spHandles.green(choice).spotROI);
    
    updateprofilesListbox(spHandles)
    set(spHandles.greenListbox,'Value',length(spHandles.green));

elseif get(spHandles.redRadiobutton,'Value') && (~isempty(spHandles.red))
    spHandles.red = storeSpot(spHandles.red, ...
        sprintf('Backspot: %s',spHandles.red(choice).name), ...
        imgSpot, ...
        spHandles.red(choice).ROI, ...
        spHandles.red(choice).spotROI);
    
    updateprofilesListbox(spHandles)
    set(spHandles.redListbox,'Value',length(spHandles.red));
end

% Delete waitbar
try delete(hWaitbar), end

% Update
guidata(spHandles.figure1,spHandles)
updateimages(spHandles)


%% Nested

    function vq = getProfile(img,ROI)
        vq = [];
        % if ~exist('img')
%         frames = find(mainhandles.data(filechoice).excorder==DA); % Indices of all donor exc frames
%         img = mean(mainhandles.data(filechoice).imageData(:,:,frames),3); % Avg. image
        imgheight = size(img,1);
        imgwidth = size(img,2);
        
%         [mainhandles, Droi, Aroi] = getROI(mainhandles,filechoice,img);
        % ROI = mainhandles.data(filechoice).Droi;
        % end
        
        % Intensities
        minI = min(img(:));
        maxI = max(img(:));
        d = maxI-minI;
        raw = img;
        
        % Convert
        img = mat2gray(img);
        
%         % D and A data ranges
%         if strcmpi(DA,'D')
%             ROI = Droi;
%         else
%             ROI = Aroi;
%         end
        x = ROI(1):(ROI(1)+ROI(3))-1;
        y = ROI(2):(ROI(2)+ROI(4))-1;
        
        % Cut D and A ROIs from avgimage
        img = img(x,y);
        raw = raw(x,y);
        
        fh = figure;
        set(fh,'units','normalized','Position',[0.05 0.4 0.9 0.5])%,'name',mainhandles.data(filechoice).name)
        flt = [40 40];
        img = medfilt2(img,flt);
        
        %% Estimate lower and upper intensities
        
        val = 0.8;
        img2 = sort(raw);%(:,1:3);
        backmin = max( [max(min(raw,[],1)) max(min(raw,[],2))] );
        backmax = max( img2(round(size(img2,1)*val),:) );
        
        n = 19;
        Ilevel = linspace(backmin,backmax,n);
        level = (Ilevel-minI)/d;
        
        %% Blob analysis
        
        ne = 50;
%         c = zeros(ne*n,3);
        Athres = 1200;
        c = {};
        for i = 1:n
            
            % BW image
            
            temp = im2bw(img,level(i))';
            
            % Show
            subplot(2,round(n/2),i)
            imshow(temp)
%             caxis auto
            title(i)
            
            % Blob detection
            
            obj = regionprops(temp,...
                'Area',...
                'Centroid',...
                'MajorAxisLength',...
                'MinorAxisLength',...
                'Orientation');
            [val,idx] = max([obj(:).Area]);
            
            hold on
            
            % Centroid
            if isempty(obj)
                break
            end
            plot(obj(idx).Centroid(1), obj(idx).Centroid(2), 'b*')
            
            % Ellipse
            
            phi = linspace(0,2*pi,ne);
            cosphi = cos(phi);
            sinphi = sin(phi);
            
            xbar = obj(idx).Centroid(1);
            ybar = obj(idx).Centroid(2);
            
            a = obj(idx).MajorAxisLength/2;
            b = obj(idx).MinorAxisLength/2;
            
            theta = pi*obj(idx).Orientation/180;
            R = [ cos(theta)   sin(theta)
                -sin(theta)   cos(theta)];
            
            xy = [a*cosphi; b*sinphi];
            xy = R*xy;
            
            x = xy(1,:) + xbar;
            y = xy(2,:) + ybar;
            
            plot(x,y,'r','LineWidth',2);
            
            % Coordinates
            if obj(idx).Area>Athres
                c{i,1} = double(x(:));
                c{i,2} = double(y(:));
                c{i,3} = ones(length(x),1)*double(Ilevel(i));
%                 c(ne*(i-1)+1 : ne*i,:)  = [x(:) y(:) ones(length(x),1)*Ilevel(i)];
            else
                break
            end
            hold off
            
            axis xy
            axis image
            
        end
        
        % Prompt
        name = 'Select images';
        formats = prepareformats();
        prompt = {'Select which detected blobs to use for the spot profile: ' 'imgchoices'};
        
        formats(2,1).type = 'list';
        formats(2,1).style = 'listbox';
        formats(2,1).items = num2str([1:size(c,1)]');
        formats(2,1).size = [150 200];
        formats(2,1).limits = [0 2];
        
        DefAns.imgchoices = 1:size(c,1);
        
        [answer, cancelled] = inputsdlg(prompt,name,formats,DefAns);
        if cancelled
            try delete(fh), end
            return
        end
        
        % Choices
        c = c(answer.imgchoices,:);

        % Remove non-filled blobs
%         c(all(c==0,2),:)=[];
%         c = double(c);
        minval = Ilevel(min(answer.imgchoices));
        % All coordinates
        x = [c{:,1}]+ROI(1)-1;
        y = [c{:,2}]+ROI(2)-1;
        z = [c{:,3}];
        
%         xs = [1 1 imgheight imgheight];
%         ys = [1 imgwidth 1 imgwidth];
%         zs = ones(size(xs))*minval;
%         x = [x(:); xs(:)]';
%         y = [y(:); ys(:)]';
%         z = [z(:); zs(:)]';
        [xq,yq] = meshgrid(1:imgheight, 1:imgwidth);
        vq = griddata(x,y,z,xq,yq);
        
        vq = inpaint_nans(vq,2);
        vq = vq/max(vq(:));
%         vq(vq<0) = 0;
%         vq(isnan(vq)) = minval;
        
        try delete(fh), end
    end
end

