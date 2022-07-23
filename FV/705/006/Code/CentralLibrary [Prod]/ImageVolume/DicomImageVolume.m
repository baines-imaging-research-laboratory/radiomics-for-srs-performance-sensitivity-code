classdef DicomImageVolume < ImageVolume
    %DicomImageVolume
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        chFilePath = []
        stFileMetadata = []
        
        c1chOrderedSliceFilenames = {} % filename 1 gives slice 1, etc.
    end    
    
    properties (Constant = true, GetAccess = private) 
        chDicomFileExtension = '.dcm'
        
        dSliceSpacingDifferenceWarningLimit_mm = 0.1
        dSliceSpacingDifferenceErrorLimit_mm = 0.5
        dSliceSpacingIs0Limit_mm = 1E-6
        
        dSliceDeltaDivisionByZeroBound = 1E-3
        dUnitVectorDivisionByZeroBound = 1E-6
        
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = DicomImageVolume(chFilePath, varargin)
            %obj = DicomImageVolume(chFilePath, varargin)
            %
            % SYNTAX:
            %  obj = DicomImageVolume(chFilePath)
            %  obj = DicomImageVolume(chFilePath, oRegionsOfInterest)
            %  obj = DicomImageVolume(chFilePath, chRTStructFilePath)
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  chFilePath: File path to a Dicom file. If the file is part
            %              of series over multiple files, all Dicom files
            %              within the same directory will also be loaded.
            %  oRegionsOfInterest: A regions of interest object with a
            %                      matching geometry to the image volume
            %                      being loaded
            % chRTStructFilePath: File path to a Dicom RT Struct file. This
            %                     file will be loaded as a
            %                     DicomRTStructLabelMapRegionsOfInterest
            %                     object that must have a matching geometry
            %                     to the image volume being loaded
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            
            stFileMetadata = dicominfo(chFilePath, 'UseVRHeuristic', false, 'UseDictionaryVR', true);
            chAbsoluteFilePath = FileIOUtils.GetAbsolutePath(chFilePath);
            
            [oImageVolumeGeometry, c1chOrderedSliceFilenames] = DicomImageVolume.GetImageVolumeGeometryFromImageDirectoryAndFileMetaData(chFilePath, stFileMetadata, chAbsoluteFilePath);
                          
            if length(varargin) == 1
                if isa(varargin{1}, 'RegionsOfInterest') % RegionsOfInterest object passed in
                    oRegionsOfInterest = varargin{1};
                    
                    ValidationUtils.MustBeA(oRegionsOfInterest, 'RegionsOfInterest');
                    ValidationUtils.MustBeScalar(oRegionsOfInterest);                
                else % assume that path to Dicom RT struct pass in
                    chRtStructFilePath = char(varargin{1});
                                        
                    ValidationUtils.MustBeRowVector(chRtStructFilePath);
                    
                    oImageVolumeNoRois = DicomImageVolume(chFilePath); % needed to create the regions of interest object
                    
                    oRegionsOfInterest = DicomRTStructLabelMapRegionsOfInterest(chRtStructFilePath, oImageVolumeNoRois);
                end
                
                c1xSuperArgs = {oImageVolumeGeometry, oRegionsOfInterest};
            elseif isempty(varargin)
                c1xSuperArgs = {oImageVolumeGeometry};
            else
                error(...
                    'DicomImageVolume:Constructor:InvalidNumberOfParameters',...
                    'See constructor documentation for details.');
            end
            
            % super-class constructor
            obj@ImageVolume(c1xSuperArgs{:});            
            
            % set class properities
            obj.chFilePath = chFilePath;
            obj.stFileMetadata = stFileMetadata;
            obj.c1chOrderedSliceFilenames = c1chOrderedSliceFilenames;
        end
        
        function stFileMetadata = GetFileMetadata(obj)
            % TODO
            
            stFileMetadata = obj.stFileMetadata;
        end        
        
        function chFilePath = GetOriginalFilePath(obj)
            % TODO
            
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
        end
        
        function m3xImageData = LoadOriginalImageData(obj)
            % TODO
            
            dMultiplicativeScaling = 1;
            dAdditiveOffset = 0;
            
            [chPath, ~] = FileIOUtils.SeparateFilePathAndFilename(obj.chFilePath);
            
            m2xFirstSlice = dicomread(fullfile(chPath, obj.c1chOrderedSliceFilenames{1}));
            
            vdVolumeDimensions = obj.GetOnDiskImageVolumeGeometry().GetVolumeDimensions();
            
            m3xImageData = zeros(vdVolumeDimensions, class(m2xFirstSlice));
            
            m3xImageData(:,:,1) = m2xFirstSlice;
                
            for dSliceIndex=2:vdVolumeDimensions(3)
                m3xImageData(:,:,dSliceIndex) = dicomread(fullfile(chPath, obj.c1chOrderedSliceFilenames{dSliceIndex}));
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = ?DicomRTDoseVolume, Static = true)
        
        function [vdRowAxisUnitVector, vdColAxisUnitVector, vdFirstVoxelPosition_mm, vdVolumeDimensions, vdVoxelDimensions_mm] = GetImageVolumeGeometryPortionsFromFileMetadata(stFileMetaData)
            % extract the image volume geometry from the metadata
            vdRowAxisUnitVector = stFileMetaData.ImageOrientationPatient(4:6)';
            vdColAxisUnitVector = stFileMetaData.ImageOrientationPatient(1:3)';
            
            vdFirstVoxelPosition_mm = stFileMetaData.ImagePositionPatient';
            
            vdVolumeDimensions = double([stFileMetaData.Rows, stFileMetaData.Columns, 0]);
            vdVoxelDimensions_mm = [stFileMetaData.PixelSpacing', 0];
            
            % Transform from LPS coordinate system (what DICOM uses) to RAS
            % (what ImageVolume uses)
            
            vdRowAxisUnitVector(1:2) = -vdRowAxisUnitVector(1:2);
            vdColAxisUnitVector(1:2) = -vdColAxisUnitVector(1:2);
            vdFirstVoxelPosition_mm(1:2) = -vdFirstVoxelPosition_mm(1:2);
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function [oImageVolumeGeometry, c1chOrderedSliceFilenames] = GetImageVolumeGeometryFromImageDirectoryAndFileMetaData(chMasterSliceFilePath, stMasterSliceFileMetaData, chAbsoluteFilePath)
            % TODO
            
            % extract the image volume geometry from the metadata
            [vdRowAxisUnitVector, vdColAxisUnitVector, vdMasterSliceFirstVoxelPosition_mm, vdVolumeDimensions, vdVoxelDimensions_mm] = ...
                DicomImageVolume.GetImageVolumeGeometryPortionsFromFileMetadata(stMasterSliceFileMetaData);
                       
            dSliceThickness_mm = stMasterSliceFileMetaData.SliceThickness;            
            vdAlongSliceAxisUnitVector = cross(vdRowAxisUnitVector, vdColAxisUnitVector);
            
            % find other slices in the given directory
            [chPath, ~] = FileIOUtils.SeparateFilePathAndFilename(chAbsoluteFilePath);
            
            vstDirEntries = dir(chPath);
            dNumEntries = length(vstDirEntries);
            
            c1stFileMetadata = cell(dNumEntries,1);
            vbFilePartOfSeries = false(dNumEntries,1);
            
            for dIndex=1:dNumEntries
                chFilename = vstDirEntries(dIndex).name;
                
                if ~vstDirEntries(dIndex).isdir
                    [~, chExtension] = FileIOUtils.SeparateFilePathExtension(chFilename);
                    
                    if strcmp(chExtension, DicomImageVolume.chDicomFileExtension)
                        stSliceMetadata = dicominfo(fullfile(chPath, chFilename), 'UseVRHeuristic', false, 'UseDictionaryVR', true);
                                                
                        if strcmp(stMasterSliceFileMetaData.SeriesInstanceUID, stSliceMetadata.SeriesInstanceUID)
                            vbFilePartOfSeries(dIndex) = true;
                            c1stFileMetadata{dIndex} = stSliceMetadata;
                        end
                    end
                end
            end
            
            dNumSlices = sum(vbFilePartOfSeries);
            vdVolumeDimensions(3) = dNumSlices;
            
            c1chOrderedSliceFilenames = cell(dNumSlices,1);
            vdSliceLocationsRelativeToMasterSlice_mm = zeros(dNumSlices,1);
            
            vdDirEntriesInSeries = find(vbFilePartOfSeries);
            
            for dFileIndex=1:dNumSlices
                c1chOrderedSliceFilenames{dFileIndex} = vstDirEntries(vdDirEntriesInSeries(dFileIndex)).name;
                
                vdSliceFirstVoxelPosition = c1stFileMetadata{vdDirEntriesInSeries(dFileIndex)}.ImagePositionPatient';
                vdSliceFirstVoxelPosition(1:2) = -vdSliceFirstVoxelPosition(1:2);
                
                vdBetweenSliceDelta = (vdSliceFirstVoxelPosition - vdMasterSliceFirstVoxelPosition_mm);
                
                if any(abs(vdAlongSliceAxisUnitVector) < DicomImageVolume.dUnitVectorDivisionByZeroBound)
                    if ~all(vdBetweenSliceDelta == 0) && any(...
                            xor(...
                            abs(vdBetweenSliceDelta) < DicomImageVolume.dSliceDeltaDivisionByZeroBound,...
                            abs(vdAlongSliceAxisUnitVector) < DicomImageVolume.dUnitVectorDivisionByZeroBound))
                        error(...
                            'DicomImageVolume:Constructor:InvalidDivideByZero',...
                            'If the slice axis unit vector has zero values, the difference between the first voxel positions in the values must also be zero.');
                    else
                        vbInclude = abs(vdAlongSliceAxisUnitVector) >= DicomImageVolume.dUnitVectorDivisionByZeroBound;
                        
                        vdDivisionVector = vdAlongSliceAxisUnitVector(vbInclude);
                        vdBetweenSliceDelta = vdBetweenSliceDelta(vbInclude);
                        
                        vdBetweenSliceDelta = vdBetweenSliceDelta ./ vdDivisionVector;
                    end
                else
                    vdBetweenSliceDelta = vdBetweenSliceDelta ./ vdAlongSliceAxisUnitVector;
                end
                
                vdSliceLocationsRelativeToMasterSlice_mm(dFileIndex) = mean(vdBetweenSliceDelta);                                
            end
            
            [vdSliceLocationsRelativeToMasterSlice_mm, vdSortIndices] = sort(vdSliceLocationsRelativeToMasterSlice_mm, 'ascend');
            c1chOrderedSliceFilenames = c1chOrderedSliceFilenames(vdSortIndices);
            
            if dNumSlices == 1 % have to rely on the slice thickness
                if isempty(dSliceThickness_mm)
                    error(...
                        'DicomImageVolume:GetImageVolumeGeometryFromImageDirectoryAndFileMetaData:CannotCalculateVoxelDimension',...
                        'Only a single slice was found with no slice thickness value given. Therefore the third voxel dimension cannot be found.');
                end
                
                vdVoxelDimensions_mm(3) = dSliceThickness_mm;
                vdFirstVoxelPosition_mm = vdMasterSliceFirstVoxelPosition_mm;
            else % base it on how spaced out the slices are (all have to be equally spaced)
                vdSliceSpacings_mm = vdSliceLocationsRelativeToMasterSlice_mm(2:end) - vdSliceLocationsRelativeToMasterSlice_mm(1:end-1);
                        
                dSliceSpacingDifference_mm = max(vdSliceSpacings_mm) - min(vdSliceSpacings_mm);
                
                if any(abs(vdSliceSpacings_mm - 0) <= DicomImageVolume.dSliceSpacingIs0Limit_mm)
                    error(...
                        'DicomImageVolume:GetImageVolumeGeometryFromImageDirectoryAndFileMetaData:SliceSpacingZero',...
                        'Two or more slices were found to be overlapping (separation of 0mm). This is invalid and cannot be loaded.');
                end                
                
                if dSliceSpacingDifference_mm > DicomImageVolume.dSliceSpacingDifferenceWarningLimit_mm
                    warning(...
                        'DicomImageVolume:GetImageVolumeGeometryFromImageDirectoryAndFileMetaData:InconsistentSliceSpacings',...
                        ['The spacing between slices was found to have a range of ', num2str(dSliceSpacingDifference_mm) , 'mm. Care should be taken using this volume.']);
                end
                
                % instead of using the rounded slice spacings used above to
                % check if slices are equidistant, we'll use the means of
                % the true slice spacings to get the slice voxel dimension:
                vdVoxelDimensions_mm(3) = mean(vdSliceSpacings_mm);
                
                vdFirstVoxelPosition_mm = c1stFileMetadata{vdDirEntriesInSeries(vdSortIndices(1))}.ImagePositionPatient';
                vdFirstVoxelPosition_mm(1:2) = -vdFirstVoxelPosition_mm(1:2);
            end            
            
            dAcquisitionDimension = 3; % always will be
            
            if isempty(dSliceThickness_mm)
                c1xVarargin = {};
                
                warning(...
                    'DicomImageVolume:GetImageVolumeGeometryFromImageDirectoryAndFileMetaData:NoAcquisitionSliceThickness',...
                    'No acquisition slice thickness was provided in the metadata. Voxel thickness (3rd dimension) is set from the by the slice spacing, so the image volume will still be created, just without the acquisition slice thickness specified.');
            else
                c1xVarargin = {dSliceThickness_mm};
            end
            
            oImageVolumeGeometry = ImageVolumeGeometry(...
                vdVolumeDimensions,...
                vdRowAxisUnitVector, vdColAxisUnitVector,...
                vdVoxelDimensions_mm, vdFirstVoxelPosition_mm,...
                dAcquisitionDimension, c1xVarargin{:});
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


