classdef FeatureValuesToFeatureExtractionRecordLink
    %FeatureValuesToFeatureExtractionRecordLink
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Sept 1, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public)
        oFeatureExtractionRecord FeatureExtractionRecord {ValidationUtils.MustBeEmptyOrScalar(oFeatureExtractionRecord)} = CustomFeatureExtractionRecord.empty
        
        vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex (:,1) double {mustBePositive, mustBeInteger}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = FeatureValuesToFeatureExtractionRecordLink(oFeatureExtractionRecord, vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex)
            %obj = FeatureValuesToFeatureExtractionRecordLink(oFeatureExtractionRecord, vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex)
            %
            % SYNTAX:
            %  obj = FeatureValuesToFeatureExtractionRecordLink(oFeatureExtractionRecord, vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            arguments
                oFeatureExtractionRecord (1,1) FeatureExtractionRecord
                vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex (:,1) double {MustBeValidRecordIndices(oFeatureExtractionRecord, vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex)}
            end
            
            % Set properties
            obj.oFeatureExtractionRecord = oFeatureExtractionRecord;
            obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex = vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex;
        end
        
        function obj = ApplySampleSelection(obj, vdSampleSelection)
            arguments
                obj
                vdSampleSelection (:,1) double {MustBeValidSampleIndices(obj, vdSampleSelection)}
            end
                        
            obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex = obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex(vdSampleSelection);
        end
        
        function obj = UnloadImageVolumeHandlersToDisk(obj, c1vsImageVolumeHandlerFilePathsPerPortion, NameValueArgs)
            arguments
                obj (1,1) FeatureValuesToFeatureExtractionRecordLink
                c1vsImageVolumeHandlerFilePathsPerPortion (1,:) cell
                NameValueArgs.HandlersAlreadySaved (1,1) logical = false
            end
            
            if ~isa(obj.oFeatureExtractionRecord, 'ImageVolumeFeatureExtractionRecord')
                error(...
                    'FeatureValuesToFeatureExtractionRecordLink:UnloadImageVolumeHandlersToDisk:InvalidRecordType',...
                    'The FeatureExtractionRecord must be of type ImageVolumeFeatureExtractionRecord to use this function.');
            end
            
            c1xVarargin = namedargs2cell(NameValueArgs);
            
            obj.oFeatureExtractionRecord = obj.oFeatureExtractionRecord.UnloadImageVolumeHandlersToDisk(c1vsImageVolumeHandlerFilePathsPerPortion, c1xVarargin{:});
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function [oFeatureExtractionImageVolumeHandler, dExtractionIndex] = GetImageVolumeHandlerAndExtractionIndexForSampleIndex(obj, dSampleIndex)
            % TODO
            
            arguments
                obj {MustBeValidObjForImageVolumeAccess(obj)}
                dSampleIndex (1,1) double {MustBeValidSampleIndices(obj, dSampleIndex)}
            end
                        
            dFeatureExtractionRecordIndex = obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex(dSampleIndex);
            
            [oFeatureExtractionImageVolumeHandler, dExtractionIndex] = obj.oFeatureExtractionRecord.GetImageVolumeHandlerAndExtractionIndexForRecordIndex(dFeatureExtractionRecordIndex);
        end
        
        function [oImageVolume, oRoiNumber] = GetImageVolumeAndRegionOfInterestNumberForSampleIndex(obj, dSampleIndex)
            % TODO
            
            arguments
                obj {MustBeValidObjForImageVolumeAccess(obj)}
                dSampleIndex (1,1) double {MustBeValidSampleIndices(obj, dSampleIndex)}
            end
            
            % input validation within function below:
            [oFeatureExtractionImageVolumeHandler, dExtractionIndex] = obj.GetImageVolumeHandlerAndExtractionIndexForSampleIndex(dSampleIndex);
            
            oImageVolume = oFeatureExtractionImageVolumeHandler.GetRASImageVolume();
            oRoiNumber = oFeatureExtractionImageVolumeHandler.GetRegionOfInterestNumberFromExtractionIndex(dExtractionIndex);            
        end        
        
        function oRecord = GetFeatureExtractionRecord(obj)
            oRecord = obj.oFeatureExtractionRecord;
        end
        
        function [oPortion, dPortionIndex] = GetFeatureExtractionRecordPortionAndPortionIndexForSampleIndex(obj, dSampleIndex)
            arguments
                obj
                dSampleIndex (1,1) double {MustBeValidSampleIndices(obj, dSampleIndex)}
            end
            
            [oPortion, dPortionIndex] = obj.oFeatureExtractionRecord.GetPortionAndPortionIndexForRecordIndex(obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex(dSampleIndex));
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<
        
        function newObj = vertcat(varargin)
            dNumObjects = length(varargin);
            
            % calculate total number of samples
            dTotalNumSamples = 0;
            c1oRecords = cell(dNumObjects,1);
            
            for dObjectIndex=1:dNumObjects
                % add total number of samples
                dTotalNumSamples = dTotalNumSamples + length(varargin{dObjectIndex}.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex);
                
                % combine records
                c1oRecords{dObjectIndex} = varargin{dObjectIndex}.GetFeatureExtractionRecord();
            end
                
            
            % put the sample indices into cell array for
            % FeatureExtractionRecord vertcat to handle
            c1oSampleIndices = cell(dNumObjects,1);
            
            for dObjectIndex=1:dNumObjects
                c1oSampleIndices{dObjectIndex} = varargin{dObjectIndex}.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex;
            end
            
            
            % concatenate the FeatureExtractionRecords (validation to be
            % handled on that end). 
            % vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex is
            % passed in and then back to reflect updates to sample indices
            % as FeatureExtactionRecordPortions are added
            
            [oFeatureExtractionRecord, vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex] =...
                vertcat(c1oRecords{:}, 'SampleIndices', c1oSampleIndices); 
                  
            
            % create new object
            newObj = FeatureValuesToFeatureExtractionRecordLink(...
                oFeatureExtractionRecord,...
                vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex);
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function DisplayFeatureSourceExtractionSummary(voFeatureValuesToFeatureExtractionRecordLinks)
            
            for dLinkIndex=1:length(voFeatureValuesToFeatureExtractionRecordLinks)
                oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                oRecord = oLink.GetFeatureExtractionRecord();
                
                fprintf([num2str(dLinkIndex), '. Feature Source: ', char(oRecord.GetFeatureSource()), newline]);
                fprintf(['   UUID: ', oRecord.GetUuid(), newline]);
                fprintf(['   Feature Extraction Runs: ', newline]);
                
                voPortions = oRecord.GetFeatureExtractionRecordPortions();
                
                for dPortionIndex=1:length(voPortions)
                    oPortion = voPortions(dPortionIndex);
                    
                    fprintf(['   ', num2str(dPortionIndex), '. Description: ', char(oPortion.GetDescription()), newline]);
                    fprintf(['      Creation Timestamp: ', datestr(oPortion.GetCreationTimestamp, 'mmm dd, yyyy HH:MM:SS'), newline]);
                    fprintf(['      UUID: ', oPortion.GetUuid(), newline]);
                    fprintf(['      # Samples: ', num2str(oPortion.GetNumberOfSamples()), newline]);
                end
                
                fprintf(newline);
            end
        end
        
        function DisplayFeatureSourceSummaryForSamples(voFeatureValuesToFeatureExtractionRecordLinks, viGroupIds, viSubGroupIds)
            
            dNumLinks = length(voFeatureValuesToFeatureExtractionRecordLinks);
            
            chLineFormat = '%5s | %7s || ';
            c1chHeaders = {'Group','Sub Grp'};
            
            for dLinkIndex=1:dNumLinks
                oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                oRecord = oLink.GetFeatureExtractionRecord();
                
                chLineFormat = [chLineFormat, '%10s | %10s | '];                
                c1chHeaders = [c1chHeaders, {'Source', 'UUID(1:10)'}];
                
                if isa(oRecord, 'ImageVolumeFeatureExtractionRecord')                    
                    chLineFormat = [chLineFormat, '%15s | %4s | '];
                    c1chHeaders = [c1chHeaders, {'Image Path', 'ROI#'}];
                end
                
                chLineFormat(end-1:end) = '||';
                chLineFormat = [chLineFormat,' '];
            end
            
            chLineFormat = chLineFormat(1:end-4);
                        
            fprintf(chLineFormat, c1chHeaders{:});
            fprintf(newline);
            
            % get data per row
            
            dNumSamples = length(viGroupIds);
            
            for dSampleIndex=1:dNumSamples
                c1chStrings = {...
                    num2str(viGroupIds(dSampleIndex)),...
                    num2str(viSubGroupIds(dSampleIndex))};
                
                for dLinkIndex=1:dNumLinks
                    oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                    oRecord = oLink.GetFeatureExtractionRecord();
                    
                    chUuid = oRecord.GetUuid();
                    sSource = oRecord.GetFeatureSource();
                    
                    dLen = length(sSource);
                    dEnd = min(10,dLen);
                    
                    c1chStrings = [c1chStrings, {sSource(1:dEnd), chUuid(1:10)}];
                    
                    if isa(oRecord, 'ImageVolumeFeatureExtractionRecord')
                        [oImageVolume, dRoiNumber] = oLink.GetImageVolumeAndRegionOfInterestNumberForSampleIndex(dSampleIndex);
                        
                        chFilePath = oImageVolume.GetFilePath();
                        
                        dLen = length(chFilePath);
                        dStart = max(1,dLen-14);
                        
                        c1chStrings = [c1chStrings, {chFilePath(dStart:end), num2str(dRoiNumber)}];
                    end
                end
                
                fprintf(chLineFormat, c1chStrings{:});
                fprintf(newline);
            end
            
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
                
        function ValidateRecordIndexFromFeatureValuesSampleIndex(vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex, oFeatureExtractionRecord)
            if any(vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex > oFeatureExtractionRecord.GetNumberOfSamples())
                error(...
                    'FeatureValuesToFeatureExtractionRecordLink:ValidateFeatureExtractionRecordIndexFromFeatureValuesSampleIndex:InvalidType',...
                    'vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex cannot have a value greater than the number of samples within oFeatureExtractionRecord.');
            end
        end
        
        function MustBeValidObjForImageVolumeAccess(obj)
            ValidationUtils.MustBeA(obj.oFeatureExtractionRecord, 'ImageVolumeFeatureExtractionRecord');
        end
        
        function MustBeValidSampleIndices(obj, vdSampleIndices)
            arguments
                obj
                vdSampleIndices (1,:) double {mustBeInteger, mustBePositive}
            end
            
            mustBeLessThanOrEqual(vdSampleIndices, length(obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex));            
        end 
    end
    
    
    methods (Access = ?LabelledFeatureValuesByValue)
        
        function WritePerSampleDataToXls(obj, chXlsFilePath, sSheetName)
            % headers
            vsPerSampleHeaders = obj.oFeatureExtractionRecord.GetPerSampleHeadersForXls();
            
            writematrix(...
                vsPerSampleHeaders, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', sSheetName,...
                'Range', 'H5');
            
            % write row by row
            for dSampleIndex=1:length(obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex)
                c1xPerSampleData = obj.oFeatureExtractionRecord.GetPerSampleDataForXls(obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex(dSampleIndex));
                
                writecell(...
                    c1xPerSampleData, chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', sSheetName,...
                    'Range', ['H', num2str(5+dSampleIndex)]);
            end
        end
    end
    
    
    methods (Access = ?ClassificationGuessResult)
        
        function newObj = SimplifyFeatureExtractionRecord(obj)
            % this function casts whatever class the
            % FeatureExtractionRecord is to the base
            % FeatureExtractionRecord class. This effectively strips out an
            % extra information except for what is essential for linking
            % between the objects (e.g. Record and Portion UUIDs)
            % This is useful for the classification guess result objects to
            % have to avoid bloating them with ImageVolumeHandlers, etc.
            
            newObj = FeatureValuesToFeatureExtractionRecordLink(...                        
                FeatureExtractionRecord(obj.oFeatureExtractionRecord),...
                obj.vdFeatureExtractionRecordIndexFromFeatureValuesSampleIndex);
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

