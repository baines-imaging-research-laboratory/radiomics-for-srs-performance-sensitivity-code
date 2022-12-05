classdef DCSResourceManagerRequest < handle
    %DCSResourceManagerRequest
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: August 26, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)        
        chSubmittingComputerName (1,:) char
        dSubmittingProcessId (1,1) double
        
        sClusterProfile (1,1) string
        
        dTimeout_hr (1,1) double {mustBePositive, mustBeFinite} = 1
    end
    
    properties (SetAccess = private, GetAccess = public)   
        sRequestId (1,1) string
        
        eRequestType (1,1) DCSResourceManagerRequestTypes
        dNumberOfWorkersInRequest double {ValidationUtils.MustBeEmptyOrScalar(dNumberOfWorkersInRequest)}
        
        dNumberOfWorkersAllocated (1,1) double = 0
        bAllocatedWorkersAreReady (1,1) logical = false
        
        dJobId double {ValidationUtils.MustBeEmptyOrScalar} = []
        dNumberOfWorkersInUse (1,1) double = 0
        
        bRequestTimeoutBasedOnCreationTimestamp (1,1) logical = true % if false, it'll be based off the job no longer being on the cluster job list
        
        dtCreationTimestamp (1,1) datetime
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false) 
    end
    
    
    methods (Access = public, Static = true) 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected)    
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
      
    methods (Access = {?DCSResourceManager, ?DCSResourceManagerUser}, Static = false) 
        
        function obj = DCSResourceManagerRequest(sRequestId, eRequestType, dNumberOfWorkers, sClusterProfile, dTimeout_hr)
            arguments
                sRequestId (1,1) string
                eRequestType (1,1) DCSResourceManagerRequestTypes
                dNumberOfWorkers double {ValidationUtils.MustBeEmptyOrScalar(dNumberOfWorkers)}
                sClusterProfile (1,1) string
                dTimeout_hr (1,1) double {mustBePositive, mustBeFinite} = 1
            end
            
            obj.sRequestId = sRequestId;
            
            obj.chSubmittingComputerName = char(ComputingEnvironmentUtils.GetCurrentComputerName());
            obj.dSubmittingProcessId = ComputingEnvironmentUtils.GetCurrentProcessId();
            
            obj.sClusterProfile = sClusterProfile;            
            
            obj.eRequestType = eRequestType;
            
            if eRequestType == DCSResourceManagerRequestTypes.AsManyAsPossible
                if ~isempty(dNumberOfWorkers)
                    error(...
                        'DCSResourceManagerRequest:Constructor:NumberOfWorkersNotEmpty',...
                        'The number of workers must be empty when requesting as many as possible.');
                end
            else
                if ~isscalar(dNumberOfWorkers)
                    error(...
                        'DCSResourceManagerRequest:Constructor:NumberOfWorkersNotScalar',...
                        'The number of workers must be scalar if not requesting as many as possible.');
                end
            end
            
            obj.dNumberOfWorkersInRequest = dNumberOfWorkers;            
            obj.dTimeout_hr = dTimeout_hr;
            
            obj.dtCreationTimestamp = datetime;         
        end
        
        function SetAllocatedWorkersAreReady(obj, bBool)
            arguments
                obj (1,1) DCSResourceManagerRequest
                bBool (1,1) logical
            end
            
            obj.bAllocatedWorkersAreReady = bBool;
        end
        
        function bBool = DoesRequireMoreWorkers(obj)
            bBool = obj.dNumberOfWorkersAllocated > obj.dNumberOfWorkersInUse;
        end
        
        function dtCreationTimestamp = GetCreationTimestamp(obj)
            dtCreationTimestamp = obj.dtCreationTimestamp;
        end
        
        function dNumWorkersNeeded = GetNumberOfWorkersRequiredToBeReady(obj)
            dNumWorkersNeeded = obj.dNumberOfWorkersAllocated - obj.dNumberOfWorkersInUse;
        end
        
        function chSubmittingComputerName = GetSubmittingComputerName(obj)
            chSubmittingComputerName = obj.chSubmittingComputerName;
        end
        
        function dSubmittingProcessId = GetSubmittingProcessId(obj)
            dSubmittingProcessId = obj.dSubmittingProcessId;
        end
        
        function IfLosingWorkersSetAllocatedWorkersReady(obj)
            if obj.dNumberOfWorkersAllocated < obj.dNumberOfWorkersInUse
                obj.bAllocatedWorkersAreReady = true;
            end
        end
        
        function ResetTimeout(obj)
            obj.dtCreationTimestamp = datetime;
        end
        
        function UpdateRequestForWorkers(obj, oRequestToUpdateFrom)
            obj.sRequestId = oRequestToUpdateFrom.sRequestId;
            obj.eRequestType = oRequestToUpdateFrom.eRequestType;
            obj.dNumberOfWorkersInRequest = oRequestToUpdateFrom.dNumberOfWorkersInRequest;
            obj.dtCreationTimestamp = datetime;
        end
            
        function PrepareForDelete(obj)
            if obj.DoesPoolCurrentlyExist()
                obj.MustBeAccessedBySameSubmittingMatlabInstance(); % or else the current parpool can't be deleted
            
                delete(ParallelComputingUtils.GetCurrentParpool());
            end
        end
        
        function DeletePoolIfItExistsAndFromIncorrectProfile(obj)
            oPool = ParallelComputingUtils.GetCurrentParpool();
            
            if ~isempty(oPool)
                if string(oPool.Cluster.Profile) ~= obj.sClusterProfile
                    delete(oPool);
                end
            end
        end
        
        function [bWorkersAreAvailable, dNumWorkersAvailable] = CheckIfRequestedWorkersAreAvailable(obj)
            bWorkersAreAvailable = obj.bAllocatedWorkersAreReady;
            
            if obj.bAllocatedWorkersAreReady
                dNumWorkersAvailable = obj.dNumberOfWorkersAllocated;
            else
                dNumWorkersAvailable = [];
            end
            
            % reset timeout
            obj.dtCreationTimestamp = datetime;
        end
        
        function [oPool, bMakeNewPool] = CreatePool(obj, vdCurrentJobIds)            
            obj.MustBeAccessedBySameSubmittingMatlabInstance();
            
            bMakeNewPool = false;
                        
            obj.DeletePoolIfItExistsAndFromIncorrectProfile();
            
            if obj.DoesPoolCurrentlyExist()
                if obj.dNumberOfWorkersAllocated == obj.dNumberOfWorkersInUse
                    oPool = ParallelComputingUtils.GetCurrentParpool(); % just get the current pool, no change
                elseif obj.bAllocatedWorkersAreReady % change is needed (e.g. more/less cores, and the change can be made)
                    delete(ParallelComputingUtils.GetCurrentParpool());
                    
                    bMakeNewPool = true;
                else % change is needed, but the cores aren't free yet
                    oPool = [];
                end
            else
                if obj.bAllocatedWorkersAreReady
                    bMakeNewPool = true;
                else
                    oPool = [];
                    obj.dtCreationTimestamp = datetime;
                end
            end
            
            if bMakeNewPool
                c1xParpoolVarargin = {...
                    'AutoAddClientPath', false,...
                    'AttachedFiles', {}};
                
                dtSubmitTime = datetime;
                oPool = parpool(obj.sClusterProfile, obj.dNumberOfWorkersAllocated, 'IdleTimeout', round(obj.dTimeout_hr*60), c1xParpoolVarargin{:});
                
                dJobId = DCSResourceManager.GetNewJobId(vdCurrentJobIds, dtSubmitTime, obj.sClusterProfile);
                
                obj.dNumberOfWorkersInUse = obj.dNumberOfWorkersAllocated;
                obj.dJobId = dJobId;
                obj.bRequestTimeoutBasedOnCreationTimestamp = false; %once the job is free, it's done
            end
        end
        
        function bBool = IsTimedOut(obj, vdRunningJobIds)
            if obj.bRequestTimeoutBasedOnCreationTimestamp % based on request creation timestamp
                dtNow = datetime;
                
                bBool = datetime > obj.dtCreationTimestamp + duration(obj.dTimeout_hr, 0, 0);                
            else % based off of if job is still running
                if any(obj.dJobId == vdRunningJobIds) % still active
                    bBool = false;
                else
                    bBool = datetime > obj.dtCreationTimestamp + duration(obj.dTimeout_hr, 0, 0); % the parpool was running, stopped, and then the timeout elapse, and the creation timeout must be elapsed
                end
            end
        end
        
        function UpdateRequest(obj, vdRunningJobIds)
            if isempty(obj.dJobId)
                % do nothing
            elseif ~any(obj.dJobId == vdRunningJobIds)
                obj.dJobId = [];
                obj.bRequestTimeoutBasedOnCreationTimestamp = true;
                obj.dNumberOfWorkersInUse = 0;
            end
        end
        
        function SetNumberOfWorkersAllocated(obj, dNumWorkersAllocated)
            arguments
                obj (1,1) DCSResourceManagerRequest
                dNumWorkersAllocated (1,1) double {mustBeInteger, mustBePositive}
            end
            
            obj.dNumberOfWorkersAllocated = dNumWorkersAllocated;
        end
        
        function bBool = IsRequestingAsManyAsPossible(obj)
            bBool = obj.eRequestType.IsRequestingAsManyAsPossible();
        end
        
        function sId = GetId(obj)
            sId = obj.sRequestId;
        end
        
        function dJobId = GetJobId(obj)
            dJobId = obj.dJobId;
        end
        
        function dNumWorkersInUse = GetNumberOfWorkersInUse(obj)
            dNumWorkersInUse = obj.dNumberOfWorkersInUse;
        end
        
        function dNumWorkersInRequest = GetNumberOfWorkersInRequest(obj)
            dNumWorkersInRequest = obj.dNumberOfWorkersInRequest;
        end
        
        function eRequestType = GetRequestType(obj)
            eRequestType = obj.eRequestType;
        end
        
        function sString = GetRequestStringForDisplay(obj)
            switch obj.eRequestType
                case DCSResourceManagerRequestTypes.AsManyAsPossible
                    sString = "AMAP";
                case DCSResourceManagerRequestTypes.AsManyAsPossibleMinus
                    sString = "AMAP -" + string(num2str(obj.dNumberOfWorkersInRequest));
                case DCSResourceManagerRequestTypes.NumberOfWorkers 
                    sString = string(num2str(obj.dNumberOfWorkersInRequest));
                otherwise
                    error(...
                        'DCSResourceManagerRequest:GetRequestStringForDisplay:InvalidRequestType',...
                        'Unknown request type.');
            end     
        end
        
        function dNumWorkers = GetNumberOfWorkersAllocated(obj)
            dNumWorkers = obj.dNumberOfWorkersAllocated;
        end
        
        function bBool = AreAllocatedWorkersReady(obj)
            bBool = obj.bAllocatedWorkersAreReady;
        end
    end
    
    
    methods (Access = private, Static = false)
        
        function MustBeAccessedBySameSubmittingMatlabInstance(obj)
            chSubmittingComputerName = char(ComputingEnvironmentUtils.GetCurrentComputerName());
            dSubmittingProcessId = ComputingEnvironmentUtils.GetCurrentProcessId();
            
            if ~strcmp(chSubmittingComputerName, obj.chSubmittingComputerName) || dSubmittingProcessId ~= obj.dSubmittingProcessId
                error(...
                    'DCSResourceManagerRequest:MustBeAccessedBySameSubmittingMatlabInstance:NotSameMatlabInstance',...
                    'Each request can only create pools for the Matlab instance that issued it.');
            end
        end
        
        function bBool = DoesPoolCurrentlyExist(obj)
            bBool = obj.dNumberOfWorkersInUse > 0;
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

