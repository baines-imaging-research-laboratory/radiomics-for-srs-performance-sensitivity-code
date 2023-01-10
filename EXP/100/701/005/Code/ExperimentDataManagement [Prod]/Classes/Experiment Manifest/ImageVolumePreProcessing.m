classdef ImageVolumePreProcessing
    %ImageVolumePreProcessing
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oImageVolumePreProcessing'        
        
        chImageVolumeWithContoursSuffix = '[Contoured]'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImageVolumePreProcessing(sIdTag)
            arguments
                sIdTag (1,1) string
            end
            
            obj.sIdTag = sIdTag;
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function sFolder = GetImageDatabaseFolder(obj)
            if obj.sIdTag == "IMGPP-000"
                sFolder = string.empty;
            else
                sFolder = obj.sIdTag;
            end
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) ImageVolumePreProcessing
                chFilePath (1,:) char
            end
            
            FileIOUtils.SaveMatFile(chFilePath, ImageVolumePreProcessing.chMatFileVarName, obj);
        end
        
        function oImageVolume = LoadImageVolume(obj, sImagingRootPath, sImageVolumeFilename)
            arguments
                obj (1,1) ImageVolumePreProcessing
                sImagingRootPath (1,1) string
                sImageVolumeFilename (1,1) string
            end
            
            oImageVolume = ImageVolume.Load(obj.GetImageVolumePath(sImagingRootPath, sImageVolumeFilename));
        end
        
        function sPath = GetImageVolumePath(obj, sImagingRootPath, sImageVolumeFilename)
            arguments
                obj (1,1) ImageVolumePreProcessing
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
                sPath = fullfile(sLoadDirectory, vsLoadFilenames(1));
            else
                error(...
                    'ImageVolumePreProcessing:GetImageVolumePath:NoOrMultipleMatFilesFound',...
                    ['No or multiple valid mat files were found to be loaded at ', char(sLoadDirectory), ' and so no file could be loaded.']);
            end
        end
        
        function oImageVolume = LoadImageVolumeWithNoContours(obj, sStudyPath, sFilename)
            arguments
                obj (1,1) ImageVolumePreProcessing
                sStudyPath (1,1) string
                sFilename (1,1) string
            end
            
            sFilename = ImageVolumePreProcessing.RemoveContourSuffixInFilename(sFilename);
            
            oImageVolume = ImageVolume.Load(fullfile(sStudyPath, obj.sIdTag, sFilename));
        end
        
        function SaveImageVolumeWithNoContours(obj, oImageVolume, sStudyPath, sFilename, varargin)
            arguments
                obj (1,1) ImageVolumePreProcessing
                oImageVolume (1,1) ImageVolume
                sStudyPath (1,1) string
                sFilename (1,1) string
            end
            arguments (Repeating)
                varargin
            end
            
            sFilename = ImageVolumePreProcessing.RemoveContourSuffixInFilename(sFilename);
                        
            mkdir(sStudyPath, obj.sIdTag);
            
            oImageVolume.Save(fullfile(sStudyPath, obj.sIdTag, sFilename), varargin{:});
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ImageVolumePreProcessing.chMatFileVarName);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function sFilename = RemoveContourSuffixInFilename(sFilename)
            
            if contains(sFilename, ImageVolumePreProcessing.chImageVolumeWithContoursSuffix)
                sFilename = strrep(...
                    sFilename,...
                    [' ', ImageVolumePreProcessing.chImageVolumeWithContoursSuffix],...
                    '');
            end
        end
        
        function sImageVolumeFilename = ImageVolumePreProcessing.AddedContourSuffixToFilename(sImageVolumeFilename)
            [chFileName, chExtension] = FileIOUtils.SeparateFilePathExtension(sImageVolumeFilename);
            
            sImageVolumeFilename = string([chFileName, ' ', ImageVolume.chImageVolumeWithContoursSuffix, chExtension]);
        end
        
        function vsLoadFilenames = FindValidMatFilesToLoadInDirectory(sDirectoryPath, sImageVolumeFilename)
            voEntries = dir(sDirectoryPath);
            dNumEntries = length(voEntries);
            
            vbValidEntry = false(dNumEntries,1);
            
            chImageVolumeFilename = FileIOUtils.SeparateFilePathExtension(sImageVolumeFilename);
            
            for dEntryIndex=1:dNumEntries
                oEntry = voEntries(dEntryIndex);
                
                if ~oEntry.isdir
                    [chFilename, chFileExtension] = FileIOUtils.SeparateFilePathExtension(oEntry.name);                    
                    
                    if contains(chFilename, chImageVolumeFilename) && strcmp(chFileExtension, '.mat')
                        vbValidEntry(dEntryIndex) = true;
                    end
                end
            end
            
            voValidEntries = voEntries(vbValidEntry);
            dNumValidEntries = length(voValidEntries);
            
            vsLoadFilenames = strings(dNumValidEntries,1);
            
            for dEntryIndex=1:dNumValidEntries
                vsLoadFilenames(dEntryIndex) = string(voValidEntries(dEntryIndex).name);
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

