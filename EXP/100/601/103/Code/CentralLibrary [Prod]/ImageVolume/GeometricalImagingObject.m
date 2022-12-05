classdef (Abstract) GeometricalImagingObject < matlab.mixin.Copyable
    %GeometricalImagingObject
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public)
        bIsRASObject = []
    end
    
    properties (SetAccess = protected, GetAccess = public)
        voAppliedImagingObjectTransforms (1,:) ImagingObjectTransform = ImagingObjectInitialTransform.empty(1,0)
        dCurrentAppliedImagingObjectTransform = []
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public, Abstract = true)
        
        LoadVolumeData(obj)
    end
    
    methods (Access = public)
        
        function obj = GeometricalImagingObject(oOnDiskImageVolumeGeometry)
            %obj = GeometricalImagingObject(oOnDiskImageVolumeGeometry)
            arguments
                oOnDiskImageVolumeGeometry (1,1) ImageVolumeGeometry
            end
                   
            % Set properities:
            obj.voAppliedImagingObjectTransforms = ImagingObjectInitialTransform(oOnDiskImageVolumeGeometry);            
            obj.dCurrentAppliedImagingObjectTransform = 1;
        end 
            
        % >>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeRAS(obj)
            if ~obj.IsRAS()
                error(...
                    'GeometricalImagingObject:MustBeRAS:Invalid',...
                    'The GeometricalImagingObject was not in the RAS geometry (+row = right, +column = anterior, +slice = superior).');
            end
        end
        
        function MustBeRASTransformFromObject(obj, fromObj)
            obj.MustBeRAS();
            
            if ...
                    obj.GetImageVolumeGeometry() ~= fromObj.GetImageVolumeGeometry() && ...
                    obj.GetPreviousImageVolumeGeometry() ~= fromObj.GetImageVolumeGeometry()
                error(...
                    'GeometricalImagingObject:MustBeRASTransformFromObject:Invalid',...
                    'Either the current or previous ImageVolumeGeometry of obj must equal the current ImageVolumeGeometry of fromObj.');
            end
            
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          
        function bBool = IsRAS(obj)
            if isempty(obj.bIsRASObject)
                obj.bIsRASObject = obj.GetImageVolumeGeometry().IsRAS();
            end
            
            bBool = obj.bIsRASObject;
        end
        
        function bBool = AreAllTransformsApplied(obj)
            % TODO
            
            bBool = (obj.dCurrentAppliedImagingObjectTransform == length(obj.voAppliedImagingObjectTransforms));
        end
        
        function oOnDiskImageVolumeGeometry = GetOnDiskImageVolumeGeometry(obj)
            oOnDiskImageVolumeGeometry = obj.voAppliedImagingObjectTransforms(1).GetPostTransformImageVolumeGeometry(); 
        end
        
        function oImageVolumeGeometry = GetImageVolumeGeometry(obj)
            oImageVolumeGeometry = obj.voAppliedImagingObjectTransforms(end).GetPostTransformImageVolumeGeometry();
        end
        
        function vdVoxelDimensions_mm = GetVoxelDimensions_mm(obj)
            vdVoxelDimensions_mm = obj.GetImageVolumeGeometry().GetVoxelDimensions_mm();
        end
        
        function vdVolumeDimensions = GetVolumeDimensions(obj)
            vdVolumeDimensions = obj.GetImageVolumeGeometry().GetVolumeDimensions();
        end
        
        function vdVolumeDimensions_mm = GetVolumeDimensions_mm(obj)
            vdVolumeDimensions_mm = obj.GetImageVolumeGeometry().GetVolumeDimensions_mm();
        end
        
        function dAcquisitionDimension = GetAcquisitionDimension(obj)
            dAcquisitionDimension = obj.GetImageVolumeGeometry().GetAcquisitionDimension();
        end
        
        function AcquisitionSliceThickness_mm = GetAcquisitionSliceThickness_mm(obj)
            AcquisitionSliceThickness_mm = obj.GetImageVolumeGeometry().GetAcquisitionSliceThickness_mm();
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>> TRANSFORMS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function ForceApplyAllTransforms(obj)      
            obj.LoadVolumeData();
            dNumTransforms = length(obj.voAppliedImagingObjectTransforms);
             
            % if transforms need to be applied, this loop will make that
            % happen
            for dTransformIndex = obj.dCurrentAppliedImagingObjectTransform+1 : dNumTransforms
                obj.voAppliedImagingObjectTransforms(dTransformIndex).Apply(obj);
                
                obj.dCurrentAppliedImagingObjectTransform = dTransformIndex;
            end
        end
        
        function RemoveAllTransforms(obj)
            obj.voAppliedImagingObjectTransforms = obj.voAppliedImagingObjectTransforms(1);            
            obj.dCurrentAppliedImagingObjectTransform = 1;   
            obj.bIsRASObject = []; % empty = who knows? Will compute on the fly if needed
        end
        
        function ReassignFirstVoxel(obj, oTargetImageVolumeGeometry)
            oTransform = ImagingObjectFirstVoxelTransform(...
                obj.GetImageVolumeGeometry(),...
                oTargetImageVolumeGeometry);
            
            obj.AddTransform(oTransform);
        end
        
        function ReassignFirstVoxelToAlignWithRASCoordinateSystem(obj)
            % NOTE: This gets the image volume as close to the RAS system
            % as possible, such that:
            %   +row   == left->right (+x)
            %   +col   == post->ant   (+y)
            %   +slice == inf->sup    (+z)
            
            ReassignFirstVoxel(obj, ImageVolumeGeometry.GetRASImageVolumeGeometry());
        end
    end
    
    
    methods (Access = public, Static = true)
       
        function MustHaveSameImageVolumeGeometry(obj1, obj2)
            arguments
                obj1 (1,1) GeometricalImagingObject
                obj2 (1,1) GeometricalImagingObject
            end
            
            if obj1.GetImageVolumeGeometry() ~= obj2.GetImageVolumeGeometry()
                error(...
                    'GeometricalImagingObject:MustHaveSameImageVolumeGeometry:Invalid',...
                    'The two objects do not have equal ImageVolumeGeometry values.');
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
            % - none
        end
        
        function AddTransform(obj, oTransform)
            obj.voAppliedImagingObjectTransforms = [obj.voAppliedImagingObjectTransforms, oTransform];
            obj.bIsRASObject = []; % empty = who knows? Will compute on the fly if needed
            
            % if the transform is "Independent" it doesn't need to be
            % applied right now. If it is "Dependent", that means the
            % transform relies on some other GeometricalImagingObjects, so
            % it's important to apply the transform now, as the those
            % objects may change/shouldn't be stored
            if isa(oTransform, 'DependentImagingObjectTransform')
                obj.ForceApplyAllTransforms();
            end
        end
        
        function oCurrentImageVolumeGeometry = GetCurrentImageVolumeGeometry(obj)
            oCurrentImageVolumeGeometry = obj.voAppliedImagingObjectTransforms(obj.dCurrentAppliedImagingObjectTransform).GetPostTransformImageVolumeGeometry();
        end
        
        function MustBeValidCropBounds(obj, vdBounds, dDim)
            arguments
                obj
                vdBounds (1,2) double {mustBeInteger}
                dDim (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(dDim, 1), mustBeLessThanOrEqual(dDim, 3)}
            end
            
            vdVolumeDims = obj.GetImageVolumeGeometry().GetVolumeDimensions();
            dCompareDim = vdVolumeDims(dDim);
            
            if vdBounds(1) > vdBounds(2)
                error(...
                    'GeometricalImagingObject:MustBeValidCropBounds:InvalidOrder',...
                    'First bound must be less than second bound');
            end
            
            if vdBounds(1) < 1
                error(...
                    'GeometricalImagingObject:MustBeValidCropBounds:FirstBoundTooLow',...
                    'First bound must be greater or equal to 1');
            end
            
            if vdBounds(2) > dCompareDim
                error(...
                    'GeometricalImagingObject:MustBeValidCropBounds:SecondBoundTooHigh',...
                    'Second bound must be less or equal to volume size');
            end
        end
    end
    
    
    methods (Access = protected, Static = true)
        
        function MustBeValidVolumeData(m3xVolumeData, oImageVolumeGeometry)
            arguments
                m3xVolumeData (:,:,:) {mustBeReal, ValidationUtils.MustBeFinite_Optimized}
                oImageVolumeGeometry (1,1) ImageVolumeGeometry
            end
            
            % validate dimensions match the ImageVolumeGeometry
            vdVolumeDimensions = oImageVolumeGeometry.GetVolumeDimensions();
            
            for dDimIndex=1:3
                if vdVolumeDimensions(dDimIndex) ~= size(m3xVolumeData,dDimIndex)
                    error(...
                    'GeometricalImagingObject:MustBeValidVolumeData:DimMismatch',...
                    'The volume data must have the same dimensions as given in by the ImageVolumeGeometry.');
                end
            end
        end
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
      
    methods (Access = private)
        
        function oImageVolumeGeometry = GetPreviousImageVolumeGeometry(obj)
            dNumTransforms = length(obj.voAppliedImagingObjectTransforms);
            
            oImageVolumeGeometry = obj.voAppliedImagingObjectTransforms(max(1,dNumTransforms)).GetPostTransformImageVolumeGeometry();
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