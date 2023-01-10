classdef ClassificationGuessResult < MatrixContainerFromHandle & matlab.mixin.Copyable
    %ClassificationGuessResult
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Nov 11, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        chClassifierClassName (1,:) char
        chClassifierUuid (1,36) char
        bAllResultsFromSameClassifier (1,1) logical % and by same classifier, this is the exact same classifier, e.g. same UUID
        
        vdPositiveLabelConfidences (:,1) double {mustBeNonnegative, mustBeLessThanOrEqual(vdPositiveLabelConfidences,1)} = []
        
        viGroupIds (:,1) {ValidationUtils.MustBeIntegerClass} = int8([]) % together Group and Sub-Group IDs form a unique key for a sample (may be duplicated though during balancing)
        viSubGroupIds (:,1) {ValidationUtils.MustBeIntegerClass} = int8([])
        
        vsFeatureNames (1,:) string % unique string for each feature
        
        vdFeatureStandardizationMeans (1,:) double = []
        vdFeatureStandardizationStDevs (1,:) double = []
        bIsStandardized (1,1) logical = false
        
        viLabels (:,1) {ValidationUtils.MustBeIntegerClass} = int8([]) % vector of integers containing the labels
        
        iPositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0) % scalar integer
        iNegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0) % scalar integer
        
        voFeatureValuesToFeatureExtractionRecordLinks (1,:) FeatureValuesToFeatureExtractionRecordLink = FeatureValuesToFeatureExtractionRecordLink.empty(1,0)
        vdLinkIndexPerFeature (1,:) double {mustBeInteger}
        
        bOverrideDuplicatedSamplesValidation (1,1) logical = false
    end
    
    properties (SetAccess = private, GetAccess = public)
        c1chValidatedFeatureValuesUuids = {}
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function viPredictedLabels = GetPredictedLabels(obj, dPositiveConfidenceLevel)
            viPositiveLabel = obj.GetPositiveLabel();
            viNegativeLabel = obj.GetNegativeLabel();
            
            vbPredictedPositive = obj.GetPositiveLabelConfidences >= dPositiveConfidenceLevel;
            
            viPredictedLabels = zeros(size(vbPredictedPositive), class(viPositiveLabel));
            
            viPredictedLabels(vbPredictedPositive) = viPositiveLabel;
            viPredictedLabels(~vbPredictedPositive) = viNegativeLabel;
        end
        
        function [oTruePositives, oTrueNegatives, oFalsePositives, oFalseNegatives] = SplitIntoSensitivityAndSpecificityGroups(obj, dPositiveConfidenceLevel)
            viPredictedLabels = obj.GetPredictedLabels(dPositiveConfidenceLevel);
            iPositiveLabel = obj.GetPositiveLabel();
            iNegativeLabel = obj.GetNegativeLabel();
            viLabels = obj.GetLabels();
            
            vbCorrect = (viLabels == viPredictedLabels);
            
            vbTruePosMask = (viLabels == iPositiveLabel) & vbCorrect;
            vbTrueNegMask = (viLabels == iNegativeLabel) & vbCorrect;
            
            vbFalsePosMask = (viLabels == iPositiveLabel) & ~vbCorrect;
            vbFalseNegMask = (viLabels == iNegativeLabel) & ~vbCorrect;
            
            oTruePositives = obj.SelectRows(vbTruePosMask);
            oTrueNegatives = obj.SelectRows(vbTrueNegMask);
            
            oFalsePositives = obj.SelectRows(vbFalsePosMask);
            oFalseNegatives = obj.SelectRows(vbFalseNegMask);
        end
        
        function vdPositiveLabelConfidences = GetPositiveLabelConfidences(obj)
            %[output1, output2] = Function1(input1, input2, varargin)
            %
            % SYNTAX:
            %  [output1, output2] = function1(input1, input2)
            %  [output1, output2] = function1(input1, input2, 'Flag', input3)
            %
            % DESCRIPTION:
            %  Description of the function
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %          long wrap it with tabs to align the second line, and
            %          then the third line will automatically be in line
            %  input3: What input3 is
            %
            % OUTPUTS ARGUMENTS:
            %  output1: What output1 is
            %  output2: What output2 is
            
            % Primary Author: Your name here
            % Created: MMM DD, YYYY
            
            vdPositiveLabelConfidences = obj.vdPositiveLabelConfidences;
        end
        
        function vdNegativeLabelConfidences = GetNegativeLabelConfidences(obj)
            %[output1, output2] = Function1(input1, input2, varargin)
            %
            % SYNTAX:
            %  [output1, output2] = function1(input1, input2)
            %  [output1, output2] = function1(input1, input2, 'Flag', input3)
            %
            % DESCRIPTION:
            %  Description of the function
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %          long wrap it with tabs to align the second line, and
            %          then the third line will automatically be in line
            %  input3: What input3 is
            %
            % OUTPUTS ARGUMENTS:
            %  output1: What output1 is
            %  output2: What output2 is
            
            % Primary Author: Your name here
            % Created: MMM DD, YYYY
            
            vdNegativeLabelConfidences = 1 - obj.GetPositiveLabelConfidences();
        end
        
        function vdSampleIndices = GetSampleIndicesForFeatureValues(obj, oFeatureValues)
            arguments
                obj
                oFeatureValues (:,:) FeatureValues {MustBeValidFeatureValues(obj, oFeatureValues)}
            end
            
            vdSampleIndices = oFeatureValues.GetSampleIndicesFromGroupAndSubGroupIds(obj.viGroupIds, obj.viSubGroupIds);
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            dNumSamples = length(obj);
        end
        
        function viGroupIds = GetGroupIds(obj)
            %viGroupIds = GetGroupIds(obj)
            %
            % SYNTAX:
            %  viGroupIds = GetGroupIds(obj)
            %
            % DESCRIPTION:
            %  Returns the Group IDs for the samples
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viGroupIds: Column vector of integers (one for each row)
            
            viGroupIds = obj.viGroupIds;
        end
        
        function viSubGroupIds = GetSubGroupIds(obj)
            %viSubGroupIds = GetSubGroupIds(obj)
            %
            % SYNTAX:
            %  viSubGroupIds = GetSubGroupIds(obj)
            %
            % DESCRIPTION:
            %  Returns the Sub Group IDs for the samples
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viSubGroupIds: Column vector of integers (one for each row)
            
            viSubGroupIds = obj.viSubGroupIds;
        end
        
        function vsFeatureNames = GetFeatureNames(obj)
            %vsFeatureNames = GetFeatureNames(obj)
            %
            % SYNTAX:
            %  vsFeatureNames = GetFeatureNames(obj)
            %
            % DESCRIPTION:
            %  Returns the Feature Names for each column of the featue table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vsFeatureNames: Strings row vector (one for each column)
            
            vsFeatureNames = obj.vsFeatureNames;
        end
        
        function bIsStandardized = IsStandardized(obj)
            %bIsStandardized = IsStandardized(obj)
            %
            % SYNTAX:
            %   bIsStandardized = IsStandardized(obj)
            %
            % DESCRIPTION:
            %  Returns the if the FeatureValues object is standardized
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  bIsStandardized: Boolean (true if standardized)
            
            bIsStandardized = obj.bIsStandardized;
        end
        
        function vdFeatureStandardizationMeans = GetFeatureStandardizationMeans(obj)
            %vdFeatureStandardizationMeans = GetFeatureStandardizationMeans(obj)
            %
            % SYNTAX:
            %   vdFeatureStandardizationMeans = GetFeatureStandardizationMeans(obj)
            %
            % DESCRIPTION:
            %  Returns the Feature Standardization Mean for each column of the
            %  featue table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdFeatureStandardizationMeans: Double row vector (one for each column)
            
            vdFeatureStandardizationMeans = obj.vdFeatureStandardizationMeans;
        end
        
        function vdFeatureStandardizationStDevs = GetFeatureStandardizationStDevs(obj)
            %vdFeatureStandardizationStDevs = GetFeatureStandardizationStDevs(obj)
            %
            % SYNTAX:
            %   vdFeatureStandardizationStDevs = GetFeatureStandardizationStDevs(obj)
            %
            % DESCRIPTION:
            %  Returns the Feature Standardization Standard Deviation for each
            %  column of the featue table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdFeatureStandardizationStDevs: Double row vector (one for each column)
            
            vdFeatureStandardizationStDevs = obj.vdFeatureStandardizationStDevs;
        end
        
        function viLabels = GetLabels(obj)
            %viLabels = GetLabels(obj)
            %
            % SYNTAX:
            %  viLabels = GetLabels(obj)
            %
            % DESCRIPTION:
            %  Provides the sample labels (positive/negative)
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viLabels: Column vector of integers (one for each row)
            
            viLabels = obj.viLabels;
        end
        
        function iPositiveLabel = GetPositiveLabel(obj)
            %iPositiveLabel = GetPositiveLabel(obj)
            %
            % SYNTAX:
            %  iPositiveLabel = GetPositiveLabel(obj)
            %
            % DESCRIPTION:
            %  Provides the positive label
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  iPositiveLabel: The positive label
            
            iPositiveLabel = obj.iPositiveLabel;
        end
        
        function iNegativeLabel = GetNegativeLabel(obj)
            %iNegativeLabel = GetNegativeLabel(obj)
            %
            % SYNTAX:
            %  iNegativeLabel = GetNegativeLabel(obj)
            %
            % DESCRIPTION:
            %  Provides the negative label
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  iNegativeLabel: The negative label
            
            iNegativeLabel = obj.iNegativeLabel;
        end
        
        function DisplayFeatureSourceExtractionSummary(obj)
            FeatureValuesToFeatureExtractionRecordLink.DisplayFeatureSourceExtractionSummary(...
                obj.voFeatureValuesToFeatureExtractionRecordLinks);
        end
        
        function DisplayFeatureSourceSummaryForSamples(obj)
            FeatureValuesToFeatureExtractionRecordLink.DisplayFeatureSourceSummaryForSamples(...
                obj.voFeatureValuesToFeatureExtractionRecordLinks,...
                obj.viGroupIds, obj.viSubGroupIds);            
        end
        
        
        % >>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<
        
        function vdDims = size(obj, varargin)
            vdDims = size(obj.vdPositiveLabelConfidences,varargin{:});
        end
        
        function dLength = length(obj)
            dLength = length(obj.vdPositiveLabelConfidences);
        end
        
        function  dNumel = numel(obj)
            dNumel = numel(obj.vdPositiveLabelConfidences);
        end
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            % create headings/format
            vsFeatureNames = obj.vsFeatureNames;
            vdLinkIndices = obj.vdLinkIndexPerFeature;
            
            dNumFeatures = length(vsFeatureNames);
            
            for dFeatureIndex=1:dNumFeatures
                vsFeatureNames(dFeatureIndex) = strcat(...
                    num2str(vdLinkIndices(dFeatureIndex)), ":",...
                    vsFeatureNames(dFeatureIndex));
            end
            
            c1chDispHeaderValues = {'+/- Label', 'Label', '+ Confidence', 'Group', 'Sub Grp', vsFeatureNames};
            chDispHeaderFormat = ['%9s | %5s | %12s | %5s | %7s | ', repmat('%17s ',1,dNumFeatures)];
               
            % print headings
            fprintf(chDispHeaderFormat, c1chDispHeaderValues{:});
            fprintf(newline);
            
            % get format for rows
            chRowFormat = '%9s | %5i | %12.4f | %5i | %7i | %20s';
            
            for dSampleIndex=1:obj.GetNumberOfSamples()
                if dSampleIndex == 1
                    chPosNegLabel = [num2str(obj.GetPositiveLabel()), ' / ' num2str(obj.GetNegativeLabel())];
                    chFeatureValuesLabel = '<< Feature values are not stored within the GuessResult object >>';
                else
                    chPosNegLabel = '';
                    chFeatureValuesLabel = '';
                end
                
                fprintf(chRowFormat, chPosNegLabel, obj.viLabels(dSampleIndex), obj.vdPositiveLabelConfidences(dSampleIndex), obj.viGroupIds(dSampleIndex), obj.viSubGroupIds(dSampleIndex), chFeatureValuesLabel);
                fprintf(newline);
            end
            
            % print feature sources
            fprintf(newline);            
            fprintf('Feature Sources:');
            fprintf(newline);
            
            voLinks = obj.voFeatureValuesToFeatureExtractionRecordLinks;
            
            for dLinkIndex=1:length(voLinks)
                oRecord = voLinks(dLinkIndex).GetFeatureExtractionRecord();
                
                fprintf(strcat(" ", num2str(dLinkIndex), ": ", oRecord.GetFeatureSource(), " [UUID: ", oRecord.GetUuid(), "]"));
                fprintf(newline);
            end
            
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  Overloading subsref to allow selections (e.g. a(1:3,4)) to
            %  be made on matrix containers. Also handles a.FnName() calls.
            %  Operates for FeatureValuesByValue by calling the
            %  MatrixContainer implementation and then applying this
            %  selection.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: If is was a selection, a MatrixContainer object
            %             will be returned. If it was a a.FnName() call,
            %             anything could be returned
            
            
            % call super-class method that has this call figured out
            [varargout{1:nargout}] = subsref@MatrixContainerFromHandle(obj, stSelection);
            
            % sub-class specific
            if strcmp(stSelection(1).type, '()')
                % if it was a selection, don't want to store all the data
                % since we're passing by value
                vdRowSelection = varargout{1}.GetRowSelection();
                
                varargout{1} = ClassificationGuessResult(varargout{1}, vdRowSelection);
            end
        end
        
        function newObj = horzcat(varargin)
            error(...
                'ClassificationGuessResult:horzcat:Invalid',...
                'ClassificationGuessReusult objects can only be vertically concatenated.');
        end
        
        function newObj = cat(dDim, varargin)
            if dDim == 1
                newObj = vertcat(varargin{:});
            else
                error(...
                    'ClassificationGuessResult:cat:Invalid',...
                    'ClassificationGuessReusult objects can only be vertically concatenated.');
            end
        end
        
        function newObj = vertcat(varargin)
            %newObj = vertcat(varargin)
            %
            % SYNTAX:
            %  newObj = [oGuessResult1; oGuessResult2]
            %  newObj = [oGuessResult1; oGuessResult2; oGuessResult3; ...]
            %  newObj = vertcat(c1oGuessResults{:})
            %
            % DESCRIPTION:
            %  Combines multiple GuessResults into a single GuessResult
            %  object. It is validated that the all the combined
            %  GuessResult objects reference the same FeatureValues object
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A single GuessResult object
            %  c1oGuessResults{:}: A cell array of GuessResult objects that
            %                      by using the "{:}" command, each object
            %                      becomes an individual input
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: A single GuessResult object with the combined
            %          confiedences, group IDs, etc. of the provided
            %          GuessResult objects
            
            if nargin > 1
                newObj = ClassificationGuessResult('vertcat', varargin{:});
            elseif nargin == 1
                newObj = varargin{1};
            else
                newObj = ClassificationGuessResult.empty;
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function newObj = CopyContainedMatrices(obj)
            %newObj = CopyContainedMatrices(obj, newObj)
            %
            % SYNTAX:
            %  newObj = CopyContainedMatrices(obj, newObj)
            %
            % DESCRIPTION:
            %  Copies the contained matrices to the new object.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  newObj: Copied class object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copied class object
            
            newObj = obj;
        end
        
        function saveObj = saveobj(obj)
            saveObj = copy(obj);
            
            % clear out m3xImageData (can either get that back from the
            % original file (Dicom, Nifti) or from a Matfile if
            % .SaveTransformedData() was called
            saveObj.c1chValidatedFeatureValuesUuids = {};
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = ?Classifier)
        
        function obj = ClassificationGuessResult(varargin)
            %obj = ClassificationGuessResult(varargin)
            %
            % SYNTAX:
            %  obj = ClassificationGuessResult(oClassifier, oLabelledFeatureValues, vdPositiveLabelConfidences)
            %  obj = ClassificationGuessResult(oClassifier, oLabelledFeatureValues, vdPositiveLabelConfidences, bOverrideDuplicatedSamplesValidation)
            %  obj = ClassificationGuessResult(oLabelledFeatureValuesIdenitifer, viGroupIds, viSubGroupIds, vsFeatureNames, vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, viLabels, iPositiveLabel, iNegativeLabel, vdPositiveLabelConfidences)
            %  obj = ClassificationGuessResult(oClassificationGuessResult, vdRowSelection)
            
            %
            % DESCRIPTION:
            %  Creates a GuessResult object either from all the required
            %  data fields from a LabellelFeatureValues object and
            %  confidences, or a LabelledFeatureValues object directly and
            %  confidences
            %
            % INPUT ARGUMENTS:
            %  chFeatureValuesUuid: The UUID of the FeatureValues object
            %                       for which the "Guess" call was used on
            %  vdPositiveLabelConfidences: Confidences for each sample to
            %                              be a positive label, as found by
            %                              the classifier. These values
            %                              should be in the range [0..1]
            %  viGroupIds: column vector of Group Ids for each sample. Do
            %              not to be unique
            %  viSubGroupIds: column vector of Sub Group Ids for each
            %                 sample. Need to be unique within a given Group
            %                 Id
            %  viLabels: a column vector of integers containing two and
            %            only two uniquely different labels. The number of
            %            rows must match the number of samples/rows of the
            %            feature table.
            %  iPositiveLabel: an integer that sepecifies which label value
            %                  within viLabels marks a "positive" sample
            %  iNegativeLabel: an integer that sepecifies which label value
            %                  within viLabels marks a "negative" sample
            %   bOverrideDuplicatedSamplesValidation:
            %    Set to true to avoid checking if the same samples were in
            %    the test set. Typically this should be checked, but if
            %    you're doing bootstrapping, for example, you'd likely turn
            %    it off
            %
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            c1chValidatedFeatureValuesUuids = {};
            
            if (nargin == 3 || nargin ==4) && isa(varargin{1}, 'Classifier')
                oClassifier = varargin{1};
                oLabelledFeatureValues = varargin{2};
                vdPositiveLabelConfidences = double(varargin{3});
                
                if nargin == 4
                    bOverrideDuplicatedSamplesValidation = varargin{4};
                else
                    bOverrideDuplicatedSamplesValidation = false; % default
                end
                
                % validate
                ValidationUtils.MustBeA(bOverrideDuplicatedSamplesValidation, 'logical');
                ValidationUtils.MustBeScalar(bOverrideDuplicatedSamplesValidation);
                
                ValidationUtils.MustBeA(oClassifier, 'Classifier');
                ValidationUtils.MustBeScalar(oClassifier);
                
                ClassificationGuessResult.MustBeValidLabelledFeatureValues(oLabelledFeatureValues, bOverrideDuplicatedSamplesValidation);
                ClassificationGuessResult.MustBeValidPositiveLabelConfidences(vdPositiveLabelConfidences, oLabelledFeatureValues);
                                
                
                % get property values
                chClassifierClassName = class(oClassifier);
                chClassifierUuid = oClassifier.GetUuid();
                bAllResultsFromSameClassifier = true;
                
                viGroupIds = oLabelledFeatureValues.GetGroupIds();
                viSubGroupIds = oLabelledFeatureValues.GetSubGroupIds();
                
                vsFeatureNames = oLabelledFeatureValues.GetFeatureNames();
                
                vdFeatureStandardizationMeans = oLabelledFeatureValues.GetFeatureStandardizationMeans();
                vdFeatureStandardizationStDevs = oLabelledFeatureValues.GetFeatureStandardizationStDevs();
                bIsStandardized = oLabelledFeatureValues.IsStandardized();
                
                viLabels = oLabelledFeatureValues.GetLabels();
                iPositiveLabel = oLabelledFeatureValues.GetPositiveLabel();
                iNegativeLabel = oLabelledFeatureValues.GetNegativeLabel();
                
                voFeatureValuesToFeatureExtractionRecordLinks = oLabelledFeatureValues.GetFeatureValuesToFeatureExtractionRecordLinks();
                vdLinkIndexPerFeature = oLabelledFeatureValues.GetLinkIndexPerFeature();
                
                for dLinkIndex=1:length(voFeatureValuesToFeatureExtractionRecordLinks)
                    voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex) = SimplifyFeatureExtractionRecord(voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex));
                end
                
            elseif nargin == 2 && isa(varargin{1}, 'ClassificationGuessResult')
                oClassificationGuessResult = varargin{1};
                vdRowSelection = varargin{2};
                
                % validate parameters
                ValidationUtils.MustBeA(oClassificationGuessResult, 'ClassificationGuessResult');
                MustBeValidRowSelection(oClassificationGuessResult, vdRowSelection);
                
                % get property values and apply selection
                chClassifierClassName = oClassificationGuessResult.chClassifierClassName;
                chClassifierUuid = oClassificationGuessResult.chClassifierUuid;
                bAllResultsFromSameClassifier = oClassificationGuessResult.bAllResultsFromSameClassifier;
                
                vdPositiveLabelConfidences = oClassificationGuessResult.vdPositiveLabelConfidences(vdRowSelection);
                
                viGroupIds = oClassificationGuessResult.viGroupIds(vdRowSelection);
                viSubGroupIds = oClassificationGuessResult.viSubGroupIds(vdRowSelection);
                
                vsFeatureNames = oClassificationGuessResult.vsFeatureNames;
                
                vdFeatureStandardizationMeans = oClassificationGuessResult.vdFeatureStandardizationMeans;
                vdFeatureStandardizationStDevs = oClassificationGuessResult.vdFeatureStandardizationStDevs;
                bIsStandardized = oClassificationGuessResult.bIsStandardized;
                
                viLabels = oClassificationGuessResult.viLabels(vdRowSelection);
                iPositiveLabel = oClassificationGuessResult.iPositiveLabel;
                iNegativeLabel = oClassificationGuessResult.iNegativeLabel;
                
                voFeatureValuesToFeatureExtractionRecordLinks = oClassificationGuessResult.voFeatureValuesToFeatureExtractionRecordLinks;
                
                for dLinkIndex=1:length(voFeatureValuesToFeatureExtractionRecordLinks)
                    voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex) = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex).ApplySampleSelection(vdRowSelection);
                end
                
                vdLinkIndexPerFeature = oClassificationGuessResult.vdLinkIndexPerFeature;
                
                bOverrideDuplicatedSamplesValidation = oClassificationGuessResult.bOverrideDuplicatedSamplesValidation;
                
            elseif nargin >= 3 && strcmp(varargin{1}, 'vertcat')
                c1oGuessResults = varargin(2:end);
                dNumGuessResults = length(c1oGuessResults);
                
                for dResultIndex=1:dNumGuessResults
                    ValidationUtils.MustBeA(c1oGuessResults{dResultIndex}, 'ClassificationGuessResult');
                end
                
                [chClassifierClassName, chClassifierUuid, bAllResultsFromSameClassifier, vdPositiveLabelConfidences, viGroupIds, viSubGroupIds, vsFeatureNames, vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, viLabels, iPositiveLabel, iNegativeLabel, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature, c1chValidatedFeatureValuesUuids, bOverrideDuplicatedSamplesValidation] = ...
                    ClassificationGuessResult.GetPropertiesForVertcat(c1oGuessResults{:});
            else
                error(...
                    'ClassificationGuesssResult:Constructor:InvalidParameters',...
                    'Refer to the constructor documentation');
            end
            
            % Super-class constructor
            obj@MatrixContainerFromHandle(vdPositiveLabelConfidences);
            
            % Set properities
            obj.chClassifierClassName = chClassifierClassName;
            obj.chClassifierUuid = chClassifierUuid;
            obj.bAllResultsFromSameClassifier = bAllResultsFromSameClassifier;
            
            obj.vdPositiveLabelConfidences = vdPositiveLabelConfidences;
            
            obj.viGroupIds = viGroupIds;
            obj.viSubGroupIds = viSubGroupIds;
            
            obj.vsFeatureNames = vsFeatureNames;
            
            obj.vdFeatureStandardizationMeans = vdFeatureStandardizationMeans;
            obj.vdFeatureStandardizationStDevs = vdFeatureStandardizationStDevs;
            obj.bIsStandardized = bIsStandardized;
            
            obj.viLabels = viLabels;
            obj.iPositiveLabel = iPositiveLabel;
            obj.iNegativeLabel = iNegativeLabel;
            
            obj.voFeatureValuesToFeatureExtractionRecordLinks = voFeatureValuesToFeatureExtractionRecordLinks;
            obj.vdLinkIndexPerFeature = vdLinkIndexPerFeature;
            
            obj.c1chValidatedFeatureValuesUuids = c1chValidatedFeatureValuesUuids;
            
            obj.bOverrideDuplicatedSamplesValidation = bOverrideDuplicatedSamplesValidation;
        end
    end
    
    methods (Access = private)
        
        function MustBeValidFeatureValues(obj, oFeatureValues)
            chFeatureValuesUuid = oFeatureValues.GetUuid();
            
            bPreValidated = false;
            
            for dUuidIndex=1:length(obj.c1chValidatedFeatureValuesUuids)
                if strcmp(chFeatureValuesUuid, obj.c1chValidatedFeatureValuesUuids{dUuidIndex})
                    bPreValidated = true;
                    break;
                end
            end
            
            if ~bPreValidated
                try
                    vdFeatureValuesSampleIndices = oFeatureValues.GetSampleIndicesFromGroupAndSubGroupIds(obj.viGroupIds, obj.viSubGroupIds);
                catch e
                    error(...
                        'ClassificationGuessResult:MustBeValidFeatureValues:GroupAndSubGroupIdFailure',...
                        'Not all Group/Sub-Group ID pairs within the ClassificationGuessResult object were found in the LabelledFeatureValues object.');
                end
                
                vsFeatureNamesFromFeatureValues = oFeatureValues.GetFeatureNames();
                voFeatureValuesToFeatureExtractionRecordLinksFromFeatureValues = oFeatureValues.GetFeatureValuesToFeatureExtractionRecordLinks();
                vdLinkIndexPerFeatureFromFeatureValues = oFeatureValues.GetLinkIndexPerFeature();
                
                for dGuessResultFeatureIndex=1:length(obj.vsFeatureNames)
                    vdFeatureValuesFeatureIndices = find(vsFeatureNamesFromFeatureValues == obj.vsFeatureNames(dGuessResultFeatureIndex));
                    
                    if isempty(vdFeatureValuesFeatureIndices) % no feature name matches were foudn
                        error(...
                            'ClassificationGuessResult:MustBeValidFeatureValues:FeatureNameNotFound',...
                            ['The feature name "', obj.vsFeatureNames(dGuessResultFeatureIndex), '" was not found within the LabelledFeatureValues object.']);
                    else % 1 or more feature name matches were found
                        % know we need to check whether or not these
                        % columns with the same feature name have the same
                        % feature extraction record
                        
                        bFeatureExtractionRecordUuidMatchFound = false;
                        
                        for dMatchIndex=1:length(vdFeatureValuesFeatureIndices)
                            dFeatureValuesFeatureIndex = vdFeatureValuesFeatureIndices(dMatchIndex);
                            
                            oFeatureValuesLink = voFeatureValuesToFeatureExtractionRecordLinksFromFeatureValues(vdLinkIndexPerFeatureFromFeatureValues(dFeatureValuesFeatureIndex));
                            oGuessResultLink = obj.voFeatureValuesToFeatureExtractionRecordLinks(obj.vdLinkIndexPerFeature(dGuessResultFeatureIndex));
                            
                            if strcmp(oFeatureValuesLink.GetFeatureExtractionRecord().GetUuid(), oGuessResultLink.GetFeatureExtractionRecord().GetUuid()) % a column with a matching feature extraction source was found!
                                bFeatureExtractionRecordUuidMatchFound = true;
                                break;
                            end
                        end
                        
                        if ~bFeatureExtractionRecordUuidMatchFound
                            % if no FeatureExtractionRecord UUID match was
                            % found that could be due to the Record UUID
                            % being changed when
                            % FeatureExtractionRecordPortions are combined.
                            % So let's go through again and make sure that
                            % every row's portion UUID matches up
                            
                            bAllFeatureExtractionRecordPortionUuidMatchesFound = false;
                            
                            for dMatchIndex=1:length(vdFeatureValuesFeatureIndices)
                                dFeatureValuesFeatureIndex = vdFeatureValuesFeatureIndices(dMatchIndex);
                                
                                oFeatureValuesLink = voFeatureValuesToFeatureExtractionRecordLinksFromFeatureValues(vdLinkIndexPerFeatureFromFeatureValues(dFeatureValuesFeatureIndex));
                                oGuessResultLink = obj.voFeatureValuesToFeatureExtractionRecordLinks(obj.vdLinkIndexPerFeature(dGuessResultFeatureIndex));
                                
                                bPortionUuidMismatchFound = false;
                                
                                for dGuessResultSampleIndex=1:obj.GetNumberOfSamples()
                                    dFeatureValuesSampleIndex = vdFeatureValuesSampleIndices(dGuessResultSampleIndex);
                                    
                                    oFeatureValuesRecordPortion = oFeatureValuesLink.GetFeatureExtractionPortionBySampleIndex(dFeatureValuesSampleIndex);
                                    oGuessResultRecordPortion = oGuessResultLink.GetFeatureExtractionPortionBySampleIndex(dGuessResultSampleIndex);
                                    
                                    if ~strcmp(oFeatureValuesRecordPortion.GetUuid(), oGuessResultRecordPortion.GetUuid())
                                        bPortionUuidMismatchFound = true;
                                        break;
                                    end
                                end
                                
                                
                                if strcmp(oFeatureValuesLink.GetFeatureExtractionRecord().GetUuid(), oGuessResultLink.GetFeatureExtractionRecord().GetUuid()) % a column with a matching feature extraction source was found!
                                    bFeatureExtractionRecordUuidMatchFound = true;
                                    break;
                                end
                            end
                            
                            if ~bAllFeatureExtractionRecordPortionUuidMatchesFound % all options are exhausted, these are incompatible GuessResult and FeatureValues objects
                                error(...
                                    'ClassificationGuessResult:MustBeValidFeatureValues:FeatureExtractionRecordsMismatch',...
                                    'While there were Group and Sub-Group ID matches between the ClassificationGuessResult and LabelledFeatureValues objects, as well as FeatureNames, the FeatureExtractionRecords for the Features did not match.');
                            end
                        end
                    end
                end
                
                % if we get here that means an error was never triggered,
                % so we're good!
                % Add the FeatureValue object's UUID to the list so this
                % big long check doesn't need to happen again
                obj.c1chValidatedFeatureValuesUuids = [obj.c1chValidatedFeatureValuesUuids; {chFeatureValuesUuid}];
            end
        end
        
        function newObj = SelectRows(obj, vdRowIndices)
            vdRowIndices = {{vdRowIndices}};
            
            stSelection = struct(...
                'type', '()',...
                'subs', vdRowIndices);
            
            newObj = obj.subsref(stSelection);
        end
        
        function MustBeValidRowSelection(obj, vdRowSelection)
            ValidationUtils.MustBeA(vdRowSelection, 'double');
            ValidationUtils.MustBeRowVector(vdRowSelection);
            mustBeInteger(vdRowSelection);
            mustBePositive(vdRowSelection);
            mustBeLessThanOrEqual(vdRowSelection, obj.GetNumberOfSamples());
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function [chClassifierClassName, chClassifierUuid, bAllResultsFromSameClassifier, vdPositiveLabelConfidences, viGroupIds, viSubGroupIds, vsFeatureNames, vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, viLabels, iPositiveLabel, iNegativeLabel, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature, c1chValidatedFeatureValuesUuids, bMasterOverrideDuplicatedSamplesValidation] = GetPropertiesForVertcat(varargin)
            % calculate how many samples there will be in total
            dTotalNumSamples = 0;
            dTotalNumValidatedFeatureValuesUuids = 0;
            
            for dObjIndex=1:nargin
                dTotalNumSamples = dTotalNumSamples + varargin{dObjIndex}.GetNumberOfSamples();
                dTotalNumValidatedFeatureValuesUuids = dTotalNumValidatedFeatureValuesUuids + length(varargin{dObjIndex}.c1chValidatedFeatureValuesUuids);
            end
            
            % select first guess result to compare others to
            oMasterGuessResult = varargin{1};
            
            chMasterClassifierClassName = oMasterGuessResult.chClassifierClassName;
            chMasterClassifierUuid = oMasterGuessResult.chClassifierUuid;
            bAllResultsFromSameClassifier = oMasterGuessResult.bAllResultsFromSameClassifier;
            
            vsMasterFeatureNames = oMasterGuessResult.vsFeatureNames;
            voMasterFeatureValuesToFeatureExtractionRecordLinks = oMasterGuessResult.voFeatureValuesToFeatureExtractionRecordLinks;
            vdMasterLinkIndexPerFeature = oMasterGuessResult.vdLinkIndexPerFeature;
            
            chMasterGroupIdsClass = class(oMasterGuessResult.viGroupIds);
            chMasterSubGroupIdsClass = class(oMasterGuessResult.viSubGroupIds);
            chMasterLabelClass = class(oMasterGuessResult.viLabels);
            
            bMasterIsStandardized = oMasterGuessResult.bIsStandardized;
            vdMasterFeatureStandardizationMeans = oMasterGuessResult.vdFeatureStandardizationMeans;
            vdMasterFeatureStandardizationStDevs = oMasterGuessResult.vdFeatureStandardizationStDevs;
            
            iMasterPositiveLabel = oMasterGuessResult.iPositiveLabel;
            iMasterNegativeLabel = oMasterGuessResult.iNegativeLabel;
            
            bMasterOverrideDuplicatedSamplesValidation = oMasterGuessResult.bOverrideDuplicatedSamplesValidation;
            
            % pre-allocate final arrays
            vdPositiveLabelConfidences = zeros(dTotalNumSamples,1);
            viGroupIds = zeros(dTotalNumSamples,1,chMasterGroupIdsClass);
            viSubGroupIds = zeros(dTotalNumSamples,1,chMasterSubGroupIdsClass);
            viLabels = zeros(dTotalNumSamples,1,chMasterLabelClass);
              
            % insert master object's values
            dInsertIndexEnd = oMasterGuessResult.GetNumberOfSamples();
            
            viGroupIds(1:dInsertIndexEnd) = oMasterGuessResult.viGroupIds;
            viSubGroupIds(1:dInsertIndexEnd) = oMasterGuessResult.viSubGroupIds;            
            viLabels(1:dInsertIndexEnd) = oMasterGuessResult.viLabels;          
            vdPositiveLabelConfidences(1:dInsertIndexEnd) = oMasterGuessResult.vdPositiveLabelConfidences;
                            
            % loop through objects to be concatenated
            dInsertIndexStart = dInsertIndexEnd + 1;
            
            for dObjIndex=2:nargin
                oCurrentGuessResult = varargin{dObjIndex};
                dCurrentNumSamples = oCurrentGuessResult.GetNumberOfSamples();
                dInsertIndexEnd = dInsertIndexStart + dCurrentNumSamples - 1;
                
                % validate same "bOverrideDuplicatedSamplesValidation"
                % value
                if bMasterOverrideDuplicatedSamplesValidation ~= oCurrentGuessResult.bOverrideDuplicatedSamplesValidation
                    error(...
                        'ClassifierGuessResult:GetPropertiesForVertcat:ClassifierOverideDuplicatedSamplesValidationMismatch',...
                        'ClassificationGuessResult objects can only be concatenated if they were all produced with the same duplicated samples validation.');                    
                end
                
                % validate and set classifier properties (class name, UUID)
                if ~strcmp(chMasterClassifierClassName, oCurrentGuessResult.chClassifierClassName)
                    error(...
                        'ClassifierGuessResult:GetPropertiesForVertcat:ClassifierClassMismatch',...
                        'ClassificationGuessResult objects can only be concatenated if they were all produced by the same classifier type.');
                end
                
                bAllResultsFromSameClassifier = bAllResultsFromSameClassifier && strcmp(chMasterClassifierUuid, oCurrentGuessResult.chClassifierUuid);
                
                
                % validate that feature names are equal
                if ~all(vsMasterFeatureNames == oCurrentGuessResult.vsFeatureNames)
                    error(...
                        'ClassifierGuessResult:GetPropertiesForVertcat:ClassifierClassMismatch',...
                        'ClassificationGuessResult objects can only be concatenated if they have the same FeatureNames in the same order.');
                end
                
                
                % validate that Standardization is the same
                if bMasterIsStandardized ~= oCurrentGuessResult.bIsStandardized
                    error(...
                        'ClassifierGuessResult:GetPropertiesForVertcat:IsStandardizedMismatch',...
                        'ClassificationGuessResult objects can only be concatenated if they either all come from standardized FeatureValues or all unstandardized FeatureValues.');
                end
                
                if bMasterIsStandardized % check that standardization was the same
