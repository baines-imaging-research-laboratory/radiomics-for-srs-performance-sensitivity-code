 classdef (Sealed) RandomNumberGenerator < handle % This class is set-up to be a singleton. DO NOT SET TO BE COPYABLE!
    %RandomNumberGenerator
    %
    % A class designed to abstract away the ability to create random
    % streams in a reproducible way for standard linear code, for loops and
    % parfor loops
    %
    % See Demos/RandomNumberGenerator_* for examples.
    
    % Primary Author: David DeVries
    % Created: Feb 28, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
        
    properties (SetAccess = private, GetAccess = public)        
        dStreamIndex = 1                % start at 1, increment from there
        c1oPreAllocatedStreams = {}     % cell array of Stream objects
        c1oCachedGlobalStreams = {}        % random stream object used temporarily store/restore the current global random number stream        
        bIsInvalidFromReset = false     % set to true when "Reset" is called. Allows for existing objects to be invalidated
                
        vui64NumberOfLoopIterationsPerNestedLevel = uint64([])
        vui64NumberOfStreamsPerLoopIterationPerNestedLevel = uint64([])
        vui64CurrentLoopIterationPerNestedLevel = uint64([])
        
        vui64NumberOfSerialForLoopsPerNestedLevel = uint64(1000) % (For debug: uint64(4)% )
        vui64NumberOfStreamsPerSerialForLoopPerNestedLevel = uint64([])
        vui64CurrentSerialForLoopPerNestedLevel = uint64(0)
        
        bSetForParfor = false
        
        bPreLoopSetupLastCalled = false
        
        bUsingSerialForLoopForIndividualRandStreams = false % set to true if user selects ".GetRandStream"
        ui64IndividualRandStreamsIndex = uint64(1)
        ui64MaxIndividualRandStreamsIndex
    end
    
    
    properties (Access = private, Constant = true)
        sType = 'mrg32k3a'              % Combined Recursive (recommended for parallel streams)
        sNormalTransform = 'Ziggurat'   % default from Matlab
        ui64TotalNumStreams = uint64(2^63) % maximum precision of a double (For debug: uint64(10000)% )
        bCellOutput = false              % doesn't output stream into cell array
        
        ui64MaxNumberOfSerialForLoops_Root = uint64(2^11) % e.g. 1000 .PreLoopSetup calls in main.m (For debug: uint64(4)% )
        ui64MaxNumberOfSerialForLoops_Nested = uint64(2^11) % e.g. 10 .PreLoopSetup calls per loop iteration managed by .PreLoopSetup (For debug; uint64(3)% )
        
        chSaveAndRestoreStateMatFileVarName = 'oRandomNumberGenerator'
    end
    
    
    properties (SetAccess = immutable, GetAccess = private)
        dSeed = []                      % the seed used to generate all streams within the object
        
        chInitialComputationHostComputerName
        dInitialComputationWorkerNumberOrProcessId
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = RandomNumberGenerator(dSeed)
            %obj = RandomNumberGenerator(dSeed)
            %
            % SYNTAX:
            %  obj = RandomNumberGenerator(dSeed)
            %  obj = RandomNumberGenerator()
            %
            % DESCRIPTION:
            %  Sets the seed and set the global RNG stream to the first
            %  stream from the RandomNumberGenerator.
            %  If no seed is given the same RandomNumberGenerator object is
            %  returned.
            %
            %  It should be noted that RandomNumberGenerator is a SINGLETON-type class,
            %  meaning that only a single instance of the class can exist.
            %  If the constructor is called again (without a seed), it will 
            %  return the same instance. To enforce this, calling the 
            %  constructor within a parallel computing loop/call is
            %  prohibited
            %
            % INPUT ARGUMENTS:
            %  dSeed: Seed for the RandomNumberGenerator. Can only be
            %         set during the first and only construction. For
            %         further constructions, no seed should be given.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                        
            % get persistent oRandomNumberGenerator object
            global oRandomNumberGenerator;
            
            if isempty(oRandomNumberGenerator) || oRandomNumberGenerator.bIsInvalidFromReset % not set yet, so create it
                if nargin == 1
                    obj.dSeed = dSeed;
                    obj.SetGlobalStream(uint64(1));
                    
                    [chInitialComputationHostComputerName, dInitialComputationWorkerNumberOrProcessId] =...
                        RandomNumberGenerator.GetCurrentComputationEnvironmentDetails();
                    
                    obj.chInitialComputationHostComputerName = chInitialComputationHostComputerName;
                    obj.dInitialComputationWorkerNumberOrProcessId = dInitialComputationWorkerNumberOrProcessId;
                            
                    obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(1) = idivide(obj.ui64TotalNumStreams - uint64(1), obj.vui64NumberOfSerialForLoopsPerNestedLevel(1), 'floor');
                    
                    oRandomNumberGenerator = obj;
                else
                    error(...
                        'RandomNumberGenerator:Constructor:InvalidParameters',...
                        'Invalid number of parameters, no RandomNumberGenerator initialized yet.');
                end
            else % it already exists, can't create a new one
                if nargin > 0 % invalid, user was trying to create a new version
                    error(...
                        'RandomNumberGenerator:Constructor:CannotCreateMultipleInstances',...
                        'Multiple instances of the RandomNumberGenerator class cannot be created since it is a singleton class. Doing so could case possibly repeated random number streams');
                else % user wants the already intialize object, so pass the persistent variable
                    obj = oRandomNumberGenerator;
                end
            end
        end
                
        function PreLoopSetup(obj, dNumLoopIterations)
            %PreLoopSetup(obj, dNumLoopIterations)
            %
            % SYNTAX:
            %  PreLoopSetup(obj, dNumLoopIterations)
            %
            % DESCRIPTION:
            %   Prepares the RandomNumberGenerator for a for or parfor loop
            %   of dNumLoopIterations.
            %
            %   In detail, it:
            %   - Caches the current global RNG stream to be
            %     restored after the loop (since a for loop WOULD change the
            %     global RNG, while a parfor WOULD NOT (since the RNG is set on
            %     each worker), therefore to keep results reproduciblity
            %     regardless of using for or parfor, the stream must be saved
            %     and restored)
            %   - Pre-allocates a stream for each loop iteration. This is
            %     really essential for parfor loops.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dNumLoopIterations: The number of loop iterations that will
            %                      be performed after this call
            %
            % OUTPUTS ARGUMENTS:
            %  None
                           
            if obj.bIsInvalidFromReset
                obj.ThrowInvalidFromResetError();
            else
                if obj.bPreLoopSetupLastCalled
                    error(...
                        'RandomNumberGenerator:PreLoopSetup:InvalidRepeatedCall',...
                        '.PreLoopSetup cannot be called again without either a .PostLoopTeardown or .PerLoopIndexCall occurring first.');
                end
                
                obj.bPreLoopSetupLastCalled = true;
                obj.CacheGlobalStream();
                
                obj.bUsingSerialForLoopForIndividualRandStreams = false;
                obj.vui64CurrentSerialForLoopPerNestedLevel(end) = obj.vui64CurrentSerialForLoopPerNestedLevel(end) + uint64(1);
                
                if obj.vui64CurrentSerialForLoopPerNestedLevel(end) > obj.vui64NumberOfSerialForLoopsPerNestedLevel(end)
                    error(...
                        'RandomNumberGenerator:PreLoopSetup:SerialForLoopLimitExceeded',...
                        'Maximum number of serial (sequential) for loops with RandomNumberGenerator stream management reached.');
                end
                
                ui64NumLoopIterations = uint64(dNumLoopIterations);                
                
                if ~isempty(obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel) && obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel(end) < ui64NumLoopIterations
                    error(...
                        'RandomNumberGenerator:PreLoopSetup:StreamLimitExceeded',...
                        'There are not enough streams available to provide at least one stream per loop iteration.');
                end
                
                obj.vui64NumberOfLoopIterationsPerNestedLevel(end+1) = ui64NumLoopIterations;
                obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel(end+1) = idivide(obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(end), ui64NumLoopIterations, 'floor');
                obj.vui64CurrentLoopIterationPerNestedLevel(end+1) = uint64(0);
                
                obj.vui64NumberOfSerialForLoopsPerNestedLevel(end+1) = RandomNumberGenerator.ui64MaxNumberOfSerialForLoops_Nested;
                obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(end+1) = idivide(obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel(end) - uint64(1), RandomNumberGenerator.ui64MaxNumberOfSerialForLoops_Nested, 'floor');
                obj.vui64CurrentSerialForLoopPerNestedLevel(end+1) = uint64(0);
            end
        end
        
        function ui64StreamIndex = PerLoopIndexSetup(obj, dLoopIndex)
            %ui64StreamIndex = PerLoopIndexSetup(obj, dLoopIndex)
            %
            % SYNTAX:
            %  PerLoopIndexSetup(obj, dLoopIndex)
            %
            % DESCRIPTION:
            %  Sets the dLoopIndex-th pre-allocated stream as the global RNG
            %  stream.
            %
            %  See also PreLoopSetup.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dLoopIndex: The current loop index within a for/parfor loop
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            global oRandomNumberGenerator;
            
            if obj.bIsInvalidFromReset
                obj.ThrowInvalidFromResetError();
            else
                obj.bPreLoopSetupLastCalled = false;
                
                [chHostComputerName, dWorkerNumberOrProcessId] = RandomNumberGenerator.GetCurrentComputationEnvironmentDetails();
                
                if ~strcmp(chHostComputerName, obj.chInitialComputationHostComputerName) || dWorkerNumberOrProcessId ~= obj.dInitialComputationWorkerNumberOrProcessId
                    if obj.bSetForParfor == false
                        % we're in a parfor, so set obj as global
                        oRandomNumberGenerator = obj;
                        obj.bSetForParfor = true;
                    else
                        
                    end
                end
                   
                uint64LoopIndex = uint64(dLoopIndex);
                
                if isempty(obj.vui64NumberOfLoopIterationsPerNestedLevel) || uint64LoopIndex > obj.vui64NumberOfLoopIterationsPerNestedLevel(end) 
                    error(...
                        'RandomNumberGenerator:PerLoopIndexSetup:InvalidIndex',...
                        'The loop index exceeds the number of loop iterations set-up for.');
                end
                
                obj.vui64CurrentLoopIterationPerNestedLevel(end) = uint64(uint64LoopIndex);
                obj.vui64CurrentSerialForLoopPerNestedLevel(end) = uint64(0);
                
                % set global stream by index
                ui64StreamIndex = uint64(1);
                
                for dNestedLevel=1:length(obj.vui64CurrentLoopIterationPerNestedLevel)
                    ui64StreamIndex = ui64StreamIndex +...
                        uint64(1) + ...% the global stream of the nth-level for loop iteration
                        (obj.vui64CurrentSerialForLoopPerNestedLevel(dNestedLevel)-uint64(1)) * obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(dNestedLevel) + ...
                        (obj.vui64CurrentLoopIterationPerNestedLevel(dNestedLevel)-uint64(1)) * obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel(dNestedLevel);                        
                end
                
                obj.SetGlobalStream(ui64StreamIndex);
                
