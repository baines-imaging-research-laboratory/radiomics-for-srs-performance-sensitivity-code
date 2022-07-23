classdef (Abstract) HyperParameterOptimizer
    %HyperParameterOptimizer
    %
    % HyperParameterOptimizer is an ABSTRACT class (cannot be instantiated)
    % that describes a common functionality that all implementations of a
    % HyperParameterOptimizer object should provide. It also provides
    % validation functions for the data that would likely be stored with a
    % HyperParameterOptimizer object
    
    % Primary Author: Carol Johnson
    % Created: Feb 28, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private

    properties (SetAccess = protected, GetAccess = public)
        % Flag will be set to true by appropriate subclass
        %stImplementation = struct('bMATLAB_Opt',false,'bMATLAB_ML',false,'bPRTools',false,'bOpenCV',false); 
        %sName = "";
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        tOptions = [];
        oLabelledFeatureValues = [];
    end
    
    properties (Constant = true, GetAccess = private)
        chOptionsFileTableVarName = 'tOptions'
    end
    
    properties (Constant = true, GetAccess = protected)
        sExperimentJournalingObjVarName = "oHyperParameterOptimizer"
    end
       
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PUBLIC METHODS                             *             2 Not Abstract    X.2 Static
    % *********************************************************************

    methods (Access = public, Static = false)
        
        function obj = HyperParameterOptimizer(chOptimizationOptionsFileName,oLabelledFeatureValues)
            %obj = HyperParameterOptimizer(chOptimizationOptionsFileName,oLabelledFeatureValues)
            %
            % SYNTAX:
            %  obj = HyperParameterOptimizer(chOptimizationOptionsFileName,oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Constructor for HyperParameterOptimizer
            %       - Calls function to validate input arguments
            %       - Loads table from disk holding the optimizer options
            %       - Sets the property values with the optimizer options
            %         and labelled feature values
            %
            % INPUT ARGUMENTS:
            %  chOptimizationOptionsFileName: character array holding the
            %           file name where the optimizer options are stored 
            %  oLabelledFeatureValues: object of type LabelledFeatureValues  
            %           holding the training set feature values and labels  
            %           to be used during parameter optimization.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: Carol Johnson
            % Created: Feb 21, 2019
            
            arguments
                chOptimizationOptionsFileName (1,:) char
                oLabelledFeatureValues (:,:) LabelledFeatureValues
            end
            
            tOptions = FileIOUtils.LoadMatFile(chOptimizationOptionsFileName, HyperParameterOptimizer.chOptionsFileTableVarName);
            
            obj.tOptions = tOptions;
            obj.oLabelledFeatureValues = oLabelledFeatureValues;            
        end
        
        function tOptions = GetOptimizerOptions(obj)
            %tOptions = GetOptimizerOptions(obj)
            %
            % SYNTAX:
            %  tOptions = GetOptimizerOptions(obj)
            %
            % DESCRIPTION:
            %  A function to get the table of user defined options for the
            %  optimizer
            %
            % INPUT ARGUMENTS:
            %  obj: the HyperParameterOptimizer object
            %
            % OUTPUTS ARGUMENTS:
            %  tOptions: returns the property tOptions which
            %           holds the table of user defined options
            %           for the optimizer
            
            % Primary Author: Carol Johnson
            % Created: Sep 25, 2019

            tOptions = obj.tOptions;
        end
        
        function oLabelledFeatureValues = GetLabelledFeatureValues(obj)
            %oLabelledFeatureValues = GetLabelledFeatureValues(obj)
            %
            % SYNTAX:
            %  oLabelledFeatureValues = GetLabelledFeatureValues(obj)
            %
            % DESCRIPTION:
            %  A function to get the labelled feature values object
            %
            % INPUT ARGUMENTS:
            %  obj: the HyperParameterOptimizer object
            %
            % OUTPUTS ARGUMENTS:
            %  oLabelledFeatureValues: returns the property
            %           oLabelledFeatureValues object which
            %           holds the features and their corresponding labels
            
            % Primary Author: Carol Johnson
            % Created: Sep 25, 2019

            oLabelledFeatureValues = obj.oLabelledFeatureValues;
        end
    end

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true) % None        
    end
end