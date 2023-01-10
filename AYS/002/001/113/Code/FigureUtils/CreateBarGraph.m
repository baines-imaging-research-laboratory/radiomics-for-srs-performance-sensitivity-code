function [hFig, hLegendFig, hAxes] = CreateBarGraph(m2dDataPerGroupPerVariable, vsLabelPerGroup, NameValueArgs)

% m2dDataPerGroup
% # rows = # groups    (groups are spaced out along the x axis and are identified via x-axis labels e.g. vsLabelPerGroup)
% # cols = # variables (variables are plotted one next to each other and are identified via the legend)

arguments
    m2dDataPerGroupPerVariable
    vsLabelPerGroup
    NameValueArgs.ErrorBarSizePerGroupPerVariable
    NameValueArgs.FontSize
    NameValueArgs.FontName
    NameValueArgs.GroupSpacing = 0.1
    NameValueArgs.VariableSpacing = 0.05
    NameValueArgs.TexturePerVariable
    NameValueArgs.BarColourPerVariable
    NameValueArgs.TextureColourPerVariable
    NameValueArgs.VariableVisibility
    NameValueArgs.GroupVisibility
    NameValueArgs.LegendVariableNames
    NameValueArgs.FigureSize
    NameValueArgs.FigureSizeUnits    
    NameValueArgs.FillFigure = true
    NameValueArgs.XLabel
    NameValueArgs.YLabel
    NameValueArgs.YTicks
    NameValueArgs.YLim
    NameValueArgs.XTickAngle
    NameValueArgs.TextureLineWidth = 2
    NameValueArgs.TextureLineSpacing = 15
    NameValueArgs.LatexOn = false
end

dTextureLineWidth = NameValueArgs.TextureLineWidth;
dTextureLineSpacing = NameValueArgs.TextureLineSpacing;

dNumGroups = size(m2dDataPerGroupPerVariable, 1);
dNumVariables = size(m2dDataPerGroupPerVariable, 2);

if ~isfield(NameValueArgs, 'VariableVisibility')
    NameValueArgs.VariableVisibility = true(dNumVariables,1);
end

if ~isfield(NameValueArgs, 'GroupVisibility')
    NameValueArgs.GroupVisibility = true(dNumGroups,1);
end


hFig = figure();
hAxes = axes();

if isfield(NameValueArgs, 'FigureSize')
    if isfield(NameValueArgs, 'FigureSizeUnits')
        chCachedUnits = hFig.Units;
        hFig.Units = NameValueArgs.FigureSizeUnits;
    end
    
    hFig.Position(3:4) = NameValueArgs.FigureSize;
    
    if isfield(NameValueArgs, 'FigureSizeUnits')
        hFig.Units = chCachedUnits;
    end
end


xlim([0, dNumGroups]);
xticks(0.5:1:dNumGroups-0.5);

xticklabels([]);

dMaxGroupLabelHeight = 0;

c1xVarargin = {};

if isfield(NameValueArgs, 'FontSize')
    c1xVarargin = [c1xVarargin, {'FontSize', NameValueArgs.FontSize}];
end

if isfield(NameValueArgs, 'FontName')
    c1xVarargin = [c1xVarargin, {'FontName', NameValueArgs.FontName}];
end

for dGroupIndex=1:dNumGroups
    hTempText = text(0,0,strsplit(vsLabelPerGroup(dGroupIndex),"\\n"), c1xVarargin{:});
        
    dMaxGroupLabelHeight = max(dMaxGroupLabelHeight, hTempText.Extent(4));
    
    delete(hTempText);
end


if isfield(NameValueArgs, 'XTickAngle')
    xtickangle(NameValueArgs.XTickAngle);
end

hHiddenFigure = figure('Visible','off');
bar(m2dDataPerGroupPerVariable);
vdAutoYLim = ylim(gca);
delete(hHiddenFigure);

ylim(vdAutoYLim);

if isfield(NameValueArgs, 'YTicks')
    yticks(NameValueArgs.YTicks);
end
   
if isfield(NameValueArgs, 'YLim')
    ylim(NameValueArgs.YLim);
else
    ylim(vdAutoYLim);
end

hAxes.YGrid = 'on';
hAxes.TickLength = [0 0];

if NameValueArgs.LatexOn
    c1xVarargin = {'interpreter','latex'};
else
    c1xVarargin = {};
end

if isfield(NameValueArgs, 'YLabel')
    ylabel(hAxes, NameValueArgs.YLabel, c1xVarargin{:});
end

xlabel("Test");

dWidthPerBar = (1 - 2*NameValueArgs.GroupSpacing - (dNumVariables-1) * NameValueArgs.VariableSpacing) / dNumVariables;

c2hBarPatchHandlesPerDataPoint = cell(dNumGroups, dNumVariables);
c2hBarTextureHandlesPerDataPoint = cell(dNumGroups, dNumVariables);

