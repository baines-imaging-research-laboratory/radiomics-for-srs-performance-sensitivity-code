classdef LabelledFeatureValues < FeatureValues
    %LabelledFeatureValues
    %
    % LabelledFeatureValues is an ABSTRACT class (cannot be instianted) that
    % describes a common functionality that all implementations of a
    % LabelledFeatureValues object should provide. It also provides validation
    % functions for the data that would likely be stored with a
    % LabelledFeatureValues object
    %
    % It INHERITS from FeatureValues, so refer to FeatureValues to see
    % functionality that is inherited from FeatureValues and should be
    % implemented within a LabelledFeatureValues implementation (or a
    % super-class that a LabelledFeatureValues implementation also inherits
    % from)
    %
    % See also FeatureValues
    
    % Primary Author: David DeVries
    % Created: Mar 8, 2019
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = private) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract = true)
        
        iPositiveLabel = GetPositiveLabel(obj)
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
        
        iNegativeLabel = GetNegativeLabel(obj)
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
        
    end
    
    methods (Access = public)
        
%         function obj = LabelledFeatureValues(s)
%             obj@FeatureValues(s);
%             
%             obj.oFeatureValuesIdentifier = s.oFeatureValuesIdentifier;
%         end
        
        function obj = LabelledFeatureValues(varargin)
            %obj = FeatureValues(varargin)
            %
            % SYNTAX:
            %  obj = LabelledFeatureValues(oLabelledFeatureValuesOnDiskIdentifier)
            %  obj = LabelledFeatureValues(oLabelledFeatureValues, vdRowSelection, vdColSelection)
            %  obj = LabelledFeatureValues(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel)
            %  obj = LabelledFeatureValues(__, __, __, __, __, __, __, __, oFeatureExtractionRecord)
            %  obj = LabelledFeatureValues(viLabels, iPositiveLabel, iNegativeLabel)
            %  obj = LabelledFeatureValuesByValue('horzcat', viLabels, iPositiveLabel, oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %  obj = LabelledFeatureValuesByValue('vertcat', viLabels, iPositiveLabel, oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdFeatureStandardizationStDevs: Double row vector (one for each column)
            
            
            bNewLabelValues = false; % boolean to track if new label values need to be set after the super-class constructor call
            bFeatureValuesGiven = false;
            
            if nargin == 1 && isa(varargin{1}, 'LabelledFeatureValuesOnDiskIdentifier')
                % For: obj = LabelledFeatureValues(oLabelledFeatureValuesOnDiskIdentifier)
                
                vararginFeatureValues = {}; % empty FeatureValues constructor call
                
            elseif nargin == 3 && isa(varargin{1}, 'LabelledFeatureValues')
                % For: obj = LabelledFeatureValues(oLabelledFeatureValues, vdRowSelection, vdColSelection)
                
                vararginFeatureValues = {}; % empty FeatureValues constructor call
                
            elseif nargin >= 5 && isa(varargin{1}, 'char') && ( strcmp(varargin{1}, 'horzcat') || strcmp(varargin{1}, 'vertcat') ) && CellArrayUtils.AreAllIndexClassesEqual(varargin(5:end)) && isa(varargin{5}, 'LabelledFeatureValues')
                % For:  obj = LabelledFeatureValuesByValue('horzcat', viLabels, iPositiveLabel, oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
                %       obj = LabelledFeatureValuesByValue('vertcat', viLabels, iPositiveLabel, oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
                
                viLabels = varargin{2};
                iPositiveLabel = varargin{3};
                iNegativeLabel = varargin{4};
                
                bNewLabelValues = true;
                
                vararginFeatureValues = {}; % empty FeatureValues constructor call
                
            elseif nargin == 8 || nargin == 9
                % For: obj = LabelledFeatureValues(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel)
                %  OR: obj = LabelledFeatureValues(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel, oFeatureExtractionRecord)
                
                viLabels = varargin{6};
                iPositiveLabel = varargin{7};
                iNegativeLabel = varargin{8};
                
                bNewLabelValues = true;
                bFeatureValuesGiven = true;
                
                vdFeatureValuesVarargin = 1:5;
                
                if nargin == 9
                    vdFeatureValuesVarargin = [vdFeatureValuesVarargin, 9];
                end
                
                vararginFeatureValues = varargin(vdFeatureValuesVarargin);
                
            elseif nargin == 3
                % For: obj = LabelledFeatureValues(viLabels, iPositiveLabel, iNegativeLabel)
                
                viLabels = varargin{1};
                iPositiveLabel = varargin{2};
                iNegativeLabel = varargin{3};
                
                bNewLabelValues = true;
                
                vararginFeatureValues = {}; % empty FeatureValues constructor call
                
            else
                error(...
                    'LabelledFeatureValues:Constructor:InvalidParameters',...
                    'See constructor documentation for usage.');
            end
            
            
            % Super-class call (may be empty)
            obj@FeatureValues(vararginFeatureValues{:});
            
            
            % if there are new label values
            if bNewLabelValues
                if bFeatureValuesGiven
                    m2dUnstandardizedFeatures = varargin{1};
                else
                    m2dUnstandardizedFeatures = obj.GetUnstandardizedFeatures();
                end
                
                LabelledFeatureValues.ValidatePositiveAndNegativeLabels(iPositiveLabel, iNegativeLabel);
                LabelledFeatureValues.ValidateLabels(viLabels, m2dUnstandardizedFeatures, iPositiveLabel, iNegativeLabel);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<
        
        
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
            
            [varargout{1:nargout}] = subsref@FeatureValues(obj, stSelection);
        end
    end
    
    
    methods (Access = public, Sealed = true)
        
        function obj = BalanceLabels(obj, NameValueArgs)
            %obj = BalanceLabels(obj)
            %
            % SYNTAX:
            %  obj = BalanceLabels(obj)
            %
            % DESCRIPTION:
            %  This function balances samples by random duplication with the contingency of maximizing 
			%	spread amongst the groups when balancing the samples. If the number of samples in the more 
			%   frequent label set (m) is more than one times the number in the less frequent set (n), the 
			%   function first duplicates the less frequent set the number of times n can be duplicated
			%   without surpassing m (R). This obtained by m modulus n. Then if there is a remainder (z), 
			%   all groups that contain the less frequent label (valid groups) are surveyed for how many 
			%   of that label the contain. These initialize the number of available samples in the group. 
			%   From that, a sample is taken from each group at random until a sample had been picked 
			%   from each group or enough samples are obtained.
			%	As this is happening, the number of "available" samples in each group is updated to 
			%   reflect that a sample had already been selected from it. This process is iterated until
			%   enough samples are obtained to reach balance between labels.			
            %
            % For writing purposes, the most succinct description of this algorithm is:
            %   "we duplicated samples of the less frequent label with a uniform distribution across
            %   groups until we achieved balance." A group is usually one patient in our experiments.   
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object with balanced labels, with duplicate samples denotes with a *.
                
            arguments
                obj
                NameValueArgs.SuppressWarnings (1,1) logical = false
            end
            
            
            % Get the needed data
            viLabels = obj.GetLabels();
            iPositiveLabel = obj.GetPositiveLabel();
            iNegativeLabel = obj.GetNegativeLabel();
                
            % Make sure two labels are provided
            if length(unique(viLabels)) < 2 % LabelledFeatureValues does a check disallowing >2 labels
                error('LabelledFeaturesValuesByValue:BalanceAcrossGroups:LessThanTwoLabels',...
                    'Less than two labels were provided for balancing, making balancing not possible.')
            end            
            
            % Figure out the number of samples with each label and their indices
            vdPositiveLabelIndices = find(viLabels == iPositiveLabel);
            dNumPositiveLabels = length(vdPositiveLabelIndices);
            
            vdNegativeLabelIndices = find(viLabels == iNegativeLabel);
            dNumNegativeLabels = length(vdNegativeLabelIndices);
                         
            % Check if labels are already balanced
            if dNumPositiveLabels == dNumNegativeLabels
                
                % Since they are already balanced, the final set does not need to be modified but
                % the user should be warned
                if ~NameValueArgs.SuppressWarnings
                    warning('LabelledFeaturesValuesByValue:BalanceAcrossGroups:AlreadyBalanced',...
                        ['The samples in this dataset already have balanced labels. The function call ',...
                        'was a do-nothing operation.']);
                end
                
                return
            end
            
            % Warning for m>>>n or n >>>m, as this data will have a lot of duplicates
            if (dNumPositiveLabels > 100*dNumNegativeLabels) || (dNumNegativeLabels > 100*dNumPositiveLabels)
                if ~NameValueArgs.SuppressWarnings
                    warning('LabelledFeaturesValuesByValue:BalanceAcrossGroups:HighlyUnbalanced',...
                        ['One of your labels has more than a 100 times the other label. This is a highly ',...
                        'unbalanced dataset.']);
                end
            end
            
            % Check which way they are not balanced
            if dNumPositiveLabels < dNumNegativeLabels
                vdLessFrequentLabelSampleIndices = vdPositiveLabelIndices;
                iLessFrequentLabel = iPositiveLabel;
                dNumLessFrequentLabelSamples = dNumPositiveLabels;
            else
                vdLessFrequentLabelSampleIndices = vdNegativeLabelIndices;                
                iLessFrequentLabel = iNegativeLabel;
                dNumLessFrequentLabelSamples = dNumNegativeLabels;
            end
            
            % Check how many of the less frequent label are needed
            dNumSamplesNeeded = abs(dNumPositiveLabels-dNumNegativeLabels);
            
            % Warning for less frequent < 1
            if length(vdLessFrequentLabelSampleIndices) == 1
                if ~NameValueArgs.SuppressWarnings
                    warning('LabelledFeaturesValuesByValue:BalanceAcrossGroups:OneSampleForLabel',...
                        ['The less frequent label in this dataset has only one sample, for balancing, '...
                        'this was duplicated ',num2str(dNumSamplesNeeded)  ,' times.']);
                end
            end
                        
            %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> numNeeded >= R*lessFreq, where R is a +ve int and equals dNumFullRepetitions
            if dNumSamplesNeeded >= dNumLessFrequentLabelSamples
               dNumFullRepetitions = floor(dNumSamplesNeeded/dNumLessFrequentLabelSamples); % i.e. finding R, could use modulus instead
               
               % copy all less frequent samples R times                
               vdDuplicatesIndicesForFullSetRepetetions =...
                   repmat(vdLessFrequentLabelSampleIndices, dNumFullRepetitions, 1);
               
               dNumSamplesNeeded = dNumSamplesNeeded - (dNumLessFrequentLabelSamples*dNumFullRepetitions);
            else
                vdDuplicatesIndicesForFullSetRepetetions = [];
            end            
            
            %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> numNeeded < lessFreq
            if dNumSamplesNeeded > 0 && dNumSamplesNeeded < dNumLessFrequentLabelSamples
                vdDuplicatesIndicesForSubsetSelection = nan(dNumSamplesNeeded,1);                
            
            [viGroupsWithLessFrequentLabel, vdNumSamplesMatchingLabel] =...
                GetGroupIdsAndNumberOfSamplesMatchingLabel(obj, iLessFrequentLabel);
            
            % Build a tracker to track how many samples are available to copy from each group
            tSelectionTracker = table(viGroupsWithLessFrequentLabel, vdNumSamplesMatchingLabel);
            tSelectionTracker.vdNumSamplesAvailable = vdNumSamplesMatchingLabel;
            tSelectionTracker.vdNumToSelect = zeros(length(viGroupsWithLessFrequentLabel),1);
                
			% Keep pulling samples until enough samples are copied
            while dNumSamplesNeeded > 0 
                dNumValidGroups = sum(tSelectionTracker.vdNumSamplesAvailable ~= 0); % n
                
				% If there are more samples needed than there are groups with samples available to copy (i.e. Valid Group),
				% start by getting a sample from each Valid Group, reduce the number of available samples for all valid groups 
				% by one. This loop will get revisited when the while loop executes again if there are still more samples needed
				% than there are Valid Group.
                if dNumSamplesNeeded >= dNumValidGroups
                    for iGroupID = 1:size(tSelectionTracker,1)
                        if tSelectionTracker.vdNumSamplesAvailable(iGroupID) ~= 0                            
                            tSelectionTracker.vdNumSamplesAvailable(iGroupID) = tSelectionTracker.vdNumSamplesAvailable(iGroupID) - 1;
                            tSelectionTracker.vdNumToSelect(iGroupID) = tSelectionTracker.vdNumToSelect(iGroupID) + 1;                            
                        
                        end %if tSampleSelectionTracker.vdNumSamplesAvailable(iRow) ~= 0                        
                    
                    end % for iRow = 1:size(tSampleSelectionTracker,1)                    
                
				% If there are less samples than there are valid groups, select one samples from different groups at random.
				% Do this by coming up with a list of numbers between 1 and the number of Valid groups, where the amount of numbers
				% equals how many samples are needed e.g. [1,4]. Then loop through all groups and get the first and fourth Valid Groups.
                else %if dNumSamplesNeeded < dNumSamplesAvailable
                    vdRandSamplesToSelect = randperm(dNumValidGroups,dNumSamplesNeeded); %randperm does gives unique values
                    dValidCount = 0;
                    
                    for iGroupID = 1:size(tSelectionTracker,1)
                        if tSelectionTracker.vdNumSamplesAvailable(iGroupID) ~= 0
                            dValidCount = dValidCount + 1; % If the group is valid, increment the counter, otherwise skip
							
                            if ~isempty(find(vdRandSamplesToSelect == dValidCount,1)) % If the valid group counter matches the randomly picked valid group position, grab a sample, otherwise, skip
                                tSelectionTracker.vdNumSamplesAvailable(iGroupID) = tSelectionTracker.vdNumSamplesAvailable(iGroupID) - 1;
                                tSelectionTracker.vdNumToSelect(iGroupID) = tSelectionTracker.vdNumToSelect(iGroupID) + 1;
                            
                            end
                        end %if tSelectionTracker.vdNumSamplesAvailable(iRow) ~= 0
                    end %for iRow = 1:size(tSelectionTracker,1)
                    
                end %if dNumSamplesNeeded >=  dNumSamplesAvailable
            dNumSamplesNeeded = dNumSamplesNeeded - dNumValidGroups;
            end % while dNumNeededSamples > 0    
            
			% Now that we know how many samples to add from each group, pick that number of samples randomly from each group
            dSamplesAddedSoFar = 1;
            for iGroupID = 1:size(tSelectionTracker,1)
                dNumSamplesToAdd = tSelectionTracker.vdNumToSelect(iGroupID);
                
                if dNumSamplesToAdd >0
                    vdDuplicatesIndicesForSubsetSelection(dSamplesAddedSoFar : dNumSamplesToAdd+dSamplesAddedSoFar-1 ) =...
                        GetRandomSampleIndicesWithinGroupIdMatchingLabel(...
                        obj,...
                        tSelectionTracker.viGroupsWithLessFrequentLabel(iGroupID),...
                        iLessFrequentLabel, dNumSamplesToAdd, vdNumSamplesMatchingLabel(iGroupID));
                    
                    dSamplesAddedSoFar = dSamplesAddedSoFar + dNumSamplesToAdd;
                end
            end %for iRow = 1:size(tSelectionTracker,1)
            
            else % if dNumberOfNeededLabels > dNumLessFrequentLabel  
                vdDuplicatesIndicesForSubsetSelection = [];
            end % if dNumberOfNeededLabels < dNumLessFrequentLabel            
            
            
            % Now actually copy the samples
            obj = AddDuplicateRowIndices(obj, ...
                [vdDuplicatesIndicesForFullSetRepetetions; vdDuplicatesIndicesForSubsetSelection]');
        end
        
        function viChangedLabels = GetChangedLabels(obj, iDesiredPositiveLabel, iDesiredNegativeLabel)
            %viChangedLabels = GetChangedLabels(obj, iDesiredPositiveLabel, iDesiredNegativeLabel)
            %
            % SYNTAX:
            %  viChangedLabels = GetChangedLabels(obj, iDesiredPositiveLabel, iDesiredNegativeLabel)
            %
            % DESCRIPTION:
            %  Provides the labels remapped with the positive labels set to
            %  "iDesiredPositiveLabel" and the negative labels set to
            %  "iDesiredNegativeLabel"
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  iDesiredPositiveLabel: The desired positive label as an
            %                         integer
            %  iDesiredNegativeLabel: The desired negative label as an
            %                         integer
            %
            % OUTPUTS ARGUMENTS:
            %  viChangeLabels: The remapped labels as column vector of
            %                  integers
            
            
            % validate input
            if ~strcmp(class(iDesiredPositiveLabel), class(iDesiredNegativeLabel)) || ~isinteger(iDesiredPositiveLabel)
                error(...
                    'LabelFeatureValues:GetChangedLabels:InvalidDataType',...
                    'The desired positive and negative labels must be of the type integer and of the same exact type.');
            end
            
            viLabels = obj.GetLabels();
            
            % create changed labels as the same integer class as the given
            % positive/negative labels. Assures support for negative labels
            % values if original labels were given as unsigned ints
            viChangedLabels = cast(zeros(size(viLabels)), class(iDesiredPositiveLabel));
            
            vbPosLabels = ( viLabels == obj.GetPositiveLabel() );
            
            viChangedLabels(vbPosLabels) = iDesiredPositiveLabel;
            viChangedLabels(~vbPosLabels) = iDesiredNegativeLabel;
        end
		
		        function [obj, vsRemovedFeatures, vbRemovedFeaturesMask] = RemoveFeaturesWithZeroVarianceWithinAnyLabel(obj)
            %[obj, vsRemovedFeatures, vbRemovedFeaturesMask] = RemoveFeaturesWithZeroVarianceWithinAnyLabel(obj)
            %
            % SYNTAX:
            %   [obj, vsRemovedFeatures, vbRemovedFeaturesMask] = obj.RemoveFeaturesWithZeroVarianceWithinAnyLabel()
            %
            % DESCRIPTION:
            %  This method removes features that have zero variance within 
            %  their values for either labels. Zero variance almost certainly
            %  means that the feature is constant within that label.
            %  The removal of such a feature is necessary for classifiers
            %  that perform a 1/variance calculation as zero variance would
            %  result in a div/0 error such as MATLAB's fitcdiscr. However, 
            %  constant features within one label are not invalid, and can 
            %  in fact be very important in separating the classes,
            %  therefore it would be wise to only use this function if
            %  absolutely necessary. A long warning explaining this is
            %  invoked on running this function  since using the function 
            %  when not absolutely necessary could lead to missing out on
            %  potentially highly useful features.
            %  
            % INPUT ARGUMENTS:
            %  obj: this class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: this class object with the features that have zero variance in either label removed
            %  vsRemovedFeatures: list of the names of the features which were removed
            %  vbRemovedFeaturesMask: mask with as many columns as the
            %    original feature values object, with true values showing
            %    which features were removed
            %
            % Author: Salma       
            
            % Warning explaining why using method this is a bad idea unless you're
            % using a classifier that breaks with zero variance within one
            % label
            warning("LabelledFeatureValues:RemoveFeaturesWithZeroVarianceWithinAnyLabel:ThisIsABadIdeaUnlessYouKnowWhatYouAreDoing",...
                "This funcion removes any features that have zero variance " +...
                "within one label. Sometimes this happens due to having min "+...
                "or max features that are only different between classes "   +...
                "due to randomness. In that case, the difference is not "    +...
                "scientifically useful, and can be rejected. However, "      +...
                "more often, zero variance within a label is scientifically "+...
                "valid and also important for classification, such as the "  +...
                "case for a categorical variable (e.g. clinical features) "  +...
                "or even a continuous variable (e.g. mean gray level is at " +...
                "value X for all non-cancer patients while it is a mix of  " +...
                "different values for cancer patients). So why use this "    +...
                "method? Sometimes a classifier assumes non-zero variance "  +...
                "because it has a calculation somewhere that divides by the "+...
                "variance leading to a div/0 error. This is the case with "  +...
                "MATLAB's fitcdisc classifier, and maybe others. Despite "   +...
                "the potential loss of useful classification information, "  +...
                "we might still want to use such a classifier, and to do so "+...
                "we need to get rid of the cause for a div/0 error, hence "  +...
                "this method.")
            
            % Initialize the removal mask. It's true for removed feature, false otherwise
            vbRemovedFeaturesMask = false(1,obj.GetNumberOfFeatures()); 
            
            % As our framework currently only works on binary
            % classification, this is the most efficient sufficient way to
            % get the labels to test the variance within. This would need
            % to change for a multiclass feature values objects.
            viLabels = [obj.GetPositiveLabel, obj.GetNegativeLabel];          
            
            for iLabel = viLabels
                % Get the rows indices for the samples corresponding to the
                % label whose variance is being checked
                viSampleIdxForLabel = (obj.GetLabels() == iLabel);
                oLabelledFeatureValuesForOneLabel = obj.SelectRowsAndColumns(viSampleIdxForLabel,':');
                
                % This warning gets triggered by the method being called
                % below, but it's irrelevant in the way the function is
                % being called here because we're calling it on a
                % subselection of the overall object. A warning covering
                % the same intention is added at the end of this method,
                % so the user will still be warned if no features at all
                % were removed. Not the error for feature removal is not
                % suppressed because if features are removed because they
                % have zero variance for one label, they'll still be
                % removed even if they're not so for the other label.
                warning('off',"FeatureValues:RemoveConstantFeatures:NoneRemoved")
                
                [~, ~, vbRemovedFeaturesMaskForOneLabel] = ...
                    RemoveFeaturesWithZeroVariance(oLabelledFeatureValuesForOneLabel);                
                 
                % OR statement makes it so that if a flag is set to true
                % (i.e. remove) for a feature for either label, it gets
                % removed for both.
                vbRemovedFeaturesMask = or(vbRemovedFeaturesMask, vbRemovedFeaturesMaskForOneLabel);
            end
            
            % First, grab the list of names of features to be removed
            vsRemovedFeatures = obj.GetFeatureNames();
            vsRemovedFeatures = vsRemovedFeatures(vbRemovedFeaturesMask);
            
            % Then remove the flagged features
            obj = obj.SelectRowsAndColumns(':',~vbRemovedFeaturesMask);
            
            % If the user called this function and it did nothing, let them know
            if sum(vbRemovedFeaturesMask) == 0
                warning("LabelledFeatureValues:RemoveFeaturesWithZeroVarianceWithinAnyLabel:NoneRemoved",...
                    "No constant features were found within either labels, therefore, none were removed.")
            % While this seems redundant due to the called function
            % triggering the error if a label causes all features to be
            % removed, that error does not capture the case where any one
            % label does not cause the removal of all features, but the
            % union of removed features from both labels causes it.
            elseif sum(~vbRemovedFeaturesMask) == 0               
                error("LabelledFeatureValues:RemoveFeaturesWithZeroVarianceWithinAnyLabel:AllRemoved",...
                    "All the features had zero variance within one or both labels and were all removed. This object now has no features.")
            end
            
        end
		
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract = true)
        
        newObj = AddDuplicateRowIndices(obj, vdDuplicateRowIndices)
        %newObj = AddDuplicateRowIndices(obj, vdDuplicateRowIndices)
        %
        % SYNTAX:
        %  newObj = AddDuplicateRowIndices(obj, vdDuplicateRowIndices)
        %
        % DESCRIPTION:
        %  Produces a new LabelledFeatureValuesByValue object with the
        %  provided rows duplicated.
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %  vdDuplicateRowIndices: Numeric row vector of row indices to
        %                         duplicate in the produced object
        %
        % OUTPUTS ARGUMENTS:
        %  newObj: Produced class object with duplicated rows
        
        [viGroupIds, vdNumSamplesMatchingLabel] = GetGroupIdsAndNumberOfSamplesMatchingLabel(obj, iLabel)
        %[viGroupIds, vdNumSamplesMatchingLabel] = GetGroupIdsAndNumberOfSamplesMatchingLabel(obj, iLabel)
        %
        % SYNTAX:
        %  [viGroupIds, vdNumSamplesMatchingLabel] = obj.GetGroupIdsAndNumberOfSamplesMatchingLabel(iLabel)
        %
        % DESCRIPTION:
        %  Returns all the Group IDs that have one or more samples that
        %  match the provided labels. If a Group ID is returned, the number
        %  of samples that match that label is also given
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %  iLabel: The label to match to. Must exactly match either the
        %          positive or negative label of the object
        %
        % OUTPUTS ARGUMENTS:
        %  viGroupIds: Column vector of Group IDs that have at least one
        %              sample with a matching label
        %  vdNumSamplesMatchingLabel: Column vector of the same size of
        %                             viGroupIds that holds the number of
        %                             samples within the group that match
        %                             the label
        
        vdSampleIndices = GetRandomSampleIndicesWithinGroupIdMatchingLabel(obj, iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
        %vdSampleIndices = GetRandomSampleIndicesWithinGroupIdMatchingLabel(obj, iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
        %
        % SYNTAX:
        %  vdSampleIndices = obj.GetRandomSampleIndicesWithinGroupIdMatchingLabel(iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
        %
        % DESCRIPTION:
        %  Randomly returns the number of sample indices (rows in the
        %  LabelledFeatureValues table) requested, such that:
        %   - the samples' Group IDs match the one given
        %   - the samples' labels match the one given
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %  iGroupId: The Group ID to select samples from
        %  iLabel: The label the samples must match
        %  dNumSamplesToSelect: The number of samples to randomly select. 
        %                       dNumSamplesToSelect < dNumSamplesInGroupMatchingLabel
        %  dNumSamplesInGroupMatchingLabel: The number of samples with the
        %                                   group that are known to have
        %                                   the matching label. 
        %                                   **NOTE**: This value could
        %                                   easily be misused. It is
        %                                   included to save computational
        %                                   overhead, since GetGroupIdsAndNumberOfSamplesMatchingLabel
        %                                   has probably been called before
        %                                   this and that value has already
        %                                   been calculated. Please
        %                                   CAREFULLY pass that value back
        %                                   in here.
        %
        % OUTPUTS ARGUMENTS:
        %  vdSampleIndices: The selected row indices of the
        %                   LabelledFeatureValues object
    end
    
    
    methods (Access = protected, Abstract = false)
        
        function [c1chDispHeaderValues, chDispHeaderFormat] = GetHeaderForDisp(obj)
            % TODO
            
            [c1chDispHeaderValues, chDispHeaderFormat] = GetHeaderForDisp@FeatureValues(obj);
            
            c1chDispHeaderValues = [{'+/- Label', 'Label'}, c1chDispHeaderValues];
            chDispHeaderFormat = ['%9s | %5s | ', chDispHeaderFormat];
        end
                
        function chRowFormat = GetRowFormatForDisp(obj)
            % TODO
            
            chRowFormat = GetRowFormatForDisp@FeatureValues(obj);
            
            chRowFormat = ['%9s | %1s%4i | ', chRowFormat];
        end
        
        function c1chRowValues = GetRowValuesForDisp(obj, dSampleIndex, viGroupIds, viSubGroupIds, m2dFeatures, vbIsDuplicatedSample, viLabels)
            % TODO
            
            c1chRowValues = GetRowValuesForDisp@FeatureValues(obj, dSampleIndex, viGroupIds, viSubGroupIds, m2dFeatures, vbIsDuplicatedSample);
            
            chCopyChar = c1chRowValues{1};
            c1chRowValues{1} = '';
            
            if dSampleIndex == 1
                chPosNegLabel = [num2str(obj.GetPositiveLabel()), ' / ' num2str(obj.GetNegativeLabel())];
            else
                chPosNegLabel = '';
            end
            
            c1chRowValues = [{chPosNegLabel, chCopyChar, viLabels(dSampleIndex)}, c1chRowValues];            
        end
        
        function PrintRowsForDisp(obj)
            % TODO
            
            viGroupIds = obj.GetGroupIds();
            viSubGroupIds = obj.GetSubGroupIds();
            m2dFeatures = obj.GetFeaturesForDisp();
            vbIsDuplicatedSample = obj.GetIsDuplicatedSample();
            viLabels = obj.GetLabels();
            
            chRowFormat = obj.GetRowFormatForDisp();
            
            % print line by line of Group ID/Sub Group ID/Feature Values
            for dSampleIndex=1:obj.GetNumberOfSamples()
                c1chRowValues = obj.GetRowValuesForDisp(dSampleIndex, viGroupIds, viSubGroupIds, m2dFeatures, vbIsDuplicatedSample, viLabels);
                
                fprintf(chRowFormat, c1chRowValues{:});
                fprintf(newline);
            end
        end
        
    end
    
    
    methods (Access = {?LabelledFeatureValues, ?LabelledFeatureValuesOnDiskIdentifier}, Abstract = true)
        
        viLabels = GetNonDuplicatedLabels(obj)
        %viLabels = GetNonDuplicatedLabels(obj)
        %
        % SYNTAX:
        %  viLabels = obj.GetNonDuplicatedLabels()
        %
        % DESCRIPTION:
        %  Returns the labels without any duplicated
        %  samples
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %
        % OUTPUTS ARGUMENTS:
        %  viLabels: Labels without duplicates            
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
    end
    
    
    methods (Access = {?ClassificationGuessResult, ?LabelledFeatureExtractionImageVolumeHandler}, Static = true)
        
        function ValidateLabels(viLabels, m2dFeatures, iPositiveLabel, iNegativeLabel)
            %ValidateLabels(viLabels, m2dFeatures)
            %
            % SYNTAX:
            %  ValidateLabels(viLabels, m2dFeatures)
            %
            % DESCRIPTION:
            %  Validates the labels:
            %   - Is a column vector
            %   - Of type integer
            %   - Has a label for each row of the feature table
            %   - Has two and only two unique values
            %
            %  Throws an exception otherwise
            %
            % INPUT ARGUMENTS:
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %  viLabels: a column vector of integers containing two and
            %            only two uniquely different labels. The number of
            %            rows must match the number of samples/rows of the
            %            feature table.
            %
            % OUTPUTS ARGUMENTS:
            %  NONE
            
            
            dNumRows = size(m2dFeatures,1);
            
            vdLabelDims = size(viLabels);
            
            % check dims and type
            
            if ~iscolumn(viLabels)
                error(...
                    'LabelledFeatureValues:ValidateLabels:InvalidDims',...
                    'The Labels must be a column vector.');
            end
            
            if vdLabelDims(1) ~= dNumRows
                error(...
                    'LabelledFeatureValues:ValidateLabels:InvalidLength',...
                    'The Labels must be same length as the number of rows in the feature table.');
            end
            
            if ~isa(viLabels,class(iPositiveLabel))
                error(...
                    'LabelledFeatureValues:ValidateLabels:InvalidType',...
                    ['The labels you input are of type ', class(viLabels),', but they must match the types of the given positive and negative labels (', class(iPositiveLabel), ').']);
            end
            
            if any( (viLabels(:) ~= iPositiveLabel) & (viLabels(:) ~= iNegativeLabel) )
                error(...
                    'LabelledFeatureValues:ValidateLabels:InvalidValue',...
                    ['The given label values must either match the positive label (', num2str(iPositiveLabel), ') or the negative label (', num2str(iNegativeLabel), ').']);
            end
        end
        
% % % % %         function ValidatePositiveLabel(iPositiveLabel, viLabels)
% % % % %             %ValidatePositiveLabel(iPositiveLabel, viLabels)
% % % % %             %
% % % % %             % SYNTAX:
% % % % %             %  ValidatePositiveLabel(iPositiveLabel, viLabels)
% % % % %             %
% % % % %             % DESCRIPTION:
% % % % %             %  Validates the positive label:
% % % % %             %   - Is a single element
% % % % %             %   - Of type integer
% % % % %             %   - At least one label matches its values
% % % % %             %
% % % % %             %  Throws an exception otherwise
% % % % %             %
% % % % %             % INPUT ARGUMENTS:
% % % % %             %  iPositiveLabel: an integer that sepecifies which label value
% % % % %             %                 within viLabels marks a "positive" sample
% % % % %             %  viLabels: a column vector of integers containing two and
% % % % %             %            only two uniquely different labels. The number of
% % % % %             %            rows must match the number of samples/rows of the
% % % % %             %            feature table.
% % % % %             %
% % % % %             % OUTPUTS ARGUMENTS:
% % % % %             %  NONE
% % % % %             
% % % % %             % check dims and type
% % % % %             
% % % % %             if numel(iPositiveLabel) ~= 1
% % % % %                 error(...
% % % % %                     'LabelledFeatureValues:ValidatePositiveLabel:InvalidDims',...
% % % % %                     'The Positive Label must be a scalar value.');
% % % % %             end
% % % % %             
% % % % %             if ~isa(iPositiveLabel,'integer')
% % % % %                 error(...
% % % % %                     'LabelledFeatureValues:ValidatePositiveLabel:InvalidType',...
% % % % %                     'The positive label must be of type integer.');
% % % % %             end
% % % % %             
% % % % %             % At least one instance of the positive label exists in
% % % % %             % viLabels
% % % % %             
% % % % %             if sum(viLabels == iPositiveLabel) == 0
% % % % %                 error(...
% % % % %                     'LabelledFeatureValues:ValidatePositiveLabel:NoLabelMatch',...
% % % % %                     ['The given positive label value of ', num2str(iPositiveLabel), ' was not found within the given label list. At least one instance of the positive label must be within the label list.']);
% % % % %             end
% % % % %         end
        
        function ValidatePositiveAndNegativeLabels(iPositiveLabel, iNegativeLabel)
            if ~isscalar(iPositiveLabel) || ~isscalar(iNegativeLabel) || ~isinteger(iPositiveLabel) || ~isinteger(iNegativeLabel) || ~strcmp(class(iPositiveLabel), class(iNegativeLabel))
                error(...
                    'LabelledFeatureValues:ValidatePositiveAndNegativeLabels:InvalidType',...
                    'Positive and negative labels must be scalar values of same type of integer.');
            end
            
            if iPositiveLabel == iNegativeLabel
                error(...
                    'LabelledFeatureValues:ValidatePositiveAndNegativeLabels:CannotBeEqual',...
                    'Positive and negative labels must not have the same value.');
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