% %                 **UNCOMMENT BELOW FOR DEBUGGING MESSAGES**
% % 
% %                 chString = '';
% %                 
% %                 for dNestedLevel=1:length(obj.vui64CurrentLoopIterationPerNestedLevel)
% %                     chString = [chString,...
% %                         char(64+obj.vui64CurrentSerialForLoopPerNestedLevel(dNestedLevel)),...
% %                         num2str(obj.vui64CurrentLoopIterationPerNestedLevel(dNestedLevel)),...
% %                         ' '];
% %                 end
% %                 
% %                 disp(['RNG Indices:  ', chString]);
% %                 disp(['  Stream Index: ', num2str(ui64StreamIndex)]);
            end
        end
        
        function PerLoopIndexTeardown(obj)
            % Do nothing operation, only added to support
            % ExperimentLoopIterationManager substituion when Experiment.run is
            % not being used
        end
        
        function PostLoopTeardown(obj)
            %PostLoopTeardown(obj)
            %
            % SYNTAX:
            %  PostLoopTeardown(obj)
            %
            % DESCRIPTION:
            %  Restores the global RNG cached from before the for loop and
            %  clears any pre-allocated streams.
            %
            %  See also PreLoopSetup.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
                        
            if obj.bIsInvalidFromReset
                obj.ThrowInvalidFromResetError();
            else
                if isempty(obj.vui64NumberOfLoopIterationsPerNestedLevel)
                    error(...
                        'RandomNumberGenerator:PostLoopTeardown:NoPreLoopSetupCall',...
                        'There is no .PreLoopSetup call to teardown for.');
                end
                
                obj.bPreLoopSetupLastCalled = false;
                obj.SetCachedStreamAsGlobalStream();
                
                obj.vui64NumberOfLoopIterationsPerNestedLevel = obj.vui64NumberOfLoopIterationsPerNestedLevel(1:end-1);
                obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel = obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel(1:end-1);
                obj.vui64CurrentLoopIterationPerNestedLevel = obj.vui64CurrentLoopIterationPerNestedLevel(1:end-1);
                
                obj.vui64NumberOfSerialForLoopsPerNestedLevel = obj.vui64NumberOfSerialForLoopsPerNestedLevel(1:end-1);
                obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel = obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(1:end-1);
                obj.vui64CurrentSerialForLoopPerNestedLevel = obj.vui64CurrentSerialForLoopPerNestedLevel(1:end-1);
            end
        end
        
        function [oRandStream, ui64StreamIndex] = GetRandomNumberStream(obj)
            %[oRandStream, ui64StreamIndex] = GetRandomNumberStream(obj)
            %
            % SYNTAX:
            %  [oRandStream, ui64StreamIndex] = obj.GetRandomNumberStream()
            %
            % DESCRIPTION:
            %  Provides a MATLAB RandStream object for use in functions
            %  requiring such an object. The global random stream is
            %  remained untouched. Any random streams prepared for
            %  for/parfor loops are also untouched.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  oRandStream: A MATLAB RandStream object
            
            if ~obj.bUsingSerialForLoopForIndividualRandStreams
                obj.vui64CurrentSerialForLoopPerNestedLevel(end) = obj.vui64CurrentSerialForLoopPerNestedLevel(end) + uint64(1);
                obj.bUsingSerialForLoopForIndividualRandStreams = true;
                
                % calculate stream number
                ui64StreamIndex = uint64(1);
                
                dNumLevels = length(obj.vui64CurrentLoopIterationPerNestedLevel);
                
                for dNestedLevel=1:dNumLevels
                    ui64StreamIndex = ui64StreamIndex +...
                        uint64(1) + ...% the global stream of the nth-level for loop iteration
                        (obj.vui64CurrentSerialForLoopPerNestedLevel(dNestedLevel)-uint64(1)) * obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(dNestedLevel) + ...
                        (obj.vui64CurrentLoopIterationPerNestedLevel(dNestedLevel)-uint64(1)) * obj.vui64NumberOfStreamsPerLoopIterationPerNestedLevel(dNestedLevel);
                end
                
                ui64StreamIndex = ui64StreamIndex + (obj.vui64CurrentSerialForLoopPerNestedLevel(dNumLevels+1)-uint64(1)) * obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(dNumLevels+1);
                ui64StreamIndex = ui64StreamIndex + obj.ui64IndividualRandStreamsIndex;
                                
                obj.ui64IndividualRandStreamsIndex = ui64StreamIndex;
                obj.ui64MaxIndividualRandStreamsIndex = ui64StreamIndex + obj.vui64NumberOfStreamsPerSerialForLoopPerNestedLevel(end) - uint64(1);
            end
                        
            if obj.ui64IndividualRandStreamsIndex > obj.ui64MaxIndividualRandStreamsIndex
                error(...
                    'RandomNumberGenerator:GetRandomNumberStream:StreamLimitExceeded',...
                    'The maximum number of streams has been exceeded.');
            end
            
            oRandStream = obj.GetStreamByIndex(obj.ui64IndividualRandStreamsIndex);
            ui64StreamIndex = obj.ui64IndividualRandStreamsIndex;
            
        	% increment stream index
            obj.ui64IndividualRandStreamsIndex = obj.ui64IndividualRandStreamsIndex + uint64(1);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<
