classdef (Abstract) RegionsOfInterestFromPolygons < matlab.mixin.Copyable
    %RegionsOfInterest
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = protected, GetAccess = public) % None
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
          
    methods (Access = public)
        
        function oRenderer = GetRenderer(obj)
            if ~obj.IsRAS
                objRas = copy(obj);
                objRas.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            else
                objRas = obj;
            end
            
            oRenderer = LabelMapRegionsOfInterestFromPolygonsRenderer(obj, objRas);
        end
    end
    
    methods (Access = public, Abstract = true)
        c1m2dVertexPositionCoords_mm = GetAllEnabledPolygonVertexPositionCoordinatesByRoiNumber(obj, dRegionOfInterestNumber)
        
        c1m2dVertexVoxelIndices = GetAllEnabledPolygonVertexVoxelIndicesByRoiNumber(obj, dRegionOfInterestNumber)
        
        c1m2dVertexVoxelIndices = GetAllEnabledPolygonVertexVoxelIndicesInSliceByRoiNumber(obj, dRegionOfInterestNumber, vdAnatomicalPlaneIndices, eImagingPlaneType)
        
        [c1m2dVertexPositionCoords_mm, vbEnabled] = GetAllPolygonVertexPositionCoordinatesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
        
        [c1m2dVertexVoxelIndices, vbEnabled] = GetAllPolygonVertexVoxelIndicesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
        
        [c1m2dVertexVoxelIndices, vbEnabled, vdPolygonIndices] = GetAllPolygonVertexVoxelIndicesInSliceByRegionOfInterestNumber(obj, dRegionOfInterestNumber, vdAnatomicalPlaneIndices, eImagingPlaneType)
        
        [m2dVertexVoxelIndices, bEnabled] = GetPolygonVertexVoxelIndicesByRoiNumberAndPolygonIndex(obj, dRegionOfInterestNumber, dPolygonIndex)
        
        dNumRois = GetNumberOfRegionsOfInterestWithEnabledPolygons(obj)
        
        dNumEnabledPolygons = GetNumberOfEnabledPolygonsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
        
        dNumPolygons = GetNumberOfPolygonsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
        
        vbEnabled = AreRegionsOfInterestPolygonsEnabled(obj)
        
        bEnabled = ArePolygonsEnabledByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
        
        bEnabled = IsPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj, dRegionOfInterestNumber, dPolygonIndex)
        
        vbEnabled = IsPolygonEnabledByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
        
        SetEnabledByRegionOfInterestNumber(obj, dRegionOfInterestNumber, bEnabled)
        
        SetPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj, dRegionOfInterestNumber, dPolygonIndex, bEnabled)
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


