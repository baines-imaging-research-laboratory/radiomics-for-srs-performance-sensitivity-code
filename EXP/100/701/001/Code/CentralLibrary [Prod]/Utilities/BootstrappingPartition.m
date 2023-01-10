classdef (Abstract) BootstrappingPartition
    %BootstrappingPartition
    %   TODO
    
    % Author: David Devries
    
    properties (Access = private, Constant = true)
    end
    
    methods (Access = public, Static = true)
        
        function vstBootstrappedPartitionRowIndices = CreatePartitions(oFeatureValues, dNumberOfRepetitions, dNumberOfGroupsInTrainingPartition, dNumberOfGroupsInTestingPartition, bAtLeastOneOfEachLabelPerPartition)
            % vstBootstrappedPartitionRowIndices = CreatePartitions(oFeatureValues, dNumberOfRepetitions, dNumberOfGroupsInTrainingPartition, dNumberOfGroupsInTestingPartition, bAtLeastOneOfEachLabelPerPartition)
            %
            % SYNTAX:
            %  vstBootstrappedPartitionRowIndices = CreatePartitions(oFeatureValues, dNumberOfRepetitions, dNumberOfGroupsInTrainingPartition)
            %  vstBootstrappedPartitionRowIndices = CreatePartitions(__, __, __, dNumberOfGroupsInTestingPartition)
            %  vstBootstrappedPartitionRowIndices = CreatePartitions(__, __, __, __, bAtLeastOneOfEachLabelPerPartition)
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
                oFeatureValues (:,:) LabelledFeatureValues
                dNumberOfRepetitions (1,1) double {mustBeInteger, mustBePositive}
                dNumberOfGroupsInTrainingPartition (1,1) double {mustBeInteger, mustBePositive}
                dNumberOfGroupsInTestingPartition double {ValidationUtils.MustBeEmptyOrScalar} = []
                bAtLeastOneOfEachLabelPerPartition (1,1) logical = false
            end
            
            viLabels = oFeatureValues.GetLabels();
            iPosLabel = oFeatureValues.GetPositiveLabel();
            iNegLabel = oFeatureValues.GetNegativeLabel();
            
            vdGroupIds = oFeatureValues.GetGroupIds();
            vdUniqueGroupIds = unique(vdGroupIds);
            
            dNumUniqueGroupIds = oFeatureValues.GetNumberOfGroups();
            
            vdNumberOfSamplesPerGroup = zeros(1, dNumUniqueGroupIds);
            
            for dGroupIndex=1:dNumUniqueGroupIds
                vdNumberOfSamplesPerGroup(dGroupIndex) = sum(vdGroupIds == vdUniqueGroupIds(dGroupIndex));
            end
                        
            if isscalar(dNumberOfGroupsInTestingPartition)
                mustBePositive(dNumberOfGroupsInTestingPartition);
                mustBeInteger(dNumberOfGroupsInTrainingPartition);         
                
                if dNumberOfGroupsInTestingPartition >= dNumUniqueGroupIds
                    error(...
                        'BootstrappingPartition:CreatePartitions:InvalidNumberOfGroupsInTestingPartitions',...
                        'Since samples with the same Group ID cannot appear in both a testing and training set, the specified number of groups in the testing partition must be strictly less than the number of unique Group IDs in the feature values object, to allow for at least one Group ID to be present in training set.');
                end
            end
            
            c1stBootstrappedPartitionRowIndices = cell(dNumberOfRepetitions,1); 
            
            dNumberOfRepsCreated = 0;
            
            while dNumberOfRepsCreated < dNumberOfRepetitions
                vdRandomGroupIndices = randi(dNumUniqueGroupIds, 1, dNumberOfGroupsInTrainingPartition);
                
                vdTrainGroupIds = vdUniqueGroupIds(vdRandomGroupIndices);
                
                % count-up how many samples there will be in the training
                % partition
                dNumberOfSamples = 0;
                
                for dGroupIdIndex=1:dNumberOfGroupsInTrainingPartition
                    dNumberOfSamples = dNumberOfSamples + vdNumberOfSamplesPerGroup(vdUniqueGroupIds == vdTrainGroupIds(dGroupIdIndex));
                end
                
                % make vector of sample indices of training partition
                vdTrainingIndices = zeros(1,dNumberOfSamples);
                
                dInsertIndex = 1;
                
                for dGroupIndex=1:dNumberOfGroupsInTrainingPartition
                    dGroupId = vdTrainGroupIds(dGroupIndex);
                    
                    vdSamplesIndicesForGroupId = find(vdGroupIds == dGroupId);
                    dNumToInsert = length(vdSamplesIndicesForGroupId);
                    
                    vdTrainingIndices(dInsertIndex : dInsertIndex + dNumToInsert - 1) = vdSamplesIndicesForGroupId;
                    
                    dInsertIndex = dInsertIndex + dNumToInsert;
                end
                
                % make vector of sample indices for testing set
                if isempty(dNumberOfGroupsInTestingPartition)
                    % take all group IDs that WERE NOT selected by the
                    % training partition and place them in the testing
                    % partition, each once
                    % If the training partition used all the groups in the
                    % feature values object, it's an invalid partition, so
                    % this iteration will not create a valid rep.
                    
                    vdTestingGroupIds = setdiff(vdGroupIds, vdTrainGroupIds);
                else
                    % Randomly select the number of requested groups for
                    % the testing set from the groups that were not
                    % selected for the training set.
                    % If the number of requested groups for the testing set
                    % is not possible because of the number of unique
                    % groups in the training set, it's an invalid
                    % partition, so this iteration will not creat a valid
                    % rep.
                    
                    vdTestingGroupIds = setdiff(vdGroupIds, vdTrainGroupIds);
                    
                    if length(vdTestingGroupIds) < dNumberOfGroupsInTestingPartition
                        vdTestingGroupIds = []; % invalid partition
                    elseif length(vdTestingGroupIds) == dNumberOfGroupsInTestingPartition
                        vdTestingGroupIds = vdTestingGroupIds; % no random selection needed, use them all
                    else
                        vdSelectionIndices = randperm(length(vdTestingGroupIds));
                        vdSelectionIndices = vdSelectionIndices(1:dNumberOfGroupsInTestingPartition);
                        
                        vdTestingGroupIds = vdTestingGroupIds(vdSelectionIndices);
                    end                        
                end
                    
                if ~isempty(vdTestingGroupIds)
                    % count-up how many samples there will be in the
                    % testing partition
                    dNumberOfSamples = 0;
                    
                    for dGroupIdIndex=1:length(vdTestingGroupIds)
                        dNumberOfSamples = dNumberOfSamples + vdNumberOfSamplesPerGroup(vdUniqueGroupIds == vdTestingGroupIds(dGroupIdIndex));
                    end
                    
                    % make vector of sample indices for testing set
                    vdTestingIndices = zeros(1,dNumberOfSamples);
                    
                    dInsertIndex = 1;
                
                    for dGroupIndex=1:length(vdTestingGroupIds)
                        dGroupId = vdTestingGroupIds(dGroupIndex);
                        
                        vdSamplesIndicesForGroupId = find(vdGroupIds == dGroupId);
                        dNumToInsert = length(vdSamplesIndicesForGroupId);
                        
                        vdTestingIndices(dInsertIndex : dInsertIndex + dNumToInsert - 1) = vdSamplesIndicesForGroupId;
                        
                        dInsertIndex = dInsertIndex + dNumToInsert;
                    end
                    
                    bValidPartition = true;
                    
                    if bAtLeastOneOfEachLabelPerPartition
                        viTrainingLabels = viLabels(vdTrainingIndices);
                        viTestingLabels = viLabels(vdTestingIndices);
                        
                        bTrainHasPos = any(viTrainingLabels == iPosLabel);
                        bTrainHasNeg = any(viTrainingLabels == iNegLabel);
                        
                        bTestHasPos = any(viTestingLabels == iPosLabel);
                        bTestHasNeg = any(viTestingLabels == iNegLabel);
                        
                        if ~(bTrainHasPos && bTrainHasNeg && bTestHasPos && bTestHasNeg)
                            bValidPartition = false; % needs to have one of each label 
                        end
                    end
                    
                    
                    % add to cell array of successful partitions
                    if bValidPartition                    
                        dNumberOfRepsCreated = dNumberOfRepsCreated + 1;
                    
                        c1stBootstrappedPartitionRowIndices{dNumberOfRepsCreated} = struct('TrainingIndices', vdTrainingIndices, 'TestingIndices', vdTestingIndices);
                    end
                end
            end
            
            vstBootstrappedPartitionRowIndices = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1stBootstrappedPartitionRowIndices);
        end
    end
    
    methods (Access = private, Static = true)
        
    end
end

