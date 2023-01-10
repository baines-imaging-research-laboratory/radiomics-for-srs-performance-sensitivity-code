classdef (Abstract) ErrorMetricsCalculator
    %ErrorMetricsCalculator
    %   This utility package contains functions to calculate error metrics on
    %   the results from testing.
    %
    %   ErrorMetricsCalculator.CalculateFalseNegativeRate
    %   ErrorMetricsCalculator.CalculateFalsePositiveRate
    %   ErrorMetricsCalculator.CalculateTrueNegativeRate
    %   ErrorMetricsCalculator.CalculateTruePositiveRate
    %   ErrorMetricsCalculator.CalculateMisclassificationRate
    %   ErrorMetricsCalculator.CalculateAUC
    %   ErrorMetricsCalculator.CalculateOptimalThreshold
    %   ErrorMetricsCalculator.CalculateROCPoints
    %   ErrorMetricsCalculator.CalculatePRAUC
    %   ErrorMetricsCalculator.CalculatePRROCPoints
    %   ErrorMetricsCalculator.CalculatePrecision
    
    % Primary Author: Ryan Alfano
    % Created: Apr 22, 2019
    properties (Access = private, Constant = true)
    end
    
    methods (Access = public, Static = true)
        
        function vdFalseNegativeRate = CalculateFalseNegativeRate(varargin)
            %vdFalseNegativeRate = CalculateFalseNegativeRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %
            % SYNTAX:
            %  vdFalseNegativeRate = CalculateFalseNegativeRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %  vdFalseNegativeRate = CalculateFalseNegativeRate(__, __, __, __, 'JournalingOn', bJournalingOn)
            %  vdFalseNegativeRate = CalculateFalseNegativeRate(oGuessResult, vdConfidenceThreshold)
            %  vdFalseNegativeRate = CalculateFalseNegativeRate(__, __, 'JournalingOn', bJournalingOn)
            %
            % DESCRIPTION:
            %  Calculates false negative rates on the data based on the
            %  input threshold(s).
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  bJournalingOn: A boolean flag to turn on/off experiment
            %   journalling
            %  vdConfidenceThreshold: A vector of doubles representing the confidence
            %   threshold used for error metric calculation.
            %
            % OUTPUTS ARGUMENTS:
            %  vdFalseNegativeRate: A vector of the false negative rate calculated at each threshold.
            
            % Primary Author: Ryan Alfano
            % Created: 04 22, 2019
            
            [viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold, bJournallingOn] = ErrorMetricsCalculator.ParseInput(varargin{:});
            % Check to make sure there are positive labels and if not
            % return a vector of NaN the size of the thresholds array
            if ~ismember(iPositiveLabel,viLabels)
                warning(...
                    'ErrorMetricsCalculator:NoPositiveLabels',...
                    'No positive labels found in viLabels. Positive labels are required to calculate FalseNegativeRate. Vector of NaN has been returned.');
                vdFalseNegativeRate = NaN(1,size(vdConfidenceThreshold,1));
            else
                vdFalseNegativeRate = [];
                
                for iThresholdIterator = 1:size(vdConfidenceThreshold,1)
                    dNumFalseNegatives = 0;
                    dNumPositives = 0;
                    
                    for iConfidenceIterator = 1:size(vdConfidences,1)
                        % Is the sample positive?
                        if viLabels(iConfidenceIterator) == iPositiveLabel
                            % Increment total number of positive samples
                            dNumPositives = dNumPositives + 1;
                            % Has it been labelled negative?
                            if vdConfidences(iConfidenceIterator) < vdConfidenceThreshold(iThresholdIterator)
                                dNumFalseNegatives = dNumFalseNegatives + 1;
                            end
                        end
                    end
                    
                    vdFalseNegativeRate(end+1) = dNumFalseNegatives / dNumPositives;
                end
            end
            
            ErrorMetricsCalculator.JournalNumericValue('False Negative Rate', vdFalseNegativeRate, bJournallingOn);
        end
        
        function vdFalsePositiveRate = CalculateFalsePositiveRate(varargin)
            %vdFalsePositiveRate = CalculateFalsePositiveRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %
            % SYNTAX:
            %  vdFalsePositiveRate = CalculateFalsePositiveRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %  vdFalsePositiveRate = CalculateFalsePositiveRate(__, __, __, __, 'JournalingOn', bJournalingOn)
            %  vdFalsePositiveRate = CalculateFalsePositiveRate(oGuessResult, vdConfidenceThreshold)
            %  vdFalsePositiveRate = CalculateFalsePositiveRate(__, __, 'JournalingOn', bJournalingOn)
            %
            % DESCRIPTION:
            %  Calculates false positive rates on the data based on the
            %  input threshold(s).
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  bJournalingOn: A boolean flag to turn on/off experiment
            %   journalling
            %  vdConfidenceThreshold: A vector of doubles representing the confidence
            %   threshold used for error metric calculation.
            %
            % OUTPUTS ARGUMENTS:
            %  vdFalsePositiveRate: A vector of the false positive rate calculated at each threshold.
            
            % Primary Author: Ryan Alfano
            % Created: 04 22, 2019
            
            [viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold, bJournallingOn] = ErrorMetricsCalculator.ParseInput(varargin{:});
            
            % Check to make sure there are negative labels and if not
            % return a vector of NaN the size of the thresholds array
            if sum(viLabels == iPositiveLabel) == length(viLabels)
                warning(...
                    'ErrorMetricsCalculator:NoNegativeLabels',...
                    'No negative labels found in viLabels. Negative labels are required to calculate FalsePositiveRate. Vector of NaN has been returned.');
                vdFalsePositiveRate = NaN(1,size(vdConfidenceThreshold,1));
            else
                vdFalsePositiveRate = [];
                
                for iThresholdIterator = 1:size(vdConfidenceThreshold,1)
                    dNumFalsePositives = 0;
                    dNumNegatives = 0;
                    
                    for iConfidenceIterator = 1:size(vdConfidences,1)
                        % Is the sample negative?
                        if viLabels(iConfidenceIterator) ~= iPositiveLabel
                            % Increment total number of negative samples
                            dNumNegatives = dNumNegatives + 1;
                            % Has it been labelled positive?
                            if vdConfidences(iConfidenceIterator) >= vdConfidenceThreshold(iThresholdIterator)
                                dNumFalsePositives = dNumFalsePositives + 1;
                            end
                        end
                    end
                    
                    vdFalsePositiveRate(end+1) = dNumFalsePositives / dNumNegatives;
                end
            end
            
            ErrorMetricsCalculator.JournalNumericValue('False Positive Rate', vdFalsePositiveRate, bJournallingOn);
        end
        
        function vdTrueNegativeRate = CalculateTrueNegativeRate(varargin)
            %vdTrueNegativeRate = CalculateTrueNegativeRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %
            % SYNTAX:
            %  vdTrueNegativeRate = CalculateTrueNegativeRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %  vdTrueNegativeRate = CalculateTrueNegativeRate(__, __, __, __, 'JournalingOn', bJournalingOn)
            %  vdTrueNegativeRate = CalculateTrueNegativeRate(oGuessResult, vdConfidenceThreshold)
            %  vdTrueNegativeRate = CalculateTrueNegativeRate(__, __, 'JournalingOn', bJournalingOn)
            %
            % DESCRIPTION:
            %  Calculates true negative rates on the data based on the
            %  input threshold(s).
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  bJournalingOn: A boolean flag to turn on/off experiment
            %   journalling
            %  vdConfidenceThreshold: A vector of doubles representing the confidence
            %   threshold used for error metric calculation.
            %
            % OUTPUTS ARGUMENTS:
            %  vdTrueNegativeRate: A vector of the true negative rate calculated at each threshold.
            
            % Primary Author: Ryan Alfano
            % Created: 04 22, 2019
            
            [viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold, bJournallingOn] = ErrorMetricsCalculator.ParseInput(varargin{:});
            
            % Check to make sure there are negative labels and if not
            % return a vector of NaN the size of the thresholds array
            if sum(viLabels == iPositiveLabel) == length(viLabels)
                warning(...
                    'ErrorMetricsCalculator:NoNegativeLabels',...
                    'No negative labels found in viLabels. Negative labels are required to calculate TrueNegativeRate. Vector of NaN has been returned.');
                vdTrueNegativeRate = NaN(1,size(vdConfidenceThreshold,1));
            else
                vdTrueNegativeRate = [];
               
                for iThresholdIterator = 1:size(vdConfidenceThreshold,1)
                    dNumTrueNegatives = 0;
                    dNumNegatives = 0;
                    
                    for iConfidenceIterator = 1:size(vdConfidences,1)
                        % Is the sample negative?
                        if viLabels(iConfidenceIterator) ~= iPositiveLabel
                            % Increment total number of negative samples
                            dNumNegatives = dNumNegatives + 1;
                            % Has it been labelled negative?
                            if vdConfidences(iConfidenceIterator) < vdConfidenceThreshold(iThresholdIterator)
                                dNumTrueNegatives = dNumTrueNegatives + 1;
                            end
                        end
                    end
                    
                    vdTrueNegativeRate(end+1) = dNumTrueNegatives / dNumNegatives;
                end
            end
            
            ErrorMetricsCalculator.JournalNumericValue('True Negative Rate', vdTrueNegativeRate, bJournallingOn);
        end
        
        function vdTruePositiveRate = CalculateTruePositiveRate(varargin)
            %vdTruePositiveRate = CalculateTruePositiveRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %
            % SYNTAX:
            %  vdTruePositiveRate = CalculateTruePositiveRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %  vdTruePositiveRate = CalculateTruePositiveRate(__, __, __, __, 'JournalingOn', bJournalingOn)
            %  vdTruePositiveRate = CalculateTruePositiveRate(oGuessResult, vdConfidenceThreshold)
            %  vdTruePositiveRate = CalculateTruePositiveRate(__, __, 'JournalingOn', bJournalingOn)
            % DESCRIPTION:
            %  Calculates true positive rates on the data based on the
            %  input threshold(s).
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  vdConfidenceThreshold: A vector of doubles representing the confidence
            %   threshold used for error metric calculation.
            %
            % OUTPUTS ARGUMENTS:
            %  vdTruePositiveRate: A vector of the true positive rate calculated at each threshold.
            
            % Primary Author: Ryan Alfano
            % Created: 04 22, 2019
            
            [viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold, bJournallingOn] = ErrorMetricsCalculator.ParseInput(varargin{:});
           
            % Check to make sure there are positive labels and if not
            % return a vector of NaN the size of the thresholds array
            if ~ismember(iPositiveLabel,viLabels)
                warning(...
                    'ErrorMetricsCalculator:NoPositiveLabels',...
                    'No positive labels found in viLabels. Positive labels are required to calculate TruePositiveRate. Vector of NaN has been returned.');
                vdTruePositiveRate = NaN(1,size(vdConfidenceThreshold,1));
            else
                vdTruePositiveRate = [];
                
                for iThresholdIterator = 1:size(vdConfidenceThreshold,1)
                    dNumTruePositives = 0;
                    dNumPositives = 0;
                    
                    for iConfidenceIterator = 1:size(vdConfidences,1)
                        % Is the sample positive?
                        if viLabels(iConfidenceIterator) == iPositiveLabel
                            % Increment total number of positive samples
                            dNumPositives = dNumPositives + 1;
                            % Has it been labelled positive?
                            if vdConfidences(iConfidenceIterator) >= vdConfidenceThreshold(iThresholdIterator)
                                dNumTruePositives = dNumTruePositives + 1;
                            end
                        end
                    end
                    
                    vdTruePositiveRate(end+1) = dNumTruePositives / dNumPositives;
                end
            end
            
            ErrorMetricsCalculator.JournalNumericValue('True Positive Rate', vdTruePositiveRate, bJournallingOn);
        end
        
        function vdMisclassificationRate = CalculateMisclassificationRate(varargin)
            %vdMisclassificationRate = CalculateMisclassificationRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %
            % SYNTAX:
            %  vdMisclassificationRate = CalculateMisclassificationRate(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %  vdMisclassificationRate = CalculateMisclassificationRate(__, __, __, __, 'JournalingOn', bJournalingOn)
            %  vdMisclassificationRate = CalculateMisclassificationRate(oGuessResult, vdConfidenceThreshold)
            %  vdMisclassificationRate = CalculateMisclassificationRate(__, __, 'JournalingOn', bJournalingOn)
            %
            % DESCRIPTION:
            %  Calculates miscclassification rates on the data based on the
            %  input threshold(s).
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  bJournalingOn: A boolean flag to turn on/off experiment
            %   journalling
            %  vdConfidenceThreshold: A vector of doubles representing the confidence
            %   threshold used for error metric calculation.
            %
            % OUTPUTS ARGUMENTS:
            %  vdMisclassificationRate: A vector of the misclassification rate calculated at each threshold.
            
            % Primary Author: Ryan Alfano
            % Created: 04 25, 2019
            
            [viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold, bJournallingOn] = ErrorMetricsCalculator.ParseInput(varargin{:});
            
            vdMisclassificationRate = [];
            
            for iThresholdIterator = 1:size(vdConfidenceThreshold,1)
                dNumFalsePositives = 0;
                dNumPositives = 0;
                dNumNegatives = 0;
                dNumFalseNegatives = 0;
                
                for iConfidenceIterator = 1:size(vdConfidences,1)
                    % Is the sample positive?
                    if viLabels(iConfidenceIterator) == iPositiveLabel
                        % Increment total number of positive samples
                        dNumPositives = dNumPositives + 1;
                        % Has it been labelled negative (False negative)?
                        if vdConfidences(iConfidenceIterator) < vdConfidenceThreshold(iThresholdIterator)
                            dNumFalseNegatives = dNumFalseNegatives + 1;
                        end
                    else
                        % Increment total number of negative samples
                        dNumNegatives = dNumNegatives + 1;
                        % Has it been labelled positive (False positive)?
                        if vdConfidences(iConfidenceIterator) >= vdConfidenceThreshold(iThresholdIterator)
                            dNumFalsePositives = dNumFalsePositives + 1;
                        end
                    end
                end
                vdMisclassificationRate(end+1) = (dNumFalsePositives + dNumFalseNegatives) / (dNumPositives + dNumNegatives);
            end
            
            ErrorMetricsCalculator.JournalNumericValue('Misclassification Rate', vdMisclassificationRate, bJournallingOn);
        end
        
        function vdPrecision = CalculatePrecision(varargin)
            %vdPrecision = CalculatePrecision(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %
            % SYNTAX:
            %  vdPrecision = CalculatePrecision(viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold)
            %  vdPrecision = CalculatePrecision(__, __, __, __, 'JournalingOn', bJournalingOn)
            %  vdPrecision = CalculatePrecision(oGuessResult, vdConfidenceThreshold)
            %  vdPrecision = CalculatePrecision(__, __, 'JournalingOn', bJournalingOn)
            %
            % DESCRIPTION:
            %  Calculates precision on the data based on the
            %  input threshold(s).
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  bJournalingOn: A boolean flag to turn on/off experiment
            %   journalling
            %  vdConfidenceThreshold: A vector of doubles representing the confidence
            %   threshold used for error metric calculation.
            %
            % OUTPUTS ARGUMENTS:
            %  vdPrecision: A vector of the precision calculated at each threshold.
            
            % Primary Author: Ryan Alfano
            % Created: 04 25, 2019
            
            [viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold, bJournallingOn] = ErrorMetricsCalculator.ParseInput(varargin{:});
            
            vdPrecision = [];
            
            for iThresholdIterator = 1:size(vdConfidenceThreshold,1)
                dNumFalsePositives = 0;
                dNumTruePositives = 0;
                for iConfidenceIterator = 1:size(vdConfidences,1)
                    % Is the sample positive?
                    if viLabels(iConfidenceIterator) == iPositiveLabel
                        % Has it been labelled positive?
                        if vdConfidences(iConfidenceIterator) >= vdConfidenceThreshold(iThresholdIterator)
                            dNumTruePositives = dNumTruePositives + 1;
                        end
                    else
                        % Has it been labelled positive (False positive)?
                        if vdConfidences(iConfidenceIterator) >= vdConfidenceThreshold(iThresholdIterator)
                            dNumFalsePositives = dNumFalsePositives + 1;
                        end
                    end
                end
                
                if (dNumTruePositives == 0) && (dNumFalsePositives == 0)
                    warning(...
                        'ErrorMetricsCalculator:NoTruePositivesOrFalsePositives',...
                        'No true positives or false positives found creating a zero denominator when calculating precision. NaN has been returned.');
                    vdPrecision(end+1) = NaN;
                else
                    vdPrecision(end+1) = dNumTruePositives / (dNumTruePositives + dNumFalsePositives);
                end
            end
            
            ErrorMetricsCalculator.JournalNumericValue('Precision Rate', vdPrecision, bJournallingOn);
        end
        
        function dAUC = CalculateAUC(varargin)
            %dAUC = CalculateAUC(viLabels, vdConfidences, iPositiveLabel)
            %
            % SYNTAX:
            %  dAUC = CalculateAUC(viLabels, vdConfidences, iPositiveLabel)
            %  dAUC = CalculateAUC(__, __, __, 'JournalingOn', bJournalingOn)
            %  dAUC = CalculateAUC(oGuessResult)
            %  dAUC = CalculateAUC(__, 'JournalingOn', bJournalingOn)
            %
            % DESCRIPTION:
            %  Calculates the area under the receiver operating
            %   characteristic curve - a wrapper to the MATLAB function
            %   perfcurve
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  bJournalingOn: A boolean flag to turn on/off experiment
            %   journalling
            %
            % OUTPUTS ARGUMENTS:
            %  dAUC: The area under the receiver operating characteristic
            %   curve.
            
            % Primary Author: Ryan Alfano
            % Created: 04 22, 2019
            
            bJournalingOn = true; % default
            
            if (nargin == 1 || (nargin == 3 && strcmp(varargin{2}, 'JournalingOn'))) && isa(varargin{1}, 'ClassificationGuessResult')
                viLabels = varargin{1}.GetLabels();
                vdConfidences = varargin{1}.GetPositiveLabelConfidences();
                iPositiveLabel = varargin{1}.GetPositiveLabel();
                
                if nargin == 3
                    bJournalingOn = varargin{3};
                end
            elseif (nargin == 1 || (nargin == 3 && strcmp(varargin{2}, 'JournalingOn'))) && isa(varargin{1}, 'GuessResult')
                oGuessResult = varargin{1};
                
                MustBeValidForBinaryClassification(oGuessResult);
                
                viLabels = oGuessResult.GetGroundTruthSampleLabels().GetLabels();
                vdConfidences = oGuessResult.GetGuessResultSampleLabels().GetPositiveLabelConfidences();
                iPositiveLabel = oGuessResult.GetGroundTruthSampleLabels().GetPositiveLabel();
                
                if nargin == 3
                    bJournalingOn = varargin{3};
                end
            elseif nargin == 3 || (nargin == 5 && strcmp(varargin{4}, 'JournalingOn'))
                if ~iscolumn(varargin{1}) || ~iscolumn(varargin{2}) || ~isa(varargin{1}, 'integer') || ~isa(varargin{2}, 'double')...
                        || ~isa(varargin{3}, 'integer') || ~isscalar(varargin{3})
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The given labels and confidences must be column vectors of type integer and double respectively.  The positive label must be a scalar of type integer.');
                else
                    viLabels = varargin{1};
                    vdConfidences = varargin{2};
                    iPositiveLabel = varargin{3};
                end
                
                if nargin == 5
                    bJournalingOn = varargin{5};
                end
            else
                error(...
                    'ErrorMetricsCalculator:InvalidNumParameters',...
                    'See constructor documentation for usage.');
            end
            
            % validate journaling on
            ValidationUtils.MustBeScalar(bJournalingOn);
            ValidationUtils.MustBeA(bJournalingOn, 'logical');
            
            % Calculate AUC
            [vdX,vdY,~,dAUC] = perfcurve(double(viLabels),vdConfidences,iPositiveLabel); % TODO: Give user option to plot ROC curves
            
            % Journal
            if Experiment.IsRunning() && bJournalingOn
                % journal ROC curve and AUC value
                hFig = figure('Visible', 'off');
                plot(vdX, vdY, 'Color', 'r', 'LineWidth', 2);
                hold('on');
                plot([0 1],[0 1], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '--');
                grid('on');
                axis('equal');
                xlim([0,1]);
                ylim([0,1]);
                xticks(0:0.1:1);
                yticks(0:0.1:1);
                xlabel('False Positive Rate');
                ylabel('True Positive Rate');
                title('ROC Curve');
                
                chSavePath = [Experiment.GetUniqueResultsFileNamePath(), '.fig'];
                
                savefig(hFig, chSavePath);
                close(hFig);
                
                Experiment.AddToReport(chSavePath);
                
                ErrorMetricsCalculator.JournalNumericValue('AUC', dAUC, bJournalingOn);
            end
        end
        
        function dPRAUC = CalculatePRAUC(varargin)
            %dPRAUC = CalculatePRAUC(viLabels, vdConfidences, iPositiveLabel)
            %
            % SYNTAX:
            %  dPRAUC = CalculatePRAUC(viLabels, vdConfidences, iPositiveLabel)
            %  dPRAUC = CalculatePRAUC(__, __, __, 'JournalingOn', bJournalingOn)
            %  dPRAUC = CalculatePRAUC(oGuessResult)
            %  dPRAUC = CalculatePRAUC(__, 'JournalingOn', bJournalingOn)
            %
            % DESCRIPTION:
            %  Calculates the area under the precision-recall receiver operating
            %   characteristic curve - a wrapper to the MATLAB function
            %   perfcurve
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %  bJournalingOn: A boolean flag to turn on/off experiment
            %   journalling
            %
            % OUTPUTS ARGUMENTS:
            %  dPRAUC: The area under the precision-recall receiver operating characteristic
            %   curve.
            
            % Primary Author: Ryan Alfano
            % Created: 04 22, 2019
            
            bJournalingOn = true; % default
            
            if nargin == 1 || (nargin == 3 && strcmp(varargin{2}, 'JournalingOn'))
                if ~isa(varargin{1}, 'ClassificationGuessResult')
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The GuessResult object must be a valid object from the GuessResult class.');
                else
                    viLabels = varargin{1}.GetLabels();
                    vdConfidences = varargin{1}.GetPositiveLabelConfidences();
                    iPositiveLabel = varargin{1}.GetPositiveLabel();
                end
                
                if nargin == 3
                    bJournalingOn = varargin{3};
                end
            elseif nargin == 3 || (nargin == 5 && strcmp(varargin{4}, 'JournalingOn'))
                if ~iscolumn(varargin{1}) || ~iscolumn(varargin{2}) || ~isa(varargin{1}, 'integer') || ~isa(varargin{2}, 'double')...
                        || ~isa(varargin{3}, 'integer') || ~isscalar(varargin{3})
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The given labels and confidences must be column vectors of type integer and double respectively.  The positive label must be a scalar of type integer.');
                else
                    viLabels = varargin{1};
                    vdConfidences = varargin{2};
                    iPositiveLabel = varargin{3};
                end
                
                if nargin == 5
                    bJournalingOn = varargin{5};
                end
            else
                error(...
                    'ErrorMetricsCalculator:InvalidNumParameters',...
                    'See constructor documentation for usage.');
            end
            
            % validate journaling on
            ValidationUtils.MustBeScalar(bJournalingOn);
            ValidationUtils.MustBeA(bJournalingOn, 'logical');
            
            [vdX,vdY,~,dPRAUC] = perfcurve(double(viLabels),vdConfidences,iPositiveLabel,'XCrit','reca','YCrit','prec');
            
            dNumPositive = sum(viLabels(:)==iPositiveLabel);
            dNumNegative = sum(viLabels(:)~=iPositiveLabel);
            dRandomPerfLine = dNumPositive/(dNumPositive + dNumNegative);
            
            % Journal
            if Experiment.IsRunning() && bJournalingOn
                % journal PRROC curve and PRAUC value
                hFig = figure('Visible', 'off');
                plot(vdX, vdY, 'Color', 'r', 'LineWidth', 2);
                hold('on');
                yline(dRandomPerfLine, 'Color', 'k', 'LineWidth', 1, 'LineStyle', '--');
                grid('on');
                axis('equal');
                xlim([0,1]);
                ylim([0,1]);
                xticks(0:0.1:1);
                yticks(0:0.1:1);
                xlabel('Recall');
                ylabel('Precision');
                title('Precision-Recall ROC Curve');
                
                chSavePath = [Experiment.GetUniqueResultsFileNamePath(), '.fig'];
                
                savefig(hFig, chSavePath);
                close(hFig);
                
                Experiment.AddToReport(hFig);
                
                ErrorMetricsCalculator.JournalNumericValue('PRAUC', dPRAUC, bJournalingOn);
            end
        end
        
        function dConfidenceThreshold = CalculateOptimalThreshold(varargin)
            %dConfidenceThreshold = CalculateOptimalThreshold(c1xCriteria,viLabels, vdConfidences, iPositiveLabel)
            %
            % SYNTAX:
            %  dConfidenceThreshold = CalculateOptimalThreshold(c1xCriteria,viLabels, vdConfidences, iPositiveLabel)
            %  dConfidenceThreshold = CalculateOptimalThreshold(c1xCriteria,oGuessResult)
            %
            % DESCRIPTION:
            %  Calculates the optimal confidence threshold based on the
            %  criteria provided in c1xCriteria. The information stored in
            %  this array may be a string to indicate use of a premade
            %  function or a function handle if one decides to make their
            %  own.
            %
            %  Current premade criteria are: "FNR", "FPR", "TNR", "TPR", "MCR", "matlab", "upperleft"
            %
            % INPUT ARGUMENTS:
            %  c1xCriteria: a vector of strings and/or function handles
            %  oGuessResult: a valid GuessResult object
            %  viLabels: vector of ground truth labels
            %  vdConfidences: vector of output confidences from
            %  iPositiveLabel: interger representing the positive label in
            %   the vector of viLabels
            %
            % OUTPUTS ARGUMENTS:
            %  dConfidenceThreshold: the confidence threshold for best
            %  classification (x >= dConfidenceThreshold = iPositiveLabel)
            
            % Primary Author: Ryan Alfano
            % Created: 04 22, 2019
            
            bJournalingOn = true; % default
            bSuppressWarnings = false; % default
            
            c1xNameValuePairs = {};
            
            if nargin == 2 || (nargin > 2 && (ischar(varargin{3}) || isstring(varargin{3})) )
                if ~isa(varargin{1},'cell') || ~isa(varargin{2}, 'ClassificationGuessResult')
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The GuessResult object must be a valid object from the GuessResult class. The criteria must be a vector of strings.');
                else
                    c1xCriteria = varargin{1};
                    viLabels = varargin{2}.GetLabels();
                    vdConfidences = varargin{2}.GetPositiveLabelConfidences();
                    iPositiveLabel = varargin{2}.GetPositiveLabel();
                end
                
                if nargin > 2
                    c1xNameValuePairs = varargin(3:end);
                end
            elseif nargin == 4 || nargin == 2 || (nargin > 4 && (ischar(varargin{5}) || isstring(varargin{5})) )
                if ~isa(varargin{1},'cell') || ~iscolumn(varargin{2}) || ~iscolumn(varargin{3}) || ~isa(varargin{2}, 'integer') || ~isa(varargin{3}, 'double')...
                        || ~isa(varargin{4}, 'integer') || ~isscalar(varargin{4})
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The given labels and confidences must be column vectors of type integer and double respectively.  The positive label must be a scalar of type integer. The criteria must be a vector of strings.');
                else
                    c1xCriteria = varargin{1};
                    viLabels = varargin{2};
                    vdConfidences = varargin{3};
                    iPositiveLabel = varargin{4};
                end
                
                if nargin > 4
                    c1xNameValuePairs = varargin(5:end);
                end
            else
                error(...
                    'ErrorMetricsCalculator:InvalidNumParameters',...
                    'See constructor documentation for usage.');
            end
            
            % process name-value pairs
            for dVarIndex=1:2:length(c1xNameValuePairs)
                switch char(c1xNameValuePairs{dVarIndex})
                    case 'JournalingOn'
                        bJournalingOn = c1xNameValuePairs{dVarIndex+1};
                        
                        ValidationUtils.MustBeScalar(bJournalingOn);
                        ValidationUtils.MustBeA(bJournalingOn, 'logical');
                    case 'SuppressWarnings'
                        bSuppressWarnings = c1xNameValuePairs{dVarIndex+1};
                        
                        ValidationUtils.MustBeScalar(bSuppressWarnings);
                        ValidationUtils.MustBeA(bSuppressWarnings, 'logical');
                    otherwise
                        error(...
                            'ErrorMetricsCalculator:CalculateOptimalThreshold:InvalidNameValuePair',...
                            ['The name ''', char(c1xNameValuePairs{dVarIndex}), ''' is invalid.']);
                end
            end
            
            % calculate:
            vdThresholds = unique(vdConfidences);
            
            % Loop through all the criteria
            for iCriteriaNum = 1:length(c1xCriteria)
                % Tiebreaker alert
                if (iCriteriaNum > 1) && length(vdThresholds) > 1
                    if ~bSuppressWarnings
                        warning('ErrorMetricsCalculator:ThresholdTiebreaker',...
                            ['More than one threshold found from the previous criterion. Breaking the tie with criterion number ' num2str(iCriteriaNum) '.']);
                    end
                end
                
                if isa(c1xCriteria{iCriteriaNum},'function_handle')
                    fhCriteriaFunc = c1xCriteria{iCriteriaNum};
                    vdThresholds = fhCriteriaFunc(viLabels,vdConfidences,iPositiveLabel,vdThresholds);
                else
                    switch c1xCriteria{iCriteriaNum}
                        
                        case {"FNR","FalseNegativeRate"}
                            % Calculate false negative rates
                            vdFalseNegativeRates = ErrorMetricsCalculator.CalculateFalseNegativeRate(...
                                viLabels, vdConfidences, iPositiveLabel, vdThresholds,...
                                'JournalingOn', bJournalingOn);
                            
                            % Find the minimum FNR
                            dMinFNR = min(vdFalseNegativeRates);
                            
                            % Find the threshold(s) that have this value
                            vdThresholds = vdThresholds(vdFalseNegativeRates == dMinFNR);
                            
                            
                        case {"FPR","FalsePositiveRate"}
                            % Calculate false positive rates
                            vdFalsePositiveRates = ErrorMetricsCalculator.CalculateFalsePositiveRate(...
                                viLabels, vdConfidences, iPositiveLabel, vdThresholds,...
                                'JournalingOn', bJournalingOn);
                            
                            % Find the minimum FNR
                            dMinFPR = min(vdFalsePositiveRates);
                            
                            % Find the threshold(s) that have this value
                            vdThresholds = vdThresholds(vdFalsePositiveRates == dMinFPR);
                            
                            
                        case {"TPR","TruePositiveRate"}
                            % Calculate true positive rates
                            vdTruePositiveRates = ErrorMetricsCalculator.CalculateTruePositiveRate(...
                                viLabels, vdConfidences, iPositiveLabel, vdThresholds,...
                                'JournalingOn', bJournalingOn);
                            
                            % Find the max TPR
                            dMaxTPR = max(vdTruePositiveRates);
                            
                            % Find the threshold(s) that have this value
                            vdThresholds = vdThresholds(vdTruePositiveRates == dMaxTPR);
                            
                            
                        case {"TNR","TrueNegativeRate"}
                            % Calculate true negative rates
                            vdTrueNegativeRates = ErrorMetricsCalculator.CalculateTrueNegativeRate(...
                                viLabels, vdConfidences, iPositiveLabel, vdThresholds,...
                                'JournalingOn', bJournalingOn);
                            
                            % Find the max TNR
                            dMaxTNR = max(vdTrueNegativeRates);
                            
                            % Find the threshold(s) that have this value
                            vdThresholds = vdThresholds(vdTrueNegativeRates == dMaxTNR);
                            
                            
                        case {"MCR","MisclassificationRate"}
                            % Calculate misclassification rates
                            vdMisclassificationRates = ErrorMetricsCalculator.CalculateMisclassificationRate(...
                                viLabels, vdConfidences, iPositiveLabel, vdThresholds,...
                                'JournalingOn', bJournalingOn);
                            
                            % Find the minimum MCR
                            dMinMCR = min(vdMisclassificationRates);
                            
                            % Find the threshold(s) that have this value
                            vdThresholds = vdThresholds(vdMisclassificationRates == dMinMCR);
                            
                            
                        case "matlab"
                            [vdROCXVals,vdROCYVals,vdConfidenceThresholds,~,vdOptimalROCPoints] = perfcurve(double(viLabels),vdConfidences,iPositiveLabel);
                            vdThresholds = vdConfidenceThresholds((vdROCXVals==vdOptimalROCPoints(1))&(vdROCYVals==vdOptimalROCPoints(2)));
                            
                            
                        case "upperleft"
                            % Calculate the ROC points
                            [vdROCXVals,vdROCYVals,vdConfidenceThresholds,~,vdOptimalROCPoints] = perfcurve(double(viLabels),vdConfidences,iPositiveLabel);
                            
                            dMinDistance = -1;
                            % Loop through and find the minimum distance to the
                            % upper left corner
                            for iROCValIdx = 1:length(vdConfidenceThresholds)
                                dEuclideanDistance = sqrt(((vdROCXVals(iROCValIdx) - 0)^2)+((vdROCYVals(iROCValIdx) - 1)^2));
                                if dMinDistance == -1
                                    dMinDistance = dEuclideanDistance;
                                    vdThresholds = vdConfidenceThresholds(iROCValIdx);
                                else
                                    % Is there multiple points with the same
                                    % distance or is there a point with a
                                    % smaller distance
                                    if dEuclideanDistance == dMinDistance
                                        vdThresholds(end+1,1) = vdConfidenceThresholds(iROCValIdx);
                                    elseif  dEuclideanDistance < dMinDistance
                                        dMinDistance = dEuclideanDistance;
                                        vdThresholds = vdConfidenceThresholds(iROCValIdx);
                                    end
                                end
                            end
                            
                            
                        otherwise
                            % One of the strings provided is not listed in the switch statement
                            error(...
                                'ErrorMetricsCalculator:InvalidThresholdCriterion',...
                                'The threshold criterion listed could not be found. See documentation for more information.');
                    end
                end
            end
            
            % Error out of there is more than one threshold at the end
            if length(vdThresholds) > 1
                error(...
                    'ErrorMetricsCalculator:MultipleThresholds',...
                    'Could not converge to one optimal threshold with the given criteria.');
            elseif length(vdThresholds) == 0
                error(...
                    'ErrorMetricsCalculator:UnknownThreshold',...
                    'No threshold could be found with the criteria provided.');
            else
                dConfidenceThreshold = vdThresholds;
            end
        end
        
        function [vdROCXVals,vdROCYVals,vdConfidenceThresholds] = CalculateROCPoints(varargin)
            %[vdROCXVals,vdROCYVals,vdConfidenceThresholds] = CalculateROCPoints(varargin)
            %
            % SYNTAX:
            %  [vdROCXVals,vdROCYVals,vdConfidenceThresholds] = CalculateROCPoints(viLabels, vdConfidences, iPositiveLabel)
            %  [vdROCXVals,vdROCYVals,vdConfidenceThresholds] = CalculateROCPoints(oGuessResult)
            %
            % DESCRIPTION:
            %  Calculates the ROC points on both axis and the confidence
            %  thresholds at each point.
            %
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %
            % OUTPUTS ARGUMENTS:
            %  vdROCXVals: A vector of doubles representing x-values of each ROC point
            %  vdROCYVals: A vector of doubles representing y-values of each ROC point
            %  vdConfidenceThresholds: A vector of confidence thresholds at
            %  each ROC point
            
            % Primary Author: Ryan Alfano
            % Created: 09 23, 2019
            
            if nargin == 1
                if ~isa(varargin{1}, 'ClassificationGuessResult')
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The GuessResult object must be a valid object from the GuessResult class.');
                else
                    viLabels = varargin{1}.GetLabels();
                    vdConfidences = varargin{1}.GetPositiveLabelConfidences();
                    iPositiveLabel = varargin{1}.GetPositiveLabel();
                end
            elseif nargin == 3
                if ~iscolumn(varargin{1}) || ~iscolumn(varargin{2}) || ~isa(varargin{1}, 'integer') || ~isa(varargin{2}, 'double')...
                        || ~isa(varargin{3}, 'integer') || ~isscalar(varargin{3})
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The given labels and confidences must be column vectors of type integer and double respectively.  The positive label must be a scalar of type integer.');
                else
                    viLabels = varargin{1};
                    vdConfidences = varargin{2};
                    iPositiveLabel = varargin{3};
                end
            else
                error(...
                    'ErrorMetricsCalculator:InvalidNumParameters',...
                    'See constructor documentation for usage.');
            end
            
            [vdROCXVals,vdROCYVals,vdConfidenceThresholds,~,vdOptimalROCPoints] = perfcurve(double(viLabels),vdConfidences,iPositiveLabel);
        end
        
        function [vdPRROCXVals,vdPRROCYVals,vdConfidenceThresholds] = CalculatePRROCPoints(varargin)
            %[vdROCXVals,vdROCYVals,vdConfidenceThresholds] = CalculatePRROCPoints(varargin)
            %
            % SYNTAX:
            %  [vdROCXVals,vdROCYVals,vdConfidenceThresholds] = CalculatePRROCPoints(viLabels, vdConfidences, iPositiveLabel)
            %  [vdROCXVals,vdROCYVals,vdConfidenceThresholds] = CalculatePRROCPoints(oGuessResult)
            %
            % DESCRIPTION:
            %  Calculates the precision-recall ROC points on both axis and the confidence
            %  thresholds at each point.
            %
            % INPUT ARGUMENTS:
            %  oGuessResult: A valid GuessResult object.
            %  viLabels: A vector of labels.
            %  vdConfidences: A vector of confidences thresholds.
            %  iPositiveLabel: An integer representing the positive label in
            %   the vector of viLabels.
            %
            % OUTPUTS ARGUMENTS:
            %  vdROCXVals: A vector of doubles representing x-values of each precision-recall ROC point
            %  vdROCYVals: A vector of doubles representing y-values of each precision-recall ROC point
            %  vdConfidenceThresholds: A vector of doubles representing the confidence thresholds at
            %  each ROC point
            
            % Primary Author: Ryan Alfano
            % Created: 09 23, 2019
            
            if nargin == 1
                if ~isa(varargin{1}, 'ClassificationGuessResult')
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The GuessResult object must be a valid object from the GuessResult class.');
                else
                    viLabels = varargin{1}.GetLabels();
                    vdConfidences = varargin{1}.GetPositiveLabelConfidences();
                    iPositiveLabel = varargin{1}.GetPositiveLabel();
                end
            elseif nargin == 3
                if ~iscolumn(varargin{1}) || ~iscolumn(varargin{2}) || ~isa(varargin{1}, 'integer') || ~isa(varargin{2}, 'double')...
                        || ~isa(varargin{3}, 'integer') || ~isscalar(varargin{3})
                    error(...
                        'ErrorMetricsCalculator:InvalidInput',...
                        'The given labels and confidences must be column vectors of type integer and double respectively.  The positive label must be a scalar of type integer.');
                else
                    viLabels = varargin{1};
                    vdConfidences = varargin{2};
                    iPositiveLabel = varargin{3};
                end
            else
                error(...
                    'ErrorMetricsCalculator:InvalidNumParameters',...
                    'See constructor documentation for usage.');
            end
            
            [vdPRROCXVals,vdPRROCYVals,vdConfidenceThresholds,~] = perfcurve(double(viLabels),vdConfidences,iPositiveLabel,'XCrit','reca','YCrit','prec');
        end
    end
    
    methods (Access = private, Static = true)
        
        function [viLabels, vdConfidences, iPositiveLabel, vdConfidenceThreshold, bJournalingOn] = ParseInput(varargin)
            bJournalingOn = true; % default
            
            if (nargin == 2 || (nargin == 4 && strcmp(varargin{3}, 'JournalingOn'))) && isa(varargin{1}, 'ClassificationGuessResult')
                ErrorMetricsCalculator.VerifyClassificationGuessResultInput(varargin{1},varargin{2});
                viLabels = varargin{1}.GetLabels();
                vdConfidences = varargin{1}.GetPositiveLabelConfidences();
                iPositiveLabel = varargin{1}.GetPositiveLabel();
                vdConfidenceThreshold = varargin{2};
                
                if nargin == 4
                    bJournalingOn = varargin{4};
                end
            elseif (nargin == 2 || (nargin == 4 && strcmp(varargin{3}, 'JournalingOn'))) && isa(varargin{1}, 'GuessResult')
                oGuessResult = varargin{1};
                vdConfidenceThreshold = varargin{2};
                
                if nargin == 4
                    bJournalingOn = varargin{4};
                end
                
                ValidationUtils.MustBeA(oGuessResult, 'GuessResult');
                MustBeValidForBinaryClassification(oGuessResult);
                
                ValidationUtils.MustBeA(vdConfidenceThreshold, 'double');
                ValidationUtils.MustBeColumnVector(vdConfidenceThreshold);
                mustBeNonnegative(vdConfidenceThreshold);
                mustBeLessThanOrEqual(vdConfidenceThreshold,1);
                                
                viLabels = oGuessResult.GetGroundTruthSampleLabels().GetLabels();
                vdConfidences = oGuessResult.GetGuessResultSampleLabels().GetPositiveLabelConfidences();
                iPositiveLabel = oGuessResult.GetGroundTruthSampleLabels().GetPositiveLabel();
                
            elseif nargin == 4 || (nargin == 6 && strcmp(varargin{5}, 'JournalingOn'))
                ErrorMetricsCalculator.VerifyInput(varargin{1},varargin{2},varargin{3},varargin{4});
                viLabels = varargin{1};
                vdConfidences = varargin{2};
                iPositiveLabel = varargin{3};
                vdConfidenceThreshold = varargin{4};
                
                if nargin == 6
                    bJournalingOn = varargin{6};
                end
            else
                error(...
                    'ErrorMetricsCalculator:ParseInputs:InvalidNumParameters',...
                    'See constructor documentation for usage.');
            end
            
            % validate journaling flag
            ValidationUtils.MustBeScalar(bJournalingOn);
            ValidationUtils.MustBeA(bJournalingOn, 'logical');
        end
        
        function VerifyInput(viLabels,vdConfidences,iPositiveLabel,vdConfidenceThreshold)
            %VerifyInput(viLabels,vdConfidences,iPositiveLabel,vdConfidenceThreshold)
            %
            % SYNTAX:
            %  VerifyInput(viLabels,vdConfidences,iPositiveLabel,vdConfidenceThreshold)
            %
            % DESCRIPTION:
            %  Verifies the inputs to the public functions are of the
            %  correct datatypes.
            %  TODO: Use MATLAB2019b new validation framework and remove
            %  these functions.
            %
            % INPUT ARGUMENTS:
            %  viLabels: vector of ground truth labels
            %  vdConfidences: vector of output confidences from
            %  iPositiveLabel: interger representing the positive label in
            %   the vector of viLabels
            %  vdConfidenceThreshold: double representing the confidence
            %   threshold used for error metric calculation
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            if ~iscolumn(viLabels) || ~iscolumn(vdConfidences) || ~isa(viLabels, 'integer') || ~isa(vdConfidences, 'double')...
                    || ~isa(iPositiveLabel, 'integer') || ~isscalar(iPositiveLabel) || ~isa(vdConfidenceThreshold, 'double')...
                    || ~iscolumn(vdConfidenceThreshold)
                error(...
                    'ErrorMetricsCalculator:InvalidInput',...
                    'The given labels and confidences must be column vectors of type integer and double respectively.  The positive label must be a scalar of type integer.');
            end
        end
        
        function VerifyClassificationGuessResultInput(oGuessResult, vdConfidenceThreshold)
            %VerifyClassificationGuessResultInput(viLabels,vdConfidences,iPositiveLabel,vdConfidenceThreshold)
            %
            % SYNTAX:
            %  VerifyClassificationGuessResultInput(viLabels,vdConfidences,iPositiveLabel,vdConfidenceThreshold)
            %
            % DESCRIPTION:
            %  Verifies the inputs to the public functions are of the
            %  correct datatypes.
            %  TODO: Use MATLAB2019b new validation framework and remove
            %  these functions.
            %
            % INPUT ARGUMENTS:
            %  viLabels: vector of ground truth labels
            %  vdConfidences: vector of output confidences from
            %  iPositiveLabel: interger representing the positive label in
            %   the vector of viLabels
            %  vdConfidenceThreshold: double representing the confidence
            %   threshold used for error metric calculation
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            if ~isa(oGuessResult, 'ClassificationGuessResult') || ~isa(vdConfidenceThreshold, 'double') || ~iscolumn(vdConfidenceThreshold)
                error(...
                    'ErrorMetricsCalculator:InvalidInput',...
                    'The GuessResult object must be a valid object from the GuessResult class. The confidence thresholds must be a column vector of type double.');
            end
        end
        
        function JournalNumericValue(chValueLabel, xValue, bJournalingOn)
            %JournalNumericValue(chValueLabel, xValue, bJournalingOn)
            %
            % SYNTAX:
            %  JournalNumericValue(chValueLabel, xValue, bJournalingOn)
            %
            % DESCRIPTION:
            %  Journals the values into an external text document.
            %
            % INPUT ARGUMENTS:
            %  chValueLabel: characters corresponding to the name of the
            %  value to be journaled
            %  xValue: the output of whatever is to be journaled
            %  bJournalingOn: boolean of whether to journal or not
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            if Experiment.IsRunning() && bJournalingOn
                oParagraph = ReportUtils.CreateParagraphWithBoldLabel(...
                    [chValueLabel, ': '],...
                    num2str(xValue));
                
                Experiment.AddToReport(oParagraph);
            end
        end
    end
end

