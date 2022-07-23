classdef MATLABImageVolume < ImageVolume
    %MATLABImageVolume
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public)
        chFilePath = ''
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = MATLABImageVolume(m3xImageData, oImageVolumeGeometry, oRegionsOfInterest)
            %obj = MATLABImageVolume(varargin)
            %
            % SYNTAX:            
            %  obj = MATLABImageVolume(m3xImageData, oImageVolumeGeometry)
            %  obj = MATLABImageVolume(__, __, oRegionsOfInterest)
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
                m3xImageData (:,:,:) {mustBeNumeric}
                oImageVolumeGeometry (1,1) ImageVolumeGeometry
                oRegionsOfInterest = MATLABLabelMapRegionsOfInterest.empty
            end
                        
            if ~isempty(oRegionsOfInterest)
                c1xSuperClassVarargin = {oImageVolumeGeometry, oRegionsOfInterest};
            else
                c1xSuperClassVarargin = {oImageVolumeGeometry};
            end
            
            c1xSuperClassVarargin = [c1xSuperClassVarargin, {'ImageData', m3xImageData}];
            
            % super-class constructor
            obj@ImageVolume(c1xSuperClassVarargin{:});
        end
        
        function chFilePath = GetOriginalFilePath(obj)
            if isempty(obj.chFilePath)
                chFilePath = 'Not saved to disk.';
            else
                chFilePath = obj.chFilePath;                
            end            
        end
                          
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>> FILE I/O <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    
        function UnloadVolumeData(obj)
            % overwriting superclass
            if isempty(obj.chFilePath) && isempty(obj.chMatFilePath)% not saved, can't unload
                
            else
                UnloadVolumeData@ImageVolume(obj);
            end
        end
        
        function Save(obj, chMatFilePath, bForceApplyAllTransforms, varargin)
            arguments
                obj
                chMatFilePath (1,:) char
                bForceApplyAllTransforms (1,1) logical = false
            end
            arguments (Repeating)
                varargin
            end
            
            if obj.dCurrentAppliedImagingObjectTransform == 1 % no transforms have happened yet, so we can set this to be the "original data"
                obj.chFilePath = FileIOUtils.GetAbsolutePath(chMatFilePath);
            end 
            
            Save@ImageVolume(obj, chMatFilePath, bForceApplyAllTransforms, varargin{:});
                       
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@ImageVolume(obj);
        end
        
        function m3xImageData = LoadOriginalImageData(obj)
            if ~isempty(obj.chFilePath)
                m3xImageData = FileIOUtils.LoadMatFile(obj.chFilePath, ImageVolume.chImageDataMatFileVarName);
            else
                error(...
                    'MATLABImageVolume:LoadOriginalImageData:OriginalDataNotSavedToDisk',...
                    'The original data was never saved to disk, and so cannot be retreived.');
            end
        end
        
        function saveObj = saveobj(obj)
            % super-class call
            saveObj = saveobj@ImageVolume(obj);
            
            % error if data hasn't been saved via "Save"
            if isempty(obj.chMatFilePath)
                error(...
                    'MATLABImageVolume:saveobj:NotSavedToDisk',...
                    'The MATLABImageVolume object has not been saved using the ".Save()" command, and therefore no copy of it''s image data is on disk. If the current save was performed it WOULD NOT maintain a copy of the image data within the MATLABImageVolume object, and so the saved copy of the object would be useless.');
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true) % None
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


