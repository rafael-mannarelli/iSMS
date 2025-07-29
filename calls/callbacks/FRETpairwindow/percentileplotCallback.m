function mainhandles = percentileplotCallback(fpwHandles)

%% Initialize

% Get handles structure
mainhandles = getmainhandles(fpwHandles);

for i = 1:length(mainhandles.figures)
    try close(mainhandles.figures{i}), end
end

% Selected pairs
selectedPairs = getPairs(fpwHandles.main,'selected');
if isempty(selectedPairs)
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single pair only.')
    return
end

% Selection
file = selectedPairs(1,1);
pair = selectedPairs(1,2);

% If data is missing
if isempty(mainhandles.data(file).DD_ROImovie)
    mymsgbox('Please reload the raw data in order to continue with the requested action.')
    return
end

% Save to restore afterwards
pair_before = mainhandles.data(file).FRETpairs(pair);
settings_before = mainhandles.settings;

% Change settings temporarily
prct = 55;
mainhandles.settings.integration.choice = 1; % Aperture
mainhandles.settings.background.bleachchoice = 0; % Dont subtract background after bleach
mainhandles.settings.background.blinkchoice = 0;
mainhandles.settings.FRETpairplots.exPixels = 1;

% Settings
aperture_widths = 10;%[1 3:11];
aperture_space = 2;
aperture_backwidth = 1;

%% Calculate

% Waitbar
hWaitbar = mywaitbar(0,'Calculating...');

% Initialize data
data = struct(...
    'wh', []);
data(:) = [];

% Collect mean reference
mainhandles.settings.background.backtype = 1;
i = aperture_widths;
[mainhandles, refdata] = calculateTraces(mainhandles,data);

% Back types
prctiles = 40:1:75;

alldata = cell(1,3);
for jj = 1:length(prctiles)
    
    mainhandles.settings.background.backtype = 3;
    mainhandles.settings.background.prctile = prctiles(jj);
    
    % Initialize data
    data(:) = [];
    
    for i = aperture_widths
        [mainhandles, data] = calculateTraces(mainhandles,data);
    end
    
    % Collect
    alldata{jj} = data;
    
    % Waitbar
    waitbar(jj/length(prctiles),hWaitbar);
end

% Delete waitbar
try delete(hWaitbar), end

% Images
mainhandles = calculateMoleculeImages(mainhandles.figure1,[file pair]);
DD_avgimage = mainhandles.data(file).FRETpairs(pair).DD_avgimage;
AD_avgimage = mainhandles.data(file).FRETpairs(pair).AD_avgimage;
AA_avgimage = mainhandles.data(file).FRETpairs(pair).AA_avgimage;

%% Restore and plot

% Restore original pair
mainhandles.data(file).FRETpairs(pair) = pair_before;
mainhandles.settings = settings_before;
updatemainhandles(mainhandles);

% Round-off difference used to correct image centers later:
limcorrect = mainhandles.data(file).FRETpairs(pair).limcorrect;

% If D or A is at the edge of the ROI make image smaller
edges = mainhandles.data(file).FRETpairs(pair).edges;

% Plot
Bref = sum(refdata.DDbackVal(:));
B = zeros(length(prctiles),1);
for ii = 1:length(prctiles)
    data = alldata{ii};
    B(ii) = (sum(data.DDbackVal(:))-Bref).^2;
end
fh = figure(5);
updatelogo(fh)
ax = gca;
hold off

plot(prctiles,B)
title(sprintf('Minimum: %.1f%%',prctiles(B==min(B))))

xlabel('Percentile')
ylabel('RMS')
updateUIcontextMenus(mainhandles.figure1,ax);
hold on
ylims = get(ax,'ylim');
plot([50 50],ylims,'r')

updatemainhandles(mainhandles)

% Set positions
% set(mainhandles.figures{end-2},'Units','Normalized','Position',[0 0 0.33 1])
% set(mainhandles.figures{end-1},'Units','Normalized','Position',[0.33 0 0.33 1])
% set(mainhandles.figures{end},'Units','Normalized','Position',[00.66 0 0.33 1])

