classdef ClosedPlanarPolygon < matlab.mixin.Copyable
    %ClosedPlanarPolygon
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Access = private, Constant)  
        dPolygonSliceDimensionVariationBound = 0.05 % 1/50 of a voxel
        
        dPolygonSliceIndexDistanceFromCentreWarningBound = 0.05 % 1/50 of a voxel
        dPolygonSliceIndexDistanceFromCentreErrorBound = 0.33 % 1/3 of a voxel
    end
    
    properties (SetAccess = private, GetAccess = public)
        % coordinates of the polygon vertices in 3D space (e.g. x,y,z in
        % mm)
        m2dVertexPositionCoordinates_mm (:,3) double
        
        % coordinates of polygon vertices with respect to the image volume
        % geometry voxel centre indices (e.g. row, col, slice)
        m2dVertexVoxelIndices (:,3) double
        
        % **IF** the polygon is planar with the row, column or slice
        % dimension of the ImageVolumeGeometry
        dImageVolumePlaneDimension double {ValidationUtils.MustBeEmptyOrScalar} = []
        dImageVolumePlaneIndex double {ValidationUtils.MustBeEmptyOrScalar} = []
        
        % the image volume geometry of the objects parent
        oImageVolumeGeometry ImageVolumeGeometry {ValidationUtils.MustBeEmptyOrScalar} = ImageVolumeGeometry.empty
        bIsRASObject logical {ValidationUtils.MustBeEmptyOrScalar}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ClosedPlanarPolygon(m2dVertexPositionCoordinates_mm, oImageVolumeGeometry)
            % set properities
            obj.oImageVolumeGeometry = oImageVolumeGeometry;
            obj.m2dVertexPositionCoordinates_mm = m2dVertexPositionCoordinates_mm;
            
            % calculate the voxel indices using the ImageVolumeGeometry
            [vdRowIndices, vdColumnIndices, vdSliceIndices] = oImageVolumeGeometry.GetVoxelIndicesFromPositionCoordinates(...
                m2dVertexPositionCoordinates_mm(:,1),...
                m2dVertexPositionCoordinates_mm(:,2),...
                m2dVertexPositionCoordinates_mm(:,3));
            
            obj.m2dVertexVoxelIndices = [vdRowIndices, vdColumnIndices, vdSliceIndices];
                 
            % find the dimension with the least variation
            [dImageVolumePlaneDimension, dImageVolumePlaneIndex] = ClosedPlanarPolygon.GetPlaneDimensionAndIndexForVertexVoxelIndices(obj.m2dVertexVoxelIndices);
              
            obj.dImageVolumePlaneDimension = dImageVolumePlaneDimension;
            obj.dImageVolumePlaneIndex = dImageVolumePlaneIndex;            
        end   
        
        function RestoreToOnDiskGeometry(obj, oOnDiskObj)
            obj.m2dVertexPositionCoordinates_mm = oOnDiskObj.m2dVertexPositionCoordinates_mm;
            obj.m2dVertexVoxelIndices = oOnDiskObj.m2dVertexVoxelIndices;
            obj.dImageVolumePlaneDimension = oOnDiskObj.dImageVolumePlaneDimension;
            obj.dImageVolumePlaneIndex = oOnDiskObj.dImageVolumePlaneIndex;
            obj.oImageVolumeGeometry = oOnDiskObj.oImageVolumeGeometry;
            obj.bIsRASObject = oOnDiskObj.bIsRASObject;
        end
        
        function bBool = IsRAS(obj)
            if isempty(obj.bIsRASObject)
                obj.bIsRASObject = obj.oImageVolumeGeometry.IsRAS();
            end
            
            bBool = obj.bIsRASObject;
        end
                
        function bBool = IsValidToSetImageVolumePlaneDimensionTo(obj, dPlaneDim)
            arguments
                obj (1,1) ClosedPlanarPolygon
                dPlaneDim (1,1) double {mustBeMember(dPlaneDim, [1,2,3])}
            end
            
            dRange = max(obj.m2dVertexVoxelIndices(:,dPlaneDim)) - min(obj.m2dVertexVoxelIndices(:,dPlaneDim));
            
            bBool = dRange <= ClosedPlanarPolygon.dPolygonSliceDimensionVariationBound;
        end
        
        function SetImageVolumePlaneDimension(obj, dPlaneDim)
            arguments
                obj (1,1) ClosedPlanarPolygon
                dPlaneDim (1,1) double {mustBeMember(dPlaneDim, [1,2,3]), MustBeValidImageVolumePlaneDimension(obj, dPlaneDim)}
            end
            
            obj.dImageVolumePlaneDimension = dPlaneDim;
            obj.dImageVolumePlaneIndex = mean(obj.m2dVertexVoxelIndices(:,dPlaneDim));
        end
        
        function dPlaneDim = GetImageVolumePlaneDimension(obj)
            dPlaneDim = obj.dImageVolumePlaneDimension;
        end
        
        function dPlaneIndex = GetImageVolumePlaneIndex(obj)
            dPlaneIndex = obj.dImageVolumePlaneIndex;
        end
        
        function vdCentroid = GetImageVolumeCoordinatesCentroid(obj)
            vdCentroid = mean(obj.m2dVertexVoxelIndices,1);
        end
        
        function dRecist_mm = GetRecist(obj)
            if isempty(obj.dImageVolumePlaneDimension)
                error(...
                    'ClosedPlanarPolygons:GetRecist:NotInPlane',...
                    'RECIST can only be calculated if the polygons are in plane.');
            end
            
            m2dVertexVoxelIndices_mm = obj.m2dVertexVoxelIndices;
            
            vdDimsSelect = 1:3;
            vdDimsSelect(obj.dImageVolumePlaneDimension) = [];
            
            vdVoxelDimensions_mm = obj.oImageVolumeGeometry.GetVoxelDimensions_mm();
            vdVoxelDimensions_mm = vdVoxelDimensions_mm(vdDimsSelect);
            
            m2dVertexVoxelIndices_mm = m2dVertexVoxelIndices_mm(:,vdDimsSelect);
            
            m2dVertexVoxelIndices_mm(:,1) = vdVoxelDimensions_mm(1).*m2dVertexVoxelIndices_mm(:,1);
            m2dVertexVoxelIndices_mm(:,2) = vdVoxelDimensions_mm(2).*m2dVertexVoxelIndices_mm(:,2);
            
            dRecist_mm = GetRecistForPolygon_mex(m2dVertexVoxelIndices_mm);
        end
        
        function m2dVertexVoxelIndices = GetVertexVoxelIndices(obj)
            m2dVertexVoxelIndices = obj.m2dVertexVoxelIndices;
        end
        
        function m2dVertexPositionCoords_mm = GetVertexPositionCoordinates_mm(obj)
            m2dVertexPositionCoords_mm = obj.m2dVertexPositionCoordinates_mm;
        end
        
        function bBool = IsInSlice(obj, vdAnatomicalPlaneIndices, eImagingPlaneType)
            arguments
                obj (1,1) ClosedPlanarPolygon {MustBeRAS(obj)}
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger}
                eImagingPlaneType (1,1) ImagingPlaneTypes
            end
            
            bBool = false;
            
            vdRasDimSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            dSliceDimSelect = vdRasDimSelect(3);
            
            if ~isempty(obj.dImageVolumePlaneDimension) && obj.dImageVolumePlaneDimension == dSliceDimSelect % check that polygon is within an RAS plane and that plane is the same as ImagingPlaneType
                bBool = ...
                    (obj.dImageVolumePlaneIndex <= vdAnatomicalPlaneIndices(dSliceDimSelect) + 0.5) && ...
                    (obj.dImageVolumePlaneIndex >= vdAnatomicalPlaneIndices(dSliceDimSelect) - 0.5); % these inclusive 0.5 bounds allow for polygons that are anywhere within a slice to be grabbed, not just EXACTLY at the slice centre (this EXACTLY at slice centre would likely be true when viewing data directly after exporting/contouring, but after interpolation, etc. it would likely not be anymore)
            end
        end
        
        function m3bMask = AddToMask(obj, m3bMask)
            if isempty(obj.dImageVolumePlaneDimension)
                error(...
                    'ClosedPlanarPolygon:AddToMask:PolygonNotCoplanar',...
                    'The ClosedPlanarPoylgon is not coplanar with the image volume voxel matrix, and so it cannot be used to create a mask.');
            elseif (size(obj.m2dVertexPositionCoordinates_mm,1) ~= 1) % not a point
                dDistanceFromVoxelCentre = abs(obj.dImageVolumePlaneIndex - round(obj.dImageVolumePlaneIndex)); % gives in numbers of voxels how far the polygon's plane index is from the voxel centres (voxel centres are whole numbers)
                
                if dDistanceFromVoxelCentre > ClosedPlanarPolygon.dPolygonSliceIndexDistanceFromCentreErrorBound % if the polygon is too far from the voxel centres, it isn't really valid to use to generate masks directly onto the voxel grid. Extreme example: polygon lies directly halfway between to two slices of voxel centres. Which voxels do you assign it to?
                    error(...
                        'ClosedPlanarPolygon:AddToMask:PolygonNotOnVoxelCentres',...
                        ['The ClosedPlanarPoylgon is too far from the image volume voxel matrix centres, and so it cannot be used to create a mask. Distance from voxel centre: ', num2str(dDistanceFromVoxelCentre)]);               
                end
                
                % round the image volume plane index, since we have
                % validated above that it is close enough to the voxel
                % centres
                dSliceIndex = round(obj.dImageVolumePlaneIndex);
                
                % get polygon coords in slice
                vdInPlaneDims = 1:3;
                vdInPlaneDims(obj.dImageVolumePlaneDimension) = [];
                
                vdYCoords = obj.m2dVertexVoxelIndices(:,vdInPlaneDims(1));
                vdXCoords = obj.m2dVertexVoxelIndices(:,vdInPlaneDims(2));
                
                vdVolumeDimensions = obj.oImageVolumeGeometry.GetVolumeDimensions();
                vdSliceDimensions = vdVolumeDimensions(vdInPlaneDims);
                
                % convert coords to mask slice
                m2bSliceMask = poly2mask(vdXCoords, vdYCoords, vdSliceDimensions(1), vdSliceDimensions(2));
                
                % retrieve the current mask in the slice
                switch obj.dImageVolumePlaneDimension
                    case 1
                        m2bCurrentSliceMask = squeeze(m3bMask(dSliceIndex,:,:));
                    case 2
                        m2bCurrentSliceMask = squeeze(m3bMask(:,dSliceIndex,:));
                    case 3
                        m2bCurrentSliceMask = m3bMask(:,:,dSliceIndex);
                end
                
                % logical OR current slice mask and the polygon slice mask
                % (e.g. if two polygon overlap, they're "added" together)
                m2bCurrentSliceMask = m2bSliceMask | m2bCurrentSliceMask; 
                
                % write it back
                switch obj.dImageVolumePlaneDimension
                    case 1
                        m3bMask(dSliceIndex,:,:) = m2bCurrentSliceMask;
                    case 2
                        m3bMask(:,dSliceIndex,:) = m2bCurrentSliceMask;
                    case 3
                        m3bMask(:,:,dSliceIndex) = m2bCurrentSliceMask;
                end
            end
        end
        
        function m2bSliceMask = AddToSliceMask(obj, m2bSliceMask)
            if isempty(obj.dImageVolumePlaneDimension)
                error(...
                    'ClosedPlanarPolygon:AddToMask:PolygonNotCoplanar',...
                    'The ClosedPlanarPoylgon is not coplanar with the image volume voxel matrix, and so it cannot be used to create a mask.');
            else                
                % get polygon coords in slice
                vdInPlaneDims = 1:3;
                vdInPlaneDims(obj.dImageVolumePlaneDimension) = [];
                
                vdYCoords = obj.m2dVertexVoxelIndices(:,vdInPlaneDims(1));
                vdXCoords = obj.m2dVertexVoxelIndices(:,vdInPlaneDims(2));
                
                vdVolumeDimensions = obj.oImageVolumeGeometry.GetVolumeDimensions();
                vdSliceDimensions = vdVolumeDimensions(vdInPlaneDims);
                
                % convert coords to mask slice
                m2bSliceMaskToAdd = poly2mask(vdXCoords, vdYCoords, vdSliceDimensions(1), vdSliceDimensions(2));
                                
                % logical OR current slice mask and the polygon slice mask
                % (e.g. if two polygon overlap, they're "added" together)
                m2bSliceMask = m2bSliceMaskToAdd | m2bSliceMask;                 
            end
        end
        
        function ApplyReassignFirstVoxel(obj, oNewImageVolumeGeometry, vdVolumeDimensionReassignment)
            obj.oImageVolumeGeometry = oNewImageVolumeGeometry;
            
            [vdRowIndices, vdColumnIndices, vdSliceIndices] = oNewImageVolumeGeometry.GetVoxelIndicesFromPositionCoordinates(...
                obj.m2dVertexPositionCoordinates_mm(:,1),...
                obj.m2dVertexPositionCoordinates_mm(:,2),...
                obj.m2dVertexPositionCoordinates_mm(:,3));
            
            obj.m2dVertexVoxelIndices = [vdRowIndices, vdColumnIndices, vdSliceIndices];
                        
            if ~isempty(obj.dImageVolumePlaneDimension) % need to figure out if the plane the polygon is in needs to be adjusted
                obj.dImageVolumePlaneDimension = find(vdVolumeDimensionReassignment == obj.dImageVolumePlaneDimension);
                obj.dImageVolumePlaneIndex = mean(obj.m2dVertexVoxelIndices(:,obj.dImageVolumePlaneDimension));
            end
        end
        
        function ApplyNewVoxelResolution(obj, oNewImageVolumeGeometry)
            if ...
                    any(oNewImageVolumeGeometry.GetRowAxisUnitVector() ~= obj.oImageVolumeGeometry.GetRowAxisUnitVector()) ||...
                    any(oNewImageVolumeGeometry.GetColumnAxisUnitVector() ~= obj.oImageVolumeGeometry.GetColumnAxisUnitVector())
                error(...
                    'ClosedPlanarPolygon:ApplyNewVoxelResolution:InvalidRotation',...
                    'Cannot apply any rotations to the Image Volume when changing resolution.');
            end
            
            obj.oImageVolumeGeometry = oNewImageVolumeGeometry;
            
            [vdRowIndices, vdColumnIndices, vdSliceIndices] = oNewImageVolumeGeometry.GetVoxelIndicesFromPositionCoordinates(...
                obj.m2dVertexPositionCoordinates_mm(:,1),...
                obj.m2dVertexPositionCoordinates_mm(:,2),...
                obj.m2dVertexPositionCoordinates_mm(:,3));
            
            obj.m2dVertexVoxelIndices = [vdRowIndices, vdColumnIndices, vdSliceIndices];
            
            if ~isempty(obj.dImageVolumePlaneDimension) % plane the polygon is in doesn't change, but the slice number sure does
                obj.dImageVolumePlaneIndex = mean(obj.m2dVertexVoxelIndices(:,obj.dImageVolumePlaneDimension));
            end
        end
    end
    
    
    
    
    % TODO: Headers
    
        
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function MustBeValidImageVolumePlaneDimension(obj, dPlaneDim)
            if ~obj.IsValidToSetImageVolumePlaneDimensionTo(dPlaneDim)
                error(...
                    'ClosedPlanarPolygon:MustBeValidImageVolumePlaneDimension:Invalid',...
                    'The plane dimension given would result in a polygon that is not coplanar with the image volume voxel matrix.');
            end
        end
        
        function MustBeRAS(obj)
            if ~obj.IsRAS()
                error(...
                    'ClosedPlanarPolygon:MustBeRAS:Invalid',...
                    'The object must be in an RAS image volume geometry.');
            end
        end
    end    
    
    methods (Access = private, Static = true)
       
        function [dImageVolumePlaneDimension, dImageVolumePlaneIndex] = GetPlaneDimensionAndIndexForVertexVoxelIndices(m2dVertexVoxelIndices)
            vdDimRange = (max(m2dVertexVoxelIndices,[],1) - min(m2dVertexVoxelIndices,[],1));
            [dMinDimRange,dMinDim] = min(vdDimRange);
            
            if dMinDimRange > ClosedPlanarPolygon.dPolygonSliceDimensionVariationBound % polygon not co-planar with the image volume
                dImageVolumePlaneDimension = [];
                dImageVolumePlaneIndex = [];
            else
                dImageVolumePlaneDimension = dMinDim;
                dImageVolumePlaneIndex = mean(m2dVertexVoxelIndices(:,dMinDim));
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

