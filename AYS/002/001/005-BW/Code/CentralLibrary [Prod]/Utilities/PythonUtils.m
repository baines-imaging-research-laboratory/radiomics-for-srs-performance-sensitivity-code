classdef (Abstract) PythonUtils
    %PythonUtils
    %
    % Provides functions calling Python code
    
    % Primary Author: David DeVries
    % Created: June 8, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function ExecutePythonScriptInAnacondaEnvironment(chPythonScriptPath, c1chPythonScriptArguments, chAnacondaInstallPath, chEnvironmentName)
            %ExecutePythonScriptInAnacondaEnvironment(chPythonScriptPath, c1chPythonScriptArguments, chAnacondaInstallPath, chEnvironmentName)
            %
            % SYNTAX:
            %  ExecutePythonScriptInAnacondaEnvironment(chPythonScriptPath, c1chPythonScriptArguments, chAnacondaInstallPath, chEnvironmentName)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  chPythonScriptPath:
            %  c1chPythonScriptArguments:
            %  chAnacondaInstallPath:
            %  chEnvironmentName:
            %
            % OUTPUT ARGUMENTS:
            %  None
            
            PythonUtils.ValidateOS();
            
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'PythonUtils:ExecutePythonScriptInAnacondaEnvironment:InParallelEnvironment',...
                    'Python calls cannot be executed from a parallel computing environment.');
            end
            
            chActivateAnacondaEnvironment = ['CALL "', fullfile(chAnacondaInstallPath, 'condabin', 'conda.bat'), '" activate ', chEnvironmentName];
            chRunScript = ['python "', chPythonScriptPath, '"', sprintf(repmat(' "%s"',1,length(c1chPythonScriptArguments)), c1chPythonScriptArguments{:})];
            chDeactivateAnacondaEnvironment = ['CALL "', fullfile(chAnacondaInstallPath, 'condabin', 'conda.bat'), '" deactivate'];
            
            chCall = [...
                chActivateAnacondaEnvironment, ' && ',...
                chRunScript, ' && ',...
                chDeactivateAnacondaEnvironment];
            
            dStatusCode = system(chCall);
            
            if dStatusCode ~= 0
                error(...
                    'PythonUtils:ExecutePythonScriptInAnacondaEnvironment:Error',...
                    'See call output for error messages.');
            end
        end
        
        function ExecuteCondaCommandInAnacondaEnvironment(chCondaCommand, chAnacondaInstallPath, chEnvironmentName)
            %ExecuteCondaCommandInAnacondaEnvironment(chCondaCommand, chAnacondaInstallPath, chEnvironmentName)
            %
            % SYNTAX:
            %  ExecuteCondaCommandInAnacondaEnvironment(chCondaCommand, chAnacondaInstallPath, chEnvironmentName)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  chCondaCommand:
            %  chAnacondaInstallPath:
            %  chEnvironmentName:
            %
            % OUTPUT ARGUMENTS:
            %  None
            
            PythonUtils.ValidateOS();
            
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'PythonUtils:ExecuteCondaCommandInAnacondaEnvironment:InParallelEnvironment',...
                    'Python calls cannot be executed from a parallel computing environment.');
            end
            
            chActivateAnacondaEnvironment = ['CALL "', fullfile(chAnacondaInstallPath, 'condabin', 'conda.bat'), '" activate ', chEnvironmentName];
            chCondaCommand = ['CALL "', fullfile(chAnacondaInstallPath, 'condabin', 'conda.bat'), '" ', chCondaCommand];
            chDeactivateAnacondaEnvironment = ['CALL "', fullfile(chAnacondaInstallPath, 'condabin', 'conda.bat'), '" deactivate'];
            
            chCall = [...
                chActivateAnacondaEnvironment, ' && ',...
                chCondaCommand, ' && ',...
                chDeactivateAnacondaEnvironment];
            
            dStatusCode = system(chCall);
            
            if dStatusCode ~= 0
                error(...
                    'PythonUtils:ExecuteCondaCommandInAnacondaEnvironment:Error',...
                    'See call output for error messages.');
            end
        end
        
        function dPythonRandomSeed = GetNextPythonRandomSeedNumber()
            %dPythonRandomSeed = GetNextPythonRandomSeedNumber()
            %
            % SYNTAX:
            %  dPythonRandomSeed = GetNextPythonRandomSeedNumber()
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUT ARGUMENTS:
            %  dPythonRandomSeed:
            
            PythonUtils.ValidateOS();
            
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'PythonUtils:GetNextPythonRandomSeed:InParallelEnvironment',...
                    'Cannot alter Python random seed tracking from a parallel computing environment.');
            end
            
            global dCurrentPythonRandomSeed;
            
            if isempty(dCurrentPythonRandomSeed)
                dCurrentPythonRandomSeed = 1;
            else
                dCurrentPythonRandomSeed = dCurrentPythonRandomSeed + 1;
            end
            
            dPythonRandomSeed = dCurrentPythonRandomSeed;
        end
        
        function ResetPythonRandomSeedNumber()
            %ResetPythonRandomSeedNumber()
            %
            % SYNTAX:
            %  ResetPythonRandomSeedNumber()
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUT ARGUMENTS:
            %  None:
            
            PythonUtils.ValidateOS();
            
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'PythonUtils:GetNextPythonRandomSeed:ResetPythonRandomSeedNumber',...
                    'Cannot alter Python random seed tracking from a parallel computing environment.');
            end
            
            global dCurrentPythonRandomSeed;
            
            dCurrentPythonRandomSeed = 1;
        end
        
        
