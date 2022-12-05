classdef FeatureExtractionParameters < handle
    %Image
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        dMinNumberOfVoxelsPerRoi
        
        dGLCMFirstBinEdge
        dGLCMBinSize
        dGLCMNumberOfBins   
        
        dGLCMLookupDistance
        bGLCMSymmetric
        bGLCMNormalize
        vdGLCMOffsetsToCompute
        bCombineAllGLCMOffsets
        
        dGLRLMFirstBinEdge
        dGLRLMBinSize
        dGLRLMNumberOfBins
        
        dGLRLMRunThreshold
        eGLRLMNumberOfColumnsOption
        vdGLRLMOffsetsToCompute
        bCombineAllGLRLMOffsets
        
        dEntropyAndUniformityNumberOfBins
        
        ePerimeterMethod
        eAreaMethod
        eSurfaceAreaMethod
        eVolumeMethod
        eShapePrinicipalComponentsPoints
        
        eMeshMaskInterpolationMethod
        eMeshMaskInterpolationVoxelSizeSource
        dMeshMaskInterpolationVoxelSizeMultiplier
    end
    
    properties (SetAccess = private, GetAccess = public)
        dMaxMemoryUsage_Gb = 0
    end
    
    properties (Constant = true, GetAccess = private)
        chParameterSheetName = 'Parameters'
        dHeaderColumnNumber = 1;
        dParameterLabelColumnNumber = 2;
        dParameterValueColumnNumber = 3;
        
        chGeneralHeader = 'General:'
        chMinNumberOfVoxelsLabel = 'Minimum Number of Voxels per ROI'
        
        chGLCMHeader = 'GLCM Features:'        
        chGLCMFirstBinEdgeLabel = 'First Bin Edge'
        chGLCMBinSizeLabel = 'Bin Size'
        chGLCMNumberOfBinsLabel = 'Number of Bins'        
        chGLCMLookupDistanceLabel = 'Look-up Distance'
        chGLCMSymmetricLabel = 'Symmetric GLCM'
        chGLCMNormalizeLabel = 'Normalize GLCM'
        chGLCMOffsetLabel = 'Offset'
        dGLCMNumberOfOffsets = 26
        chCombineAllGLCMOffsetsLabel = 'All Offsets'
        
        chGLRLMHeader = 'GLRLM Features:'
        chGLRLMFirstBinEdgeLabel = 'First Bin Edge'
        chGLRLMBinSizeLabel = 'Bin Size'
        chGLRLMNumberOfBinsLabel = 'Number of Bins'
        chGLRLMRunThresholdLabel = 'Run Threshold'
        chGLRLMNumberOfColumnsLabel = 'Number of Columns'
        chGLRLMOffsetLabel = 'Offset'
        dGLRLMNumberOfOffsets = 26
        chCombineAllGLRLMOffsetsLabel = 'All Offsets'        
        
        chFirstOrderFeaturesHeader = 'First-Order Features:'
        chEntropyNumberOfBinsLabel = 'Number of bins for entropy/uniformity'
        
        chShapeAndSizeFeaturesHeader = 'Shape & Size Features:'
        chPerimeterMethodLabel = 'Perimeter Method'
        chAreaMethodLabel = 'Area Method'
        chSurfaceAreaMethodLabel = 'Surface Area Method'
        chVolumeMethodLabel = 'Volume Method'
        chShapePrincipalComponentsPointsLabel = 'Shape Principal Components Points'
        
        chMeshMaskInterpolationMethodLabel = 'Fit Mesh Mask Interpolation Method*'
        chMeshMaskInterpolationVoxelSizeSourceLabel = 'Fit Mesh Mask Isotropic Voxel Size Source*'
        chMeshMaskInterpolationVoxelSizeMultiplierLabel = 'Fit Mesh Mask Isotropic Voxel Size Multiplier*'
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = FeatureExtractionParameters(chFeatureExtractionParametersXlsPath)
            %obj = NewClass(input1, input2)
            %
            % SYNTAX:
            %  obj = NewClass(input1, input2)
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %         long wrap it with tabs to align the second line, and
            %         then the third line will automatically be in line
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: Your name here
            % Created: MMM DD, YYYY
            
            c2xExcelData = readcell(...
                chFeatureExtractionParametersXlsPath,...
                'FileType', 'spreadsheet',...
                'Sheet', FeatureExtractionParameters.chParameterSheetName);
            
            vdGeneralHeaderRowBounds = [];
            vdGLCMHeaderRowBounds = [];
            vdGLRLMHeaderRowBounds = [];
            vdFirstOrderHeaderRowBounds = [];
            vdShapeAndSizeHeaderRowBounds = [];
            
            dRowIndex  = 1;
            
            bLastRowWasNan = false;
            
            while dRowIndex <= size(c2xExcelData,1)
                 xHeaderValue = c2xExcelData{dRowIndex, FeatureExtractionParameters.dHeaderColumnNumber};
                 
                 if ~isa(xHeaderValue, 'missing')
                     dStartIndex = dRowIndex;
                     bLastRowWasNan = false;
                     dRowIndex = dRowIndex + 1;
                     
                     while dRowIndex <= size(c2xExcelData,1)
                         if isa(c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterLabelColumnNumber}, 'missing')
                             break;
                         else
                             dRowIndex = dRowIndex + 1;
                         end
                     end
                     
                     switch xHeaderValue
                         case FeatureExtractionParameters.chGeneralHeader
                             vdGeneralHeaderRowBounds = [dStartIndex dRowIndex-1];
                         case FeatureExtractionParameters.chGLCMHeader
                             vdGLCMHeaderRowBounds = [dStartIndex dRowIndex-1];
                         case FeatureExtractionParameters.chGLRLMHeader
                             vdGLRLMHeaderRowBounds = [dStartIndex dRowIndex-1];
                         case FeatureExtractionParameters.chFirstOrderFeaturesHeader
                             vdFirstOrderHeaderRowBounds = [dStartIndex dRowIndex-1];
                         case FeatureExtractionParameters.chShapeAndSizeFeaturesHeader
                             vdShapeAndSizeHeaderRowBounds = [dStartIndex dRowIndex-1];
                         otherwise
                             error(...
                                 'FeatureExtractionParameters:Constructor:InvalidHeader',...
                                 [c2xExcelData{dRowIndex, FeatureExtractionParameters.dHeaderColumnNumber}, ' is an invalid header.']);
                             
                     end
                 else
                     if bLastRowWasNan
                         % two nans is a row
                         break;
                     else
                         bLastRowWasNan = true;
                         dRowIndex = dRowIndex + 1;
                     end
                 end
            end
            
            % read in parameters from each heading
            if ~isempty(vdGeneralHeaderRowBounds)
                for dRowIndex = vdGeneralHeaderRowBounds(1):vdGeneralHeaderRowBounds(2)
                    xParameterValue = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterValueColumnNumber};
                    chParameterLabel = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterLabelColumnNumber};
                    
                    switch chParameterLabel
                        case FeatureExtractionParameters.chMinNumberOfVoxelsLabel
                            xParameterValue = double(xParameterValue);
                            
                            mustBeInteger(xParameterValue);
                            mustBeFinite(xParameterValue);
                            mustBeNonnegative(xParameterValue);
                            
                            obj.dMinNumberOfVoxelsPerRoi = xParameterValue;
                        otherwise
                            error(...
                                'FeatureExtractionParameters:Constructor:InvalidGeneralParameter',...
                                [chParameterLabel, ' is an invalid General parameter label.']);
                    end
                end
            end
            
            if ~isempty(vdGLCMHeaderRowBounds)
                vdGLCMOffsets = [];
                
                for dRowIndex = vdGLCMHeaderRowBounds(1) : vdGLCMHeaderRowBounds(2)
                    xParameterValue = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterValueColumnNumber};
                    chParameterLabel = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterLabelColumnNumber};
                    
                    switch chParameterLabel
                        case FeatureExtractionParameters.chGLCMFirstBinEdgeLabel
                            obj.dGLCMFirstBinEdge = xParameterValue;
                        case FeatureExtractionParameters.chGLCMBinSizeLabel
                            obj.dGLCMBinSize = xParameterValue;
                        case FeatureExtractionParameters.chGLCMNumberOfBinsLabel
                            obj.dGLCMNumberOfBins = xParameterValue;
                        case FeatureExtractionParameters.chGLCMLookupDistanceLabel
                            obj.dGLCMLookupDistance = xParameterValue;
                        case FeatureExtractionParameters.chGLCMSymmetricLabel
                            obj.bGLCMSymmetric = FeatureExtractionParameters.ConvertYNToBoolean(xParameterValue);
                        case FeatureExtractionParameters.chGLCMNormalizeLabel
                            obj.bGLCMNormalize = FeatureExtractionParameters.ConvertYNToBoolean(xParameterValue);
                        case FeatureExtractionParameters.chCombineAllGLCMOffsetsLabel
                            obj.bCombineAllGLCMOffsets = FeatureExtractionParameters.ConvertYNToBoolean(xParameterValue);
                       otherwise
                            vdIndices = strfind(chParameterLabel, FeatureExtractionParameters.chGLCMOffsetLabel);
                            dLength = length(FeatureExtractionParameters.chGLCMOffsetLabel);
                            
                            if isscalar(vdIndices)
                                dOffsetNumber = str2double(chParameterLabel(vdIndices(1)+dLength : end));
                                
                                if dOffsetNumber >= 1 && dOffsetNumber <= FeatureExtractionParameters.dGLCMNumberOfOffsets && floor(dOffsetNumber) == dOffsetNumber
                                    if FeatureExtractionParameters.ConvertYNToBoolean(xParameterValue)
                                        vdGLCMOffsets = [vdGLCMOffsets, dOffsetNumber]; % not pre-allocated, but I'm sure we'll survive 26 allocations at worst
                                    end
                                else
                                    error(...
                                        'FeatureExtractionParameters:Constructor:InvalidGLCMOffsetNumber',...
                                        ['GLCM offset numbers must be integers between 1 and ', num2str(FeatureExtractionParameters.dGLCMNumberOfOffsets)]);
                                end
                            else
                                error(...
                                    'FeatureExtractionParameters:Constructor:InvalidGLCMParameter',...
                                    [chParameterLabel, ' is an invalid GLCM parameter label.']);
                            end
                    end
                end
                
                if obj.bGLCMSymmetric
                    vdGLCMOffsets = FeatureExtractionParameters.ValidateAndRemoveOffsetsForSymmetricGLCMs(vdGLCMOffsets);
                end
                
                obj.vdGLCMOffsetsToCompute = vdGLCMOffsets;
            end
            
            if ~isempty(vdGLRLMHeaderRowBounds)
                vdGLRLMOffsets = [];
                
                for dRowIndex = vdGLRLMHeaderRowBounds(1) : vdGLRLMHeaderRowBounds(2)
                    xParameterValue = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterValueColumnNumber};
                    chParameterLabel = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterLabelColumnNumber};
                    
                    switch chParameterLabel
                        
                        case FeatureExtractionParameters.chGLRLMFirstBinEdgeLabel
                            obj.dGLRLMFirstBinEdge = xParameterValue;
                        case FeatureExtractionParameters.chGLRLMBinSizeLabel
                            obj.dGLRLMBinSize = xParameterValue;
                        case FeatureExtractionParameters.chGLRLMNumberOfBinsLabel
                            obj.dGLRLMNumberOfBins = xParameterValue;
                        case FeatureExtractionParameters.chGLRLMRunThresholdLabel
                            obj.dGLRLMRunThreshold = xParameterValue;
                        case FeatureExtractionParameters.chGLRLMNumberOfColumnsLabel
                            obj.eGLRLMNumberOfColumnsOption = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'GLRLMNumberOfColumnsOptions');                            
                        case FeatureExtractionParameters.chCombineAllGLRLMOffsetsLabel
                            obj.bCombineAllGLRLMOffsets = FeatureExtractionParameters.ConvertYNToBoolean(xParameterValue);
                        otherwise
                            vdIndices = strfind(chParameterLabel, FeatureExtractionParameters.chGLRLMOffsetLabel);
                            dLength = length(FeatureExtractionParameters.chGLRLMOffsetLabel);
                            
                            if isscalar(vdIndices)
                                dOffsetNumber = str2double(chParameterLabel(vdIndices(1)+dLength : end));
                                
                                if dOffsetNumber >= 1 && dOffsetNumber <= FeatureExtractionParameters.dGLRLMNumberOfOffsets && floor(dOffsetNumber) == dOffsetNumber
                                    if FeatureExtractionParameters.ConvertYNToBoolean(xParameterValue)
                                        vdGLRLMOffsets = [vdGLRLMOffsets, dOffsetNumber]; % not pre-allocated, but I'm sure we'll survive 26 allocations at worst
                                    end
                                else
                                    error(...
                                        'FeatureExtractionParameters:Constructor:InvalidGLRLMOffsetNumber',...
                                        ['GLRLM offset numbers must be integers between 1 and ', num2str(FeatureExtractionParameters.dGLRLMNumberOfOffsets)]);
                                end
                            else
                                error(...
                                    'FeatureExtractionParameters:Constructor:InvalidGLRLMParameter',...
                                    [chParameterLabel, ' is an invalid GLRLM parameter label.']);
                            end
                    end
                    
                end
                
                obj.vdGLRLMOffsetsToCompute = vdGLRLMOffsets;
            end
            
            if ~isempty(vdFirstOrderHeaderRowBounds)
                for dRowIndex = vdFirstOrderHeaderRowBounds(1) : vdFirstOrderHeaderRowBounds(2)
                    xParameterValue = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterValueColumnNumber};
                    chParameterLabel = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterLabelColumnNumber};
                    
                    switch chParameterLabel
                        case FeatureExtractionParameters.chEntropyNumberOfBinsLabel
                            obj.dEntropyAndUniformityNumberOfBins = xParameterValue;
                        otherwise
                            error(...
                                'FeatureExtractionParameters:Constructor:InvalidFirstOrderFeatureParameter',...
                                [chParameterLabel, ' is an invalid First-Order Feature parameter label.']);
                    end
                end
            end
            
            if ~isempty(vdShapeAndSizeHeaderRowBounds)
                for dRowIndex = vdShapeAndSizeHeaderRowBounds(1) : vdShapeAndSizeHeaderRowBounds(2)
                    xParameterValue = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterValueColumnNumber};
                    chParameterLabel = c2xExcelData{dRowIndex, FeatureExtractionParameters.dParameterLabelColumnNumber};
                    
                    switch chParameterLabel
                        case FeatureExtractionParameters.chPerimeterMethodLabel
                            obj.ePerimeterMethod = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'PerimeterMethodOptions');
                        case FeatureExtractionParameters.chAreaMethodLabel
                            obj.eAreaMethod = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'AreaMethodOptions');
                        case FeatureExtractionParameters.chSurfaceAreaMethodLabel
                            obj.eSurfaceAreaMethod = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'SurfaceAreaMethodOptions');
                        case FeatureExtractionParameters.chVolumeMethodLabel
                            obj.eVolumeMethod = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'VolumeMethodOptions');
                        case FeatureExtractionParameters.chShapePrincipalComponentsPointsLabel
                            obj.eShapePrinicipalComponentsPoints = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'ShapePrincipalComponentsPointsOptions');
                        case FeatureExtractionParameters.chMeshMaskInterpolationMethodLabel
                            obj.eMeshMaskInterpolationMethod = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'MeshMaskInterpolationOptions');
                        case FeatureExtractionParameters.chMeshMaskInterpolationVoxelSizeSourceLabel
                            obj.eMeshMaskInterpolationVoxelSizeSource = FeatureExtractionParameters.FindMatchForEnumeration(xParameterValue, 'MeshMaskInterpolationVoxelSizeSourceOptions');
                        case FeatureExtractionParameters.chMeshMaskInterpolationVoxelSizeMultiplierLabel
                            xParameterValue = double(xParameterValue);
                            
                            ValidationUtils.MustBeScalar(xParameterValue);
                            mustBeFinite(xParameterValue);
                            mustBePositive(xParameterValue);
                            
                            obj.dMeshMaskInterpolationVoxelSizeMultiplier = xParameterValue;
                        otherwise
                            error(...
                                'FeatureExtractionParameters:Constructor:InvalidShapeAndSizeParameter',...
                                [chParameterLabel, ' is an invalid Shape & Size parameter label.']);
                    end
                end
            end
        end
        
        function obj = SetMaxMemoryUsage_Gb(obj, dMaxMemoryUsage_Gb)
            obj.dMaxMemoryUsage_Gb = dMaxMemoryUsage_Gb;
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % >> General Getters:
        
        function dMinNumVoxels = GetMinimumNumberOfVoxelsPerMask(obj)
            dMinNumVoxels = obj.dMinNumberOfVoxelsPerRoi;
        end
        
        % >> First-Order Getters:
        
        function dEntropyAndUniformityNumberOfBins = GetEntropyAndUniformityNumberOfBins(obj)
            dEntropyAndUniformityNumberOfBins = obj.dEntropyAndUniformityNumberOfBins;
        end
        
        % >> GLCM Getters:
        
        function dFirstBinEdge = GetGLCMFirstBinEdge(obj)
            dFirstBinEdge = obj.dGLCMFirstBinEdge;
        end
        
        function dBinSize = GetGLCMBinSize(obj)
            dBinSize = obj.dGLCMBinSize;
        end
        
        function dNumberOfBins = GetGLCMNumberOfBins(obj)
            dNumberOfBins = obj.dGLCMNumberOfBins;
        end
        
        function dGLCMLookupDistance = GetGLCMLookupDistance(obj)
            dGLCMLookupDistance = obj.dGLCMLookupDistance;
        end
        
        function bGLCMSymmetric = GetGLCMSymmetric(obj)
            bGLCMSymmetric = obj.bGLCMSymmetric;
        end
        
        function bGLCMNormalize = GetGLCMNormalize(obj)
            bGLCMNormalize = obj.bGLCMNormalize;
        end
        
        function bCombineAllGLCMOffsets = GetCombineAllGLCMOffsets(obj)
            bCombineAllGLCMOffsets = obj.bCombineAllGLCMOffsets;
        end
        
        function vdGLCMOffsetNumbers = GetGLCMOffsetNumbers(obj)
            vdGLCMOffsetNumbers = obj.vdGLCMOffsetsToCompute;
            
            if obj.bCombineAllGLCMOffsets
                vdGLCMOffsetNumbers = [vdGLCMOffsetNumbers, Inf];
            end
        end
        
        function m2dGLCMOffsets = GetGLCMOffsetVectors(obj)
            m2dGLCMOffsets = obj.GetGLCMOffsetVectorsFromOffsetNumbers(obj.vdGLCMOffsetsToCompute);
        end
        
        % >> GLRLM Getters:
        
        function dGLRLMRunThreshold = GetGLRLMRunThreshold(obj)
            dGLRLMRunThreshold = obj.dGLRLMRunThreshold;
        end
        
        function dFirstBinEdge = GetGLRLMFirstBinEdge(obj)
            dFirstBinEdge = obj.dGLRLMFirstBinEdge;
        end
        
        function dBinSize = GetGLRLMBinSize(obj)
            dBinSize = obj.dGLRLMBinSize;
        end
        
        function dNumberOfBins = GetGLRLMNumberOfBins(obj)
            dNumberOfBins = obj.dGLRLMNumberOfBins;
        end
        
        function bCombineAllGLRLMOffsets = GetCombineAllGLRLMOffsets(obj)
            bCombineAllGLRLMOffsets = obj.bCombineAllGLRLMOffsets;
        end
        
        function vdGLRLMOffsetNumbers = GetGLRLMOffsetNumbers(obj)
            vdGLRLMOffsetNumbers = obj.vdGLRLMOffsetsToCompute;
            
            if obj.bCombineAllGLRLMOffsets
                vdGLRLMOffsetNumbers = [vdGLRLMOffsetNumbers, Inf];
            end
        end
        
        function m2dGLRLMOffsets = GetGLRLMOffsetVectors(obj)
            m2dGLRLMOffsets = obj.GetGLRLMOffsetVectorsFromOffsetNumbers(obj.vdGLRLMOffsetsToCompute);
        end
        
        function dNumColumns = GetGLRLMNumberOfColumns(obj, oFeatureExtractionImageVolumeHandler)
            dNumColumns = obj.eGLRLMNumberOfColumnsOption.GetNumberOfColumns(oFeatureExtractionImageVolumeHandler);
        end
        
        function bTrimNumColumns = GetGLRLMTrimNumberOfColumns(obj)
            bTrimNumColumns = obj.eGLRLMNumberOfColumnsOption.GetTrimNumberOfColumns();
        end
        
        % >> Shape & Size Getters
        
        function ePerimeterMethod = GetPerimeterMethod(obj)
            ePerimeterMethod = obj.ePerimeterMethod;
        end
                
        function eAreaMethod = GetAreaMethod(obj)
            eAreaMethod = obj.eAreaMethod;
        end
        
        function eSurfaceAreaMethod = GetSurfaceAreaMethod(obj)
            eSurfaceAreaMethod = obj.eSurfaceAreaMethod;
        end
        
        function eVolumeMethod = GetVolumeMethod(obj)
            eVolumeMethod = obj.eVolumeMethod;
        end
        
        function eShapePrinicipalComponentsPoints = GetShapePrinicipalComponentsPoints(obj)
            eShapePrinicipalComponentsPoints = obj.eShapePrinicipalComponentsPoints;
        end
        
        function eMeshMaskInterpolationMethod = GetMeshMaskInterpolationMethod(obj)
            eMeshMaskInterpolationMethod = obj.eMeshMaskInterpolationMethod;
        end
        
        function eMeshMaskInterpolationVoxelSizeSource = GetMeshMaskInterpolationVoxelSizeSource(obj)
            eMeshMaskInterpolationVoxelSizeSource = obj.eMeshMaskInterpolationVoxelSizeSource;
        end
                
        function dMeshMaskInterpolationVoxelSizeMultiplier = GetMeshMaskInterpolationVoxelSizeMultiplier(obj)
            dMeshMaskInterpolationVoxelSizeMultiplier = obj.dMeshMaskInterpolationVoxelSizeMultiplier;
        end
        
        % >> Misc. Getters:
        
        function dMaxMemoryUsage_Gb = GetMaxMemoryUsage_Gb(obj)
            dMaxMemoryUsage_Gb = obj.dMaxMemoryUsage_Gb;
        end
    end
    
    
    methods (Access = public, Static = true)
       
        function m2dOffsetVectors = GetGLCMOffsetVectorsFromOffsetNumbers(vdOffsetNumbers)
            m2dOffsetVectors = [...
                1 0 0;...
                1 1 0;...
                0 1 0;...
                -1 1 0;...
                -1 0 0;...
                -1 -1 0;...
                0 -1 0;...
                1 -1 0;...
                0 0 1;...
                1 0 1;...
                1 1 1;...
                0 1 1;...
                -1 1 1;...
                1 0 -1;...
                1 1 -1;...
                0 1 -1;...
                -1 1 -1;...
                0 0 -1;...
                -1 0 -1;...
                -1 -1 -1;...
                0 -1 -1;...
                1 -1 -1;...
                -1 0 1;...
                -1 -1 1;...
                0 -1 1;...
                1 -1 1];
            
            m2dOffsetVectors = m2dOffsetVectors(vdOffsetNumbers,:);
        end
        
        function vdOppositeOffsetNumbers = GetOppositeGLCMOffsetNumbers(vdOffsetNumbers)
            m2dOffsetVectors = FeatureExtractionParameters.GetGLCMOffsetVectorsFromOffsetNumbers(1:26);
            
            dNumOffsetNumbers = length(vdOffsetNumbers);
            
            vdOppositeOffsetNumbers = zeros(size(vdOffsetNumbers)); 
            
            for dOffsetIndex=1:dNumOffsetNumbers
                if vdOffsetNumbers(dOffsetIndex) == Inf % combination of all offsets
                    vdOppositeOffsetNumbers(dOffsetIndex) = Inf;
                else
                    vdSearchOffset = -m2dOffsetVectors(vdOffsetNumbers(dOffsetIndex),:);
                    
                    bMatchFound = false;
                    
                    for dSearchIndex=1:size(m2dOffsetVectors,1)
                        if all(vdSearchOffset == m2dOffsetVectors(dSearchIndex,:))
                            vdOppositeOffsetNumbers(dOffsetIndex) = dSearchIndex;
                            bMatchFound = true;
                            break;
                        end
                    end
                    
                    if ~bMatchFound
                        error(...
                            'GetOppositeGLCMOffsetNumbers:InvalidOffsetNumber',...
                            'No opposite offset found, therefore an invalid offset number was provided.');
                    end
                end
            end
        end
        
        function m2dOffsetVectors = GetGLRLMOffsetVectorsFromOffsetNumbers(vdOffsetNumbers)
            m2dOffsetVectors = [...
                1 0 0;...
                1 1 0;...
                0 1 0;...
                -1 1 0;...
                -1 0 0;...
                -1 -1 0;...
                0 -1 0;...
                1 -1 0;...
                0 0 1;...
                1 0 1;...
                1 1 1;...
                0 1 1;...
                -1 1 1;...
                1 0 -1;...
                1 1 -1;...
                0 1 -1;...
                -1 1 -1;...
                0 0 -1;...
                -1 0 -1;...
                -1 -1 -1;...
                0 -1 -1;...
                1 -1 -1;...
                -1 0 1;...
                -1 -1 1;...
                0 -1 1;...
                1 -1 1];
            
            m2dOffsetVectors = m2dOffsetVectors(vdOffsetNumbers,:);
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
    
    methods (Access = private, Static = true)
           
        function eMatch = FindMatchForEnumeration(xParameterValue, chEnumClassName)
            
            xParameterValue = char(xParameterValue);
            
            veEnumOptions = enumeration(chEnumClassName);
            
            eMatch = [];
            
            for dOptionIndex=1:length(veEnumOptions)
                if strcmp(veEnumOptions(dOptionIndex).GetParameterFileString(), xParameterValue)
                    eMatch = veEnumOptions(dOptionIndex);
                    break;
                end
            end
            
            if isempty(eMatch)
                error(...
                    'FeatureExtactionParameters:FindMatchForEnumeration:NoMatch',...
                    ['No match found for ', chEnumClassName, '. See .xlsx for details.']);
            end
        end
        
        function bBoolean = ConvertYNToBoolean(chYN)
            if strcmp(chYN, 'Y')
                bBoolean = true;
            elseif strcmp(chYN, 'N')
                bBoolean = false;
            else
                error(...
                    'FeatureExtractionParameters:ConvertYNToBoolean:InvalidValue',...
                    'Boolean values must be specified as "Y" or "N".');
            end
        end
        
        function vdTrimmedGLCMOffsetNumbers = ValidateAndRemoveOffsetsForSymmetricGLCMs(vdGLCMOffsetNumbers)
            vdOppositeOffsetNumbers = FeatureExtractionParameters.GetOppositeGLCMOffsetNumbers(vdGLCMOffsetNumbers);
                        
            dNumOffsetNumbers = length(vdGLCMOffsetNumbers);
            vbKeepOffset = true(dNumOffsetNumbers,1);
            
            for dOffsetIndex=1:dNumOffsetNumbers
                if vbKeepOffset(dOffsetIndex)                  
                    % find it's match and set its vbKeepOffset to false
                                       
                    dNumMatches = 0;
                    
                    for dSearchIndex=dOffsetIndex+1:dNumOffsetNumbers
                        if vdOppositeOffsetNumbers(dSearchIndex) == vdGLCMOffsetNumbers(dOffsetIndex)
                            vbKeepOffset(dSearchIndex) = false;
                            dNumMatches = dNumMatches + 1;
                        end
                    end
                    
                    if dNumMatches == 0
                        error(...
                            'FeatureExtractionParameters:ValidateAndRemoveOffsetsForSymmetricGLCMs:NoOppositeVector',...
                            ['Found no opposite offset vector match for offset ', num2str(vdGLCMOffsetNumbers(dOffsetIndex)), '. For symmetric GLCM calculations, each offset and it''s opposite must be set to "Y".'])
                    elseif dNumMatches > 1 
                        error(...
                            'FeatureExtractionParameters:ValidateAndRemoveOffsetsForSymmetricGLCMs:NoOppositeVector',...
                            'Multiple opposite offset vectors found for a given offset. This is a fatal error and should not occur. Please check that each offset number only appears in the parameters file once.');                  
                    end
                end
            end
            
            vdTrimmedGLCMOffsetNumbers = vdGLCMOffsetNumbers(vbKeepOffset);
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

