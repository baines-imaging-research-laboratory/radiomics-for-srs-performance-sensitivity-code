classdef PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder < PythonLabelledDataGeneratorBuilder
    %PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 5, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        oLabelledImageCollection (:,1) LabelledImageCollection
        
        vdRASBoundingBoxDimensions (1,3) double {mustBeInteger, mustBePositive} = [1 1 1]
        
    end
                
    properties (SetAccess = private, GetAccess = public)
        dBatchSize (1,1) double {mustBeInteger, mustBePositive} = 1
        
        m2dRASBoundingBoxTopLeftCornerIndicesPerSample (:,3) double {mustBeInteger, mustBePositive} = [1 1 1]
        bCustomRASBoundingBoxTopLeftCornerIndicesUsed (1,1) logical = true
        
        bLoadAllDataIntoRam (1,1) logical = false
        bIncludeImageData (1,1) logical  = true
        bIncludeMaskData (1,1) logical = false
        bUseMaskAsImageChannel (1,1) logical = false
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder(oLabelledImageCollection, dBatchSize, vdRASBoundingBoxDimensions, NameValueArgs)
            %obj = PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder(oLabelledImageCollection, dBatchSize, vdRASBoundingBoxDimensions, NameValueArgs)
            %
            % SYNTAX:
            %  obj = PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder(oLabelledImageCollection, dBatchSize, vdRASBoundingBoxDimensions, NameValueArgs)
            %
            % DESCRIPTION:
            %  Constructor for PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oLabelledImageCollection (:,1) LabelledImageCollection
                dBatchSize (1,1) double {mustBeInteger, mustBePositive}
                vdRASBoundingBoxDimensions (1,3) double {mustBeInteger, mustBePositive}
                NameValueArgs.LoadAllDataIntoRam (1,1) logical = false
                NameValueArgs.IncludeImageData (1,1) logical  = true
                NameValueArgs.IncludeMaskData (1,1) logical = false
                NameValueArgs.UseMaskAsImageChannel (1,1) logical = false
                NameValueArgs.CustomRASBoundingBoxTopLeftCornerIndicesPerSample (:,3) double {mustBeInteger, mustBePositive}
            end
            
            % super-class constructor
            obj@PythonLabelledDataGeneratorBuilder();
            
            % under construction
            if NameValueArgs.LoadAllDataIntoRam
                error('Under construction');
            end
            
            % set properities
            obj.oLabelledImageCollection = oLabelledImageCollection;
            
            obj.dBatchSize = dBatchSize;
            
            obj.vdRASBoundingBoxDimensions = vdRASBoundingBoxDimensions;
            
            obj.bLoadAllDataIntoRam = NameValueArgs.LoadAllDataIntoRam;
            obj.bIncludeImageData = NameValueArgs.IncludeImageData;
            obj.bIncludeMaskData = NameValueArgs.IncludeMaskData;
            obj.bUseMaskAsImageChannel = NameValueArgs.UseMaskAsImageChannel;
            
            if isfield(NameValueArgs, 'CustomRASBoundingBoxTopLeftCornerIndicesPerSample')
                bCustomRASBoundingBoxTopLeftCornerIndicesUsed = true;
                m2dRASBoundingBoxTopLeftCornerIndicesPerSample = NameValueArgs.CustomRASBoundingBoxTopLeftCornerIndicesPerSample;
                
                if size(m2dRASBoundingBoxTopLeftCornerIndicesPerSample,1) ~= oLabelledImageCollection.GetNumberOfSamples()
                    error(...
                        'PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder:Constructor:InvalidCustomRASBoundingBoxTopLeftCornerIndicesPerSample',...
                        'Number of rows of coordinates must equal the number of samples within oLabelledImageCollection.');
                end
            else % centre bounding box on mask
                bCustomRASBoundingBoxTopLeftCornerIndicesUsed = false;
                m2dRASBoundingBoxTopLeftCornerIndicesPerSample = PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder.GetRASBoundingBoxTopLeftCornerIndicesByCentringOnMask(oLabelledImageCollection, vdRASBoundingBoxDimensions);
            end
            
            obj.bCustomRASBoundingBoxTopLeftCornerIndicesUsed = bCustomRASBoundingBoxTopLeftCornerIndicesUsed;
            obj.m2dRASBoundingBoxTopLeftCornerIndicesPerSample = m2dRASBoundingBoxTopLeftCornerIndicesPerSample;
        end   
        
        function obj = SetBatchSize(obj, dBatchSize)
            arguments
                obj
                dBatchSize (1,1) double {mustBeInteger, mustBePositive}
            end
            
            obj.dBatchSize = dBatchSize;
        end
        
        function obj = SetLoadAllDataIntoRam(obj, bLoadAllDataIntoRam)
            arguments
                obj
                bLoadAllDataIntoRam (1,1) logical
            end
            
            obj.bLoadAllDataIntoRam = bLoadAllDataIntoRam;
        end
        
        function obj = SetIncludeImageData(obj, bIncludeImageData)
            arguments
                obj
                bIncludeImageData (1,1) logical
            end
            
            obj.bIncludeImageData = bIncludeImageData;
        end
        
        function obj = SetIncludeMaskData(obj, bIncludeMaskData)
            arguments
                obj
                bIncludeMaskData (1,1) logical
            end
            
            obj.bIncludeMaskData = bIncludeMaskData;
        end
        
        function obj = SetUseMaskAsImageChannel(obj, bUseMaskAsImageChannel)
            arguments
                obj
                bUseMaskAsImageChannel (1,1) logical
            end
            
            obj.bUseMaskAsImageChannel = bUseMaskAsImageChannel;
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            dNumSamples = obj.oLabelledImageCollection.GetNumberOfSamples();
        end
        
        function oDataSet = GetMachineLearningDataSet(obj)
            oDataSet = obj.GetLabelledImageCollection();
        end
        
        function oDataSet = GetLabelledImageCollection(obj)
            oDataSet = obj.oLabelledImageCollection;
        end
        
        function [m3xImageData, m3bMask] = GetBoundedImageDataAndMaskForSample(obj, dSampleNumber)
            arguments
                obj (1,1) PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
                dSampleNumber (1,1) double {mustBeInteger, mustBePositive, MustBeValidSampleNumbers(obj, dSampleNumber)}
            end
            
            [oImageVolume, dRoiNumber] = obj.oLabelledImageCollection.GetImageVolumeAndRegionOfInterestNumberForSample(dSampleNumber);
            
            if ~oImageVolume.GetImageVolumeGeometry().IsRAS()
                error(...
                    'PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder:GetBoundedImageDataAndMaskForSample:InvalidImageVolume',...
                    'oImageVolume must in an RAS Image Volume geometry.');
            end
                        
            vdBoundingBoxTopLeftIndices = obj.m2dRASBoundingBoxTopLeftCornerIndicesPerSample(dSampleNumber,:);
            vdBoundingBoxDimensions = obj.vdRASBoundingBoxDimensions;
            
            if obj.bIncludeImageData
                m3xImageData = oImageVolume.GetImageData();
                
                m3xImageData = MatrixUtils.CropMatrixByTopLeftAndDimensions(m3xImageData, vdBoundingBoxTopLeftIndices, vdBoundingBoxDimensions);
            else
                m3xImageData = [];
            end
            
            if obj.bIncludeMaskData
                m3bMask = oImageVolume.GetRegionsOfInterest().GetMaskByRegionOfInterestNumber(dRoiNumber);
                
                m3bMask = MatrixUtils.CropMatrixByTopLeftAndDimensions(m3bMask, vdBoundingBoxTopLeftIndices, vdBoundingBoxDimensions);
            else
                m3bMask = logical([]);
            end
        end
        
        function m5xTensor = GetTensorForSampleNumbers(obj, vdSampleNumbers)
            arguments
                obj (1,1) PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
                vdSampleNumbers (1,:) double {mustBeInteger, mustBePositive, MustBeValidSampleNumbers(obj, vdSampleNumbers)}
            end
            
            dNumChannels = obj.bIncludeImageData + obj.bIncludeMaskData;
            
            dNumSamples = length(vdSampleNumbers);
            
            m5xTensor = zeros([dNumSamples, obj.vdRASBoundingBoxDimensions, dNumChannels]);
            
            for dSampleIndex=1:dNumSamples
                [m3xImageData, m3bMask] = obj.GetBoundedImageDataAndMaskForSample(vdSampleNumbers(dSampleIndex));
                
                if obj.bUseMaskAsImageChannel
                    dInsertChannel = 1;
                    
                    if obj.bIncludeImageData
                        m5xTensor(dSampleIndex,:,:,:,dInsertChannel) = m3xImageData;
                        dInsertChannel = dInsertChannel + 1;
                    end
                    
                    if obj.bIncludeMaskData
                        m5xTensor(dSampleIndex,:,:,:,dInsertChannel) = m3bMask;
                    end                        
                        
                else
                    if dNumChannels ~= 1
                        error('Under Construction');
                    else
                        if obj.bIncludeImageData
                            m5xTensor(dSampleIndex,:,:,:,1) = m3xImageData;
                        else
                            m5xTensor(dSampleIndex,:,:,:,1) = m3bMask;
                        end
                    end
                end
            end  
        end
            
        function m2dOneHotEncodedLabels = GetOneHotEncodedLabelsForSampleNumbers(obj, vdSampleNumbers)
            arguments
                obj (1,1) PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
                vdSampleNumbers (1,:) double {mustBeInteger, mustBePositive, MustBeValidSampleNumbers(obj, vdSampleNumbers)}
            end
            
            m2dOneHotEncodedLabels = obj.GetLabelledImageCollection().GetSampleLabels().GetOneHotEncodedLabels();
            m2dOneHotEncodedLabels = m2dOneHotEncodedLabels(vdSampleNumbers,:);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidSampleNumbers(obj, vdSampleNumbers)
            arguments
                obj (1,1) PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
                vdSampleNumbers (1,:) double {mustBeInteger, mustBePositive}
            end
            
            if any(vdSampleNumbers > obj.oLabelledImageCollection.GetNumberOfSamples())
                error(...
                    'PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder:MustBeValidSampleNumber:Invalid',...
                    'A sample number is greater than the number of samples in the contained LabelledImageCollection.');
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
% % %         function CreatePerSampleDataFiles(obj, chDirectoryPath, NameValueArgs)
% % %             %CreatePerSampleDataFiles(obj, chDirectoryPath, NameValueArgs)
% % %             %
% % %             % SYNTAX:
% % %             %  obj.CreatePerSampleDataFiles(chDirectoryPath, NameValueArgs)
% % %             %
% % %             % DESCRIPTION:
% % %             %  For each ROI within the LabelledImageCollection, the
% % %             %  bounding box is applied (centred on each ROI), and the
% % %             %  resulting matrix (same dimensions as the bounding box) is
% % %             %  saved to disk.
% % %             %
% % %             % INPUT ARGUMENTS:
% % %             %  TODO
% % %             %
% % %             % OUTPUTS ARGUMENTS:
% % %             %  None
% % %             
% % %             arguments
% % %                 obj (1,1) PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
% % %                 chDirectoryPath (1,:) char
% % %                 NameValueArgs.SaveInCompressedFile (1,1) logical = false
% % %                 NameValueArgs.SaveImageData (1,1) logical = true
% % %                 NameValueArgs.SaveMaskData (1,1) logical = true
% % %             end
% % %             
% % %             dNumSamples = obj.GetNumberOfSamples();
% % %             
% % %             for dSampleIndex=1:dNumSamples
% % %                 iGroupId = obj.oLabelledImageCollection.GetSampleIds().GetGroupIdForSample(dSampleIndex);
% % %                 iSubGroupId = obj.oLabelledImageCollection.GetSampleIds().GetSubGroupIdForSample(dSampleIndex);
% % %                 
% % %                 chFileName = ['Sample ', num2str(iGroupId), '-', num2str(iSubGroupId), ' (', char(obj.oLabelledImageCollection.GetImageSource()), ').mat'];
% % %                 
% % %                 [oRASImageVolume, dRoiNumber] = obj.oLabelledImageCollection.GetImageVolumeAndRegionOfInterestNumberForSample(dSampleIndex);
% % %                 
% % %                 c1xSaveVarargin = {};
% % %                 
% % %                 vdRoiCentreVoxelIndices = oRASImageVolume.GetRegionsOfInterest().GetCentreOfRegionVoxelIndicesByRegionOfInterestNumber(dRoiNumber);
% % %                 
% % %                 if NameValueArgs.SaveImageData
% % %                     m3xImageDataMatrix = oRASImageVolume.GetCroppedImageData(vdRoiCentreVoxelIndices, obj.vdRASBoundingBoxDimensions);
% % %                     
% % %                     c1xSaveVarargin = [c1xSaveVarargin, {'m3xImageData', m3xImageDataMatrix}];
% % %                 end
% % %                 
% % %                 if NameValueArgs.SaveMaskData
% % %                     m3xMaskDataMatrix = oRASImageVolume.GetRegionsOfInterest().GetCroppedMaskByRegionOfInterestNumber(vdRoiCentreVoxelIndices, obj.vdRASBoundingBoxDimensions, dRoiNumber);
% % %                     m3xMaskDataMatrix = uint8(m3xMaskDataMatrix);
% % %                     
% % %                     c1xSaveVarargin = [c1xSaveVarargin, {'m3bMaskData', m3xMaskDataMatrix}];
% % %                 end
% % %                 
% % %                 if ~NameValueArgs.SaveInCompressedFile
% % %                     c1xSaveVarargin = [c1xSaveVarargin, {'-v7.3', '-nocompression'}];
% % %                 end
% % %                 
% % %                 FileIOUtils.SaveMatFile(fullfile(chDirectoryPath, chFileName), c1xSaveVarargin{:});
% % %             end
% % %             
% % %             error('Under construction, need to update oLabelledImageCollection and bounding box locations appropriately');
% % %         end
        
