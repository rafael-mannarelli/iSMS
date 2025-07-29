function str = getYlabel(mainhandles,ax)
% Returns axes ylabel-string
%
%    Input:
%     mainhandles   - handles structure of the main window
%     ax            - string specifying unique axes
%
%    Output:
%     str           - string to put as ylabel
%

%% Initialize

str = 'y';
alex = mainhandles.settings.excitation.alex;

%% FRETpair window

if strcmpi(ax,'FRETpairwindowAx1')
    if alex
        str = 'D_e_m - D_e_x_c';
    else
        str = 'D';
    end
    return
end

if strcmpi(ax,'FRETpairwindowAx2')
    if alex
        str = 'A_e_m - D_e_x_c';
    else
        str = 'A';
    end
    return
end

if strcmpi(ax,'FRETpairwindowAx3')
    if alex
        str = 'A_e_m - A_e_x_c';
    else
        str = 'Overlay';
    end
    return
end

if strcmpi(ax,'FRETpairwindowAx4')
    if alex
        str = 'Stoichiometry';
    else
        str = 'A_{FRET} + \gamma\timesD';
    end
    return
end

%% Histogramwindow

if strcmpi(ax,'Ehist')
    if alex
        str = '';
    else
        str = 'Observations';
    end
    return
end

%% Correction factor window

if strcmpi(ax,'correctionAx1')
    str = 'D_e_m - D_e_x_c';
    return
end

if strcmpi(ax,'correctionAx2')
    str = 'A_e_m - D_e_x_c';
    return
end


if strcmpi(ax,'correctionAx3')
    if alex
        str = 'A_e_m - A_e_x_c';
    else
        str = 'E';
    end
    return
end

if strcmpi(ax,'correctionAx4')
    if alex
        choice = mainhandles.settings.correctionfactorplot.ax4;
    else
        choice = 1;
    end
    
    if choice==1
    
        if mainhandles.settings.correctionfactorplot.factorchoice == 1
            str = 'D leakage';
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 2
            str = 'A direct';
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 3
            str = 'Gamma';
        end
        
    elseif choice==2
        str = 'S';
    elseif choice==3
        str = 'E';
    end
    
    return
end

%% Drift window

if strcmpi(ax,'driftwindowAx2')
    if alex
        str = 'A_e_m - A_e_x_c';
    else
        str = 'A_e_m - D_e_x_c';
    end
    return
end
