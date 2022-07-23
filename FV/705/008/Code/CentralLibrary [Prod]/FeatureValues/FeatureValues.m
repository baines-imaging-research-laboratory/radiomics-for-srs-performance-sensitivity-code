classdef (Abstract) FeatureValues
    %FeatureValues
    %
    % FeatureValues is an ABSTRACT class (cannot be instianted) that
    % describes a common functionality that all implementations of a
    % FeatureValues object should provide. It also provides validation
    % functions for the data that would likely be stored with a
    % FeatureValues object
    
    % Primary Author: David DeVries
    % Created: Mar 8, 2019
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************
        
    properties (SetAccess = immutable, GetAccess = public)
        chUuid = ''
        bContainsDuplicatedSamples (1,1) logical = false % set to true if a sample is or has ever been duplicated with the FeatureValues object
    end
    
    properties (SetAccess = protected, GetAccess = public)
        % store the state of the FeatureValue object's standardization
        vdFeatureStandardizationMeans (1,:) double = []
        vdFeatureStandardizationStDevs (1,:) double = []
        bIsStandardized (1,1) logical = false
        bIsPerturbed (1,1) logical = false
        m2dPerturbationMatrix (:,:) double = []
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract = true)
        
        viGroupIds = GetGroupIds(obj)
        %viGroupIds = GetGroupIds(obj)
        %
        % SYNTAX:
        %  viGroupIds = obj.GetGroupIds()
        %
        % DESCRIPTION:
        %  Returns the Group IDs for the samples (with duplicates)
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  viGroupIds: Column vector of integers (one for each row,
        %              including duplicates)
        
        viSubGroupIds = GetSubGroupIds(obj)
        %viSubGroupIds = GetSubGroupIds(obj)
        %
        % SYNTAX:
        %  viSubGroupIds = obj.GetSubGroupIds()
        %
        % DESCRIPTION:
        %  Returns the Sub Group IDs for the samples (with duplicates)
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  viSubGroupIds: Column vector of integers (one for each row,
        %                 including duplicates)
        
        vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
        %vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
        %
        % SYNTAX:
        %  vsUserDefinedSampleStrings = obj.GetUserDefinedSampleStrings()
        %
        % DESCRIPTION:
        %  Returns the custom user defined strings for each sample
        %  (row) in the feature table (including duplicates).
        %  SHOULD ONLY BE USED FOR DISPLAY/DEBUGGING purposes!
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  vsUserDefinedSampleStrings: Column vector of strings (one
        %                              for each row, including duplicates)
                
        vsFeatureNames = GetFeatureNames(obj)
        %vsFeatureNames = GetFeatureNames(obj)
        %
        % SYNTAX:
        %  vsFeatureNames = obj.GetFeatureNames()
        %
        % DESCRIPTION:
        %  Returns the Feature Names for each column of the featue table
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  vsFeatureNames: String row vector (one for each column)
        
        vdDims = size(obj, varargin)
        %vdDims = size(obj, varargin)
        %
        % SYNTAX:
        %  vdDims = size(obj)
        %  vdDims = size(obj, dDim)
        %
        % DESCRIPTION:
        %  Returns the size of the FeatureValues object, where the number
        %  rows is the number of samples and the number of columns is the
        %  number of features. There should be no further dimensions
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %  dDim: Dimension number
        %
        % OUTPUTS ARGUMENTS:
        %  vdDims: Scalar or vector of dimensions
        
    end

    
    methods (Access = public)
        