% % %         function ExportToPythonCentralLibraryImageDataGeneratorInFile(obj, dBatchSize, bLoadAllDataIntoRam, chExportPath, chAnacondaInstallPath, chAnacondaEnvironmentName)
% % %             arguments
% % %                 obj
% % %                 dBatchSize (1,1) double {mustBeInteger, mustBePositive}
% % %                 bLoadAllDataIntoRam (1,1) logical
% % %                 chExportPath (1,:) char
% % %                 chAnacondaInstallPath (1,:) char
% % %                 chAnacondaEnvironmentName (1,:) char
% % %             end            
% % %             
% % %             chTempFilePath = tempname;
% % %             obj.SaveToFileForPython(chTempFilePath, dBatchSize, bLoadAllDataIntoRam);
% % %             
% % %             PythonUtils.ExecutePythonScriptInAnacondaEnvironment(...
% % %                 FileIOUtils.GetAbsolutePath('ExportToPythonCentralLibraryImageDataGeneratorToFile.py'),...
% % %                 {chTempFilePath, chExportPath},...
% % %                 chAnacondaInstallPath, chAnacondaEnvironmentName);
% % %         end
        
        function SaveToFileForPython(obj, chFilePath)
            arguments
                obj (1,1) PythonCentralLibraryLabelledImageCollectionDataGeneratorBuilder
                chFilePath (1,:) char
            end
            
            dNumSamples = obj.GetNumberOfSamples();
            
            vsFilePaths = cell(dNumSamples,1);
            vdRegionOfInterestNumbers = zeros(dNumSamples,1);
            
            for dSampleIndex = 1:dNumSamples
                [oRASImageVolume, dRoiNumber] = obj.oLabelledImageCollection.GetImageVolumeAndRegionOfInterestNumberForSample(dSampleIndex);
                
                sFilePath = oRASImageVolume.GetMatFilePath();
                
                if isempty(sFilePath)
                    error('Not sure what to do here...if there''s no Mat file we''re in trouble since the image and mask data are probably in different files..');
                end
                
                vsFilePaths{dSampleIndex} = char(sFilePath);
                vdRegionOfInterestNumbers(dSampleIndex) = dRoiNumber;
            end
            
            m2dImageBoundingBoxTopLeftCornerIndices = obj.m2dRASBoundingBoxTopLeftCornerIndicesPerSample;
            m2dMaskBoundingBoxTopLeftCornerIndices = obj.m2dRASBoundingBoxTopLeftCornerIndicesPerSample;
            
            vdImageBoundingBoxDimensions = obj.vdRASBoundingBoxDimensions;
            vdMaskBoundingBoxDimensions = obj.vdRASBoundingBoxDimensions;
            
            % convert to correct data types for Python
            viRegionOfInterestNumbers = uint8(vdRegionOfInterestNumbers-1); % zero-index
            
            m2iImageBoundingBoxTopLeftCornerIndices = uint16(m2dImageBoundingBoxTopLeftCornerIndices-1); % zero-index
            viImageBoundingBoxDimensions = uint16(vdImageBoundingBoxDimensions);
            
            m2iMaskBoundingBoxTopLeftCornerIndices = uint16(m2dMaskBoundingBoxTopLeftCornerIndices-1); % zero-index            
            viMaskBoundingBoxDimensions = uint16(vdMaskBoundingBoxDimensions);
            
            iBatchSize = uint16(obj.dBatchSize); 
            
            % get data for labels
            c1xVararginForLabels = obj.oLabelledImageCollection.GetSampleLabels().GetVarNamesAndValuesForExportToPython();
            
            % save to file
            FileIOUtils.SaveMatFile(chFilePath,...
                'vsFilePaths', vsFilePaths,...
                'viRegionOfInterestNumbers', viRegionOfInterestNumbers,...
                'm2iImageBoundingBoxTopLeftCornerIndices', m2iImageBoundingBoxTopLeftCornerIndices,...
                'viImageBoundingBoxDimensions', viImageBoundingBoxDimensions,...
                'm2iMaskBoundingBoxTopLeftCornerIndices', m2iMaskBoundingBoxTopLeftCornerIndices,...
                'viMaskBoundingBoxDimensions', viMaskBoundingBoxDimensions,...
                'iBatchSize', iBatchSize,...
                'bLoadAllDataIntoRam', obj.bLoadAllDataIntoRam,...
                'bUseImageData', obj.bIncludeImageData,...
                'bUseMaskData', obj.bIncludeMaskData,...
                'bUseMaskAsImagingChannel', obj.bUseMaskAsImageChannel,...
                c1xVararginForLabels{:});
        end
    end
    
    
    methods (Access = public, Static = true)       
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected) 
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)       
    end
    
    
    methods (Access = private, Static = true)
        
        function m2dRASBoundingBoxTopLeftCornerIndicesPerSample = GetRASBoundingBoxTopLeftCornerIndicesByCentringOnMask(oLabelledImageCollection, vdRASBoundingBoxDimensions)
            dNumSamples = oLabelledImageCollection.GetNumberOfSamples();
                        
            m2dRASBoundingBoxTopLeftCornerIndicesPerSample = zeros(dNumSamples,3);
            
            for dSampleIndex = 1:dNumSamples
                [oRASImageVolume, dRoiNumber] = oLabelledImageCollection.GetImageVolumeAndRegionOfInterestNumberForSample(dSampleIndex);
                
                sFilePath = oRASImageVolume.GetMatFilePath();
                
                if isempty(sFilePath)
                    error('Not sure what to do here...if there''s no Mat file we''re in trouble since the image and mask data are probably in different files..');
                end
                                
                vdRoiCentreVoxelIndices = oRASImageVolume.GetRegionsOfInterest().GetCentreOfRegionVoxelIndicesByRegionOfInterestNumber(dRoiNumber);
                
                [vdXBounds, vdYBounds, vdZBounds] = MatrixUtils.GetCropBoundsByCentreAndDimensions(vdRoiCentreVoxelIndices, vdRASBoundingBoxDimensions);
                
                m2dRASBoundingBoxTopLeftCornerIndicesPerSample(dSampleIndex,:) = [vdXBounds(1), vdYBounds(1), vdZBounds(1)];
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