for dGroupIndex=1:dNumGroups
    
    dBarStartingX = (dGroupIndex-1) + NameValueArgs.GroupSpacing;
    
    for dVariableIndex=1:dNumVariables
        dX1 = dBarStartingX + (dVariableIndex-1)*(dWidthPerBar + NameValueArgs.VariableSpacing);
        dX2 = dX1 + dWidthPerBar;
        
        dY1 = 0;
        dY2 = m2dDataPerGroupPerVariable(dGroupIndex, dVariableIndex);
        
        hBar = patch([dX1, dX1, dX2, dX2], [dY1, dY2, dY2, dY1], NameValueArgs.BarColourPerVariable{dVariableIndex});
        c2hBarPatchHandlesPerDataPoint{dGroupIndex, dVariableIndex} = hBar;
                
        if ~NameValueArgs.VariableVisibility(dVariableIndex) || ~NameValueArgs.GroupVisibility(dGroupIndex)
            hBar.Visible = 'off';
        end
    end
end


if isfield(NameValueArgs, 'FontSize')
    hAxes.FontSize = NameValueArgs.FontSize;
end

if isfield(NameValueArgs, 'FontName')
    hAxes.FontName = NameValueArgs.FontName;
end




drawnow;

if NameValueArgs.FillFigure    
    vdInSet = get(hAxes, 'TightInset');
    set(hAxes, 'Position', [vdInSet(1), vdInSet(2)+dMaxGroupLabelHeight, 1-vdInSet(1)-vdInSet(3)-0.005, 1-vdInSet(2)-vdInSet(4)-dMaxGroupLabelHeight-0.005]);
end

if isfield(NameValueArgs, 'XLabel')
    xticklabels(repmat(" ", dNumGroups, 1));
    xlabel(NameValueArgs.XLabel);
end

vdYLim = ylim(hAxes);

for dGroupIndex=1:dNumGroups
    c1xVarargin = {};
    
    if isfield(NameValueArgs, 'FontSize')
        c1xVarargin = [c1xVarargin, {'FontSize', NameValueArgs.FontSize}];
    end
    
    if isfield(NameValueArgs, 'FontName')
        c1xVarargin = [c1xVarargin, {'FontName', NameValueArgs.FontName}];
    end
        
    text(dGroupIndex-0.5, vdYLim(1), strsplit(vsLabelPerGroup(dGroupIndex), "\\n"), 'VerticalAlignment', 'cap', 'HorizontalAlignment', 'center', c1xVarargin{:});
end



for dGroupIndex=1:dNumGroups
        
    for dVariableIndex=1:dNumVariables
        
        if NameValueArgs.TexturePerVariable(dVariableIndex) == "Solid"
            % no texture call needed
            hTexture = [];
        else
            switch NameValueArgs.TexturePerVariable(dVariableIndex)
                case "Line0"
                    chStyle = 'single';
                    dAngle = 0;
                case "Line45"
                    chStyle = 'single';
                    dAngle = 45;
                case "Line135"
                    chStyle = 'single';
                    dAngle = 135;
                case "Cross0"
                    chStyle = 'cross';
                    dAngle = 0;
                case "Cross45"
                    chStyle = 'cross';
                    dAngle = 45;
            end
            
            hTexture = hatchfill(c2hBarPatchHandlesPerDataPoint{dGroupIndex, dVariableIndex}, chStyle, dAngle, dTextureLineSpacing, NameValueArgs.BarColourPerVariable{dVariableIndex}, 'LineWidth', dTextureLineWidth, 'LineColour', NameValueArgs.TextureColourPerVariable{dVariableIndex});
            c2hBarTextureHandlesPerDataPoint{dGroupIndex, dVariableIndex} = hTexture;
        end
        
        if ~isempty(hTexture) && (~NameValueArgs.VariableVisibility(dVariableIndex) || ~NameValueArgs.GroupVisibility(dGroupIndex))
            hTexture.Visible = 'off';
        end
    end
end


for dGroupIndex=1:dNumGroups
    
    dBarStartingX = (dGroupIndex-1) + NameValueArgs.GroupSpacing;
    
    for dVariableIndex=1:dNumVariables
        dX1 = dBarStartingX + (dVariableIndex-1)*(dWidthPerBar + NameValueArgs.VariableSpacing);
        dX2 = dX1 + dWidthPerBar;
        
        dY1 = 0;
        dY2 = m2dDataPerGroupPerVariable(dGroupIndex, dVariableIndex);
        
        hBar = patch('XData', [dX1, dX1, dX2, dX2], 'YData', [dY1, dY2, dY2, dY1], 'FaceColor', 'none');
                
        if ~NameValueArgs.VariableVisibility(dVariableIndex) || ~NameValueArgs.GroupVisibility(dGroupIndex)
            hBar.Visible = 'off';
        end
    end
end

