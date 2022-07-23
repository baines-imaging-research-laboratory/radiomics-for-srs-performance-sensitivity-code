classdef DatabaseImagingStudy < handle
    %ImagingStudy
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)        
        dStudyNumber double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger}
        
        dtImagingDate datetime {ValidationUtils.MustBeEmptyOrScalar}
        voDatabaseImageVolumes (1,:) DatabaseImageVolume = DatabaseImageVolume.empty(1,0)
        
        chRawDataDirectoryPath (1,:) char
        chImageDatabaseDirectoryPath (1,:) char
        
        vdRegionOfInterestNumberInContouredImageVolumePerTumour (1,:) double
        veVisibilityAndContouringStateInContouredImageVolumePerTumour (1,:) TumourVisibilityAndContouringStates
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DatabaseImagingStudy(dStudyNumber, dtImagingDate, chRawDataDirectoryPath, chImageDatabaseDirectoryPath, voDatabaseImageVolumes)
            obj.dStudyNumber = dStudyNumber;
            obj.dtImagingDate = dtImagingDate;
                        
            obj.chRawDataDirectoryPath = chRawDataDirectoryPath;
            obj.chImageDatabaseDirectoryPath = chImageDatabaseDirectoryPath;
            
            obj.voDatabaseImageVolumes = voDatabaseImageVolumes;
        end
        
        function Update(obj)
            
            % update contained objects
            
            for dImageVolumeIndex=1:length(obj.voDatabaseImageVolumes)
                obj.voDatabaseImageVolumes(dImageVolumeIndex).Update();
            end
        end
        
        function dNumDays = GetNumberOfDaysFromDate(obj, dtDate)
            dNumDays = days(obj.dtImagingDate - dtDate);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> IMAGE VOLUME GETTERS <<<<<<<<<<<<<<<<<<<<<<
                
        function voDatabaseImageVolumes = GetImageVolumes(obj)
            voDatabaseImageVolumes = obj.voDatabaseImageVolumes;
        end
        
        function dNumVolumes = GetNumberOfImageVolumes(obj)
            dNumVolumes = length(obj.voDatabaseImageVolumes);
        end
        
        function oImagingSeries = GetImageVolumeByVolumeNumber(obj, dVolumeNum)
            oImagingSeries = [];
            
            for dVolumeIndex=1:length(obj.voDatabaseImageVolumes)
                if obj.voDatabaseImageVolumes(dVolumeIndex).GetVolumeNumber() == dVolumeNum
                    oImagingSeries = obj.voDatabaseImageVolumes(dVolumeIndex);
                    break;
                end
            end
        end
        
        function oDatabaseImageVolume = GetContouredImageVolume(obj)
            dNumSeries = length(obj.voDatabaseImageVolumes);
            
            vbIncludeImagingSeries = false(dNumSeries,1);
            
            for dVolumeIndex=1:dNumSeries
                if obj.voDatabaseImageVolumes(dVolumeIndex).IsContoured()
                    vbIncludeImagingSeries(dVolumeIndex) = true;
                end
            end
            
            voDatabaseImageVolumes = obj.voDatabaseImageVolumes(vbIncludeImagingSeries);
            
            if length(voDatabaseImageVolumes) ~= 1
                error(...
                    'DatabaseImagingStudy:GetContouredImageVolume:SingleImageVolumeNotFound',...
                    '0 or multiple contoured Image Volumes found.');
            end
            
            oDatabaseImageVolume = voDatabaseImageVolumes(1);
        end
        
        function voDatabaseImageVolumes = GetContouredImageVolumes(obj)
            dNumVolumes = length(obj.voDatabaseImageVolumes);
            
            vbIncludeImagingSeries = false(dNumVolumes,1);
            
            for dVolumeIndex=1:dNumVolumes
                if obj.voDatabaseImageVolumes(dVolumeIndex).IsContoured()
                    vbIncludeImagingSeries(dVolumeIndex) = true;
                end
            end
            
            voDatabaseImageVolumes = obj.voDatabaseImageVolumes(vbIncludeImagingSeries);            
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                    
        function dStudyNumber = GetStudyNumber(obj)
            dStudyNumber = obj.dStudyNumber;
        end
        
        function dtImagingDate = GetImagingDate(obj)
            dtImagingDate = obj.dtImagingDate;
        end
        
        function chDirectoryPath = GetRawDataDirectoryPath(obj)
            chDirectoryPath = obj.chRawDataDirectoryPath;
        end
        
        function chDirectoryPath = GetImageDatabaseDirectoryPath(obj)
            chDirectoryPath = obj.chImageDatabaseDirectoryPath;
        end
        
        function vdRegionOfInterestNumberInContouredImageVolumePerTumour = GetRegionOfInterestNumberInContouredImageVolumePerTumour(obj)
            vdRegionOfInterestNumberInContouredImageVolumePerTumour = obj.vdRegionOfInterestNumberInContouredImageVolumePerTumour;
        end
        
        function veVisibilityAndContouringStateInContouredImageVolumePerTumour = GetVisibilityAndContouringStateInContouredImageVolumePerTumour(obj)
            veVisibilityAndContouringStateInContouredImageVolumePerTumour = obj.veVisibilityAndContouringStateInContouredImageVolumePerTumour;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> SETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function SetRegionOfInterestNumberInContouredImageVolumePerTumour(obj, vdRegionOfInterestNumberInContouredImageVolumePerTumour)
            obj.vdRegionOfInterestNumberInContouredImageVolumePerTumour = vdRegionOfInterestNumberInContouredImageVolumePerTumour;
        end
        
        function SetVisibilityAndContouringStateInContouredImageVolumePerTumour(obj, veVisibilityAndContouringStateInContouredImageVolumePerTumour)
            obj.veVisibilityAndContouringStateInContouredImageVolumePerTumour = veVisibilityAndContouringStateInContouredImageVolumePerTumour;
        end
    end
end