% % %                     if ...
% % %                             any(vdMasterFeatureStandardizationMeans ~= oCurrentGuessResult.vdFeatureStandardizationMeans) || ...
% % %                             any(vdMasterFeatureStandardizationStDevs ~= oCurrentGuessResult.vdFeatureStandardizationStDevs)
% % %                         error(...
% % %                             'ClassifierGuessResult:GetPropertiesForVertcat:StandardizationValuesMismatch',...
% % %                             'ClassificationGuessResult objects can only be concatenated if they all have the same standardization values.');
% % %                     end
                end
                
                
                % validate that Group/Sub-Group ID classes are the same
                % insert Group/Sub-Group IDs
                if ~isa(oCurrentGuessResult.viGroupIds, chMasterGroupIdsClass) || ~isa(oCurrentGuessResult.viSubGroupIds, chMasterSubGroupIdsClass)
                    error(...
                            'ClassifierGuessResult:GetPropertiesForVertcat:GroupAndSubGroupIdsClassMistmatch',...
                            'ClassificationGuessResult objects can only be concatenated if their Group/Sub-Group IDs are all the same class.');                    
                end
                
                viGroupIds(dInsertIndexStart:dInsertIndexEnd) = oCurrentGuessResult.viGroupIds;
                viSubGroupIds(dInsertIndexStart:dInsertIndexEnd) = oCurrentGuessResult.viSubGroupIds;
                
                
                % validate that Label classes are the same, and positive
                % and negative labels are the same.
                % insert labels
                if ~isa(oCurrentGuessResult.viLabels, chMasterLabelClass) || oCurrentGuessResult.iPositiveLabel ~= iMasterPositiveLabel || oCurrentGuessResult.iNegativeLabel ~= iMasterNegativeLabel
                    error(...
                        'ClassifierGuessResult:GetPropertiesForVertcat:LabelClassOrValuesMismatch',...
                        'ClassificationGuessResult objects can only be concatenated if their labels are of the same class and their positive and negative labels are consistent across objects.');
                end
                
                viLabels(dInsertIndexStart:dInsertIndexEnd) = oCurrentGuessResult.viLabels;
                    
                
                % insert confidences
                vdPositiveLabelConfidences(dInsertIndexStart:dInsertIndexEnd) = oCurrentGuessResult.vdPositiveLabelConfidences;
                
                
                % increment insert index
                dInsertIndexStart = dInsertIndexEnd + 1;
            end
                        
            % validate that no Group/Sub-Group ID pairs are repeated
            ClassificationGuessResult.ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, bMasterOverrideDuplicatedSamplesValidation);
            
            
            % concatenate FeatureValuesToFeatureExtractionRecordLinks
            voFeatureValuesToFeatureExtractionRecordLinks = voMasterFeatureValuesToFeatureExtractionRecordLinks;
            
            vdUniqueMasterLinkIndices = unique(vdMasterLinkIndexPerFeature);
            dNumLinks = length(vdUniqueMasterLinkIndices);
            
            for dLinkIndex=1:dNumLinks
                c1oLinksToConcatenate = cell(1,nargin);
                
                vdFeatureIndicesForLink = find(dLinkIndex == vdMasterLinkIndexPerFeature);
                dFeatureIndexForLink = vdFeatureIndicesForLink(1);
                
                for dObjIndex=1:nargin
                    voLinksForObj = varargin{dObjIndex}.voFeatureValuesToFeatureExtractionRecordLinks;
                    vdLinkIndexPerFeatureForObj = varargin{dObjIndex}.vdLinkIndexPerFeature;
                    
                    c1oLinksToConcatenate{dObjIndex} = voLinksForObj(vdLinkIndexPerFeatureForObj(dFeatureIndexForLink));
                end
                
                voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex) = vertcat(c1oLinksToConcatenate{:});
            end
            
            vdLinkIndexPerFeature = vdMasterLinkIndexPerFeature; % since vdMasterLinkIndexPerFeature was used to organize the concatenation
            
            
            % set properties
            chClassifierClassName = chMasterClassifierClassName;
            
            if bAllResultsFromSameClassifier
                chClassifierUuid = chMasterClassifierUuid;
            else
                chClassifierUuid = blanks(36);
            end
            
            vsFeatureNames = vsMasterFeatureNames;
            
            iPositiveLabel = iMasterPositiveLabel;
            iNegativeLabel = iMasterNegativeLabel;
            
            bIsStandardized = bMasterIsStandardized;
            vdFeatureStandardizationMeans = vdMasterFeatureStandardizationMeans;
            vdFeatureStandardizationStDevs = vdMasterFeatureStandardizationStDevs;
            
            
            % figure out if there's any FeatureValue UUIDs that all objects
            % had
            % If so, these FeatureValue objects would also be valid for the
            % concatenated object
            
            c1chValidatedFeatureValuesUuids = cell(dTotalNumValidatedFeatureValuesUuids,1);
            vdNumMatchesPerUuid = zeros(dTotalNumValidatedFeatureValuesUuids,1);
            dNumUuidsInserted = 0;
            
            for dObjIndex=1:nargin
                c1chUuids = varargin{dObjIndex}.c1chValidatedFeatureValuesUuids;
                
                for dUuidIndex=1:length(c1chUuids)
                    chUuidToInsert = c1chUuids{dUuidIndex};
                    bWasInserted = false;
                    
                    for dSearchIndex=1:dNumUuidsInserted
                        if strcmp(c1chValidatedFeatureValuesUuids{dSearchIndex}, chUuidToInsert)
                            vdNumMatchesPerUuid(dSearchIndex) = vdNumMatchesPerUuid(dSearchIndex) + 1;
                            bWasInserted = true;
                            break;
                        end
                    end
                    
                    if ~bWasInserted
                        dNumUuidsInserted = dNumUuidsInserted + 1;
                        c1chUuids{dNumUuidsInserted} = chUuidToInsert;
                        vdNumMatchesPerUuid(dNumUuidsInserted) = 1;
                    end
                end
            end
            
            % select only uuids that were in all objects being concatenated
            c1chValidatedFeatureValuesUuids = c1chValidatedFeatureValuesUuids(vdNumMatchesPerUuid == nargin);            
        end
        
        function ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, bOverrideDuplicatedSamplesValidation)
            % spoof m2dFeatures
            m2dFeaturesSpoof = zeros(size(viGroupIds));
            
            FeatureValues.ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, m2dFeaturesSpoof, bOverrideDuplicatedSamplesValidation);
        end
