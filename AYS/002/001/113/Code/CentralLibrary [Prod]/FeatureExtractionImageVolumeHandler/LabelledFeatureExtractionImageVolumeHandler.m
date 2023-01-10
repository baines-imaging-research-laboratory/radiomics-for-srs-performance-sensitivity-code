classdef LabelledFeatureExtractionImageVolumeHandler < FeatureExtractionImageVolumeHandler
    %Image
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public) % None
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)         
        % Per Region of Interest/Sample
        viLabels       = []        
        iPositiveLabel = []
        iNegativeLabel = []
    end  
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = LabelledFeatureExtractionImageVolumeHandler(oImageVolume, sImageSource, NameValueArgs)
            %obj = FeatureExtractionImagingSeries(oImageVolume, sImageSource, NameValueArgs)
            %
            % SYNTAX:
            %  obj = FeatureExtractionImagingSeries(oImageVolume, sImageSource, Name, Value)
            %
            %  Name-Value Pairs:
            %   'GroupIds': (Required) Can be either a single integer or a
            %               list of integers. If a single integer is given,
            %               all regions of interest will be given the same
            %               Group ID. If a list is given, it must be the
            %               same length as the number of ROIs for which
            %               features are being extracted. These  Group IDs
            %               will be assigned to their corresponding ROIs
            %   'SubGroupIds': (Optional) Must be a list of integers the
            %                  same length as the number of ROIs. They will
            %                  be assigned to their corresponding ROIs. If
            %                  no value is given, Sub-Group IDs will be
            %                  automatically assigned from 1 to n for each 
            %                  Group ID, where n is the number each Group
            %                  ID appears. 
            %  'UserDefinedSampleStrings': (Optional) This value can either
            %                              be a single string or an array
            %                              of strings. If a single string
            %                              is given, all ROIs will be given
            %                              the same sample string. If an
            %                              array is given, they will be
            %                              applied to each corresponding
            %                              ROI. If no value is given, the
            %                              sample string will be defaulted
            %                              to "X-Y", where X is the
            %                              sample's Group ID, and Y is the
            %                              Sub-Group ID
            % 'SampleOrder':     (Optional) This is a vector of Region of
            %                    Interest numbers (see "RegionsOfInterest")
            %                    that specify in which order the regions of
            %                    interest will have their features
            %                    extracted. This also allows for ROIs
            %                    within the ImageVolume to be excluded from
            %                    having features extracted. **NOTE** This
            %                    vector also determines with
            %                    Group/Sub-Group IDs are linked up with
            %                    each sample. E.g if 'ExtractionOrder' =
            %                    [4,3,1] and 'GroupIds' = [6,7,8], then ROI
            %                    #4 in the ImageVolume object will be
            %                    assigned Group ID 6, ROI #3 will be ID 7,
            %                    and ROI #1 will be ID 8. ROI #2 will not
            %                    be processed.
            %                    If this value is not specified, the
            %                    default behaviour will be to extract
            %                    features for all ROIs within the
            %                    ImageVolume, in order.
            % 'ImageInterpretation': (Optional) Values: '2D' or '3D'
            %                        This allows for image volume with a
            %                        third (slice) dimension of 1 to be
            %                        interpreted as a 2D image (e.g. with a
            %                        thickness of 0). This effects which
            %                        features can be extracted for the
            %                        image volume. **NOTE** Image volumes
            %                        with a third dimensions >1 CAN ONLY be
            %                        interpreted as a 3D image. If the third 
            %                        dimension is 1, the image can be interpretted
            %                        as either 2D or 3D. If no value is
            %                        given the default is to interpret all
            %                        images as 3D.
            % 'Labels': (Required) This is a column vector of integers that
            %           contains the label (positive/negative) for each
            %           region of interest to be processed. The values
            %           within the vector must either be the positive or
            %           negative label provided
            % 'PositiveLabel': (Required) A scalar integer value that
            %                   defines which label within the labels
            %                   values are positive. It cannot be the same
            %                   a the negative label.
            % 'NegativeLabel': (Required) A scalar integer value that
            %                   defines which label within the labels
            %                   values are negative. It cannot be the same
            %                   a the positive label. 
            %                
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %         long wrap it with tabs to align the second line, and
            %         then the third line will automatically be in line
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterest(oImageVolume)}
                sImageSource (1,1) string {mustBeNonempty}
                NameValueArgs.SampleOrder (:,1) double {mustBeInteger, ValidationUtils.MustContainUniqueValues} = []
                NameValueArgs.GroupIds (1,:) {ValidationUtils.MustBeIntegerClass} = int8([])
                NameValueArgs.SubGroupIds (1,:) {ValidationUtils.MustBeIntegerClass} = int8([])
                NameValueArgs.UserDefinedSampleStrings (1,:) string = string([])
                NameValueArgs.ImageInterpretation (1,:) char {mustBeMember(NameValueArgs.ImageInterpretation, {'2D','3D'})} = '3D'
                NameValueArgs.SetRepresentativeFieldsOfView (1,1) logical = true
                NameValueArgs.Labels (:,1) {ValidationUtils.MustBeIntegerClass}
                NameValueArgs.PositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass}
                NameValueArgs.NegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass}
            end
            
            % Parse in name value pairs
            if ~isfield(NameValueArgs, 'Labels') || ~isfield(NameValueArgs, 'PositiveLabel') || ~isfield(NameValueArgs, 'NegativeLabel')
                error(...
                    'LabelledFeatureExtractionImageVolumeHandler:Constructor:MissingNameValueArgs',...
                    'The name-value pairs ''Labels'', ''PositiveLabel'', and ''NegativeLabel'' must be provided.');
            end
                        
            viLabels = NameValueArgs.Labels;
            iPositiveLabel = NameValueArgs.PositiveLabel;
            iNegativeLabel = NameValueArgs.NegativeLabel;
                        
            % Superclass constructor call
            stSuperclassNameValueArgs = rmfield(NameValueArgs, ["Labels", "PositiveLabel", "NegativeLabel"]);            
            c1xSuperclassNameValueArgs = namedargs2cell(stSuperclassNameValueArgs);
            
            obj@FeatureExtractionImageVolumeHandler(oImageVolume, sImageSource, c1xSuperclassNameValueArgs{:});
                        
            if isempty(oImageVolume) && isempty(sImageSource)
                
            else
                % Validation
                dNumRois = obj.GetNumberOfRegionsOfInterest();
                
                LabelledFeatureExtractionImageVolumeHandler.ValidatePositiveAndNegativeLabels(iPositiveLabel, iNegativeLabel);
                LabelledFeatureExtractionImageVolumeHandler.ValidateLabels(viLabels, iPositiveLabel, iNegativeLabel, dNumRois);
                
                % Set Properities
                obj.viLabels = viLabels;
                obj.iPositiveLabel = iPositiveLabel;
                obj.iNegativeLabel = iNegativeLabel;
            end
        end 
       
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function iPositiveLabel = GetPositiveLabel(obj)
            iPositiveLabel = obj.iPositiveLabel;
        end  
                
        function iNegativeLabel = GetNegativeLabel(obj)
            iNegativeLabel = obj.iNegativeLabel;
        end       
        
        function viLabels = GetRegionsOfInterestLabels(obj)
            viLabels = obj.viLabels;
        end


    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    
    methods (Access = protected)
        