%% Nested

    function [mainhandles, data] = calculateTraces(mainhandles, data)
        % Change temporarily
        mainhandles.data(file).FRETpairs(pair).Dwh = [i i];
        mainhandles.data(file).FRETpairs(pair).Awh = [i i];
        mainhandles.data(file).FRETpairs(pair).DintMask = [];
        mainhandles.data(file).FRETpairs(pair).AintMask = [];
        mainhandles.data(file).FRETpairs(pair).backspace = aperture_space;
        mainhandles.data(file).FRETpairs(pair).backwidth = aperture_backwidth;
        updatemainhandles(mainhandles)
        
        % Calcualte traces
        mainhandles = calculateIntensityTraces(mainhandles.figure1,[file pair],0);
        
        % Store this trace
        data(end+1).wh = i;
        data(end).DDtrace = mainhandles.data(file).FRETpairs(pair).DDtrace;
        data(end).ADtrace = mainhandles.data(file).FRETpairs(pair).ADtrace;
        data(end).AAtrace = mainhandles.data(file).FRETpairs(pair).AAtrace;
        
        data(end).DDback = mainhandles.data(file).FRETpairs(pair).DDback;
        data(end).ADback = mainhandles.data(file).FRETpairs(pair).ADback;
        data(end).AAback = mainhandles.data(file).FRETpairs(pair).AAback;
        
        data(end).Etrace = mainhandles.data(file).FRETpairs(pair).Etrace;
        
        data(end).Dbleach = mainhandles.data(file).FRETpairs(pair).DbleachingTime;
        data(end).Ableach = mainhandles.data(file).FRETpairs(pair).AbleachingTime;
        
        data(end).DDraw = data(end).DDtrace+data(end).DDback;
        data(end).ADraw = data(end).ADtrace+data(end).ADback;
        data(end).AAraw = data(end).AAtrace+data(end).AAback;
        
        data(end).DDscr = data(end).DDtrace./data(end).DDraw;
        data(end).ADscr = data(end).ADtrace./data(end).ADraw;
        data(end).AAscr = data(end).AAtrace./data(end).AAraw;
        
        data(end).DintPixels = length(find(mainhandles.data(file).FRETpairs(pair).DintMask));
        data(end).AintPixels = length(find(mainhandles.data(file).FRETpairs(pair).AintMask));
        
        data(end).DDbackVal = data(end).DDback/data(end).DintPixels;
        data(end).ADbackVal = data(end).ADback/data(end).AintPixels;
        data(end).AAbackVal = data(end).AAback/data(end).AintPixels;
        
        data(end).DintMask = mainhandles.data(file).FRETpairs(pair).DintMask;
        data(end).DbackMask = mainhandles.data(file).FRETpairs(pair).DbackMask;
        
        data(end).allIsDD = getappdata(0,'allIsDD');
        data(end).allbacksDD = getappdata(0,'allbacksDD');
        data(end).allIsAD = getappdata(0,'allIsAD');
        data(end).allbacksAD = getappdata(0,'allbacksAD');
        data(end).allIsAA = getappdata(0,'allIsAA');
        data(end).allbacksAA = getappdata(0,'allbacksAA');
    end

    function fh = plottheAp(str,col,img, limcorrect, edge,data)
        
        % Calculate signatures
        [I, B] = calcSignature();
        
        % Make separate figure plot
        %         fh2 = figure(1);
        %         ax1 = subplot(4,1,1);
        %         wh = aperture_widths(find(scrs_before==max(scrs_before))); % For
        %         plotting ring
        
        % Image
        imageMolecule(ax1);
        
        % Plot signatures
        ax2 = plotSignature(ax2, I, I(1), 'Norm. intensity', [],[]);
        ax3 = plotSignature(ax3, B, B(1), 'Norm. background', 'auto', 'Aperture width /pixels');
        %         ax4 = plotSignature(subplot(4,1,4), scrs_before, 1, 'S/N', 'auto', 'Aperture width');
        
        % Set axes positions
        if ii==3
            setAxPos();
        end
        
        % Handle output
        fh = fh2;
        
        % Plot traces
        plotTraces();
        
        %% Nested
        
        function imageMolecule(ax)%mainhandles, ax, img, limcorrect, edge)
            %             ax = gca;
            
            % Check contrast
            if isempty(mainhandles.data(file).FRETpairs(pair).contrastslider) % Set a default contrast slider value, if it's empty
                mainhandles.data(file).FRETpairs(pair).contrastslider = 0;
                updatemainhandles(mainhandles)
            end
            contrastMax = 1-mainhandles.data(file).FRETpairs(pair).contrastslider;
            
            % Set Contrast
            maxValue = (max(img(:))-min(img(:)))*contrastMax + min(img(:));
            img(img>maxValue) = maxValue;
            
            % Make logarithmic scale plot
            if mainhandles.settings.FRETpairplots.logImage
                %                 img = real(log10(img));
            end
            
            % Aperture movie
            %
            %         fh = figure;
            %         wh = aperture_widths(1);
            %         imageMolecule();
            %         for j = 1:length(aperture_widths)
            %             wh = aperture_widths(j);
            %             imageMolecule();
            % %             pause(0.5)
            %             waitfor(msgbox('continue'))
            %         end
            
            % Plot image
            hImg = imagesc(img,'Parent',ax); % Show image
            updateUIcontextMenus(mainhandles.figure1,hImg);
            colormap(jet)
            
            % Set axis properties
            axis(ax,'image') % Equalizes x and y limits
            set(ax,'YDir','normal') % Flips y-axis so that it goes from low to high numbers, going up
            if ~strcmp(get(ax,'XTickLabel'),'') % Remove axes labels
                set(ax, 'XTickLabel','')
                set(ax, 'YTickLabel','')
            end
            
            % Make sure moleucule position is in the exact center of the image
            
            % Check current limits
            xlims = get(ax,'xlim'); % Get current x-limits
            ylims = get(ax,'ylim'); % Get current y-limits
            xlims = xlims+limcorrect(1)+[1 -1]+0.0; % Correct center of image due to pixel round-off. +[1 -1] to avoid white edges
            ylims = ylims+limcorrect(2)+[1 -1]+1.0;
            
            % If molecule is located at an edge set additional limits
            if sum(edge)>0
                xlims = [xlims(1)-edge(1) xlims(2)+edge(2)];
                ylims = [ylims(1)-edge(3) ylims(2)+edge(4)];
            end
            
            % Set new limits
            xlims = sort(xlims);
            ylims = sort(ylims);
            xlim(ax,xlims) % Set axis limits so that Dxy is in the exact center of the image
            ylim(ax,ylims)
            
            return
            % Filled circle
            xc = mean(xlims);
            yc = mean(ylims);
            r = wh/2;
            x = r*sin(-pi:0.05*pi:pi) + xc;
            y = r*cos(-pi:0.05*pi:pi) + yc;
            c = [0.8 0.8 0.8];
            hold on
            %             fill(x, y, c, 'FaceAlpha', 0.4)
            hold off
            
            % Filled ring
            %             r2 = wh/2+1;
            %             x2 = r2*sin(-pi:0.05*pi:pi) + xc;
            %             y2 = r2*cos(-pi:0.05*pi:pi) + yc;
            %             c2 = [0.8 0.8 0.8];
            %
            %             hold on
            %             fill(x, y, c, 'FaceAlpha', 0.4)
            %             hold off
            
            % Intensity ring
            viscircles([mean(xlims) mean(ylims)],wh(1)/2,'EdgeColor','white','LineWidth',0.5);
            
            % Background ring
            %             viscircles([mean(xlims) mean(ylims)],wh(1)/2+1,'EdgeColor',[0.7 0.7 0.7],'LineWidth',2,'DrawBackgroundCircle',false);
        end
        
        function fh = histogramPlot()
            fh = [];
            %             if j==5 && strcmpi(str,'DD')
            %                 fh = figure(50)
            %                 hold off
            %                 hist(allbackvector,100)
            %                 hold on
            %                 line([mean(allbackvector) mean(allbackvector)],get(gca,'ylim'),'color','black','linewidth',3)
            %                 line([prctile(allbackvector,prctile) prctile(allbackvector,prctile)],get(gca,'ylim'),'color','green','linewidth',1.5)
            %                 line([median(allbackvector) median(allbackvector)],get(gca,'ylim'),'color','red','linewidth',3)
            %                 xlim([0 100])
            %                 set(gca,'fontsize',15)
            %                 xlabel('Pixel value','fontsize',15)
            %                 ylabel('Number of pixels','fontsize',15)
            %             end
        end
        
        function [I B] = calcSignature()
            %         scrs_before = zeros(length(aperture_widths),1);
            %         scrs_after = [];
            I = zeros(length(aperture_widths),1);
            B = zeros(length(aperture_widths),1);
            %
            %         stdbacks = zeros(length(aperture_widths),1);
            %         prcbacks = zeros(length(aperture_widths),1);
            %
            for j = 1:length(aperture_widths)
                bidx = data(j).([str(1) 'bleach']);
                
                % Background-corrected intensity
                if ~isempty(bidx) && bidx<length(data(j).([str 'trace']))
                    I(j) = sum(data(j).([str 'trace'])(1:bidx-1));
                else
                    I(j) = sum(data(j).([str 'trace'])(:));
                end
                
                % Avg. background
                if ~isempty(bidx) && bidx<length(data(j).([str 'trace']))
                    B(j) = sum(data(j).([str 'backVal'])(1:bidx-1));
                else
                    B(j) = sum(data(j).([str 'backVal'])(:));
                end
                
                %             scr = data(j).([str 'scr']);
                %             %             scr = medianSmoothFilter(scr,5);
                %             scr_after = [];
                %             if ~isempty(bidx) && bidx<length(scr)
                %                 scr_before = mean(scr(1:bidx-1));
                %                 scr_after = mean(scr(bidx+1:end));
                %             else
                %                 scr_before = mean(scr);
                %             end
                %
                %             % Store
                %             scrs_before(j) = scr_before;
                %             if ~isempty(scr_after)
                %                 scrs_after(end+1) = scr_after;
                %             end
                %
                %             % Collect all pixels
                %             if ~isempty(bidx) && bidx<length(scr)
                %                 allbackvector = [data(j).(['allbacks' str]){1:bidx-1}];
                %             else
                %                 allbackvector = [data(j).(['allbacks' str]){:}];
                %             end
                %             allbackvector = double(allbackvector(:));
                %
                %             % Background dispersion estimators
                %             stdbacks(j) = std(allbackvector);
                %             prcbacks(j) = prctile(allbackvector,prct);%[10 50 90])
                %
                %             % Histogram plot
                %             fh = histogramPlot();
                %
                %         end
                
            end
        end
        
        function ax = plotSignature(ax,y,normY,ylab,xtick,xlab)
            
            %             if ii==1
            %                 hold(ax,'off')
            %             else
            %                 hold(ax,'on')
            %             end
            %
            % Plot
            y = y/normY;%sums_before/sums_before(1);
            cols = {'blue','green','red'};
            plot(ax,aperture_widths,y,'color',cols{ii})
            
            % Y ax
            %             ylim([min(y(:)) max(y(:))])
            ylabel(ax,ylab)
            
            % X ax
            xlim(ax,[min(aperture_widths(:)) max(aperture_widths(:))])
            if isempty(xtick)
                set(ax,'xtick',xtick)
            end
            if ~isempty(xlab)
                xlabel(ax,xlab)
            end
            
            box(ax,'on')
        end
        
        function plotTraces2()
            
        end
        
        function setAxPos()
            setpixelposition(fh2,[figxPos 10 220 768])
            
            corr = 24;
            axp1 = getpixelposition(ax1);
            axp2 = getpixelposition(ax2);
            setpixelposition(ax2,[axp2(1)+corr axp1(2)-axp2(4)+corr axp1(3:4)-corr])
            
            axp2 = getpixelposition(ax2);
            axp3 = getpixelposition(ax3);
            setpixelposition(ax3,[axp2(1) axp2(2)-axp3(4)+corr axp2(3:4)])
            
            %             axp3 = getpixelposition(ax3);
            %             axp4 = getpixelposition(ax4);
            %             setpixelposition(ax4,[axp3(1) axp3(2)-axp4(4) axp3(3:4)])
            
            axp1 = getpixelposition(ax1);
            setpixelposition(ax1,[axp2(1) axp1(2) axp1(3:4)-corr])
            
            updateUIcontextMenus(mainhandles.figure1,[ax1 ax2 ax3])% ax4])
        end
        
        function plotTraces()
            %         run = 4;
            %         xi = [1 100];
            %         for j = steps
            %             wh = aperture_widths(j);
            %
            %             subplot(nrows,3,run)
            %             I = data(j).([str 'trace'])(1:xi(2));
            %             plot(1:2:length(I)*2,I,'color',col)
            %             title(sprintf('wh = %i',wh))
            %             ylim([min(I(:)) max(I(:))])
            %             xlim([xi(1) xi(2)*2])
            %             if j<steps(end)
            %                 set(gca,'xtick',[])
            %             else
            %                 xlabel('Frame')
            %             end
            %             if j==steps(1)
            %                 title(sprintf('wh = %i; Intensity',wh))
            %             end
            %             run = run+1;
            %
            %             subplot(nrows,3,run)
            %             B = data(j).([str 'back'])(1:xi(2));
            %             plot(1:2:length(B)*2,B,'color','black')
            %             ylim([min(B(:)) max(B(:))])
            %             xlim([xi(1) xi(2)*2])
            %             if j<steps(end)
            %                 set(gca,'xtick',[])
            %             else
            %                 xlabel('Frame')
            %             end
            %             if j==steps(1)
            %                 title('Backgr.')
            %             end
            %             run = run+1;
            %
            % %             % S/N
            % %             subplot(nrows,3,run)
            % %             scr = data(j).([str 'scr'])(1:xi(2));
            % %             plot(1:2:length(scr)*2,scr,'color','black')
            % % %             title(sprintf('wh = %i',wh))
            % % %             ylabel('S/N')
            % %             ylim([min(scr(:)) max(scr(:))])
            % %             xlim([xi(1) xi(2)*2])
            % %             if j<steps(end)
            % %                 set(gca,'xtick',[])
            % %             else
            % %                 xlabel('Frame')
            % %             end
            % %             if j==steps(1)
            % %                 title('Signal/Total')
            % %             end
            % %             run = run+1;
            %
            %             % Molecules
            %             subplot(nrows,3,run)
            %             imageMolecule()
            %             run = run+1;
            
            %         end
            
        end
        
        function plotUnknown()
            %         subplot(nrows,3,1)
            %         sumI = sums_before/sums_before(1);
            %         plot(aperture_widths,sumI,'color','black')
            %         ylim([min(sumI(:)) max(sumI(:))])
            %         ylabel('Norm. sum')
            %         xlabel('Width')
            %         title('Total count')
            %         xlim([min(aperture_widths(:)) max(aperture_widths(:))])
            %
            %         subplot(nrows,3,2)
            %         backI = backs_before/backs_before(1);
            %         plot(aperture_widths,backI,'color','black')
            %         ylim([min(backI(:)) max(backI(:))])
            %         ylabel('Norm. backgr.')
            %         xlabel('Width')
            %         title('Background')
            %         xlim([min(aperture_widths(:)) max(aperture_widths(:))])
            %
            %         subplot(nrows,3,3)
            %         plot(aperture_widths,scrs_before,'color','black')
            %         ylim([min(scrs_before(:)) max(scrs_before(:))])
            %         xlim([min(aperture_widths(:)) max(aperture_widths(:))])
            %         ylabel('S/N')
            %         xlabel('Width')
            %         title('Signal/total')
        end
    end

end