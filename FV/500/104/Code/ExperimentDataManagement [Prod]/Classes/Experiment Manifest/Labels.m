classdef Labels
    %Labels
    %
    % Provides a label (pos. or neg.) for each patient/lesion sample within
    % a database group
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        sDatabaseGroupIdTag (1,1) string
        
        vbSampleIsPositive (:,1) logical
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oLabels'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Labels(sIdTag, oDatabaseGroup, vbSampleIsPositive)
            arguments
                sIdTag (1,1) string
                oDatabaseGroup (1,1) DatabaseGroup
                vbSampleIsPositive(:,1) logical
            end
            
            obj.sIdTag = sIdTag;
            obj.sDatabaseGroupIdTag = oDatabaseGroup.GetIdTag();
            
            obj.vbSampleIsPositive = vbSampleIsPositive;
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) Labels
                chFilePath (1,:) char
            end
            
            FileIOUtils.SaveMatFile(chFilePath, Labels.chMatFileVarName, obj);
        end
        
        function vbSampleIsPositive = GetSampleIsPositive(obj)
            vbSampleIsPositive = obj.vbSampleIsPositive;
        end
        
        function [dNumPositive, dNumNegative] = GetNumberOfPositivesAndNegatives(obj)
            dNumPositive = sum(obj.vbSampleIsPositive);
            dNumNegative = sum(~obj.vbSampleIsPositive);
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, Labels.chMatFileVarName);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
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