% % % % %         
% % % % %         function ValidateFeatureNames(vsFeatureNames)
% % % % %             % spoof m2dFeatures
% % % % %             m2dFeaturesSpoof = zeros(size(vsFeatureNames));
% % % % %             
% % % % %             FeatureValues.ValidateFeatureNames(vsFeatureNames, m2dFeaturesSpoof);
% % % % %         end
% % % % %         
% % % % %         function ValidateStandardizationProperities(vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, vsFeatureNames)
% % % % %             if ~isa(bIsStandardized, 'logical') || ~isscalar(bIsStandardized)
% % % % %                 error(...
% % % % %                     'ClassificationGuessResult:ValidateStandardizationProperities:InvalidIsStandardizedClass',...
% % % % %                     'bIsStandardized must of class logical and a scalar value.');
% % % % %             end
% % % % %             
% % % % %             if bIsStandardized
% % % % %                 vdMeanDims = size(vdFeatureStandardizationMeans);
% % % % %                 vdStDevDims = size(vdFeatureStandardizationStDevs);
% % % % %                 vdFeatureNamesDims = size(vsFeatureNames);
% % % % %                 
% % % % %                 if ~all(vdMeanDims == vdFeatureNameDims) || ~all(vdStDevDims == vdFeatureNameDims)
% % % % %                     error(...
% % % % %                         'ClassificationGuessResult:ValidateStandardizationProperities:InvalidStandardizedProperitiesDims',...
% % % % %                         'vdFeatureStandardizationMeans and vdFeatureStandardizationStDevs must have the same dimensions as vsFeatureNames');
% % % % %                 end
% % % % %                 
% % % % %                 if ~isa(vdFeatureStandardizationMeans, 'double') || ~isa(vdFeatureStandardizationStDevs, 'double')
% % % % %                     error(...
% % % % %                         'ClassificationGuessResult:ValidateStandardizationProperities:InvalidStandardizedProperitiesClass',...
% % % % %                         'vdFeatureStandardizationMeans and vdFeatureStandardizationStDevs must both of type double.');
% % % % %                 end
% % % % %             else
% % % % %                 if ~isempty(vdFeatureStandardizationMeans) || ~isempty(vdFeatureStandardizationStDevs)
% % % % %                     error(...
% % % % %                         'ClassificationGuessResult:ValidateStandardizationProperities:InvalidNotStandardizedProperities',...
% % % % %                         'If the bIsStandardized is false, vdFeatureStandardizationMeans and vdFeatureStandardizationStDevs must both be set to [].');
% % % % %                 end
% % % % %             end
% % % % %         end
% % % % %         
% % % % %         function ValidateLabels(viLabels, viGroupIds)
% % % % %             % spoof m2dFeatures
% % % % %             m2dFeaturesSpoof = zeros(size(viGroupIds));
% % % % %             
% % % % %             LabelledFeatureValues.ValidateLabels(viLabels, m2dFeaturesSpoof);
% % % % %         end
% % % % %         
% % % % %         function ValidatePositiveLabel(iPositiveLabel, viLabels)
% % % % %             LabelledFeatureValues.ValidatePositiveLabel(iPositiveLabel, viLabels);
% % % % %         end
% % % % %         
% % % % %         function ValidateNegativeLabel(iNegativeLabel, iPositiveLabel, viLabels)
% % % % %             if ~isa(iNegativeLabel, class(iPositiveLabel))
% % % % %                 error(...
% % % % %                     'ClassificationGuessResult:ValidateNegativeLabel:InvalidClass',...
% % % % %                     'The negative label must be the same type as the positive label.');
% % % % %             end
% % % % %             
% % % % %             if iNegativeLabel == iPositiveLabel
% % % % %                 error(...
% % % % %                     'ClassificationGuessResult:ValidateNegativeLabel:EqualToPositiveLabel',...
% % % % %                     'The negative label cannot be equal to the positive label.');
% % % % %             end
% % % % %             
% % % % %             if sum(viLabels == iNegativeLabel) + sum(viLabels == iPositiveLabel) ~= numel(viLabels)
% % % % %                 error(...
% % % % %                     'ClassificationGuessResult:ValidateNegativeLabel:InvalidMatchToLabels',...
% % % % %                     'The negative label does not match the negative label in the given labels vector.');
% % % % %             end
% % % % %         end
        
        function MustBeValidPositiveLabelConfidences(vdPositiveLabelConfidences, oLabelledFeatureValues)
            vdConfidencesDims = size(vdPositiveLabelConfidences);
            dNumSamples = oLabelledFeatureValues.GetNumberOfSamples();
            
            ValidationUtils.MustBeA(vdPositiveLabelConfidences, 'double');
            ValidationUtils.MustBeColumnVector(vdPositiveLabelConfidences);
            mustBeNonNan(vdPositiveLabelConfidences);
            mustBeNonnegative(vdPositiveLabelConfidences);
            mustBeLessThanOrEqual(vdPositiveLabelConfidences,1);
            ValidationUtils.MustBeOfSize(vdPositiveLabelConfidences, [dNumSamples,1]);
        end
        
        function MustBeValidLabelledFeatureValues(oLabelledFeatureValues, bOverrideDuplicatedSamplesValidation)
            
            ValidationUtils.MustBeA(oLabelledFeatureValues, 'LabelledFeatureValues');
            
            % validate that the used oLabelledFeatureValues object has
            % NO DUPLICATED SAMPLES!
            if oLabelledFeatureValues.ContainsDuplicatedSamples() && ~bOverrideDuplicatedSamplesValidation
                error(...
                    'ClassificationGuessResult:MustBeValidLabelledFeatureValues:InvalidLabelledFeatureValues',...
                    'LabelledFeatureValue objects used for testing (e.g. Classifier.Guess) MAY NOT CONTAIN DUPLICATED SAMPLES! DOING SO WOULD BE A SCIENTIFIC ERROR!');
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
        
        function obj = Constructor_UnitTestAccess(varargin)
            obj = ClassificationGuessResult(varargin{:});
        end
    end
end

