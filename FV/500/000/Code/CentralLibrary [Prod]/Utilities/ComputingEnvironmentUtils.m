classdef (Abstract) ComputingEnvironmentUtils
    %ComputingEnvironmentUtils
    %  A class of utilities that will return various computer settings
    %  including username, process id and computer name.
    %  Useful for calls in the Experiment class.
    
    % Written by: David DeVries
    % Created: Aug 30, 2020
    % Modified: -

    properties (Access = private, Constant = true)
    end
    
    methods (Access = public, Static = true)
        
        function sUsername = GetCurrentUsername()
            % sUsername = GetCurrentUsername()
            
            % Gets the current username
            
            % INPUTS:
            %  NONE
            
            % OUTPUTS:
            %  sUsername: current username
                        
            sUsername = string(getenv('USERNAME')); % this is supported by PC, Mac, and Linux
        end
        
        function sComputerName = GetCurrentComputerName()
            % sComputerName = GetCurrentComputerName()
            
            % Gets the current computer name
            
            % INPUTS:
            %  NONE
            
            % OUTPUTS:
            %  sUsername: current computer name

            sComputerName = string(java.net.InetAddress.getLocalHost.getHostName); % this is supported by PC, Mac, and Linux
        end
        
        function dProcessId = GetCurrentProcessId()
            % dProcessId = GetCurrentProcessId()
            
            % Gets the current process id
            
            % INPUTS:
            %  NONE
            
            % OUTPUTS:
            %  dProcessId: current process id
            
            dProcessId = feature('getpid'); % this is supported by PC, Mac, and Linux
        end
    end
    
    methods (Access = private, Static = true)
        
    end
end

