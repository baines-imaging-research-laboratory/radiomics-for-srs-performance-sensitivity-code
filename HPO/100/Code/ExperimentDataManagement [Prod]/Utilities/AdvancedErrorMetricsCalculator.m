classdef (Abstract) AdvancedErrorMetricsCalculator
    
    
    methods (Access = public, Static = true)
        
        function [dAUC_1_1, dStDev] = LeaveOnePairOutBootstrapAUCAndStDev(vstBootstrapPartitions, c1oGuessResultPerBootstrapPartition)
            
            [dn_1, dn_2,  vdClass1SampleIndices, vdClass2SampleIndices, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, c1vdPositiveConfidencesPerBootstrapPartition] = ProcessInputs(vstBootstrapPartitions, c1oGuessResultPerBootstrapPartition);
            
            
            % *** CALCULATE AUC ***
            bClass1IsNegativeLabel = true;
            dAUC_1_1 = AUC_1_1(vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, bClass1IsNegativeLabel);
            
            
            
            % *** CALCULATE ST DEV ***
            
            % TERM 1
            
            
            bClass1IsNegativeLabel = true;
            vdUTerms = CalculateUTerms(vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, dAUC_1_1, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, bClass1IsNegativeLabel);
            dTerm1Sum = sum(vdUTerms.^2);
            
            dTerm1 = dTerm1Sum ./ (dn_1 ^2);
            
            
            % TERM 2
            bClass1IsNegativeLabel = false;
            vdUTerms = CalculateUTerms(vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, dAUC_1_1, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, bClass1IsNegativeLabel);
            dTerm2Sum = sum(vdUTerms.^2);
            
            dTerm2 = dTerm2Sum ./ (dn_2 ^2);
            
            
            % FINAL
            dStDev = sqrt(dTerm1 + dTerm2);
        end
        
        function dz = CalculateDifferenceTestStatistic(vstBootstrapPartitions1, c1oGuessResultPerBootstrapPartition1, vstBootstrapPartitions2, c1oGuessResultPerBootstrapPartition2)
            [dn_1_1, dn_2_1,  vdClass1SampleIndices1, vdClass2SampleIndices1, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition1, c1vdPositiveConfidencesPerBootstrapPartition1] = ProcessInputs(vstBootstrapPartitions1, c1oGuessResultPerBootstrapPartition1);
            [dn_1_2, dn_2_2,  vdClass1SampleIndices2, vdClass2SampleIndices2, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition2, c1vdPositiveConfidencesPerBootstrapPartition2] = ProcessInputs(vstBootstrapPartitions2, c1oGuessResultPerBootstrapPartition2);
            
            if dn_1_1 ~= dn_1_2 || dn_2_1 ~= dn_2_2 || ~all(vdClass1SampleIndices1 == vdClass1SampleIndices2) || ~all(vdClass2SampleIndices1 == vdClass2SampleIndices2)
                error(...
                    'AdvancedErrorMetricsCalculator:CalculateDifferenceTestStatistic:SamplesMismatch',...
                    'The two results being compared must have the same samples.');
            else
                dn_1 = dn_1_1;
                dn_2 = dn_2_1;
                
                vdClass1SampleIndices = vdClass1SampleIndices1;
                vdClass2SampleIndices = vdClass2SampleIndices1;
            end
            
            
            % Calculate AUC Difference
            bClass1IsNegativeLabel = true;
            
            dAUC1 = AUC_1_1(vstBootstrapPartitions1, c1vdPositiveConfidencesPerBootstrapPartition1, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition1, bClass1IsNegativeLabel);
            dAUC2 = AUC_1_1(vstBootstrapPartitions2, c1vdPositiveConfidencesPerBootstrapPartition2, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition2, bClass1IsNegativeLabel);
            
            dDelta = dAUC1-dAUC2;
            
            
            % Calculate variance delta
            bClass1IsNegativeLabel = true;
            
            vdUTerms1 = CalculateUTerms(vstBootstrapPartitions1, c1vdPositiveConfidencesPerBootstrapPartition1, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, dAUC1, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition1, bClass1IsNegativeLabel);
            vdUTerms2 = CalculateUTerms(vstBootstrapPartitions2, c1vdPositiveConfidencesPerBootstrapPartition2, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, dAUC2, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition2, bClass1IsNegativeLabel);
            
            dTerm1 = sum((vdUTerms1-vdUTerms2).^2) / (dn_1^2);
            
            
            bClass1IsNegativeLabel = false;
            
            vdUTerms1 = CalculateUTerms(vstBootstrapPartitions1, c1vdPositiveConfidencesPerBootstrapPartition1, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, dAUC1, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition1, bClass1IsNegativeLabel);
            vdUTerms2 = CalculateUTerms(vstBootstrapPartitions2, c1vdPositiveConfidencesPerBootstrapPartition2, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, dAUC2, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition2, bClass1IsNegativeLabel);
            
            dTerm2 = sum((vdUTerms1-vdUTerms2).^2) / (dn_2^2);
            
            
            dVarDelta = dTerm1 + dTerm2;
            
            
            dz = dDelta / sqrt(dVarDelta);
        end
        
        
        function vdAUCPerBootstrap = CalculateAUC_0Point632(c1oGuessResultPerBootstrapPartition, oGuessResultForTrainingAndTestingOnAllData)
            % as per Sahiner 2008 eqn. 5
            % - note: AUC_0.632 is being calculated per bootstrap rep. If
            % the mean is taken of all these values, the result is eqn. 5.
            % Doing it this way always for other stats to be done on the
            % bootstrap values (median, st dev, etc.), though DO NOTE,
            % these might not be valid/may be meaningless.
            
            dAUC_x_x = ErrorMetricsCalculator.CalculateAUC(oGuessResultForTrainingAndTestingOnAllData, 'JournalingOn', false);
            
            dNumBootstraps = length(c1oGuessResultPerBootstrapPartition);
            
            vdAUCPerBootstrap = zeros(dNumBootstraps,1);
            
            for dBootstrapIndex=1:dNumBootstraps
                dAUC = ErrorMetricsCalculator.CalculateAUC(c1oGuessResultPerBootstrapPartition{dBootstrapIndex}, 'JournalingOn', false);
                
                vdAUCPerBootstrap(dBootstrapIndex) = ( (1-0.632)*dAUC_x_x ) + ( 0.632 * dAUC );
            end
        end
        
        
        function vdAUCPerBootstrap = CalculateAUC_0Point632Plus(c1oGuessResultPerBootstrapPartition, oGuessResultForTrainingAndTestingOnAllData)
            % as per Sahiner 2008 eqn. 6-9
            % - note: AUC_0.632+ is being calculated per bootstrap rep. If
            % the mean is taken of all these values, the result is eqn. 6.
            % Doing it this way always for other stats to be done on the
            % bootstrap values (median, st dev, etc.), though DO NOTE,
            % these might not be valid/may be meaningless.
            
            dAUC_x_x = ErrorMetricsCalculator.CalculateAUC(oGuessResultForTrainingAndTestingOnAllData, 'JournalingOn', false);
            
            dNumBootstraps = length(c1oGuessResultPerBootstrapPartition);
            
            vdAUCPerBootstrap = zeros(dNumBootstraps,1);
            
            for dBootstrapIndex=1:dNumBootstraps
                dAUC = ErrorMetricsCalculator.CalculateAUC(c1oGuessResultPerBootstrapPartition{dBootstrapIndex}, 'JournalingOn', false);
                
                dAUCPrime = max(0.5, dAUC);
                
                if dAUC <= 0.5
                    dR = 1;
                elseif dAUC_x_x > dAUC && dAUC > 0.5
                    dR = ( dAUC_x_x - dAUC ) / ( dAUC_x_x - 0.5 );
                else
                    dR = 0;
                end
                
                dAlpha = 0.632 / (1 - ((1-0.632)*dR) );
                
                vdAUCPerBootstrap(dBootstrapIndex) = ( (1-dAlpha)*dAUC_x_x ) + ( dAlpha * dAUCPrime );
            end
        end
    end
