classdef FeatureExtractionRecordPortion < matlab.mixin.Heterogeneous
    %FeatureExtractionRecordPortion
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        chPortionUuid (1,36) char        
        sDescription (1,1) string        
        dtCreationTimestamp (1,1) datetime        
        dTotalNumberOfSamples (1,1) double {mustBePositive, mustBeInteger} = 1
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = FeatureExtractionRecordPortion(varargin)
            %obj = FeatureExtractionRecordPortion(sDescription, dTotalNumberOfSamples)
            %
            % SYNTAX:
            %  obj = FeatureExtractionRecordPortion(sDescription, dTotalNumberOfSamples)
            %  obj = FeatureExtractionRecordPortion(voFeatureExtractionRecordPortions)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  input1: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: TODO
                        
            if nargin == 1
                voFeatureExtractionRecordPortions = varargin{1};
                
                ValidationUtils.MustBeA(voFeatureExtractionRecordPortions, 'FeatureExtractionRecordPortion');
                
                vdDims = size(voFeatureExtractionRecordPortions);
                dNumPortions = prod(vdDims);
                
                obj = repmat(FeatureExtractionRecordPortion("Pre-allocate",1),vdDims);
                
                for dPortionIndex = 1:dNumPortions
                    obj(dPortionIndex).chPortionUuid = voFeatureExtractionRecordPortions(dPortionIndex).chPortionUuid;
                    obj(dPortionIndex).sDescription = voFeatureExtractionRecordPortions(dPortionIndex).sDescription;
                    obj(dPortionIndex).dtCreationTimestamp = voFeatureExtractionRecordPortions(dPortionIndex).dtCreationTimestamp;
                    obj(dPortionIndex).dTotalNumberOfSamples = voFeatureExtractionRecordPortions(dPortionIndex).dTotalNumberOfSamples;
                end                
            elseif nargin == 2
                sDescription = string(varargin{1});
                dTotalNumberOfSamples = double(varargin{2});
                
                % validate
                ValidationUtils.MustBeA(sDescription, 'string');
                ValidationUtils.MustBeScalar(sDescription);
                
                ValidationUtils.MustBeA(dTotalNumberOfSamples, 'double');
                ValidationUtils.MustBeScalar(dTotalNumberOfSamples);
                mustBePositive(dTotalNumberOfSamples);
                mustBeInteger(dTotalNumberOfSamples);
                
                % set properities
                obj.sDescription = sDescription;
                obj.dtCreationTimestamp = datetime(now, 'ConvertFrom', 'datenum');
                obj.chPortionUuid = char(java.util.UUID.randomUUID());
                obj.dTotalNumberOfSamples = dTotalNumberOfSamples;
            else
                error(...
                    'FeatureExtractionRecordPortion:Constructor:InvalidNumParams',...
                    'Too many parameters. See constructor documentation for details.');
            end
        end 
    end
    
    
    methods (Access = public, Sealed = true)
        
        function dNumberOfSamples = GetNumberOfSamples(obj)
            dNumberOfSamples = obj.dTotalNumberOfSamples;
        end
        
        function dtTimestamp = GetCreationTimestamp(obj)
            dtTimestamp = obj.dtCreationTimestamp;
        end
        
        function sDescription = GetDescription(obj)
            sDescription = obj.sDescription;
        end
        
        function chUuid = GetUuid(obj)
            chUuid = obj.chPortionUuid;
        end
    end
   
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = protected)
        
        function MustBeValidPortionIndex(obj, dPortionIndex)
            arguments
                obj
                dPortionIndex (1,1) double {mustBeInteger, mustBePositive}
            end
            
            mustBeLessThanOrEqual(dPortionIndex, obj.dTotalNumberOfSamples);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?FeatureExtractionRecordPortion, ?FeatureExtractionRecord})
        
        function c1xDataForXls = GetPerSampleDataForXls(obj, dPortionIndex)
            c1xDataForXls = {obj.chPortionUuid, obj.sDescription};
        end
    end
    
    
    methods (Access = {?FeatureExtractionRecordPortion, ?FeatureExtractionRecord}, Static = true)
        
        function vsHeaders = GetPerSampleHeadersForXls()            
            % local call
            vsHeaders = ["Portion UUID", "Description"];
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

