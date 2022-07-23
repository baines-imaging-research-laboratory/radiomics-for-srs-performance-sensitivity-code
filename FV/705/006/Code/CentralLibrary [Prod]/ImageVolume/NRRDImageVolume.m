classdef NRRDImageVolume < ImageVolume
    %NRRDImageVolume
    %   - uses the NRRD reader by Rensonnet:
    %     https://www.mathworks.com/matlabcentral/fileexchange/66645-nrrd-nhdr-reader-and-writer\
    %     which was built on Maher's (Matlab staff) reader:
    %     http://nl.mathworks.com/matlabcentral/fileexchange/34653-nrrd-format-file-reader
    % CAVEATs: 
    %   - Assumes non-oblique geometries
    %   - Expects LPS orientation 
    %   
    
    % Primary Author: Salma Dammak
    % Created: March 9th, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        chFilePath = []        
        stFileMetadata = []
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = NRRDImageVolume(chFilePathOrName, varargin)
            %obj = NRRDImageVolume(chFilePath)
            %obj = NRRDImageVolume(chFilePath, oRegionsOfInterest)
            %
            % SYNTAX:
            %  obj = NRRDmageVolume(sFeatureSource, chFilePath, oRegionsOfInterest, sUserDefinedIdTag)
            %  obj = MATLABImageVolume(__, __, __, __, vdDisplayMinMax)
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
            
            chFilePath = FileIOUtils.GetAbsolutePathForExistingFiles(chFilePathOrName);
            
            % Checks that the file exists
            if isempty(chFilePath)
                error("NRRDImageVolume:FileNotFound",...
                    "File not found." + newline + "Path: " +...
                    strrep(string(chFilePathOrName),'\','\\'))
            end
            
            % Get the file info
            stFileMetaData = nhdr_nrrd_read(chFilePath, false);
                        
            oImageVolumeGeometry = NRRDImageVolume.GetImageVolumeGeometryFromFileMetaData(stFileMetaData);
                          
            if ~isempty(varargin)
                oRegionsOfInterest = varargin{1};
                
                c1xSuperArgs = {oImageVolumeGeometry, oRegionsOfInterest};
            else
                c1xSuperArgs = {oImageVolumeGeometry};
            end
            
            % super-class constructor
            obj@ImageVolume(c1xSuperArgs{:});            
            
            % set class properities
            obj.chFilePath = chFilePath;
            
            obj.stFileMetadata = stFileMetaData;
        end
        
        function chFilePath = GetOriginalFilePath(obj)
            chFilePath = obj.chFilePath;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@ImageVolume(obj);
            
            % local call
            % no deep copies required
        end
        
        function m3xImageData = LoadOriginalImageData(obj)
            
            stFileMetaData = nhdr_nrrd_read(obj.chFilePath, true);            
            m3xImageData = stFileMetaData.data;
            
            % The nrrdread function I use is oriented incorrectly. 
            % I made these transforms to get it to match what I was seeing
            % on ITK Snap
            %m3xImageData = flip(m3xImageData,3); 
%             m3xImageData = flip(m3xImageData,2);    
%             m3xImageData = flip(m3xImageData,1);   
%             m3xImageData = imrotate3(m3xImageData,90,[0 0 1]);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true) 
        
        function oImageVolumeGeometry = GetImageVolumeGeometryFromFileMetaData(stFileMetaData)
                        
            vdVolumeDimensions = stFileMetaData.sizes; 
            vdVoxelDimensions_mm = NRRDImageVolume.ParseSpaceDirections([stFileMetaData.spacedirections{:}]);
            
            vdFirstVoxelPosition_mm = stFileMetaData.spaceorigin'; % in oroginal orientation, not RAS

            
            % Get direction                   
            vsThreeLetterSpace = NRRDImageVolume.ParseSpace(stFileMetaData.space);
            
            if strcmp(vsThreeLetterSpace(1),'l') && strcmp(vsThreeLetterSpace(2),'p')
                vdColAxisUnitVector = [0 -1 0];
                vdFirstVoxelPosition_mm(1) = -vdFirstVoxelPosition_mm(2);           
                vdRowAxisUnitVector = [-1 0 0];
                vdFirstVoxelPosition_mm(2) = -vdFirstVoxelPosition_mm(1);
            else
                error("NRRDImageVolume:oImageVolumeGeometry",...
                    "This class currently only handles images where the space is "+...
                    "left-anterior-superior (found under space in the header), if your NRRD "+...
                    "image is different you will need to modify this class.");
            end          
            
            % Because of the flip we do in the third dimension, we have to adjust where the original
            % voxel actually is. The line below works ONLY if the geometry is non-oblique.
            vdFirstVoxelPosition_mm(3) = vdFirstVoxelPosition_mm(3) + (vdVolumeDimensions(3)-1) * vdVoxelDimensions_mm(3);
            
            oImageVolumeGeometry = ImageVolumeGeometry(...
                vdVolumeDimensions,...
                vdRowAxisUnitVector, vdColAxisUnitVector,...
                vdVoxelDimensions_mm, vdFirstVoxelPosition_mm);
        end
        
        function vdSpaceDirections = ParseSpaceDirections(chSpaceDirections)
            % From the documentation:
            % "For each of the axes of the array, this vector gives the difference in position 
            %   associated with incrementing (by one) the corresponding coordinate in the array".
            % Given that we don't get a pixel width in addition to pixel spacing, I will assume that
            % they ar eequal and that this spacing also gives th epixel width.
            
            vdSpaceDirections = nan(1,3);
            c1c1chAll = regexp(chSpaceDirections,...
                '\((\S*),\S*,\S*\)\(\S*,(\S*),\S*\)\(\S*,\S*,(\S*)\)','tokens');
            if any(cellfun(@(c) isempty(c), c1c1chAll))
                error("NRRDImageVolume:ParseSpaceDirections:UnexpectedFormat",...
                    "Space directions could not be parsed out from the image header. "+...
                    "The header string is " + newline + string(chSpaceDirections) +...
                    newline + "but this format is expected: "+...
                    "(num, 0, 0)(0, num, 0)(0, 0, num)" )
            end
            
            c1chAll = c1c1chAll{1}; 
            if length(c1chAll) ~= 3
                error("NRRDImageVolume:ParseSpaceDirections:NotThreeDirections",...
                    "The number of space directions found in this image is "+...
                    "not equal to three. To debug, load image directly using "+...
                    "headerInfo = nhdr_nrrd_read(imagePath, true) and ensure that "+...
                    "headerInfo.spacedirections is of the format: "+...
                    "(num, 0, 0)(0, num, 0)(0, 0, num)" )
            end
            
            for i = 1:3 
                vdSpaceDirections(i) = str2double(c1chAll{i});
            end
        end
                
        function vsThreeLetterSpace = ParseSpace(chSpace)
            %[l,p,s] or [r,a,s] for now
            
            c1c1chAll = regexp(chSpace, '(\w)\w*-(\w)\w*-(\w)\w*','tokens');%TODO: check for empty TODO: check for other spaces in NRRD definition
            vsThreeLetterSpace = string(c1c1chAll{1}); %TODO: check for empty
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


