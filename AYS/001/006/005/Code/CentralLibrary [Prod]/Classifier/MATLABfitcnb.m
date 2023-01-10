classdef MATLABfitcnb < MATLABClassifier & ClassifierWithHyperParameterConstraintFunctions
    %MATLABfitcnb
    %
    % MATLAB Naive Bayes Classifier is an concrete class that uses MATLAB's built-in classifier to
    % create a machine learning model. See documentation here:
    % https://www.mathworks.com/help/stats/fitcnb.html
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        sName = "MATLAB Naive Bayes Classifier";
        hClassifier = @fitcnb;
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods  (Static = false)
        
        function obj = MATLABfitcnb(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, NameValueArgs)
            %obj = MATLABfitcnb(xClassifierHyperParametersFileNameOrHyperParametersTable, NameValueArgs)
            %
            % SYNTAX:
            %  obj = MATLABfitcnb(chClassifierHyperParametersFileName)
            %  obj = MATLABfitcnb(tHyperParameters)
            %  obj = MATLABfitcnb(__, oHyperParameterOptimizer)
            %
            % DESCRIPTION:
            %  Constructor for MATLABfitcnb
            %
            % INPUT ARGUMENTS:
            %  chClassifierHyperParametersFileName This is a .mat file containing all the
            %       hyperparameter information.
            %       A default settings mat file for this classifier is found under:
            %       BOLT > DefaultInputs > Classifier
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: Salma Dammak
            % Created: Feb 31, 2019
            arguments
                xClassifierHyperParametersFileNameOrHyperParametersTable
                % This can be any concrete class inheriting from HyperParameterOptimizer since it
                % won't be used anywhere but to pass an object that can be checked by the parent
                % class which checks for the abstract parent class
                oHyperParameterOptimizer = MATLABMachineLearningHyperParameterOptimizer.empty
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            % Call MATLABClassifier constructor
            c1xVarargin = namedargs2cell(NameValueArgs);
            obj@MATLABClassifier(xClassifierHyperParametersFileNameOrHyperParametersTable, oHyperParameterOptimizer, c1xVarargin{:});
            
            % ClassifierWithHyperParameterConstraintFunctions super-class
            % call
            obj@ClassifierWithHyperParameterConstraintFunctions(xClassifierHyperParametersFileNameOrHyperParametersTable);
        end
        
        function obj = Train(obj, oLabelledFeatureValues, NameValueArgs)
            %oTrainedClassifier = Train(obj,oLabelledFeatureValues)
            %
            % SYNTAX:
            % oTrainedClassifier = Train(oClassifier,oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Calls the superclass train, catch a fitcnb-specific error, and attempts a fix. 
            %  fitcnb default feature distributions are set to 'normal' and if tit's given a feature 
            %  distribution that is constant across labels or within either of them, it errors out
            %  as fitcnb attempts to fit a normal distribution to the features and a constant
            %  feature would make it fail that. To avoid loosing important information as much as
            %  possible, we first remove features that are constant across labels, and hence
            %  useless, and if that doesn't work, then we remove features that are constant within
            %  labels which is suboptimal but better than erroring. Note that if all features passed 
            %  are constant, this function will error as it will attempt to remove all features. 
            %
            % INPUT ARGUMENTS:
            %  oClassifier: A classifier object
            %  oLabelledFeatureValues: This is a labeled feature values object (class in this
            %           library) that contains information about the features and the feature values
            %           themselves. This must only contain the training samples.
            %
            % OUTPUTS ARGUMENTS:
            %  oTrainedClassifier: input classifier object modified to hold a TrainedClassifier
            %           property that represents the trained model. This is necessary for Guess to
            %           work.
            
            % Primary Author: Salma Dammak
            % Created: 5 October, 2020
            
            arguments
                obj
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
			c1xVarargin = namedargs2cell(NameValueArgs);
			
            % Original (zero-eth) try of train
            try
                obj = Train@MATLABClassifier(obj, oLabelledFeatureValues, c1xVarargin{:});
                
            catch oFirstLevelError
                % We're only concerned with the exception thrown due to features with zero variance
                if strcmp(oFirstLevelError.identifier , 'stats:ClassificationNaiveBayes:ClassificationNaiveBayes:ZeroVarianceForUniFit')
                    
                    oLabelledFeatureValues = oLabelledFeatureValues.PerturbeValuesByMinisculeAmount(10^-10);
                    
                    obj = Train@MATLABClassifier(obj, oLabelledFeatureValues, c1xVarargin{:});
                    
% %                     % First try removing features that are constant across both labels (useless
% %                     % features)
% %                     warning('off',"FeatureValues:RemoveConstantFeatures:NoneRemoved")
% %                     [oLabelledFeatureValues, vsRemovedFeatures, ~]...
% %                         = RemoveFeaturesWithZeroVariance(oLabelledFeatureValues);
% %                     
% %                     % Try training again
% %                     try
% %                         obj = Train@MATLABClassifier(obj, oLabelledFeatureValues, c1xVarargin{:});
% %                         
% %                         % The if statement below only runs if the training doesn't throw an
% %                         % exception and that's why it's placed here as opposed to outside the
% %                         % try-catch block), since the error message is different if the training
% %                         % throws an exception again.
% %                         if ~isempty(vsRemovedFeatures)
% %                             warning("MATLABfitcnb:Train:FeaturesConstantAcrossLabelsRemoved",...
% %                                 "Some features were constant across both labels, and were removed, "     +...
% %                                 "as that causes fitcnb to throw an exception. The removed features are: "+...
% %                                 + newline +...
% %                                 vsRemovedFeatures);
% %                         end
% %                         
% %                     catch oSecondLevelError
% %                         if strcmp(oSecondLevelError.identifier , 'stats:ClassificationNaiveBayes:ClassificationNaiveBayes:ZeroVarianceForUniFit')
% %                             
% %                             % Second, try the more drastic measure of removing any features that are
% %                             % constant in either classes.
% %                             warning('off',"LabelledFeatureValues:RemoveFeaturesWithZeroVarianceWithinAnyLabel:ThisIsABadIdeaUnlessYouKnowWhatYouAreDoing")
% %                             warning('off',"LabelledFeatureValues:RemoveFeaturesWithZeroVarianceWithinAnyLabel:NoneRemoved")
% %                             [oLabelledFeatureValues, vsRemovedFeatures, ~]...
% %                                 = RemoveFeaturesWithZeroVarianceWithinAnyLabel(oLabelledFeatureValues);
% %                             
% %                             % Try training again
% %                             obj = Train@MATLABClassifier(obj, oLabelledFeatureValues, c1xVarargin{:});
% %                             
% %                             % If the training does go through, an error message letting the user
% %                             % know what happened is thrown
% %                             if ~isempty(vsRemovedFeatures)
% %                                 warning("MATLABfitcnb:Train:FeaturesConstantWithinLabelsRemoved",...
% %                                     "Some features have zero variance within one or both of the classes and "+...
% %                                     "were removed to avoid causing fitcnb to throw an error. This error "+...
% %                                     "happens when using fitcnb with normal distribution specified for a feature "+...
% %                                     "that is in fact constant for either or both labels. Removal of a contant "+...
% %                                     "feature within a class can lead to loss of valuable information. To prevent  "+...
% %                                     "this removal behaviour, set the distribution name to something else "+...
% %                                     "for the constant feature(s)."+...
% %                                     "The removed features are: "+...
% %                                     + newline +...
% %                                     vsRemovedFeatures);
% %                             end
% %                         else
% %                             % If the error is something else entirely, re-throw it
% %                             rethrow(oSecondLevelError)
% %                         end
% %                     end
                    
                else
                    % If the error is something else entirely, re-throw it
                    rethrow(oFirstLevelError)
                end
                
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ClassifierWithHyperParameterConstraintFunctions, ?MATLABBayesianHyperParameterOptimizer})
        
        function fn = GetConditionalVariableFcn(obj)
            fn = @MATLABfitcnbCVF;
            
            function XTable = MATLABfitcnbCVF(XTable)
                % adapted from:
                % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCNB.m
                
                vsVariableNames = string(XTable.Properties.VariableNames);
                
                % Kernel and Width are only relevant when DistributionNames is 'kernel'
                if any(vsVariableNames == "DistributionNames") && any(vsVariableNames == "Kernel")
                    XTable.Kernel(XTable.DistributionNames ~= 'kernel') = '<undefined>';
                end
                
                if any(vsVariableNames == "DistributionNames") && any(vsVariableNames == "Width")
                    XTable.Width(XTable.DistributionNames ~= 'kernel') = NaN;
                end
            end
        end
        
        function fn = GetXConstraintFcn(obj)
            % not found in:
            % C:\Program Files\MATLAB\R2019b\toolbox\stats\classreg\+classreg\+learning\+paramoptim\BayesoptInfoCNB.m
            
            fn = function_handle.empty;
        end
    end
end