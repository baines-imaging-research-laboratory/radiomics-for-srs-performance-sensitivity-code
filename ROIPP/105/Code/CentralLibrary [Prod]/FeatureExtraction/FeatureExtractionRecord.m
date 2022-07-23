classdef FeatureExtractionRecord
    %FeatureExtractionRecord
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        chFeatureExtractionUuid (1,36) char
        
        sFeatureSource          (1,1) string
        
        dtCreationTimestamp     (1,1) datetime
    end
    
    properties (SetAccess = private, GetAccess = public)
        dTotalNumberOfSamples (1,1) double {mustBePositive, mustBeInteger} = 1
    end
    
    properties (SetAccess = protected, GetAccess = public)
        voFeatureExtractionRecordPortions (1,:) FeatureExtractionRecordPortion = FeatureExtractionRecordPortion.empty(1,0)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = FeatureExtractionRecord(varargin)
            %obj = FeatureExtractionRecord(sFeatureSource, oFeatureExtractionRecordPortion, varargin)
            %
            % SYNTAX:
            %  obj = FeatureExtractionRecord(sFeatureSource, oFeatureExtractionRecordPortion)            
            %  obj = FeatureExtractionRecord(__, __, oFeatureExtractionRecordUniqueKey)
            %  obj = FeatureExtractionRecord(oFeatureExtractionRecord)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
                        
            if nargin == 1 % casting
                voFeatureExtractionRecords = varargin{1};
                
                ValidationUtils.MustBeA(voFeatureExtractionRecords, 'FeatureExtractionRecord');
                
                vdDims = size(voFeatureExtractionRecords);
                dNumRecords = prod(vdDims);
                
                obj = repmat(FeatureExtractionRecord("Pre-allocate",FeatureExtractionRecordPortion("Pre-allocate",1)), vdDims);
                
                for dRecordIndex=1:dNumRecords
                    obj(dRecordIndex).chFeatureExtractionUuid = voFeatureExtractionRecords(dRecordIndex).chFeatureExtractionUuid;
                    obj(dRecordIndex).sFeatureSource = voFeatureExtractionRecords(dRecordIndex).sFeatureSource;
                    obj(dRecordIndex).dtCreationTimestamp = voFeatureExtractionRecords(dRecordIndex).dtCreationTimestamp;
                    obj(dRecordIndex).dTotalNumberOfSamples = voFeatureExtractionRecords(dRecordIndex).dTotalNumberOfSamples;
                    obj(dRecordIndex).voFeatureExtractionRecordPortions = FeatureExtractionRecordPortion(voFeatureExtractionRecords(dRecordIndex).voFeatureExtractionRecordPortions);
                end
            elseif nargin == 2 || nargin == 3
                sFeatureSource = string(varargin{1});
                oFeatureExtractionRecordPortion = varargin{2};
                
                % validate
                ValidationUtils.MustBeA(sFeatureSource, 'string');
                ValidationUtils.MustBeScalar(sFeatureSource);
                
                ValidationUtils.MustBeA(oFeatureExtractionRecordPortion, 'FeatureExtractionRecordPortion');
                ValidationUtils.MustBeScalar(oFeatureExtractionRecordPortion);
                
                % set properities
                obj.sFeatureSource = sFeatureSource;
                obj.dtCreationTimestamp = datetime(now, 'ConvertFrom', 'datenum');
                obj.voFeatureExtractionRecordPortions = oFeatureExtractionRecordPortion;
                obj.dTotalNumberOfSamples = oFeatureExtractionRecordPortion.GetNumberOfSamples();
                            
                % set UUID (either new or FeatureExtractionRecordUniqueKey
                % used for distributed feature extraction computation)
                if nargin == 3
                    oFeatureExtractionRecordUniqueKey = varargin{3};
                    
                    ValidationUtils.MustBeA(oFeatureExtractionRecordUniqueKey, 'FeatureExtractionRecordUniqueKey');
                    ValidationUtils.MustBeScalar(oFeatureExtractionRecordUniqueKey);
                    
                    obj.chFeatureExtractionUuid = oFeatureExtractionRecordUniqueKey.GetUuid(obj);
                else
                    obj.chFeatureExtractionUuid = char(java.util.UUID.randomUUID());
                end
            else
                error(...
                    'FeatureExtractionRecord:Constructor:InvalidNumParameters',...
                    'See constructor documentation for details.');                
            end        
        end 
    end
    
    
    methods (Access = public, Sealed = true)
        
        function sFeatureSource = GetFeatureSource(obj)
            sFeatureSource = obj.sFeatureSource;
        end
        
        function chUuid = GetUuid(obj)
            chUuid = obj.chFeatureExtractionUuid;
        end
        
        function dtCreationTimestamp = GetCreationTimestamp(obj)
            dtCreationTimestamp = obj.dtCreationTimestamp;
        end
        
        function voPortions = GetFeatureExtractionRecordPortions(obj)
            voPortions = obj.voFeatureExtractionRecordPortions;
        end
        
        function [oPortion, dPortionIndex, dPortionNumber] = GetPortionAndPortionIndexForRecordIndex(obj, dRecordIndex)
            arguments
                obj
                dRecordIndex (1,1) double {MustBeValidRecordIndices(obj, dRecordIndex)}
            end
            
            dExtractionIndexCounter = 1;
            
            oFeatureExtractionImageVolumeHandler = [];
            dPortionIndex = [];
            
            for dPortionNumber=1:length(obj.voFeatureExtractionRecordPortions)
                dNumSamplesInPortion = obj.voFeatureExtractionRecordPortions(dPortionNumber).GetNumberOfSamples();
                
                if dRecordIndex <= dExtractionIndexCounter + dNumSamplesInPortion - 1
                    oPortion = obj.voFeatureExtractionRecordPortions(dPortionNumber);
                    dPortionIndex = dRecordIndex - dExtractionIndexCounter + 1;

                    break;
                else
                    dExtractionIndexCounter = dExtractionIndexCounter + dNumSamplesInPortion;
                end
            end
            
            
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            dNumSamples = obj.dTotalNumberOfSamples;
        end
        
        function varargout = vertcat(varargin)
            % oFeatureExtractionRecord = vertcat(oRecord1, oRecord2, ...) 
            % [oFeatureExtractionRecord, vdSampleIndices] = vertcat(__, 'SampleIndices', c1vdSampleIndices)
            
            bRearrangeIndices = false;
            
            if numel(varargin) >= 2 && strcmp(varargin{end-1}, 'SampleIndices')
                bRearrangeIndices = true;
                
                c1vdSampleIndices = varargin{end};
                
                if ...
                        ~iscolumn(c1vdSampleIndices) ||...
                        ~isa(c1vdSampleIndices, 'cell') ||...
                        ~CellArrayUtils.AreAllIndexClassesEqual(c1vdSampleIndices) ||...
                        ~isa(c1vdSampleIndices{1}, 'double')
                    error(...
                        'FeatureExtractionRecord:vertcat:InvalidSampleIndices',...
                        'vdSampleIndices must be a column vector of type double containing integer valued indices greater than 1.');
                end
                
                c1oObjects = varargin(1:end-2);
            else
                c1oObjects = varargin;               
            end
            
            dNumObjects = length(c1oObjects);
            
            % since if multiple UUIDs across records exist
            dTotalNumSamples = 0;
            dMaxNumPortions = 0;
            oMasterRecord = c1oObjects{1};
            
            c1chUuids = cell(dNumObjects,1);
            dNumDifferentUuids = 0;
            
            for dObjectIndex=1:dNumObjects
                if bRearrangeIndices
                    % add total number of samples
                    dTotalNumSamples = dTotalNumSamples + length(c1vdSampleIndices{dObjectIndex});
                end
                
                dMaxNumPortions = dMaxNumPortions + length(c1oObjects{dObjectIndex}.voFeatureExtractionRecordPortions);
                
                % ensure that records have same feature source
                if ...
                        oMasterRecord.GetFeatureSource() ~= c1oObjects{dObjectIndex}.GetFeatureSource() ||...
                        ~isa(varargin{dObjectIndex}, class(oMasterRecord))
                    error(...
                        'FeatureExtractionRecord:vertcat:FeatureSourcesMismatch',...
                        'Objects being concatenated must have FeatureExtractionRecords of the same type and from the same feature source.');
                end
                
                % search for different UUID
                bUuidFound = false;
                
                for dUuidSearchIndex=1:dNumDifferentUuids
                    if strcmp(c1chUuids{dUuidSearchIndex}, c1oObjects{dObjectIndex}.GetUuid())
                        bUuidFound = true;                        
                        break;
                    end
                end
                
                if ~bUuidFound
                    dNumDifferentUuids = dNumDifferentUuids + 1;
                    c1chUuids{dNumDifferentUuids} = c1oObjects{dObjectIndex}.GetUuid();
                end
            end
            
            if dNumDifferentUuids ~= 1
                bOverride = FeatureExtractionRecord.PromptUserToOverrideFeatureExtractionRecordConcatenation(c1oObjects{:});
                
                if ~bOverride
                    error(...
                        'FeatureExtractionRecord:vertcat:FeatureExtractionRecordsMismatch',...
                        'To concatenate FeatureExtractionRecords, the FeatureExtractionRecords must match or be overriden to be forced to match.');                
                end
            end
            
            % if we reach this point, we're a go for concatenation
            newObj = c1oObjects{1};
            
            voPortions = repmat(FeatureExtractionRecordPortion("Pre-allocate",1),1,dMaxNumPortions);
            
            dNumUniquePortions = length(newObj.voFeatureExtractionRecordPortions);
            voPortions(1:dNumUniquePortions) = newObj.voFeatureExtractionRecordPortions;
            
            vdNumSamplesPerPortion = zeros(dMaxNumPortions,1);
            
            for dPortionIndex=1:dNumUniquePortions
                vdNumSamplesPerPortion(dPortionIndex) = voPortions(dPortionIndex).GetNumberOfSamples();
            end
            
            % combine portions together (without duplication)
            for dObjectIndex=2:dNumObjects
                oObject = c1oObjects{dObjectIndex};
                voPortionsToInsert = oObject.voFeatureExtractionRecordPortions;
                
                dCurrentSampleIndex = 1;
                
                for dPortionToInsertIndex=1:length(voPortionsToInsert)
                    oPortionToInsert = voPortionsToInsert(dPortionToInsertIndex);
                    
                    bMatchFound = false;
                    
                    for dPortionSearchIndex=1:dNumUniquePortions
                        if strcmp(oPortionToInsert.GetUuid(), voPortions(dPortionSearchIndex).GetUuid())
                            if bRearrangeIndices
                                % need to figure out how to update the
                                % sample indices for this object
                                
                                % 1) find indices that need updating
                                vbUpdateIndices = c1vdSampleIndices{dObjectIndex} >= dCurrentSampleIndex & c1vdSampleIndices{dObjectIndex} <= dCurrentSampleIndex + oPortionToInsert.GetNumberOfSamples() - 1;
                                
                                % 2) calculate the new starting index for
                                % these indices
                                dStartingIndex = sum(vdNumSamplesPerPortion(1:dPortionSearchIndex-1)) + 1;
                                
                                % 3) update the index values
                                c1vdSampleIndices{dObjectIndex}(vbUpdateIndices) = dStartingIndex + c1vdSampleIndices{dObjectIndex}(vbUpdateIndices) - dCurrentSampleIndex; 
                            end
                            
                            bMatchFound = true;
                            break;
                        end
                    end
                    
                    if ~bMatchFound
                        dNumUniquePortions = dNumUniquePortions + 1;
                        voPortions(dNumUniquePortions) = oPortionToInsert;
                        vdNumSamplesPerPortion(dNumUniquePortions) = oPortionToInsert.GetNumberOfSamples();
                        
                        if bRearrangeIndices
                            % update sample indices to align with new
                            % portion position
                            
                            % 1) find indices that need updating
                            vbUpdateIndices = ...
                                ( c1vdSampleIndices{dObjectIndex} >= dCurrentSampleIndex ) &...
                                ( c1vdSampleIndices{dObjectIndex} <= dCurrentSampleIndex + oPortionToInsert.GetNumberOfSamples() - 1 );
                            
                            % 2) calculate the new starting index for
                            % these indices
                            dStartingIndex = sum(vdNumSamplesPerPortion(1:dNumUniquePortions-1)) + 1;
                            
                            % 3) update the index values
                            c1vdSampleIndices{dObjectIndex}(vbUpdateIndices) = dStartingIndex + c1vdSampleIndices{dObjectIndex}(vbUpdateIndices) - dCurrentSampleIndex;
                        end
                    end
                    
                    dCurrentSampleIndex = dCurrentSampleIndex + oPortionToInsert.GetNumberOfSamples();
                end
            end
            
            % set portions
            newObj.voFeatureExtractionRecordPortions = voPortions(1:dNumUniquePortions);
            
            % update total number of samples
            dNumSamplesAcrossPortions = 0;
            
            for dPortionIndex=1:length(newObj.voFeatureExtractionRecordPortions)
                dNumSamplesAcrossPortions = dNumSamplesAcrossPortions + newObj.voFeatureExtractionRecordPortions(dPortionIndex).GetNumberOfSamples();
            end
            
            newObj.dTotalNumberOfSamples = dNumSamplesAcrossPortions;
            
            % set varargout
            varargout = {newObj};
            
            % concatenate the updated sample indices
            if bRearrangeIndices
                vdSampleIndices = zeros(dTotalNumSamples,1);
                
                dInsertIndex = 1;
                
                for dObjectIndex=1:dNumObjects
                    dNumIndicesToInsert = length(c1vdSampleIndices{dObjectIndex});
                    
                    vdSampleIndices(dInsertIndex : dInsertIndex + dNumIndicesToInsert - 1) = c1vdSampleIndices{dObjectIndex};
                    
                    dInsertIndex = dInsertIndex + dNumIndicesToInsert;
                end
                
                varargout = [varargout {vdSampleIndices}];
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = {?FeatureExtractionRecord, ?FeatureValuesToFeatureExtractionRecordLink})
        
        function MustBeValidRecordIndices(obj, vdRecordIndices)
            arguments
                obj
                vdRecordIndices double {mustBeInteger, mustBeReal, mustBePositive}
            end
            
            mustBeLessThanOrEqual(vdRecordIndices, obj.dTotalNumberOfSamples);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?FeatureExtractionRecord, ?FeatureValuesToFeatureExtractionRecordLink})
        
        function vsHeaders = GetPerSampleHeadersForXls(obj)
            vsHeaders = obj.voFeatureExtractionRecordPortions(1).GetPerSampleHeadersForXls();
            
            vsHeaders = ["Record Index", "Portion #", "Portion Index", vsHeaders];
        end
        
        function c1xDataForXls = GetPerSampleDataForXls(obj, dRecordIndex)
            [oPortion, dPortionIndex, dPortionNumber] = obj.GetPortionAndPortionIndexForRecordIndex(dRecordIndex);
            
            c1xDataForXls = oPortion.GetPerSampleDataForXls(dPortionIndex);
            
            c1xDataForXls = [{dRecordIndex, dPortionNumber, dPortionIndex}, c1xDataForXls];
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function bOverride = PromptUserToOverrideFeatureExtractionRecordConcatenation(varargin)
            dNumObjects = length(varargin);
            
            c1chUuids = cell(dNumObjects,1);
            c1voMatchingRecords = cell(dNumObjects,1);
            c1voRecordPortions = cell(dNumObjects,1);
            
            dNumUniqueUuids = 0;
            
            for dObjectIndex=1:dNumObjects
                oRecord = varargin{dObjectIndex};
                
                bUuidFound = false;
                
                for dUuidSearchIndex=1:dNumUniqueUuids
                    if strcmp(oRecord.GetUuid(), c1chUuids{dUuidSearchIndex})
                        bUuidFound = true;
                        
                        c1voMatchingRecords{dUuidSearchIndex} = [c1voMatchingRecords{dUuidSearchIndex}, {oRecord}];
                        
                        voPortions = oRecord.GetFeatureExtractionRecordPortions();
                                                
                        for dPortionIndex=1:length(voPortions)
                            bPortionFound = false;
                            
                            for dPortionSearchIndex=1:length(c1voRecordPortions{dUuidSearchIndex})
                                if strcmp(voPortions(dPortionIndex).GetUuid(), c1voRecordPortions{dUuidSearchIndex}{dPortionSearchIndex})
                                    bPortionFound = true;
                                end
                            end
                            
                            if ~bPortionFound
                                c1voRecordPortions{dUuidSearchIndex} = [c1voRecordPortions{dUuidSearchIndex}, voPortions(dPortionIndex)]; 
                            end
                        end
                        
                        break;
                    end
                end
                
                if ~bUuidFound
                    dNumUniqueUuids = dNumUniqueUuids + 1;
                    
                    c1chUuids{dNumUniqueUuids} = oRecord.GetUuid();
                    c1voMatchingRecords{dNumUniqueUuids} = {oRecord};
                    c1voRecordPortions{dNumUniqueUuids} = oRecord.GetFeatureExtractionRecordPortions();
                end
            end
            
            % display to user:
            warning('FeatureExtractionRecords with differing UUIDs cannot be concatenated, as the feature values connected to them could have be produced with different versions of code. Please review the proposed merge below to override if desired.');
            
            chPrompt = '\nBelow is a list of the FeatureExtractionRecords proposed to be concatenated:\n';
            
            for dUuidIndex=1:dNumUniqueUuids
                chPrompt = [chPrompt, '\nRecord UUID: ', c1chUuids{dUuidIndex}, '\n Feature Source: ', char(c1voMatchingRecords{dUuidIndex}{1}.GetFeatureSource()), '\n Record Portions:\n'];
                
                voPortions = c1voRecordPortions{dUuidIndex};
                
                for dPortionIndex=1:length(voPortions)
                    chPrompt = [chPrompt, '  ', datestr(voPortions(dPortionIndex).GetCreationTimestamp(), 'mmm dd, yyyy HH:MM:SS'), ' - ', char(voPortions(dPortionIndex).GetDescription()), '\n'];
                end
            end
            
            chPrompt = [chPrompt, '\n\nDo you wish to concatenate these objects? (''Y''/''N'')\n'];
            
            xResponse = 0;
            
            while ~(xResponse == 'Y' || xResponse == 'N')
                xResponse = input(chPrompt);
            end
            
            bOverride = (xResponse == 'Y');
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

