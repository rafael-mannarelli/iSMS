function mainhandles = checkbackgroundCallback(fpwHandles)
% Callback for the check background function in the FRETpairwindow
%
%    Input:
%     fpwHandles   - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles  - handles structure of the main window
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

mainhandles = getmainhandles(fpwHandles);

selectedPairs = getPairs(mainhandles.figure1,'listed');
if isempty(selectedPairs)
    return
end

% Pair selection dialog
if size(selectedPairs,1)>30
    [choices ok] = listdlg(...
        'ListString',getFRETpairString(mainhandles.figure1,fpwHandles.figure1),...
        'Name', 'Check background',...
        'PromptString', 'Select FRET pairs:',...
        'InitialValue', get(fpwHandles.PairListbox,'Value'),...
        'SelectionMode','multiple',...
        'ListSize', [400 300]);
    if ~ok
        return
    end
    selectedPairs = selectedPairs(choices,:);
end

hD = zeros(size(selectedPairs,1),1);
hA = hD;
hAA = hD;
pD = hD;
pA = hD;
pAA = hD;
alpha = 0.001;

fcn = @adtest;%runstest; %corrcoef, adtest, kstest, lillietest, jbtest, runstest

traces = getTraces(mainhandles.figure1,selectedPairs,'nodarkstates',1);

% Calculate Anderson-Darling test scores
warning off
for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    DDback = mainhandles.data(file).FRETpairs(pair).DDback(:);
    ADback = mainhandles.data(file).FRETpairs(pair).ADback(:);
    AAback = mainhandles.data(file).FRETpairs(pair).AAback(:);
    
    pD(i) = getP(mainhandles.data(file).FRETpairs(pair).DDback(:));
    pA(i) = getP(mainhandles.data(file).FRETpairs(pair).ADback(:));
    pAA(i) = getP(mainhandles.data(file).FRETpairs(pair).AAback(:));
    
    [R, P] = corrcoef(DDback,mainhandles.data(file).FRETpairs(pair).Etrace(:));%+DDback);
    pD2(i) = P(2);
    [R, P] = corrcoef(ADback,mainhandles.data(file).FRETpairs(pair).Etrace(:));%+ADback);
    pA2(i) = P(2);
    [R, P] = corrcoef(AAback,mainhandles.data(file).FRETpairs(pair).Etrace(:));%+AAback);
    pAA2(i) = P(2);
    
    %     [hD(i), pD(i)] = kstest(mainhandles.data(file).FRETpairs(pair).DDback, 'alpha',alpha);
    %     [hA(i), pA(i)] = kstest(mainhandles.data(file).FRETpairs(pair).ADback, 'alpha',alpha);
    %     [hAA(i), pAA(i)] = kstest(mainhandles.data(file).FRETpairs(pair).AAback, 'alpha',alpha);
    %     [hD(i), pD2(i)] = lillietest(mainhandles.data(file).FRETpairs(pair).DDback);
    %     [hA(i), pA2(i)] = lillietest(mainhandles.data(file).FRETpairs(pair).ADback);
    %     [hAA(i), pAA2(i)] = lillietest(mainhandles.data(file).FRETpairs(pair).AAback);
    %     [hD(i), pD(i)] = jbtest(mainhandles.data(file).FRETpairs(pair).DDback);
    %     [hA(i), pA(i)] = jbtest(mainhandles.data(file).FRETpairs(pair).ADback);
    %     [hAA(i), pAA(i)] = jbtest(mainhandles.data(file).FRETpairs(pair).AAback);
    %     [hD(i), pD(i)] = runstest(mainhandles.data(file).FRETpairs(pair).DDback);
    %     [hA(i), pA(i)] = runstest(mainhandles.data(file).FRETpairs(pair).ADback);
    %     [hAA(i), pAA(i)] = runstest(mainhandles.data(file).FRETpairs(pair).AAback);
    
