classdef (Abstract) LabelMapRegionsOfInterest < RegionsOfInterest
    %LabelMapRegionsOfInterest
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
           
    properties (Constant = true, GetAccess = private)
        chGetSurfaceAreaCrossPlane2DInterpolationMethod = 'linear'
        chGetSurfaceAreaThroughPlane1DLevelSetInterpolationMethod = 'pchip'
    end
    
    properties (Constant = true, GetAccess = protected)
        chLabelMapsMatFileVarName = 'm3uiLabelMaps'
    end    
    
    properties (SetAccess = protected, GetAccess = public)
        m3uiLabelMaps = []
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
           
    
%     methods (Access = public, Abstract = true)
%         
%         m3bMask = GetCurrentRegionOfInterestMask(obj)
%         
%         Load(obj)
%         
%         Unload(obj)
%     end
    
    methods (Access = public)
        
        function obj = LabelMapRegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest, NameValueArgs)
            %LabelMapRegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest, m2dRegionOfInterestDefaultRenderColours_rgb)
            %
            % SYNTAX:
            %  LabelMapRegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest, m2dRegionOfInterestDefaultRenderColours_rgb)
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
                 
            arguments
                oOnDiskImageVolumeGeometry (1,1) ImageVolumeGeometry
                dNumberOfRegionsOfInterest (1,1) double {mustBePositive, mustBeInteger, mustBeLessThanOrEqual(dNumberOfRegionsOfInterest, 64)}
                NameValueArgs.LabelMaps (:,:,:) {ValidationUtils.MustBeUnsignedInteger}
            end
            
            % super-class constructor
            obj@RegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest);
            
            % set properities (if required)
            if isfield(NameValueArgs, 'LabelMaps')
                LabelMapRegionsOfInterest.MustBeValidLabelMaps(NameValueArgs.LabelMaps, oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest);
                obj.m3uiLabelMaps = NameValueArgs.LabelMaps;
            end
        end
        
        function oRenderer = GetRenderer(obj)
            if ~obj.IsRAS
                objRas = copy(obj);
                objRas.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            else
                objRas = obj;
            end
            
            oRenderer = LabelMapRegionsOfInterestRenderer(obj, objRas);
        end
        
        function PerformRigidTransform(obj, m2dAffineTransformMatrix)
            arguments
                obj (1,1) LabelMapRegionsOfInterest
                m2dAffineTransformMatrix (4,4) double
                % %                 vdRotations_deg (1,3) double {mustBeFinite} = [0 0 0]
                % %                 vdTranslations_mm (1,3) double {mustBeFinite} = [0 0 0]
            end
            
            oTransform = RigidTransform(obj.GetImageVolumeGeometry(), m2dAffineTransformMatrix);
            obj.AddTransform(oTransform);
        end
        
        function PerformMorphologicalTransform(obj, vdRegionOfInterestNumbers, chTransformFunction, varargin)
            arguments
                obj
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumbers)}
                chTransformFunction (1,:) char
            end
            arguments (Repeating)
                varargin
            end
               
            oTransform = LabelMapMorphologicalTransform(...
                obj,...
                vdRegionOfInterestNumbers,...
                chTransformFunction, varargin{:});
            
            obj.AddTransform(oTransform);
        end
        
        function PerformBooleanOperation(obj, vdRegionOfInterestNumbers, fnBooleanOperation, oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput)
            %PerformBooleanOperation(obj, vdRegionOfInterestNumbers, fnBooleanOperation, oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput)
            %
            % SYNTAX:
            %  obj.PerformBooleanOperation(vdRegionOfInterestNumbers, fnBooleanOperation, oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput)
            %
            % DESCRIPTION:
            %  Applies a provided element-wise boolean operation to regions
            %  of interest within a LabelMapRegionsOfInterest object. A
            %  second RegionsOfInterest object provides the second input
            %  for the boolean operation. The produced labelmaps replace
            %  the labelmaps within the first LabelMapRegionsOfInterest
            %  object for the region of interest numbers provided.
            %
            % INPUT ARGUMENTS:
            %  obj:
            %   A LabelMapRegionsOfInterest object
            %  vdRegionOfInterestNumbers:
            %   A row vector of ROI numbers within obj for which to perform
            %   fnBooleanOperation on
            %  fnBooleanOperation:
            %   A MATLAB function handle to a function that takes two
            %   logical matrices of the same dimensionality as input and 
            %   produces a single logical matrix as output that is the same 
            %   dimensionality as the input
            %  oRegionsOfInterestSecondInput:
            %   A RegionsOfInterest object that provide the second input
            %   for fnBooleanOperation. It must have the identical
            %   ImageVolumeGeometry as obj.
            %  vdRegionOfInterestNumbersSecondInput:
            %   A row vector of ROI numbers from
            %   oRegionsOfInterestSecondInput. This row vector must be the
            %   same dimensionality as vdRegionsOfInterestNumbers.
            %   fnBooleanOperation will be performed using obj's ROI #
            %   vdRegionOfInterestNumbers(i) as the first input, and
            %   oRegionsOfInterestSecondInput's ROI #
            %   vdRegionOfInterestNumbersSecondInput(i) as the second
            %   input.
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                obj
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumbers)}
                fnBooleanOperation (1,1) function_handle
                oRegionsOfInterestSecondInput (1,1) RegionsOfInterest {GeometricalImagingObject.MustHaveSameImageVolumeGeometry(oRegionsOfInterestSecondInput, obj)}
                vdRegionOfInterestNumbersSecondInput double {MustBeValidRegionOfInterestNumbers(oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput), ValidationUtils.MustBeSameSize(vdRegionOfInterestNumbersSecondInput, vdRegionOfInterestNumbers)}
            end
            
            % create transform
            oTransform = LabelMapBooleanOperationTransform(...
                obj,...
                vdRegionOfInterestNumbers, fnBooleanOperation,...
                oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput);
            
            % add transform to obj
            obj.AddTransform(oTransform);
            
            %
        end
       
        
        % >>>>>>>>>>>>>>>>>>>> MEASUREMENT GETTERS <<<<<<<<<<<<<<<<<<<<<<<<
        
        function dVolume_mm3 = GetVolumeMeasurementByRegionOfInterestNumber(obj, dRegionOfInterestNumber, chVolumeMethod)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                chVolumeMethod (1,:) char {LabelMapRegionsOfInterest.MustBeValidVolumeMethod(chVolumeMethod)}
            end
            
            m3bMask = obj.GetMaskByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            switch chVolumeMethod
                case 'voxel'
                    dVoxelVolume_mm3 = prod(obj.GetImageVolumeGeometry().GetVoxelDimensions_mm());
                    dNumVoxels = sum(m3bMask(:));
                    
                    dVolume_mm3 = dVoxelVolume_mm3 * dNumVoxels;
                case 'mesh'
                    error(...
                        'LabelMapRegionsOfInterest:GetVolumeMeasurementByRegionOfInterestNumber:UnderConstruction',...
                        'Computing volume using the option ''mesh'' is currently unsupported.');
            end
        end
        
        function varargout = GetGeometricalMeasurementsByRegionOfInterestNumber(obj, dRegionOfInterestNumber, chVolumeInterpretation, chPerimeterOrSurfaceAreaMethod, chAreaOrVolumeMethod, chPcaPointsMethod, varargin)
            % varargout = GetGeometricalMeasurementsByRegionOfInterestNumber(obj, dRegionOfInterestNumber, chVolumeInterpretation, chPerimeterOrSurfaceAreaMethod, chAreaOrVolumeMethod, chPcaPointsMethod, varargin)
            %
            % SYNTAX:
            %  [dPerimeter_mm, dArea_mm2, dMaxDiameter_mm, vdRadialLengths_mm, dRecist_mm, dPcaLambdaMinor, dPcaLambdaMajor] = obj.GetGeometricalMeasurementsByRegionOfInterestNumber(dRegionOfInterestNumber, '2D', chPerimeterMethod, chAreaMethod, chPcaPointsMethod)
            %  [dSurfaceArea_mm2, dVolume_mm3, dMaxDiameter_mm, vdRadialLengths_mm, dSagittalRecist_mm, dCoronalRecist_mm, dAxialRecist_mm, dPcaLambdaLeast, dPcaLambdaMinor, dPcaLambdaMajor] = obj.GetGeometricalMeasurementsByRegionOfInterestNumber(dRegionOfInterestNumber, '3D', chSurfaceAreaMethod, chVolumeMethod, chPcaPointsMethod, 'none')
            %  [dSurfaceArea_mm2, dVolume_mm3, dMaxDiameter_mm, vdRadialLengths_mm, dSagittalRecist_mm, dCoronalRecist_mm, dAxialRecist_mm, dPcaLambdaLeast, dPcaLambdaMinor, dPcaLambdaMajor] = obj.GetGeometricalMeasurementsByRegionOfInterestNumber(dRegionOfInterestNumber, '3D', chSurfaceAreaMethod, chVolumeMethod, chPcaPointsMethod, chInterpMethod, chVoxelDimensionSource, dVoxelDimensionMultiplier)
            %  [dSurfaceArea_mm2, dVolume_mm3, dMaxDiameter_mm, vdRadialLengths_mm, dSagittalRecist_mm, dCoronalRecist_mm, dAxialRecist_mm, dPcaLambdaLeast, dPcaLambdaMinor, dPcaLambdaMajor] = obj.GetGeometricalMeasurementsByRegionOfInterestNumber(dRegionOfInterestNumber, '3D', chSurfaceAreaMethod, chVolumeMethod, chPcaPointsMethod, 'levelsets', chVoxelDimensionSource, dVoxelDimensionMultiplier, dThroughPlaneDimension)
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  obj: LabelMapRegionsOfInterest object
            %  dRegionOfInterestNumber: A scalar double giving the region
            %                           of interest number to find the
            %                           values for
            %  chVolumeInterpretation: Either '2D' or '3D', depending if
            %                          the  image volume is to be
            %                          interpreted as a 2D (by pixels) or
            %                          3D (by voxels). If '2D' is chosen,
            %                          the region of interest must have
            %                          voxels in a volume where one of the
            %                          dimensions is 1 (e.g. within a
            %                          slice)
            % chPerimeterMethod: Either 'pixel' or 'polygon'. If 'pixel',
            %                    the perimeter is found by tracing the
            %                    boundaries between true and false pixels.
            %                    If 'polygon', a polygon that best fits the
            %                    mask is found, and it's perimeter is used.
            % chAreaMethod: Either 'pixel' or 'poylgon'. If 'pixel', area is
            %               found using number of true pixels multiplied by
            %               the area of a pixel. If 'polygon', area is
            %               found by finding a polygon that best fits the
            %               mask and finding it's area.
            % chSurfaceAreaMethod: Either 'voxel' or 'mesh'. If 'voxel',
            %                      surface area is found by summing the
            %                      areas of voxel faces that are between
            %                      true and false values. If 'mesh', a
            %                      triangular mesh is found using an
            %                      isotropic voxel mask. The surface area
            %                      is then the sum of the area of the
            %                      triangular faces.
            % chVolumeMethod: Either 'voxel' or 'mesh'. If 'voxel', the
            %                 volume is the number of true voxels
            %                 multiplied by the volume of one voxel. If
            %                 'mesh', a triangular mesh is found using an
            %                 isotropic voxel mask. The volume of this mesh
            %                 is then found.
            % chPcaPointsMethod: Either 'all' or 'exterior'.
            %                    If 'all', the centres of all voxels
            %                    are used to find the principal components.
            %                    If 'exterior', the vertices from a fit
            %                    polygon/mesh to the mask are used.
            %
            % OUTPUTS ARGUMENTS:
            %  dPerimeter_mm: For '2D'. The perimeter of the ROI. If the
            %                 ROI consists of multiple "islands", the
            %                 perimeter is the sum of the perimeter from 
            %                 each of these "islands".
            %  dArea_mm2: For '2D'. The area of the ROI. If the
            %             ROI consists of multiple "islands", the
            %             area is the sum of the area from each of these
            %             "islands".
            %  dSurfaceArea_mm2: For '3D'. The surface area of the ROI. If
            %                    the ROI consists of multiple "islands",
            %                    the surface area is the sum of the surface
            %                    areas of each of these "islands".
            %  dVolume_mm3: For '3D'. The volume of the ROI. If the ROI
            %               consists of multiple "islands", the volume is
            %               the sum of the volume from each of these
            %               "islands".
            %  dMaxDiameter_mm: For '2D' or '3D'. Finds the maximum
            %                   distance between any pair of points from
            %                   the polygon (2D) or mesh (3D). This
            %                   diameter can cross false voxels. If there
            %                   are multiple "islands" in the ROIs, the
            %                   maximum diameter can extend in between
            %                   them.
            %  vdRadialLengths_mm: For '2D' or '3D'. A column vector of
            %                      distances from the centre of mass of the
            %                      ROI to each vertex of the polygon (2D)
            %                      or mesh (3D).
            %  dRecist_mm: For '2D'. The maximum distance between any pair
            %              of points of the ROI polygon, but it cannot
            %              cross any false voxels (e.g. intersect with any
            %              edges of the polygon). This follows the RECSIST
            %              v1.1 protocol.
            %  dSagittalRecist_mm: For '3D'. RECIST values (see dRecist_mm)
            %                      are found for each sagittal slice, and
            %                      the maximum value is returned.
            %  dCoronalRecist_mm: For '3D'. RECIST values (see dRecist_mm)
            %                     are found for each coronal slice, and
            %                     the maximum value is returned.
            %  dAxialRecist_mm: For '3D'. RECIST values (see dRecist_mm)
            %                   are found for each axial slice, and
            %                   the maximum value is returned.
            %  dPcaLambdaLeast: For '3D'. This is 3rd largest eigenvalue
            %                   found from the covariance matrix.
            %  dPcaLambdaMinor: For '2D' or '3D'. This is the 2nd largest
            %                   eigenvalue found from the covariance
            %                   matrix.
            %  dPcaLambdaMajor: For '2D' or '3D'. This is largest
            %                   eigenvalue found from the covariance
            %                   matrix.
            
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                chVolumeInterpretation (1,2) char {mustBeMember(chVolumeInterpretation, {'2D','3D'})}
                chPerimeterOrSurfaceAreaMethod (1,:) char {LabelMapRegionsOfInterest.MustBeValidPerimeterOfSurfaceAreaMethod(chPerimeterOrSurfaceAreaMethod, chVolumeInterpretation)}
                chAreaOrVolumeMethod (1,:) char {LabelMapRegionsOfInterest.MustBeValidAreaOrVolumeMethod(chAreaOrVolumeMethod, chVolumeInterpretation)}
                chPcaPointsMethod (1,:) char {mustBeMember(chPcaPointsMethod, {'all','exterior'})}
            end
            arguments (Repeating)
                varargin
            end
            
            [m3bMask, vdRowBounds, vdColBounds, vdSliceBounds] = obj.GetZeroPaddedMinimallyBoundedMaskByRegionOfInterestNumber(dRegionOfInterestNumber);
            oMaskImageVolumeGeometry = obj.GetImageVolumeGeometry().GetSelectionImageVolumeGeometry(vdRowBounds, vdColBounds, vdSliceBounds);
            vdMinimalMaskDims = size(m3bMask);
            vdRegionOfInterestDims = vdMinimalMaskDims - 2; % remove padding
            
            switch chVolumeInterpretation
                case '2D'
                    % validate varargin
                    ValidationUtils.MustBeEmpty(varargin);
                    
                    % validate that ROI is 2D
                    if all(vdRegionOfInterestDims ~= 1) % since minimal mask is padded, if a dimension is 3, it is a single dimension
                        error(...
                            'LabelMapRegionsOfInterest:GetGeometricalMeasurementsByRegionOfInterestNumber:Invalid2DImageVolume',...
                            'The region of interest does not have singleton dimension, and so cannot be interpreted as a 2D image.');                        
                    end
                    
                    % get planar dimension
                    dPlanarDimension = obj.Get2DPlanarDimension(vdRegionOfInterestDims);
                    vdVoxelDimensions_mm = obj.GetVoxelDimensions_mm();
                    
                    switch dPlanarDimension
                        case 1
                            m3bMask = squeeze(m3bMask(2,:,:));
                            vdVoxelDimensions_mm = vdVoxelDimensions_mm([2,3]);
                        case 2
                            m3bMask = squeeze(m3bMask(:,2,:));
                            vdVoxelDimensions_mm = vdVoxelDimensions_mm([1,3]);
                        case 3
                            m3bMask = m3bMask(:,:,2);
                            vdVoxelDimensions_mm = vdVoxelDimensions_mm([1,2]);
                    end
                    
                    [c1m2dPolyCoords_mm, c1oPolyshapes_mm, dNumTotalPoints] = LabelMapRegionsOfInterest.GetPolygonsForMask(m3bMask, vdVoxelDimensions_mm);
                    dNumPolygons = length(c1oPolyshapes_mm);
                    
                    % PERIMETER:
                    switch chPerimeterOrSurfaceAreaMethod
                        case 'pixel'
                            % get boundaries
                            c1m2dVoxelOutlineCoordinates = GetVoxelOutlineCoordinatesForSlice_mex(m3bMask);
                            
                            % tally up the total number of row and col edges
                            dNumAcrossRowEdges = 0;
                            dNumAcrossColEdges = 0;
                            
                            dNumOutlines = length(c1m2dVoxelOutlineCoordinates); % ROI could be fragmented
                            
                            for dOutlineIndex=1:dNumOutlines
                                m2dVoxelOutlineCoordinates = c1m2dVoxelOutlineCoordinates{dOutlineIndex};
                                
                                vdLastCoord = m2dVoxelOutlineCoordinates(1,:);
                                
                                for dCoordIndex=2:size(m2dVoxelOutlineCoordinates,1)
                                    vdCurrentCoord = m2dVoxelOutlineCoordinates(dCoordIndex);
                                    
                                    vdDiff = vdLastCoord - vdCurrentCoord;
                                    
                                    if vdDiff(1) == 0
                                        dNumAcrossColEdges = dNumAcrossColEdges + 1;
                                    else
                                        dNumAcrossRowEdges = dNumAcrossRowEdges + 1;
                                    end
                                    
                                    vdLastCoord = vdCurrentCoord;
                                end
                            end
                            
                            % multiple num of each edge type by dimension in mm and then
                            % sum to get perimeter
                            dPerimeter_mm = ...
                                dNumAcrossRowEdges*vdVoxelDimensions_mm(1) +...
                                dNumAcrossColEdges*vdVoxelDimensions_mm(2);
                            
                        case 'polygon'
                            dPerimeter_mm = 0;
                            
                            % loop over poylgons;
                            for dPolygonIndex=1:dNumPolygons
                                dPerimeter_mm = dPerimeter_mm + perimeter(c1oPolyshapes_mm{dPolygonIndex});
                            end
                    end
                    
                    % AREA:
                    switch chAreaOrVolumeMethod
                        case 'pixel'
                            dPixelArea_mm2 = prod(vdVoxelDimensions_mm);
                            dNumPixels = sum(m3bMask(:));
                            
                            dArea_mm2 = dPixelArea_mm2 * dNumPixels;
                        case 'polygon'
                            dArea_mm2 = 0;
                            
                            % loop over poylgons;
                            for dPolygonIndex=1:dNumPolygons
                                dArea_mm2 = dArea_mm2 + area(c1oPolyshapes_mm{dPolygonIndex});
                            end
                    end
                    
                    % MAX DIAMETER:
                    % - gather all points
                    m2dVertices_mm = zeros(dNumTotalPoints,2);
                    
                    dInsertIndex = 1;
                    
                    for dPolygonIndex=1:dNumPolygons
                        dNumPoints = size(c1m2dPolyCoords_mm{dPolygonIndex},1);
                        
                        m2dVertices_mm(dInsertIndex + (1:dNumPoints) - 1, :) = c1m2dPolyCoords_mm{dPolygonIndex};
                        dInsertIndex = dInsertIndex + dNumPoints;
                    end
                                                
                    % RADIAL LENGTHS:
                    % - find centre of mass
                    vdCentreOfMass = GetCentreOfMassForMask_mex(m3bMask);
                    vdCentreOfMass_mm = vdCentreOfMass(1:2) .* vdVoxelDimensions_mm;
                    
                    % - radial lengths calc done below (2D and 3D the same)
                    
                    
                    % RECIST:
                    dRecist_mm = 0;
                    
                    % look for RECIST per polygon (RECIST not valid between
                    % polygons)
                    for dPolygonIndex=1:dNumPolygons
                        dRecist_mm = max(dRecist_mm, GetRecistForPolygon_mex(c1m2dPolyCoords_mm{dPolygonIndex}));
                    end
                    
                    % PRINCIPAL COMPONENT ANALYSIS:
                    switch chPcaPointsMethod
                        case 'all'
                            m2dPcaPoints_mm = GetVoxelIndicesForMask_mex(m3bMask);
                            m2dPcaPoints_mm = m2dPcaPoints_mm(:,1:2); % trim last column
                            m2dPcaPoints_mm = m2dPcaPoints_mm .* vdVoxelDimensions_mm;
                            
                            m2dPcaPoints_mm = m2dPcaPoints_mm - vdCentreOfMass_mm; % centre around centre of mass
                            m2dPcaPoints_mm = m2dPcaPoints_mm ./ sqrt(size(m2dPcaPoints_mm,1)); % divide by sqrt of num. of points                            
                        case 'exterior'
                            m2dPcaPoints_mm = m2dVertices_mm;
                            
                            m2dPcaCentreOfMass = mean(m2dPcaPoints_mm, 1);
                            
                            m2dPcaPoints_mm = m2dPcaPoints_mm - m2dPcaCentreOfMass;
                            m2dPcaPoints_mm = m2dPcaPoints_mm ./ sqrt(size(m2dPcaPoints_mm,1));
                    end       
                    
                    
                    
                case '3D'
                    % validate varargin
                    dVararginLength = length(varargin);
                    
                    if dVararginLength == 1
                        chInterpMethod = char(varargin{1});
                        
                        mustBeMember(chInterpMethod, {'none'});
                    elseif dVararginLength == 3 || dVararginLength == 4
                        chInterpMethod = char(varargin{1});
                        chVoxelDimensionSource = char(varargin{2});
                        dVoxelDimensionMultiplier = double(varargin{3});
                        
                        mustBeMember(chInterpMethod, {'interpolate3D','levelsets'});
                        mustBeMember(chVoxelDimensionSource, {'min','max'});
                        
                        mustBePositive(dVoxelDimensionMultiplier);
                        ValidationUtils.MustBeScalar(dVoxelDimensionMultiplier);
                        
                        if dVararginLength == 4
                            if strcmp(chInterpMethod, 'levelsets')
                                dThroughPlaneDimension = double(varargin{4});
                                
                                ValidationUtils.MustBeScalar(dThroughPlaneDimension);
                                mustBeMember(dThroughPlaneDimension, [1 2 3]);
                            else
                                error(...
                                    'LabelMapRegionsOfInterest:GetGeometricalMeasurementsByRegionOfInterestNumber:InvalidThroughPlaneDimensions',...
                                    'See constructor for details. Through plane dimension can only be specified when ''levelsets'' is used.');
                            end
                        else
                            dThroughPlaneDimension = [];
                        end
                    else
                        error(...
                            'LabelMapRegionsOfInterest:GetGeometricalMeasurementsByRegionOfInterestNumber:InvalidParams',...
                            'See constructor for details.');
                    end
                    
                    % calculate mesh
                    
                    vdVoxelDimensions_mm = oMaskImageVolumeGeometry.GetVoxelDimensions_mm();
                    
                    switch chInterpMethod
                        case 'none'
                            m3bMeshMask = m3bMask;
                            vdMeshMaskVoxelDimensions_mm = oMaskImageVolumeGeometry.GetVoxelDimensions_mm();
                            
                        otherwise
                            switch chVoxelDimensionSource
                                case 'min'
                                    dMeshMaskIsotropicVoxelSize_mm = min(vdVoxelDimensions_mm);
                                case 'max'
                                    dMeshMaskIsotropicVoxelSize_mm = max(vdVoxelDimensions_mm);
                            end                           
                            
                            dMeshMaskIsotropicVoxelSize_mm = dMeshMaskIsotropicVoxelSize_mm * dVoxelDimensionMultiplier;
                            
                            oTargetImageVolumeGeometry = oMaskImageVolumeGeometry.GetMatchedImageVolumeGeometryWithIsotropicVoxels(dMeshMaskIsotropicVoxelSize_mm);
                            
                            % want to ensure there is a zero padding for mesh creation:
                            vdVolumeDimensions = oTargetImageVolumeGeometry.GetVolumeDimensions();
                            oTargetImageVolumeGeometry = oTargetImageVolumeGeometry.GetSelectionImageVolumeGeometry(...
                                [0 vdVolumeDimensions(1)+1],...
                                [0 vdVolumeDimensions(2)+1],...
                                [0 vdVolumeDimensions(3)+1]);
                            
                            switch chInterpMethod
                                case 'interpolate3D'
                                    c1xMeshMaskInterpolateParams = {'linear'}; % 3D linear interpolation
                                case 'levelsets'
                                    if isempty(dThroughPlaneDimension)
                                        dThroughPlaneDimension = oMaskImageVolumeGeometry.GetThroughPlaneDimensionForMaskLevelSetInterpolation();
                                    end
                                    
                                    c1xMeshMaskInterpolateParams = {'linear', 'pchip', dThroughPlaneDimension};
                            end
                            
                            m3bMeshMask = oMaskImageVolumeGeometry.InterpolateMaskMatrixOntoTargetImageVolumeGeometry(...
                                m3bMask, oTargetImageVolumeGeometry,...
                                chInterpMethod,...
                                c1xMeshMaskInterpolateParams{:});
                            
                            vdMeshMaskVoxelDimensions_mm = oTargetImageVolumeGeometry.GetVoxelDimensions_mm();
                    
                    end
                    
                    [m2dFaces, m2dVertices_mm] = isosurface(m3bMeshMask, 0.5);
                    m2dVertices_mm(:,[1 2 3]) = m2dVertices_mm(:,[2 1 3]);
                        
                    m2dVertices_mm(:,1) = m2dVertices_mm(:,1) .* vdMeshMaskVoxelDimensions_mm(1);
                    m2dVertices_mm(:,2) = m2dVertices_mm(:,2) .* vdMeshMaskVoxelDimensions_mm(2);
                    m2dVertices_mm(:,3) = m2dVertices_mm(:,3) .* vdMeshMaskVoxelDimensions_mm(3);                    
                    
                    % SURFACE AREA:
                    switch chPerimeterOrSurfaceAreaMethod
                        case 'voxel'
                            error(...
                                'LabelMapRegionsOfInterest:GetGeometricalMeasurementsByRegionOfInterestNumber:UnderConstruction',...
                                'Computing surface area using the option ''voxel'' is currently unsupported.');
                        case 'mesh'
                            vdSideLengths_mm = cross(...
                                m2dVertices_mm(m2dFaces(:, 2), :) - m2dVertices_mm(m2dFaces(:, 1), :),...
                                m2dVertices_mm(m2dFaces(:, 3), :) - m2dVertices_mm(m2dFaces(:, 1), :),...
                                2);
                            dSurfaceArea_mm2 = 1/2 * sum(sqrt(sum(vdSideLengths_mm.^2, 2)));
                    end
                    
                    % VOLUME:
                    switch chAreaOrVolumeMethod
                        case 'voxel'
                            dVoxelArea_mm3 = prod(vdVoxelDimensions_mm);
                            dNumVoxels = sum(m3bMask(:));
                            
                            dVolume_mm3 = dVoxelArea_mm3 * dNumVoxels;
                        case 'mesh'
                            error(...
                                'LabelMapRegionsOfInterest:GetGeometricalMeasurementsByRegionOfInterestNumber:UnderConstruction',...
                                'Computing volume using the option ''mesh'' is currently unsupported.');
                    end
                    
                    % MAX DIAMETER:
                    % - have m2dVertices_mm already, calc is done below (2D
                    % and 3D the same
                    
                    % RADIAL LENGTHS:
                    % - find centre of mass
                    vdCentreOfMass = GetCentreOfMassForMask_mex(m3bMask);
                    vdCentreOfMass_mm = vdCentreOfMass .* vdVoxelDimensions_mm;
                    
                    % - radial lengths calc done below (2D and 3D the same)
                    
                    % RECIST (SAG, COR, AND AX):
                                        
                    % - Sagittal RECIST:
                    dSagittalRecist_mm = 0;
                    vdSliceVoxelDimensions_mm = vdVoxelDimensions_mm([2,3]);
                    
                    for dRowIndex=2:vdMinimalMaskDims(1)-1 % don't need to do first and last slices (mask padded w/ zeros)
                        m2bSlice = squeeze(m3bMask(dRowIndex,:,:));
                        
                        dSagittalRecist_mm = max(dSagittalRecist_mm, LabelMapRegionsOfInterest.GetRecistForMask(m2bSlice, vdSliceVoxelDimensions_mm));
                    end
                    
                    % - Coronal RECIST:
                    dCoronalRecist_mm = 0;
                    vdSliceVoxelDimensions_mm = vdVoxelDimensions_mm([1,3]);
                    
                    for dRowIndex=2:vdMinimalMaskDims(2)-1 % don't need to do first and last slices (mask padded w/ zeros)
                        m2bSlice = squeeze(m3bMask(:,dRowIndex,:));
                        
                        dCoronalRecist_mm = max(dCoronalRecist_mm, LabelMapRegionsOfInterest.GetRecistForMask(m2bSlice, vdSliceVoxelDimensions_mm));
                    end
                    
                    % - Axial RECIST:
                    dAxialRecist_mm = 0;
                    vdSliceVoxelDimensions_mm = vdVoxelDimensions_mm([1,2]);
                    
                    for dRowIndex=2:vdMinimalMaskDims(3)-1 % don't need to do first and last slices (mask padded w/ zeros)
                        m2bSlice = m3bMask(:,:,dRowIndex);
                        
                        dAxialRecist_mm = max(dAxialRecist_mm, LabelMapRegionsOfInterest.GetRecistForMask(m2bSlice, vdSliceVoxelDimensions_mm));
                    end
                                        
                    % PRINCIPAL COMPONENT ANALYSIS:
                    switch chPcaPointsMethod
                        case 'all'
                            m2dPcaPoints_mm = GetVoxelIndicesForMask_mex(m3bMask);
                            m2dPcaPoints_mm = m2dPcaPoints_mm .* vdVoxelDimensions_mm;
                            
                            m2dPcaPoints_mm = m2dPcaPoints_mm - vdCentreOfMass_mm; % centre around centre of mass
                            m2dPcaPoints_mm = m2dPcaPoints_mm ./ sqrt(size(m2dPcaPoints_mm,1)); % divide by sqrt of num. of points                            
                        case 'exterior'
                            m2dPcaPoints_mm = m2dVertices_mm;
                            
                            m2dPcaCentreOfMass = mean(m2dPcaPoints_mm, 1);
                            
                            m2dPcaPoints_mm = m2dPcaPoints_mm - m2dPcaCentreOfMass;
                            m2dPcaPoints_mm = m2dPcaPoints_mm ./ sqrt(size(m2dPcaPoints_mm,1));
                    end 
            end
            
            
            
            % Max diameter:            
            dMaxDiameter_mm = FindMaxDistanceBetweenCoordinates_mex(m2dVertices_mm);
                                    
            % Radial lengths:
            vdRadialLengths_mm = vecnorm(m2dVertices_mm - vdCentreOfMass_mm,2,2); % norm across rows
                        
            % Principal Component Analysis
            vdEigenValues = size(m2dPcaPoints_mm,1)*eig( cov(m2dPcaPoints_mm,1) ); % matlab normalizes the covariance matrix by the number of points, PyRadiomics does not. Multiple by number of points to reverse this normalization.
            
            if any(~isreal(vdEigenValues)) % want to catch complex values
                error(...
                    'LabelMapRegionsOfInterest:GetGeometricalMeasurementsByRegionOfInterestNumber:InvalidEigenvalues',...
                    'Principal Component Analysis found complex valued eigenvalues. Not too sure what to do about that, but we definitely don''t want complex values in our feature extraction.');
            end
            
            vdEigenValues = sort(vdEigenValues, 'descend');
            
            dPcaLambdaMajor = vdEigenValues(1);
            dPcaLambdaMinor = vdEigenValues(2);
            
            if strcmp(chVolumeInterpretation, '3D')
                dPcaLambdaLeast = vdEigenValues(3);
            end
            
            % set outputs
            switch chVolumeInterpretation
                case '2D'
                    varargout = {...
                        dPerimeter_mm,...
                        dArea_mm2,...
                        dMaxDiameter_mm,...
                        vdRadialLengths_mm,...
                        dRecist_mm,...
                        dPcaLambdaMinor,...
                        dPcaLambdaMajor};
                case '3D'
                    varargout = {...
                        dSurfaceArea_mm2,...
                        dVolume_mm3,...
                        dMaxDiameter_mm,...
                        vdRadialLengths_mm,...
                        dSagittalRecist_mm,...
                        dCoronalRecist_mm,...
                        dAxialRecist_mm,...
                        dPcaLambdaLeast,...
                        dPcaLambdaMinor,...
                        dPcaLambdaMajor};
                otherwise
                    varargout = {};
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function vdCentreVoxelIndices = GetCentreOfRegionVoxelIndicesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            vdCentreVoxelIndices = [mean(vdRowBounds), mean(vdColumnBounds), mean(vdSliceBounds)];
        end
        
        function InterpolateOntoTargetGeometry(obj, oTargetImageVolumeGeometry, chInterpolationMethod, varargin)%  chCrossPlane2DInterpolationMethod, chThroughPlane1DLevelSetInterpolationMethod, varargin)
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'interpolate3D')
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'interpolate3D', chInterp3DMethod)
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'levelsets')
            % obj.InterpolateOntoTargetGeometry(oTargetImageVolumeGeometry, 'levelsets', Name, Value)
            %
            % Name, Value:
            % 'InPlaneInterp2DMethod'
            % 'ThroughPlaneInterp1DMethod'
            % 'ThroughPlaneDimension'
            
            arguments
                obj
                oTargetImageVolumeGeometry (1,1) ImageVolumeGeometry
                chInterpolationMethod (1,:) char                
            end
            arguments (Repeating)
                varargin
            end
            
            oTransform = ImagingObjectMaskSpatialTransform(...
                obj, oTargetImageVolumeGeometry,...
                chInterpolationMethod,...
                varargin{:});
            
            obj.AddTransform(oTransform);
        end
        
        function InterpolateToIsotropicVoxelResolution(obj, dIsotropicVoxelDimension_mm, chInterpolationMethod, varargin)
            arguments
                obj
                dIsotropicVoxelDimension_mm (1,1) double {mustBePositive, mustBeFinite}
                chInterpolationMethod (1,:) char                
            end
            arguments (Repeating)
                varargin
            end
            
            oTargetImageVolumeGeometry = obj.GetImageVolumeGeometry().GetMatchedImageVolumeGeometryWithIsotropicVoxels(dIsotropicVoxelDimension_mm);
            
            obj.InterpolateOntoTargetGeometry(...
                oTargetImageVolumeGeometry,...
                chInterpolationMethod,...
                varargin{:});
        end       
        
        function InterpolateToNewVoxelResolution(obj, vdNewVoxelDimensions_mm, chInterpolationMethod, varargin)
            arguments
                obj
                vdNewVoxelDimensions_mm (1,3) double {mustBePositive, mustBeFinite}
                chInterpolationMethod (1,:) char                
            end
            arguments (Repeating)
                varargin
            end
            
            oTargetImageVolumeGeometry = obj.GetImageVolumeGeometry().GetMatchedImageVolumeGeometryWithCustomVoxelDimensions(vdNewVoxelDimensions_mm);
            
            obj.InterpolateOntoTargetGeometry(...
                oTargetImageVolumeGeometry,...
                chInterpolationMethod,...
                varargin{:});
        end
        
        function Crop(obj, vdRowBounds, vdColBounds, vdSliceBounds)
            arguments
                obj LabelMapRegionsOfInterest
                vdRowBounds (1,:) double {MustBeValidCropBounds(obj, vdRowBounds, 1)}
                vdColBounds (1,:) double {MustBeValidCropBounds(obj, vdColBounds, 2)}
                vdSliceBounds (1,:) double {MustBeValidCropBounds(obj, vdSliceBounds, 3)}
            end
            
            oTransform = ImagingObjectCropTransform(obj.GetImageVolumeGeometry(), vdRowBounds, vdColBounds, vdSliceBounds);
            
            obj.AddTransform(oTransform);
        end
        
        function [m3bMask, vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMinimallyBoundedMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            obj.ForceApplyAllTransforms();
            
            [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            if isempty(vdRowBounds) % no true values
                m3bMask = logical.empty;
            else
                switch class(obj.m3uiLabelMaps)
                    case 'uint8'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint8_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                    case 'uint16'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint16_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                    case 'uint32'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint32_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                    case 'uint64'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint64_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                end
            end
        end
        
        function vdSliceIndices = GetCentreSliceIndicesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            
            obj.ForceApplyAllTransforms();
            
            [vdRowBounds, vdColBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            if isempty(vdRowBounds) % no true values
                vdSliceIndices = round(obj.GetVolumeDimensions() ./ 2);
            else
                % take average to find centre
                vdSliceIndices = round([...
                    mean(vdRowBounds),...
                    mean(vdColBounds),...
                    mean(vdSliceBounds)]);
            end
        end
        
        function [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMinimalBoundsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            obj.ForceApplyAllTransforms();
            
            switch class(obj.m3uiLabelMaps)
                case 'uint8'
                    [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMaskBoundsFromBitLabelMap_uint8_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber);
                case 'uint16'
                    [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMaskBoundsFromBitLabelMap_uint16_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber);
                case 'uint32'
                    [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMaskBoundsFromBitLabelMap_uint32_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber);
                case 'uint64'
                    [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMaskBoundsFromBitLabelMap_uint64_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber);
            end
        end
        
        function [m2dFaces, m2dVertices_mm] = Get3DMeshByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            obj.ForceApplyAllTransforms();
            
            [m3bMask, vdRowBounds, vdColBounds, vdSliceBounds] = obj.GetZeroPaddedMinimallyBoundedMaskByRegionOfInterestNumber(dRegionOfInterestNumber);
                   
            if isempty(m3bMask) % no true values
                m2dFaces = double.empty(0,3);
                m2dVertices_mm = double.empty(0,3);
            else
                [m2dFaces, m2dVertices_mm] = isosurface(m3bMask, 0.5); % 0.5 iso-surface (halfway between 0 and 1 of the mask)
                
                m2dVertices_mm(:,1) = m2dVertices_mm(:,1) + vdColBounds(1) - 1; % vdRowBounds and vdColBounds switched since vertices come out as (x,y,z) == (col,row,slice)
                m2dVertices_mm(:,2) = m2dVertices_mm(:,2) + vdRowBounds(1) - 1;
                m2dVertices_mm(:,3) = m2dVertices_mm(:,3) + vdSliceBounds(1) - 1;
                
                [m2dVertices_mm(:,1), m2dVertices_mm(:,2), m2dVertices_mm(:,3)] =...
                    obj.GetImageVolumeGeometry().GetPositionCoordinatesFromVoxelIndices(...
                    m2dVertices_mm(:,2), m2dVertices_mm(:,1), m2dVertices_mm(:,3)); % m2dVertices given in 2,1,3 since m2dVertices come out as (x,y,z) == (col,row,slice)
            end
        end
        
        function [dSliceIndex, oFieldOfView2D] = GetDefaultFieldOfViewForImagingPlaneByRegionOfInterestNumber(obj, dRegionOfInterestNumber, eImagingPlaneType)
            arguments
                obj {MustBeRAS(obj)}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                eImagingPlaneType (1,1) ImagingPlaneTypes
            end
            
            obj.ForceApplyAllTransforms();
            
            [vdRowBounds, vdColBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
                        
            if isempty(vdRowBounds) % no true values
                vdVolumeDimensions = obj.GetVolumeDimensions();
                c1vdBounds = {...
                    [1, vdVolumeDimensions(1)],...
                    [1, vdVolumeDimensions(2)],...
                    [1, vdVolumeDimensions(3)]};
            else
                c1vdBounds = {vdRowBounds, vdColBounds, vdSliceBounds};
            end
            
            % get the row, col, slice dimensions for the ImagingPlaneType
            vdSelectDims = eImagingPlaneType.GetRASVolumeDimensionSelect();
            
            % select the correct bounds for each dimension for the
            % ImagingPlaneType
            vdRowBounds = c1vdBounds{vdSelectDims(1)};
            vdColBounds = c1vdBounds{vdSelectDims(2)};
            vdSliceBounds = c1vdBounds{vdSelectDims(3)};
            
            % slice index is rounded mean of the slice bounds
            dSliceIndex = round(mean(vdSliceBounds));
            
            % set FOV
            vdVoxelDimensions_mm = eImagingPlaneType.GetVoxelDimensions_mm(obj);
            [vdScaledRowCoords_mm, vdScaledColCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(vdRowBounds, vdColBounds, vdVoxelDimensions_mm(1), vdVoxelDimensions_mm(2));
            
            dHeight_mm = vdScaledRowCoords_mm(2) - vdScaledRowCoords_mm(1) + vdVoxelDimensions_mm(1); % add an extra voxel, since we don't want the FOV to go from voxel centre to voxel centre, but upper edge of top voxel to lower edge of bottom voxel (e.g. plus two half voxels)
            dWidth_mm = vdScaledColCoords_mm(2) - vdScaledColCoords_mm(1) + vdVoxelDimensions_mm(2);
            
            dCentreRow_mm = mean(vdScaledRowCoords_mm);
            dCentreCol_mm = mean(vdScaledColCoords_mm);
            
            oFieldOfView2D = ImageVolumeFieldOfView2D([dCentreRow_mm, dCentreCol_mm], dHeight_mm, dWidth_mm);
        end
        
        function m3bMask = GetMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            m3bMask = logical(bitget(obj.m3uiLabelMaps, dRegionOfInterestNumber));
        end
        
        function m3xCroppedMask = GetCroppedMaskByRegionOfInterestNumber(obj, vdCropCentreVoxelIndices, vdCropDimensions, dRegionOfInterestNumber)
            arguments
                obj
                vdCropCentreVoxelIndices (1,3) double {mustBeFinite}
                vdCropDimensions (1,3) double {mustBeInteger, mustBePositive}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            m3bMask = obj.GetMaskByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            m3xCroppedMask = MatrixUtils.CropMatrixByCentreAndDimensions(m3bMask, vdCropCentreVoxelIndices, vdCropDimensions);
        end 
        
        function [m3bMask, vdRowBounds, vdColumnBounds, vdSliceBounds] = GetZeroPaddedMinimallyBoundedMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}                
            end
            
            % m3bMask = GetMinimallyBoundedMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            %
            % SYNTAX:
            %  m3bMask = obj.GetMinimallyBoundedMaskByRegionOfInterestNumber(dRegionOfInterestNumber)
            %
            % DESCRIPTION:
            %  Returns a mask for the region of interest number given that
            %  is as small as possible, with a padding layer of "false" on
            %  all sides. This padding false is required for fitting
            %  polygons/meshes to the mask.
            %
            % INPUT ARGUMENTS:
            %  obj: MatlabLabelMapRegionsOfInterest object
            %  dRegionOfInterestNumber: A scalar double giving the region
            %                           of interest number to find the
            %                           values for
            %
            % OUTPUTS ARGUMENTS:
            %  m3bMask: 3D logical mask for the region of interest
            
            obj.ForceApplyAllTransforms();
            
            [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            if isempty(vdRowBounds) % no true values
                m3bMask = logical.empty;
            else
                % zero pad:
                vdRowBounds = vdRowBounds + [-1 1];
                vdColumnBounds = vdColumnBounds + [-1 1];
                vdSliceBounds = vdSliceBounds + [-1 1];
                
                % select
                switch class(obj.m3uiLabelMaps)
                    case 'uint8'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint8_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                    case 'uint16'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint16_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                    case 'uint32'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint32_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                    case 'uint64'
                        m3bMask = GetMaskSubsetFromBitLabelMap_uint64_mex(obj.m3uiLabelMaps, dRegionOfInterestNumber, vdRowBounds, vdColumnBounds, vdSliceBounds);
                end
            end
        end
        
        function vsRoiNames = GetRegionsOfInterestNames(obj)
            vsRoiNames = string.empty;
        end
        
        function vsRoiLabels = GetRegionsOfInterestObservationLabels(obj)
            vsRoiLabels = string.empty;
        end
        
        function vsRoiTypes = GetRegionsOfInterestInterpretedTypes(obj)
            vsRoiTypes = string.empty;
        end
        
        function vdRoiLabelMapNumbers = GetRegionsOfInterestLabelMapNumbers(obj)
            vdRoiLabelMapNumbers = [];
        end
        
        function RemoveAllTransforms(obj)
            RemoveAllTransforms@GeometricalImagingObject(obj);
            
            obj.m3uiLabelMaps = [];
            
            obj.chMatFilePath = '';
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>> FILE I/O <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function LoadVolumeData(obj)
            if isempty(obj.m3uiLabelMaps)
                if ~isempty(obj.chMatFilePath)
                    m3uiLabelMaps = FileIOUtils.LoadMatFile(...
                        obj.chMatFilePath,...
                        obj.chLabelMapsMatFileVarName);
                    
                    GeometricalImagingObject.MustBeValidVolumeData(m3uiLabelMaps, obj.GetCurrentImageVolumeGeometry());
                elseif ~isempty(obj.GetOriginalFilePath())
                    m3uiLabelMaps = obj.LoadLabelMapsFromDisk();
                    ValidationUtils.MustBeUnsignedInteger(m3uiLabelMaps);
                    obj.dCurrentAppliedImagingObjectTransform = 1;
                    GeometricalImagingObject.MustBeValidVolumeData(m3uiLabelMaps, obj.GetOnDiskImageVolumeGeometry());
                end
                
                % set values
                obj.m3uiLabelMaps = m3uiLabelMaps;
            end
        end
        
        function UnloadVolumeData(obj)
            obj.m3uiLabelMaps = [];
        end
    end
    
    methods (Access = public, Abstract = true)
        m2dColours_rgb = GetDefaultRenderColours_rgb(obj)
        
        vdColour_rgb = GetDefaultRenderColourByRegionOfInterestNumber_rgb(obj, dRegionOfInterestNumber)
        
        chFilePath = GetOriginalFilePath(obj) 
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract = true)
        
        m3uiLabelMaps = LoadLabelMapsFromDisk(obj)           
    end
    
    
    methods (Access = protected, Static = true)
        
        function MustBeValidMatFilePath_ChildClass(chMatFilePath)
            % TODO
            
            % local call
            oMatfile = matfile(chMatFilePath);
            
            vsFileEntries = whos(oMatfile);
            
            bLabelMapDataFound = false;
            
            for dEntryIndex=1:length(vsFileEntries)
                sEntry = vsFileEntries(dEntryIndex);
                                
                % check if entry is image volume data
                if strcmp(sEntry.name, LabelMapRegionsOfInterest.chLabelMapsMatFileVarName)
                    bLabelMapDataFound = true;
                end
            end
            
            if ~bLabelMapDataFound
                error(...
                    'LabelMapRegionsOfInterest:MustBeValidMatFilePath:InvalidMatFile',...
                    ['The given .mat file did not have the property "', LabelMapRegionsOfInterest.chLabelMapsMatFileVarName, '" required to load a LabelMapRegionsOfInterest object.']);
            end
        end
        
        function chClassName = GetLabelMapUintType(dNumberOfRegionsOfInterest)
            if dNumberOfRegionsOfInterest > 64
                error(...
                    'LabelMapRegionsOfInterest:GetLabelMapUintType:InvalidNumberOfRegionsOfInterest',...
                    'Cannot have more than 64 regions of interest.');
            elseif dNumberOfRegionsOfInterest > 32
                chClassName = 'uint64';
            elseif dNumberOfRegionsOfInterest > 16
                chClassName = 'uint32';
            elseif dNumberOfRegionsOfInterest > 8
                chClassName = 'uint16';
            else
                chClassName = 'uint8';
            end
        end
    end
    
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@RegionsOfInterest(obj);
            
            % local call
            % - none
        end
        
        function saveObj = saveobj(obj)
            saveObj = copy(obj);
            
            % clear out m3uiLabelMaps (can either get that back from the
            % original file (Dicom, Nifti) or from a Matfile if
            % .Save() was called
            saveObj.UnloadVolumeData();
        end
        
        function c1xRoiDataNameValuePairs = GetNameValuePairsForSave(obj, chMatFilePath)
            c1xRoiDataNameValuePairs = {...
                LabelMapRegionsOfInterest.chLabelMapsMatFileVarName, obj.m3uiLabelMaps};
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    
    methods (Access = {?LabelMapRegionsOfInterest, ?ImagingObjectTransform})
                
        function ApplyReassignFirstVoxel(obj, oTargetImageVolumeGeometry)
            obj.m3uiLabelMaps = obj.GetCurrentImageVolumeGeometry().ReassignFirstVoxel(...
                obj.GetCurrentLabelMaps(), oTargetImageVolumeGeometry);            
        end
        
        function ApplyMaskSpatialInterpolation(obj, oTargetImageVolumeGeometry, chInterpolationMethod, varargin)
            m3uiLabelMaps = obj.GetCurrentLabelMaps();
            
            vdTargetVolumeDimensions = oTargetImageVolumeGeometry.GetVolumeDimensions();
            
            m3ui64NewLabelMaps = zeros(vdTargetVolumeDimensions, 'like', m3uiLabelMaps);
                     
            
            
            for dMaskIndex=1:obj.GetNumberOfRegionsOfInterest()                                
                if isa(obj, 'RegionsOfInterestFromPolygons') && strcmp(chInterpolationMethod, 'levelsets')
                    vararginForRoi = [varargin, {obj.GetEnabledClosedPlanarPolygonsByRegionOfInterestNumber(dMaskIndex)}];
                else
                    vararginForRoi = varargin;
                end
                
                m3bNewMask = obj.GetCurrentImageVolumeGeometry().InterpolateMaskMatrixOntoTargetImageVolumeGeometry(...
                    logical(bitget(m3uiLabelMaps, dMaskIndex)),...
                    oTargetImageVolumeGeometry,...
                    chInterpolationMethod,...
                    vararginForRoi{:});
                
                m3ui64NewLabelMaps = bitset(m3ui64NewLabelMaps, dMaskIndex, m3bNewMask);
            end
            
            obj.m3uiLabelMaps = m3ui64NewLabelMaps;
        end
        
        function ApplyImageFilter(obj)            
        end
        
        function ApplyMorphologicalTransform(obj, vdRegionOfInterestNumbers, chFunctionName, varargin)
            arguments
                obj
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumbers)}
                chFunctionName (1,:) char                
            end
            arguments (Repeating)
                varargin
            end
            
            obj.SetLabelMapsForTransform();
            
            for dRoiIndex=1:length(vdRegionOfInterestNumbers)
                dRoiNumber = vdRegionOfInterestNumbers(dRoiIndex);
                
                m3bMask = logical(bitget(obj.m3uiLabelMaps, dRoiNumber));
                
                switch chFunctionName
                    case 'imerode'
                        m3bMask = imerode(m3bMask, varargin{:});
                    case 'imdilate'
                        m3bMask = imdilate(m3bMask, varargin{:});
                    otherwise
                        error(...
                            'LabelMapRegionsOfInterest:ApplyMorphologicalTransform:UnsupportedFunction',...
                            [chFunctionName, ' is not supported.']);
                end 
                
                obj.m3uiLabelMaps = bitset(obj.m3uiLabelMaps, dRoiNumber, m3bMask);                
            end                               
        end
        
        function ApplyBooleanOperation(obj, vdRegionOfInterestNumbers, fnBooleanOperation, oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput)
            arguments
                obj
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumbers)}
                fnBooleanOperation (1,1) function_handle
                oRegionsOfInterestSecondInput (1,1) {ValidationUtils.MustBeA(oRegionsOfInterestSecondInput, 'LabelMapRegionsOfInterest')}
                vdRegionOfInterestNumbersSecondInput (1,:) double {MustBeValidRegionOfInterestNumbers(oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput), ValidationUtils.MustBeSameSize(vdRegionOfInterestNumbersSecondInput, vdRegionOfInterestNumbers)}
            end
            
            obj.SetLabelMapsForTransform();
            oRegionsOfInterestSecondInput.SetLabelMapsForTransform();
            
            for dRoiIndex=1:length(vdRegionOfInterestNumbers)
                dFirstInputRoiNumber = vdRegionOfInterestNumbers(dRoiIndex);
                dSecondInputRoiNumber = vdRegionOfInterestNumbersSecondInput(dRoiIndex);
                
                m3bFirstInputMask = logical(bitget(obj.m3uiLabelMaps, dFirstInputRoiNumber));
                m3bSecondInputMask = logical(bitget(oRegionsOfInterestSecondInput.m3uiLabelMaps, dSecondInputRoiNumber));
                
                m3bFirstInputMask = fnBooleanOperation(m3bFirstInputMask, m3bSecondInputMask);
                
                obj.m3uiLabelMaps = bitset(obj.m3uiLabelMaps, dFirstInputRoiNumber, m3bFirstInputMask); 
            end
        end
        
        function ApplyCrop(obj, m2dCropBounds, oTargetImageVolumeGeometry)
            obj.m3uiLabelMaps = obj.m3uiLabelMaps(...
                m2dCropBounds(1,1) : m2dCropBounds(1,2),...
                m2dCropBounds(2,1) : m2dCropBounds(2,2),...
                m2dCropBounds(3,1) : m2dCropBounds(3,2));
        end
    end
    
    
    methods (Access = private)
        
        function dPlanarDimension = Get2DPlanarDimension(obj, vdRoiDimensions)
            vbIs1 = (vdRoiDimensions == 1);
            
            % determine which dimension the 2D-ness is in
            dAcquisitionDim = obj.GetAcquisitionDimension();
            
            if sum(vbIs1) == 1
                dPlanarDimension = find(vbIs1);
                
                if ~isempty(dAcquisitionDim) && dPlanarDimensions ~= dAcquisitionDim % if there is an acquisition dimensions and the planar dimension isn't it, error out
                    error(...
                        'LabelMapRegionsOfInterest:Get2DPlanarDimensionByRegionOfInterestNumber:IncorrectPlanarDimension',...
                        'The only dimension 1 voxel high of the ROI was not found to be the same as the acquisition dimension.');
                end
            else
                % there are multiple dimensions of 1 voxel, so we'll need
                % to set to be the acquisition dimension (if it exists!)
                
                if isempty(dAcquisitionDim) % no acquisition dimension, so we're sunk
                    error(...
                        'LabelMapRegionsOfInterest:GetPerimeterByRegionOfInterestNumber:AmbiguousPlanarDimension',...
                        'Multiple dimensions were found to be 1 voxel, and no acquisition dimension was found. The planar dimension is therefore ambiguous.');
                end
                
                dPlanarDimension = dAcquisitionDimension;
            end
        end
        
        function m3uiLabelMaps = GetCurrentLabelMaps(obj)
            obj.SetLabelMapsForTransform();
            
            m3uiLabelMaps = obj.m3uiLabelMaps;
        end
        
        function SetLabelMapsForTransform(obj)
            if isempty(obj.m3uiLabelMaps)
                obj.LoadVolumeData();
            end
        end
    end
    
    
    methods (Access = private, Static = true)
                
        function dRecist_mm = GetRecistForMask(m2bMask, vdVoxelDimensions_mm)
            if any(m2bMask(:))
                c1m2dPolyCoords_mm = LabelMapRegionsOfInterest.GetPolygonCoordsForMask(m2bMask, vdVoxelDimensions_mm);
                
                dRecist_mm = 0;
                
                for dPolygonIndex=1:length(c1m2dPolyCoords_mm)
                    %dRecist_mm = max(dRecist_mm, LabelMapRegionsOfInterest.GetRecistForPolygon(c1m2dPolyCoords_mm{dPolygonIndex},c1oPolyshapes_mm{dPolygonIndex}));
                    dRecist_mm = max(dRecist_mm, GetRecistForPolygon_mex(c1m2dPolyCoords_mm{dPolygonIndex})); % could use mex code here, but it's slower
                end
                
            else % no true values
                dRecist_mm = 0;
            end
        end
        
        function [c1m2dPolyCoords_mm, c1oPolyshapes_mm, dTotalNumPoints] = GetPolygonsForMask(m2bMask, vdVoxelDimensions_mm)
            
            % get polygons for mask
            % - use Matlab contour function at 0.5 (mid-way between
            %   0 and 1) to get polygons
            m2dContourMatrix = contourc(double(m2bMask), [0.5 0.5]);
            
            % - calc number of polygons (see Matlab docs for what
            %   m2dContourMatrix is like)
            dNumPolygons = 0;
            dColIndex = 1;
            
            while dColIndex <= size(m2dContourMatrix,2)
                dColIndex = dColIndex + m2dContourMatrix(2,dColIndex) + 1;
                dNumPolygons = dNumPolygons + 1;
            end
            
            % - set polygon coords into cell array.
            c1m2dPolyCoords_mm = cell(1,dNumPolygons);
            c1oPolyshapes_mm = cell(1,dNumPolygons);
            dContourMatrixIndex = 1;
            dTotalNumPoints = 0;
            
            for dPolygonIndex=1:dNumPolygons
                dNumPoints = m2dContourMatrix(2,dContourMatrixIndex);
                dTotalNumPoints = dTotalNumPoints + dNumPoints;
                
                vdX_mm = m2dContourMatrix(1, dContourMatrixIndex + (1:dNumPoints)); % minus 1, since last point is duplicated
                vdY_mm = m2dContourMatrix(2, dContourMatrixIndex + (1:dNumPoints));
                
                vdX_mm = vdX_mm .* vdVoxelDimensions_mm(2);
                vdY_mm = vdY_mm .* vdVoxelDimensions_mm(1);
                
                c1m2dPolyCoords_mm{dPolygonIndex} = [vdY_mm', vdX_mm']; % y then x, since y corresponds to rows, x to columns (want to keep everything in row, column, slice)
                c1oPolyshapes_mm{dPolygonIndex} = polyshape(vdY_mm,vdX_mm, 'KeepCollinearPoints', true); % same y then x ordering here
                
                dContourMatrixIndex = dContourMatrixIndex + dNumPoints + 1;
            end
        end
        
        function c1m2dPolyCoords_mm = GetPolygonCoordsForMask(m2bMask, vdVoxelDimensions_mm)
            
            % get polygons for mask
            % - use Matlab contour function at 0.5 (mid-way between
            %   0 and 1) to get polygons
            m2dContourMatrix = contourc(double(m2bMask), [0.5 0.5]);
            
            % - calc number of polygons (see Matlab docs for what
            %   m2dContourMatrix is like)
            dNumPolygons = 0;
            dColIndex = 1;
            
            while dColIndex <= size(m2dContourMatrix,2)
                dColIndex = dColIndex + m2dContourMatrix(2,dColIndex) + 1;
                dNumPolygons = dNumPolygons + 1;
            end
            
            % - set polygon coords into cell array.
            c1m2dPolyCoords_mm = cell(1,dNumPolygons);
            dContourMatrixIndex = 1;
            
            for dPolygonIndex=1:dNumPolygons
                dNumPoints = m2dContourMatrix(2,dContourMatrixIndex);
                
                vdX_mm = m2dContourMatrix(1, dContourMatrixIndex + (1:dNumPoints)); % minus 1, since last point is duplicated
                vdY_mm = m2dContourMatrix(2, dContourMatrixIndex + (1:dNumPoints));
                
                vdX_mm = vdX_mm .* vdVoxelDimensions_mm(2);
                vdY_mm = vdY_mm .* vdVoxelDimensions_mm(1);
                
                c1m2dPolyCoords_mm{dPolygonIndex} = [vdY_mm', vdX_mm']; % y then x, since y corresponds to rows, x to columns (want to keep everything in row, column, slice)
                
                dContourMatrixIndex = dContourMatrixIndex + dNumPoints + 1;
            end
        end
        
        function MustBeValidLabelMaps(m3uiLabelMaps, oImageVolumeGeometry, dNumberOfRegionsOfInterest)
            GeometricalImagingObject.MustBeValidVolumeData(m3uiLabelMaps, oImageVolumeGeometry);
            
            dMax = double(max(m3uiLabelMaps(:)));
            
            if dMax >= 2^dNumberOfRegionsOfInterest
                error(...
                    'LabelMapRegionsOfInterest:MustBeValidLabelMaps:InvalidBitValue',...
                    'The label maps contain true values in invalid bit positions given the number of regions of interest specified.');
            end
        end
        
        function MustBeValidPerimeterOfSurfaceAreaMethod(chPerimeterOrSurfaceAreaMethod, chVolumeInterpretation)
            arguments
                chPerimeterOrSurfaceAreaMethod (1,:) char
                chVolumeInterpretation (1,2) char
            end
            
            switch chVolumeInterpretation
                case '2D'
                    if ~ismember(chPerimeterOrSurfaceAreaMethod, {'pixel','polygon'})
                        error(...
                            'LabelMapRegionsOfInterest:ValidatePerimeterOfSurfaceAreaMethod:InvalidPerimeterMethod',...
                            'Perimeter method must be ''pixel'' or ''polygon''.');
                    end
                case '3D'
                    if ~ismember(chPerimeterOrSurfaceAreaMethod, {'voxel','mesh'})
                        error(...
                            'LabelMapRegionsOfInterest:ValidatePerimeterOfSurfaceAreaMethod:InvalidSurfaceAreaMethod',...
                            'Surface area method must be ''voxel'' or ''mesh''.');
                    end                    
                otherwise
                    error(...
                        'LabelMapRegionsOfInterest:ValidatePerimeterOfSurfaceAreaMethod:InvalidVolumeInterpretation',...
                        'chVolumeInterpretation must be ''2D'' or ''3D''.');
            end
        end
        
        function MustBeValidAreaOrVolumeMethod(chAreaOrVolumeMethod, chVolumeInterpretation)
            arguments
                chAreaOrVolumeMethod (1,:) char
                chVolumeInterpretation (1,2) char
            end
            
            switch chVolumeInterpretation
                case '2D'
                    if ~ismember(chAreaOrVolumeMethod, {'pixel','polygon'})
                        error(...
                            'LabelMapRegionsOfInterest:ValidateAreaOrVolumeMethod:InvalidAreaMethod',...
                            'Area method must be ''pixel'' or ''polygon''.');
                    end
                case '3D'
                    LabelMapRegionsOfInterest.MustBeValidVolumeMethod(chAreaOrVolumeMethod);                    
                otherwise
                    error(...
                        'LabelMapRegionsOfInterest:ValidateAreaOrVolumeMethod:InvalidVolumeInterpretation',...
                        'chVolumeInterpretation must be ''2D'' or ''3D''.');
            end
        end
        
        function MustBeValidVolumeMethod(chVolumeMethod)
            arguments
                chVolumeMethod (1,:) char
            end
            
            if ~ismember(chVolumeMethod, {'voxel','mesh'})
                error(...
                    'LabelMapRegionsOfInterest:MustBeValidVolumeMethod:InvalidVolumeMethod',...
                    'Volume method must be ''voxel'' or ''mesh''.');
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
        
        function m3uiLabelMaps = GetLabelMaps_ForUnitTest(obj)
            % this is useful for unit tests to be able to directly see what
            % the current state of m3uiLabelMaps, whereas using the public
            % methods performs necessary loading/transforms
            
            m3uiLabelMaps = obj.m3uiLabelMaps;
        end      
        
        function chVarName = GetLabelMapsMatFileVarName_ForUnitTest(obj)
            chVarName = obj.chLabelMapsMatFileVarName;
        end
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end


