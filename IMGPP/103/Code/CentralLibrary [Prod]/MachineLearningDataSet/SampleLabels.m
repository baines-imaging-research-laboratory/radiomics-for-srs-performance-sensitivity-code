classdef (Abstract) SampleLabels < MatrixContainer
    %SampleLabels
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (SetAccess = immutable, GetAccess = public)
        sLabelsSource (1,1) string = ""
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
        oRecord = GetRecordForModel(obj)
    end
    
    methods (Access = public, Static = false)
        
        function obj = SampleLabels(m2xLabels, sLabelsSource)
            %obj = SampleLabels(m2xLabels, sLabelsSource)
            %
            % SYNTAX:
            %  obj = SampleLabels(m2xLabels, sLabelsSource)
            %
            % DESCRIPTION:
            %  Constructor for SampleLabels
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
               
            arguments
                m2xLabels (:,:) {mustBeNumericOrLogical}
                sLabelsSource (1,1) string = ""
            end
            
            % super-class constructor
            obj@MatrixContainer(m2xLabels)
            
            % set properities
            obj.sLabelsSource = sLabelsSource;
        end      
        
        
        % >>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dNumSamples = GetNumberOfSamples(obj)
            %dNumSamples = GetNumberOfSamples(obj)
            %
            % SYNTAX:
            %  dNumSamples = obj.GetNumberOfSamples()
            %
            % DESCRIPTION:
            %  Returns the number of samples for which there are IDs for
            %  (e.g. the number of rows in each of the column vectors
            %  stored)
            %
            % INPUT ARGUMENTS:
            %  obj: SampleLabels obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = length(obj); % used overloaded length function
        end
        
        function sLabelsSource = GetLabelsSource(obj)
            %sLabelsSource = GetLabelsSource(obj)
            %
            % SYNTAX:
            %  sLabelsSource = obj.GetLabelsSource()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleLabels obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            sLabelsSource = obj.sLabelsSource;
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

