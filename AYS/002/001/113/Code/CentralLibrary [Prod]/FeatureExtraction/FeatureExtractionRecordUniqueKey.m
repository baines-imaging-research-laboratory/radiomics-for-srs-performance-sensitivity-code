classdef FeatureExtractionRecordUniqueKey < handle
    %FeatureExtractionRecordUniqueKey
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = private)
        chFeatureExtractionUuid
    end
    
    properties (SetAccess = private, GetAccess = private)
        chAssociatedFeatureExtractionRecordTypeClassname = ''
        sAssociatedFeatureExtractionRecordSource = ""
        
        oFeatureExtractionRecord = []
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = FeatureExtractionRecordUniqueKey()
            %obj = FeatureExtractionRecordUniqueKey()
            %
            % SYNTAX:
            %  obj = FeatureExtractionRecordUniqueKey()
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
            
            
            obj.chFeatureExtractionUuid = char(java.util.UUID.randomUUID());            
        end 
        
        function saveobj(obj)
            % CANNOT allow these objects to be saved, as then code could be
            % altered and the same key could be passed to
            % FeatureExtractionRecords that used different code
            
            error(...
                'FeatureExtractionRecordUniqueKey:saveobj:Invalid',...
                'FeatureExtractionRecordUniqueKey objects cannot be saved to disk, as then they could be used to produce invalid results.');
        end
    end 
    
    
    methods (Access = public, Static = true)
         
        
        function loadobj(stStruct)
            % CANNOT allow these objects to be saved, as then code could be
            % altered and the same key could be passed to
            % FeatureExtractionRecords that used different code
            
            error(...
                'FeatureExtractionRecordUniqueKey:loadobj:Invalid',...
                'FeatureExtractionRecordUniqueKey objects cannot be loaded from disk, as then they could be used to produce invalid results.');
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
    
    methods (Access = {?FeatureExtractionRecord})
        
        function chUuid = GetUuid(obj, oFeatureExtractionRecord)
            if ~isscalar(oFeatureExtractionRecord) || ~isa(oFeatureExtractionRecord, 'FeatureExtractionRecord')            
                error(...
                    'FeatureExtractionRecordUniqueKey:GetUuid:InvalidFeatureExtractionRecord',...
                    'oFeatureExtractionRecord must be a scalar object of type FeatureExtractionRecord.');
            end
            
            if isempty(obj.oFeatureExtractionRecord)
                obj.oFeatureExtractionRecord = oFeatureExtractionRecord;
                chUuid = obj.chFeatureExtractionUuid; 
            else
                if ~isa(oFeatureExtractionRecord, class(obj.oFeatureExtractionRecord)) || ~strcmp(oFeatureExtractionRecord.GetFeatureSource(), obj.oFeatureExtractionRecord.GetFeatureSource())
                    error(...
                        'FeatureExtractionRecordUniqueKey:GetUuid:CanOnlyProvideUuidToRecordsWithSameTypeAndFeatureSource',...
                        'UUID can only be provided to FeatureExtractionRecords that are of the same type and have the same recorded source as the first FeatureExtractionRecord to use the key.');
                else
                    chUuid = obj.chFeatureExtractionUuid;
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

