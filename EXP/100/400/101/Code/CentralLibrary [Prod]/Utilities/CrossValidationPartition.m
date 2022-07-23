classdef (Abstract) CrossValidationPartition
    %CrossValidationPartition
    %   This utility package contains functions to generate cross
    %   validation row indices for partitioning data.
    %
    %   CrossValidationPartition.CreateFoldedPartition
    %
    % Author: Ryan Alfano
    
    properties (Access = private, Constant = true)
    end
    
    methods (Access = public, Static = true)
        
        function stCrossValidationRowIndices = CreateFoldedPartition(oFeatureValues, dNumFolds, bRepresentativeTestingSets)
            % stCrossValidationRowIndices = CreateFoldedPartition(oFeatureValues, dNumFolds, bRepresentativeTestingSets)
            %
            % SYNTAX:
            % stCrossValidationRowIndices = CreateFoldedPartition(oFeatureValues, dNumFolds, bRepresentativeTestingSets)
            %
            % DESCRIPTION:
            %  Creates randomized folded cross validation partitions on the dataset based on group IDs and
            %  returns the row indices per fold.
            %
            % INPUT ARGUMENTS:
            %  oFeatureValues: labelled feature values by value/reference
            %  dNumFolds: number of folds to split the data into
            %  bRepresentativeTestingSets: flag that if enabled ensures
            %   that each testing set will have a positive and negative
            %   label
            %
            % OUTPUTS ARGUMENTS:
            %  stCrossValidationRowIndices: struct of vectors of integers - columns
            %   represent each individual fold
            
            % Primary Author: Ryan Alfano
            % Created: Mar 26, 2019
            
            arguments
                oFeatureValues (:,:) FeatureValues
                dNumFolds (1,1) double {mustBeInteger, mustBePositive}
                bRepresentativeTestingSets (1,1) logical
            end
            
            % Make sure the number of folds provided is not larger than the
            % max number of unique group IDs in the feature values object.
            if dNumFolds > oFeatureValues.GetNumberOfGroups()
                error(...
                        'CrossValidationPartition:TooManyFolds',...
                        'The number of folds requested is larger than the number of unique group IDs present in the feature values object.');
            end
            
            % Make sure the number of folds provided is greater than 1 as the minimum parition size is 2.
            iMinNumFolds = 2;
            if dNumFolds < iMinNumFolds
                error(...
                        'CrossValidationPartition:TooFewFolds',...
                        ['The number of folds requested is too small. The minimum number of folds allowable is ' num2str(iMinNumFolds) '.']);
            end
            
            % Error checking to ensure that the user does not get stuck in
            % an infinite loop based on the number of folds they use and
            % their dataset
            if bRepresentativeTestingSets
                viGroupIDs = oFeatureValues.GetGroupIds;
                viLabels = oFeatureValues.GetLabels;
                viUniqueGroupIDs = unique(viGroupIDs,'stable');
                dNumGroupsWithPositive = 0;
                dNumGroupsWithNegative = 0;
                
                for iUniqueGroupIDIterator = 1:size(viUniqueGroupIDs,1)
                    viCurrentGroupLabels = [];
                
                    for iGroupIDIterator = 1:size(viGroupIDs,1)
                        if viGroupIDs(iGroupIDIterator) == viUniqueGroupIDs(iUniqueGroupIDIterator)
                            viCurrentGroupLabels(end+1) = viLabels(iGroupIDIterator);
                        end
                    end
                    
                    if ismember(oFeatureValues.GetPositiveLabel,viCurrentGroupLabels)
                        dNumGroupsWithPositive = dNumGroupsWithPositive + 1;
                    end
                    
                    if ismember(oFeatureValues.GetNegativeLabel,viCurrentGroupLabels)
                        dNumGroupsWithNegative = dNumGroupsWithNegative + 1;
                    end
                end
                                
                if (dNumFolds > dNumGroupsWithPositive) || (dNumFolds > dNumGroupsWithNegative)
                    error(...
                        'CrossValidationPartition:RepresentativeTestingInfiniteLoop',...
                        ['The maxmium number of folds you may use to ensure each testing set has one positive and negative label is: ' num2str(min([dNumGroupsWithPositive,dNumGroupsWithNegative])) '.']);
                end
            end
            
            % Begin a while-loop that finishes once each training partition
            % has at least one positive and negative sample
            bValidPartitions = 0;
            
            while ~bValidPartitions
                % Fetch all unique group ids
                viGroupIDs = oFeatureValues.GetGroupIds;
                viUniqueGroupIDs = unique(viGroupIDs,'stable');

                % Randomly sample group ids into each fold (will deal with
                % remainder after)
                iNumUniqueTestGroupIDsPerFold = int16(floor(size(viUniqueGroupIDs,1) / double(dNumFolds)));
                viRemainingTestingGroupIDs = viUniqueGroupIDs;

                for iFoldIteration = 1:dNumFolds

                    % Randsample gives a set of numbers from the first input vector if the vector has >1
                    % number.However, it gives a set of numbers from 1-n, if the vector has one value: n
                    if length(viRemainingTestingGroupIDs) > 1

                        % Randomly sample the next set of testing group ids
                        viCurrentTestingIDs = randsample(viRemainingTestingGroupIDs,iNumUniqueTestGroupIDsPerFold);

                    elseif length(viRemainingTestingGroupIDs) == 1

                        viCurrentTestingIDs = viRemainingTestingGroupIDs;
                    end
                    % Remove them from our list so we don't test on the same
                    % group ID more than once!!
                    viRemainingTestingGroupIDs = setdiff(viRemainingTestingGroupIDs,viCurrentTestingIDs);

                    % Find the row indices corresponding to this testing data
                    % and store it in the struct
                    vbIsSampleInTesting = ismember(viGroupIDs,viCurrentTestingIDs);
                    viTestingRowIndices = int16(find(vbIsSampleInTesting>0));

                    stCrossValidationRowIndices(iFoldIteration).TestingIndices = viTestingRowIndices; %TODO: Pre-allocate for speed
                end

                % Add the remainder groups to the testing data
                if ~isempty(viRemainingTestingGroupIDs)
                    for iTestingFoldIteration = 1:dNumFolds
                        if ~isempty(viRemainingTestingGroupIDs)
                            % Randomly sample the next set of testing group ids
                            if size(viRemainingTestingGroupIDs,1) == 1
                                viCurrentTestingIDs = viRemainingTestingGroupIDs;
                            else
                                viCurrentTestingIDs = randsample(viRemainingTestingGroupIDs,1);                            
                            end

                            % Remove them from our list so we don't test on the same
                            % group ID more than once!!
                            viRemainingTestingGroupIDs = setdiff(viRemainingTestingGroupIDs,viCurrentTestingIDs);

                            % Find the row indices corresponding to this testing data
                            % and store it in the struct
                            vbIsSampleInTesting = ismember(viGroupIDs,viCurrentTestingIDs);
                            viTestingRowIndices = int16(find(vbIsSampleInTesting>0));

                            stCrossValidationRowIndices(iTestingFoldIteration).TestingIndices = vertcat(stCrossValidationRowIndices(iTestingFoldIteration).TestingIndices,viTestingRowIndices); %TODO: Pre-allocate for speed
                        end
                    end
                end

                % Now we assign the training indices (difference from the test
                % indices at each fold)
                for iTrainingFoldIteration = 1:dNumFolds
                    % Randomly sample the next set of testing group ids
                    viCurrentTestingIDs = unique(viGroupIDs(stCrossValidationRowIndices(iTrainingFoldIteration).TestingIndices),'stable');

                    % Find the row indices corresponding to this testing data
                    % and store the training data in the struct
                    vbIsSampleInTesting = ismember(viGroupIDs,viCurrentTestingIDs);
                    viTrainingRowIndices = int16(find(vbIsSampleInTesting<1));

                    stCrossValidationRowIndices(iTrainingFoldIteration).TrainingIndices = viTrainingRowIndices; %TODO: Pre-allocate for speed
                end
                
                % Check to see if we have a positive and negative label in
                % each training partition
                bBadFoldPartition = 0;
                
                for iFoldNumber = 1:size(stCrossValidationRowIndices,2)
                    % Create a FeatureValues object for the training set
                    oFeatureValuesTraining = oFeatureValues(stCrossValidationRowIndices(iFoldNumber).TrainingIndices);
                    
                    % Get a unique list of labels in the set
                    viUniqueLabels = unique(oFeatureValuesTraining.GetLabels());
                    
                    if size(viUniqueLabels,1) ~= 2 || ~ismember(oFeatureValues.GetPositiveLabel(),viUniqueLabels)
                        bBadFoldPartition = 1;
                    end
                    
                    % If the user enabled representative testing sets then
                    % check each testing fold
                    if bRepresentativeTestingSets
                        % Create a FeatureValues object for the testing set
                        oFeatureValuesTesting = oFeatureValues(stCrossValidationRowIndices(iFoldNumber).TestingIndices);
                        
                        % Get a unique list of labels in the set
                        viUniqueLabels = unique(oFeatureValuesTesting.GetLabels());

                        if size(viUniqueLabels,1) ~= 2 || ~ismember(oFeatureValues.GetPositiveLabel(),viUniqueLabels)
                            bBadFoldPartition = 1;
                        end
                    end
                end
                
                % If there is no bad fold partition then break the loop
                if ~bBadFoldPartition
                    bValidPartitions = 1;
                end
            end
        end
    end
    
    methods (Access = private, Static = true)
        
    end
end

