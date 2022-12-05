classdef DatabaseImageVolume < handle
    %DatabaseImageVolume
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public) 
        dVolumeNumber double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger}
        
        chRawDataDirectoryPath (1,:) char
        chImageDatabaseFilePath (1,:) char
        
        chRawDataRegionsOfInterestFilePath (1,:) char
        
        voDatabaseRegionsOfInterest (1,:) DatabaseRegionOfInterest = DatabaseRegionOfInterest.empty(1,0)
        
        % study specific settings
        vdPreferredImageVolumeDisplayThreshold (1,2) double {ValidationUtils.MustBeIncreasing} = [0 1] % e.g window/level
        vdExtractionIndexToRegionOfInterestNumber (1,:) double {mustBeInteger} = [] % if the value of this was [3, 2] it would mean that 1st extraction index would point to ROI 3, and 2nd extraction index would point to ROI 2. Any other ROIs would be ignored.
        
        % image volume object cache
        oCachedImageVolume = []
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DatabaseImageVolume(dVolumeNumber, chRawDataDirectoryPath, chImageDatabaseFilePath, chRawDataRegionsOfInterestFilePath, voDatabaseRegionsOfInterest)
            %obj = DatabaseImageVolume(dVolumeNumber, chRawDataDirectoryPath, chImageDatabaseFilePath, chRawDataRegionsOfInterestFilePath, voDatabaseRegionsOfInterest)
            
            obj.dVolumeNumber = dVolumeNumber;
            
            obj.chRawDataDirectoryPath = chRawDataDirectoryPath;
            obj.chImageDatabaseFilePath = chImageDatabaseFilePath;
            
            obj.chRawDataRegionsOfInterestFilePath = chRawDataRegionsOfInterestFilePath;
                        
            obj.voDatabaseRegionsOfInterest = voDatabaseRegionsOfInterest;
        end
               
        function Update(obj)
            
            for dRoiIndex=1:length(obj.voDatabaseRegionsOfInterest)
                obj.voDatabaseRegionsOfInterest(dRoiIndex).Update();
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dVolumeNumber = GetVolumeNumber(obj)
            dVolumeNumber = obj.dVolumeNumber;
        end
        
        function oImageVolume = GetImageVolumeObject(obj)
            if isempty(obj.oCachedImageVolume)
                obj.oCachedImageVolume = ImageVolume.Load(obj.chImageDatabaseFilePath);
            end
            
            oImageVolume = obj.oCachedImageVolume;
        end
        
        function chImageDatabaseFilePath = GetImageDatabaseFilePath(obj)
            chImageDatabaseFilePath = obj.chImageDatabaseFilePath;
        end
        
        function bBool = IsContoured(obj)
            bBool = ~isempty(obj.voDatabaseRegionsOfInterest);
        end
        
        function dNumRois = GetNumberOfRegionsOfInterest(obj)
            dNumRois = length(obj.voDatabaseRegionsOfInterest);
        end
        
        function oRoi = GetRegionOfInterestByRegionOfInterestNumber(obj, dRoiNumber)
            oRoi = DatabaseRegionOfInterest.empty;
            
            for dRoiIndex=1:length(obj.voDatabaseRegionsOfInterest)
                if obj.voDatabaseRegionsOfInterest(dRoiIndex).GetRegionOfInterestNumber() == dRoiNumber
                    oRoi = obj.voDatabaseRegionsOfInterest(dRoiIndex);
                    break;
                end
            end
        end
        
        function voRois = GetRegionsOfInterestWithPolygons(obj)
            dNumRois = length(obj.voDatabaseRegionsOfInterest);
            vbRoiHasPolygons = false(1,dNumRois);
            
            oImageVolumeObject = obj.GetImageVolumeObject();
            oRoisObject = oImageVolumeObject.GetRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                vbRoiHasPolygons(dRoiIndex) = oRoisObject.GetNumberOfPolygonsByRegionOfInterestNumber(dRoiIndex) > 0;
            end
            
            voRois = obj.voDatabaseRegionsOfInterest(vbRoiHasPolygons);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> SETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function SetPreferredImageVolumeDisplayThreshold(obj, vdDisplayThreshold)
            arguments
                obj (1,1) DatabaseImageVolume
                vdDisplayThreshold (1,2) double {ValidationUtils.MustBeIncreasing}
            end
            
            obj.vdPreferredImageVolumeDisplayThreshold = vdDisplayThreshold;
        end
    end
    
    
    methods (Access = protected)
        
        function saveObj = saveobj(obj)
            saveObj = obj;
            saveObj.oCachedImageVolume = []; % don't want the image volume object with the database
        end 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
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

