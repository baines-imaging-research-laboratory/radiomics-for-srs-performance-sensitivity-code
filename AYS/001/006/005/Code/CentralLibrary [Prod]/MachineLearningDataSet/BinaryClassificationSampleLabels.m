classdef BinaryClassificationSampleLabels < SampleLabels
    %BinaryClassificationSampleLabels
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        viLabels (:,1) {ValidationUtils.MustBeIntegerClass} = int8([])
        
        iPositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0)
        iNegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0)
    end
    
    properties (Access = private, Constant = true)
        dHighlyUnbalancedLabelsThreshold (1,1) double = 100
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = BinaryClassificationSampleLabels(viLabels, iPositiveLabel, iNegativeLabel, sLabelSource)
            %obj = BinaryClassificationSampleLabels(viLabels, iPositiveLabel, iNegativeLabel, sLabelSource)
            %
            % SYNTAX:
            %  obj = BinaryClassificationSampleLabels(viLabels, iPositiveLabel, iNegativeLabel, sLabelSource)
            %
            % DESCRIPTION:
            %  Constructor for BinaryClassificationSampleLabels
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                viLabels (:,1) {ValidationUtils.MustBeIntegerClass}
                iPositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeSameClass(iPositiveLabel, viLabels)}
                iNegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeSameClass(iNegativeLabel, viLabels), ValidationUtils.MustBeNotEqual(iPositiveLabel, iNegativeLabel)}
                sLabelSource (1,1) string = ""
            end
            
            BinaryClassificationSampleLabels.MustBeValidLabels(viLabels, iPositiveLabel, iNegativeLabel);
            
            % super-class constructor
            obj@SampleLabels(viLabels, sLabelSource)
            
            % set properities
            obj.viLabels = viLabels;
            obj.iPositiveLabel = iPositiveLabel;
            obj.iNegativeLabel = iNegativeLabel;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeEqual(obj1, obj2)
            arguments
                obj1 (:,1) BinaryClassificationSampleLabels
                obj2 (:,1) BinaryClassificationSampleLabels {ValidationUtils.MustBeSameSize(obj1, obj2)}
            end
            
            if ...
                    any(obj1.viLabels ~= obj2.viLabels) ||...
                    obj1.iPositiveLabel ~= obj2.iPositiveLabel ||...
                    obj1.iNegativeLabel ~= obj2.iNegativeLabel
                error(...
                    'BinaryClassificationSampleLabels:MustBeEqual:Invalid',...
                    'BinaryClassificationSampleLabels are not equal.');
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
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
            
            arguments
                obj (:,1) BinaryClassificationSampleLabels
                iDesiredPositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass}
                iDesiredNegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeSameClass(iDesiredNegativeLabel, iDesiredPositiveLabel), ValidationUtils.MustBeNotEqual(iDesiredPositiveLabel, iDesiredNegativeLabel)}
            end
            
            viLabels = obj.GetLabels();
            
            % create changed labels as the same integer class as the given
            % positive/negative labels. Assures support for negative labels
            % values if original labels were given as unsigned ints
            viChangedLabels = zeros(size(viLabels), class(iDesiredPositiveLabel));
            
            vbPosLabels = ( viLabels == obj.GetPositiveLabel() );
            
            viChangedLabels(vbPosLabels) = iDesiredPositiveLabel;
            viChangedLabels(~vbPosLabels) = iDesiredNegativeLabel;
        end
        
        function m2dOneHotEncodedLabels = GetOneHotEncodedLabels(obj)
            %m2dOneHotEncodedLabels = GetOneHotEncodedLabels(obj)
            %
            % SYNTAX:
            %  m2dOneHotEncodedLabels = GetOneHotEncodedLabels(obj)
            %
            % DESCRIPTION:
            %  Provides the labels as a "one-hot encoded" matrix, where
            %  each row is one sample's label express as [1,0] for a
            %  positive label, and [0,1] for a negative label
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dOneHotEncodedLabels: TODO
            
            m2dOneHotEncodedLabels = zeros(obj.GetNumberOfSamples(),2);
            
            m2dOneHotEncodedLabels(obj.viLabels == obj.iPositiveLabel, 1) = 1;
            m2dOneHotEncodedLabels(obj.viLabels == obj.iNegativeLabel, 2) = 1;
        end
        
        function oRecord = GetRecordForModel(obj)
            %oRecord = GetRecordForModel(obj)
            %
            % SYNTAX:
            %  oRecord = obj.GetRecordForModel()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: BinaryClassificationSampleLabels object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oRecord = BinaryClassificationSampleLabelsRecordForModel(obj);
        end
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function obj = vertcat(varargin)
            c1oSampleLabels = varargin;
            
            dNumSampleLabels = length(c1oSampleLabels);
            vdNumSamplesPerSampleLabelsObj = zeros(1,dNumSampleLabels);
            
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                ValidationUtils.MustBeA(oSampleLabelsObj, 'BinaryClassificationSampleLabels');
                
                % get number of samples
                vdNumSamplesPerSampleLabelsObj(dObjIndex) = oSampleLabelsObj.GetNumberOfSamples();
            end
            
            dTotalNumSamples = sum(vdNumSamplesPerSampleLabelsObj);
            
            oMasterSampleLabels = oSampleLabelsObj;
            chMasterLabelsClass = class(oMasterSampleLabels.GetLabels());
            
            viLabels = zeros(dTotalNumSamples,1,chMasterLabelsClass);
            dInsertIndex = 1;
            
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                BinaryClassificationSampleLabels.MustBeValidForVertcat(oMasterSampleLabels, oSampleLabelsObj);
                
                % insert labels
                dNumToInsert = vdNumSamplesPerSampleLabelsObj(dObjIndex);
                
                viLabels(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleLabelsObj.GetLabels();
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
            
            % create new obj
            obj = BinaryClassificationSampleLabels(viLabels, oMasterSampleLabels.iPositiveLabel, oMasterSampleLabels.iNegativeLabel);
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: If is was a selection, a BinaryClassificationSampleLabels object
            %             will be returned. If it was a obj.FnName() call,
            %             anything could be returned
            
            
            % call super-class method that has this call figured out
            switch stSelection(1).type
                case '.' % allow built in function to run (member methods, etc.)
                    [varargout{1:nargout}] = builtin('subsref',obj, stSelection);
                case '()'
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
                    
                    % if it was a selection, don't want to store the whole matrix
                    % as MatrixContainer does, since this is a waste of memory
                    % if we're passing by value
                    % We'll take the choosen selection, and apply it behind the
                    % scenes
                    viLabels = obj.viLabels(varargout{1}.GetRowSelection());
                    
                    varargout{1} = BinaryClassificationSampleLabels(viLabels, obj.iPositiveLabel, obj.iNegativeLabel);
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> PRINT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function PrintHeaders(obj)
            fprintf(' %9s | %5s |', '+/- Class', 'Class');
        end
        
        function PrintRowForSample(obj, dSampleIndex)
            if dSampleIndex == 1
                chLabelDefStr = [num2str(obj.iPositiveLabel), ' / ', num2str(obj.iNegativeLabel)];
            else
                chLabelDefStr = '';
            end
            
            fprintf(' %9s | %5i |', chLabelDefStr, obj.viLabels(dSampleIndex));
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function c1xVararginForLabels = GetVarNamesAndValuesForExportToPython(obj)
            c1xVararginForLabels = {...
                'chLabelType', 'BinaryClassification',...
                'viLabels', obj.viLabels,...
                'iPositiveLabel', obj.iPositiveLabel,...
                'iNegativeLabel', obj.iNegativeLabel};
        end
        
        function vdRowSelectionIndices = GetRowSelectionIndicesToBalanceLabels(obj, oSampleIds, NameValueArgs)
            %obj = BalanceLabels(obj, oSampleIds, NameValueArgs)
            %
            % SYNTAX:
            %  vdRowSelectionIndices = BalanceLabels(obj, oSampleIds)
            %  vdRowSelectionIndices = BalanceLabels(obj, oSampleIds, 'SuppressWarnings', bSuppressWarnings)
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
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  vdRowSelectionIndices: Row selection indices to produce an object with balanced labels, with duplicate samples denotes with a *.
            
            arguments
                obj (:,1) BinaryClassificationSampleLabels
                oSampleIds (:,1) SampleIds {ValidationUtils.MustBeSameSize(obj, oSampleIds)}
                NameValueArgs.SuppressWarnings (1,1) logical = false
            end
            
            % Get the needed data
            viLabels = obj.viLabels;
            iPositiveLabel = obj.iPositiveLabel;
            iNegativeLabel = obj.iNegativeLabel;
            
            % Figure out the number of samples with each label and their indices
            vdPositiveLabelIndices = find(viLabels == iPositiveLabel);
            dNumPositiveLabels = length(vdPositiveLabelIndices);
            
            vdNegativeLabelIndices = find(viLabels == iNegativeLabel);
            dNumNegativeLabels = length(vdNegativeLabelIndices);
            
            vdRowSelectionIndices = 1:obj.GetNumberOfSamples();
            
            % Check if labels are already balanced
            if dNumPositiveLabels == dNumNegativeLabels
                
                % Since they are already balanced, the final set does not need to be modified but
                % the user should be warned
                if ~NameValueArgs.SuppressWarnings
                    warning('BinaryClassificationSampleLabels:GetRowSelectionIndicesToBalanceLabels:AlreadyBalanced',...
                        ['The samples in this dataset already have balanced labels. The function call ',...
                        'was a do-nothing operation.']);
                end
                
                return
            end
            
            % Warning for m>>>n or n >>>m, as this data will have a lot of duplicates
            if ....
                    (dNumPositiveLabels > BinaryClassificationSampleLabels.dHighlyUnbalancedLabelsThreshold*dNumNegativeLabels) ||...
                    (dNumNegativeLabels > BinaryClassificationSampleLabels.dHighlyUnbalancedLabelsThreshold*dNumPositiveLabels)
                if ~NameValueArgs.SuppressWarnings
                    warning('BinaryClassificationSampleLabels:GetRowSelectionIndicesToBalanceLabels:HighlyUnbalanced',...
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
                    warning('BinaryClassificationSampleLabels:GetRowSelectionIndicesToBalanceLabels:OneSampleForLabel',...
                        ['The less frequent label in this dataset has only one sample, for balancing, '...
                        'this was duplicated ',num2str(dNumSamplesNeeded)  ,' times.']);
                end
            end
            
            %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> numNeeded >= R*lessFreq, where R is a +ve int and equals dNumFullRepetitions
            if dNumSamplesNeeded >= dNumLessFrequentLabelSamples
                dNumFullRepetitions = floor(dNumSamplesNeeded/dNumLessFrequentLabelSamples); % i.e. finding R, could use modulus instead
                
                % copy all less frequent samples R times
                vdDuplicatesIndicesForFullSetRepetitions =...
                    repmat(vdLessFrequentLabelSampleIndices, dNumFullRepetitions, 1);
                
                dNumSamplesNeeded = dNumSamplesNeeded - (dNumLessFrequentLabelSamples*dNumFullRepetitions);
            else
                vdDuplicatesIndicesForFullSetRepetitions = [];
            end
            
            %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> numNeeded < lessFreq
            if dNumSamplesNeeded > 0 && dNumSamplesNeeded < dNumLessFrequentLabelSamples
                vdDuplicatesIndicesForSubsetSelection = nan(dNumSamplesNeeded,1);
                
                [viGroupsWithLessFrequentLabel, vdNumSamplesMatchingLabel] =...
                    obj.GetGroupIdsAndNumberOfSamplesMatchingLabel(oSampleIds, iLessFrequentLabel);
                
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
                            obj, oSampleIds,...
                            tSelectionTracker.viGroupsWithLessFrequentLabel(iGroupID),...
                            iLessFrequentLabel, dNumSamplesToAdd, vdNumSamplesMatchingLabel(iGroupID));
                        
                        dSamplesAddedSoFar = dSamplesAddedSoFar + dNumSamplesToAdd;
                    end
                end %for iRow = 1:size(tSelectionTracker,1)
                
            else % if dNumberOfNeededLabels > dNumLessFrequentLabel
                vdDuplicatesIndicesForSubsetSelection = [];
            end % if dNumberOfNeededLabels < dNumLessFrequentLabel
            
            % Get final indices for the duplications
            vdRowSelectionIndices = [...
                vdRowSelectionIndices,...
                vdDuplicatesIndicesForFullSetRepetitions,...
                vdDuplicatesIndicesForSubsetSelection];
        end
    end
    
    
    methods (Access = public, Static = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected, Static = false)
        
        function newObj = CopyContainedMatrices(obj, newObj)
            %newObj = CopyContainedMatrices(obj, newObj)
            %
            % SYNTAX:
            %  newObj = CopyContainedMatrices(obj, newObj)
            %
            % DESCRIPTION:
            %  Copies any matrix contained in "obj" over to "newObj". If the
            %  contained matrices are handle objects they should be FULLY
            %  COPIED
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  newObj: Copied class object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copied class object
            
            newObj = obj;
        end
    end
    
    
    methods (Access = protected, Static = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)
        
        function [viGroupIdsMatchingLabel, vdNumSamplesMatchingLabel] = GetGroupIdsAndNumberOfSamplesMatchingLabel(obj, oSampleIds, iLabel)
            %[viGroupIds, vdNumSamplesMatchingLabel] = GetGroupIdsAndNumberOfSamplesMatchingLabel(obj, oSampleIds, iLabel)
            %
            % SYNTAX:
            %  [viGroupIds, vdNumSamplesMatchingLabel] = obj.GetGroupIdsAndNumberOfSamplesMatchingLabel(oSampleIds, iLabel)
            %
            % DESCRIPTION:
            %  Returns all the Group IDs that have one or more samples that
            %  match the provided labels. If a Group ID is returned, the number
            %  of samples that match that label is also given
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  oSampleIds: SampleIds object
            %  iLabel: The label to match to. Must exactly match either the
            %          positive or negative label of the object
            %
            % OUTPUTS ARGUMENTS:
            %  viGroupIdsMatchingLabel: Column vector of Group IDs that have at least one
            %                           sample with a matching label
            %  vdNumSamplesMatchingLabel: Column vector of the same size of
            %                             viGroupIds that holds the number of
            %                             samples within the group that match
            %                             the label
            
            arguments
                obj (:,1) BinaryClassificationSampleLabels
                oSampleIds (:,1) SampleIds
                iLabel (1,1) {ValidationUtils.MustBeIntegerClass(iLabel)}
            end
            
            
            viGroupIds = oSampleIds.GetGroupIds();
            dNumGroups = oSampleIds.GetNumberOfGroups();
            
            viUniqueGroupIds = unique(viGroupIds);
            
            vdNumSamplesMatchingLabel = zeros(dNumGroups,1);
            
            for dSampleIndex=1:obj.GetNumberOfSamples()
                if obj.viLabels(dSampleIndex) == iLabel
                    iGroupId = viGroupIds(dSampleIndex);
                    
                    dGroupIdIndex = find(viUniqueGroupIds == iGroupId);
                    
                    vdNumSamplesMatchingLabel(dGroupIdIndex) = vdNumSamplesMatchingLabel(dGroupIdIndex) + 1;
                end
            end
            
            viGroupIdsMatchingLabel = viUniqueGroupIds(vdNumSamplesMatchingLabel ~= 0);
            vdNumSamplesMatchingLabel = vdNumSamplesMatchingLabel(vdNumSamplesMatchingLabel ~= 0);
        end
        
        function vdSampleIndices = GetRandomSampleIndicesWithinGroupIdMatchingLabel(obj, oSampleIds, iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
            %vdSampleIndices = GetRandomSampleIndicesWithinGroupIdMatchingLabel(obj, oSampleIds, iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
            %
            % SYNTAX:
            %  vdSampleIndices = obj.GetRandomSampleIndicesWithinGroupIdMatchingLabel(oSampleIds, iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
            %
            % DESCRIPTION:
            %  Randomly returns the number of sample indices (rows in the
            %  LabelledFeatureValues table) requested, such that:
            %   - the samples' Group IDs match the one given
            %   - the samples' labels match the one given
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  oSampleIds: SampleIds object
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
            
            arguments
                obj (:,1) BinaryClassificationSampleLabels
                oSampleIds (:,1) SampleIds
                iGroupId (1,1) {ValidationUtils.MustBeIntegerClass(iGroupId)}
                iLabel (1,1) {ValidationUtils.MustBeIntegerClass(iLabel)}
                dNumSamplesToSelect (1,1) double {mustBeInteger, mustBePositive}
                dNumSamplesInGroupMatchingLabel (1,1) double {mustBeInteger, mustBePositive}
            end
            
            if dNumSamplesToSelect > dNumSamplesInGroupMatchingLabel
                error(...
                    'BinaryClassificationSampleLabels:GetRandomSampleIndicesWithinGroupIdMatchingLabel:InvalidNumberOfSamplesToSelect',...
                    'The number of samples to select must be less than the number of samples in the group and matching the label.');
            end
            
            viGroupIds = oSampleIds.GetGroupIds();
            viLabels = obj.GetLabels();
            
            vdSampleIndices = zeros(1,dNumSamplesToSelect);
            
            vdMatchingSamplesToSelect = randperm(dNumSamplesInGroupMatchingLabel, dNumSamplesToSelect);
            
            dNumMatchingSamples = 0;
            dNumSamplesSelected = 0;
            dSampleIndex = 1;
            
            while dNumSamplesSelected < dNumSamplesToSelect
                if viGroupIds(dSampleIndex) == iGroupId && viLabels(dSampleIndex) == iLabel
                    % e.g. we've found the nth sample with the same Group ID and label
                    dNumMatchingSamples = dNumMatchingSamples + 1;
                    
                    % check if this is one for us to select
                    if any(vdMatchingSamplesToSelect == dNumMatchingSamples)
                        dNumSamplesSelected = dNumSamplesSelected + 1;
                        vdSampleIndices(dNumSamplesSelected) = dSampleIndex;
                    end
                end
                
                dSampleIndex = dSampleIndex + 1;
            end
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function MustBeValidLabels(viLabels, iPositiveLabel, iNegativeLabel)
            if any( (viLabels(:) ~= iPositiveLabel) & (viLabels(:) ~= iNegativeLabel) )
                error(...
                    'BinaryClassificationSampleLabels:MustBeValidLabels:Invalid',...
                    ['The given label values must either match the positive label (', num2str(iPositiveLabel), ') or the negative label (', num2str(iNegativeLabel), ').']);
            end
        end
        
        function MustBeValidForVertcat(obj1, obj2)
            if...
                    ~strcmp(class(obj1.viLabels), class(obj2.viLabels)) ||...
                    obj1.iPositiveLabel ~= obj2.iPositiveLabel ||...
                    obj1.iNegativeLabel ~= obj2.iNegativeLabel
                error(...
                    'BinaryClassificationSampleLabels:MustBeValidForVertcat:Invalid',...
                    'For two BinaryClassificationSampleLabels objects to be concatenated, their labels must be of the same class and the positive/negative label definitions must be identical.');
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

