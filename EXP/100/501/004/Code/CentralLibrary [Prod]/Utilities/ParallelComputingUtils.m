classdef (Abstract) ParallelComputingUtils
    %ParallelComputingUtils
    %   This utility package contains function that are useful when using
    %   the MATLAB parallel computing toolbox (e.g. parfor)
    %   *NOTE* All additions should be added as Static Methods.
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Access = private, Constant = true)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Static = true)
        function bIsInParallel = IsInParallelComputing()
            % bIsInParallel = IsInParallelComputing()
            %
            % SYNTAX:
            %  bIsInParallel = IsInParallelComputing()
            %
            % DESCRIPTION:
            % checks whether the current computing environment is in a
            % standard MATLAB application (false) or a parallel computing
            % environment (true)
            
            % INPUTS:
            %  NONE
            
            % OUTPUTS:
            % - bIsInParallel: true if computing environment is in
            % parallel, false otherwise
                        
            % returned object is empty in standard environment, filled by
            % worker if in parallel
            
            % Written by: David DeVries
            % Created: Feb 28, 2019
            % Modified: -
            
            
            if ~isempty(which('Experiment')) && Experiment.IsRunning
                bIsInParallel = ~Experiment.IsInInitialComputationEnvironment();
            else            
                oCurrentTask = getCurrentTask();
                
                bIsInParallel = ~isempty(oCurrentTask);
            end
        end
        
        function oPool = GetCurrentParpool()
            % oPool = GetCurrentParpool()
            %
            % SYNTAX:
            %  oPool = GetCurrentParpool() = GetCurrentParpool()
            %
            % DESCRIPTION:
            %  ???
            
            % INPUTS:
            %  NONE
            
            % OUTPUTS:
            %  oPool:
            
            oPool = gcp('nocreate');
        end
    end

    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    
    methods (Access = private, Static = true)
        
    end
end