% add error bars (if needed)
if isfield(NameValueArgs, 'ErrorBarSizePerGroupPerVariable')
    m2dErrorBarSizePerGroupPerVariable = NameValueArgs.ErrorBarSizePerGroupPerVariable;
    
    for dGroupIndex=1:dNumGroups
        
        dBarStartingX = (dGroupIndex-1) + NameValueArgs.GroupSpacing;
        
        for dVariableIndex=1:dNumVariables
            dCentrelineX = dBarStartingX + (dVariableIndex-1)*(dWidthPerBar + NameValueArgs.VariableSpacing) + (dWidthPerBar/2);
            
            dValueY = m2dDataPerGroupPerVariable(dGroupIndex, dVariableIndex);
            
            dUpperY = dValueY + m2dErrorBarSizePerGroupPerVariable(dGroupIndex, dVariableIndex);
            dLowerY = dValueY - m2dErrorBarSizePerGroupPerVariable(dGroupIndex, dVariableIndex);
            
            dErrorBarWidth = 0.75 * dWidthPerBar;
            
            dLeftX = dCentrelineX - (dErrorBarWidth/2);
            dRightX = dCentrelineX + (dErrorBarWidth/2);
            
            hCentreline = line([dCentrelineX, dCentrelineX], [dLowerY, dUpperY], 'Color', [0 0 0], 'LineWidth', 1);
            
            hUpperBar = line([dLeftX, dRightX], [dUpperY, dUpperY], 'Color', [0 0 0], 'LineWidth', 1);
            hLowerBar = line([dLeftX, dRightX], [dLowerY, dLowerY], 'Color', [0 0 0], 'LineWidth', 1);
            
            if ~NameValueArgs.VariableVisibility(dVariableIndex) || ~NameValueArgs.GroupVisibility(dGroupIndex)
                hCentreline.Visible = 'off';
                
                hUpperBar.Visible = 'off';
                hLowerBar.Visible = 'off';
            end
        end
    end
    
end





% Legend

if isfield(NameValueArgs, 'LegendVariableNames')
    hLegendFig = figure();
    hLegendAxes = axes();
    
    hLegendFig.Units = 'pixels';
    hLegendAxes.Units = 'pixels';
    
    vdPosition = hLegendFig.Position;
    vdPosition(1:2) = [0 0];
    
    hLegendAxes.Position = vdPosition;
    
    xlim([0, vdPosition(3)]);
    ylim([0, vdPosition(4)]);
    
    hTestText = text(0,0,"Test");
    
    if isfield(NameValueArgs, 'FontSize')
        hTestText.FontSize = NameValueArgs.FontSize;
    end
    
    if isfield(NameValueArgs, 'FontName')
        hTestText.FontName = NameValueArgs.FontName;
    end
    
    dHeight = hTestText.Extent(4);
    
    delete(hTestText);
    
    vsLegendVariableNames = NameValueArgs.LegendVariableNames;
    vsLegendVariableNames = vsLegendVariableNames(NameValueArgs.VariableVisibility);
    
    vdVisibleVarIndex = 1:dNumVariables;
    vdVisibleVarIndex = vdVisibleVarIndex(NameValueArgs.VariableVisibility);
    
    dSpacing = 5;
    
    dStartX = dSpacing;
    
    for dVarIndex=1:length(vsLegendVariableNames)
        dX1 = dStartX;
        dX2 = dX1 + dHeight;
        
        dY1 = dSpacing;
        dY2 = dHeight+dSpacing;
        
        hPatch = patch([dX1 dX1 dX2 dX2], [dY1 dY2 dY2 dY1],  NameValueArgs.BarColourPerVariable{vdVisibleVarIndex(dVarIndex)});
                
        if NameValueArgs.TexturePerVariable(vdVisibleVarIndex(dVarIndex)) == "Solid"
            % no texture call needed
        else
            switch NameValueArgs.TexturePerVariable(vdVisibleVarIndex(dVarIndex))
                case "Line0"
                    chStyle = 'single';
                    dAngle = 0;
                case "Line45"
                    chStyle = 'single';
                    dAngle = 45;
                case "Line135"
                    chStyle = 'single';
                    dAngle = 135;
                case "Cross0"
                    chStyle = 'cross';
                    dAngle = 0;
                case "Cross45"
                    chStyle = 'cross';
                    dAngle = 45;
            end
            
            hTexture = hatchfill(hPatch, chStyle, dAngle, dTextureLineSpacing, NameValueArgs.BarColourPerVariable{vdVisibleVarIndex(dVarIndex)}, 'LineWidth', dTextureLineWidth, 'LineColour', NameValueArgs.TextureColourPerVariable{vdVisibleVarIndex(dVarIndex)});            
        end
        
        
        dStartX = dX2 + dSpacing;
        
        hText = text(dStartX, dSpacing, vsLegendVariableNames(dVarIndex), 'VerticalAlignment', 'bottom');
        
        if isfield(NameValueArgs, 'FontSize')
            hText.FontSize = NameValueArgs.FontSize;
        end
        
        if isfield(NameValueArgs, 'FontName')
            hText.FontName = NameValueArgs.FontName;
        end
        
        dStartX = dStartX + hText.Extent(3) + dSpacing;
    end
    
    dFigHeight = dHeight + 2*dSpacing;
    dFigWidth = dStartX;
    
    hLegendAxes.Units = 'pixels';
    
    hLegendAxes.Position = [0, 0, dFigWidth, dFigHeight];
    xlim([0, dFigWidth]);
    ylim([0, dFigHeight]);
    
    hLegendFig.Position(3:4) = [dFigWidth, dFigHeight];
    
    axis(hLegendAxes, 'off');
else
    hLegendFig = [];
end






end