% % % %         function saveObj = saveobj(obj)
% % % %             % super-class call
% % % %             saveObj = saveobj@FeatureExtractionImageVolumeHandler(obj);
% % % %         end
                
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@FeatureExtractionImageVolumeHandler(obj);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private) % None
    end        
    
    
    methods (Access = private, Static = true)
                
        function ValidatePositiveAndNegativeLabels(iPositiveLabel, iNegativeLabel)
            LabelledFeatureValues.ValidatePositiveAndNegativeLabels(iPositiveLabel, iNegativeLabel);
        end
        
        function ValidateLabels(viLabels, iPositiveLabel, iNegativeLabel, dNumRois)
            m2dSpoofedFeatures = zeros(dNumRois,1);
            
            LabelledFeatureValues.ValidateLabels(viLabels, m2dSpoofedFeatures, iPositiveLabel, iNegativeLabel)            
        end
    end 
    
    
    methods (Access = {?Feature}, Static = true)
                    
        function viLabels = GetLabelsForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                viLabels = [];
            else
                viMasterLabels = voImageVolumeHandlers(1).viLabels;
                
                if isempty(viMasterLabels)
                    for dImageIndex = 1:length(voImageVolumeHandlers)
                        if ~isempty(voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestLabels())
                            error(...
                                'LabelledFeatureExtractionImageVolumeHandler:GetLabelsForImagesAndROIs:NotEmpty',...
                                'All images must either all define labels or all not define labels.');
                        end
                    end
                    
                    viLabels = [];
                else
                    chMasterLabelsClass = class(viMasterLabels);
                    
                    viLabels = zeros(dNumTotalRois, 1, chMasterLabelsClass);
                    
                    dInsertIndex = 1;
                    
                    for dImageIndex = 1:length(voImageVolumeHandlers)
                        viNextLabels = voImageVolumeHandlers(dImageIndex).GetRegionsOfInterestLabels();
                        
                        if ~isempty(viNextLabels) && isa(viNextLabels, chMasterLabelsClass)
                            dNumToInsert = length(viNextLabels);
                            
                            viLabels(dInsertIndex : dInsertIndex + dNumToInsert - 1) = viNextLabels;
                            dInsertIndex = dInsertIndex + dNumToInsert;
                        else
                            error(...
                                'LabelledFeatureExtractionImageVolumeHandler:GetPositiveLabelForImageVolumeHandlers:InvalidValue',...
                                'All labels across images and ROIs must be of the same class and non-empty.');
                        end
                    end
                end
            end
        end
        
        function iPositiveLabel = GetPositiveLabelForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                iPositiveLabel = [];
            else
                iMasterPositiveLabel = voImageVolumeHandlers(1).iPositiveLabel;                
                chMasterPositiveLabelClass = class(iMasterPositiveLabel);
                
                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    iNextPositiveLabel = voImageVolumeHandlers(dImageIndex).iPositiveLabel;
                    
                    if isempty(iNextPositiveLabel) || ~isa(iNextPositiveLabel, chMasterPositiveLabelClass) || iNextPositiveLabel ~= iMasterPositiveLabel
                        error(...
                            'LabelledFeatureExtractionImageVolumeHandler:GetPositiveLabelForImageVolumeHandlers:InvalidValue',...
                            'All positive labels across images and ROIs must be of the same class and value.');
                    end
                end
                
                iPositiveLabel = iMasterPositiveLabel;
            end
        end
        
        function iNegativeLabel = GetNegativeLabelForImageVolumeHandlers(voImageVolumeHandlers)
            dNumTotalRois = FeatureExtractionImageVolumeHandler.GetNumberOfRegionsOfInterestForImageVolumeHandlers(voImageVolumeHandlers);
            
            if dNumTotalRois == 0
                iNegativeLabel = [];
            else                
                iMasterNegativeLabel = voImageVolumeHandlers(1).iNegativeLabel;  
                chMasterNegativeLabelClass = class(iMasterNegativeLabel);
                                
                for dImageIndex = 1:length(voImageVolumeHandlers)
                    iNextNegativeLabel = voImageVolumeHandlers(dImageIndex).iNegativeLabel;
                    
                    if isempty(iNextNegativeLabel) || ~isa(iNextNegativeLabel, chMasterNegativeLabelClass) || iNextNegativeLabel ~= iMasterNegativeLabel
                        error(...
                            'LabelledFeatureExtractionImageVolumeHandler:GetNegativeLabelForImageVolumeHandlers:InvalidValue',...
                            'All negative labels across images and ROIs must be of the same class and value.');
                    end
                end
                
                iNegativeLabel = iMasterNegativeLabel;
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