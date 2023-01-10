classdef (Abstract) RegionsOfInterest < GeometricalImagingObject
    %RegionsOfInterest
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = protected, GetAccess = public)    
        dNumberOfRegionsOfInterest = []
    end
    
    properties (SetAccess = protected, GetAccess = public)    
        chMatFilePath = ''
    end
    
    properties (Constant = true, GetAccess = protected)
        dDefaultRenderAlpha = 0.25
        bDefaultRenderShowEdges = false
        
        dDefaultRenderPlaneVoxelOverlayAlpha = 0.5
        
        chObjMatFileVarName = 'oRegionsOfInterest'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract = true)   
        LoadVolumeData(obj)
        
        UnloadVolumeData(obj)
                  
        m3bMask = GetMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
        
        InterpolateOntoTargetGeometry(obj, oTargetImageVolumeGeometry, chInterpolationMethod)        
    end
    
    methods (Access = public)
        
        function obj = RegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest)
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
            
            % Super-class constructor
            obj@GeometricalImagingObject(oOnDiskImageVolumeGeometry);
            
            % Validation
            RegionsOfInterest.ValidateNumberOfRegionsOfInterest(dNumberOfRegionsOfInterest);
                        
            % Set properities
            obj.dNumberOfRegionsOfInterest = dNumberOfRegionsOfInterest;
        end  
        
        
        
        function SetMatFilePath(obj, chNewMatFilePath)
            arguments
                obj (1,1) RegionsOfInterest
                chNewMatFilePath (1,:) char
            end
            
            obj.chMatFilePath = chNewMatFilePath;
        end
        
        function dNumberOfRegionsOfInterest = GetNumberOfRegionsOfInterest(obj)
            dNumberOfRegionsOfInterest = obj.dNumberOfRegionsOfInterest;
        end
        
        function c1m3bMasks = GetMasks(obj)
            obj.ForceApplyAllTransforms();
            
            dNumRois = obj.GetNumberOfRegionsOfInterest();
            
            c1m3bMasks = cell(1,dNumRois);
            
            for dRoiIndex=1:dNumRois
                c1m3bMasks{dRoiIndex} = obj.GetMaskByRegionOfInterestNumber(dRoiIndex);
            end
        end
        
        function MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumber)
            arguments
                obj
                vdRegionOfInterestNumber (1,:) double {mustBeInteger, mustBePositive}
            end
            
            % all validation taken care of above
            if any(vdRegionOfInterestNumber > obj.GetNumberOfRegionsOfInterest())
                error(...
                    'RegionsOfInterest:MustBeValidRegionOfInterestNumber:Invalid',...
                    'Region of interest numbers must be less than or equal to the number of regions of interest');
            end
        end
        
        function Save(obj, chMatFilePath, bForceApplyAllTransforms, bAppend, varargin)
            arguments
                obj
                chMatFilePath (1,:) char = ''
                bForceApplyAllTransforms (1,1) logical = false
                bAppend (1,1) logical = false
            end
            arguments (Repeating)
                varargin
            end
            
            if isempty(chMatFilePath)
                if isempty(obj.chMatFilePath)
                    error(...
                        'RegionsOfInterest:Save:NotPreviouslySaved',...
                        'The RegionsOfInterest object has not yet been saved, and so .Save cannot be called without any input arguments.');
                else
                    chMatFilePath = obj.chMatFilePath;
                end
            end
            
            obj.LoadVolumeData(); % we're going to have to load the data if we're going to resave it
            
            if ~obj.AreAllTransformsApplied()
                if bForceApplyAllTransforms
                    obj.ForceApplyAllTransforms();
                else
                    warning(...
                        'RegionsOfInterest:Save:NotAllTransformsApplied',...
                        'Not all transforms have been applied to the image data matrix that is being saved to disk. Use obj.ForceApplyAllTransforms() or the bForceApplyAllTransforms flag for this function if you want all transforms to be applied.');                     
                end
            end
            
            [chFilePath,chFilename] = FileIOUtils.SeparateFilePathAndFilename(chMatFilePath);
            [~, chFileExtension] = FileIOUtils.SeparateFilePathExtension(chFilename);
            
            if ~isempty(chFilePath) && exist(chFilePath,'dir') ~= 7
                error(...
                    'RegionsOfInterest:SaveTransformedData:InvalidDirectory',...
                    'The provided directory does not exist.');
            end
            
            if ~strcmp(chFileExtension, '.mat')
                error(...
                    'RegionsOfInterest:SaveTransformedData:InvalidFileType',...
                    'RegionsOfInterest objects must be saved to .mat files.');
            end
            
            % set temporarily (full path to be saved after, this just helps
            % objects in checking whether data can be unloaded or not)
            obj.chMatFilePath = chMatFilePath;
              
            % get ROI vars
            c1xRoiDataNameValuePairs = obj.GetNameValuePairsForSave(chMatFilePath);
            
            % add append flag if needed
            if bAppend
                c1xRoiDataNameValuePairs = [c1xRoiDataNameValuePairs, {'-append'}];
            end
            
            % save
            FileIOUtils.SaveMatFile(chMatFilePath,...                
                RegionsOfInterest.chObjMatFileVarName, obj,...
                c1xRoiDataNameValuePairs{:},...
                varargin{:});
            
            % set .mat file path
            obj.chMatFilePath = FileIOUtils.GetAbsolutePath(chMatFilePath);            
        end
        
        function chMatFilePath = GetMatFilePath(obj)
            chMatFilePath = obj.chMatFilePath;
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chMatFilePath)
            arguments
                chMatFilePath (1,:) char {RegionsOfInterest.MustBeValidMatFilePath}
            end
            
            obj = FileIOUtils.LoadMatFile(chMatFilePath, RegionsOfInterest.chObjMatFileVarName);
            
            if ~isa(obj, 'RegionsOfInterest')
                error(...
                    'RegionsOfInterest:Load:InvalidRegionsOfInterestClass',...
                    ['The "', RegionsOfInterest.chObjMatFileVarName,'" property within the .mat file must be of type RegionsOfInterest.']);
            end
            
            % set chMatFilePath just in case file was moved since it was
            % saved
            obj.chMatFilePath = FileIOUtils.GetAbsolutePath(chMatFilePath);
            
            % validate that the child class is happy about the mat file
            obj.MustBeValidMatFilePath_ChildClass(chMatFilePath);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    
    methods (Access = protected, Static = true)
        
        function MustBeValidMatFilePath(chMatFilePath)
            % TODO
            if ~RegionsOfInterest.IsValidMatFilePath(chMatFilePath)
                error(...
                    'RegionsOfInterest:ValidateMatFilePath:InvalidMatFile',...
                    ['The given .mat file did not a property named "', RegionsOfInterest.chObjMatFileVarName, '".']);
            end
        end
    end
    
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@GeometricalImagingObject(obj);
            
            % local call
            % - no deep copy required
        end
    end
    
    
    methods (Access = protected, Abstract = true)
        
        c1xRoiDataNameValuePairs = GetNameValuePairsForSave(obj, chMatFilePath)
        MustBeValidMatFilePath_ChildClass(chMatFilePath)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = ?ImageVolume, Static = true)
        
        function bBool =  IsValidMatFilePath(chMatFilePath)            
            oMatfile = matfile(chMatFilePath);
            
            vsFileEntries = whos(oMatfile);
            
            bRegionsOfInterestFound = false;
                        
            for dEntryIndex=1:length(vsFileEntries)
                sEntry = vsFileEntries(dEntryIndex);
                
                % check if entry is image volume object
                if strcmp(sEntry.name, RegionsOfInterest.chObjMatFileVarName)
                    % check that the class is correct
                    bRegionsOfInterestFound = true;
                end
            end
            
            bBool = bRegionsOfInterestFound;
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function ValidateNumberOfRegionsOfInterest(dNumberOfRegionsOfInterest)
            % TODO
            
            if ~isscalar(dNumberOfRegionsOfInterest) || ~isa(dNumberOfRegionsOfInterest, 'double')
                error(...
                    'RegionsOfInterest:ValidateVoxelDimensions_mm:Invalid',...
                    'NumberOfRegionsOfInterest must be scalar of type double.');
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


