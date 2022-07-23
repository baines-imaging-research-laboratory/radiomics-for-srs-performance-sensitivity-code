classdef ImageVolumeFeatureExtractionRecord < FeatureExtractionRecord
    %ImageVolumeFeatureExtractionRecord
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = ImageVolumeFeatureExtractionRecord(sDescription, voImageVolumeHandlers, oFeatureExtractionParameters, dtFeatureExtractionStart, dtFeatureExtractionEnd, oFeatureExtractionRecordUniqueKey)
            %obj = ImageVolumeFeatureExtractionRecord(sDescription, voImageVolumeHandlers, oFeatureExtractionParameters, dtFeatureExtractionStart, dtFeatureExtractionEnd, oFeatureExtractionRecordUniqueKey)
            %
            % SYNTAX:
            %  obj = ImageVolumeFeatureExtractionRecord(sDescription, voImageVolumeHandlers, oFeatureExtractionParameters, dtFeatureExtractionStart, dtFeatureExtractionEnd)
            %  obj = ImageVolumeFeatureExtractionRecord(__, __, __, __, __, oFeatureExtractionRecordUniqueKey)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            % validate properities
            
            arguments
                sDescription (1,1) string
                voImageVolumeHandlers (1,:) FeatureExtractionImageVolumeHandler {ImageVolumeFeatureExtractionRecord.MustBeValidImageVolumeHandlers(voImageVolumeHandlers)}
                oFeatureExtractionParameters (1,1) FeatureExtractionParameters
                dtFeatureExtractionStart (1,1) datetime
                dtFeatureExtractionEnd (1,1) datetime
                oFeatureExtractionRecordUniqueKey (1,1) FeatureExtractionRecordUniqueKey = FeatureExtractionRecordUniqueKey()
            end
            
            % set properities:
            oPortion = ImageVolumeFeatureExtractionRecordPortion(...
                sDescription, voImageVolumeHandlers, oFeatureExtractionParameters,...
                dtFeatureExtractionStart, dtFeatureExtractionEnd);
            
            sFeatureSource = voImageVolumeHandlers(1).GetFeatureSource();
                        
            % super-class call:
            obj@FeatureExtractionRecord(sFeatureSource, oPortion, oFeatureExtractionRecordUniqueKey)
        end 
        
        function obj = UnloadImageVolumeHandlersToDisk(obj, c1vsImageVolumeHandlerFilePathsPerPortion, NameValueArgs)
            arguments
                obj (1,1) ImageVolumeFeatureExtractionRecord
                c1vsImageVolumeHandlerFilePathsPerPortion (1,:) cell
                NameValueArgs.HandlersAlreadySaved (1,1) logical = false
            end
            
            if length(c1vsImageVolumeHandlerFilePathsPerPortion) ~= length(obj.voFeatureExtractionRecordPortions)
                error(...
                    'ImageVolumeFeatureExtractionRecord:UnloadImageVolumeHandlersToDisk:InvalidNumberOfPaths',...
                    'The number of vectors of paths must equal the number of FeatureExtractionRecordPortions.');
            end
            
            c1xVarargin = namedargs2cell(NameValueArgs);
            
            for dPortionIndex=1:length(obj.voFeatureExtractionRecordPortions)
                obj.voFeatureExtractionRecordPortions(dPortionIndex) = obj.voFeatureExtractionRecordPortions(dPortionIndex).UnloadImageVolumeHandlersToDisk(c1vsImageVolumeHandlerFilePathsPerPortion{dPortionIndex}, c1xVarargin{:});
            end
        end
    end
    
    
    methods (Access = public, Sealed = true)
                
        function [oFeatureExtractionImageVolumeHandler, dExtractionIndex] = GetImageVolumeHandlerAndExtractionIndexForRecordIndex(obj, dRecordIndex)
            arguments
                obj
                dRecordIndex (1,1) double {MustBeValidRecordIndices(obj, dRecordIndex)}
            end
            
            [oPortion, dPortionIndex] = obj.GetPortionAndPortionIndexForRecordIndex(dRecordIndex);
            [oFeatureExtractionImageVolumeHandler, dExtractionIndex] = oPortion.GetImageVolumeHandlerAndExtractionIndexForPortionIndex(dPortionIndex);            
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
    
    methods (Access = private, Static = true)
        
        function MustBeValidImageVolumeHandlers(voImageVolumeHandlers)
            % Validate that all the FeatureExtractionImageVolumeHandlers
            % are from the same feature source
            sMasterFeatureSource = voImageVolumeHandlers(1).GetFeatureSource();
            
            for dHandlerIndex=1:length(voImageVolumeHandlers)
                if sMasterFeatureSource ~= voImageVolumeHandlers(dHandlerIndex).GetFeatureSource()
                    error(...
                        'ImageVolumeFeatureExtractionRecord:ValidateImageVolumeHandlers:MismatchedFeatureSources',...
                        ['All FeatureExtractionImageVolumeHandlers must have the same Feature Source in order to be part of the same FeatureExtractionRecord. Found features sources include "', char(sMasterFeatureSource), '" and "', char(voImageVolumeHandlers(dHandlerIndex).GetFeatureSource()), '".']);
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

