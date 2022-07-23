classdef ImageVolumeGeometry
    %ImageVolumeGeometry
    %
    % Stores all the geometry information (location, orientation,
    % dimensions, voxel spacing) for a image volume that consists of
    % consistently spaced, orthogonal voxels 
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        vdVolumeDimensions (1,3) double {mustBeInteger, mustBePositive} = [1 1 1]
        
        vdVoxelDimensions_mm (1,3) double {mustBePositive} = [1 1 1]
        
        vdFirstVoxelPosition_mm (1,3) double {mustBeFinite} = [0 0 0]
        
        vdRowAxisUnitVector (1,3) double {mustBeFinite} = [1 0 0]    % i
        vdColumnAxisUnitVector (1,3) double {mustBeFinite} = [0 1 0] % j
        % slice unit (k) vector is cross-product of vdRowAxisUnitVector and
        % vdRowAxisUnitVector 
        
        % these may be empty, depending if this data is known
        dAcquisitionDimension (:,:) double = []
        dAcquisitionSliceThickness_mm (:,:) double = []
    end
    
    
    properties (Constant = true, GetAccess = private)
        % precision bound when needing to know if two values are
        % equivalent. Within medical imaging, 1nm is good enough
        dPrecisionBound (1,1) double = 1E-6
        
        dOrthogonalPrecisionBound (1,1) double = 1E-4
        dUnitVectorNormPrecisionBound (1,1) double = 1E-4
        
        % when "eq" is called, this is how close the ImageVolumeGeometries
        % need to be.
        dEqualityBound (1,1) double = 0.001 %1/1000th of a mm should be more than enough for medical imaging applications
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImageVolumeGeometry(vdVolumeDimensions, vdRowAxisUnitVector, vdColumnAxisUnitVector,  vdVoxelDimensions_mm, vdFirstVoxelPosition_mm, dAcquisitionDimension, dAcquisitionSliceThickness_mm)
            % obj = ImageVolumeGeometry(vdVolumeDimensions, vdRowAxisUnitVector, vdColumnAxisUnitVector,  vdVoxelDimensions_mm, vdFirstVoxelPosition_mm, dAcquisitionDimension, dAcquisitionSliceThickness_mm)
            % 
            % SYNTAX:
            %  obj = ImageVolumeGeometry(vdVolumeDimensions, vdRowAxisUnitVector, vdColumnAxisUnitVector,  vdVoxelDimensions_mm, vdFirstVoxelPosition_mm)
            %  obj = ImageVolumeGeometry(vdVolumeDimensions, vdRowAxisUnitVector, vdColumnAxisUnitVector,  vdVoxelDimensions_mm, vdFirstVoxelPosition_mm, dAcquisitionDimension, dAcquisitionSliceThickness_mm)
            %
            % DESCRIPTION:
            %  Constructor for the ImageVolumeGeometry class. Acquisition
            %  dimension and slice thickness are optional.
            %
            % INPUT ARGUMENTS:
            %  vdVolumeDimensions: A 1x3 row vector containing the number
            %                      of voxels in each dimension of the image
            %                      matrix. They must be positive, integer
            %                      values. This would be the same vector
            %                      produced by "size(imageMatrix)". If an
            %                      image is 2D, it's third dimension value
            %                      should be set to 1.
            % vdRowAxisUnitVector: A 1x3 row vector containing the
            %                      orientation of the image matrix's rows
            %                      (e.g. "i" dimensions). This vector is
            %                      specified within an RAS geometry. It
            %                      must be a unit vector.
            % vdColumnAxisUnitVector: A 1x3 row vector containing the
            %                         orientation of the image matrix's columns
            %                         (e.g. "j" dimensions). This vector is
            %                         specified within an RAS geometry. It
            %                         must be a unit vector.
            % vdVoxelDimensions_mm: A 1x3 row vector containing the voxel
            %                       spacing in mm. The first value is the
            %                       spacing between rows of the matrix, the
            %                       second between the columns, and third
            %                       between the slices. If an image is 2D,
            %                       it's third dimension value should be
            %                       set to be a non-zero value.
            % vdFirstVoxelPosition_mm: A 1x3 row vector containing the RAS
            %                          coordinates in mm of the first voxel
            %                          (1,1,1) centre, with respect the
            %                          origin set by the imager.
            % dAcquisitionDimensions: (Optional) A scalar value of either 
            %                          1, 2 or 3. If known, it specifies
            %                          which dimension of the matrix
            %                          represents an acquired slice from
            %                          the scanner. E.g. if
            %                          imageMatrix(:,n,:) would produce an
            %                          acquired slice at n, this parameter
            %                          should be set to 2. This value must
            %                          be specified if dAcquisitionSliceThickness_mm
            %                          is specified.
            % dAcquisitionSliceThickness_mm: (Optional) A non-zero scalar value
            %                                 representing the slice
            %                                 thickness in mm of the
            %                                 acquired slices. Depending on
            %                                 the slice spacing during
            %                                 acquisition, this may or may
            %                                 not be the same as the value
            %                                 given in vdVoxelDimensions_mm
            %
            % OUTPUT ARGUMENTS:
            %  obj: Constructed class object
            
            arguments
                vdVolumeDimensions (1,3) double {mustBeInteger, mustBePositive}
                vdRowAxisUnitVector (1,3) double {mustBeFinite, ImageVolumeGeometry.MustBeUnitVector(vdRowAxisUnitVector)}
                vdColumnAxisUnitVector (1,3) double {mustBeFinite, ImageVolumeGeometry.MustBeUnitVector(vdColumnAxisUnitVector), ImageVolumeGeometry.MustBeOrthogonal(vdColumnAxisUnitVector, vdRowAxisUnitVector)}
                vdVoxelDimensions_mm (1,3) double {mustBePositive, mustBeFinite}
                vdFirstVoxelPosition_mm (1,3) double {mustBeFinite}
                dAcquisitionDimension (:,:) double {ImageVolumeGeometry.ValidateAcquisitionDimension(dAcquisitionDimension)} = []
                dAcquisitionSliceThickness_mm (:,:) double {ImageVolumeGeometry.ValidateAcquisitionSliceThickness_mm(dAcquisitionSliceThickness_mm)} = []
            end
            
            % set properities            
            obj.vdVolumeDimensions = vdVolumeDimensions;
            
            obj.vdRowAxisUnitVector = vdRowAxisUnitVector;
            obj.vdColumnAxisUnitVector = vdColumnAxisUnitVector;
            
            obj.vdVoxelDimensions_mm = vdVoxelDimensions_mm;
            obj.vdFirstVoxelPosition_mm = vdFirstVoxelPosition_mm;
            
            obj.dAcquisitionDimension = dAcquisitionDimension;
            obj.dAcquisitionSliceThickness_mm = dAcquisitionSliceThickness_mm;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function bBool = IsRAS(obj)
            % bBool = IsRAS(obj)
            %
            % SYNTAX:
            %  bBool = obj.IsRAS();
            %
            % DESCRIPTION:
            %  Returns a value of true if the ImageVolumeGeometry is
            %  aligned with the RAS geometry (that is the row unit vector
            %  is [1 0 0], the column unit vector is [0 1 0], and therefore
            %  the slice unit vector is [0 0 1]). If the
            %  ImageVolumeGeometry is oblique, the value can be returned as
            %  true as long the orientation is as close to RAS as possible.
            %
            % INPUT ARGUMENTS:
            %  obj:
            %   An ImageVolumeGeometry object
            %
            % OUTPUT ARGUMENTS:
            %  bBool:
            %   Scalar boolean value. See DESCRIPTION above.
            
            
            % have obj be transformed to align w/ RAS. If there's no
            % change, it was RAS already.
            [~, oGeometryAfterTransform] = obj.ReassignFirstVoxel([], obj.GetRASImageVolumeGeometry);
            
            bBool = all(obj.vdRowAxisUnitVector == oGeometryAfterTransform.vdRowAxisUnitVector) && all(obj.vdColumnAxisUnitVector == oGeometryAfterTransform.vdColumnAxisUnitVector);
        end
        
        function [vdVolumeBoundsX_mm, vdVolumeBoundsY_mm, vdVolumeBoundsZ_mm] = GetVolumeBounds(obj)
            % [vdVolumeBoundsX_mm, vdVolumeBoundsY_mm, vdVolumeBoundsZ_mm] = GetVolumeBounds(obj)
            %
            % SYNTAX:
            %  [vdVolumeBoundsX_mm, vdVolumeBoundsY_mm, vdVolumeBoundsZ_mm] = obj.GetVolumeBounds()
            %
            % DESCRIPTION:
            %  Provides the minimum and maximum bounds of the image volume
            %  in each dimension (x [LR], y [AP], z [SI]).
            %
            % INPUT ARGUMENTS:
            %  obj:
            %   An ImageVolumeObject
            %
            % OUTPUT ARGUMENTS:
            %  vdVolumeBoundsX_mm:
            %   A 1x2 double containing the most negative extent of the
            %   volume in the x direction in index 1, and the most positive
            %   extent of the volume in index 2.
            %  vdVolumeBoundsY_mm:
            %   A 1x2 double containing the most negative extent of the
            %   volume in the y direction in index 1, and the most positive
            %   extent of the volume in index 2.
            %  vdVolumeBoundsZ_mm:
            %   A 1x2 double containing the most negative extent of the
            %   volume in the z direction in index 1, and the most positive
            %   extent of the volume in index 2.
            
            vdVolumeDimensions = obj.vdVolumeDimensions;
            
            % using voxel indices of 0.5 and "size"+0.5 so that the
            % position coordinates are to the edge of the image volume, not
            % the centre of the outermost voxels
            [vdX_mm, vdY_mm, vdZ_mm] = obj.GetPositionCoordinatesFromVoxelIndices(...
                [0.5 vdVolumeDimensions(1)+0.5],...
                [0.5 vdVolumeDimensions(2)+0.5],...
                [0.5 vdVolumeDimensions(3)+0.5]);
            
            vdVolumeBoundsX_mm = [min(vdX_mm) max(vdX_mm)];
            vdVolumeBoundsY_mm = [min(vdY_mm) max(vdY_mm)];
            vdVolumeBoundsZ_mm = [min(vdZ_mm) max(vdZ_mm)];
        end
        
        function vdVolumeDimensions = GetVolumeDimensions(obj)
            % vdVolumeDimensions = GetVolumeDimensions(obj)
            %
            % SYNTAX:
            %  vdVolumeDimensions = obj.GetVolumeDimensions()
            %
            % DESCRIPTION:
            %  Returns the dimensions of the image matrix (e.g. the number
            %  of rows, columns, and slices)
            %
            % INPUT ARGUMENTS:
            %  obj:
            %   An ImageVolumeObject
            %
            % OUTPUT ARGUMENTS:
            %  vdVolumeDimensions:
            %   A 1x3 double of positive integers containing the number of
            %   rows, columns, and slices in the image matrix
            
            vdVolumeDimensions = obj.vdVolumeDimensions;
        end
        
        function vdVolumeDimensions_mm = GetVolumeDimensions_mm(obj)
            % vdVolumeDimensions_mm = GetVolumeDimensions_mm(obj)
            %
            % SYNTAX:
            %  vdVolumeDimensions_mm = obj.GetVolumeDimensions_mm()
            %
            % DESCRIPTION:
            %  Returns the dimensions of the image matrix in mm (e.g. the
            %  size of the image volume matrix in the row, column, and
            %  slice directions)
            %
            % INPUT ARGUMENTS:
            %  obj:
            %   An ImageVolumeObject 
            %
            % OUTPUT ARGUMENTS:
            %  vdVolumeDimensions_mm:
            %   A 1x3 double of positive values containing the size of the
            %   image matrix in each dimensions, in units of mm.
            
            vdVolumeDimensions_mm = obj.vdVolumeDimensions .* obj.vdVoxelDimensions_mm;
        end
        
        function vdVoxelDimensions_mm = GetVoxelDimensions_mm(obj)
            vdVoxelDimensions_mm = obj.vdVoxelDimensions_mm;
        end
        
        function vdFirstVoxelPosition_mm = GetFirstVoxelPosition_mm(obj)
            vdFirstVoxelPosition_mm = obj.vdFirstVoxelPosition_mm;
        end
        
        function vdFirstVoxelCornerPosition_mm = GetFirstVoxelCornerPosition(obj)
            vdVoxelDimensions_mm = obj.vdVoxelDimensions_mm;
            vdFirstVoxel_mm = obj.vdFirstVoxelPosition_mm;
            
            vdRowUnitVector = obj.GetRowAxisUnitVector();
            vdColUnitVector = obj.GetColumnAxisUnitVector();
            vdSliceUnitVector = obj.GetSliceAxisUnitVector();
            
            vdFirstVoxelCornerPosition_mm = vdFirstVoxel_mm - 0.5 .* (...
                vdVoxelDimensions_mm(1) * vdRowUnitVector +...
                vdVoxelDimensions_mm(2) * vdColUnitVector +...
                vdVoxelDimensions_mm(3) * vdSliceUnitVector);
        end
        
        function vdAlongColUnitVector = GetColumnAxisUnitVector(obj)
            vdAlongColUnitVector = obj.vdColumnAxisUnitVector;
        end
        
        function vdRowAxisUnitVector = GetRowAxisUnitVector(obj)
            vdRowAxisUnitVector = obj.vdRowAxisUnitVector;
        end
        
        function vdAlongSliceUnitVector = GetSliceAxisUnitVector(obj)
            vdAlongSliceUnitVector = ImageVolumeGeometry.CalculateSliceAxisUnitVector(...
                obj.vdRowAxisUnitVector, obj.vdColumnAxisUnitVector);
        end
        
        function dAcquisitionDimension = GetAcquisitionDimension(obj)
            dAcquisitionDimension = obj.dAcquisitionDimension;
        end
        
        function dAcquisitionSliceThickness_mm = GetAcquisitionSliceThickness_mm(obj)
            dAcquisitionSliceThickness_mm = obj.dAcquisitionSliceThickness_mm;
        end
        
        function oNewImageVolumeGeometry = GetSelectionImageVolumeGeometry(obj, vdRowSelectionBounds, vdColumnSelectionBounds, vdSliceSelectionBounds)
            [dX_mm, dY_mm, dZ_mm] = obj.GetPositionCoordinatesFromVoxelIndices(vdRowSelectionBounds(1), vdColumnSelectionBounds(1), vdSliceSelectionBounds(1));
            vdMaskFirstVoxelPosition_mm = [dX_mm, dY_mm, dZ_mm];
            
            vdVolumeDims = [vdRowSelectionBounds(2)-vdRowSelectionBounds(1), vdColumnSelectionBounds(2)-vdColumnSelectionBounds(1), vdSliceSelectionBounds(2)-vdSliceSelectionBounds(1)]+1;
            
            if isempty(obj.dAcquisitionDimension)
                varargin = {};
            else
                varargin = {...
                    obj.dAcquisitionDimension,...
                    obj.dAcquisitionSliceThickness_mm};
            end
            
            oNewImageVolumeGeometry = ImageVolumeGeometry(...
                vdVolumeDims,...
                obj.vdRowAxisUnitVector, obj.vdColumnAxisUnitVector,...
                obj.vdVoxelDimensions_mm,...
                vdMaskFirstVoxelPosition_mm,...
                varargin{:});
        end
        
        function vdVolumeCentrePosition_mm = GetVolumeCentrePosition_mm(obj)
            vdAlongRowUnitVector = obj.GetRowAxisUnitVector();
            vdAlongColUnitVector = obj.GetColumnAxisUnitVector();
            vdAlongSliceUnitVector = obj.GetSliceAxisUnitVector();
            
            vdVolumeDimensions = obj.vdVolumeDimensions;
            vdVoxelDimensions_mm = obj.vdVoxelDimensions_mm;
            vdFirstVoxelPosition_mm = obj.vdFirstVoxelPosition_mm;
            
            % the volume vertex coords by the first voxel position. This
            % position is given for the CENTRE of the voxel, so a shift of
            % half a voxel opposite to the unit vectors is needed
            vdVertexPosition_mm = vdFirstVoxelPosition_mm - 0.5.*(...
                vdAlongRowUnitVector .* vdVoxelDimensions_mm(1) +...
                vdAlongColUnitVector .* vdVoxelDimensions_mm(2) +...
                vdAlongSliceUnitVector .* vdVoxelDimensions_mm(3));
            
            % to get the centre, add half the volume dimensions from the
            % vertex
            
            vdVolumeCentrePosition_mm = vdVertexPosition_mm + 0.5 .* (...
                vdAlongRowUnitVector .* vdVolumeDimensions(1) .* vdVoxelDimensions_mm(1) + ...
                vdAlongColUnitVector .* vdVolumeDimensions(2) .* vdVoxelDimensions_mm(2) + ...
                vdAlongSliceUnitVector .* vdVolumeDimensions(3) .* vdVoxelDimensions_mm(3));
            
        end
        
        function oNewImageVolumeGeometry = ApplyRigidTransform(obj, m2dAffineTransformMatrix)
            arguments
                obj (1,1) ImageVolumeGeometry
                m2dAffineTransformMatrix (4,4) double
            end
            
            m2dAffineTransformMatrix = m2dAffineTransformMatrix;
            
            vdNewFirstVoxelPosition_mm = m2dAffineTransformMatrix * [obj.vdFirstVoxelPosition_mm' ; 1];
            
            m2dRotationMatrix = m2dAffineTransformMatrix(1:3,1:3);
            
            vdNewRowAxisUnitVector = m2dRotationMatrix * obj.vdRowAxisUnitVector';
            vdNewColumnAxisUnitVector = m2dRotationMatrix * obj.vdColumnAxisUnitVector';
            
            if isempty(obj.dAcquisitionDimension)
                varargin = {};
            else
                varargin = {...
                    obj.dAcquisitionDimension,...
                    obj.dAcquisitionSliceThickness_mm};
            end
            
            oNewImageVolumeGeometry = ImageVolumeGeometry(...
                obj.vdVolumeDimensions,...
                vdNewRowAxisUnitVector, vdNewColumnAxisUnitVector,...
                obj.vdVoxelDimensions_mm,...
                vdNewFirstVoxelPosition_mm(1:3),...
                varargin{:});
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj, dTabSpaces)
            arguments
                obj (1,1) ImageVolumeGeometry
                dTabSpaces (1,1) double {mustBeNonnegative, mustBeInteger} = 0
            end
            
            chTab = repmat(' ', 1, dTabSpaces);
            
            dTitleSize = 29;
            
            chIntegerLineFormat = [chTab, '%-', num2str(dTitleSize), 's', '%11i %11i %11i', newline];
            chFloatLineFormat = [chTab, '%-', num2str(dTitleSize), 's', '%11.6f %11.6f %11.6f', newline];
            
            vdVolumeDimensions = obj.GetVolumeDimensions();
            vdVoxelDimensions_mm = obj.GetVoxelDimensions_mm();
            vdFirstVoxelPosition_mm = obj.GetFirstVoxelPosition_mm();
            vdRowAxisUnitVector = obj.GetRowAxisUnitVector();
            vdColumnAxisUnitVector = obj.GetColumnAxisUnitVector();
            vdSliceAxisUnitVector = obj.GetSliceAxisUnitVector();
            
            fprintf(chIntegerLineFormat, 'Volume Dimensions:', vdVolumeDimensions(1), vdVolumeDimensions(2), vdVolumeDimensions(3));
            fprintf(chFloatLineFormat, 'Voxel Dimensions [mm]:', vdVoxelDimensions_mm(1), vdVoxelDimensions_mm(2), vdVoxelDimensions_mm(3));
            fprintf(chFloatLineFormat, 'Voxel (1,1,1) Position [mm]:', vdFirstVoxelPosition_mm(1), vdFirstVoxelPosition_mm(2), vdFirstVoxelPosition_mm(3));
            fprintf(chFloatLineFormat, 'Row Axis (i) Unit Vector:', vdRowAxisUnitVector(1), vdRowAxisUnitVector(2), vdRowAxisUnitVector(3));
            fprintf(chFloatLineFormat, 'Column Axis (j) Unit Vector:', vdColumnAxisUnitVector(1), vdColumnAxisUnitVector(2), vdColumnAxisUnitVector(3));
            fprintf(chFloatLineFormat, 'Slice Axis (k) Unit Vector:', vdSliceAxisUnitVector(1), vdSliceAxisUnitVector(2), vdSliceAxisUnitVector(3));
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function [m3xMatrix, oGeometryAfterTransform, vdVolumeDimensionReassignment] = ReassignFirstVoxel(obj, m3xMatrix, oTargetImageVolumeGeometry)
            m2dPossibleUnitVectors = [...
                1  0  0;...
                -1  0  0;...
                0  1  0;...
                0 -1  0;...
                0  0  1;...
                0  0 -1];
            
            vdRowUnitVector = obj.GetRowAxisUnitVector();
            vdColUnitVector = obj.GetColumnAxisUnitVector();
            
            vdRowNorms = vecnorm(m2dPossibleUnitVectors - vdRowUnitVector, 2, 2);
            vdColNorms = vecnorm(m2dPossibleUnitVectors - vdColUnitVector, 2, 2);
            
            [~,dMinRowIndex] = min(vdRowNorms);
            [~,dMinColIndex] = min(vdColNorms);
            
            vdClosestRowUnitVector = m2dPossibleUnitVectors(dMinRowIndex,:);
            vdClosestColUnitVector = m2dPossibleUnitVectors(dMinColIndex,:);
            
            oClosestAlignedImageVolumeGeometry = ImageVolumeGeometry(...
                obj.vdVolumeDimensions,...
                vdClosestRowUnitVector, vdClosestColUnitVector,...
                obj.vdVoxelDimensions_mm, obj.vdFirstVoxelPosition_mm);
            
            
            % the rotation matrix needed to align the current volume to
            % the target geometry
            m2dRequiredRotationMatrix = ImageVolumeGeometry.GetRotationMatrixBetweenGeometries(...
                oClosestAlignedImageVolumeGeometry, oTargetImageVolumeGeometry);
            
            % can only do flips of multiples of 90. These allows
            % "rotations" to be done by swapping of indices instead
            % of actual interpolation.
            
            vdRotationsAboutAxes_deg = ImageVolumeGeometry.GetEulerAnglesAboutArbitraryAxes(...
                m2dRequiredRotationMatrix, oClosestAlignedImageVolumeGeometry.GetRowAxisUnitVector(), oClosestAlignedImageVolumeGeometry.GetColumnAxisUnitVector());
            
            % this will "as close as possible", but without any
            % interpolation
            vdNum90DegreeFlipsAboutAxes = round(vdRotationsAboutAxes_deg./90);
            
            c1m2dEulerAngleRotationMatrices = {...
                ImageVolumeGeometry.GetRotationMatrixAboutArbitraryAxes(obj.GetRowAxisUnitVector(), 90*vdNum90DegreeFlipsAboutAxes(1)),...
                ImageVolumeGeometry.GetRotationMatrixAboutArbitraryAxes(obj.GetColumnAxisUnitVector(), 90*vdNum90DegreeFlipsAboutAxes(2)),...
                ImageVolumeGeometry.GetRotationMatrixAboutArbitraryAxes(obj.GetSliceAxisUnitVector(), 90*vdNum90DegreeFlipsAboutAxes(3))};
            
            oCurrentImageVolumeGeometry = obj;
            
            vdVolumeDimensions = obj.GetVolumeDimensions();
            
            vdVolumeDimensionLocations = 1:3;
            
            for dAngleIndex=1:3
                m2dRotationMatrix = c1m2dEulerAngleRotationMatrices{dAngleIndex};
                
                vdAxisAngle = rotm2axang(m2dRotationMatrix);
                
                vdAxis = vdAxisAngle(1:3);
                dNum90DegreeFlips = round(vdAxisAngle(4) ./ (pi/2));
                
                m2dUnitVectors = [...
                    oCurrentImageVolumeGeometry.GetRowAxisUnitVector();...
                    oCurrentImageVolumeGeometry.GetColumnAxisUnitVector();...
                    oCurrentImageVolumeGeometry.GetSliceAxisUnitVector()...
                    ];
                
                vdPosAxesUnitVectorsDifference = vecnorm(vdAxis - m2dUnitVectors, 2, 2);
                vdNegAxesUnitVectorsDifference = vecnorm(vdAxis - (-m2dUnitVectors), 2, 2);
                
                [dMinPos, dMinPosIndex] = min(vdPosAxesUnitVectorsDifference);
                [dMinNeg, dMinNegIndex] = min(vdNegAxesUnitVectorsDifference);
                
                if dMinPos < dMinNeg
                    dRotationDim = dMinPosIndex;
                else
                    dNum90DegreeFlips = -dNum90DegreeFlips;
                    dRotationDim = dMinNegIndex;
                end
                
                [m3xMatrix, vdNewDimensionLocation] = ImageVolumeGeometry.RotateMatrixBy90AboutDimension(m3xMatrix, dRotationDim, -dNum90DegreeFlips);
                vdVolumeDimensionLocations = vdVolumeDimensionLocations(vdNewDimensionLocation);
                
                oCurrentImageVolumeGeometry = ImageVolumeGeometry(...
                    [1 1 1],...
                    (m2dRotationMatrix*oCurrentImageVolumeGeometry.GetRowAxisUnitVector()')',...
                    (m2dRotationMatrix*oCurrentImageVolumeGeometry.GetColumnAxisUnitVector()')',...
                    [1 1 1],[0 0 0]);
            end
            
            % apply the same rotations to the geometry
            m2dRotationMatrix = ...
                ImageVolumeGeometry.GetRotationMatrixAboutArbitraryAxes(obj.GetSliceAxisUnitVector(), 90*vdNum90DegreeFlipsAboutAxes(3)) *...
                ImageVolumeGeometry.GetRotationMatrixAboutArbitraryAxes(obj.GetColumnAxisUnitVector(), 90*vdNum90DegreeFlipsAboutAxes(2)) *...
                ImageVolumeGeometry.GetRotationMatrixAboutArbitraryAxes(obj.GetRowAxisUnitVector(), 90*vdNum90DegreeFlipsAboutAxes(1));
            
            vdNewRowAxisUnitVector = (m2dRotationMatrix * obj.vdRowAxisUnitVector')';
            vdNewColumnAxisUnitVector = (m2dRotationMatrix * obj.vdColumnAxisUnitVector')';
            
            % Figure out first voxel
            % The way we do this is by having boolean flags that if true
            % mean that the last voxel in a given dimension is now the
            % first voxel, false means the first voxel in a dimension is
            % the first voxel. For each of the rotation directions, the
            % value of these flags can be found using boolean logic and
            % permutations (see the three for loops below)
            % Once the flags are knows, the indices of voxel (in the original
            % image volume geometry voxel indices) that is the new first
            % voxel can be found. The coordinates of this voxel can then be
            % found using the original image volume geometry. Voila!
            vbUseLastVolumeIndex = false(1,3);
            
            vdFirstVoxelIndexFlips = vdNum90DegreeFlipsAboutAxes;
            vdFirstVoxelIndexFlips(vdFirstVoxelIndexFlips < 0) = 4 + vdFirstVoxelIndexFlips(vdFirstVoxelIndexFlips < 0);
            
            for dRotIndex=1:vdFirstVoxelIndexFlips(1)
                vbUseLastVolumeIndex([3,2]) = vbUseLastVolumeIndex([2,3]);
                vbUseLastVolumeIndex(2) = ~vbUseLastVolumeIndex(2);
            end
            
            for dRotIndex=1:vdFirstVoxelIndexFlips(2)
                vbUseLastVolumeIndex([1,3]) = vbUseLastVolumeIndex([3,1]);
                vbUseLastVolumeIndex(3) = ~vbUseLastVolumeIndex(3);
            end
            
            for dRotIndex=1:vdFirstVoxelIndexFlips(3)
                vbUseLastVolumeIndex([2,1]) = vbUseLastVolumeIndex([1,2]);
                vbUseLastVolumeIndex(1) = ~vbUseLastVolumeIndex(1);
            end
            
            vdFirstVoxelIndices = [1 1 1];
            vdFirstVoxelIndices(vbUseLastVolumeIndex) = vdVolumeDimensions(vbUseLastVolumeIndex);
            
            [dX, dY, dZ] = obj.GetPositionCoordinatesFromVoxelIndices(vdFirstVoxelIndices(1), vdFirstVoxelIndices(2), vdFirstVoxelIndices(3));
            vdNewFirstVoxelPosition_mm = [dX, dY, dZ];
            
            % make new geometry object
            if ~isempty(obj.dAcquisitionDimension)
                c1xVarargin = {...
                    find(vdVolumeDimensionLocations == obj.dAcquisitionDimension),...
                    obj.dAcquisitionSliceThickness_mm};
            else
                c1xVarargin = {};
            end
            
            oGeometryAfterTransform = ImageVolumeGeometry(...
                obj.vdVolumeDimensions(vdVolumeDimensionLocations),...
                vdNewRowAxisUnitVector,...
                vdNewColumnAxisUnitVector,...
                obj.vdVoxelDimensions_mm(vdVolumeDimensionLocations),...
                vdNewFirstVoxelPosition_mm,...
                c1xVarargin{:});
            
            vdVolumeDimensionReassignment = vdVolumeDimensionLocations;
        end
        
        function oNewGeometry = AlignAndCentreToImageVolumeGeometry(obj, oReferenceObj)
            arguments
                obj
                oReferenceObj (1,1) {ValidationUtils.MustBeA(oReferenceObj, 'ImageVolumeGeometry')}
            end
            
            vdVolumeCentre_mm = oReferenceObj.GetVolumeCentrePosition_mm();
            
            vdRowAxisUnitVector = oReferenceObj.GetRowAxisUnitVector();
            vdColAxisUnitVector = oReferenceObj.GetColumnAxisUnitVector();
            vdSliceAxisUnitVector = oReferenceObj.GetSliceAxisUnitVector();
            
            [~, ~, vdVolumeDimensionReassignment] = obj.ReassignFirstVoxel([], oReferenceObj);
            
            vdVolumeDimensions = obj.vdVolumeDimensions(vdVolumeDimensionReassignment);
            vdVoxelDimensions_mm = obj.vdVoxelDimensions_mm(vdVolumeDimensionReassignment);
            
            % from the centre position, get the first voxel CORNER position
            % (NOT the first voxel position, which is the centre of the
            % first voxel)
            vdFirstCornerPosition_mm = vdVolumeCentre_mm - 0.5.*(...
                vdRowAxisUnitVector .* vdVolumeDimensions(1) .*  vdVoxelDimensions_mm(1) +...
                vdColAxisUnitVector .* vdVolumeDimensions(2) .* vdVoxelDimensions_mm(2) +...
                vdSliceAxisUnitVector .* vdVolumeDimensions(3) .* vdVoxelDimensions_mm(3));
            
            % from the first voxel CORNER position, the centre is found by
            % shifting half a voxel over
            vdFirstVoxelPosition_mm = vdFirstCornerPosition_mm + 0.5.*(...
                vdRowAxisUnitVector .* vdVoxelDimensions_mm(1) +...
                vdColAxisUnitVector .* vdVoxelDimensions_mm(2) +...
                vdSliceAxisUnitVector .* vdVoxelDimensions_mm(3));          
                         
            % get new geometry
            oNewGeometry = ImageVolumeGeometry(...
                vdVolumeDimensions,...
                vdRowAxisUnitVector, vdColAxisUnitVector,...
                vdVoxelDimensions_mm,...
                vdFirstVoxelPosition_mm);
        end
        
        function oNewGeometry = GetMatchedImageVolumeGeometryWithIsotropicVoxels(obj, dNewVoxelSize_mm)
            arguments
                obj
                dNewVoxelSize_mm (1,1) double {mustBePositive, mustBeFinite}
            end
            
            oNewGeometry = obj.GetMatchedImageVolumeGeometryWithCustomVoxelDimensions(repmat(dNewVoxelSize_mm, 1, 3));
        end
        
        function oNewGeometry = GetMatchedImageVolumeGeometryWithCustomVoxelDimensions(obj, vdNewVoxelDimensions_mm)
            arguments
                obj
                vdNewVoxelDimensions_mm (1,3) double {mustBePositive, mustBeFinite}
            end
            
            % the parameters for the new geometry will be as follows:
            % - same row/col/slice axis unit vectors (unchanged
            %   orientation)
            % - voxel dimensions will be changed to the new voxel
            %   dimensions
            % - the CENTRE of the volume will REMAIN AT THE SAME LOCATION
            % - the TOTAL DIMENSIONS of the volume will attempt to be kept
            %   constant. If they cannot be due to a total dimension not
            %   being evenly divisible by a new voxel dimension, the size
            %   of that dimension will be slightly larger (e.g. number of
            %   voxels will be rounded up)
            % - Due to the change of the voxel dimensions AND potentially
            %   the total dimensions, the first voxel location WILL MOST
            %   LIKELY CHANGE. This is because the first voxel location
            %   gives the coordinates of the CENTRE of the first voxel, not
            %   a corner of the total volume.
            % - The acquisition dimension/slice thickness (if set) will
            %   remain unchanged
            
            % calculate the number of voxels in each dimension and new
            % first voxel position
            vdVolumeCentre_mm = obj.GetVolumeCentrePosition_mm();
            vdVolumeDimensions_mm = obj.GetVolumeDimensions_mm();
            
            vdNumVoxelsPerDimension = ceil(round(vdVolumeDimensions_mm ./ vdNewVoxelDimensions_mm,3)); % use ceil such that the whole volume is always encompassed by the new volume (round(X,3) used to trim of any tiny rounding errors that shouldn't result in a whole voxel being slapped on)
            vdNumVoxelsFromCentreToFirstVoxel = (vdNumVoxelsPerDimension ./ 2) - 0.5;
            
            vdRowAxesUnitVector = obj.GetRowAxisUnitVector();
            vdColAxesUnitVector = obj.GetColumnAxisUnitVector();
            vdSliceAxesUnitVector = obj.GetSliceAxisUnitVector();
            
            vdNewFirstVoxelPosition_mm = vdVolumeCentre_mm ...
                - vdRowAxesUnitVector .* vdNewVoxelDimensions_mm(1) .* vdNumVoxelsFromCentreToFirstVoxel(1)...
                - vdColAxesUnitVector .* vdNewVoxelDimensions_mm(2) .* vdNumVoxelsFromCentreToFirstVoxel(2)...
                - vdSliceAxesUnitVector .* vdNewVoxelDimensions_mm(3) .* vdNumVoxelsFromCentreToFirstVoxel(3);
            
            % transfer acquisition dimension and slice thickness if needed
            if ~isempty(obj.dAcquisitionDimension)
                c1oOptionalParams = {obj.dAcquisitionDimension, obj.dAcquisitionSliceThickness_mm};
            else
                c1oOptionalParams = {};
            end
            
            % get new geometry
            oNewGeometry = ImageVolumeGeometry(...
                vdNumVoxelsPerDimension,...
                vdRowAxesUnitVector, vdColAxesUnitVector,...
                vdNewVoxelDimensions_mm,...
                vdNewFirstVoxelPosition_mm,...
                c1oOptionalParams{:});
        end
        
        function [vdX_mm, vdY_mm, vdZ_mm] = GetPositionCoordinatesFromVoxelIndices(obj, vdRow, vdColumn, vdSlice)
            vdRowAxisUnitVector = obj.GetRowAxisUnitVector();
            vdColAxisUnitVector = obj.GetColumnAxisUnitVector();
            vdSliceAxisUnitVector = obj.GetSliceAxisUnitVector();
            
            vdVoxelDimensions_mm = obj.GetVoxelDimensions_mm();
            vdFirstVoxelPosition_mm = obj.GetFirstVoxelPosition_mm();
            
            vdX_mm = vdFirstVoxelPosition_mm(1) + ...
                (vdRow-1) .* vdRowAxisUnitVector(1) .* vdVoxelDimensions_mm(1) + ...
                (vdColumn-1) .* vdColAxisUnitVector(1) .* vdVoxelDimensions_mm(2) + ...
                (vdSlice-1) .* vdSliceAxisUnitVector(1) .* vdVoxelDimensions_mm(3);
            
            vdY_mm = vdFirstVoxelPosition_mm(2) + ...
                (vdRow-1) .* vdRowAxisUnitVector(2) .* vdVoxelDimensions_mm(1) + ...
                (vdColumn-1) .* vdColAxisUnitVector(2) .* vdVoxelDimensions_mm(2) + ...
                (vdSlice-1) .* vdSliceAxisUnitVector(2) .* vdVoxelDimensions_mm(3);
            
            vdZ_mm = vdFirstVoxelPosition_mm(3) + ...
                (vdRow-1) .* vdRowAxisUnitVector(3) .* vdVoxelDimensions_mm(1) + ...
                (vdColumn-1) .* vdColAxisUnitVector(3) .* vdVoxelDimensions_mm(2) + ...
                (vdSlice-1) .* vdSliceAxisUnitVector(3) .* vdVoxelDimensions_mm(3);
        end
        
        function [vdRow, vdColumn, vdSlice] = GetVoxelIndicesFromPositionCoordinates(obj, vdX_mm, vdY_mm, vdZ_mm)
            vdRowAxisUnitVector = obj.GetRowAxisUnitVector();
            vdColAxisUnitVector = obj.GetColumnAxisUnitVector();
            vdSliceAxisUnitVector = obj.GetSliceAxisUnitVector();
            
            vdVoxelDimensions_mm = obj.GetVoxelDimensions_mm();
            vdFirstVoxelPosition_mm = obj.GetFirstVoxelPosition_mm();
            
            vdRow = 1 + (...
                vdRowAxisUnitVector(1) .* (vdX_mm - vdFirstVoxelPosition_mm(1)) + ...
                vdRowAxisUnitVector(2) .* (vdY_mm - vdFirstVoxelPosition_mm(2)) + ...
                vdRowAxisUnitVector(3) .* (vdZ_mm - vdFirstVoxelPosition_mm(3)))...
                ./ vdVoxelDimensions_mm(1);
            
            vdColumn = 1 + (...
                vdColAxisUnitVector(1) .* (vdX_mm - vdFirstVoxelPosition_mm(1)) + ...
                vdColAxisUnitVector(2) .* (vdY_mm - vdFirstVoxelPosition_mm(2)) + ...
                vdColAxisUnitVector(3) .* (vdZ_mm - vdFirstVoxelPosition_mm(3)))...
                ./ vdVoxelDimensions_mm(2);
            
            vdSlice = 1 + (...
                vdSliceAxisUnitVector(1) .* (vdX_mm - vdFirstVoxelPosition_mm(1)) + ...
                vdSliceAxisUnitVector(2) .* (vdY_mm - vdFirstVoxelPosition_mm(2)) + ...
                vdSliceAxisUnitVector(3) .* (vdZ_mm - vdFirstVoxelPosition_mm(3)))...
                ./ vdVoxelDimensions_mm(3);
        end
        
        function [m3dX_mm, m3dY_mm, m3dZ_mm] = GetVoxelCentrePositionMeshGrids(obj)
            vdRowIndices = 1 : 1 : obj.vdVolumeDimensions(1);
            vdColIndices = 1 : 1 : obj.vdVolumeDimensions(2);
            vdSliceIndices = 1 : 1 : obj.vdVolumeDimensions(3);
            
            [m3dColMeshGrid, m3dRowMeshGrid, m3dSliceMeshGrid] = meshgrid(...
                vdColIndices, vdRowIndices, vdSliceIndices);
            
            [m3dX_mm, m3dY_mm, m3dZ_mm] = obj.GetPositionCoordinatesFromVoxelIndices(...
                m3dRowMeshGrid, m3dColMeshGrid, m3dSliceMeshGrid);
        end
        
        function dThroughPlaneDimension = GetThroughPlaneDimensionForMaskLevelSetInterpolation(obj)
            % Multiple cases depending on voxel dimensions:
            % 1) All dimensions are different: Error; cannot determine
            % 2) All dimensions are EXACTLY equal: Error; cannot determine
            % 3) All dimensions are within 0.01mm: Error; cannot determine
            % 4) Two dimensions are EXACTLY equal, 3rd is less than other two: Error; cannot determine
            % 5) Two dimensions are EXACTLY equal, 3rd is more than 1/100mm than other two: 3rd dimension index will be returned
            %
            % *NOTE* If acquisition dimension is not empty and case 5)
            % occurs must is different than the acquisition dimension, a
            % warning will be triggered
            
            dEqualityLimit_mm = 0.01;
            
            vdVoxelDimensions_mm = obj.GetVoxelDimensions_mm();
            
            dMinDim_mm = min(vdVoxelDimensions_mm);
            dMaxDim_mm = max(vdVoxelDimensions_mm);
            
            if dMaxDim_mm - dMinDim_mm <= dEqualityLimit_mm % Case 2) & 3)
                error(...
                    'ImageVolumeGeometry:GetThroughPlaneDimensionForMaskLevelSetInterpolation:IsotropicVoxelsFound',...
                    'Isotropic voxels were found, so no through plane dimension was found. Either manually set a level set interpolation dimension or use 3D interpolation instead of level set interpolation.');
            else
                dNumDims = length(vdVoxelDimensions_mm);
                
                dNumIndexRepeats = zeros(1,dNumDims);
                
                for dDimIndex=1:dNumDims
                    dNumRepeats = 0;
                    
                    for dSearchIndex=1:dNumDims
                        dNumRepeats = dNumRepeats + ( vdVoxelDimensions_mm(dDimIndex) == vdVoxelDimensions_mm(dSearchIndex) );
                    end
                    
                    dNumIndexRepeats(dDimIndex) = dNumRepeats;
                end
                
                dNumSingles = sum(dNumIndexRepeats == 1);
                
                if dNumSingles ~= 1 % Case 1)
                    error(...
                        'ImageVolumeGeometry:GetThroughPlaneDimensionForMaskLevelSetInterpolation:AnisotropicVoxelsFound',...
                        'Cannot automatically determine the through plane direction because no voxel dimensions were equal. Two voxel dimensions must be exactly equal for the through plane dimension to be determined.');
                else
                    dThroughPlaneDimension = find(dNumIndexRepeats == 1);
                    vdInPlaneDimensions = find(dNumIndexRepeats ~= 1);
                    
                    if vdVoxelDimensions_mm(dThroughPlaneDimension) < vdVoxelDimensions_mm(vdInPlaneDimensions(1)) % Case 4)
                        error(...
                            'ImageVolumeGeometry:GetThroughPlaneDimensionForMaskLevelSetInterpolation:AnisotropicVoxelsFound',...
                            'Cannot automatically determine the through plane direction because it must have a voxel dimension larger than the two voxel dimensions that are equal.');
                    else % Case 5)
                        % dThroughPlaneDimension is already set
                    end
                end
            end
        end
        
        function m3dInterpolatedScalarData = InterpolateScalarDataMatrixOntoTargetGeometry(obj, m3xScalarData, oTargetImageVolumeGeometry, chInterpolationMethod, dExtrapolationValue)
            % m3dInterpolatedImageData = InterpolateScalarDataMatrixOntoTargetGeometry(obj, m3xScalarData, oTargetImageVolumeGeometry, chInterpolationMethod, dExtrapolationValue)
            %
            % SYNTAX:
            %  m3dInterpolatedImageData = obj.InterpolateScalarDataMatrixOntoTargetGeometry(m3xScalarData, oTargetImageVolumeGeometry, chInterpolationMethod, dExtrapolationValue)
            %
            % DESCRIPTION:
            %  This function takes a scalar data matrix for which the
            %  ImageVolumeGeometry describes and interpolates it onto the
            %  provided target ImageVolumeGeometry, using the interpolation
            %  method and extrapolation value given by the user.
            %
            % INPUT ARGUMENTS:
            %  obj:
            %   An ImageVolumeGeometry object describing the current
            %   geometry of m3xScalarData
            %  m3xScalarData:
            %   A 3D matrix of an numerical type. This data will be
            %   interpolated onto the target geometry. NOTE that this data
            %   will be cast to of type double before it is interpolated.
            %   Therefore integer values beyond 2^53 may lose precision
            %   (based on the IEEE double specification).
            %  oTargetImageVolumeGeometry:
            %   An ImageVolumeGeometry object with an position, orientation,
            %   or voxel spacing, onto which m3xScalarData will be
            %   interpolated onto.
            %  chInterpolationMethod:
            %   The 3D interpolation method to be used to perform the
            %   interpolation. Any of the methods listed in the
            %   documentation of the Matlab "interp3" function may be
            %   provided.
            %  dExtrapolationValue:
            %   A scalar, finite value of type double that be placed into
            %   any voxels of the interpolated data that lie outside of the
            %   bounds of the original data matrix
            %
            % OUTPUT ARGUMENTS:
            %  m3dInterpolatedScalarData:
            %   A 3D matrix of doubles holding the interpolated values that
            %   now correspond to the geometry specified in
            %   oTargetImageVolumeGeometry. This matrix is of type double
            %   in order to preserve all of the precision during
            %   interpolation. It may be cast to other numerical data types
            %   if required by the user.
            
            arguments
                obj (1,1) {ValidationUtils.MustBeA(obj, 'ImageVolumeGeometry')}
                m3xScalarData (:,:,:) {mustBeFinite, mustBeReal, ValidationUtils.MustBeNumericOrLogical}
                oTargetImageVolumeGeometry (1,1) {ValidationUtils.MustBeA(oTargetImageVolumeGeometry, 'ImageVolumeGeometry')}
                chInterpolationMethod (1,:) char
                dExtrapolationValue (1,1) double {mustBeFinite, mustBeReal}
            end
            
            
            % 1) Imagine that our current data is actually perfectly
            % aligned with a geometry that:
            %   - has the first voxel at (0,0,0)
            %   - has row axis unit vector along (1,0,0) and col axis unit
            %     vector along (0,1,0)
            %  the volume size and voxel spacing carries over though.
            % This will allow for it's voxel coords to be easily specified
            % as an axis aligned, monotonically increasing data set
            % (essential for working with Matlab's interp3 functions)
            
            oAxisAlignedGeometry = ImageVolumeGeometry(...
                obj.vdVolumeDimensions,...
                [1 0 0], [0 1 0],...
                obj.vdVoxelDimensions_mm, [0 0 0]);
            
            % 2) Figure out the transform needed to get the current
            % geometry aligned with this ideal geometry
            
            [m2dCurrentToAlignedRotationMatrix, vdCurrentToAlignedTranslationVector] = ImageVolumeGeometry.GetRotationMatrixAndTranslationVectorBetweenGeometries(obj, oAxisAlignedGeometry);
                        
            % 3) Get the required voxel coords from the target geometry and
            % perform the transform from 2) to get voxel coords with
            % respect to the image volume in the axis aligned ideal
            % geometry
            
            % using rotation matrices/translation vectors to perform
            % transformation:
            vdInterpolationRowAxisUnitVector = (m2dCurrentToAlignedRotationMatrix * oTargetImageVolumeGeometry.vdRowAxisUnitVector')';
            vdInterpolationColAxisUnitVector = (m2dCurrentToAlignedRotationMatrix * oTargetImageVolumeGeometry.vdColumnAxisUnitVector')';
            vdInterpolationFirstVoxelPosition_mm = (m2dCurrentToAlignedRotationMatrix*(oTargetImageVolumeGeometry.vdFirstVoxelPosition_mm)')' + vdCurrentToAlignedTranslationVector;
            
            oInterpolationGeometry = ImageVolumeGeometry(...
                oTargetImageVolumeGeometry.vdVolumeDimensions,...
                vdInterpolationRowAxisUnitVector, vdInterpolationColAxisUnitVector,...
                oTargetImageVolumeGeometry.vdVoxelDimensions_mm, vdInterpolationFirstVoxelPosition_mm);
            
            % 4) Perform the interpolation
            
            % make a copy of the data that is both padded with the
            % edge voxel values and is of type double (as per the
            % griddedInterpolant function's request)
            m3dDataToInterp = padarray(double(m3xScalarData), [1 1 1], 'symmetric', 'both');
            
            % Make a MATLAB interpolating function with
            % defined grid based on the voxel centres, along with the
            % outer voxel edges (this matches 3DSlicer's approach)
            hInterpolatingFn = griddedInterpolant(...
                {...
                ([-0.5, 0 : 1 : oAxisAlignedGeometry.vdVolumeDimensions(1)-1, oAxisAlignedGeometry.vdVolumeDimensions(1)-0.5]) * oAxisAlignedGeometry.vdVoxelDimensions_mm(1),...
                ([-0.5, 0 : 1 : oAxisAlignedGeometry.vdVolumeDimensions(2)-1, oAxisAlignedGeometry.vdVolumeDimensions(2)-0.5]) * oAxisAlignedGeometry.vdVoxelDimensions_mm(2),...
                ([-0.5, 0 : 1 : oAxisAlignedGeometry.vdVolumeDimensions(3)-1, oAxisAlignedGeometry.vdVolumeDimensions(3)-0.5]) * oAxisAlignedGeometry.vdVoxelDimensions_mm(3)...
                },...
                m3dDataToInterp,...
                chInterpolationMethod,...
                'none'); % 'none' means no extrapoltion beyond the image bounds. NaN's fill be put there for now.
            
            % perform the interpolation
            [m3dTargetX_mm, m3dTargetY_mm, m3dTargetZ_mm] = oInterpolationGeometry.GetVoxelCentrePositionMeshGrids();
            
            m3dInterpolatedScalarData = hInterpolatingFn(m3dTargetX_mm, m3dTargetY_mm, m3dTargetZ_mm);
            
            % values the are beyond the image bounds are NaN, so set them
            % to the provided extrapolation value
            m3dInterpolatedScalarData(isnan(m3dInterpolatedScalarData)) = dExtrapolationValue;
        end
        
        function m3bInterpMask = InterpolateMaskMatrixOntoTargetImageVolumeGeometry(obj, m3bMask, oTargetImageVolumeGeometry, chInterpolationType, varargin)
            arguments
                obj
                m3bMask (:,:,:) logical
                oTargetImageVolumeGeometry (1,1) {ValidationUtils.MustBeA(oTargetImageVolumeGeometry,'ImageVolumeGeometry')}
                chInterpolationType (1,:) char {mustBeMember(chInterpolationType, {'interpolate3D','levelsets'})}
            end
            arguments (Repeating)
                varargin
            end
            
            % m3bInterpMask = obj.InterpolateMaskMatrixOntoTargetImageVolumeGeometry(m3bMask, oTargetImageVolumeGeometry, 'interpolate3D', chMethod)
            % m3bInterpMask = obj.InterpolateMaskMatrixOntoTargetImageVolumeGeometry(m3bMask, oTargetImageVolumeGeometry, 'levelsets', chInSliceInterpolationMethod, chThroughSliceInterpolationMethod, dThroughPlaneSliceDimension)
            % m3bInterpMask = obj.InterpolateMaskMatrixOntoTargetImageVolumeGeometry(m3bMask, oTargetImageVolumeGeometry, 'levelsets', chInSliceInterpolationMethod, chThroughSliceInterpolationMethod, dThroughPlaneSliceDimension, voClosedPlanarPolygons)
            
            if strcmp(chInterpolationType, 'interpolate3D')
                % Validate inputs
                ValidationUtils.MustBeA(varargin, 'cell');
                ValidationUtils.MustBeOfSize(varargin, [1 1]);
                
                chMethod = char(varargin{1});
                
                ValidationUtils.MustBeA(chMethod, 'char');
                ValidationUtils.MustBeRowVector(chMethod);
                
                % use scalar data (e.g. image data) interpolater
                dExtrapolationValue = 0; % e.g. false
                
                m3bInterpMask = obj.InterpolateScalarDataMatrixOntoTargetGeometry(...
                    m3bMask, oTargetImageVolumeGeometry,...
                    chMethod, dExtrapolationValue);
                
                % convert back to mask based on 0.5 cut-off
                m3bInterpMask = m3bInterpMask >= 0.5;
            else % 'levelsets'
                % Validate inputs
                bPolygonsAvailable = false;
                
                if length(varargin) >= 3
                    chInSliceInterpolationMethod = char(varargin{1});
                    chThroughSliceInterpolationMethod = char(varargin{2});
                    dThroughPlaneSliceDimension = double(varargin{3});
                    
                    ValidationUtils.MustBeA(chInSliceInterpolationMethod, 'char');
                    ValidationUtils.MustBeRowVector(chInSliceInterpolationMethod);
                    
                    ValidationUtils.MustBeA(chThroughSliceInterpolationMethod, 'char');
                    ValidationUtils.MustBeRowVector(chThroughSliceInterpolationMethod);
                    
                    ValidationUtils.MustBeA(dThroughPlaneSliceDimension, 'double');
                    mustBeMember(dThroughPlaneSliceDimension, [1,2,3]);
                end
                
                if length(varargin) == 3
                    % nothing special
                else
                    ValidationUtils.MustBeOfSize(varargin,[1,4]);
                    
                    voClosedPlanarPolygons = varargin{4};
                    
                    ValidationUtils.MustBeA(voClosedPlanarPolygons, 'ClosedPlanarPolygon');
                    ValidationUtils.MustBeColumnVector(voClosedPlanarPolygons);
                    
                    voClosedPlanarPolygons = copy(voClosedPlanarPolygons);
                    
                    bPolygonsAvailable = true;
                end
                
                % perform level set interpolation
                vdCurrentRowUnitVector = obj.GetRowAxisUnitVector();
                vdCurrentColUnitVector = obj.GetColumnAxisUnitVector();
                
                vdTargetRowUnitVector = oTargetImageVolumeGeometry.GetRowAxisUnitVector();
                vdTargetColUnitVector = oTargetImageVolumeGeometry.GetColumnAxisUnitVector();
                
                if any(vdCurrentRowUnitVector ~= vdTargetRowUnitVector) || any(vdCurrentColUnitVector ~= vdTargetColUnitVector)
                    error(...
                        'ImageVolumeGeometry:InterpolateMaskMatrixOntoTargetImageVolumeGeometry:InvalidRotation',...
                        'When performing level set interpolation, the volume cannot be rotated, only voxel/volume dimensions can be altered.');
                end
                
                
                % IF polygons are available:
                % 1 - Use polygons to make masks at TARGET resolution for
                %     each slice position the polygons were in
                % 2 - Make level sets for each of these masks
                % 3 - Use 1D interpolation to make full volume
                
                if bPolygonsAvailable
                    % pre-allocate level sets
                    dNumPolygons = length(voClosedPlanarPolygons);
                    
                    if dNumPolygons == 0
                        m3bInterpMask = false(oTargetImageVolumeGeometry.GetVolumeDimensions());
                    else
                        vdPolygonSlices = zeros(1,dNumPolygons);
                        vdPolygonSliceDimensions = zeros(1,dNumPolygons);
                        
                        for dPolygonIndex=1:dNumPolygons
                            vdPolygonSlices(dPolygonIndex) = voClosedPlanarPolygons(dPolygonIndex).GetImageVolumePlaneIndex();
                            vdPolygonSliceDimensions(dPolygonIndex) = voClosedPlanarPolygons(dPolygonIndex).GetImageVolumePlaneDimension();
                        end
                        
                        if ~all(vdPolygonSliceDimensions == vdPolygonSliceDimensions(1))
                            error('All polygons must be in the same slice dimension');
                        else
                            dContourPolygonsSliceDimension = vdPolygonSliceDimensions(1);
                        end
                        
                        vdPolygonSlices = round(vdPolygonSlices);
                        
                        [vdCurrentSlices,~,vdSliceNumberToPolygonIndices] = unique(vdPolygonSlices);
                        
                        dLowerBound = vdCurrentSlices(1);
                        dUpperBound = vdCurrentSlices(end);
                        
                        vdSliceSelectDimensions = 1:3;
                        vdSliceSelectDimensions(dContourPolygonsSliceDimension) = [];
                        
                        vdTargetVolumeDimensions = oTargetImageVolumeGeometry.GetVolumeDimensions();
                        
                        dNumRowsPerSlice = vdTargetVolumeDimensions(vdSliceSelectDimensions(1));
                        dNumColumnsPerSlice = vdTargetVolumeDimensions(vdSliceSelectDimensions(2));
                        
                        dNumLevelSetSlices = (dUpperBound - dLowerBound + 1) + 2;
                        
                        m3dLevelSets = zeros(dNumRowsPerSlice, dNumColumnsPerSlice, dNumLevelSetSlices);
                        vbLevelSetHasNoPolygons = true(dNumLevelSetSlices,1);
                        
                        vbLevelSetHasNoPolygons((vdCurrentSlices - dLowerBound + 1) + 1) = false;
                        
                        vdNewImageVolumeGeometryLevelSetSliceNumbers = zeros(dNumLevelSetSlices,1);
                        
                        % set level sets, slice by slice
                        for dPolygonIndex=1:dNumPolygons
                            voClosedPlanarPolygons(dPolygonIndex).ApplyNewVoxelResolution(oTargetImageVolumeGeometry);
                        end
                        
                        dPolygonSliceIndex = 1;
                        
                        for dLevelSetSlice=1:dNumLevelSetSlices
                            if ~vbLevelSetHasNoPolygons(dLevelSetSlice)
                                % make mask
                                m2bMaskSlice = false(dNumRowsPerSlice, dNumColumnsPerSlice);
                                
                                voClosedPlanarPolygonsForMask = voClosedPlanarPolygons(vdSliceNumberToPolygonIndices == dPolygonSliceIndex);
                                vdPolygonsForMaskSliceIndices = zeros(length(voClosedPlanarPolygonsForMask),1);
                                
                                for dPolygonToAddIndex=1:length(voClosedPlanarPolygonsForMask)
                                    m2bMaskSlice = voClosedPlanarPolygonsForMask(dPolygonToAddIndex).AddToSliceMask(m2bMaskSlice);
                                    vdPolygonsForMaskSliceIndices(dPolygonToAddIndex) = voClosedPlanarPolygonsForMask(dPolygonToAddIndex).GetImageVolumePlaneIndex();
                                end
                                
                                % make levelset
                                m3dLevelSets(:,:,dLevelSetSlice) = bwdist(~m2bMaskSlice) - bwdist(m2bMaskSlice);
                                
                                % find where this slice is within new image
                                % volume geometry
                                dNewGeometrySliceNumber = mean(vdPolygonsForMaskSliceIndices);
                                vdNewImageVolumeGeometryLevelSetSliceNumbers(dLevelSetSlice) = dNewGeometrySliceNumber;
                                
                                % increase polygon slice counter
                                dPolygonSliceIndex = dPolygonSliceIndex + 1;
                            else
                                dCurrentGeometrySliceNumber = dLowerBound + dLevelSetSlice - 2;
                                
                                vdVoxelIndices = ones(1,3);
                                vdVoxelIndices(dContourPolygonsSliceDimension) = dCurrentGeometrySliceNumber;
                                
                                [dX_mm, dY_mm, dZ_mm] = obj.GetPositionCoordinatesFromVoxelIndices(vdVoxelIndices(1), vdVoxelIndices(2), vdVoxelIndices(3));
                                [dRow, dCol, dSlice] = oTargetImageVolumeGeometry.GetVoxelIndicesFromPositionCoordinates(dX_mm, dY_mm, dZ_mm);
                                vdNewGeometryVoxelIndices = [dRow, dCol, dSlice];
                                
                                vdNewImageVolumeGeometryLevelSetSliceNumbers(dLevelSetSlice) = vdNewGeometryVoxelIndices(dContourPolygonsSliceDimension);
                            end
                        end
                        
                        % for level sets that are representing "empty" slices,
                        % set to the minimum value
                        
                        dMinLevelSetValue = min(m3dLevelSets(:));
                        
                        for dLevelSetSlice=1:dNumLevelSetSlices
                            if vbLevelSetHasNoPolygons(dLevelSetSlice)
                                m3dLevelSets(:,:,dLevelSetSlice) = dMinLevelSetValue;
                            end
                        end
                        
                        % construct mask using the levels
                        vdVolumeDimensions = oTargetImageVolumeGeometry.GetVolumeDimensions();
                        m3bInterpMask = false(vdVolumeDimensions);
                        
                        vdInterpSliceValues = 1:vdVolumeDimensions(dContourPolygonsSliceDimension);
                        
                        for dCol=1:dNumColumnsPerSlice
                            for dRow=1:dNumRowsPerSlice
                                vbInterpMaskVector = ( 0 <= interp1(...
                                    vdNewImageVolumeGeometryLevelSetSliceNumbers,...
                                    squeeze(m3dLevelSets(dRow,dCol,:)),...
                                    vdInterpSliceValues,...
                                    chThroughSliceInterpolationMethod, -Inf) );
                                
                                switch dContourPolygonsSliceDimension
                                    case 1
                                        m3bInterpMask(:,dRow,dCol) = squeeze(m3bInterpMask(:,dRow,dCol)) | vbInterpMaskVector';
                                    case 2
                                        m3bInterpMask(dRow,:,dCol) = squeeze(m3bInterpMask(dRow,:,dCol))' | vbInterpMaskVector';                                        
                                    case 3
                                        m3bInterpMask(dRow,dCol,:) = squeeze(m3bInterpMask(dRow,dCol,:)) | vbInterpMaskVector';
                                end
                            end
                        end
                    end
                    
                else % FOR NO POLYGONS
                    
                    
                    % find the contour slice bounds
                    dLowerBound = 1;
                    
                    for dContourDimIndex=1:size(m3bMask, dThroughPlaneSliceDimension)
                        switch dThroughPlaneSliceDimension
                            case 1
                                m2bMaskSlice = squeeze(m3bMask(dContourDimIndex,:,:));
                            case 2
                                m2bMaskSlice = squeeze(m3bMask(:,dContourDimIndex,:));
                            case 3
                                m2bMaskSlice = squeeze(m3bMask(:,:,dContourDimIndex));
                        end
                        
                        if any(m2bMaskSlice(:))
                            dLowerBound = dContourDimIndex;
                            break;
                        end
                    end
                    
                    dUpperBound = size(m3bMask, dThroughPlaneSliceDimension);
                    
                    for dContourDimIndex=size(m3bMask, dThroughPlaneSliceDimension):-1:1
                        switch dThroughPlaneSliceDimension
                            case 1
                                m2bMaskSlice = squeeze(m3bMask(dContourDimIndex,:,:));
                            case 2
                                m2bMaskSlice = squeeze(m3bMask(:,dContourDimIndex,:));
                            case 3
                                m2bMaskSlice = squeeze(m3bMask(:,:,dContourDimIndex));
                        end
                        
                        if any(m2bMaskSlice(:))
                            dUpperBound = dContourDimIndex;
                            break;
                        end
                    end
                    
                    if dLowerBound == 1 || dUpperBound == size(m3bMask, dThroughPlaneSliceDimension)
                        error('What to do here?');
                    end
                    
                    % create level sets for each known slice within the bounds
                    % (e.g. for slices where there are true values)
                    dNumLevelSetSlices = dUpperBound - dLowerBound + 1;
                    
                    vdCurrentVolumeDimensions = obj.GetVolumeDimensions();
                    
                    vdLevelSetDimensions = vdCurrentVolumeDimensions;
                    vdLevelSetDimensions(dThroughPlaneSliceDimension) = [];
                    
                    m3dLevelSets = zeros([vdLevelSetDimensions, dNumLevelSetSlices + 2]); % this will store the slices in the contouring plane as slices in this matrix, add 2 to pad the ROI "true" values with one row of all "false" values
                    
                    vbIsEmptySlice = false(dNumLevelSetSlices + 2,1);
                    vbIsEmptySlice(1) = true;
                    vbIsEmptySlice(end) = true;
                    
                    for dLevelSetIndex=1:dNumLevelSetSlices
                        dMaskSliceIndex = dLowerBound + dLevelSetIndex - 1;
                        
                        switch dThroughPlaneSliceDimension
                            case 1
                                m2bMaskSlice = squeeze(m3bMask(dMaskSliceIndex,:,:));
                            case 2
                                m2bMaskSlice = squeeze(m3bMask(:,dMaskSliceIndex,:));
                            case 3
                                m2bMaskSlice = m3bMask(:,:,dMaskSliceIndex);
                        end
                        
                        if any(m2bMaskSlice(:))
                            m3dLevelSets(:,:,dLevelSetIndex+1) = bwdist(~m2bMaskSlice) - bwdist(m2bMaskSlice);
                        else % no true values, set to zeros
                            m3dLevelSets(:,:,dLevelSetIndex+1) = 0;
                            vbIsEmptySlice(dLevelSetIndex+1) = true;
                        end
                    end
                    
                    % in the bottom and top-most slices (and any empty slices between slices with "true" values) set to be equal to most
                    % negative value from the level sets
                    dMinValue = min(m3dLevelSets(:));
                    
                    for dLevelSetIndex=1:dNumLevelSetSlices + 2
                        if vbIsEmptySlice(dLevelSetIndex)
                            m3dLevelSets(:,:,dLevelSetIndex) = dMinValue;
                        end
                    end
                    
                    % figure out the coordinates were interpolating from and into
                    
                    vdCurrentVoxelDimensions_mm = obj.GetVoxelDimensions_mm();
                    vdCurrentFirstVoxelPosition_mm = obj.GetFirstVoxelPosition_mm();
                    
                    vdTargetVolumeDimensions = oTargetImageVolumeGeometry.GetVolumeDimensions();
                    vdTargetVoxelDimensions_mm = oTargetImageVolumeGeometry.GetVoxelDimensions_mm();
                    vdTargetFirstVoxelPosition_mm = oTargetImageVolumeGeometry.GetFirstVoxelPosition_mm();
                    
                    % Since we know that the volumes are aligned (e.g. row, col,
                    % and slice axis unit vectors are equal), we'll imagine that
                    % we're in a coordinate system where the current volume first
                    % voxel is at (0,0,0) and it's row, col, slice unit vectors are
                    % axis aligned.
                    % The current voxel centres are therefore at:
                    vdUnmatchedCurrentVoxelRowPositions_mm = 0:vdCurrentVoxelDimensions_mm(1):(vdCurrentVolumeDimensions(1)-1) * vdCurrentVoxelDimensions_mm(1);
                    vdUnmatchedCurrentVoxelColPositions_mm = 0:vdCurrentVoxelDimensions_mm(2):(vdCurrentVolumeDimensions(2)-1) * vdCurrentVoxelDimensions_mm(2);
                    vdUnmatchedCurrentVoxelSlicePositions_mm = 0:vdCurrentVoxelDimensions_mm(3):(vdCurrentVolumeDimensions(3)-1) * vdCurrentVoxelDimensions_mm(3);
                    
                    switch dThroughPlaneSliceDimension
                        case 1
                            vdCurrentVoxelRowPositions_mm = vdUnmatchedCurrentVoxelSlicePositions_mm;
                            vdCurrentVoxelColPositions_mm = vdUnmatchedCurrentVoxelRowPositions_mm;
                            vdCurrentVoxelSlicePositions_mm = vdUnmatchedCurrentVoxelColPositions_mm;
                        case 2
                            vdCurrentVoxelRowPositions_mm = vdUnmatchedCurrentVoxelRowPositions_mm;
                            vdCurrentVoxelColPositions_mm = vdUnmatchedCurrentVoxelSlicePositions_mm;
                            vdCurrentVoxelSlicePositions_mm = vdUnmatchedCurrentVoxelColPositions_mm;
                        case 3
                            vdCurrentVoxelRowPositions_mm = vdUnmatchedCurrentVoxelRowPositions_mm;
                            vdCurrentVoxelColPositions_mm = vdUnmatchedCurrentVoxelColPositions_mm;
                            vdCurrentVoxelSlicePositions_mm = vdUnmatchedCurrentVoxelSlicePositions_mm;
                    end
                    
                    
                    % Okay...that's great and all, but now how are we going to find
                    % the voxel centre positions for our target geometry,
                    % especially if the first voxel positions are not aligned.
                    % Good question. The idea here will be to find the vector
                    % between the current and target first voxel positions. We can
                    % then use the common row, col, and slice unit vectors to then
                    % get the components of the first voxel difference vector along
                    % each of the row, col, and slice unit vectors. This when then
                    % give us our starting position for the target voxel centres
                    vdFirstVoxelDifference_mm = vdTargetFirstVoxelPosition_mm - vdCurrentFirstVoxelPosition_mm;
                    
                    dTargetRowStart = dot(vdFirstVoxelDifference_mm, vdCurrentRowUnitVector);
                    dTargetColStart = dot(vdFirstVoxelDifference_mm, vdCurrentColUnitVector);
                    dTargetSliceStart = dot(vdFirstVoxelDifference_mm, obj.GetSliceAxisUnitVector());
                    
                    vdUnmatchedTargetVoxelRowPositions_mm = dTargetRowStart + vdTargetVoxelDimensions_mm(1) .* (0:1:vdTargetVolumeDimensions(1)-1);
                    vdUnmatchedTargetVoxelColPositions_mm = dTargetColStart + vdTargetVoxelDimensions_mm(2) .* (0:1:vdTargetVolumeDimensions(2)-1);
                    vdUnmatchedTargetVoxelSlicePositions_mm = dTargetSliceStart + vdTargetVoxelDimensions_mm(3) .* (0:1:vdTargetVolumeDimensions(3)-1);
                    
                    switch dThroughPlaneSliceDimension
                        case 1
                            vdTargetVoxelRowPositions_mm = vdUnmatchedTargetVoxelSlicePositions_mm;
                            vdTargetVoxelColPositions_mm = vdUnmatchedTargetVoxelRowPositions_mm;
                            vdTargetVoxelSlicePositions_mm = vdUnmatchedTargetVoxelColPositions_mm;
                        case 2
                            vdTargetVoxelRowPositions_mm = vdUnmatchedTargetVoxelRowPositions_mm;
                            vdTargetVoxelColPositions_mm = vdUnmatchedTargetVoxelSlicePositions_mm;
                            vdTargetVoxelSlicePositions_mm = vdUnmatchedTargetVoxelColPositions_mm;
                        case 3
                            vdTargetVoxelRowPositions_mm = vdUnmatchedTargetVoxelRowPositions_mm;
                            vdTargetVoxelColPositions_mm = vdUnmatchedTargetVoxelColPositions_mm;
                            vdTargetVoxelSlicePositions_mm = vdUnmatchedTargetVoxelSlicePositions_mm;
                    end
                    
                    % perform the interpolation.
                    % Two steps:
                    % - Use level sets to get the slice mask at the current
                    %   in-plane resolution
                    % - Use the slice mask to then produce the slice mask at the
                    %   new in-plane resolution
                    
                    % Step 1:
                    dNumTargetContouringSlices = vdTargetVolumeDimensions(dThroughPlaneSliceDimension);
                    
                    vdInterpolatedSlicesDims = vdCurrentVolumeDimensions;
                    vdInterpolatedSlicesDims(dThroughPlaneSliceDimension) = [];
                    vdInterpolatedSlicesDims = [vdInterpolatedSlicesDims, dNumTargetContouringSlices];
                    
                    m3bInterpolatedContourSlices = false(vdInterpolatedSlicesDims);
                    
                    vdCurrentLevelSetSlicePositions_mm = vdCurrentVoxelSlicePositions_mm((dLowerBound-1):1:(dUpperBound+1));
                    
                    for dCol=1:vdInterpolatedSlicesDims(2)
                        for dRow=1:vdInterpolatedSlicesDims(1)
                            m3bInterpolatedContourSlices(dRow,dCol,:) = ( 0 <= interp1(...
                                vdCurrentLevelSetSlicePositions_mm,...
                                squeeze(m3dLevelSets(dRow,dCol,:)),...
                                vdTargetVoxelSlicePositions_mm,...
                                chThroughSliceInterpolationMethod, -Inf) );
                        end
                    end
                    
                    clear('m3dLevelSets');
                    
                    % Step 2:
                    m3bInterpMask = false(vdTargetVolumeDimensions);
                    
                    for dContouringSliceIndex=1:vdTargetVolumeDimensions(dThroughPlaneSliceDimension)
                        [m2dRowMesh, m2dColMesh] = meshgrid(vdTargetVoxelColPositions_mm,vdTargetVoxelRowPositions_mm);
                        
                        m2bInterpolatedSlice = 0.5 <= interp2(...
                            vdCurrentVoxelColPositions_mm,vdCurrentVoxelRowPositions_mm,...
                            single(m3bInterpolatedContourSlices(:,:,dContouringSliceIndex)),...
                            m2dRowMesh, m2dColMesh,...
                            chInSliceInterpolationMethod,0);
                        
                        switch dThroughPlaneSliceDimension
                            case 1
                                m3bInterpMask(dContouringSliceIndex,:,:) = m2bInterpolatedSlice;
                            case 2
                                m3bInterpMask(:,dContouringSliceIndex,:) = m2bInterpolatedSlice;
                            case 3
                                m3bInterpMask(:,:,dContouringSliceIndex) = m2bInterpolatedSlice;
                        end
                    end
                end
                
                
                
            end
            
        end
        
        % >>>>>>>>>>>>>>>>>>>> VIEWING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        function hAxes = View(obj, hAxes)
            arguments
                obj
                hAxes matlab.graphics.axis.Axes {ValidationUtils.MustBeEmptyOrScalar} = matlab.graphics.axis.Axes.empty 
            end
            
            oTempImageVolume = MATLABImageVolume(zeros(obj.GetVolumeDimensions()), obj);
            oRASImageVolume = copy(oTempImageVolume);
            oRASImageVolume.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            
            oRenderer = ImageVolumeRenderer(oTempImageVolume, oRASImageVolume);
            
            if isempty(hAxes)
                hAxes = GeometricalImagingObjectRenderer.GetAxesFor3DRender();            
                o3DAxes = Imaging3DRenderAxes(hAxes);
                
                oRenderer.Render3DAxes(o3DAxes);
                oRenderer.Render3DAxesAnatomicalLabels(o3DAxes);
            else
                o3DAxes = Imaging3DRenderAxes(hAxes);
            end
                      
            oRenderer.Render3DImageVolumeOutline(o3DAxes);
            oRenderer.Render3DImageVolumeCoordinateAxes(o3DAxes);
            oRenderer.Render3DImageVolumeCoordinateAxesLabels(o3DAxes);
        end
        
        
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<
        
        function bBool = eq(obj1, obj2)
            bBool = ...
                DoubleUtils.MatricesEqualWithinBound(obj1.vdVolumeDimensions, obj2.vdVolumeDimensions, ImageVolumeGeometry.dEqualityBound) &&...
                DoubleUtils.MatricesEqualWithinBound(obj1.vdVoxelDimensions_mm, obj2.vdVoxelDimensions_mm, ImageVolumeGeometry.dEqualityBound) &&...
                DoubleUtils.MatricesEqualWithinBound(obj1.vdFirstVoxelPosition_mm, obj2.vdFirstVoxelPosition_mm, ImageVolumeGeometry.dEqualityBound) &&...
                DoubleUtils.MatricesEqualWithinBound(obj1.vdRowAxisUnitVector, obj2.vdRowAxisUnitVector, ImageVolumeGeometry.dEqualityBound) &&...
                DoubleUtils.MatricesEqualWithinBound(obj1.vdColumnAxisUnitVector, obj2.vdColumnAxisUnitVector, ImageVolumeGeometry.dEqualityBound);
        end
        
        function bBool = ne(obj1, obj2)
            bBool = ~(obj1 == obj2);
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function oRASImageVolumeGeometry = GetRASImageVolumeGeometry()
            oRASImageVolumeGeometry = ImageVolumeGeometry(...
                [1 1 1],...
                [1 0 0],[0 1 0],...
                [1 1 1],[0 0 0]);
        end
        
        function dPrecisionBound = GetPrecisionBound()
            dPrecisionBound = ImageVolumeGeometry.dPrecisionBound;
        end
        
        function vdEulerAngles_deg = GetEulerAnglesAboutCartesianAxesBetweenGeometries(obj1, obj2)
            m2dRotationMatrix = ImageVolumeGeometry.GetRotationMatrixBetweenGeometries(obj1, obj2);
            
            vdEulerAngles_deg = ImageVolumeGeometry.GetEulerAnglesAboutCartesianAxes(m2dRotationMatrix);
        end
        
        function oCartesianGeometry = GetCartesianGeometry()
            oCartesianGeometry = ImageVolumeGeometry(...
                [1 1 1],...
                [1 0 0], [0 1 0],...
                [1 1 1], [0 0 0]);
        end
        
        function oRASGeometry = GetRASGeometry()
            oRASGeometry = ImageVolumeGeometry(...
                [1 1 01],...
                [1 0 0], [0 1 0],...
                [1 1 1], [0 0 0]);
        end
        
        function [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMinimalBoundsForMask(m3bMask)
            arguments
                m3bMask (:,:,:) logical
            end
            
            vdDims = size(m3bMask);
            
            if length(vdDims) == 2
                vdDims = [vdDims,1];
            end
            
            % get row bounds
            dRowMin = 1;
            dRowMax = vdDims(1);
            
            bSearchingForMin = true;
            
            for dRowIndex=1:vdDims(1)
                m2bSlice = m3bMask(dRowIndex,:,:);
                bSliceHasTrue = any(m2bSlice(:));
                
                if bSliceHasTrue && bSearchingForMin
                    bSearchingForMin = false;
                    dRowMin = dRowIndex;
                elseif bSliceHasTrue && ~bSearchingForMin
                    dRowMax = dRowIndex;
                end
            end
            
            vdRowBounds = [dRowMin, dRowMax];
            
            % get col bounds
            dColMin = 1;
            dColMax = vdDims(2);
            
            bSearchingForMin = true;
            
            for dColIndex=1:vdDims(2)
                m2bSlice = m3bMask(:,dColIndex,:);
                bSliceHasTrue = any(m2bSlice(:));
                
                if bSliceHasTrue && bSearchingForMin
                    bSearchingForMin = false;
                    dColMin = dColIndex;
                elseif bSliceHasTrue && ~bSearchingForMin
                    dColMax = dColIndex;
                end
            end
            
            vdColumnBounds = [dColMin, dColMax];
            
            % get slice bounds
            dSliceMin = 1;
            dSliceMax = vdDims(3);
            
            bSearchingForMin = true;
            
            for dSliceIndex=1:vdDims(3)
                m2bSlice = m3bMask(:,:,dSliceIndex);
                bSliceHasTrue = any(m2bSlice(:));
                
                if bSliceHasTrue && bSearchingForMin
                    bSearchingForMin = false;
                    dSliceMin = dSliceIndex;
                elseif bSliceHasTrue && ~bSearchingForMin
                    dSliceMax = dSliceIndex;
                end
            end
            
            vdSliceBounds = [dSliceMin, dSliceMax];
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
    
    methods (Access = private)
        
        function m2dOrientationMatrix = GetOrientationMatrix(obj)
            m2dOrientationMatrix = [...
                (obj.GetRowAxisUnitVector())',...
                (obj.GetColumnAxisUnitVector())',...
                (obj.GetSliceAxisUnitVector())'];
        end
    end
    
    
    methods (Access = private, Static = true)
        
        
        function vdAlongSliceUnitVector = CalculateSliceAxisUnitVector(vdRowAxisUnitVector, vdAlongColUnitVector)
            vdAlongSliceUnitVector = cross(vdRowAxisUnitVector, vdAlongColUnitVector);
        end
        
        function vdAngles_deg = GetEulerAnglesAboutCartesianAxes(m2dRotationMatrix)
            % returns the angles about the x-axes, y-axes, and z-axes (in
            % that order!), as if the rotation will be applied as:
            % 1) Rotate about x-axes
            % 2) THEN rotate about y-axes
            % 3) THEN rotate about z-axes
            
            vdAngles_deg = rotm2eul(m2dRotationMatrix, 'XYZ' ).* 180 ./ pi;
        end
        
        function m2dRotationMatrix = GetRotationMatrixBetweenGeometries(obj1, obj2)
            % returns matrix to rotate obj1 onto obj2 (assuming both of
            % their axes share the same origin.
            
            % developed as per:
            % https://stackoverflow.com/questions/21828801/how-to-find-correct-rotation-from-one-vector-to-another
            % See unit tests for testing of every row & col unit vector
            % pairing
            
            m2dObj1OrientationMatrix = obj1.GetOrientationMatrix();
            m2dObj2OrientationMatrix = obj2.GetOrientationMatrix();
            
            % the rotation matrix needed to align the current volume to
            % the target geometry
            m2dRotationMatrix = m2dObj2OrientationMatrix * m2dObj1OrientationMatrix'; % transpose on m2dObj1OrientationMatrix is effectively inverting it
        end
        
        function vdTranslationVector = GetTranslationVectorBetweenGeometries(obj1, obj2)
            % returns vector to translate first voxel of obj1 onto first
            % voxel of obj2
            
            vdTranslationVector = obj2.vdFirstVoxelPosition_mm - obj1.vdFirstVoxelPosition_mm;
        end
        
        function [m2dRotationMatrix, vdTranslationVector] = GetRotationMatrixAndTranslationVectorBetweenGeometries(obj1, obj2)
            % returns matrix to rotate obj1 onto obj2 such that their row
            % and col unit vectors will align, and first voxels will
            % coincident
            
            m2dRotationMatrix = ImageVolumeGeometry.GetRotationMatrixBetweenGeometries(obj1, obj2);
            
            % apply rotation matrix to obj1's first voxel position
            vdRotatedFirstVoxelPosition = (m2dRotationMatrix * obj1.vdFirstVoxelPosition_mm')';
            
            vdTranslationVector = obj2.vdFirstVoxelPosition_mm - vdRotatedFirstVoxelPosition;
        end
        
        function m2dRotationMatrix = GetRotationMatrixAboutArbitraryAxes(vdAxesUnitVector, dAngle_deg)
            vdAxesUnitVector = vdAxesUnitVector ./ norm(vdAxesUnitVector);
            
            dCos = cosd(dAngle_deg);
            dSin = sind(dAngle_deg);
            
            m2dRotationMatrix = [...
                dCos + (vdAxesUnitVector(1)^2 * (1 - dCos)), vdAxesUnitVector(1)*vdAxesUnitVector(2)*(1 - dCos) - vdAxesUnitVector(3)*dSin, vdAxesUnitVector(1)*vdAxesUnitVector(3)*(1 - dCos) + vdAxesUnitVector(2)*dSin;
                vdAxesUnitVector(1)*vdAxesUnitVector(2)*(1 - dCos) + vdAxesUnitVector(3)*dSin, dCos + (vdAxesUnitVector(2)^2 * (1 - dCos)), vdAxesUnitVector(2)*vdAxesUnitVector(3)*(1 - dCos) - vdAxesUnitVector(1)*dSin;
                vdAxesUnitVector(1)*vdAxesUnitVector(3)*(1 - dCos) - vdAxesUnitVector(2)*dSin, vdAxesUnitVector(2)*vdAxesUnitVector(3)*(1 - dCos) + vdAxesUnitVector(1)*dSin, dCos + (vdAxesUnitVector(3)^2 * (1 - dCos));];
        end
        
        function vdAngles_deg = GetEulerAnglesAboutArbitraryAxes(m2dRotationMatrix, vdAxis1UnitVector, vdAxis2UnitVector)
            oGivenImageVolumeGeometry = ImageVolumeGeometry(...
                [1 1 1],...
                vdAxis1UnitVector, vdAxis2UnitVector,...
                [1 1 1],[0 0 0]);
            
            % the rotation matrix needed to align the current volume to
            % the target geometry
            m2dRotationToCartesianAxesMatrix = ImageVolumeGeometry.GetRotationMatrixBetweenGeometries(oGivenImageVolumeGeometry, ImageVolumeGeometry.GetCartesianGeometry());
            
            vdRotationToCartesianAxesMatrixAngles_deg = ImageVolumeGeometry.GetEulerAnglesAboutCartesianAxes(m2dRotationToCartesianAxesMatrix');
            
            % apply rotation
            m2dRotationMatrix = m2dRotationMatrix * m2dRotationToCartesianAxesMatrix';
            
            % get Euler angles
            vdAngles_deg = ImageVolumeGeometry.GetEulerAnglesAboutCartesianAxes(m2dRotationMatrix);
            
            % undo the rotation to the angles
            vdAngles_deg = vdAngles_deg - vdRotationToCartesianAxesMatrixAngles_deg;
        end
        
        function [m3xMatrix, vdNewDimensionLocation] = RotateMatrixBy90AboutDimension(m3xMatrix, dDim, dNumRotations)
            arguments
                m3xMatrix (:,:,:)
                dDim (1,1) double {mustBeMember(dDim, [1,2,3])}
                dNumRotations (1,1) double {mustBeInteger}
            end
            
            vdNewDimensionLocation = 1:3;
            
            bNegRotation = dNumRotations < 0;
            
            dNumRotations = mod(abs(dNumRotations),4); % 4x 90 rotations = 0 rotations, 5 = 1, etc.
            
            if bNegRotation && dNumRotations ~= 0
                dNumRotations = 4 - dNumRotations;
            end
            
            for dRotationIndex=1:dNumRotations
                switch dDim
                    case 1
                        m3xMatrix = permute(m3xMatrix, [1 3 2]);
                        m3xMatrix = flip(m3xMatrix,2);
                        
                        vdNewDimensionLocation([2,3]) = vdNewDimensionLocation([3,2]);
                    case 2
                        m3xMatrix = flip(m3xMatrix,1);
                        m3xMatrix = permute(m3xMatrix, [3 2 1]);
                        
                        vdNewDimensionLocation([1,3]) = vdNewDimensionLocation([3,1]);
                    case 3
                        m3xMatrix = permute(m3xMatrix, [2 1 3]);
                        m3xMatrix = flip(m3xMatrix,1);
                        
                        vdNewDimensionLocation([1,2]) = vdNewDimensionLocation([2,1]);
                    otherwise
                        error(...
                            'ImageVolumeGeometry:RotateMatrixBy90AboutDimension:InvalidDimension',...
                            'Dimension must be 1, 2, or 3.');
                end
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> VALIDATION <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeUnitVector(vdVector)
            if abs(norm(vdVector)-1) > ImageVolumeGeometry.dUnitVectorNormPrecisionBound
                error(...
                    'ImageVolumeGeometry:MustBeUnitVector:NotUnitVector',...
                    'Unit vectors must be normalized (e.g. have a norm of 1).');
            end
        end
        
        function MustBeOrthogonal(vdVector1, vdVector2)
            if dot(vdVector1, vdVector2) > ImageVolumeGeometry.dOrthogonalPrecisionBound
                error(...
                    'ImageVolumeGeometry:MustBeOrthogonal:NotOrthogonal',...
                    'Vectors must be orthogonal (e.g. have a dot product of 0).');
            end
        end
        
        function ValidateAcquisitionDimension(dAcquisitionDimension)
            % empty OR scalar, integer, within set {1,2,3}
            if ~isempty(dAcquisitionDimension)
                if ~isscalar(dAcquisitionDimension)
                    error(...
                        'ImageVolumeGeometry:ValidateAcquisitionDimension:NotScalar',...
                        'Must be a scalar value or empty.');
                end
                
                mustBeMember(dAcquisitionDimension, [1,2,3]);
            end
        end
        
        function ValidateAcquisitionSliceThickness_mm(dAcquisitionSliceThickness_mm)
            % empty or positive, finite, scalar
            if ~isempty(dAcquisitionSliceThickness_mm)
                if ~isscalar(dAcquisitionSliceThickness_mm)
                    error(...
                        'ImageVolumeGeometry:ValidateAcquisitionSliceThickness_mm:NotScalar',...
                        'Must be a scalar value or empty.');
                end
                
                mustBeFinite(dAcquisitionSliceThickness_mm);
                mustBePositive(dAcquisitionSliceThickness_mm);
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
        
        function [m3xMatrix, vdNewDimensionLocation] = RotateMatrixBy90AboutDimension_UnitTestAccess(m3xMatrix, dDim, dNumRotations)
            [m3xMatrix, vdNewDimensionLocation] = ImageVolumeGeometry.RotateMatrixBy90AboutDimension(m3xMatrix, dDim, dNumRotations);
        end
    end
end