end




function [dn_1, dn_2,  vdClass1SampleIndices, vdClass2SampleIndices, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, c1vdPositiveConfidencesPerBootstrapPartition] = ProcessInputs(vstBootstrapPartitions, c1oGuessResultPerBootstrapPartition)

dNumSamples = 0;
dNumBootstraps = length(vstBootstrapPartitions);

for dBootstrapIndex=1:dNumBootstraps
    dNumSamples = max(dNumSamples, max(max(vstBootstrapPartitions(dBootstrapIndex).TrainingIndices), max(vstBootstrapPartitions(dBootstrapIndex).TestingIndices)));
end

vbLabelPerSample = false(dNumSamples,1);

for dBootstrapIndex=1:dNumBootstraps
    viLabels = c1oGuessResultPerBootstrapPartition{dBootstrapIndex}.GetLabels();
    iPosLabel = c1oGuessResultPerBootstrapPartition{dBootstrapIndex}.GetPositiveLabel();
    
    vbLabels = viLabels == iPosLabel;
    
    vdTestingSampleIndices = vstBootstrapPartitions(dBootstrapIndex).TestingIndices;
    
    if length(vbLabels) ~= length(vdTestingSampleIndices)
        error(...
            'AdvancedErrorMetricsCalculator:ProcessInputs:InvalidGuessResult',...
            'The number of samples in the guess result must equal the number of samples in the corresponding partition testing set.');
    end
    
    vbLabelPerSample(vdTestingSampleIndices) = vbLabels;