%         
%         function disp(obj)
%             %disp(obj)
%             %
%             % SYNTAX:
%             %  disp(obj)
%             %
%             % DESCRIPTION:
%             %  Overloaded to be able to display the private properities as
%             %  deemed appropriate
%             %
%             % INPUT ARGUMENTS:
%             %  obj: Class object
%             %
%             % OUTPUTS ARGUMENTS:
%             %  None
%             
%             disp('RandomNumberGenerator in state:');
%             disp(['Seed: ', num2str(obj.dSeed)]);
%             disp(['Stream Index: ', num2str(obj.dStreamIndex)]);
%             disp(['Num. Allocated Streams: ', num2str(length(obj.c1oPreAllocatedStreams))]);
%             disp(['Stream is Cached?: ', num2str(~isempty(obj.oCachedGlobalStream))]);
%             disp(['Invalid from Reset?: ', num2str(obj.bIsInvalidFromReset)]);
%         end
    end   
    
    
    methods (Access = public, Static = true)
        
        function bBool = IsInitialized()
            %bBool = IsInitialized()
            %
            % SYNTAX:
            %  bBool = IsInitialized()
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  bBool:
            
            global oRandomNumberGenerator;
            
            bBool = ~(isempty(oRandomNumberGenerator) || oRandomNumberGenerator.bIsInvalidFromReset);
        end
        
        function Reset(varargin)
            %Reset(varargin)
            %
            % SYNTAX:
            %  Reset()
            %  Reset('SuppressWarnings')
            %
            % DESCRIPTION:
            %  Resets the RandomNumberGenerator class such that a new
            %  RandomNumberGenerator object can be created with a new/same
            %  seed.
            %  
            %  !! WARNING !!: This SHOULD NOT be called in the middle of a
            %  script/function, since then duplicated random numbers could
            %  be produced. It should be used ONLY at the beginning of
            %  entire program or test case.
            %
            % INPUT ARGUMENTS:
            %  varargin{1}: 'SuppressWarnings' string to switch off the
            %               warnings issued when "Reset" is called
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            if ParallelComputingUtils.IsInParallelComputing()
                error(...
                    'RandomNumberGenerator:Reset:InvalidEnvironment',...
                    'The RandomNumberGenerator object cannot be reset within a parallel computing environment.');
            else
                bSuppressWarnings = false;
                
                if nargin == 1
                    if strcmp(varargin{1}, 'SuppressWarnings')
                        bSuppressWarnings = true;
                    else
                        error(...
                            'RandomNumberGenerator:Reset:InvalidInput',...
                            'The given parameter was invalid. Use ''SuppressWarnings'' to suppress warnings from calling "Reset".');
                    end
                end
                
                if ~bSuppressWarnings
                    warning(...
                        'RandomNumberGenerator:Reset:Caution',...
                        'CAUTION: The RandomNumberGenerator object has been reset! This means the same random number generation streams will be produced as previous calls. A reset should ONLY be called at the beginning of an experiment!');
                end
                
                global oRandomNumberGenerator;
                oRandomNumberGenerator.bIsInvalidFromReset = true;
            end
        end
        
        function SaveState(chPath)
            %SaveState(chPath)
            %
            % SYNTAX:
            %  SaveState(chPath)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  chPath:
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                chPath (1,:) char
            end
            
            global oRandomNumberGenerator;
            
            oRandomNumberGenerator.CacheGlobalStream();
            
            FileIOUtils.SaveMatFile(chPath, RandomNumberGenerator.chSaveAndRestoreStateMatFileVarName, oRandomNumberGenerator);            
        end
        
        function RestoreState(chPath)            
            %RestoreState(chPath)
            %
            % SYNTAX:
            %  RestoreState(chPath)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  chPath:
            %
            % OUTPUTS ARGUMENTS:
            %  None

            arguments
                chPath (1,:) char
            end
            
            global oRandomNumberGenerator;
            
            oLoadedRandomNumberGenerator = FileIOUtils.LoadMatFile(chPath, RandomNumberGenerator.chSaveAndRestoreStateMatFileVarName);
            
            if ~isa(oLoadedRandomNumberGenerator, 'RandomNumberGenerator')
                error(...
                    'RandomNumberGenerator:RestoreState:InvalidClassType',...
                    'The loaded variable must be of type RandomNumberGenerator.');
            end
            
            oRandomNumberGenerator = oLoadedRandomNumberGenerator;
            
            oRandomNumberGenerator.SetCachedStreamAsGlobalStream();
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % none
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = private, Static = false)
        
        function SetGlobalStream(obj, ui64StreamIndex)
            oStream = obj.GetStreamByIndex(ui64StreamIndex);
            
            RandomNumberGenerator.SetStreamAsGlobalStream(oStream);
        end
        
        function oStream = GetStreamByIndex(obj, ui64StreamIndex)
            oStream = RandStream.create(...
                obj.sType,...
                'NumStreams', obj.ui64TotalNumStreams,...
                'StreamIndices', ui64StreamIndex,... % specify only the stream we want
                'Seed', obj.dSeed,...
                'NormalTransform', obj.sNormalTransform,...
                'CellOutput', obj.bCellOutput);
        end
        
        function PreAllocateStreams(obj, dNumStreams)
            %PreAllocateStreams(obj, dNumStreams)
            %
            % SYNTAX:
            %  PreAllocateStreams(obj, dNumStreams)
            %
            % DESCRIPTION:
            %  Pre-allocates the given number of streams (dNumStreams) for
            %  later use by using the 'SetStreamForLoopIteration' function.
            %  This call is typically done before a loop statement, with 
            %  'SetStreamForLoopIteration' being called at the being of each
            %  loop iteration
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dNumStreams: Number of streams to pre-allocate
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            ui64NumStreams = uint64(dNumStreams);
            
            obj.vui64NumIterationsPerNestedForLoops = [obj.vui64NumIterationsPerNestedForLoops, ui64NumStreams];
            
            
        end
        
        
        
        
        
        
        
        
        
        % >>>>>>>>>>>>>> INTERMEDIATE LEVEL FUNCTION CALLS <<<<<<<<<<<<<<<<
                
        
        
        function ClearPreAllocatedStreams(obj)
            %ClearPreAllocatedStreams(obj)
            %
            % SYNTAX:
            %  ClearPreAllocatedStreams(obj)
            %
            % DESCRIPTION:
            %  Clears the pre-allocated streams (can no longer set them)
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            obj.c1oPreAllocatedStreams = {};
        end
        
        function SetPreAllocatedStreamAsGlobalStream(obj, dStreamIndex) 
            %SetPreAllocatedStreamAsGlobalStream(obj, dStreamIndex)
            %
            % SYNTAX:
            %  SetPreAllocatedStreamAsGlobalStream(obj, dStreamIndex)
            %
            % DESCRIPTION:
            %  SetPreAllocatedStreamAsGlobalStream(obj, dStreamIndex)
            %  Takes the dStreamIndex-th pre-allocated stream and sets it
            %  to the Matlab Global RNG. Therefore any randi, perm, etc.
            %  calls during the loop will draw from this pre-allocated
            %  stream.
            %
            %  This function can only be called AFTER a PreAllocateStreams
            %  call, typically at the beginning of loop iterations
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dStreamIndex: Index of pre-allocated stream to set
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            dNumPreAllocatedStreams = length(obj.c1oPreAllocatedStreams);
            
            if dStreamIndex <= dNumPreAllocatedStreams
                RandomNumberGenerator.SetStreamAsGlobalStream(obj.c1oPreAllocatedStreams{dStreamIndex});
            else
                error(...
                    'RandomNumberGenerator:SetPreAllocatedStreamAsGlobalStream:NotEnoughStreams',...
                    ['The requested stream index of ', num2str(dStreamIndex), ' was greater than the number of pre-allocated streams (', num2str(dNumPreAllocatedStreams), ')']);
            end
        end        
        
        function CacheGlobalStream(obj)
            %CacheGlobalStream(obj)
            %
            % SYNTAX:
            %  CacheGlobalStream(obj)
            %
            % DESCRIPTION:
            %   Saves the current global RNG for future use.
            %   Useful to use before a for/parfor loop, such that it can be
            %   restored after the loop is complete
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
                        
            % cached current RNG global stream
            obj.c1oCachedGlobalStreams = [obj.c1oCachedGlobalStreams, {RandStream.getGlobalStream()}];
        end
        
        function SetCachedStreamAsGlobalStream(obj)
            %SetCachedStreamAsGlobalStream(obj)
            %
            % SYNTAX:
            %  SetCachedStreamAsGlobalStream(obj)
            %
            % DESCRIPTION:
            %  Restores the cached stream to be the global MATLAB RNG stream
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            if isempty(obj.c1oCachedGlobalStreams)
                error(...
                    'RandomNumberGenerator:SetCachedStreamAsGlobalStream:EmptyCachedStream',...
                    'There is no cached stream in the RandomNumberGenerator to be restored');
            else
                % set the global RNG stream
                obj.SetStreamAsGlobalStream(obj.c1oCachedGlobalStreams{end});
                
                % clear it out
                obj.c1oCachedGlobalStreams = obj.c1oCachedGlobalStreams(1:end-1);
            end
        end
        
        function SetNextStreamAsGlobalStream(obj)
            %SetNextStreamAsGlobalStream(obj)
            %
            % SYNTAX:
            %  SetNextStreamAsGlobalStream(obj)
            %
            % DESCRIPTION:
            %  Generates the next random number stream, and sets it to be
            %  the current global RNG stream.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
                        
            c1oStreams = obj.GetStreams(1);
            
            obj.SetStreamAsGlobalStream(c1oStreams{:});
        end
        
        
        % >>>>>>>>>>>>>>>>>> LOW LEVEL FUNCTION CALLS <<<<<<<<<<<<<<<<<<<<<
        
        function c1oStreams = GetStreams(obj, dNumStreams)
            %c1oStreams = GetStreams(obj, dNumStreams)
            %
            % SYNTAX:
            %  c1oStreams = GetStreams(obj, dNumStreams)
            %
            % DESCRIPTION:
            %  Returns dNumStreams stream objects in a cell array. Each
            %  stream object can be used to set-up a new and independent
            %  random number stream using:
            %   RandomNumberGenerator.SetMatlabGlobalRandomNumberStream(c1oStreams{i})
            %  Calling GetStreams again will result in new streams being
            %  given (stream index is automatically updated)
            % 
            %  e.g. 
            %   INCORRECT:
            %    streams1 = obj.GetStreams(5);
            %    streams2 = obj.GetStreams(10);
            %    streams2 = streams2(6:end); % get rid of the ones we got already
            %
            %   CORRECT:
            %    streams1 = obj.GetStreams(5);
            %    streams2 = obj.GetStreams(5); % same call, different streams
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dNumStreams: Number of streams to return
            %
            % OUTPUTS ARGUMENTS:
            %  c1oStreams: Cell array of stream objects with length
            %              determined by "dNumSreams"
            
            
            dNextStreamIndex = obj.dStreamIndex + dNumStreams;
            
            if (dNextStreamIndex - 1 ) <= obj.ui64TotalNumStreams % ensure max. number of streams has not been exceeded         
                c1oStreams = RandStream.create(...
                    obj.sType,...
                    'NumStreams', obj.ui64TotalNumStreams,...
                    'StreamIndices', obj.dStreamIndex : dNextStreamIndex - 1,... % specify only the streams we want
                    'Seed', obj.dSeed,...
                    'NormalTransform', obj.sNormalTransform,...
                    'CellOutput', obj.bCellOutput);
                
                obj.dStreamIndex = dNextStreamIndex; % increment stream index to ensure none are repeated
            else % error
                error('RandomNumberGenerator:GetStreams:TooManyStreams','More than the maximum of 2^63 streams have been requested from the stream generator.');
            end
        end
    end
    
    methods (Access = private, Static = true)
                
        function ThrowInvalidFromResetError()
            %ThrowInvalidFromResetError()
            %
            % SYNTAX:
            %  ThrowInvalidFromResetError()
            %
            % DESCRIPTION:
            %  Common function to return an exception if a "Reset" has been
            %  called but a pre-existing RandomNumberGenerator object has a
            %  call made on it
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            error(...
                'RandomNumberGenerator:InvalidObject',...
                'The random number object is invalid due to a "Reset" call. Use "RandomNumberGenerator(dSeed)" to produce a new valid object.');
        end
        
        % >>>>>>>>>>>>>>>>>> LOW LEVEL FUNCTION CALLS <<<<<<<<<<<<<<<<<<<<<
        
        function SetStreamAsGlobalStream(oStream)
            %SetStreamAsGlobalStream(oStream)
            %
            % SYNTAX:
            %  SetStreamAsGlobalStream(oStream)
            %
            % DESCRIPTION:
            %  Sets the Matlab "rng" variable, allowing all "random" calls
            %  (e.g. randi, etc.) to be from the supplied stream
            %
            % INPUT ARGUMENTS:
            %  oStream: Matlab RandStream object
            %
            % OUTPUTS ARGUMENTS:
            %  None
                        
            RandStream.setGlobalStream(oStream);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> HELPER FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function [chHostComputerName, dWorkerNumberOrProcessId] = GetCurrentComputationEnvironmentDetails()
            oTask = getCurrentTask();
            chHostComputerName = char(java.net.InetAddress.getLocalHost.getHostName);
            
            if isempty(oTask) % we're running locally and NOT as a batch
                dWorkerNumberOrProcessId = 0;
            else
                oWorker = oTask.Worker;
                
                if isa(oWorker, 'parallel.cluster.MJSWorker') % don't have access to process ID, extract the worker number from the worker name
                    chWorkerName = oWorker.Name;                    
                    chWorkerStringTag = '_worker';
                    
                    dWorkerIndex = strfind(chWorkerName, chWorkerStringTag);
                    
                    if ~isscalar(dWorkerIndex) || isnan(str2double(chWorkerName(dWorkerIndex+length(chWorkerStringTag) : end)))
                        error(...
                            'RandomNumberGenerator:GetCurrentComputationEnvironmentDetails:InvalidWorkerNameFormat',...
                            'Worker names must be specified as "<HOSTNAME>._workerXX"');
                    end
                    
                    dWorkerNumberOrProcessId = str2double(chWorkerName(dWorkerIndex+length(chWorkerStringTag) : end));
                elseif isa(oWorker, 'parallel.cluster.CJSWorker') % easy, pick off the process ID
                    dWorkerNumberOrProcessId = oWorker.ProcessId;
                else
                    error(...
                        'RandomNumberGenerator:GetCurrentComputationEnvironmentDetails:InvalidWorkerType',...
                        'Worker must be of type parallel.cluster.MJSWorker or parallel.cluster.CJSWorker');
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

