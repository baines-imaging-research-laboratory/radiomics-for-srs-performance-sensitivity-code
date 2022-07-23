classdef ImageVolumeHandler < matlab.mixin.Copyable
    %ImageVolumeHandler
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Jun 4, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        oRASImageVolume ImageVolume {ValidationUtils.MustBeEmptyOrScalar} = MATLABImageVolume.empty
                
        oRegionsOfInterestRepresentativeFieldsOfView = []        
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
        vdSampleOrderRegionOfInterestNumbers (1,:) double {mustBeInteger, mustBePositive}
              
        sImageSource (1,1) string
        
        oSampleIds (1,:) SampleIds 
    end
    
    
    properties (Constant = true, GetAccess = public)
        dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg (1,1) double {mustBePositive, mustBeFinite} = 20
        
        % this ImageVolumeGeometry is the target geometry that all volumes
        % are transformed onto. This allows for all volumes to be aligned
        % in the same way, allowing for easier display, as well as
        % alignment of all feature calculations offset with respect to
        % patient anatomy. This target geometry aligns with the RAS (+x:
        % right, +y: anterior, +z: superier) coordinate system of 
        % BOLT, that is, matrix coordinate axes i = +x = right, j
        % = +y = anterior, k = +z = superior, where a matrix is indexed as
        % m3xMatrix(x,y,z)
        oTargetUnifiedImageVolumeGeometry (1,1) ImageVolumeGeometry = ImageVolumeGeometry.GetRASImageVolumeGeometry();
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImageVolumeHandler(oImageVolume, sImageSource, NameValueArgs)
            %obj = ImageVolumeHandler(oImageVolume, sImageSource, NameValueArgs)
            %
            % SYNTAX:
            %  obj = ImageVolumeHandler(oImageVolume, sImageSource, Name, Value)
            %
            %  Name-Value Pairs:
            %   'GroupIds': (Required) Can be either a single integer or a
            %               list of integers. If a single integer is given,
            %               all regions of interest will be given the same
            %               Group ID. If a list is given, it must be the
            %               same length as the number of ROIs for which
            %               features are being extracted. These  Group IDs
            %               will be assigned to their corresponding ROIs
            %   'SubGroupIds': (Optional) Must be a list of integers the
            %                  same length as the number of ROIs. They will
            %                  be assigned to their corresponding ROIs. If
            %                  no value is given, Sub-Group IDs will be
            %                  automatically assigned from 1 to n for each 
            %                  Group ID, where n is the number each Group
            %                  ID appears. 
            %  'UserDefinedSampleStrings': (Optional) This value can either
            %                              be a single string or an array
            %                              of strings. If a single string
            %                              is given, all ROIs will be given
            %                              the same sample string. If an
            %                              array is given, they will be
            %                              applied to each corresponding
            %                              ROI. If no value is given, the
            %                              sample string will be defaulted
            %                              to "X-Y", where X is the
            %                              sample's Group ID, and Y is the
            %                              Sub-Group ID
            % 'SampleOrder': (Optional) This is a vector of Region of
            %                    Interest numbers (see "RegionsOfInterest")
            %                    that specify in which order the regions of
            %                    interest will have their features
            %                    extracted. This also allows for ROIs
            %                    within the ImageVolume to be excluded from
            %                    having features extracted. **NOTE** This
            %                    vector also determines with
            %                    Group/Sub-Group IDs are linked up with
            %                    each sample. E.g if 'SampleOrder' =
            %                    [4,3,1] and 'GroupIds' = [6,7,8], then ROI
            %                    #4 in the ImageVolume object will be
            %                    assigned Group ID 6, ROI #3 will be ID 7,
            %                    and ROI #1 will be ID 8. ROI #2 will not
            %                    be processed.
            %                    If this value is not specified, the
            %                    default behaviour will be to extract
            %                    features for all ROIs within the
            %                    ImageVolume, in order.
            %
            %
            % DESCRIPTION:
            %  Constructor for ImageVolumeHandler
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterest(oImageVolume)}
                sImageSource (1,1) string {mustBeNonempty}
                NameValueArgs.SampleOrder (:,1) double {mustBeInteger, ValidationUtils.MustContainUniqueValues} = []
                NameValueArgs.GroupIds (1,:) {ValidationUtils.MustBeIntegerClass} = int8([])
                NameValueArgs.SubGroupIds (1,:) {ValidationUtils.MustBeIntegerClass} = int8([])
                NameValueArgs.UserDefinedSampleStrings (1,:) string = string([])
            end
                        
            % Get name value pair values
            viGroupIds = NameValueArgs.GroupIds;
            viSubGroupIds = NameValueArgs.SubGroupIds;
            vsUserDefinedSampleStrings = NameValueArgs.UserDefinedSampleStrings;
            vdSampleOrderRegionOfInterestNumbers = NameValueArgs.SampleOrder;
            
            % Validation and setting of empty values
            if isempty(viGroupIds)
                error(...
                    'ImageVolumeHandler:Constructor:GroupIdsMustBeDefinied',...
                    'The name-value pair ''GroupIds'' must be defined.');
            end
            
            oImageVolume = copy(oImageVolume);
            oImageVolume.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            
            ImageVolumeHandler.ValidateRASImageVolume(oImageVolume);
            ImageVolumeHandler.ValidateSampleOrderRegionOfInterestNumbers(vdSampleOrderRegionOfInterestNumbers, oImageVolume);
            
            if isempty(vdSampleOrderRegionOfInterestNumbers)
                dNumRois = oImageVolume.GetNumberOfRegionsOfInterest();
            else
                dNumRois = length(vdSampleOrderRegionOfInterestNumbers);
            end 
            
            if numel(viGroupIds) == 1
                viGroupIds = repmat(viGroupIds, dNumRois, 1);
            end   
            
            if isempty(viSubGroupIds)
                viUniqueGroupIds = unique(viGroupIds);
                
                vdCurrentSubGroupIdPerGroupId = ones(length(viUniqueGroupIds),1);
                viSubGroupIds = zeros(length(viGroupIds),1);
                
                for dGroupIdIndex=1:length(viGroupIds)
                    dUniqueGroupIdIndex = find(viUniqueGroupIds == viGroupIds(dGroupIdIndex));
                    
                    viSubGroupIds(dGroupIdIndex) = vdCurrentSubGroupIdPerGroupId(dUniqueGroupIdIndex);
                    vdCurrentSubGroupIdPerGroupId(dUniqueGroupIdIndex) = vdCurrentSubGroupIdPerGroupId(dUniqueGroupIdIndex) + 1;
                end
                
                viSubGroupIds = cast(viSubGroupIds, 'like', viGroupIds);
            end        
                        
            if isempty(vsUserDefinedSampleStrings)
                vsUserDefinedSampleStrings = strcat(...
                    strtrim(string(num2str(viGroupIds))),...
                    "-",...
                    strtrim(string(num2str(viSubGroupIds))));
            end
            
            % Set Properities
            
            obj.oRASImageVolume = oImageVolume;
            obj.vdSampleOrderRegionOfInterestNumbers = vdSampleOrderRegionOfInterestNumbers;
                        
            obj.sImageSource = sImageSource;
            
            obj.oSampleIds = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings);
            
            if length(obj.oSampleIds) ~= dNumRois
                error(...
                    'ImageVolumeHandler:Constructor:InvalidSampleIds',...
                    'The number of samples must match the number of ROIs to be used.');
            end
            
            if isa(oImageVolume.GetRegionsOfInterest(), 'LabelMapRegionsOfInterest')
                if isempty(vdSampleOrderRegionOfInterestNumbers)
                    vdSampleOrderRegionOfInterestNumbers = 1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
                end
                
                obj.oRegionsOfInterestRepresentativeFieldsOfView = LabelMapRegionsOfInterestFieldsOfView(oImageVolume, vdSampleOrderRegionOfInterestNumbers);
            elseif isa(oImageVolume.GetRegionsOfInterest(), 'ParametricRegionsOfInterest')
                obj.oRegionsOfInterestRepresentativeFieldsOfView = ParametricRegionsOfInterestFieldsOfView(oImageVolume);
            else
                error(...
                    'ImageVolumeHandler:Constructor:InvalidRegionsOfInterestType',...
                    'The regions of interest objects within oImageVolume must of type "LabelMapRegionsOfInterest" of "ParametricRegionsOfInterest".');
            end
        end
        
        function SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(obj, vdDisplayThreshold)
            obj.oRegionsOfInterestRepresentativeFieldsOfView.SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(vdDisplayThreshold);
        end
        
        function LoadVolumeData(obj)
            obj.oRASImageVolume.LoadVolumeData();
        end
        
        function oSampleIds = GetSampleIds(obj)
            oSampleIds = obj.oSampleIds;
        end
        
        function UnloadVolumeData(obj)
            obj.oRASImageVolume.UnloadVolumeData();
        end
        
        function MustBeValidExtractionIndex(obj, dExtractionIndex)
            arguments
                obj
                dExtractionIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if dExtractionIndex > obj.GetNumberOfRegionsOfInterest()
                error(...
                    'FeatureExtractionImageVolumeHandler:MustBeValidExtractionIndex:Invalid',...
                    'The extraction index must not be greater than the number of regions of interest within the handler.');
            end
        end
        
        function RenderRepresentativeImageOnAxesByExtractionIndex(obj, hAxes, dExtractionIndex, NameValueArgs)
            arguments
                obj (1,1) FeatureExtractionImageVolumeHandler
                hAxes (1,1) {ValidationUtils.MustBeAxes}
                dExtractionIndex (1,1) double {MustBeValidExtractionIndex(obj, dExtractionIndex)}
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar} = ImagingPlaneTypes.empty
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 0 0] % red
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 0.4 1] % blue  
            end
            
            oImagePlaneAxes = ImagingPlaneAxes(hAxes);
            
            chCurUnits = hAxes.Units;
            
            hAxes.Units = 'pixels';
            
            vdPosition = hAxes.Position;
            
            oFov = ImageVolumeFieldOfView2D([0 0], vdPosition(4), vdPosition(3));
            oImagePlaneAxes.SetFieldOfView(oFov);
            
            hAxes.Units = chCurUnits;
            
            varargin = namedargs2cell(NameValueArgs);
            
            obj.oRegionsOfInterestRepresentativeFieldsOfView.RenderFieldOfViewOnAxesByExtractionIndex(...
                oImagePlaneAxes, dExtractionIndex,...
                varargin{:});
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function oRASImageVolume = GetRASImageVolume(obj)
            oRASImageVolume = obj.oRASImageVolume;
        end
        
        function sImageSource = GetImageSource(obj)
            sImageSource = obj.sImageSource;
        end
        
        
        % >>>>>>>>>>>>>>>>>> REGIONS OF INTERESTS (ROIs) <<<<<<<<<<<<<<<<<<
        
        function dRoiNumber = GetRegionOfInterestNumberFromExtractionIndex(obj, dRegionOfInterestExtractionIndex)
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                dRoiNumber = dRegionOfInterestExtractionIndex;
            else
                dRoiNumber = obj.vdSampleOrderRegionOfInterestNumbers(dRegionOfInterestExtractionIndex);
            end
        end
        
        function vdRoiNumbers = GetRegionOfInterestNumbersInSampleOrder(obj)
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                vdRoiNumbers = transpose(1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest());
            else
                vdRoiNumbers = obj.vdSampleOrderRegionOfInterestNumbers;
            end
        end
        
        function oFieldOfView3D = GetRepresentativeFieldsOfViewForExtractionIndex(obj, dExtractionIndex)
            oFieldOfView3D = obj.oRegionsOfInterestRepresentativeFieldsOfView.GetFieldOfViewByExtractionIndex(dExtractionIndex);
        end
        
        function SetRepresentativeFieldsOfViewForExtractionIndex(obj, dExtractionIndex, oFieldOfView3D)
            obj.oRegionsOfInterestRepresentativeFieldsOfView.SetFieldOfViewByExtractionIndex(dExtractionIndex, oFieldOfView3D);
        end
               
        function dNumRegionsOfInterest = GetNumberOfRegionsOfInterest(obj)
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                dNumRegionsOfInterest = obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
            else
                dNumRegionsOfInterest = length(obj.vdSampleOrderRegionOfInterestNumbers);
            end
        end
        
        function vdSampleOrder = GetSampleOrder(obj)
            dTotalNumRois = obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
            
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                vdSampleOrder = 1:dTotalNumRois;
            else
                vdSampleOrder = 1:dTotalNumRois;
                vdSampleOrder = vdSampleOrder(obj.vdSampleOrderRegionOfInterestNumbers);
            end
        end
        
        function viGroupIds = GetRegionsOfInterestGroupIds(obj)
            viGroupIds = obj.viGroupIds;
        end
        
        function viSubGroupIds = GetRegionsOfInterestSubGroupIds(obj)
            viSubGroupIds = obj.viSubGroupIds;
        end
        
        function vsUserDefinedSampleStrings = GetRegionsOfInterestUserDefinedSampleStrings(obj)
            vsUserDefinedSampleStrings = obj.vsUserDefinedSampleStrings;
        end
        
        function sUserDefinedSampleString = GetUserDefinedSampleStringByExtractionIndex(obj, dExtractionIndex)
            sUserDefinedSampleString = obj.vsUserDefinedSampleStrings(dExtractionIndex);
        end
        
        function m3xImageData = GetFullImageData(obj)
            m3xImageData = obj.oRASImageVolume.GetImageData();
        end
    end
    
    
    methods (Access = public, Static = true)
         
        function oSampleIds = GetSampleIdsForAll(voImageVolumeHandlers)
            arguments
                voImageVolumeHandlers (1,:) ImageVolumeHandler
            end
            
            dNumHandlers = length(voImageVolumeHandlers);
            c1oSampleIdsPerHandler = cell(1, dNumHandlers);
            
            sMasterImageSource = voImageVolumeHandlers(1).sImageSource;
            
            for dHandlerIndex=1:dNumHandlers
                if sMasterImageSource ~= voImageVolumeHandlers(dHandlerIndex).sImageSource
                    error(...
                        'ImageVolumeHandler:GetSampleIdsForAll:Invalid',...
                        'All ImageVolumeHandler objects must have the same Image Source value to have their Sample IDs combined.');
                end
                
                c1oSampleIdsPerHandler{dHandlerIndex} = voImageVolumeHandlers(dHandlerIndex).GetSampleIds();
            end
            
            oSampleIds = vertcat(c1oSampleIdsPerHandler{:});
        end        
        
        function CreateCollageOfRepresentativeFieldsOfView(voImageVolumeHandlers, vdGridDimensions, NameValueArgs)
            arguments
                voImageVolumeHandlers (1,:) ImageVolumeHandler
                vdGridDimensions (1,2) double {mustBePositive, mustBeInteger}
                NameValueArgs.DimensionUnits (1,:) char = 'pixels' % one of 'pixels' | 'normalized' | 'inches' | 'centimeters' | 'points' | 'characters'
                NameValueArgs.TileDimensions (1,2) double {mustBePositive, mustBeFinite} = [200, 200] % px
                NameValueArgs.TilePadding (1,1) double {mustBeNonnegative, mustBeFinite} = 2 % px
                NameValueArgs.TileLabelFontSize (1,1) double {mustBePositive, mustBeFinite} = 10 % px
                NameValueArgs.ShowTileLabels (1,1) logical = true
                NameValueArgs.TileLabelSource (1,:) char {mustBeMember(NameValueArgs.TileLabelSource, {'Id','UserDefinedSampleString','Both'})} = 'Id'
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar} = ImagingPlaneTypes.empty
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 0 0] % red
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 0.8 1] % blue        
                NameValueArgs.ExtractionIndicesPerHandler (1,:) cell = {} % cell array of double vectors that contain the extraction indices for each handler
            end
            
            c1vdExtractionIndicesPerHandler = NameValueArgs.ExtractionIndicesPerHandler;
            
            dNumHandlers = length(voImageVolumeHandlers);
            
            if isempty(c1vdExtractionIndicesPerHandler)
                dNumRois = 0;
                
                c1vdExtractionIndicesPerHandler = cell(1,dNumHandlers);
                
                for dHandlerIndex=1:dNumHandlers
                    dNumRois = dNumRois + voImageVolumeHandlers(dHandlerIndex).GetNumberOfRegionsOfInterest();
                    c1vdExtractionIndicesPerHandler{dHandlerIndex} = 1:dNumRois;
                end
            else
                dNumRois = 0;
                
                for dHandlerIndex=1:dNumHandlers
                    dNumRois = dNumRois + length(c1vdExtractionIndicesPerHandler{dHandlerIndex});
                end
            end
            
            
            dNumGridRows = vdGridDimensions(1);
            dNumGridCols = vdGridDimensions(2);
            
            if dNumRois > dNumGridRows * dNumGridCols
                error(...
                    'FeatureExtractionImageVolumeHandler:CreateMontageOfRepresentativeFieldsOfView:InvalidGridSize',...
                    'The given grid size cannot fit the number of images provided.');
            end
            
            dTileHeight = NameValueArgs.TileDimensions(1);
            dTileWidth = NameValueArgs.TileDimensions(2);
            
            dPadding = NameValueArgs.TilePadding;
            
            dFigureWidth = dNumGridCols*(dTileWidth+dPadding) + dPadding;
            dFigureHeight = dNumGridRows*(dTileHeight+dPadding+NameValueArgs.ShowTileLabels*NameValueArgs.TileLabelFontSize) + dPadding;
            
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
            
            dNormalizedVerticalSpaceBetweenTiles = (NameValueArgs.ShowTileLabels*NameValueArgs.TileLabelFontSize + dPadding) / dFigureHeight;
           
            dNormalizedFontSize = NameValueArgs.TileLabelFontSize / dFigureHeight;
                        
            dRowIndex = 1;
            dColIndex = 1;
            
            dHandlerIndex = 1;
            dExtractionIndicesIndex = 1;
            oCurrentHandler = voImageVolumeHandlers(1);
            vdExtractionIndices = c1vdExtractionIndicesPerHandler{1};
            
            for dImageIndex=1:dNumRois
                % create sub-plot for image to be rendered in
                dNormalizedAxesBottomLeftX = dNormalizedHorizontalPadding + (dColIndex - 1) * (dNormalizedTileWidth + dNormalizedHorizontalPadding);
                dNormalizedAxesBottomLeftY = 1 - (dNormalizedVerticalPadding + dNormalizedTileHeight) - (dRowIndex - 1) * (dNormalizedTileHeight + dNormalizedVerticalSpaceBetweenTiles);
                
                hAxes = subplot(...
                    'Position', [...
                    dNormalizedAxesBottomLeftX,...
                    dNormalizedAxesBottomLeftY,...
                    dNormalizedTileWidth,...
                    dNormalizedTileHeight]);
                
                % call image volume to do the render
                oCurrentHandler.RenderRepresentativeImageOnAxesByExtractionIndex(...
                    hAxes,...
                    vdExtractionIndices(dExtractionIndicesIndex),...
                    'ForceImagingPlaneType', NameValueArgs.ForceImagingPlaneType,...
                    'ShowAllRegionsOfInterest', NameValueArgs.ShowAllRegionsOfInterest,...
                    'LineWidth', NameValueArgs.LineWidth,...
                    'RegionOfInterestColour', NameValueArgs.RegionOfInterestColour,...
                    'OtherRegionsOfInterestColour', NameValueArgs.OtherRegionsOfInterestColour);
                
                % change units to pixels
                hAxes.Units = 'pixels';
                
                % turn box on
                axis(hAxes, 'on');
                hAxes.Box = 'on';
                hAxes.XColor = [1 1 1];
                hAxes.YColor = [1 1 1];
                hAxes.LineWidth = 2.5;
                xticks(hAxes, []);
                yticks(hAxes, []);
                
                % render the image label
                if NameValueArgs.ShowTileLabels
                    if strcmp(NameValueArgs.TileLabelSource, 'Id')
                        iGroupId = oCurrentHandler.viGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                        iSubGroupId = oCurrentHandler.viSubGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                        
                        chLabel = [num2str(iGroupId), '-', num2str(iSubGroupId)];
                    elseif strcmp(NameValueArgs.TileLabelSource, 'UserDefinedSampleString')
                        chLabel = char(oCurrentHandler.vsUserDefinedSampleStrings(vdExtractionIndices(dExtractionIndicesIndex)));
                    else
                        iGroupId = oCurrentHandler.viGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                        iSubGroupId = oCurrentHandler.viSubGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                        
                        chSampleString = char(oCurrentHandler.vsUserDefinedSampleStrings(vdExtractionIndices(dExtractionIndicesIndex)));
                        
                        chLabel = [num2str(iGroupId), '-', num2str(iSubGroupId), ' (', chSampleString, ')'];
                    end
                    
                    vdAxesPosition = hAxes.Position;
                    dAxesWidth = vdAxesPosition(3);
                    
                    hText = text(...
                        hAxes,...
                        dAxesWidth/2, 0,...
                        chLabel,...
                        'Units', 'pixels',...
                        'Color', [1 1 1],...
                        'Margin', eps,...
                        'FontSize', NameValueArgs.TileLabelFontSize,...
                        'FontUnits', NameValueArgs.DimensionUnits,...
                        'HorizontalAlignment', 'center',...
                        'VerticalAlignment', 'middle');
                    
                    hText.FontUnits = 'pixels';
                    
                    dFontSizePixels = hText.FontSize;
                    
                    vdCurrentTextPosition = hText.Position;
                    vdCurrentTextPosition(2) = (-dFontSizePixels/2) + 1;
                    hText.Position = vdCurrentTextPosition;
                end
                

                % increment handler/extraction index
                if dExtractionIndicesIndex < length(vdExtractionIndices)
                    dExtractionIndicesIndex = dExtractionIndicesIndex + 1;
                elseif dImageIndex ~= dNumRois
                    dHandlerIndex = dHandlerIndex + 1;
                    oCurrentHandler = voImageVolumeHandlers(dHandlerIndex);
                    vdExtractionIndices = c1vdExtractionIndicesPerHandler{dHandlerIndex};
                    dExtractionIndicesIndex = 1;
                end                    
                
                % increment index in montage grid
                if dColIndex == dNumGridCols % jump to next row
                    dColIndex = 1;
                    dRowIndex = dRowIndex + 1;
                else
                    dColIndex = dColIndex + 1; % run along row left to right
                end
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            % local call
            cpObj.oRASImageVolume = copy(obj.oRASImageVolume);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = private, Static = true)
        
        function ValidateImageVolume(oImageVolume)
            if ~isscalar(oImageVolume) || ~isa(oImageVolume, 'ImageVolume')
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:InvalidType',...
                    'The Image Volume must be given as a scalar of type ImageVolume.');
            end
            
            if oImageVolume.GetNumberOfRegionsOfInterest() == 0
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:InvalidNumberOfRegionsOfInterest',...
                    'The Image Volume must have at least one region of interest.');
            end
        end
        
        function ValidateRASImageVolume(oRASImageVolume)
            vdMisalignmentAngles_deg = ImageVolumeGeometry.GetEulerAnglesAboutCartesianAxesBetweenGeometries(oRASImageVolume.GetImageVolumeGeometry(), FeatureExtractionImageVolumeHandler.oTargetUnifiedImageVolumeGeometry);
            
            if any(abs(vdMisalignmentAngles_deg) > FeatureExtractionImageVolumeHandler.dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg)
                error(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:HighlyObliqueImageVolume',...
                    ['The given image volume was acquired in an oblique geometry, deviating by more than ', num2str(ImageVolume.dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg), ' degrees, and therefore cannot be processed. Please interpolate the data into an non-oblique volume.']);
            elseif any(abs(vdMisalignmentAngles_deg) > ImageVolumeGeometry.GetPrecisionBound())
                warning(...
                    'FeatureExtractionImageVolumeHandler:ValidateRASImageVolume:MarginallyObliqueImageVolume',...
                    ['The given image volume was acquired with a slightly oblique geometry, deviating by at most ', num2str(max(abs(vdMisalignmentAngles_deg))), ' degrees from the desired acquisition geometry. This image volume can be processed, but care should be taken.']);
            end
        end
        
        function ValidateSampleOrderRegionOfInterestNumbers(vdSampleOrderRegionOfInterestNumbers, oImageVolume)
            if isempty(vdSampleOrderRegionOfInterestNumbers) && isa(vdSampleOrderRegionOfInterestNumbers, 'double')
                % we're good
            else
                if ~iscolumn(vdSampleOrderRegionOfInterestNumbers) || ~isa(vdSampleOrderRegionOfInterestNumbers, 'double')
                    error(...
                        'FeatureExtractionImageVolumeHandler:ValidateSampleOrderRegionOfInterestNumbers:InvalidType',...
                        'ValidateSampleOrderRegionOfInterestNumbers must be a column vector of type double.');
                end
                
                dNumRois = oImageVolume.GetNumberOfRegionsOfInterest();
                
                if ...
                        any(vdSampleOrderRegionOfInterestNumbers < 1) ||...
                        any(vdSampleOrderRegionOfInterestNumbers > dNumRois) ||...
                        length(vdSampleOrderRegionOfInterestNumbers) > dNumRois ||...
                        any(round(vdSampleOrderRegionOfInterestNumbers) ~= vdSampleOrderRegionOfInterestNumbers)
                    error(...
                        'FeatureExtractionImageVolumeHandler:ValidateSampleOrderRegionOfInterestNumbers:InvalidValue',...
                        'ValidateSampleOrderRegionOfInterestNumbers must only contain unique, integer values between 1 and the number of regions of interest within the image volume object.');
                end
            end
        end
    end
    
    
    methods (Access = {?Feature, ?FeatureExtractionImageVolumeHandler}, Static = true)
        
        function dNumTotalRois = GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = 0;
            
            for dImageIndex=1:length(voImageVolumeHandlers)
                dNumTotalRois = dNumTotalRois + voImageVolumeHandlers(dImageIndex).GetNumberOfRegionsOfInterest();
            end
        end
        
        function viGroupIds = GetGroupIdsForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                viGroupIds = [];
            else
                chMasterGroupIdClass = class(voImageVolumeHandlers(1).GetRegionsOfInterestGroupIds());
                viGroupIds = zeros(dNumTotalRois, 1, chMasterGroupIdClass);
                
                dInsertIndex = 1;
                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    viNextGroupIds = voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestGroupIds();
                    
                    if isa(viNextGroupIds, chMasterGroupIdClass)
                        dNumToInsert = length(viNextGroupIds);
                        
                        viGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = viNextGroupIds;
                        dInsertIndex = dInsertIndex + dNumToInsert;
                    else
                        error(...
                            'FeatureExtactionImageVolumeHandler:GetGroupIdsForImageVolumeHandlers:MismatchedClass',...
                            'All Group IDs across images and ROIs must be of the same class.');
                    end
                end
            end
        end
        
        function viSubGroupIds = GetSubGroupIdsForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                viSubGroupIds = [];
            else
                chMasterGroupSubIdClass = class(voImageVolumeHandlers(1).GetRegionsOfInterestSubGroupIds());
                viSubGroupIds = zeros(dNumTotalRois, 1, chMasterGroupSubIdClass);
                
                dInsertIndex = 1;
                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    viNextSubGroupIds = voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestSubGroupIds();
                    
                    if isa(viNextSubGroupIds, chMasterGroupSubIdClass)
                        dNumToInsert = length(viNextSubGroupIds);
                        
                        viSubGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = viNextSubGroupIds;
                        dInsertIndex = dInsertIndex + dNumToInsert;
                    else
                        error(...
                            'FeatureExtactionImageVolumeHandler:GetSubGroupIdsForImageVolumeHandlers:MismatchedClass',...
                            'All Sub-Group IDs across images and ROIs must be of the same class.');
                    end
                end
            end
        end
        
        function vsUserDefinedSampleStrings = GetUserDefinedSampleStringsForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                vsUserDefinedSampleStrings = [];
            else
                chMasterSampleStringClass = class(voImageVolumeHandlers(1).GetRegionsOfInterestUserDefinedSampleStrings());
                vsUserDefinedSampleStrings = strings(dNumTotalRois, 1);
                
                dInsertIndex = 1;
                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    vsNextSampleStrings = voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestUserDefinedSampleStrings();
                    
                    if isa(vsNextSampleStrings, chMasterSampleStringClass)
                        dNumToInsert = length(vsNextSampleStrings);
                        
                        vsUserDefinedSampleStrings(dInsertIndex : dInsertIndex + dNumToInsert - 1) = vsNextSampleStrings;
                        dInsertIndex = dInsertIndex + dNumToInsert;
                    else
                        error(...
                            'ImageVolume:GetUserDefinedSampleStringsForImagesAndROIs:InvalidDataType',...
                            'All User Defined Samples Strings across images and ROIs must be of the same class.');
                    end
                end
            end
        end
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