end

m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition = false(dNumSamples, dNumBootstraps);

for dBootstrapIndex=1:dNumBootstraps
    vdTrainingSampleIndices = vstBootstrapPartitions(dBootstrapIndex).TrainingIndices;
    
    for dSampleIndex=1:dNumSamples
        m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dSampleIndex, dBootstrapIndex) = any(vdTrainingSampleIndices == dSampleIndex);
    end
end

c1vdPositiveConfidencesPerBootstrapPartition = cell(1, dNumBootstraps);

for dBootstrapIndex=1:dNumBootstraps
    c1vdPositiveConfidencesPerBootstrapPartition{dBootstrapIndex} = c1oGuessResultPerBootstrapPartition{dBootstrapIndex}.GetPositiveLabelConfidences();
end


vdAllSampleIndices = (1:dNumSamples)';

vdNegSampleIndices = vdAllSampleIndices(~vbLabelPerSample);
vdPosSampleIndices = vdAllSampleIndices(vbLabelPerSample);

dn_1 = length(vdNegSampleIndices);
dn_2 = length(vdPosSampleIndices);

vdClass1SampleIndices = vdNegSampleIndices;
vdClass2SampleIndices = vdPosSampleIndices;
end


function dAUC_1_1 = AUC_1_1(vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, bClass1IsNegativeLabel)

dNumBootstraps = length(vstBootstrapPartitions);

dDoubleSummationValue = 0;

for dj=1:dn_2
    dClass2SampleIndex = vdClass2SampleIndices(dj);
    
    for di=1:dn_1
        dClass1SampleIndex = vdClass1SampleIndices(di);
        
        dNumerator = 0;
        
        for db=1:dNumBootstraps
            if ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex,db) && ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex,db)
                dNumerator = dNumerator + Phi(dClass1SampleIndex, dClass2SampleIndex, vstBootstrapPartitions(db), c1vdPositiveConfidencesPerBootstrapPartition{db}, bClass1IsNegativeLabel);
            end
        end
        
        dDenominator = sum(~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex,:) & ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex,:));
        
        dDoubleSummationValue = dDoubleSummationValue + (dNumerator / dDenominator);
    end
end

dAUC_1_1 = dDoubleSummationValue / (dn_1*dn_2);
end


function vdUTerms = CalculateUTerms(vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dn_1, dn_2, vdClass1SampleIndices, vdClass2SampleIndices, dAUC_1_1, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, bClass1IsNegativeLabel)

dNumBootstraps = length(vstBootstrapPartitions);

if bClass1IsNegativeLabel
    
    vdU_1i_DoubleSummationCache = zeros(1,dNumBootstraps);
    
    for db=1:dNumBootstraps
        for dj1=1:dn_2
            for dj2=1:dn_2
                dClass2SampleIndex_1 = vdClass2SampleIndices(dj1);
                dClass2SampleIndex_2 = vdClass2SampleIndices(dj2);
                
                if ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex_1,db) && ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex_2,db)
                    dNumerator = Phi(dClass2SampleIndex_1, dClass2SampleIndex_2, vstBootstrapPartitions(db), c1vdPositiveConfidencesPerBootstrapPartition{db}, false); % by the nature of the double summation, the value of the last parameter doesn't matter (e.g. can be true or false)
                    
                    dDenominator = sum(~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex_1,:) & ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex_2,:));
                    
                    vdU_1i_DoubleSummationCache(db) = vdU_1i_DoubleSummationCache(db) + (dNumerator / dDenominator);
                end
            end
        end
    end
    
    vdUTerms = zeros(1,dn_1);
    
    for di=1:dn_1
        dU_1i = U(di, vdClass1SampleIndices, vdClass2SampleIndices, vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dAUC_1_1, bClass1IsNegativeLabel, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, vdU_1i_DoubleSummationCache);
        
        vdUTerms(di) = dU_1i;
    end

else
    
    vdU_2j_DoubleSummationCache = zeros(1,dNumBootstraps);
    
    for db=1:dNumBootstraps
        for di1=1:dn_1
            for di2=1:dn_1
                dClass1SampleIndex_1 = vdClass1SampleIndices(di1);
                dClass1SampleIndex_2 = vdClass1SampleIndices(di2);
                
                if ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex_1,db) && ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex_2,db)
                    dNumerator = Phi(dClass1SampleIndex_1, dClass1SampleIndex_2, vstBootstrapPartitions(db), c1vdPositiveConfidencesPerBootstrapPartition{db}, false); % by the nature of the double summation, the value of the last parameter doesn't matter (e.g. can be true or false)
                    
                    dDenominator = sum(~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex_1,:) & ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex_2,:));
                    
                    vdU_2j_DoubleSummationCache(db) = vdU_2j_DoubleSummationCache(db) + (dNumerator / dDenominator);
                end
            end
        end
    end
    
    vdUTerms = zeros(1,dn_2);
    
    for dj=1:dn_2
        dU_2j = U(dj, vdClass2SampleIndices, vdClass1SampleIndices, vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dAUC_1_1, bClass1IsNegativeLabel, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, vdU_2j_DoubleSummationCache);
        
        vdUTerms(dj) = dU_2j;
    end
    
