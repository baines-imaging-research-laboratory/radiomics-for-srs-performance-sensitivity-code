classdef (Abstract) RegionsOfInterestRenderer < GeometricalImagingObjectRenderer
    %RegionsOfInterestRenderer
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)    
        oRegionsOfInterest = []
        oRASRegionsOfInterest = []
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
          
    methods (Access = public)
        
        function obj = RegionsOfInterestRenderer(oRegionsOfInterest, oRASRegionsOfInterest)
            %obj = ImageVolume(m3xImageData)
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
            arguments
                oRegionsOfInterest (1,1) RegionsOfInterest
                oRASRegionsOfInterest (1,1) RegionsOfInterest
            end
                        
            % super-class call
            obj@GeometricalImagingObjectRenderer(oRegionsOfInterest);
            
            % set properties
            obj.oRegionsOfInterest = oRegionsOfInterest;
            obj.oRASRegionsOfInterest = oRASRegionsOfInterest;
        end
        
        function MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumbers)
            obj.oRegionsOfInterest.MustBeValidRegionOfInterestNumbers(vdRegionOfInterestNumbers);
        end
        
        function dRenderGroupId = CreateRenderGroup(obj)
            dRenderGroupId = max(obj.vdRenderGroupIds) + 1;
            obj.vdRenderGroupIds = [obj.vdRenderGroupIds, dRenderGroupId];
        end
        
        function RenderIn3D(obj, oImaging3DRenderAxes, vdAnatomicalPlaneIndices, dRenderGroupId, NameValueArgs)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                vdAnatomicalPlaneIndices (1,:) double
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
                NameValueArgs.GeometricalImagingObjectRendererComplete (1,1) logical = false
            end
            
            % Super-class call:
            RenderIn3D@GeometricalImagingObjectRenderer(obj,...
                oImaging3DRenderAxes, vdAnatomicalPlaneIndices,...
                dRenderGroupId,...
                'GeometricalImagingObjectRendererComplete', NameValueArgs.GeometricalImagingObjectRendererComplete);
        end
        
        function UpdateAll(obj)
            arguments
                obj
            end
            
            obj.UpdateAll3D(obj);
            obj.UpdateAllOnPlane(obj);
        end
        
        function UpdateAll3D(obj)
            arguments
                obj
            end
            
            % super-class call
            UpdateAll3D@GeometricalImagingObjectRenderer(obj);
        end
        
        function UpdateAllOnPlane(obj)
            arguments
                obj
            end
            
            % super-class call
            UpdateAllOnPlane@GeometricalImagingObjectRenderer(obj);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = protected)
        
        function oGeometricalImagingObj = GetGeometricalImagingObject(obj)
            oGeometricalImagingObj = obj.oRegionsOfInterest;
        end
        
        function oRASGeometricalImagingObj = GetRASGeometricalImagingObject(obj)
            oRASGeometricalImagingObj = obj.oRASRegionsOfInterest;	
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function ValidateRegionsOfInterest(oRegionsOfInterest)
            if ~isscalar(oRegionsOfInterest) || ~isa(oRegionsOfInterest, 'RegionsOfInterest')
                error(...
                    'RegionsOfInterest:ValidateRegionsOfInterest:Invalid',...
                    'oRegionsOfInterest must be scalar of type RegionsOfInterest.');
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