%         function obj = FeatureValues(s)
%             obj.oFeatureValuesIdentifier = s.oFeatureValuesIdentifier;
%             obj.bContainsDuplicatedSamples = s.bContainsDuplicatedSamples;
%             obj.vdFeatureStandardizationMeans = s.vdFeatureStandardizationMeans;
%             obj.vdFeatureStandardizationStDevs = s.vdFeatureStandardizationStDevs;
%             obj.bIsStandardized = s.bIsStandardized;
%         end
        
        function obj = FeatureValues(varargin)
            %obj = FeatureValues(varargin)
            %
            % SYNTAX:
            %   obj = FeatureValues()
            %   obj = FeatureValues(oFeatureValuesOnDiskIdentifier)
            %   obj = FeatureValues(oFeatureValues, vdRowSelection, vdColSelection)
            %   obj = FeatureValues(oFeatureValues)
            %   obj = FeatureValues(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, oFeatureValuesToFeatureExtractionRecordLink)
            %   obj = FeatureValues('horzcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature, oFeatureValues1, oFeatureValues2, ...)
            %   obj = FeatureValues('vertcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature, oFeatureValues1, oFeatureValues2, ...)
            %
            % DESCRIPTION:
            %  obj = FeatureValues() can only be used if through the
            %    inheritance structure, the FeatureValues constructor has
            %    already been called. This allows for a solution around the
            %    "Diamond Problem" and allows for computationally intensive
            %    constructors to be avoided from being called multiple
            %    times. If it wasn't called before, the constructor will
            %    know.
            %  obj = FeatureValues(oFeatureValuesOnDiskIdentifier) uses a 
            %    oFeatureValuesOnDiskIdentifier object to load the
            %    neccesary data FeatureValues requires
            %  obj = FeatureValues(oFeatureValues, vdRowSelection, vdColSelection)
            %    produces a new FeatureValues object for the given row and
            %    column selection from an existing FeatureValues object.
            %    This could be reducing or duplicating rows, but only
            %    reducing columns. The produced object will have the same
            %    FeatureValuesIdentifier as the provided object.
            %  obj = FeatureValues(oFeatureValues)
            %    produces a new FeatureValues object that is a copy of the
            %    oFeatureValues object
            %  obj = FeatureValues(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames)
            %    produces a new FeatureValues object given the required
            %    properties. All of these properties are validated,
            %    assuming that they do not contain any duplicated samples.
            %  obj = FeatureValues('horzcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, oFeatureValues1, oFeatureValues2, ...)
            %    produces a new FeatureValues object that concatenates the
            %    provides FeatureValue objects (oFeatureValues1,
            %    oFeatureValues2, etc.). It also takes in what the
            %    sub-class implementation anticipates using as it's key
            %    properties. These properties should not contain duplciated
            %    samples. Horizontal concatenation requires the same
            %    samples, but new features (columns).
            %  obj = FeatureValues('vertcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, oFeatureValues1, oFeatureValues2, ...)
            %    same as "obj = FeatureValues('horzcat',...", except for
            %    vertical concatenation. Vertical concatenation requires the
            %    same features, but new samples (rows).
            %
            % INPUT ARGUMENTS:
            %  oFeatureValuesOnDiskIdentifier: A valid FeatureValuesOnDiskIdentifier
            %                                  object
            %  oFeatureValues: A valid FeatureValue object
            %  vdRowSelection: A row vector of row index numbers to select
            %  vdColSelection: A row vector of column index numbers to select
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %  viGroupIds: column vector of Group Ids for each sample. Do
            %              not to be unique
            %  viSubGroupIds: column vector of Sub Group Ids for each
            %                 sample. Need to be unique within a given Group
            %                 Id
            %  vsUserDefinedSampleStrings: a column string vector of custom
            %                              user-defined strings for each
            %                              sample
            %  vsFeatureNames: a row string array of feature names for each
            %                  column in the m2dFeatures
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed class object
            
            
            if nargin == 0
                % For: obj = FeatureValues()
                
                if isempty(obj.chUuid)
                    error(...
                        'FeatureValues:Constructor:InvalidEmptyCall',...
                        'The FeatureValues constructor was called without any parameters, suggesting the sub-class wanted to skip the constructor because it has already been called by a different inheritance path (e.g. the diamond problem). This did not occur though. Please check the order of your super-class constructor calls.');                
                end
            elseif nargin == 1 && isa(varargin{1}, 'FeatureValuesOnDiskIdentifier')
                % For: obj = FeatureValues(oFeatureValuesOnDiskIdentifier)

                oFeatureValuesOnDiskIdentifier = varargin{1};
                
                obj.vdFeatureStandardizationMeans = oFeatureValuesOnDiskIdentifier.GetFeatureStandardizationMeans();
                obj.vdFeatureStandardizationStDevs = oFeatureValuesOnDiskIdentifier.GetFeatureStandardizationStDevs();
                obj.bIsStandardized = oFeatureValuesOnDiskIdentifier.GetIsStandardized();
                
                obj.bContainsDuplicatedSamples = oFeatureValuesOnDiskIdentifier.GetContainsDuplicatedSamples();
                
            elseif nargin == 3 && isa(varargin{1}, 'FeatureValues')                
                % For: obj = FeatureValues(oFeatureValues, vdRowSelection, vdColSelection)
                
                oFeatureValues = varargin{1};
                vdRowSelection = varargin{2};
                vdColSelection = varargin{3};
                
                if ~isrow(vdRowSelection) || ~isrow(vdColSelection) || ~isa(vdRowSelection, 'double') || ~isa(vdColSelection, 'double')
                    error(...
                        'FeatureValues:Constructor:InvalidColumnSelection',...
                        'The given row and column selection vectors must be row vectors of doubles.');
                end
                                
                % transfer standardization
                if oFeatureValues.bIsStandardized
                    obj.vdFeatureStandardizationMeans = oFeatureValues.vdFeatureStandardizationMeans(vdColSelection);
                    obj.vdFeatureStandardizationStDevs = oFeatureValues.vdFeatureStandardizationStDevs(vdColSelection);
                end
                
                obj.bIsStandardized = oFeatureValues.bIsStandardized;
                
                % check for duplications
                
                % row check
                if length(unique(vdRowSelection)) == length(vdRowSelection) % no row duplciates
                    obj.bContainsDuplicatedSamples = false || oFeatureValues.bContainsDuplicatedSamples; % if it at one point contained duplicate samples, the flag will always be true
                else
                    obj.bContainsDuplicatedSamples = true;
                end
                
                % col check
                if length(unique(vdColSelection)) ~= length(vdColSelection)
                    error(...
                        'FeatureValues:Constructor:InvalidColumnSelection',...
                        'When creating a new FeatureValues object from an existing FeatureValues object, the column selection must contain only unique values.');
                end
            elseif nargin == 1 && isa(varargin{1}, 'FeatureValues')
                oFeatureValues = varargin{1};
                
                obj.bContainsDuplicatedSamples = oFeatureValues.bContainsDuplicatedSamples;
                obj.vdFeatureStandardizationMeans = oFeatureValues.vdFeatureStandardizationMeans;
                obj.vdFeatureStandardizationStDevs = oFeatureValues.vdFeatureStandardizationStDevs;
                obj.bIsStandardized = oFeatureValues.bIsStandardized;
            elseif nargin >= 11 && isa(varargin{1}, 'char') && (strcmp(varargin{1}, 'horzcat') || strcmp(varargin{1}, 'vertcat')) && CellArrayUtils.AreAllIndexClassesEqual(varargin(10:end)) && isa(varargin{10}, 'FeatureValues')
                % For: obj = FeatureValues('horzcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature, oFeatureValues1, oFeatureValues2, ...)
                %      obj = FeatureValues('vertcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature, oFeatureValues1, oFeatureValues2, ...)
                
                % property values the sub-class anticipates using
                m2dUnstandardizedNonDuplicatedFeatures = varargin{2};
                
                viNonDuplicatedGroupIds = varargin{3};
                viNonDuplicatedSubGroupIds = varargin{4};
                
                vsNonDuplicatedUserDefinedSampleStrings = varargin{5};
                vsFeatureNames = varargin{6};
                
                vbFeatureIsCateogrical = varargin{7};
                
                voNonDuplicatedFeatureValuesToFeatureExtractionRecordLinks = varargin{8};
                vdLinkIndexPerFeature = varargin{9};
                   
                % validate as if their new input
% % %                 FeatureValues.ValidateInputs(...
% % %                     m2dUnstandardizedNonDuplicatedFeatures, viNonDuplicatedGroupIds, viNonDuplicatedSubGroupIds,...
% % %                     vsNonDuplicatedUserDefinedSampleStrings, vsFeatureNames);
                
                % get standardization and duplication values
                if strcmp(varargin{1}, 'horzcat')
                    [vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples]...
                        = FeatureValues.GetProperitiesForHorzcat(varargin{10:end});
                else
                    [vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples]...
                        = FeatureValues.GetProperitiesForVertcat(varargin{10:end});
                end
                
                obj.vdFeatureStandardizationMeans = vdFeatureStandardizationMeans;
                obj.vdFeatureStandardizationStDevs = vdFeatureStandardizationStDevs;
                obj.bIsStandardized = bIsStandardized;
                obj.bContainsDuplicatedSamples = bContainsDuplicatedSamples;
                
            elseif nargin == 7
                % For: obj = FeatureValues(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, oFeatureExtractionRecord)
                
                m2dUnstandardizedNonDuplicatedFeatures = varargin{1};
                
                viNonDuplicatedGroupIds = varargin{2};
                viNonDuplicatedSubGroupIds = varargin{3};
                
                vsNonDuplicatedUserDefinedSampleStrings = varargin{4};
                vsFeatureNames = varargin{5};
                vbFeatureIsCategorical = varargin{6};
                
                oFeatureValuesToFeatureExtractionRecordLink = varargin{7};
                vdLinkIndexPerFeature = 1;
                                
                FeatureValues.ValidateInputs(...
                    m2dUnstandardizedNonDuplicatedFeatures, viNonDuplicatedGroupIds, viNonDuplicatedSubGroupIds,...
                    vsNonDuplicatedUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical,...
                    oFeatureValuesToFeatureExtractionRecordLink);             
            else
                error(...
                    'FeatureValues:Constructor:InvalidParameters',...
                    'See constructor documentation for usage.');
            end
            
            % not matter what change occurs, a new UUID is made
            obj.chUuid = char(java.util.UUID.randomUUID());
        end
    end
    
    
    methods (Access = public, Sealed = true)
        
        function chUuid = GetUuid(obj)
            chUuid = obj.chUuid;
        end
        
        function vdSampleIndices = GetSampleIndicesFromGroupAndSubGroupIds(obj, viGroupIds, viSubGroupIds)
            arguments
                obj (:,:) FeatureValues {MustNotContainDuplicatedSamples(obj)}
                viGroupIds (:,1) {ValidationUtils.MustBeIntegerClass(viGroupIds)}
                viSubGroupIds (:,1) {ValidationUtils.MustBeIntegerClass(viSubGroupIds), ValidationUtils.MustBeSameSize(viGroupIds, viSubGroupIds)}
            end
            
            dNumIds = length(viGroupIds);
            
            vdSampleIndices = zeros(1,dNumIds);
            
            viCurrentGroupIds = obj.GetGroupIds();
            viCurrentSubGroupIds = obj.GetSubGroupIds();
            
            for dIdIndex=1:dNumIds
                vdGroupIdMatches = find(viCurrentGroupIds == viGroupIds(dIdIndex) & viCurrentSubGroupIds == viSubGroupIds(dIdIndex));
                
                if isscalar(vdGroupIdMatches)
                    vdSampleIndices(dIdIndex) = vdGroupIdMatches(1);
                else
                    error(...
                        'FeatureValues:GetSampleIndicesFromGroupAndSubGroupIds:NoMatchFound',...
                        ['No unique match found for Group ID ' , num2str(viGroupIds(dIdIndex)), ' and Sub-Group ID ', num2str(viSubGroupIds(dIdIndex)), '.']);
                end
            end
        end
        
        function oFeatureExtractionRecord = GetFeatureExtractionRecord(obj, dFeatureIndex)
            arguments
                obj
                dFeatureIndex (1,1) double {mustBeInteger, mustBePositive, ValidateFeatureIndexMax(obj, dFeatureIndex)}
            end
            
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            vdLinkIndexPerFeature = obj.GetLinkIndexPerFeature();
            
            oFeatureExtractionRecord = voFeatureValuesToFeatureExtractionRecordLinks(vdLinkIndexPerFeature(dFeatureIndex)).GetFeatureExtractionRecord();
        end
        
        function [oImageVolume, dRoiNumber] = GetImageVolumeAndRegionOfInterestNumberForIndex(obj, dSampleIndex, dFeatureIndex)
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            vdLinkIndexPerFeature = obj.GetLinkIndexPerFeature();
            
            dLinkIndex = vdLinkIndexPerFeature(dFeatureIndex);            
            oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                        
            [oImageVolume, dRoiNumber] = oLink.GetImageVolumeAndRegionOfInterestNumberForSampleIndex(dSampleIndex);
        end
        
        function [oImageVolumeHandler, dExtractionIndex] = GetImageVolumeHandlerAndExtractionIndexForIndex(obj, dSampleIndex, dFeatureIndex)
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            vdLinkIndexPerFeature = obj.GetLinkIndexPerFeature();
            
            dLinkIndex = vdLinkIndexPerFeature(dFeatureIndex);            
            oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                        
            [oImageVolumeHandler, dExtractionIndex] = oLink.GetImageVolumeHandlerAndExtractionIndexForSampleIndex(dSampleIndex);
        end
        
        function [voImageVolumeHandlers, vdExtractionIndices] = GetAllImageVolumeHandlersAndExtractionIndicesForFeatureSource(obj, sFeatureSource)
            arguments
                obj
                sFeatureSource (1,1) string
            end
            
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
                        
            oLink = [];
            
            for dLinkIndex=1:length(voFeatureValuesToFeatureExtractionRecordLinks)
                if sFeatureSource == voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex).GetFeatureExtractionRecord().GetFeatureSource()
                    oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                    break;
                end
            end
            
            if isempty(oLink)
                error(...
                    'FeatureValues:GetAllImageVolumeHandlersAndExtractionIndicesForFeatureSource:InvalidFeatureSource',...
                    ['Not matching FeatureExtractionRecord for FeatureSource "', sFeatureSource, '".']);
            end
            
            oFirstHandler = oLink.GetImageVolumeHandlerAndExtractionIndexForSampleIndex(1);
            
            dNumSamples = obj.GetNumberOfSamples();
            
            voImageVolumeHandlers = repmat(oFirstHandler, dNumSamples, 1);
            vdExtractionIndices = zeros(dNumSamples,1);
            
            for dSampleIndex=1:dNumSamples
                [oImageVolumeHandler, dExtractionIndex] = oLink.GetImageVolumeHandlerAndExtractionIndexForSampleIndex(dSampleIndex);
                
                voImageVolumeHandlers(dSampleIndex) = oImageVolumeHandler;
                vdExtractionIndices(dSampleIndex) = dExtractionIndex;
            end
        end
        
        function DisplayFeatureSourceExtractionSummary(obj)
            FeatureValuesToFeatureExtractionRecordLink.DisplayFeatureSourceExtractionSummary(...
                obj.GetFeatureValuesToFeatureExtractionRecordLinks());
        end
        
        function DisplayFeatureSourceSummaryForSamples(obj)
            FeatureValuesToFeatureExtractionRecordLink.DisplayFeatureSourceSummaryForSamples(...
                obj.GetFeatureValuesToFeatureExtractionRecordLinks(),...
                obj.GetGroupIds(), obj.GetSubGroupIds());            
        end
        
        function bContainDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %bContainDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %
            % SYNTAX:
            %  bContainDuplicatedSamples = obj.ContainsDuplicatedSamples()
            %
            % DESCRIPTION:
            %  Returns if the FeatureValues object contains duplicated
            %  samples (or if it did a one point). Once a FeatureValues
            %  object has been marked as contained duplicated values, this
            %  cannot not be undone. This prevents accidental invalid
            %  testing on duplicated samples.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  bContainDuplicatedSamples: True if the FeatureValues
            %                             does/has contained duplicated
            %                             samples
            
            bContainDuplicatedSamples = obj.bContainsDuplicatedSamples;
        end
        
        function m2dFeatures = GetFeatures(obj)
            %m2dFeatures = GetFeatures(obj)
            %
            % SYNTAX:
            %  m2dFeatures = obj.GetFeatures()
            %
            % DESCRIPTION:
            %  Returns the 2D feature table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dFeatures: Feature table where features run across the
            %               columns and samples run across the rows
            
            if obj.IsStandardized
                m2dFeatures = obj.GetUnstandardizedFeatures();
                vbFeatureIsCategorical = obj.IsFeatureCategorical();
                
                % only apply standarization to non-categorical features
                m2dFeatures(:, ~vbFeatureIsCategorical) = (m2dFeatures(:, ~vbFeatureIsCategorical) - obj.vdFeatureStandardizationMeans(~vbFeatureIsCategorical)) ./ obj.vdFeatureStandardizationStDevs(~vbFeatureIsCategorical);
            else
                m2dFeatures = obj.GetUnstandardizedFeatures();
            end
            
            if obj.bIsPerturbed
                m2dFeatures = m2dFeatures + obj.m2dPerturbationMatrix;
            end
            
            % check for any NaNs, Inf, -Inf (don't worry, no copying
            % happens during this check)
            if any(isnan(m2dFeatures(:)))
                error(...
                    'FeatureValues:GetFeatures:InvalidNaN',...
                    'A NaN value was detected on output.');
            end
            
            if any(isinf(m2dFeatures(:)))
                error(...
                    'FeatureValues:ValidateFeatures:InvalidInf',...
                    'An Inf value was detected on output.');
            end
        end
        
        function dNumGroups = GetNumberOfGroups(obj)
            %dNumGroups = GetNumberOfGroups(obj)
            %
            % SYNTAX:
            %   dNumGroups = obj.GetNumberOfGroups()
            %
            % DESCRIPTION:
            %  Returns the number of unique groups with the feature values
            %  object
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumGroups: The number of groups
            
            dNumGroups = length(unique(obj.GetGroupIds));
        end
        
        function bIsStandardized = IsStandardized(obj)
            %bIsStandardized = IsStandardized(obj)
            %
            % SYNTAX:
            %   bIsStandardized = obj.IsStandardized()
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
            %   vdFeatureStandardizationMeans = obj.GetFeatureStandardizationMeans()
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
            %   vdFeatureStandardizationStDevs = obj.GetFeatureStandardizationStDevs()
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
        
        function obj = Standardize(obj)
            %obj = Standardize(obj)
            %
            % SYNTAX:
            %  obj = Standardize(obj)
            %
            % DESCRIPTION:
            %  Standardizes (mean = 0, variance = 1) the data in each feature
            %  column
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object (standardized)
            
            if ~obj.bIsStandardized
                obj.vdFeatureStandardizationMeans = mean(obj.GetUnstandardizedFeatures(),1);
                obj.vdFeatureStandardizationStDevs = std(obj.GetUnstandardizedFeatures(),0,1);
                
                % categorical features don't get standardized
                obj.vdFeatureStandardizationMeans(obj.IsFeatureCategorical()) = NaN;
                obj.vdFeatureStandardizationStDevs(obj.IsFeatureCategorical()) = NaN;
                
                if any(obj.vdFeatureStandardizationStDevs(:) == 0)
                    error(...
                        'FeatureValues:Standardize:InvalidStDev',...
                        'Cannot standardize if any features have a standard deviation of zero.');
                end
                
                obj.bIsStandardized = true;
            else
                error(...
                    'FeatureValues:Standardize:InvalidRequest',...
                    'The FeatureValues object is already standardized and cannot be standardized again');
            end
        end
        
        function obj = TransferStandardization(obj, oFeatureValues)
            % obj = TransferStandardization(obj, oFeatureValues)
            %
            % SYNTAX:
            %  obj = TransferStandardization(obj, oFeatureValues)
            %
            % DESCRIPTION:
            %  Transfer the standardization of oFeatureValues to obj. This
            %  allows for an new data set to be standardized in the same
            %  manner as a previous data set used for training/testing. obj
            %  and oFeatureValues MUST have the same feature in each and
            %  every column. oFeatureValues must also be already
            %  standardized, and obj must be un-standardized
            %
            % INPUT ARGUMENTS:
            %  obj: Class object (un-standardized)
            %  oFeatureValues: Standardized FeatureValues object            %  
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object (standardized)
            
            arguments
                obj
                oFeatureValues (:,:) FeatureValues
            end
            
            % validate standardization status
            if obj.IsStandardized()
                error(...
                    'FeatureValues:TransferStandardization:AlreadyStandardized',...
                    'Cannot transfer standardization values to a FeatureValues object already standardized. Use the ".Destandardize()" function first and then apply this function.');
            end
            
            if ~oFeatureValues.IsStandardized()
                error(...
                    'FeatureValues:TransferStandardization:SourceNotStandardized',...
                    'Cannot transfer standardization values to from a FeatureValues object that is not standardized. Use the ".Standardize()" function to standardize the source FeatureValues object.');
            end
            
            if ~FeatureValues.AreFeaturesEqual(obj, oFeatureValues)
                error(...
                    'FeatureValues:TransferStandardization:FeaturesNotEqual',...
                    'The features were not found to be in the same order, have the same name, or from the same source, and so transferring standardization values would be a scientific error.');
            end
            
            % transfer the standardization
            obj.vdFeatureStandardizationMeans = oFeatureValues.vdFeatureStandardizationMeans;
            obj.vdFeatureStandardizationStDevs = oFeatureValues.vdFeatureStandardizationStDevs;
            obj.bIsStandardized = true;
        end
        
        function obj = Destandardize(obj)
            %obj = Destandardize(obj)
            %
            % SYNTAX:
            %  obj = Destandardize(obj)
            %
            % DESCRIPTION:
            %  Detandardizes the data in each feature column according to the
            %  stored means and variance from when the data was originally
            %  standardized
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object (destandardized)
            
            if obj.bIsStandardized
                obj.vdFeatureStandardizationMeans = [];
                obj.vdFeatureStandardizationStDevs = [];
                
                obj.bIsStandardized = false;
            else
                error(...
                    'FeatureValues:Destandardize:InvalidRequest',...
                    'The FeatureValues object is already destandardized and cannot be destandardized again');
            end
        end
        
        function [obj, vsRemovedFeatures, vbRemovedFeaturesMask] = RemoveFeaturesWithZeroVariance(obj)
            %[obj, vsRemovedFeatures, vbRemovedFeaturesMask] = RemoveFeaturesWithZeroVariance(obj)
            %
            % SYNTAX:
            %   [obj, vsRemovedFeatures, vbRemovedFeaturesMask] = obj.RemoveFeaturesWithZeroVariance()
            %
            % DESCRIPTION:
            %  This method removes features that have zero variance within their values. Zero
            %  variance almost surely means that the feature is constant. The removal of such 
            %  features is very important because these features do no add useful information
            %  for machine learning, add unnecessary computation time, and cause methods that assume 
            %  a normal distribution to behave unexpectedly, auch as the MATLAB naive-bayes classifier.
            %  
            %
            % INPUT ARGUMENTS:
            %  obj: this class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: this class object with the features that have zero variance removed
            %  vsRemovedFeatures: list of the names of the features which were removed
            %  vbRemovedFeaturesMask: mask with as many columns as the
            %    original feature values object, with true values showing
            %    which features were removed
            %
            % Author: Salma 
            
            % Create a mask that starts with all features being retained
            vbRetainedFeaturesnMask = true(1, obj.GetNumberOfFeatures());
                 
            % Loop through features and check the variance within their values
            for dFeature = 1:obj.GetNumberOfFeatures()                
                
                 oCurrentFeatureValues = obj.SelectRowsAndColumns(':',dFeature);
                 vdCurrentFeatureValues = oCurrentFeatureValues.GetFeatures();                 
                 
                 % If the variance is zero, set the retention value to false for the corresponding
                 % feature
                 if var(vdCurrentFeatureValues) == 0
                    vbRetainedFeaturesnMask(dFeature) = false; 
                 end                
            end
            vbRemovedFeaturesMask = ~vbRetainedFeaturesnMask;            
            
            % Grab the list of names of features, and modify (or not) according to the different scenarios
            vsRemovedFeatures = obj.GetFeatureNames();
                
            % If the user called this function and it did nothing, let them know
            if sum(vbRemovedFeaturesMask) == 0
                warning("FeatureValues:RemoveConstantFeatures:NoneRemoved",...
                    "No constant features were found, therefore, none were removed.")
                
            
            elseif sum(vbRetainedFeaturesnMask) == 0                
                error("FeatureValues:RemoveConstantFeatures:AllRemoved",...
                    "All the features had zero variance and were all removed. This object now has no features.")
            
            elseif sum(vbRemovedFeaturesMask) ~= 0               
                % Then remove the flagged features
                obj = obj.SelectRowsAndColumns(':',find(vbRetainedFeaturesnMask));
                vsRemovedFeatures = vsRemovedFeatures(vbRemovedFeaturesMask);                
            end 
        end
        
        function dNumFeatures = GetNumberOfFeatures(obj)
            %dNumFeatures = GetNumberOfFeatures(obj)
            %
            % SYNTAX:
            %  dNumFeatures = obj.GetNumberOfFeatures()
            %
            % DESCRIPTION:
            %  Returns the number of features
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumFeatures: The number of features (columns)
            
            dNumFeatures = size(obj,2);
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            %dNumSamples = GetNumberOfSamples(obj)
            %
            % SYNTAX:
            %  dNumSamples = obj.GetNumberOfSamples()
            %
            % DESCRIPTION:
            %  Returns the number of samples
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumSamples: The number of samples (rows)
            
            dNumSamples = size(obj,1);
        end
    end
    
    
    methods (Access = public)
        
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  displays FeatureValues as a column of Group IDs, column of
            %  Sub Group Ids, and then the feature table with Feature Name
            %  headings
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            [c1chDispHeaderValues, chDispHeaderFormat] = obj.GetHeaderForDisp();
            
            % print headings
            fprintf(chDispHeaderFormat, c1chDispHeaderValues{:});
            fprintf(newline);
            
            % print rows of feature values
            obj.PrintRowsForDisp();
            
            % print legend for duplicate samples if needed           
            if obj.ContainsDuplicatedSamples()
                fprintf(newline);
                fprintf('* - Duplicated Samples');
                fprintf(newline);
            end
            
            % print feature sources
            fprintf(newline);            
            fprintf('Feature Sources:');
            fprintf(newline);
            
            voLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            
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
            %  be made on FeatureValue objects. While most of the heavy
            %  lifting is left to the sub-class, this function checks that
            %  now row or column duplication is happening through
            %  selection, only sub-selection. To duplicate rows, see
            %  specific functionality of sub-classes.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Class object
            
            varargout = {obj};
            
            % sub-class specific
%             if strcmp(stSelection(1).type, '()')
%                 for dDimIndex=1:length(stSelection(1).subs)                
%                     if ~strcmp(stSelection(1).subs{dDimIndex}, ':') &&...
%                             ~islogical(stSelection(1).subs{dDimIndex}) && ...
%                             length(stSelection(1).subs{dDimIndex}) ~= length(unique(stSelection(1).subs{dDimIndex}))
%                         
%                         error(...
%                             'FeatureValues:subsref:NonUniqueSelection',...
%                             'When selecting rows or columns from a FeatureValues object, the select indices for each dimension must be unique. Use the provided balancing functionality to insert duplicate values.');
%                     end
%                 end
%             end
        end
    end
    
    
    methods (Access = public, Static = true)
        function bBool = AreFeaturesEqual(oFeatureValues1, oFeatureValues2)
            %bBool = AreFeaturesEqual(oFeatureValues1, oFeatureValues2)
            %
            % SYNTAX:
            %  bBool = FeatureValues.AreFeaturesEqual(oFeatureValues1, oFeatureValues2)
            %
            % DESCRIPTION:
            %  Returns true if the features in each of the FeatureValue
            %  objects are equal. This does NOT mean that the objects are
            %  equal or that the values of each feature/sample are equal.
            %  Rather, it means that each feature/column has the same name,
            %  comes from the same source/feature extraction version,
            %  appears in the same order from left to right, and is marked
            %  as categorical or not.
            %  The FeatureValue objects do NOT need to both be standardized or
            %  un-standardized for their features to be considered equal
            %
            % INPUT ARGUMENTS:
            %  oFeatureValues1: Class object
            %  oFeatureValues2: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  bBool: true if features are equal, false otherwise
            
            
            arguments
                oFeatureValues1 (:,:) FeatureValues
                oFeatureValues2 (:,:) FeatureValues
            end
            
            bBool = true;
            
            if oFeatureValues1.GetNumberOfFeatures() ~= oFeatureValues2.GetNumberOfFeatures()
                bBool = false;
            else
                dNumFeatures = oFeatureValues1.GetNumberOfFeatures();
                
                vsFeatureNames1 = oFeatureValues1.GetFeatureNames();
                vsFeatureNames2 = oFeatureValues2.GetFeatureNames();
                
                if any(vsFeatureNames1 ~= vsFeatureNames2)
                    bBool = false;
                elseif any(oFeatureValues1.IsFeatureCategorical() ~= oFeatureValues2.IsFeatureCategorical())
                    bBool = false;
                else
                    for dFeatureIndex=1:dNumFeatures                        
                        % check feature sources are equal
                        oExtractionRecord1 = oFeatureValues1.GetFeatureExtractionRecord(dFeatureIndex);
                        oExtractionRecord2 = oFeatureValues2.GetFeatureExtractionRecord(dFeatureIndex);
                        
                        if ~strcmp(oExtractionRecord1.GetUuid(), oExtractionRecord2.GetUuid())
                            bBool = false;
                            break;
                        end
                    end
                end
            end
        end
    end
    
   
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract = true)
              
        m2dFeatures = GetFeaturesForDisp(obj)
        
        m2dFeatures = GetUnstandardizedFeatures(obj)
        %m2dFeatures = GetUnstandardizedFeatures(obj)
        %
        % SYNTAX:
        %  m2dFeatures = obj.GetUnstandardizedFeatures()
        %
        % DESCRIPTION:
        %  Returns the unstandardized feature table with duplicated
        %  samples included
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  m2dFeatures: Unstandardized feature table 
        
        vbIsDuplicatedSample = GetIsDuplicatedSample(obj)
        %vbIsDuplicatedSample = GetIsDuplicatedSample(obj)
        %
        % SYNTAX:
        %  vbIsDuplicatedSample = obj.GetIsDuplicatedSample()
        %
        % DESCRIPTION:
        %  Returns the a column vector of booleans that specify if a
        %  row/sample has or was duplicated. Should only be used
        %  internallly, hence why it's protected
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  vbIsDuplicatedSample: Column vector of booleans (one
        %                        for each row, including duplicates)
    end
    
    
    methods (Access = {?FeatureValues, ?FeatureValuesOnDiskIdentifier}, Abstract = true)
        % Only accessible to sub-classes and the FeatureValuesIdentifier class
        
        m2dFeatures = GetNonDuplicatedUnstandardizedFeatures(obj)
        %m2dFeatures = GetNonDuplicatedUnstandardizedFeatures(obj)
        %
        % SYNTAX:
        %  m2dFeatures = obj.GetNonDuplicatedUnstandardizedFeatures()
        %
        % DESCRIPTION:
        %  Returns the unstandardized feature table without any duplicated
        %  samples
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  m2dFeatures: Unstandardized feature table without duplicates
        
        viGroupIds = GetNonDuplicatedGroupIds(obj)
        %viGroupIds = GetNonDuplicatedGroupIds(obj)
        %
        % SYNTAX:
        %  viGroupIds = obj.GetNonDuplicatedGroupIds()
        %
        % DESCRIPTION:
        %  Returns the sample Group IDs without any duplicates
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  viGroupIds: Group IDs without duplicates
        
        viSubGroupIds = GetNonDuplicatedSubGroupIds(obj)
        %viSubGroupIds = GetNonDuplicatedSubGroupIds(obj)
        %
        % SYNTAX:
        %  viSubGroupIds = obj.GetNonDuplicatedSubGroupIds()
        %
        % DESCRIPTION:
        %  Returns the sample Sub-Group IDs without any duplicates
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  viSubGroupIds: Sub-Group IDs without duplicates
        
        vsUserDefinedSampleStrings = GetNonDuplicatedUserDefinedSampleStrings(obj)
        %vsUserDefinedSampleStrings = GetNonDuplicatedUserDefinedSampleStrings(obj)
        %
        % SYNTAX:
        %  vsUserDefinedSampleStrings = obj.GetNonDuplicatedUserDefinedSampleStrings()
        %
        % DESCRIPTION:
        %  Returns the sample strings without any duplicates
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  vsUserDefinedSampleStrings: Custom string for each sample without
        %                              duplicates
                
        vdRowSelection = GetRowSelectionForNonDuplicatedProperties(obj)
        %vdRowSelection = GetRowSelectionForNonDuplicatedProperties(obj)
        %
        % SYNTAX:
        %  vdRowSelection = obj.GetRowSelectionForNonDuplicatedProperties()
        %
        % DESCRIPTION:
        %  Returns a row vector of row indices that can be used to create
        %  the m2dFeatures, viGroupIds, etc. from the non-duplicated
        %  versions of these properities
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  vdRowSelection: A row vector of doubles containing row indices
    end
        
    
    methods (Access = protected, Abstract = false)
        
        function newObj = SelectRowsAndColumns(obj, vdRowSelection, vdColSelection)
            stSelection = struct(...
                'type', '()',...
                'subs', {{vdRowSelection, vdColSelection}});
            
            newObj = obj.subsref(stSelection);
        end
        
        function [c1chDispHeaderValues, chDispHeaderFormat] = GetHeaderForDisp(obj)
            % TODO
            
            vsFeatureNames = obj.GetFeatureNames();
            vdLinkIndices = obj.GetLinkIndexPerFeature();
            
            for dFeatureIndex=1:length(vsFeatureNames)
                vsFeatureNames(dFeatureIndex) = strcat(...
                    num2str(vdLinkIndices(dFeatureIndex)), ":",...
                    vsFeatureNames(dFeatureIndex));
            end
            
            c1chDispHeaderValues = {'Group', 'Sub Grp', vsFeatureNames};
            chDispHeaderFormat = ['%5s | %7s | ', repmat('%17s ',1,obj.GetNumberOfFeatures())];            
        end
        
        function chRowFormat = GetRowFormatForDisp(obj)
            chRowFormat = ['%1s%4i | %7i | ', repmat('%17.2f ',1,obj.GetNumberOfFeatures())];
        end
        
        function c1chRowValues = GetRowValuesForDisp(obj, dSampleIndex, viGroupIds, viSubGroupIds, m2dFeatures, vbIsDuplicatedSample)
            if vbIsDuplicatedSample(dSampleIndex)
                chCopyChar = '*';
            else
                chCopyChar = ' ';
            end
            
            c1chRowValues = {chCopyChar, viGroupIds(dSampleIndex), viSubGroupIds(dSampleIndex), m2dFeatures(dSampleIndex,:)};
        end
        
        function PrintRowsForDisp(obj)
            % TODO
            
            viGroupIds = obj.GetGroupIds();
            viSubGroupIds = obj.GetSubGroupIds();
            m2dFeatures = obj.GetFeatures();
            vbIsDuplicatedSample = obj.GetIsDuplicatedSample();
            
            chRowFormat = obj.GetRowFormatForDisp();
            
            % print line by line of Group ID/Sub Group ID/Feature Values
            for dSampleIndex=1:obj.GetNumberOfSamples()
                c1chRowValues = obj.GetRowValuesForDisp(dSampleIndex, viGroupIds, viSubGroupIds, m2dFeatures, vbIsDuplicatedSample);
                
                fprintf(chRowFormat, c1chRowValues{:});
                fprintf(newline);
            end
        end
        
        function ValidateFeatureIndexMax(obj, dFeatureIndex)
            if dFeatureIndex > obj.GetNumberOfFeatures()
                error(...
                    'FeatureValues:ValidateFeatureIndexMax:Invalid',...
                    'dFeatureIndex must be less than or equal to the number of features.');
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
                
        function MustNotContainDuplicatedSamples(obj)
            if obj.ContainsDuplicatedSamples()
                error(...
                    'FeatureValues:MustNotContainDuplicatedSamples:Invalid',...
                    'The FeatureValues object may not contain duplicated samples.');
            end
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function ValidateInputs(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, oFeatureValuesToFeatureExtractionRecordLink)
            % ValidateInputs(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, oFeatureValuesToFeatureExtractionRecordLink)
            %
            % SYNTAX:
            %  FeatureValues.ValidateInputs(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, vbFeatureIsCategorical, oFeatureValuesToFeatureExtractionRecordLink)
            %
            % DESCRIPTION:
            %  validates inputs for data that would likely be stored within
            %  a FeatureValues object.
            %
            % INPUT ARGUMENTS:
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %  viGroupIds: column vector of Group Ids for each sample. Do
            %              not to be unique
            %  viSubGroupIds: column vector of Sub Group Ids for each
            %                 sample. Need to be unique within a given Group
            %                 Id
            %  vsUserDefinedSampleStrings: a column string vector of custom
            %                              user-defined strings for each
            %                              sample
            %  vsFeatureNames: a row string array of feature names for each
            %                  column in the m2dFeatures
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            % validate each variable with sub-calls
            FeatureValues.ValidateFeaturesAndFeatureIsCategorical(m2dUnstandardizedFeatures, vbFeatureIsCategorical);
            FeatureValues.ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, m2dUnstandardizedFeatures);
            FeatureValues.ValidateUserDefinedSampleStrings(vsUserDefinedSampleStrings, m2dUnstandardizedFeatures);
            FeatureValues.ValidateFeatureNames(vsFeatureNames, m2dUnstandardizedFeatures);
            FeatureValues.ValidateFeatureValuesToFeatureExtractionRecordLink(oFeatureValuesToFeatureExtractionRecordLink);
        end
        
        function ValidateFeaturesAndFeatureIsCategorical(m2dFeatures, vbFeatureIsCategorical)
            %ValidateFeaturesAndFeatureIsCategorical(m2dFeatures, vbFeatureIsCategorical))
            %
            % SYNTAX:
            %  FeatureValues.ValidateFeatures(m2dFeatures)
            %
            % DESCRIPTION:
            %  Validates that m2dFeatures is:
            %   - A 2D matrix
            %   - Of type double
            %
            %  Throws exceptions otherwise
            %
            % INPUT ARGUMENTS:
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            
            vdDims = size(m2dFeatures);
            
            % check it is a 2d matrix
            if length(vdDims) ~= 2
                error(...
                    'FeatureValues:ValidateFeatures:InvalidDims',...
                    'The features must be a 2D matrix');
            end
            
            % check it is of type double
            if ~isa(m2dFeatures,'double')
                error(...
                    'FeatureValues:ValidateFeatures:InvalidDataType',...
                    'Features must be of type double');
            end
            
            % check for any NaNs, Inf, -Inf
            if any(isnan(m2dFeatures(:)))
                error(...
                    'FeatureValues:ValidateFeatures:InvalidNaN',...
                    'Features may not contain any NaN values.');
            end
            
            if any(isinf(m2dFeatures(:)))
                error(...
                    'FeatureValues:ValidateFeatures:InvalidInf',...
                    'Features may not contain any Inf values.');
            end
            
            % validate vbFeatureIsCategorical
            ValidationUtils.MustBeRowVector(vbFeatureIsCategorical);
            ValidationUtils.MustBeA(vbFeatureIsCategorical, 'logical');
            ValidationUtils.MustBeOfSize(vbFeatureIsCategorical, [1, size(m2dFeatures,2)]);
            
            vdCategoricalFeatureColIndices = find(vbFeatureIsCategorical);
            
            for dCategoricalFeatureIndex=1:length(vdCategoricalFeatureColIndices)
                vdFeatures = m2dFeatures(:, vdCategoricalFeatureColIndices(dCategoricalFeatureIndex));
                
                try
                    mustBeInteger(vdFeatures);
                catch e
                    error(...
                        'FeatureValues:ValidateFeaturesAndFeatureIsCategorical:CategoricalFeaturesNotIntegerValued',...
                        'Features designated to be categorical must be integer valued.');
                end
            end
            
        end
        
% % %         function ValidateFeatureExtractionRecord(oFeatureExtractionRecord)
% % %             if ~isscalar(oFeatureExtractionRecord) || ~isa(oFeatureExtractionRecord, 'FeatureExtractionRecord')
% % %                 error(...
% % %                     'FeatureValues:ValidateFeatureExtractionRecord:InvalidObject',...
% % %                     'The FeatureExtractionRecord must be single value of type FeatureExtractionRecord.');
% % %             end
% % %         end
% % %         
% % %         function ValidateSampleImageDatabaseImageIds(vdSampleImageDatabaseImageIds, m2dFeatures)
% % %             if ~isdouble(vdSampleImageDatabaseImageIds) || ~iscolumn(vdSampleImageDatabaseImageIds)
% % %                 error(...
% % %                     'FeatureValues:ValidateSampleImageDatabaseImageIds:InvalidType',...
% % %                     'SampleImageDatabaseImageIds must be given as a column vector of doubles.');
% % %             end
% % %             
% % %             if length(vdSampleImageDatabaseImageIds) ~= size(m2dFeatures,1)
% % %                 error(...
% % %                     'FeatureValues:ValidateSampleImageDatabaseImageIds:DimMismatch',...
% % %                     'The number of values in SampleImageDatabaseImageIds must match the number of rows (samples) in Features.');
% % %             end
% % %         end
% % %         
% % %         function ValidateSampleImageDatabaseRegionOfInterestNumbers(vdSampleImageDatabaseRegionOfInterestNumbers, m2dFeatures)
% % %             if ~isdouble(vdSampleImageDatabaseRegionOfInterestNumbers) || ~iscolumn(vdSampleImageDatabaseRegionOfInterestNumbers)
% % %                 error(...
% % %                     'FeatureValues:VValidateSampleImageDatabaseRegionOfInterestNumbers:InvalidType',...
% % %                     'SampleImageDatabaseRegionOfInterestNumbers must be given as a column vector of doubles.');
% % %             end
% % %             
% % %             if length(vdSampleImageDatabaseRegionOfInterestNumbers) ~= size(m2dFeatures,1)
% % %                 error(...
% % %                     'FeatureValues:ValidateSampleImageDatabaseRegionOfInterestNumbers:DimMismatch',...
% % %                     'The number of values in SampleImageDatabaseRegionOfInterestNumbers must match the number of rows (samples) in Features.');
% % %             end
% % %         end                    
                
        function ValidateFeatureValuesToFeatureExtractionRecordLink(oFeatureValuesToFeatureExtractionRecordLink)
            if ...
                    ~isscalar(oFeatureValuesToFeatureExtractionRecordLink) ||...
                    ~isa(oFeatureValuesToFeatureExtractionRecordLink, 'FeatureValuesToFeatureExtractionRecordLink')
                error(...
                    'FeatureValues:ValidateFeatureValuesToFeatureExtractionRecordLink:InvalidType',...
                    'oFeatureValuesToFeatureExtractionRecordLink must be a scalar of type FeatureValuesToFeatureExtractionRecordLink.');
            end
            
% % %             if oFeatureValuesImageValuesLink.GetNumberOfSamples() ~= size(m2dUnstandardizedFeatures, 1)
% % %                 error(...
% % %                     'FeatureValues:ValidateFeatureValuesImageVolumesLink:InvalidNumberOfSamples',...
% % %                     'The number of samples in the FeatureValuesImageValuesLink must be the same as the number of rows in m2dFeatures.'); 
% % %             end
% % %             
% % %             if oFeatureValuesImageValuesLink.GetNumberOfFeatures() ~= size(m2dUnstandardizedFeatures, 2)
% % %                 error(...
% % %                     'FeatureValues:ValidateFeatureValuesImageVolumesLink:InvalidNumberOfFeatures',...
% % %                     'The number of features in the FeatureValuesImageValuesLink must be the same as the number of columns in m2dFeatures.'); 
% % %             end
        end
        
        function [vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples] = GetProperitiesForHorzcat(varargin)
            %[vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples] = GetProperitiesForHorzcat(varargin)
            %
            % SYNTAX:
            %  [vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples] = FeatureValues.GetProperitiesForHorzcat(oFeatureValues1, oFeatureValues2, ...)
            %
            % DESCRIPTION:
            %  Validates that FeatureValue objects to be horizontally
            %  concatenated
            %   - all are non-standardized
            %   - all contain no duplicate samples
            %
            %  Throws an exception otherwise.
            %  From this is produces the standardization and duplication
            %  properities for the new FeatureValues object
            %
            % INPUT ARGUMENTS:
            %  oFeatureValues1, oFeatureValues2, ... : At least two
            %                                          FeatureValues
            %                                          objects
            %
            % OUTPUTS ARGUMENTS:
            %  vdFeatureStandardizationMeans: Empty if unstandardized, row
            %                                 vector for each column if
            %                                 standardized
            % vdFeatureStandardizationStDevs: Empty if unstandardized, row
            %                                 vector for each column if
            %                                 standardized
            % bIsStandardized: True if standardized, false otherwise
            % bContainsDuplicatedSamples: True if the FeatureValue object
            %                             does or has ever contained
            %                             duplicated values
            
            for dObjectIndex=1:nargin
                if varargin{dObjectIndex}.IsStandardized()
                    error(...
                        'FeatureValues:GetProperitiesForHorzcat:InvalidStandardization',...
                        'In order to horizontally concatenate FeatureValues objects, they must be all unstandardized.');
                end
            end            
            
            vdFeatureStandardizationMeans = varargin{1}.vdFeatureStandardizationMeans;
            vdFeatureStandardizationStDevs = varargin{1}.vdFeatureStandardizationStDevs;
            bIsStandardized = varargin{1}.bIsStandardized;
            bContainsDuplicatedSamples = varargin{1}.bContainsDuplicatedSamples;
        end
        
        
        function [vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples] = GetProperitiesForVertcat(varargin)
            %[vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples] = GetProperitiesForVertcat(varargin)
            %
            % SYNTAX:
            %  [vdFeatureStandardizationMeans, vdFeatureStandardizationStDevs, bIsStandardized, bContainsDuplicatedSamples] = FeatureValues.GetProperitiesForVertcat(oFeatureValues1, oFeatureValues2, ...)
            %
            % DESCRIPTION:
            %  Validates that FeatureValue objects to be vertically
            %  concatenated
            %   - all are non-standardized
            %   - all contain no duplicate samples
            %
            %  Throws an exception otherwise.
            %  From this is produces the standardization and duplication
            %  properities for the new FeatureValues object
            %
            % INPUT ARGUMENTS:
            %  oFeatureValues1, oFeatureValues2, ... : At least two
            %                                          FeatureValues
            %                                          objects
            %
            % OUTPUTS ARGUMENTS:
            %  vdFeatureStandardizationMeans: Empty if unstandardized, row
            %                                 vector for each column if
            %                                 standardized
            % vdFeatureStandardizationStDevs: Empty if unstandardized, row
            %                                 vector for each column if
            %                                 standardized
            % bIsStandardized: True if standardized, false otherwise
            % bContainsDuplicatedSamples: True if the FeatureValue object
            %                             does or has ever contained
            %                             duplicated values
            
            
            for dObjectIndex=1:nargin
                if varargin{dObjectIndex}.IsStandardized()
                    error(...
                        'FeatureValues:GetProperitiesForVertcat:InvalidStandardization',...
                        'In order to vertically concatenate FeatureValues objects, they must be all unstandardized.');
                elseif varargin{dObjectIndex}.ContainsDuplicatedSamples()
                    error(...
                        'FeatureValues:GetProperitiesForVertcat:InvalidDuplicatedSamples',...
                        'In order to vertically concatenate FeatureValues objects, they must all not contain any duplicated samples.');
                end
            end            
            
            vdFeatureStandardizationMeans = varargin{1}.vdFeatureStandardizationMeans;
            vdFeatureStandardizationStDevs = varargin{1}.vdFeatureStandardizationStDevs;
            bIsStandardized = varargin{1}.bIsStandardized;
            bContainsDuplicatedSamples = varargin{1}.bContainsDuplicatedSamples;
        end
    end
    
    
    methods (Access = {?ClassificationGuessResult, ?FeatureExtractionImageVolumeHandler}, Static = true)
        % Accessible to ClassificationGuessResult as well to help with some
        % validation work
        
        function ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, m2dFeatures, bOverrideDuplicatesCheck)
            %ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, m2dFeatures, bOverrideDuplicatesCheck)
            %
            % SYNTAX:
            %  FeatureValues.ValidateGroupAndSubGroupIds(viGroupIds, viSubGroupIds, m2dFeatures, bOverrideDuplicatesCheck)
            %
            % DESCRIPTION:
            %  Validates that viGroupIds is:
            %   - a column vector
            %   - of type integer
            %   - has the number of rows as m2dFeatures
            %
            %  Validates that viSubGroupIds is:
            %   - a column vector
            %   - of type integer
            %   - has the number of rows as m2dFeatures
            %
            %  Validates that with a Group ID, Sub Group IDs are unique
            %
            %  Throws exceptions otherwise
            %
            % INPUT ARGUMENTS:
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %  viGroupIds: column vector of Group Ids for each sample. Do
            %              not to be unique
            %  viSubGroupIds: column vector of Sub Group Ids for each
            %                 sample. Need to be unique within a given Group
            %                 Id
            %  bOverrideDuplicatesCheck: if set to false, repeated
            %                            group/sub-group pairs are valid
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                viGroupIds
                viSubGroupIds
                m2dFeatures
                bOverrideDuplicatesCheck (1,1) logical = false
            end
            
            dNumRows = size(m2dFeatures,1);
            
            vdGroupIdDims = size(viGroupIds);
            vdSubGroupIdDims = size(viSubGroupIds);
            
            % check viGroupIds dims and type
            
            if length(vdGroupIdDims) > 2 || vdGroupIdDims(2) ~= 1
                error(...
                    'FeatureValues:ValidateGroupAndSubGroupIds:InvalidGroupIdsDims',...
                    'The Group Ids must be a column vector.');
            end
            
            if vdGroupIdDims(1) ~= dNumRows
                error(...
                    'FeatureValues:ValidateGroupAndSubGroupIds:InvalidGroupIdsLength',...
                    'The Group Ids must be same length as the number of rows in the feature table.');
            end
            
            if ~isa(viGroupIds,'integer')
                error(...
                    'FeatureValues:ValidateGroupAndSubGroupIds:InvalidGroupIdsType',...
                    'The Group Ids must be of type integer.');
            end
            
            % check viSubGroupIds dims and type
            
            if length(vdSubGroupIdDims) > 2 || vdSubGroupIdDims(2) ~= 1
                error(...
                    'FeatureValues:ValidateGroupAndSubGroupIds:InvalidSubGroupIdsDims',...
                    'The Sub Group Ids must be a column vector.');
            end
            
            if vdSubGroupIdDims(1) ~= dNumRows
                error(...
                    'FeatureValues:ValidateGroupAndSubGroupIds:InvalidSubGroupIdsLength',...
                    'The Sub Group Ids must be same length as the number of rows in the feature table.');
            end
            
            if ~isa(viSubGroupIds,'integer')
                error(...
                    'FeatureValues:ValidateGroupAndSubGroupIds:InvalidSubGroupIdsType',...
                    'The Group Ids must be of type integer.');
            end
            
            % check that within each group, the subgroup ids are unique
            
            if ~bOverrideDuplicatesCheck
                m2dTestMatrix = [viGroupIds, viSubGroupIds];
                
                if size(m2dTestMatrix,1) ~= size(unique(m2dTestMatrix,'first','rows'),1)
                    error(...
                        'FeatureValues:ValidateGroupAndSubGroupIds:NonUniqueSubGroupIdsWithinGroup',...
                        'Non-unique Group and Sub Group ID pairs were found');
                end
            end
        end
        
        function ValidateUserDefinedSampleStrings(vsUserDefinedSampleStrings, m2dFeatures)
            %ValidateUserDefinedSampleStrings(vsUserDefinedSampleStrings, m2dFeatures)
            %
            % SYNTAX:
            %  FeatureValues.ValidateUserDefinedSampleStrings(vsUserDefinedSampleStrings, m2dFeatures)
            %
            % DESCRIPTION:
            %  Validates that vsUserDefinedSampleStrings is:
            %   - a column vector
            %   - is strings
            %   - has the same number of rows as m2dFeatures
            %
            %  Throws an exception otherwise
            %
            % INPUT ARGUMENTS:
            %  vsUserDefinedSampleStrings: a column string vector of custom
            %                              user-defined strings for each
            %                              sample
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            dNumRows = size(m2dFeatures,1);
            
            vdUserStringsDims = size(vsUserDefinedSampleStrings);
            
            % check viSubGroupNames dims and type
            
            if length(vdUserStringsDims) > 2 || vdUserStringsDims(2) ~= 1
                error(...
                    'FeatureValues:ValidateUserDefinedSampleStrings:InvalidUserDefinedSampleStringsDims',...
                    'The User Defined Sample Strings must be a column vector.');
            end
            
            if vdUserStringsDims(1) ~= dNumRows
                error(...
                    'FeatureValues:ValidateUserDefinedSampleStrings:InvalidUserDefinedSampleStringsLength',...
                    'The User Defined Sample Strings must be same length as the number of rows in the feature table.');
            end
            
            if ~isa(vsUserDefinedSampleStrings,'string')
                error(...
                    'FeatureValues:ValidateUserDefinedSampleStrings:InvalidUserDefinedSampleStringsType',...
                    'The User Defined Sample Strings must be of type string.');
            end
        end
        
        function ValidateFeatureNames(vsFeatureNames, m2dFeatures)
            % ValidateFeatureNames(vsFeatureNames, m2dFeatures)
            %
            % SYNTAX:
            %  FeatureValues.ValidateFeatureNames(vsFeatureNames, m2dFeatures)
            %
            % DESCRIPTION:
            %  Validates that c1chFeatureNames is:
            %   - a row vector
            %   - is a string vector
            %   - has the same number of columns as m2dFeatures
            %   - each feature name is unique
            %
            %  Throws an exception otherwise
            %
            % INPUT ARGUMENTS:
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %  vsFeatureNames: a row string vector of feature names for each
            %                  column in the m2dFeatures
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            dNumCols = size(m2dFeatures,2);
            
            vdFeatureNamesDims = size(vsFeatureNames);
            
            % check dims and type
            
            if length(vdFeatureNamesDims) > 2 || vdFeatureNamesDims(1) ~= 1
                error(...
                    'FeatureValues:ValidateFeatureNames:InvalidDims',...
                    'The Feature Names must be a row vector.');
            end
            
            if vdFeatureNamesDims(2) ~= dNumCols
                error(...
                    'FeatureValues:ValidateFeatureNames:InvalidLength',...
                    'The Feature Names must be same length as the number of columns in the feature table.');
            end
            
            if ~isa(vsFeatureNames,'string')
                error(...
                    'FeatureValues:ValidateFeatureNames:InvalidType',...
                    'The Feature Names must be of type string.');
            end
                                    
            if length(vsFeatureNames) ~= length(unique(vsFeatureNames))
                error(...
                    'FeatureValues:ValidateFeatureNames:NonUniqueValues',...
                    'All Feature Names must be specified as unique strings.');
            end
        end
    end
    
    methods (Access = {?Classifier, ?FeatureValues}, Static = false)
        
        function obj = PerturbeValuesByMinisculeAmount(obj, dSizeOfMinisculeAmount)
        %  dSizeOfMinisuleAmount: e.g. 1/1000, 10^-10, 0.003
        
        % Multiply by 10 because rand already returns 0.XXX values
        obj.m2dPerturbationMatrix = rand( obj.GetNumberOfSamples() , obj.GetNumberOfFeatures ) * dSizeOfMinisculeAmount * 10;
        obj.bIsPerturbed = true;
        
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