end


end



function dValue = U(dClass1Index, vdClass1SampleIndices, vdClass2SampleIndices, vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, dAUC_1_1, bClass1IsNegativeLabel, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition, vdDoubleSummationCachePerBootstrapPartition)

dn_1 = length(vdClass1SampleIndices);
dn_2 = length(vdClass2SampleIndices);

dClass1SampleIndex = vdClass1SampleIndices(dClass1Index);

% TERM 1
dTerm1A = 2 + (1 / (dn_1 - 1));
dTerm1B_AUC_i = AUC_i(dClass1SampleIndex, vdClass2SampleIndices, vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, bClass1IsNegativeLabel, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition);
dTerm1B = (dTerm1B_AUC_i - dAUC_1_1) / dn_2;

dTerm1 = dTerm1A * dTerm1B;


% TERM 2

db_summation = 0;

for db=1:length(vstBootstrapPartitions)
    stBootstrapPartition = vstBootstrapPartitions(db);
    vdPositiveConfidencesForBootstrapPartition = c1vdPositiveConfidencesPerBootstrapPartition{db};
    
    % TERM 1
    dSummationTerm1 = (N_i_b(dClass1SampleIndex, stBootstrapPartition) - 1) / (dn_1 * dn_2);
    
    % TERM 2
    dSummationTerm2 = vdDoubleSummationCachePerBootstrapPartition(db);
    
    % FINAL
    db_summation = db_summation + (dSummationTerm1 * dSummationTerm2);
end

dTerm2 = db_summation;

% FINAL
dValue = dTerm1 + dTerm2;

end

function dValue = AUC_i(dClass1SampleIndex, vdClass2SampleIndices, vstBootstrapPartitions, c1vdPositiveConfidencesPerBootstrapPartition, bClass1IsNegativeLabel, m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition)

dn_2 = length(vdClass2SampleIndices);

dNumBootstraps = length(vstBootstrapPartitions);

dj_2_summation = 0;

for dj_2=1:dn_2
    dClass2SampleIndex = vdClass2SampleIndices(dj_2);
    
    dNumerator = 0;
    
    for db=1:dNumBootstraps
        if ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex,db) && ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex,db)
            dNumerator = dNumerator + Phi(dClass1SampleIndex, dClass2SampleIndex, vstBootstrapPartitions(db), c1vdPositiveConfidencesPerBootstrapPartition{db}, bClass1IsNegativeLabel);
        end
    end
    
    dDenominator = sum(~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass1SampleIndex,:) & ~m2bSampleIsInTrainingSetPerSamplePerBootstrapPartition(dClass2SampleIndex,:));
    
    dj_2_summation = dj_2_summation + (dNumerator / dDenominator);
end

dValue = dj_2_summation / dn_2;

end


function dVal = Phi(dSample1Index, dSample2Index, stBootstrapPartition, vdPositiveConfidencesForBootstrapPartition, bSample1IsNegative)
dSample1BootstrapIndex = find(stBootstrapPartition.TestingIndices == dSample1Index);
dSample2BootstrapIndex = find(stBootstrapPartition.TestingIndices == dSample2Index);

if bSample1IsNegative
    dNegSamplePositiveConfidence = vdPositiveConfidencesForBootstrapPartition(dSample1BootstrapIndex);
    dPosSamplePositiveConfidence = vdPositiveConfidencesForBootstrapPartition(dSample2BootstrapIndex);
else
    dNegSamplePositiveConfidence = vdPositiveConfidencesForBootstrapPartition(dSample2BootstrapIndex);
    dPosSamplePositiveConfidence = vdPositiveConfidencesForBootstrapPartition(dSample1BootstrapIndex);
end

if dPosSamplePositiveConfidence > dNegSamplePositiveConfidence % correct!
    dVal = 1;
elseif dPosSamplePositiveConfidence < dNegSamplePositiveConfidence % wrong :(
    dVal = 0;
else % tie
    dVal = 0.5;
end
end


function dVal = N_i_b(dSampleIndex, stBootstrapPartition)

dVal = sum(stBootstrapPartition.TrainingIndices == dSampleIndex);

end