% % % % %         function SetPythonAnacondaEnvironment(chAnacondaInstallPath, chEnvironmentName)
% % % % %             % So why is this commented out and not usable???
% % % % %             % There's a few way to try to use the "py.numpy.???" or
% % % % %             % "py.tensorflow.???", all of which don't jive w/ Anaconda.
% % % % %             %
% % % % %             % This is what I've tried:
% % % % %             %
% % % % %             % 1) Launch Anaconda Prompt. Activate an environment. Launch
% % % % %             % the MATLAB .exe from the prompt. Use pyenv pointing at the
% % % % %             % environment's python.exe/pythonw.exe. Numpy and basic modules
% % % % %             % worked, but tensorflow didn't.
% % % % %             %
% % % % %             % 2) Use Anaconda Prompt to figure out the paths that are added
% % % % %             % to %path% when an environment is switched up. Launch MATLAB
% % % % %             % in its usually way. Update %path% using getenv/setenv to
% % % % %             % manually add these paths. Use pyenv pointing at the environment's
% % % % %             % python.exe/pythonw.exe. Numpy and basic modules
% % % % %             % worked, but tensorflow didn't.
% % % % %             % In particular, the paths to add were:
% % % % %             % miniconda3\envs\env_name;
% % % % %             % miniconda3\envs\env_name\Library\mingw-w64\bin;
% % % % %             % miniconda3\envs\env_name\Library\usr\bin;
% % % % %             % miniconda3\envs\env_name\Library\bin;
% % % % %             % miniconda3\envs\env_name\Scripts;
% % % % %             % miniconda3\envs\env_name\bin;
% % % % %             % miniconda3\condabin;
% % % % %             % 
% % % % %             %
% % % % %             % But why don't you just not use Anaconda and get a dope Python
% % % % %             % environment all set-up?
% % % % %             % I believe this would work. The only problem is that not being
% % % % %             % able to quickly change/update environments is really
% % % % %             % crippling for reproduciblity and workflows. Therefore this
% % % % %             % route was seen as a non-starter.
% % % % %             %
% % % % %             % But why don't you just edit files X,Y,Z and move these files
% % % % %             % to there, and comment out that line there, like this post on
% % % % %             % Stack Overflow says?
% % % % %             % Yes, such posts exist. They may work. These fixes are often
% % % % %             % hacks that seem to only work for certain libraries and
% % % % %             % versions. If your environment changes, I'd imagine these
% % % % %             % fixes would break. I therefore prefer a stable and maybe less
% % % % %             % elegant solution, and therefore this approach is seen as a
% % % % %             % non-starter.            
% % % % %             
% % % % %             arguments
% % % % %                 chAnacondaInstallPath (1,:) char
% % % % %                 chEnvironmentName (1,:) char
% % % % %             end
% % % % %             
% % % % %             chPyRoot = fullfile(chAnacondaInstallPath, 'envs', chEnvironmentName);
% % % % %             chPath = getenv('PATH');
% % % % %             chPath = strsplit(chPath, ';');
% % % % %             
% % % % %             addToPath = {
% % % % %                 chPyRoot
% % % % %                 fullfile(chPyRoot, 'Library', 'mingw-w64', 'bin')
% % % % %                 fullfile(chPyRoot, 'Library', 'usr', 'bin')
% % % % %                 fullfile(chPyRoot, 'Library', 'bin')
% % % % %                 fullfile(chPyRoot, 'Scripts')
% % % % %                 fullfile(chPyRoot, 'bin')
% % % % %                 fullfile(chPyRoot, 'condabin')
% % % % %                 };
% % % % %             
% % % % %             chPath = [addToPath(:); chPath(:)];
% % % % %             chPath = unique(chPath, 'stable');
% % % % %             chPath = strjoin(chPath, ';');
% % % % %             setenv('PATH', chPath);
% % % % %             
% % % % %             pyversion(fullfile(chPyRoot, 'python.exe'));
% % % % %         end
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
        
        function ValidateOS()
            if ~ispc
                error(...
                    'PythonUtils:ValidateOS:Invalid',...
                    'The PythonUtils can only be used if running Windows.');
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

