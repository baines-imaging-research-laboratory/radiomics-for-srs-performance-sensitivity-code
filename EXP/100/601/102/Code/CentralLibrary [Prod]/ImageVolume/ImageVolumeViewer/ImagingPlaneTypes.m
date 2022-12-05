classdef ImagingPlaneTypes
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dRASImageVolumeRowDimension
        dRASImageVolumeColumnDimension
        dRASImageVolumeSliceDimension
        
        vdRenderColour_rgb
    end
    
    enumeration
        Sagittal (3,2,1, [1,0,0])   % row: -z | col: -y | slice: -x (render as red)
        Coronal  (3,1,2, [0,1,0])   % row: -z | col: -x | slice: +y (render as green)
        Axial    (2,1,3, [0,0.2,1]) % row: -y | col: -x | slice: -z (render as blue_
    end
    
    methods (Access = public)
        
        function enum = ImagingPlaneTypes(dRASImageVolumeRowDimension, dRASImageVolumeColumnDimension, dRASImageVolumeSliceDimension, vdRenderColour_rgb)
            enum.dRASImageVolumeRowDimension = dRASImageVolumeRowDimension;
            enum.dRASImageVolumeColumnDimension = dRASImageVolumeColumnDimension;
            enum.dRASImageVolumeSliceDimension = dRASImageVolumeSliceDimension;
            
            enum.vdRenderColour_rgb = vdRenderColour_rgb;
        end
        
        function [eRowEnum, eColumnEnum] = GetPerpendicularImagingPlaneTypes(enum)
            veEnumOptions = enumeration(enum);
            
            eRowEnum = [];
            eColumnEnum = [];
            
            for dEnumIndex=1:length(veEnumOptions)
                if enum.dRASImageVolumeRowDimension == veEnumOptions(dEnumIndex).dRASImageVolumeSliceDimension
                    eRowEnum = veEnumOptions(dEnumIndex);
                elseif enum.dRASImageVolumeColumnDimension == veEnumOptions(dEnumIndex).dRASImageVolumeSliceDimension
                    eColumnEnum = veEnumOptions(dEnumIndex);
                end
            end
        end
        
        function vdRenderColour_rgb = GetRenderColour_rgb(obj)
            vdRenderColour_rgb = obj.vdRenderColour_rgb;
        end
        
        function vdSliceBounds = GetVolumeSliceBounds(obj, oRASImageVolume)
            vdVolumeDimensions = oRASImageVolume.GetVolumeDimensions();
            vdSliceBounds = [1 vdVolumeDimensions(obj.dRASImageVolumeSliceDimension)];
        end
        
        function vdVoxelDimensions_mm = GetVoxelDimensions_mm(obj, oRASImageVolume)
            vdVoxelDimensions_mm = oRASImageVolume.GetVoxelDimensions_mm();
            
            vdVoxelDimensions_mm = vdVoxelDimensions_mm([...
                obj.dRASImageVolumeRowDimension
                obj.dRASImageVolumeColumnDimension
                obj.dRASImageVolumeSliceDimension]);
        end
        
        function vdVolumeDimensions_mm = GetVolumeDimensions_mm(obj, oRASImageVolume)
            vdVoxelDimensions_mm = oRASImageVolume.GetVoxelDimensions_mm();
            vdVolumeDimensions = oRASImageVolume.GetVolumeDimensions();
            
            vdSelect =[obj.dRASImageVolumeRowDimension, obj.dRASImageVolumeColumnDimension, obj.dRASImageVolumeSliceDimension];
            
            vdVolumeDimensions_mm = vdVoxelDimensions_mm(vdSelect) .* vdVolumeDimensions(vdSelect);
        end
        
        function vdVolumeDimensions = GetVolumeDimensions(obj, oRASImageVolume)            
            vdVolumeDimensions = oRASImageVolume.GetVolumeDimensions();
            vdSelect =[obj.dRASImageVolumeRowDimension, obj.dRASImageVolumeColumnDimension, obj.dRASImageVolumeSliceDimension];
            
            vdVolumeDimensions = vdVolumeDimensions(vdSelect);
        end
        
        function vdDimensionSelect = GetRASVolumeDimensionSelect(obj)
            % gives dims to select the [row, col, slice]
            
            vdDimensionSelect =[obj.dRASImageVolumeRowDimension, obj.dRASImageVolumeColumnDimension, obj.dRASImageVolumeSliceDimension];
        end
        
        function dSliceIndex = GetSliceIndexFromAnatomicalPlaneIndices(enum, vdAnatomicalPlaneIndices)
            arguments
                enum
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
            end
            
            dSliceIndex = vdAnatomicalPlaneIndices(enum.dRASImageVolumeSliceDimension);
        end
        
        function [m2xSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = GetImageDataSlice(enum, oRASImageVolume, dSliceIndex)
            arguments
                enum
                oRASImageVolume (1,1) ImageVolume {MustBeRAS(oRASImageVolume)}
                dSliceIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            % get 3D Image Data
            m3xImageData = oRASImageVolume.GetImageData();
            
            [m2xSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = ...
                enum.GetSliceFromVolumeData(oRASImageVolume, m3xImageData, dSliceIndex);                        
        end
        
        function [m2xSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = GetImageDataSliceFromAnatomicalPlaneIndices(enum, oRASImageVolume, vdAnatomicalPlaneIndices)
            arguments
                enum
                oRASImageVolume (1,1) ImageVolume {MustBeRAS(oRASImageVolume)}
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
            end
            
            dSliceIndex = vdAnatomicalPlaneIndices(enum.dRASImageVolumeSliceDimension);
            
            [m2xSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = enum.GetImageDataSlice(oRASImageVolume, dSliceIndex);
        end
        
        function [m2bSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = GetMaskSliceByRegionOfInterestNumber(enum, oRASRegionsOfInterest, dRegionOfInterestNumber, dSliceIndex)
            arguments
                enum
                oRASRegionsOfInterest (1,1) RegionsOfInterest {MustBeRAS(oRASRegionsOfInterest)}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(oRASRegionsOfInterest, dRegionOfInterestNumber)}
                dSliceIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            m3bMaskData = oRASRegionsOfInterest.GetMaskByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            [m2bSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = ...
                enum.GetSliceFromVolumeData(oRASRegionsOfInterest, m3bMaskData, dSliceIndex);
        end
        
        function [m2bSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = GetMaskSliceFromAnatomicalPlaneIndicesByRegionOfInterestNumber(enum, oRASRegionsOfInterest, dRegionOfInterestNumber, vdAnatomicalPlaneIndices)
            arguments
                enum
                oRASRegionsOfInterest (1,1) RegionsOfInterest {MustBeRAS(oRASRegionsOfInterest)}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(oRASRegionsOfInterest, dRegionOfInterestNumber)}
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
            end
            
            dSliceIndex = vdAnatomicalPlaneIndices(enum.dRASImageVolumeSliceDimension);
            
            [m2bSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = enum.GetMaskSliceByRegionOfInterestNumber(oRASRegionsOfInterest, dRegionOfInterestNumber, dSliceIndex);
        end
        
        function [vdX_mm, vdY_mm] = GetSliceIntersectionCoordinates(obj, oRASImageVolume, eIntersectionImagingPlaneType, dIntersectingSliceIndex)
            dIntersectingSliceDimension = eIntersectionImagingPlaneType.dRASImageVolumeSliceDimension;
            
            vdVolumeDimensions = obj.GetVolumeDimensions(oRASImageVolume);
            vdVoxelDimensions_mm = obj.GetVoxelDimensions_mm(oRASImageVolume);
            
            if dIntersectingSliceDimension == obj.dRASImageVolumeSliceDimension % their in the same plane, so no intersection
                vdX_mm = [];
                vdY_mm = [];
            elseif dIntersectingSliceDimension == obj.dRASImageVolumeRowDimension % horizontal line across the slice
                vdX_mm = [...
                    0 - 0.5.*vdVoxelDimensions_mm(2),...
                    (vdVolumeDimensions(2) - 0.5).*vdVoxelDimensions_mm(2)];
                
                vdY_mm = ones(1,2) .* (dIntersectingSliceIndex-1) .* vdVoxelDimensions_mm(1);
            else % vertical line across the slice
                vdX_mm = ones(1,2) .* (dIntersectingSliceIndex-1).*vdVoxelDimensions_mm(2);
                
                vdY_mm = [...
                    0 - 0.5.*vdVoxelDimensions_mm(1),...
                    (vdVolumeDimensions(1) - 0.5).*vdVoxelDimensions_mm(1)];
            end
                
        end
    end
    
    
    methods (Access = private)
        
        function [m2xSlice, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm] = GetSliceFromVolumeData(enum, oRASGeometricalImagingObject, m3xVolumeData, dSliceIndex)
            
            % select slice
            switch enum
                case ImagingPlaneTypes.Sagittal
                    m2xSlice = squeeze(m3xVolumeData(dSliceIndex,:,:));
                case ImagingPlaneTypes.Coronal
                    m2xSlice = squeeze(m3xVolumeData(:,dSliceIndex,:));
                case ImagingPlaneTypes.Axial
                    m2xSlice = m3xVolumeData(:,:,dSliceIndex);
            end
            
            % transpose slice data, since:
            %
            % - Sagittal: In slice DISPLAY, the row axis is sup/inf and the
            % col axis is ant/post. For RAS ImageVolume sup/inf is the
            % slice dimension, and ant/post is the column dimension.
            % Therefore when the slice is extracted (see above), the slice
            % comes out with a row axis in the ant/post direction and a
            % column axis in the sup/inf direction. This is the opposite of
            % what we need, so a transpose is used.
            %
            % - Coronal: In slice DISPLAY, the row axis is sup/inf and the
            % col axis is right/left. For RAS ImageVolume sup/inf is the
            % slice dimension, and right/left is the row dimension.
            % Therefore when the slice is extracted (see above), the slice
            % comes out with a row axis in the right/left direction and a
            % column axis in the sup/inf direction. This is the opposite of
            % what we need, so a transpose is used.
            %
            % - Axial: In slice DISPLAY, the row axis is ant/post and the
            % col axis is right/left. For RAS ImageVolume ant/post is the
            % column dimension, and right/left is the row dimension.
            % Therefore when the slice is extracted (see above), the slice
            % comes out with a row axis in the right/left direction and a
            % column axis in the ant/post direction. This is the opposite of
            % what we need, so a transpose is used.
            
            m2xSlice = transpose(m2xSlice);
                    
            % get row/col voxel spacing (required for non-isotropic voxel
            % display)
            vdVoxelDimensions_mm = oRASGeometricalImagingObject.GetVoxelDimensions_mm();
            
            dRowVoxelSpacing_mm = vdVoxelDimensions_mm(enum.dRASImageVolumeRowDimension);
            dColumnVoxelSpacing_mm = vdVoxelDimensions_mm(enum.dRASImageVolumeColumnDimension);
        end
    end
end

