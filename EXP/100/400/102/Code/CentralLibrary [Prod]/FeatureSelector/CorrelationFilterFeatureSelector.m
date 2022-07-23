classdef CorrelationFilterFeatureSelector < FilterFeatureSelector
    %CorrelationFilterFeatureSelector
    %
    % Class for correlation based feature selection. 
    
    
    % Primary Author: David DeVries
    % Created: Sept 10, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        vdGroupNumberPerFeature (1,:) double
        
        m2dPreSelectionCorrelationMatrix (:,:) double
        m2dPostSelectionCorrelationMatrix (:,:) double
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        dCutoff (1,1) double {mustBeNonnegative, mustBeLessThan(dCutoff,1)}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract)
    end
    
    
    methods (Access = public, Static = false)
        
        function obj = CorrelationFilterFeatureSelector(chFeatureSelectionParameterFilePath)
            %obj = CorrelationFilterFeatureSelector()
            %
            % SYNTAX:
            %  obj = CorrelationFilterFeatureSelector()
            %
            % DESCRIPTION:
            %  Constructor for correlation filter feature selection
            %
            % INPUT ARGUMENTS:
            %  chFeatureSelectionParameterFilePath: filepath of the
            %  feature selection parameters file
            %
            % OUTPUTS ARGUMENTS:
            %  -
            
            % Primary Author: David Devries
            % Created: Sept 10, 2020
            obj@FilterFeatureSelector(chFeatureSelectionParameterFilePath);
            
            % Load the parameters
            [tFeatureSelectionParameters] = FileIOUtils.LoadMatFile(...
                chFeatureSelectionParameterFilePath,...
                'tFeatureSelectionParameters');
            
            % Error check for necessary parameters
            obj.dCutoff = FeatureSelector.ExtractFeatureSelectionParameter(tFeatureSelectionParameters, "Cutoff");
        end
        
        function newObj = SelectFeatures(obj, oLabelledFeatureValues, NameValueArgs)
            %newObj = SelectFeatures(obj, oLabelledFeatureValues)
            %
            % SYNTAX:
            %  newObj = SelectFeatures(obj, oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Performs a correlation analysis for each feature in the dataset
            %  for the two classes
            %
            % INPUT ARGUMENTS:
            %  obj: Feature Selector object
            %  oLabelledFeatureValues: Feature values object containing all
            %   feature data
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copy of the feature selection object
            
            arguments
                obj (1,1) CorrelationFilterFeatureSelector
                oLabelledFeatureValues (:,:) LabelledFeatureValues
                NameValueArgs.JournalingOn (1,1) logical = true
            end
            
            % create correlation matrix for all feature pairs
            dNumFeatures = oLabelledFeatureValues.GetNumberOfFeatures();
            
            m2dFeatures = oLabelledFeatureValues.GetFeatures();
            m2dPreSelectionCorrelationMatrix = corr(m2dFeatures);
            m2dPreSelectionCorrelationMatrix = m2dPreSelectionCorrelationMatrix.^2; % get R^2
                        
            % create dissimilarity matrix
            m2dDissimilarityMatrix = 1-abs(m2dPreSelectionCorrelationMatrix);
            
            vdDissimilarityMatrixVector = zeros(1, dNumFeatures * (dNumFeatures-1) / 2);
            
            dInsertIndex = 1;
            
            for dFeatureIndex=1:dNumFeatures-1
                vdToInsert = m2dDissimilarityMatrix(dFeatureIndex, dFeatureIndex + 1 : end);
                
                dNumToInsert = length(vdToInsert);
                
                vdDissimilarityMatrixVector(dInsertIndex : dInsertIndex + dNumToInsert - 1) = vdToInsert;
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
            
            % use hierarchical clustering to group the features into
            % correlated groups
            m2dLinkages = linkage(vdDissimilarityMatrixVector, 'complete');

            vdGroups = cluster(m2dLinkages, 'cutoff', 1-obj.dCutoff, 'criterion', 'distance'); % use 1-cutoff, since we're using dissimiliarity
            
            dNumGroups = max(vdGroups);
            
            % we know have the group that each feature is in. Now we need
            % to choose which feature from the group to select to keep.
            % We'll choose the feature that is best correlated with the
            % labels
            
            vbSelectedFeatureMask = false(1,dNumFeatures);
            
            vdLabels = double(oLabelledFeatureValues.GetChangedLabels(uint8(-1),uint8(1)));
            
            for dGroupIndex=1:dNumGroups
                vdGroupFeatureIndices = find(vdGroups == dGroupIndex);
                
                dNumFeaturesInGroup = length(vdGroupFeatureIndices);
                
                vdCorrelationOfFeaturesToLabels = zeros(1,dNumFeaturesInGroup);
                
                for dFeatureIndex=1:dNumFeaturesInGroup
                    vdFeatureValues = m2dFeatures(:,vdGroupFeatureIndices(dFeatureIndex));
                    
                    vdCorrelationOfFeaturesToLabels(dFeatureIndex) = corr(vdFeatureValues, vdLabels);
                end
                
                [~, dMaxIndex] = max(abs(vdCorrelationOfFeaturesToLabels));
                vbSelectedFeatureMask(vdGroupFeatureIndices(dMaxIndex)) = true;
            end
            
            % calculate correlation matrix for post feature selection
            m2dPostSelectionCorrelationMatrix = corr(m2dFeatures(:, vbSelectedFeatureMask));
            m2dPostSelectionCorrelationMatrix = m2dPostSelectionCorrelationMatrix.^2; % get R^2
            
            % set properities
            obj.vbSelectedFeatureMask = logical(vbSelectedFeatureMask);
            obj.vdGroupNumberPerFeature = vdGroups';
            
            obj.m2dPreSelectionCorrelationMatrix = m2dPreSelectionCorrelationMatrix;
            obj.m2dPostSelectionCorrelationMatrix = m2dPostSelectionCorrelationMatrix ;
            
            % EXPERIMENT JOURNALING:
            if NameValueArgs.JournalingOn && Experiment.IsRunning()
                Experiment.StartNewSubSection("Feature Selection - Correlation Filter");
                
                [bAddEntriesIntoExperimentReport, bSaveObjects, bSaveSummaryFiles] = Experiment.GetJournalingSettings();
                
                if bSaveObjects
                    sObjectFilePath = fullfile(Experiment.GetResultsDirectory(), "Journalled Variables.mat");
                    
                    FileIOUtils.SaveMatFile(sObjectFilePath, CorrelationFilterFeatureSelector.sExperimentJournalingObjVarName, obj);
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToMatFileWithVarNames("Feature selector object saved to: ", sObjectFilePath, "Feature Selector Object", CorrelationFilterFeatureSelector.sExperimentJournalingObjVarName));
                end
                
                if bSaveSummaryFiles || bAddEntriesIntoExperimentReport
                    % pre-selection correlation matrix                    
                    hFig = figure();
                    imshow(abs(m2dPreSelectionCorrelationMatrix), [0,1], 'InitialMagnification', 'fit');
                    
                    sPreSelectionCorrelationMatrixFilePath = fullfile(Experiment.GetResultsDirectory, "Pre-Filtering Feature Correlation Matrix.fig");
                    savefig(hFig, sPreSelectionCorrelationMatrixFilePath);
                    delete(hFig);
                    
                    % post-selection correlation matrix
                    hFig = figure();
                    imshow(abs(m2dPostSelectionCorrelationMatrix), [0,1], 'InitialMagnification', 'fit');
                    
                    sPostSelectionCorrelationMatrixFilePath = fullfile(Experiment.GetResultsDirectory(), "Post-Filtering Feature Correlation Matrix.fig");
                    savefig(hFig, sPostSelectionCorrelationMatrixFilePath);
                    delete(hFig);
                                        
                    c1oCommonReportAssets = {...
                        ReportUtils.CreateParagraphWithBoldLabel('Alpha: ', num2str(obj.dCutoff)),...
                        ReportUtils.CreateParagraphWithBoldLabel('Pre-Selection Correlation Matrix:',''),...
                        ReportUtils.CreateParagraph([num2str(dNumFeatures), ' Features']),...
                        sPreSelectionCorrelationMatrixFilePath,...
                        ReportUtils.CreateParagraphWithBoldLabel('Post-Selection Correlation Matrix:',''),...
                        ReportUtils.CreateParagraph([num2str(dNumGroups), ' Selected Features']),...
                        sPostSelectionCorrelationMatrixFilePath};                        
                end
                
                if bSaveSummaryFiles
                    sSummaryPdfFilePath = fullfile(Experiment.GetResultsDirectory, "Journalled Summary.pdf");
                    
                    oSummaryPdf = ReportUtils.InitializePDF(sSummaryPdfFilePath);
                    
                    oSummaryPdf.add(ReportUtils.CreateParagraphWithBoldLabel("Feature Group Break-Down:",""));
                    oSummaryPdf.add(ReportUtils.CreateParagraph("* - Selected feature from group"));
                    
                    vsFeatureNames = oLabelledFeatureValues.GetFeatureNames();
                    vsFeatureDisplayNames = Feature.GetDisplayNamesFromFeatureNames(vsFeatureNames);
                    
                    for dGroupIndex=1:dNumGroups
                        vdGroupFeatureIndices = find(vdGroups == dGroupIndex);
                        
                        dNumFeaturesInGroup = length(vdGroupFeatureIndices);
                        
                        oSummaryPdf.add(ReportUtils.CreateParagraphWithBoldLabel(['Feature Group ', StringUtils.num2str_PadWithZeros(dGroupIndex, length(num2str(dNumGroups)))], [' (', num2str(dNumFeaturesInGroup), ' Features)']));
                        
                        c2FeatureGroupTableValues = cell(dNumFeaturesInGroup,2);
                        
                        for dFeatureIndex=1:dNumFeaturesInGroup
                            c2FeatureGroupTableValues{dFeatureIndex,1} = vsFeatureNames(vdGroupFeatureIndices(dFeatureIndex));
                            c2FeatureGroupTableValues{dFeatureIndex,2} = vsFeatureDisplayNames(vdGroupFeatureIndices(dFeatureIndex));
                            
                            if vbSelectedFeatureMask(vdGroupFeatureIndices(dFeatureIndex))
                                c2FeatureGroupTableValues{dFeatureIndex,1} = "*" + c2FeatureGroupTableValues{dFeatureIndex,1};
                            end
                        end
                        
                        oSummaryPdf.add(ReportUtils.CreateTable(cell2table(c2FeatureGroupTableValues, 'VariableNames', ["Features In Group", "Full Feature Names"])));
                    end
                    
                    oSummaryPdf.close();
                    
                    Experiment.AddToReport(ReportUtils.CreateLinkToFile("Feature selection summary saved to: ", sSummaryPdfFilePath));
                end
                
                if bAddEntriesIntoExperimentReport
                    for dAssetIndex=1:length(c1oCommonReportAssets)
                        Experiment.AddToReport(c1oCommonReportAssets{dAssetIndex});
                    end
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

