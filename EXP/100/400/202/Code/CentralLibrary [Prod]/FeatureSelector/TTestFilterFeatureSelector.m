classdef TTestFilterFeatureSelector < FilterFeatureSelector
    %TTestFilterFeatureSelector
    %
    % Class for t-test filter based feature selection method
    
    
    % Primary Author: Ryan Alfano
    % Created: 03, 13 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        dAlpha (1,1) double
    end
    
    properties (SetAccess = private, GetAccess = public)
        vdPValues (1,:) double
    end
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = false)
        
        function obj = TTestFilterFeatureSelector(chFeatureSelectionParameterFilePath)
            %obj = TTestFilterFeatureSelector()
            %
            % SYNTAX:
            %  obj = TTestFilterFeatureSelector()
            %
            % DESCRIPTION:
            %  Constructor for t-test filter feature selection
            %
            % INPUT ARGUMENTS:
            %  chFeatureSelectionParameterFilePath: filepath of the
            %  feature selection parameters file
            %
            % OUTPUTS ARGUMENTS:
            %  -

            % Primary Author: Ryan Alfano
            % Created: 03 13, 2019
            obj@FilterFeatureSelector(chFeatureSelectionParameterFilePath);
            
            % Load the parameters
            [tFeatureSelectionParameters] = FileIOUtils.LoadMatFile(...
                chFeatureSelectionParameterFilePath,...
                'tFeatureSelectionParameters');
            
            % Error check for necessary parameters
            obj.dAlpha = FeatureSelector.ExtractFeatureSelectionParameter(tFeatureSelectionParameters, "Alpha");
        end
        
        function newObj = SelectFeatures(obj, oLabelledFeatureValues)
            %newObj = SelectFeatures(obj, oLabelledFeatureValues)
            %
            % SYNTAX:
            %  newObj = SelectFeatures(obj, oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Performs a t-test on each independant feature in the dataset
            %  for the two classes. If the data is non-normal or the
            %  variances are not equal, then a non-parametric test is used
            %  instead. Data marked as categorical will undergo a
            %  Chi-Squared test for statistical significance.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Selector object
            %  oLabelledFeatureValues: Feature values object containing all
            %   feature data
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copy of feature selection object.

            % Primary Author: Ryan Alfano
            % Created: 03 15, 2019
            
            % Extract the necessary data
            vbSelectedFeatureMask = zeros(1,oLabelledFeatureValues.GetNumberOfFeatures());
            vdPValues = zeros(1,oLabelledFeatureValues.GetNumberOfFeatures());
            
            % Extract which features are categorical
            vbCategoricalFeatures = oLabelledFeatureValues.IsFeatureCategorical;
            
            % Loop across all features that are in the dataset
            for dNumFeature = 1:oLabelledFeatureValues.GetNumberOfFeatures()
                oCurrentLabelledFeatureValues = oLabelledFeatureValues(:,dNumFeature);
                
                % Check if the feature is categorical
                if vbCategoricalFeatures(dNumFeature)
                    % Calculate the p-value from the Chi-square statistic
                    [~,~,dPValue,~] = crosstab(oCurrentLabelledFeatureValues.GetFeatures,oCurrentLabelledFeatureValues.GetLabels);
                    
                    % Store the p-value in the vector
                    vdPValues(dNumFeature) = dPValue;
                    
                    % Check if the test passes
                    if dPValue < obj.dAlpha
                        vbSelectedFeatureMask(dNumFeature) = logical(1);
                    else
                        vbSelectedFeatureMask(dNumFeature) = logical(0);
                    end
                else
                    % Allocate array sizes
                    dPosCount = 0;
                    dNegCount = 0;

                    for dFeatureRow = 1:oCurrentLabelledFeatureValues.GetNumberOfSamples()
                        oIndexedLabelledFeatureValuesObject = oCurrentLabelledFeatureValues(dFeatureRow,:);

                        if oIndexedLabelledFeatureValuesObject.GetLabels() == oCurrentLabelledFeatureValues.GetPositiveLabel() 
                            dPosCount = dPosCount + 1;
                        else
                            dNegCount = dNegCount + 1;
                        end
                    end

                    vdPositiveLabelledFeatures = zeros(1,dPosCount);
                    vdNegativeLabelledFeatures = zeros(1,dNegCount);

                    % Sort features that have a positive label into one vector and
                    % negative into another
                    dPosIndex = 1;
                    dNegIndex = 1;

                    for dFeatureRow = 1:oLabelledFeatureValues.GetNumberOfSamples()
                        oIndexedLabelledFeatureValuesObject = oCurrentLabelledFeatureValues(dFeatureRow,:);

                        if oIndexedLabelledFeatureValuesObject.GetLabels() == oCurrentLabelledFeatureValues.GetPositiveLabel()
                            vdPositiveLabelledFeatures(1,dPosIndex) = oIndexedLabelledFeatureValuesObject.GetFeatures();
                            dPosIndex = dPosIndex + 1;
                        else
                            vdNegativeLabelledFeatures(1,dNegIndex) = oIndexedLabelledFeatureValuesObject.GetFeatures();
                            dNegIndex = dNegIndex + 1;
                        end
                    end

                    % Check for normality (1 - reject null hypothesis that they
                    % come from a normal distribution)

                    bPosNotNormal = adtest(vdPositiveLabelledFeatures);
                    bNegNotNormal = adtest(vdNegativeLabelledFeatures);

                    % Levene's test for equality of variance
                    dVarPVal = vartestn(oCurrentLabelledFeatureValues.GetFeatures(),oCurrentLabelledFeatureValues.GetLabels(),'Display','off');

                    % Parametric vs. Non-parametric t-test
                    if (bPosNotNormal || bNegNotNormal)
                        [dPValue,bTestPass] = ranksum(vdPositiveLabelledFeatures,vdNegativeLabelledFeatures,'alpha',obj.dAlpha);
                        
                        % Store the p-value in the vector
                        vdPValues(dNumFeature) = dPValue;
                    else
                        if dVarPVal <= obj.dAlpha
                            [bTestPass,dPValue] = ttest2(vdPositiveLabelledFeatures,vdNegativeLabelledFeatures,'Alpha',obj.dAlpha,'Vartype','unequal'); 
                            
                            % Store the p-value in the vector
                            vdPValues(dNumFeature) = dPValue;
                        else
                            [bTestPass,dPValue] = ttest2(vdPositiveLabelledFeatures,vdNegativeLabelledFeatures,'Alpha',obj.dAlpha);
                            
                            % Store the p-value in the vector
                            vdPValues(dNumFeature) = dPValue;
                        end
                    end

                    vbSelectedFeatureMask(dNumFeature) = bTestPass;
                end
            end
            
            
            obj.vbSelectedFeatureMask = logical(vbSelectedFeatureMask);
            obj.vdPValues = vdPValues;
            
            % return copy of feature selector object
            % (since FeatureSelector inherits from handle, this allows for
            % this function to be used as an object from handle would
            % typically be used with no output agruments, or as a typical
            % Matlab object, with using a single output)
            newObj = copy(obj);
        end
        
        function vdPValues = GetPValuesForFeatures(obj)
            %vdPValues = GetPValuesForFeatures(obj)
            %
            % SYNTAX:
            %  vdPValues = GetPValuesForFeatures(obj)
            %
            % DESCRIPTION:
            %  Returns the p-values for the statistical tests of each
            %  feature.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdPValues: vector of p-values
            
            % Primary Author: Ryan Alfano
            % Created: 02 11, 2021
            vdPValues = obj.vdPValues;
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
    end
    
    
    methods (Access = protected, Static = true)        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)
        
    end
    
    
    methods (Access = private, Static = true)        
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

