classdef (Abstract) PlotUtils
    %PlotUtils
    %
    % Provides useful functions for plotting, figures, and axes
    
    % Primary Author: David DeVries
    % Created: July 28, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function vhAxes = CreateCollageOfAxes(dNumTiles, vdGridDimensions, vdTileDimensions, NameValueArgs)
            %vhAxes = CreateCollageOfAxes(dNumTiles, vdGridDimensions, vdTileDimensions, NameValueArgs)
            %
            % SYNTAX:
            %  vhAxes = CreateCollageOfAxes(dNumTiles, vdGridDimensions, vdTileDimensions, NameValueArgs)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  dNumTiles:
            %  vdGridDimensions: 
            %  vdTileDimensions:
            %  NameValueArgs:
            %
            % OUTPUT ARGUMENTS:
            %  vhAxes: 
            
            arguments
                dNumTiles (1,1) double {mustBeInteger, mustBePositive}
                vdGridDimensions (1,2) double {mustBeInteger, mustBePositive}
                vdTileDimensions (1,2) double {mustBePositive, mustBeFinite} % px
                NameValueArgs.DimensionUnits (1,:) char = 'pixels' % one of 'pixels' | 'normalized' | 'inches' | 'centimeters' | 'points' | 'characters'                
                NameValueArgs.TilePadding (1,1) double {mustBeNonnegative, mustBeFinite} = 2 % px
                NameValueArgs.TileLabelFontSize (1,1) double {mustBePositive, mustBeFinite} = 10 % px
                NameValueArgs.TileLabels (1,:) string
                NameValueArgs.TileBorderColor = [1 1 1] % whatever Matlab accepts as a colour; default is white   
                NameValueArgs.TileBorderWidth (1,1) double {mustBeNonnegative, mustBeFinite} = 2.5
            end
            
            dNumGridRows = vdGridDimensions(1);
            dNumGridCols = vdGridDimensions(2);
            
            % additional validations
            ValidationUtils.MustBeOfLength(NameValueArgs.TileLabels, dNumTiles);
            
            if dNumTiles > dNumGridRows*dNumGridCols
                error(...
                    'PlotUtils:CreateCollageOfAxes:InvalidNumberOfTiles',...
                    'The number of tiles cannot exceed the product of the grid dimensions.');
            end
            
            % extract parameters
            if isfield(NameValueArgs, 'TileLabels')
                bShowTileLabels = true;
            else
                bShowTileLabels = false;
            end
            
            dTileLabelFontSize = NameValueArgs.TileLabelFontSize;
            
            dTileHeight = vdTileDimensions(1);
            dTileWidth = vdTileDimensions(2);
            
            dPadding = NameValueArgs.TilePadding;
            
            dFigureWidth = dNumGridCols*(dTileWidth+dPadding) + dPadding;
            dFigureHeight = dNumGridRows*(dTileHeight+dPadding+bShowTileLabels*dTileLabelFontSize) + dPadding;
            
            % create figure to hold the montage
            hFig = figure('Color', [0 0 0],'Resize', 'off');
            
            % set units in figure
            hFig.Units = NameValueArgs.DimensionUnits;
            
            % adjust width and height of figure
            vdCurrentPosition = hFig.Position;
            
            dFigTop = vdCurrentPosition(2) + vdCurrentPosition(4);
            
            vdCurrentPosition(2) = dFigTop - dFigureHeight;
            vdCurrentPosition(3) = dFigureWidth;
            vdCurrentPosition(4) = dFigureHeight;
            
            hFig.Position = vdCurrentPosition;
            
            % subplot works with normalized units...why me?
            % so everything needs to be divided by the total figure width
            % and height
            
            dNormalizedTileHeight = dTileHeight / dFigureHeight;
            dNormalizedTileWidth = dTileWidth / dFigureWidth;
            
            dNormalizedVerticalPadding = dPadding / dFigureHeight;
            dNormalizedHorizontalPadding = dPadding / dFigureWidth;
            
            dNormalizedVerticalSpaceBetweenTiles = (bShowTileLabels*dTileLabelFontSize + dPadding) / dFigureHeight;
            
            dNormalizedFontSize = dTileLabelFontSize / dFigureHeight;
            
            dRowIndex = 1;
            dColIndex = 1;
                      
            c1hAxes = cell(1,dNumTiles);
            
            for dTileIndex=1:dNumTiles
                % create sub-plot for each tile
                dNormalizedAxesBottomLeftX = dNormalizedHorizontalPadding + (dColIndex - 1) * (dNormalizedTileWidth + dNormalizedHorizontalPadding);
                dNormalizedAxesBottomLeftY = 1 - (dNormalizedVerticalPadding + dNormalizedTileHeight) - (dRowIndex - 1) * (dNormalizedTileHeight + dNormalizedVerticalSpaceBetweenTiles);
                
                hAxes = subplot(...
                    'Position', [...
                    dNormalizedAxesBottomLeftX,...
                    dNormalizedAxesBottomLeftY,...
                    dNormalizedTileWidth,...
                    dNormalizedTileHeight]);
                c1hAxes{dTileIndex} = hAxes;
                                
                % change units to pixels
                hAxes.Units = 'pixels';
                
                % turn box on
                axis(hAxes, 'on');
                hAxes.Box = 'on';
                hAxes.XColor = NameValueArgs.TileBorderColor;
                hAxes.YColor = NameValueArgs.TileBorderColor;
                hAxes.LineWidth = NameValueArgs.TileBorderWidth;
                xticks(hAxes, []);
                yticks(hAxes, []);
                
                % render the image label
                if bShowTileLabels
                    sLabel = NameValueArgs.TileLabels(dTileIndex);
                    
                    vdAxesPosition = hAxes.Position;
                    dAxesWidth = vdAxesPosition(3);
                    
                    hText = text(...
                        hAxes,...
                        dAxesWidth/2, 0,...
                        sLabel,...
                        'Units', 'pixels',...
                        'Color', [1 1 1],...
                        'Margin', eps,...
                        'FontSize', dTileLabelFontSize,...
                        'FontUnits', NameValueArgs.DimensionUnits,...
                        'HorizontalAlignment', 'center',...
                        'VerticalAlignment', 'middle');
                    
                    hText.FontUnits = 'pixels';
                    
                    dFontSizePixels = hText.FontSize;
                    
                    vdCurrentTextPosition = hText.Position;
                    vdCurrentTextPosition(2) = (-dFontSizePixels/2) + 1;
                    hText.Position = vdCurrentTextPosition;
                end
                
                % increment index in montage grid
                if dColIndex == dNumGridCols % jump to next row
                    dColIndex = 1;
                    dRowIndex = dRowIndex + 1;
                else
                    dColIndex = dColIndex + 1; % run along row left to right
                end
            end
            
            % convert cell array of axes handles to vector
            vhAxes = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1hAxes);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private) % None
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)
    end
end