%     [~, P] = corrcoef(DDback(:))
%     pD(i) = P;
%     [~, P] = corrcoef(ADback(:))
%     pA(i) = P;
%     [~, P] = corrcoef(AAback(:))
%     pAA(i) = P;
%     
%     %     figure
    %     histfit(mainhandles.data(file).FRETpairs(pair).DDback)
end

warning on

%% Plot

pD
pA
pAA
% pD = 1-pD
% pA = 1-pA
% pAA = 1-pAA
pD2 = 1-pD2;
pA2 = 1-pA2;
pAA2 = 1-pAA2;

p2=[pD2(:) pA2(:) pAA2(:) sum([pD2(:) pA2(:) pAA2(:)],2)]
return
fh = figure;
set(fh,'name','Test score','numbertitle','off')
% plotP(1:length(x),x,1,'myscore')
% plotP(1:length(x),x1,2,'myscore x1')
% plotP(1:length(x),x2,3,'myscore x2')
plotP(1:length(pD),pD2,1,'D background')
plotP(1:length(pA),pA2,2,'A background')
plotP(1:length(pAA),pAA2,3,'AA background')

idx = find(pD>alpha | pA>alpha);
for i = 1:length(idx)
    Db = traces(idx(i)).DDback;
    Db = -1*(Db-median(Db))+median(Db);
    Ab = traces(idx(i)).ADback;
    Ab = -1*(Ab-median(Ab))+median(Ab);
    DD = traces(idx(i)).DD+traces(idx(i)).DDback-Db;
    AD = traces(idx(i)).AD+traces(idx(i)).ADback-Ab;
    
    E = traces(idx(i)).E
end
return

pAD = sum([pD2(:) pA2(:) pAA2(:)],2)
pAD(find(pD2==0 | pA2==0 | pAA2==0),:) = [];

x1 = pA.*pD;
x2 = pA.*pAA;
x1(x1==1) = x2(x1==1);
x2(x2==1) = x1(x2==1);
idx = find(x1==1 & x2==1)
x1(idx) = 0;
x2(idx) = 0;

% x = pA.*(pD+pAA)/2
% x = (x1+x2)/2
% x(x==1) = 0;

x = zeros(size(x1));
idx = find(x1>1-alpha | x2>1-alpha);
x(idx) = 1;
% fh = figure;
% set(fh,'name','Anderson-Darling test results','numbertitle','off')
% % set(fh,'name','kstest results','numbertitle','off')
% % set(fh,'name','lillietest results','numbertitle','off')
% % set(fh,'name','jbtest results','numbertitle','off')
% % set(fh,'name','run s test results','numbertitle','off')
% updatelogo(fh)
% mainhandles.figures{end+1} = fh;
% updatemainhandles(mainhandles)
%
fh = figure;
set(fh,'name','Test score','numbertitle','off')
% plotP(1:length(x),x,1,'myscore')
% plotP(1:length(x),x1,2,'myscore x1')
% plotP(1:length(x),x2,3,'myscore x2')
plotP(1:length(pD),pD,1,'D background')
plotP(1:length(pA),pA,2,'A background')
plotP(1:length(pAA),pAA,3,'AA background')


%% Nested

    function p = getP(d)

        if length(unique(d))<2
            p = 0;
        else
            [~, p] = fcn(d);
%             p = -log(p);%s.z;
        end
        
    end

    function plotP(x,y,ax,tit)
        subplot(3,1,ax)
        
        bar(x,y)
        
        title(tit)
        ylabel('P value')
        xlabel('FRETpair')
        
        % Bar labels
        for i = 1:length(y)
            if y(i)<1-alpha
                txtlab = '';
            else
                txtlab = sprintf('(%i,%i)',selectedPairs(i,1),selectedPairs(i,2));
            end
            
            text(x(i),y(i), txtlab,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom')
        end
        
        
        hold on
        plot(get(gca,'xlim'),[1-alpha 1-alpha],'-r')
%         plot(get(gca,'xlim'),[-20 -20],'-r')
        zoom reset
%         ylim([-30 -10])
        ylim([1-2*alpha 1.001])
    end

end