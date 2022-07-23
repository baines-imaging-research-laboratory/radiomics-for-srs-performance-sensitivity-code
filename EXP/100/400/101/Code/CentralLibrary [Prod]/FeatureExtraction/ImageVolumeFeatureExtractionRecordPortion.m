classdef ImageVolumeFeatureExtractionRecordPortion < FeatureExtractionRecordPortion
    %ImageVolumeFeatureExtractionRecordPortion
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Sept 1, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        oFeatureExtractionParameters    FeatureExtractionParameters % (1,1)
        
        dtFeatureExtractionStart        datetime % (1,1)
        dtFeatureExtractionEnd          datetime % (1,1)
        
        dTotalNumberRegionsOfInterest   double
    end
    
    properties (SetAccess = private, GetAccess = public)
        voImageVolumeHandlers           (1,:) FeatureExtractionImageVolumeHandler = FeatureExtractionImageVolumeHandler.empty(1,0)
        vsImageVolumeHandlerFilePaths   (1,:) string % if voImageVolumeHandlers is unloaded, then they can be reloaded using these file paths
    end
    
    properties (Constant = true, GetAccess = public)
        sImageVolumeHandlerMatFileVarName = "oHandler"
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = UnloadImageVolumeHandlersToDisk(obj, vsImageVolumeHandlerFilePaths, NameValueArgs)
            arguments
                obj (1,1) ImageVolumeFeatureExtractionRecordPortion
                vsImageVolumeHandlerFilePaths (1,:) string
                NameValueArgs.HandlersAlreadySaved (1,1) logical = false
            end
            
            if length(vsImageVolumeHandlerFilePaths) ~= length(obj.voImageVolumeHandlers)
                error(...
                    'ImageVolumeFeatureExtractionRecordPortion:UnloadImageVolumeHandlersToDisk:InvalidNumberOfPaths',...
                    'The number of paths must equal the number of ImageVolumeHandlers.');
            end
            
            obj.vsImageVolumeHandlerFilePaths = vsImageVolumeHandlerFilePaths;
            
            if ~NameValueArgs.HandlersAlreadySaved
                for dHandlerIndex=1:length(obj.voImageVolumeHandlers)
                    FileIOUtils.SaveMatFile(obj.vsImageVolumeHandlerFilePaths(dHandlerIndex), ImageVolumeFeatureExtractionRecordPortion.sImageVolumeHandlerMatFileVarName, obj.voImageVolumeHandlers(dHandlerIndex));
                end
            end
            
            obj.voImageVolumeHandlers = FeatureExtractionImageVolumeHandler.empty(1,0);
        end
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    
    methods (Access = {?FeatureExtractionRecordPortion, ?FeatureExtractionRecord})
        
        function c1xDataForXls = GetPerSampleDataForXls(obj, dFeatureExtractionPortionIndex)
            % super-class call
            c1xDataForXls = GetPerSampleDataForXls@FeatureExtractionRecordPortion(obj, dFeatureExtractionPortionIndex);
            
            % local call
            [oImageVolumeHandler, dExtractionIndex, dImageVolumeHandlerNumber] = obj.GetImageVolumeHandlerAndExtractionIndexForPortionIndex(dFeatureExtractionPortionIndex);
            
            dRoiNumber = oImageVolumeHandler.GetRegionOfInterestNumberFromExtractionIndex(dExtractionIndex);
            
            oImageVolume = oImageVolumeHandler.GetRASImageVolume();
            
            c1xDataForXls = [c1xDataForXls, {...
                datestr(obj.dtFeatureExtractionStart, "mmm dd, yyyy HH:MM:SS"),...
                datestr(obj.dtFeatureExtractionEnd, "mmm dd, yyyy HH:MM:SS"),...
                dImageVolumeHandlerNumber,...
                dExtractionIndex,...
                dRoiNumber,...
                oImageVolume.GetOriginalFilePath(),...
                oImageVolume.GetRegionsOfInterest().GetOriginalFilePath(),...
                oImageVolume.GetMatFilePath(),...
                oImageVolume.GetRegionsOfInterest().GetMatFilePath()}];
        end
    end
    
    
    methods (Access = {?FeatureExtractionRecordPortion, ?FeatureExtractionRecord}, Static = true)
        
        function vsHeaders = GetPerSampleHeadersForXls()
            % super-class call
            vsHeaders = GetPerSampleHeadersForXls@FeatureExtractionRecordPortion();
            
            % local call
            vsHeaders = [vsHeaders,...
                "Extraction Start",...
                "Extraction End",...
                "Image Volume Handler #",...
                "Extraction Index",...
                "ROI #",...
                "Original Image Path",...
                "Original ROIs Path",...
                "Image Matfile Path",...
                "ROIs Matfile Path"];
        end
    end
    
    
    methods (Access = {?FeatureExtractionRecord})
        
        function obj = ImageVolumeFeatureExtractionRecordPortion(sDescription, voImageVolumeHandlers, oFeatureExtractionParameters, dtFeatureExtractionStart, dtFeatureExtractionEnd)
            %obj = ImageVolumeFeatureExtractionRecordPortion(sDescription, voImageVolumeHandlers, oFeatureExtractionParameters, dtFeatureExtractionStart, dtFeatureExtractionEnd)
            %
            % SYNTAX:
            %  obj = ImageVolumeFeatureExtractionRecordPortion(sDescription, voImageVolumeHandlers, oFeatureExtractionParameters, dtFeatureExtractionStart, dtFeatureExtractionEnd)
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
                sDescription (1,1) string
                voImageVolumeHandlers (1,:) FeatureExtractionImageVolumeHandler
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
                dtFeatureExtractionStart (1,1) datetime
                dtFeatureExtractionEnd (1,1) datetime {ValidationUtils.DatetimesMustBeGreaterThanOrEqual(dtFeatureExtractionEnd, dtFeatureExtractionStart)}
            end
            
            % Calculate number of regions of interest processed
            dTotalNumberOfRegionsOfInterest = 0;
            
            for dHandlerIndex=1:length(voImageVolumeHandlers)
                dTotalNumberOfRegionsOfInterest = dTotalNumberOfRegionsOfInterest + ...
                    voImageVolumeHandlers(dHandlerIndex).GetNumberOfRegionsOfInterest();
            end
            
            % Super-class constructor
            obj@FeatureExtractionRecordPortion(sDescription, dTotalNumberOfRegionsOfInterest);                   
            
            % Set properties
            obj.oFeatureExtractionParameters = oFeatureExtractionParameters;        
            obj.voImageVolumeHandlers = voImageVolumeHandlers;
            obj.dtFeatureExtractionStart = dtFeatureExtractionStart;
            obj.dtFeatureExtractionEnd = dtFeatureExtractionEnd;
            
            dTotalNumberRegionsOfInterest = 0;
            
            for dHandlerIndex=1:length(voImageVolumeHandlers)
                dTotalNumberRegionsOfInterest = dTotalNumberRegionsOfInterest + voImageVolumeHandlers(dHandlerIndex).GetNumberOfRegionsOfInterest();
            end
            
            obj.dTotalNumberRegionsOfInterest = dTotalNumberRegionsOfInterest;
        end 
        
        function [oFeatureExtractionImageVolumeHandler, dExtractionIndex, dImageVolumeHandlerNumber] = GetImageVolumeHandlerAndExtractionIndexForPortionIndex(obj, dPortionIndex)
            arguments
                obj (1,1) ImageVolumeFeatureExtractionRecordPortion
                dPortionIndex (1,1) double {MustBeValidPortionIndex(obj, dPortionIndex)}
            end
            
            dRegionOfInterestCounter = 1;
            
            oFeatureExtractionImageVolumeHandler = [];
            dExtractionIndex = [];
            
            if isempty(obj.voImageVolumeHandlers)
                dNumHandlers = length(obj.vsImageVolumeHandlerFilePaths);
                c1oLoadedHandlers = cell(1,dNumHandlers);
                
                for dHandlerIndex=1:dNumHandlers
                    c1oLoadedHandlers{dHandlerIndex} = FileIOUtils.LoadMatFile(obj.vsImageVolumeHandlerFilePaths(dHandlerIndex), ImageVolumeFeatureExtractionRecordPortion.sImageVolumeHandlerMatFileVarName);
                end
                
                obj.voImageVolumeHandlers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oLoadedHandlers);
            end
            
            
            for dImageVolumeHandlerNumber=1:length(obj.voImageVolumeHandlers)
                oHandler = obj.voImageVolumeHandlers(dImageVolumeHandlerNumber);
                
                for dSearchExtractionIndex=1:oHandler.GetNumberOfRegionsOfInterest()
                    if dRegionOfInterestCounter == dPortionIndex
                        oFeatureExtractionImageVolumeHandler = oHandler;
                        dExtractionIndex = dSearchExtractionIndex;
                        break;
                    end        
                    
                    dRegionOfInterestCounter = dRegionOfInterestCounter + 1;
                end
                
                if ~isempty(oFeatureExtractionImageVolumeHandler)
                    break;
                end
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

