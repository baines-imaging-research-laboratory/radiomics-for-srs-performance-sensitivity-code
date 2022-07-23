classdef MATLABfscmrmr < RankingFeatureSelector
    %MATLABfscmrmr
    %
    % MATLAB based maximum relevancy minimum redundancy based feature
    % selector.
    
    
    % Primary Author: David DeVries
    % Created: Nov 23, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        vdFeatureRanking (1,:) double {mustBePositive, mustBeInteger}
        vdFeatureScores (1,:) double
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        dNumberOfFeatures double {ValidationUtils.MustBeEmptyOrScalar(dNumberOfFeatures)}
        c1xMatlabNameValuePairs (1,:) cell
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract)
    end
    
    
    methods (Access = public, Static = false)
        
        function obj = MATLABfscmrmr(chFeatureSelectionParameterFilePath)
            %obj = MATLABfscmrmr()
            %
            % SYNTAX:
            %  obj = MATLABfscmrmr()
            %
            % DESCRIPTION:
            %  Constructor for the MATLAB based maximum releevancy minimum
            %  redundancy based feature selection.
            %
            % INPUT ARGUMENTS:
            %  chFeatureSelectionParameterFilePath: filepath of the feature selection parameters file
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            arguments
                chFeatureSelectionParameterFilePath (1,:) char
            end
            
            % super-class construction
            obj@RankingFeatureSelector(chFeatureSelectionParameterFilePath);
            
            % Load the parameters
            tFeatureSelectionParameters = FileIOUtils.LoadMatFile(...
                chFeatureSelectionParameterFilePath,...
                FeatureSelector.sParametersFileTableVarName);
            
            % Get the parameters
            vsParamNames = tFeatureSelectionParameters.sName;
            c1xParamValues = tFeatureSelectionParameters.c1xValue;
            
            c1xMatlabNameValuePairs = {};
            
            dNumFeatures = missing;
            
            for dParamIndex=1:length(vsParamNames)
                if vsParamNames(dParamIndex) == "NumberOfFeatures"
                    dNumFeatures = c1xParamValues{dParamIndex};
                else
                    if ~ismissing(c1xParamValues{dParamIndex})
                        c1xMatlabNameValuePairs = [c1xMatlabNameValuePairs, {vsParamNames(dParamIndex), c1xValues{dParamIndex}}];
                    end
                end
            end
            
            % validation num features
            dNumFeatures = double(dNumFeatures);
            
            if ~isempty(dNumFeatures) && ~isscalar(dNumFeatures)
                error(...
                    'MATLABfscmrmr:Constructor:InvalidNumberOfFeatures',...
                    'The parameter "NumberOfFeatures" must be empty or a scalar.');
            end
            
            if isscalar(dNumFeatures)
                mustBePositive(dNumFeatures);
                mustBeInteger(dNumFeatures);
                mustBeFinite(dNumFeatures);
            end
            
            % set parameters
            obj.dNumberOfFeatures = dNumFeatures;
            obj.c1xMatlabNameValuePairs = c1xMatlabNameValuePairs;
        end
        
        function newObj = SelectFeatures(obj, oLabelledFeatureValues, NameValueArgs)
            %newObj = SelectFeatures(obj, oLabelledFeatureValues)
            %
            % SYNTAX:
            %  newObj = SelectFeatures(obj, oLabelledFeatureValues,Name, Value)
            %
            % DESCRIPTION:
            %  Performs MATLAB based maxmimum relevancy minimum redundancy
            %  based feature selection.
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Selector object
            %  oLabelledFeatureValues: Feature values object containing all
            %   feature data
            %  NameValueArgs:
            %   'JournalingOn' - (1,1) logical - Flag to turn off
            %    journalling (default: true)
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copy of feature selection object
            
            arguments
                obj (1,1) MATLABfscmrmr
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            [vdRanking, vdScores] = fscmrmr(...
                oLabelledFeatureValues.GetFeatures(),... %"X"
                oLabelledFeatureValues.GetChangedLabels(uint16(1), uint16(0)),..."Y": 1 is positive, 0 is negative
                obj.c1xMatlabNameValuePairs{:});
            
            obj.vdFeatureRanking = vdRanking;
            obj.vdFeatureScores = vdScores;
            
            
            % EXPERIMENT JOURNALING:
            if NameValueArgs.JournalingOn && Experiment.IsRunning()
                Experiment.StartNewSubSection("Feature Selection - MATLAB MRMR Ranking");
                
                [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                
                if bSaveObjects
                    sObjectFilePath = fullfile(Experiment.GetResultsDirectory(), "Journalled Variables.mat");
                    
                    FileIOUtils.SaveMatFile(sObjectFilePath, MATLABfscmrmr.sExperimentJournalingObjVarName, obj);
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToMatFileWithVarNames("Feature selector object saved to: ", sObjectFilePath, "Feature Selector Object", MATLABfscmrmr.sExperimentJournalingObjVarName));
                end
                                
                if bSaveSummaryFiles
                    sSummaryPdfFilePath = fullfile(Experiment.GetResultsDirectory, "Journalled Summary.pdf");
                    
                    oSummaryPdf = ReportUtils.InitializePDF(sSummaryPdfFilePath);
                    
                    oSummaryPdf.add(ReportUtils.CreateParagraphWithBoldLabel("Feature Group Break-Down:",""));
                    oSummaryPdf.add(ReportUtils.CreateParagraph("* - Selected feature from group"));
                    
                    vsFeatureNames = oLabelledFeatureValues.GetFeatureNames();
                    vsFeatureDisplayNames = Feature.GetDisplayNamesFromFeatureNames(vsFeatureNames);
                    
                    dNumFeatures = oLabelledFeatureValues.GetNumberOfFeatures();
                    
                    c2xTable = cell(dNumFeatures,3);
                    
                    for dFeatureIndex=1:dNumFeatures
                        dRankedFeatureIndex = vdRanking(dFeatureIndex);
                        
                        c2xTable{dFeatureIndex,1} = dFeatureIndex;
                        c2xTable{dFeatureIndex,2} = vdScores(dRankedFeatureIndex);
                        c2xTable{dFeatureIndex,3} = vsFeatureDisplayNames(dRankedFeatureIndex);
                    end
                                            
                    oSummaryPdf.add(ReportUtils.CreateTable(cell2table(c2xTable, 'VariableNames', ["Rank", "Score", "Feature Name"])));
                                        
                    oSummaryPdf.close();
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToFile("Feature selection summary saved to: ", sSummaryPdfFilePath));
                end
                
                if bAddEntriesIntoExperimentReport
                    % nothing to add
                end
                
                Experiment.EndCurrentSubSection();
            end
            
            % return copy of feature selector object
            % (since FeatureSelector inherits from handle, this allows for
            % this function to be used as an object from handle would
            % typically be used with no output agruments, or as a typical
            % Matlab object, with using a single output)
            newObj = copy(obj);
        end  
        
        function vbSelectedFeatureMask = GetFeatureMask(obj, NameValueArgs)
            %vbSelectedFeatureMask = GetFeatureMask(obj)
            %
            % SYNTAX:
            %  vbSelectedFeatureMask = GetFeatureMask(obj, Name, Value)
            %
            % DESCRIPTION:
            %  Returns mask of selected features
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %  NameValueArgs:
            %   'NumberOfFeatures' - (1,1) double  - Top 'N' features to
            %   return
            %
            % OUTPUTS ARGUMENTS:
            %  vbSelectedFeatureMask: Binary mask of selected features

            % Primary Author: David Devries
            % Created: Nov 23, 2020
            arguments
                obj (1,1) MATLABfscmrmr {MustHaveCompletedFeatureSelection}
                NameValueArgs.NumberOfFeatures (1,1) double {MustBeValidNumberOfFeatures(obj, NameValueArgs.NumberOfFeatures)} = obj.dNumberOfFeatures
            end
            
            vdTopNFeatures = obj.vdFeatureRanking(1:NameValueArgs.NumberOfFeatures);
            
            vbSelectedFeatureMask = false(1, length(obj.vdFeatureRanking));
            vbSelectedFeatureMask(vdTopNFeatures) = true;
        end
        
        function vdOrderedFeatureMask = GetOrderedFeatureMask(obj, NameValueArgs)
            %vdOrderedSelectedFeatures = GetOrderedFeatureMask(obj)
            %
            % SYNTAX:
            %  vdOrderedSelectedFeatures = GetOrderedFeatureMask(obj, Name, Value)
            %
            % DESCRIPTION:
            %  Returns the resulting ordered selected features which will
            %  illustrates the order at which features were removed/added
            %  during feature selection
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdOrderedSelectedFeatures: resulting ordered selected
            %  features
            
            % Primary Author: David Devries
            % Created: Nov 23, 2020
            arguments
                obj (1,1) MATLABfscmrmr {MustHaveCompletedFeatureSelection}
                NameValueArgs.NumberOfFeatures (1,1) double {MustBeValidNumberOfFeatures(obj, NameValueArgs.NumberOfFeatures)} = obj.dNumberOfFeatures
            end
        
            vdTopNFeatures = obj.vdFeatureRanking(1:NameValueArgs.NumberOfFeatures);
            
            vdOrderedFeatureMask = zeros(1, length(obj.vdFeatureRanking));
            vdOrderedFeatureMask(vdTopNFeatures) = 1:NameValueArgs.NumberOfFeatures;            
        end
        
        function vdRankedFeatureIndices = GetRankedFeatureIndices(obj)
            %vdRankedFeatureIndices = GetRankedFeatureIndices(obj)
            %
            % SYNTAX:
            %  vdRankedFeatureIndices = GetRankedFeatureIndices(obj)
            %
            % DESCRIPTION:
            %  Returns the resulting ranked feature indices.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdRankedFeatureIndices: resulting ranked indices
            
            % Primary Author: David Devries
            % Created: Nov 23, 2020
            arguments
                obj (1,1) MATLABfscmrmr {MustHaveCompletedFeatureSelection}
            end
            
            vdRankedFeatureIndices = obj.vdFeatureRanking;
        end
        
        function vdScorePerFeature = GetScorePerFeature(obj)
            %vdScorePerFeature = GetScorePerFeature(obj)
            %
            % SYNTAX:
            %  vdRankedFeatureIndices = GetScorePerFeature(obj)
            %
            % DESCRIPTION:
            %  Returns the score per feature.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdScorePerFeature: resulting score per feature
            
            % Primary Author: David Devries
            % Created: Nov 23, 2020
            arguments
                obj (1,1) MATLABfscmrmr {MustHaveCompletedFeatureSelection}
            end
            
            vdScorePerFeature = obj.vdFeatureScores;
        end
        
        function dNumFeatures = GetNumberOfFeatures(obj)
            %dNumFeatures = GetNumberOfFeatures(obj)
            %
            % SYNTAX:
            %  dNumFeatures = GetNumberOfFeatures(obj)
            %
            % DESCRIPTION:
            %  Returns the number of features.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumFeatures: resulting number of features.
            
            % Primary Author: David Devries
            % Created: Nov 23, 2020
            dNumFeatures = obj.dNumberOfFeatures;
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
        
        function MustHaveCompletedFeatureSelection(obj)
            %MustHaveCompletedFeatureSelection(obj)
            %
            % SYNTAX:
            %  MustHaveCompletedFeatureSelection(obj)
            %
            % DESCRIPTION:
            %  Checks to ensure that feature selection has completed.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            % Primary Author: David Devries
            % Created: Nov 23, 2020
            if isempty(obj.vdFeatureRanking) || isempty(obj.vdFeatureScores)
                error(...
                    'MATLABfscmrmr:MustHaveCompletedFeatureSelection:Invalid',...
                    'This MATLABfscmrmr object has not completed feature selection yet. Use "obj.SelectFeatures(...)" to do so.');
            end
        end
        
        function MustBeValidNumberOfFeatures(obj, dNumberOfFeatures)
            %MustBeValidNumberOfFeatures(obj, dNumberOfFeatures)
            %
            % SYNTAX:
            %  MustHaveCompletedFeatureSelection(obj, dNumberOfFeatures)
            %
            % DESCRIPTION:
            %  Checks to ensure that there are a valid number of features.
            %
            % INPUT ARGUMENTS:
            %  obj: class object
            %  dNumberOfFeatures: Number of features that will be selected.
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            % Primary Author: David Devries
            % Created: Nov 23, 2020
            
            arguments
                obj (1,1) MATLABfscmrmr
                dNumberOfFeatures (1,1) double {mustBePositive, mustBeInteger}
            end
            
            mustBeLessThanOrEqual(dNumberOfFeatures, length(obj.vdFeatureRanking));
        end
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

