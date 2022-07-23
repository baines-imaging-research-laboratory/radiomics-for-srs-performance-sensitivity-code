classdef RegionOfInterestPreProcessing
    %RegionOfInterestPreProcessing
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oRegionOfInterestPreProcessing'
        
        chImageVolumeWithContoursSuffix = '[Contoured]'
        chRegionsOfInterestContoursOnlySuffix = '[Contours Only]'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = RegionOfInterestPreProcessing(sIdTag)
            arguments
                sIdTag (1,1) string
            end
            
            obj.sIdTag = sIdTag;
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function sFolder = GetImageDatabaseFolder(obj)
            if obj.sIdTag == "ROIPP-000"
                sFolder = string.empty;
            else
                sFolder = obj.sIdTag;
            end
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) RegionOfInterestPreProcessing
                chFilePath (1,:) char
            end
            
            FileIOUtils.SaveMatFile(chFilePath, RegionOfInterestPreProcessing.chMatFileVarName, obj);
        end
        
        function SaveRegionsOfInterest(obj, oRegionsOfInterest, sStudyPath, sFilename, varargin)
            arguments
                obj (1,1) RegionOfInterestPreProcessing
                oRegionsOfInterest (1,1) RegionsOfInterest
                sStudyPath (1,1) string
                sFilename (1,1) string
            end
            arguments (Repeating)
                varargin
            end
            
            sFilename = RegionOfInterestPreProcessing.ReplaceContourSuffixInFilename(sFilename);
                        
            mkdir(sStudyPath, obj.sIdTag);
            
            oRegionsOfInterest.Save(fullfile(sStudyPath, obj.sIdTag, sFilename), varargin{:});
        end
        
        function oRois = LoadRegionsOfInterest(obj, sImagingRootPath, sImageVolumeFilename)
            arguments
                obj (1,1)RegionOfInterestPreProcessing
                sImagingRootPath (1,1) string
                sImageVolumeFilename (1,1) string
            end
            
            sImageVolumeFilename = ImageVolumePreProcessing.RemoveContourSuffixInFilename(sImageVolumeFilename);
            sDatabaseFolder = obj.GetImageDatabaseFolder();
            
            if isempty(sDatabaseFolder)
                sLoadDirectory = sImagingRootPath;                
            else
                sLoadDirectory = fullfile(sImagingRootPath, obj.GetImageDatabaseFolder());
            end
            
            vsLoadFilenames = ImageVolumePreProcessing.FindValidMatFilesToLoadInDirectory(sLoadDirectory, sImageVolumeFilename);
            
            if length(vsLoadFilenames) == 1
                oRois = RegionsOfInterest.Load(fullfile(sLoadDirectory, vsLoadFilenames(1)));
            else
                error(...
                    'RegionOfInterestPreProcessing:LoadImageVolume:NoOrMultipleMatFilesFound',...
                    ['No or multiple valid mat files were found to be loaded at ', char(sLoadDirectory), ' and so no file could be loaded.']);
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, RegionOfInterestPreProcessing.chMatFileVarName);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function sFilename = ReplaceContourSuffixInFilename(sFilename)
            
            if contains(sFilename, RegionOfInterestPreProcessing.chImageVolumeWithContoursSuffix) % the filename contains '[Contoured]' and has to be changed to '[Contours Only]'
                sFilename = strrep(sFilename, RegionOfInterestPreProcessing.chImageVolumeWithContoursSuffix, RegionOfInterestPreProcessing.chRegionsOfInterestContoursOnlySuffix);
            else % the filename doesn't contain '[Contoured]' (e.g. T1 MRI.mat), so '[Contours Only]' needs to be added to it (e.g. T1 MRI [Contours Only].mat)
                [chFilename, chFileExtension] = FileIOUtils.SeperateFilePathAndFilename(sFilename);
                
                sFilename = string([chFilename, ' ', RegionOfInterestPreProcessing.chRegionsOfInterestContoursOnlySuffix, chFileExtension]);
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

