classdef LabelledImageVolumeHandler < ImageVolumeHandler
    %LabelledImageVolumeHandler
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public) % None
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)         
        oSampleLabels (:,1) SampleLabels = BinaryClassificationSampleLabels(int8(1),int8(0),int8(1)) % TODO: what a hack...please figure out the "empty" for these
    end  
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = LabelledImageVolumeHandler(oImageVolume, sImageSource, oSampleLabels, varargin)
            %obj = LabelledImageVolumeHandler(oImageVolume, sImageSource, oSampleLabels, varargin)
            %
            % SYNTAX:
            %  obj = FeatureExtractionImagingSeries(oImageVolume, sImageSource, oSampleLabels, Name, Value)
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
            % 'SampleOrder': (Optional) This is a vector of Region of
            %                    Interest numbers (see "RegionsOfInterest")
            %                    that specify in which order the regions of
            %                    interest will have their features
            %                    extracted. This also allows for ROIs
            %                    within the ImageVolume to be excluded from
            %                    having features extracted. **NOTE** This
            %                    vector also determines with
            %                    Group/Sub-Group IDs are linked up with
            %                    each sample. E.g if 'SampleOrder' =
            %                    [4,3,1] and 'GroupIds' = [6,7,8], then ROI
            %                    #4 in the ImageVolume object will be
            %                    assigned Group ID 6, ROI #3 will be ID 7,
            %                    and ROI #1 will be ID 8. ROI #2 will not
            %                    be processed.
            %                    If this value is not specified, the
            %                    default behaviour will be to extract
            %                    features for all ROIs within the
            %                    ImageVolume, in order.
            %                
            %
            % DESCRIPTION:
            %  Constructor for LabelledImageVolumeHandle
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterest(oImageVolume)}
                sImageSource (1,1) string {mustBeNonempty}
                oSampleLabels (:,1) SampleLabels
            end
            arguments (Repeating)
                varargin
            end
                        
            % Super-class constructor
            obj@ImageVolumeHandler(oImageVolume, sImageSource, varargin{:});
                        
            % validate samples based on the super-class constructor
            dNumRois = obj.GetNumberOfRegionsOfInterest();
            
            if dNumRois ~= oSampleLabels.GetNumberOfSamples()
                error(...
                    'LabelledImageVolumeHandler:Constructor:InvalidSampleLabels',...
                    'The number of samples within oSampleLabels does not match the number of regions of interest to be used.');
            end
            
            % set properities
            obj.oSampleLabels = oSampleLabels;
        end 
       
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function oSampleLabels = GetSampleLabels(obj)
            oSampleLabels = obj.oSampleLabels;
        end  
        
    end
    
    
    methods (Access = public, Static = true)
        
        function oLabels = GetSampleLabelsForAll(voLabelledImageVolumeHandlers)
            arguments
                voLabelledImageVolumeHandlers (1,:) LabelledImageVolumeHandler
            end
            
            dNumHandlers = length(voLabelledImageVolumeHandlers);
            c1oSampleLabelsPerHandler = cell(1, dNumHandlers);
            
            sMasterImageSource = voLabelledImageVolumeHandlers(1).sImageSource;
            
            for dHandlerIndex=1:dNumHandlers
                if sMasterImageSource ~= voLabelledImageVolumeHandlers(dHandlerIndex).sImageSource
                    error(...
                        'LabelledImageVolumeHandler:GetSampleLabelsForAll:Invalid',...
                        'All LabelledImageVolumeHandler objects must have the same Image Source value to have their Sample Labels combined.');
                end
                
                c1oSampleLabelsPerHandler{dHandlerIndex} = voLabelledImageVolumeHandlers(dHandlerIndex).GetSampleLabels();
            end
            
            oLabels = vertcat(c1oSampleLabelsPerHandler{:});
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    
    methods (Access = protected)
                
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
    
    
    methods (Access = private, Static = true) % None
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