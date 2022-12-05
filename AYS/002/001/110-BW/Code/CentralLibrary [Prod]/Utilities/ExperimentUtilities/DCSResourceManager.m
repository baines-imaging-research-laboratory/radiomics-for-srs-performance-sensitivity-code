classdef DCSResourceManager < handle
    %DCSResourceManager
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: August 26, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        sClusterProfile (1,1) string
    end
    
    properties (SetAccess = private, GetAccess = public)
        voUsers (1,:) DCSResourceManagerUser
        
        vdCurrentJobIds (1,:) double
    end
    
    properties (Access = private, Constant = true)
        chManagerFilename = 'DCS Resource Manager.mat'
        chSemaphoreFilename = 'DCS Resource Manager.smphr'
        
        chFileVarName (1,:) char = 'oDCSResourceManager'
        
        dSemaphoreCheckInTime_s = 30
        dCreatePoolCheckInTime_minutes = 5
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = false)
        
    end
    
    
    methods (Access = public, Static = true)
        
        function Connect(sDirPath, NameValueArgs)
            arguments
                sDirPath (1,1) string
                NameValueArgs.Verbose (1,1) logical = true
            end
            
            DCSResourceManager.ValidateOS();
            
            DCSResourceManager.LoadManager(sDirPath);
            
            DCSResourceManager.GetOrSetPersistentVar('Set', sDirPath);
            
            if NameValueArgs.Verbose
                disp("Successfully connected to: " + sDirPath);
            end
        end
        
        function Initialize(sClusterProfile, sDirPath)
            arguments
                sClusterProfile (1,1) string
                sDirPath (1,1) string
            end
            
            DCSResourceManager.ValidateOS();
            
            obj = DCSResourceManager(sClusterProfile);
            
            obj.SaveManager(sDirPath);
            
            disp("Successfully initialized DCS Resource Manager at: " + sDirPath);
            
            DCSResourceManager.Connect(sDirPath);
        end
        
        function AddNewUser(sUsername)
            arguments
                sUsername (1,1) string
            end
            
            DCSResourceManager.ValidateOS();
            
            oNewUser = DCSResourceManagerUser(sUsername);
            
            obj = DCSResourceManager.GetConnectedManager();
            
            oError = [];
            
            try
                obj.AddNewUser_private(oNewUser);
            catch e
                oError = e;
            end
            
            if isempty(oError)
                obj.SetConnectedManager();
                
                disp("Successfully added user: " + sUsername);
            else
                obj.RecoverFromError(oError);
            end
        end
        
        function Status()
            DCSResourceManager.ValidateOS();
            
            obj = DCSResourceManager.GetConnectedManager();
            
            oError = [];
            
            try
                obj.UpdateRequests();
                
                obj.Display;
            catch e
                oError = e;
            end
            
            if isempty(oError)
                obj.SetConnectedManager();
            else
                obj.RecoverFromError(oError);
            end
        end
        
        function oRequest = RequestWorkers(sRequestId, varargin)
            %oRequest = RequestWorkers(sRequestId, varargin)
            %
            % SYNTAX:
            %  DCSResourceManager.RequestWorkers(sRequestId, 'AsManyAsPossible')
            %  DCSResourceManager.RequestWorkers(sRequestId, 'AsManyAsPossibleMinus', n)
            %  DCSResourceManager.RequestWorkers(sRequestId, n)
            %  DCSResourceManager.RequestWorkers(..., 'Timeout', hours)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            DCSResourceManager.ValidateOS();
            
            [eRequestType, dNumberOfWorkers, c1xRequestConstructorVarargin] = DCSResourceManager.ParseInputForRequestSubmitOrUpdate(varargin);
            
            oRequest = DCSResourceManager.SubmitRequest(sRequestId, eRequestType, dNumberOfWorkers, c1xRequestConstructorVarargin);
        end
        
        function [oPool, bNewPoolCreated] = GetRequestedPoolWhenAvailable()  
            DCSResourceManager.ValidateOS();
            
            [oPool, bNewPoolCreated] = DCSResourceManager.CreatePoolWhenAvailable();
        end
        
        function dNumWorkersAvailable = WaitForRequestedWorkersToBeAvailable()
            DCSResourceManager.ValidateOS();
            
            chSubmittingComputerName = ComputingEnvironmentUtils.GetCurrentComputerName();
            dSubmittingProcessId = ComputingEnvironmentUtils.GetCurrentProcessId();
            
            while true
                tic;
                [bWorkersAvailable, dNumWorkersAvailable] = DCSResourceManager.CheckIfRequestedWorkersAreAvailable(chSubmittingComputerName, dSubmittingProcessId);
                dTimeTaken_seconds = round(toc);
                
                if bWorkersAvailable
                    break;
                else
                    dPauseLength_s = (DCSResourceManager.dCreatePoolCheckInTime_minutes*60) - dTimeTaken_seconds;
                    
                    dtNextCheckTime = datetime + duration(0,0,dPauseLength_s);
                    
                    disp(['The allocated workers for the request are not yet free. Another attempt will be made at ', char(dtNextCheckTime), '.']);
                    pause((DCSResourceManager.dCreatePoolCheckInTime_minutes*60) - dTimeTaken_seconds);
                end
            end
        end
                
        function ResetTimeout()
            DCSResourceManager.ValidateOS();
            
            obj = DCSResourceManager.GetConnectedManager();
            
            oError = [];
            
            try
                obj.UpdateRequests();
                
                oUser = obj.GetUserByUsername(ComputingEnvironmentUtils.GetCurrentUsername());
                
                oUser.ResetTimeoutForRequestBySubmittingComputerNameAndProcessId(char(ComputingEnvironmentUtils.GetCurrentComputerName()), ComputingEnvironmentUtils.GetCurrentProcessId());
                
                obj.UpdateRequests();
            catch e
                oError = e;
            end
            
            if isempty(oError)
                obj.SetConnectedManager();
            else
                obj.RecoverFromError(oError);
            end
        end
        
        function DeleteRequest(NameValueArgs)
            arguments
                NameValueArgs.ComputerName (1,:) char = char(ComputingEnvironmentUtils.GetCurrentComputerName())
                NameValueArgs.ProcessId (1,1) double = ComputingEnvironmentUtils.GetCurrentProcessId()
            end
            
            DCSResourceManager.ValidateOS();
                        
            obj = DCSResourceManager.GetConnectedManager();
            
            oError = [];
            
            try
                obj.UpdateRequests();
                
                oUser = obj.GetUserByUsername(ComputingEnvironmentUtils.GetCurrentUsername());
                
                oUser.DeleteRequestBySubmittingComputerNameAndProcessId(NameValueArgs.ComputerName, NameValueArgs.ProcessId);
                
                obj.UpdateRequests();
            catch e
                oError = e;
            end
            
            if isempty(oError)
                obj.SetConnectedManager();
            else
                obj.RecoverFromError(oError);
            end
        end
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
    
    methods (Access = private, Static = false)
        
        function obj = DCSResourceManager(sClusterProfile)
            %obj = DCSResourceManager
            %
            % SYNTAX:
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            obj.sClusterProfile = sClusterProfile;
        end
        
        function SetConnectedManager(obj)
            obj.SaveManager(DCSResourceManager.GetOrSetPersistentVar());
            
            obj.ReleaseSemaphore();
        end
        
        function SaveManager(obj, sFilePath)
            FileIOUtils.SaveMatFile(fullfile(sFilePath, DCSResourceManager.chManagerFilename), DCSResourceManager.chFileVarName, obj);
        end
        
        function AddNewUser_private(obj, oNewUser)
            for dUserIndex=1:length(obj.voUsers)
                if obj.voUsers(dUserIndex).GetUsername() == oNewUser.GetUsername()
                    error(...
                        'DCSResourceManager:AddNewUser:UserAlreadyExists',...
                        'A user with that username already exists.');
                end
            end
            
            obj.voUsers = [obj.voUsers, oNewUser];
        end
        
        function oUser = GetUserByUsername(obj, sUsername)
            dMatchIndex = 0;
            
            for dIndex=1:length(obj.voUsers)
                if sUsername == obj.voUsers(dIndex).GetUsername()
                    dMatchIndex = dIndex;
                    break;
                end
            end
            
            if dMatchIndex == 0
                error(...
                    'DCSResourceManager:etUserByUsername:NotFound',...
                    'User with matching username not found.');
            else
                oUser = obj.voUsers(dIndex);
            end
        end
        
        function UpdateRequests(obj)
            oCluster = parcluster(obj.sClusterProfile);
            
            vdJobIds = DCSResourceManager.GetRunningJobIds(oCluster);
            obj.vdCurrentJobIds = vdJobIds;
            
            for dUserIndex=1:length(obj.voUsers)
                obj.voUsers(dUserIndex).UpdateRequests(vdJobIds);
            end
            
            obj.ReallocateWorkers(oCluster);
            obj.SetIfWorkersForRequestsAreFree(oCluster);
        end
        
        function RecoverFromError(obj, oError)
            obj.ReleaseSemaphore();
            rethrow(oError);
        end
        
        function SetIfWorkersForRequestsAreFree(obj, oCluster)
            % find number of workers free
            dNumWorkersInUse = 0;
            
            for dUserIndex=1:length(obj.voUsers)
                dNumWorkersInUse = dNumWorkersInUse + obj.voUsers(dUserIndex).GetNumberOfWorkersInUse();
            end
            
            dNumWorkersInCluster = oCluster.NumWorkers;
            dNumWorkersFree = dNumWorkersInCluster - dNumWorkersInUse;
            
            % for requests that are losing workers, the workers are free :)
            for dUserIndex=1:length(obj.voUsers)
                obj.voUsers(dUserIndex).SetAllRequestsLosingWorkersToHaveAllocatedWorkersReady();
            end
            
            % find the requests that need more workers than they currently
            % do and then assign workers
            voRequestsNeedingWorkers = DCSResourceManagerRequest.empty;
            
            for dUserIndex=1:length(obj.voUsers)
                voRequestsNeedingWorkers = [voRequestsNeedingWorkers, obj.voUsers(dUserIndex).GetAllRequestsRequiringMoreWorkers()];
            end
            
            dNumRequests = length(voRequestsNeedingWorkers);
            
            vdtRequestSubmitTimestamps = NaT(dNumRequests,1);
            
            for dRequestIndex=1:dNumRequests
                vdtRequestSubmitTimestamps(dRequestIndex) = voRequestsNeedingWorkers(dRequestIndex).GetCreationTimestamp();
            end
            
            [~,vdSortIndices] = sort(vdtRequestSubmitTimestamps, 'ascend'); % earliest first
            
            voRequestsNeedingWorkers = voRequestsNeedingWorkers(vdSortIndices);
            
            for dRequestIndex=1:dNumRequests
                oRequest = voRequestsNeedingWorkers(dRequestIndex);
                
                dNumWorkersNeeded = oRequest.GetNumberOfWorkersRequiredToBeReady();
                
                if dNumWorkersFree >= dNumWorkersNeeded
                    oRequest.SetAllocatedWorkersAreReady(true);
                    dNumWorkersFree = dNumWorkersFree - dNumWorkersNeeded;
                else
                    break;
                end
            end
        end
        
        function ReallocateWorkers(obj, oCluster)
            voUsers = obj.voUsers;
            dNumUsers = length(voUsers);
            
            vdUserIndices = (1:dNumUsers)';
            
            vbUserWantsAsManyWorkersAsPossible = false(dNumUsers,1);
            vdNumberOfWorkersUserWantsToLeaveFree = zeros(dNumUsers,1);
            vdNumberOfOtherWorkersUserWants = zeros(dNumUsers,1);
            
            for dUserIndex=1:dNumUsers
                [...
                    vbUserWantsAsManyWorkersAsPossible(dUserIndex),...
                    vdNumberOfWorkersUserWantsToLeaveFree(dUserIndex),...
                    vdNumberOfOtherWorkersUserWants(dUserIndex)]...
                    = voUsers(dUserIndex).GetWorkerRequestSummary();
            end
            
            vbUserWantsWorkers = vbUserWantsAsManyWorkersAsPossible | vdNumberOfOtherWorkersUserWants ~= 0;
            
            vdUserIndices = vdUserIndices(vbUserWantsWorkers);
            
            vbUserWantsAsManyWorkersAsPossible = vbUserWantsAsManyWorkersAsPossible(vbUserWantsWorkers);
            vdNumberOfWorkersUserWantsToLeaveFree = vdNumberOfWorkersUserWantsToLeaveFree(vbUserWantsWorkers);
            vdNumberOfOtherWorkersUserWants = vdNumberOfOtherWorkersUserWants(vbUserWantsWorkers);
            
            if ~isempty(vdUserIndices)
                
                if ~any(vbUserWantsAsManyWorkersAsPossible)
                    % no user wants as many as possible, so just give the users the number of workers they want
                    % if there's more requests than available workers error
                    % out
                    
                    dNumWorkersAvailable = oCluster.NumWorkers;
                    
                    if sum(vdNumberOfOtherWorkersUserWants) > dNumWorkersAvailable
                        error(...
                            'DCSResourceManager:ReallocateWorkers:InvalidRequests',...
                            'The number of workers in total requested is more than the number available.')
                    end
                    
                    for dUpdateUserIndex=1:length(vdUserIndices)
                        obj.voUsers(vdUserIndices(dUpdateUserIndex)).SetNumberOfWorkersAllocatedForRequests(vdNumberOfOtherWorkersUserWants(dUpdateUserIndex));
                    end
                else
                    dNumUsersWhoWantWorkers = sum(vbUserWantsWorkers);
                    dNumWorkersAvailable = oCluster.NumWorkers;
                    
                    % Worker allocation:
                    % 1) Split workers evenly between those who want them
                    dNumWorkersPerUser = floor(dNumWorkersAvailable / dNumUsersWhoWantWorkers);
                    dNumLeftoverWorkers = rem(dNumWorkersAvailable, dNumUsersWhoWantWorkers);
                    
                    vdFairShareNumberOfWorkersPerUser = repmat(dNumWorkersPerUser,dNumUsersWhoWantWorkers,1);
                    
                    % 2) Randomly assign the leftover workers if not an even split
                    if dNumLeftoverWorkers ~= 0
                        vdBonusWorkerIndices = JavaUtils.GetRandPerm(dNumUsersWhoWantWorkers); % use JavaUtils.GetRandPerm instead of randperm to avoid messing up experiment reproducibility by not using Matlab's random numbers
                        vdBonusWorkerIndices = vdBonusWorkerIndices(1:dNumLeftoverWorkers);
                        vdFairShareNumberOfWorkersPerUser(vdBonusWorkerIndices) = vdFairShareNumberOfWorkersPerUser(vdBonusWorkerIndices) + 1;
                    end
                    
                    % 3) For users who want a set number of workers
                    % - if they want less than their "fair share", allow that
                    % number of workers
                    % - if they want more than their "fair share", keep them at
                    % their "fair share"
                    vdNumberOfOtherWorkersAllocatedPerUser = min(vdFairShareNumberOfWorkersPerUser, vdNumberOfOtherWorkersUserWants);
                    
                    % 4) Assign workers for users who want as many as possible
                    % (AMAP)
                    vdNumberOfAMAPWorkersAllocatedPerUser = vdFairShareNumberOfWorkersPerUser - vdNumberOfOtherWorkersAllocatedPerUser;
                    
                    dNumberOfUnneededAMAPWorkers = sum(vdNumberOfAMAPWorkersAllocatedPerUser(~vbUserWantsAsManyWorkersAsPossible));
                    vdNumberOfAMAPWorkersAllocatedPerUser(~vbUserWantsAsManyWorkersAsPossible) = 0;
                    
                    % 5) Redistribute the unneeded AMAP workers
                    dNumUsersToDistributeOver = sum(vbUserWantsAsManyWorkersAsPossible);
                    
                    dNumWorkersPerUser = floor(dNumberOfUnneededAMAPWorkers / dNumUsersToDistributeOver);
                    
                    vdNumberOfAMAPWorkersAllocatedPerUser(vbUserWantsAsManyWorkersAsPossible) = vdNumberOfAMAPWorkersAllocatedPerUser(vbUserWantsAsManyWorkersAsPossible) + dNumWorkersPerUser;
                    
                    dNumLeftoverWorkers = rem(dNumberOfUnneededAMAPWorkers, dNumUsersToDistributeOver);
                    
                    vdUserIndicesInLottery = find(vbUserWantsAsManyWorkersAsPossible);
                    vdRandomIndices = JavaUtils.GetRandPerm(dNumUsersToDistributeOver); % use JavaUtils.GetRandPerm instead of randperm to avoid messing up experiment reproducibility by not using Matlab's random numbers
                    vdSelectedIndices = vdUserIndicesInLottery(vdRandomIndices(1:dNumLeftoverWorkers));
                    
                    vdNumberOfAMAPWorkersAllocatedPerUser(vdSelectedIndices) = vdNumberOfAMAPWorkersAllocatedPerUser(vdSelectedIndices) + 1;
                    
                    % 6) Check if enough non-AMAP workers are left to obey the
                    % AMAP-minus requests
                    if dNumWorkersAvailable - sum(vdNumberOfAMAPWorkersAllocatedPerUser) < max(vdNumberOfWorkersUserWantsToLeaveFree) % need to free some more up
                        dNumWorkersToBeUnallocated = max(vdNumberOfWorkersUserWantsToLeaveFree) - sum(vdNumberOfOtherWorkersAllocatedPerUser);
                        
                        vdUnallocationSelectionVector = vdNumberOfWorkersUserWantsToLeaveFree;
                        vdUnallocationSelectionVector(~vbUserWantsAsManyWorkersAsPossible) = 0;
                        
                        for dUnallocateIndex=dNumWorkersToBeUnallocated:-1:1
                            [~, dMaxIndex] = max(vdUnallocationSelectionVector);
                            
                            vdNumberOfAMAPWorkersAllocatedPerUser(dMaxIndex) = vdNumberOfAMAPWorkersAllocatedPerUser(dMaxIndex) - 1;
                            vdUnallocationSelectionVector(dMaxIndex) = vdUnallocationSelectionVector(dMaxIndex) - 1;
                        end
                    end
                    
                    
                    % now give each user their workers (user to update their
                    % requests accordingly)
                    vdTotalNumberOfWorkersAllocatedPerUser = vdNumberOfOtherWorkersAllocatedPerUser + vdNumberOfAMAPWorkersAllocatedPerUser;
                    
                    for dUpdateUserIndex=1:length(vdTotalNumberOfWorkersAllocatedPerUser)
                        obj.voUsers(vdUserIndices(dUpdateUserIndex)).SetNumberOfWorkersAllocatedForRequests(vdTotalNumberOfWorkersAllocatedPerUser(dUpdateUserIndex));
                    end
                end
            end
        end
        
        function Display(obj)
            sCurrentUsername = ComputingEnvironmentUtils.GetCurrentUsername();
            chCurrentComputerName = char(ComputingEnvironmentUtils.GetCurrentComputerName());
            dCurrentProcessId = ComputingEnvironmentUtils.GetCurrentProcessId();
            
            sDirPath = DCSResourceManager.GetOrSetPersistentVar();
            oCluster = obj.GetCluster();
            
            disp("Connected to: " + sDirPath);
            disp("Cluster profile: " + obj.sClusterProfile);
            disp("Number of workers: " + string(num2str(oCluster.NumWorkers)));
            disp(' ');
            
            dNumCharsForUsername = 20;
            dNumCharsForComputerName = 13;
            dNumCharsForProcessId = 6;
            dNumCharsForRequestId = 15;
            dNumCharsForRequest = 9;
            dNumCharsForNumWorkersAllocated = 9;
            dNumCharsForNumWorkersInUse = 9;
            dNumCharsForJobId = 6;
            dNumCharsForWorkersReady = 7;
            
            fprintf(['%', num2str(dNumCharsForUsername), 's | %', num2str(dNumCharsForComputerName), 's | %', num2str(dNumCharsForProcessId), 's | %', num2str(dNumCharsForRequestId), 's | %', num2str(dNumCharsForRequest), 's | %', num2str(dNumCharsForNumWorkersAllocated), 's | %', num2str(dNumCharsForNumWorkersInUse), 's | %', num2str(dNumCharsForJobId), 's | %', num2str(dNumCharsForWorkersReady), 's', newline],...
                'Username', 'Computer Name', 'PID', 'Request ID', 'Request', '# Workers', '# Workers', 'Job ID', 'Workers');
            fprintf(['%', num2str(dNumCharsForUsername), 's | %', num2str(dNumCharsForComputerName), 's | %', num2str(dNumCharsForProcessId), 's | %', num2str(dNumCharsForRequestId), 's | %', num2str(dNumCharsForRequest), 's | %', num2str(dNumCharsForNumWorkersAllocated), 's | %', num2str(dNumCharsForNumWorkersInUse), 's | %', num2str(dNumCharsForJobId), 's | %', num2str(dNumCharsForWorkersReady), 's', newline],...
                '', '', '', '', '', 'Allocated', 'In Use', '', 'Ready?');
            
            for dUserIndex=1:length(obj.voUsers)
                fprintf(['%', num2str(dNumCharsForUsername), 's-+-%', num2str(dNumCharsForComputerName), 's-+-%', num2str(dNumCharsForProcessId), 's-+-%', num2str(dNumCharsForRequestId), 's-+-%', num2str(dNumCharsForRequest), 's-+-%', num2str(dNumCharsForNumWorkersAllocated), 's-+-%', num2str(dNumCharsForNumWorkersInUse), 's-+-%', num2str(dNumCharsForJobId), 's-+-%', num2str(dNumCharsForWorkersReady), 's', newline],...
                    repmat('-',1,dNumCharsForUsername), repmat('-',1,dNumCharsForComputerName), repmat('-',1,dNumCharsForProcessId), repmat('-',1,dNumCharsForRequestId), repmat('-',1,dNumCharsForRequest), repmat('-',1,dNumCharsForNumWorkersAllocated), repmat('-',1,dNumCharsForNumWorkersInUse), repmat('-',1,dNumCharsForJobId),  repmat('-',1,dNumCharsForWorkersReady));
                
                obj.voUsers(dUserIndex).DisplayRows(....
                    dNumCharsForUsername, dNumCharsForComputerName, dNumCharsForProcessId, dNumCharsForRequestId, dNumCharsForRequest, dNumCharsForNumWorkersAllocated, dNumCharsForNumWorkersInUse, dNumCharsForJobId, dNumCharsForWorkersReady,...
                    sCurrentUsername, chCurrentComputerName, dCurrentProcessId);
            end
            
            disp(' ');
            disp('* - Matches current Matlab instance');
        end
        
        function oCluster = GetCluster(obj)
            oCluster = parcluster(obj.sClusterProfile);
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function ValidateOS()
            if ~ispc
                error(...
                    'DCSResourceManager:ValidateOS:Invalid',...
                    'The DCSResourceManager can only be used if running Windows.');
            end
        end
    end
    
    
    methods (Access = {?DCSResourceManagerRequest}, Static = true)
        
        function dJobId = GetNewJobId(vdCurrentJobIds, dtSubmitTime, sClusterProfile)
            oCluster = parcluster(sClusterProfile);
            
            vdNewJobIds = DCSResourceManager.GetRunningJobIds(oCluster);
            
            vdDifferentJobIds = setdiff(vdNewJobIds, vdCurrentJobIds);
            
            dJobId = [];
            
            for dJobIndex=1:length(vdDifferentJobIds)
                oJob = oCluster.findJob('ID', vdDifferentJobIds(dJobIndex));
                
                if ~isempty(oJob)
                    dtFromClusterSubmitTime = oJob.SubmitDateTime;
                    dtFromClusterSubmitTime.TimeZone = '';
                    
                    if dtSubmitTime-duration(0,1,0) < dtFromClusterSubmitTime && dtFromClusterSubmitTime < dtSubmitTime+duration(0,1,0) % submit time must be within a minute of the recorded one
                        if ~isempty(dJobId)
                            error(...
                                'DCSResourceManager:GetNewJobId:MultipleMatches',...
                                'Multiple possible job IDs found.');
                        end
                        
                        dJobId = vdDifferentJobIds(dJobIndex);
                    end
                end
            end
            
            if isempty(dJobId)
                error(...
                    'DCSResourceManager:GetNewJobId:NoMatch',...
                    'No job ID found.');
            end
        end
    end
    
    
    methods (Access = private, Static = true)
        
        function vdJobIds = GetRunningJobIds(oCluster)
            voJobs = oCluster.Jobs;
            
            dNumJobs = length(voJobs);
            
            vdJobIds = zeros(dNumJobs,1);
            vbIsRunning = false(dNumJobs,1);
            
            for dJobIndex=1:dNumJobs
                if strcmp(voJobs(dJobIndex).State, 'running')
                    vdJobIds(dJobIndex) = voJobs(dJobIndex).ID;
                    vbIsRunning(dJobIndex) = true;
                end
            end
            
            vdJobIds = vdJobIds(vbIsRunning);
        end
        
        function sDirPath = GetOrSetPersistentVar(NameValueArgs)
            arguments
                NameValueArgs.Set
            end
            
            persistent sDCSResourceManagerDirectory;
            
            if isfield(NameValueArgs, 'Set')
                sDCSResourceManagerDirectory = NameValueArgs.Set;
            else
                if isempty(sDCSResourceManagerDirectory)
                    error(...
                        'DCSResourceManager:GetOrSetPersistentVar:NotConnected',...
                        'Not connected to a DCS Resource Manager file.');
                end
                
                sDirPath = sDCSResourceManagerDirectory;
            end
        end
        
        function oRequest = SubmitRequest(sRequestId, eRequestType, dNumberOfWorkers, c1xRequestVarargin)
            obj = DCSResourceManager.GetConnectedManager();
            
            oError = [];
            
            try
                obj.UpdateRequests();
                
                oRequest = DCSResourceManagerRequest(sRequestId, eRequestType, dNumberOfWorkers, obj.sClusterProfile, c1xRequestVarargin{:});
                
                sUsername = ComputingEnvironmentUtils.GetCurrentUsername();
                
                oUser = obj.GetUserByUsername(sUsername);
                oUser.AddOrUpdateRequest(oRequest);
                
                obj.UpdateRequests();
            catch e
                oError = e;
            end
            
            if isempty(oError)
                obj.SetConnectedManager();
            else
                obj.RecoverFromError(oError);
            end
        end
        
        function UpdateRequest_private(oRequest, eRequestType, dNumberOfWorkers)
            obj = DCSResourceManager.GetConnectedManager();
            
            obj.UpdateRequests();
            
            sUsername = ComputingEnvironmentUtils.GetCurrentUsername();
            
            oUser = obj.GetUserByUsername(sUsername);
            oUser.UpdateRequest(oRequest, eRequestType, dNumberOfWorkers);
            
            obj.UpdateRequests();
            
            obj.SetConnectedManager();
        end
        
        function obj = GetConnectedManager(chReadOnlyFlag)
            arguments
                chReadOnlyFlag (1,:) char = ''
            end
            
            if ~strcmp(chReadOnlyFlag, 'read-only')
                DCSResourceManager.CheckAndSetSemaphore();
            end
            
            obj = DCSResourceManager.LoadManager(DCSResourceManager.GetOrSetPersistentVar());
        end
        
        function CheckAndSetSemaphore()
            sDirPath = DCSResourceManager.GetOrSetPersistentVar();
            
            sSemaphoreFilePath = fullfile(sDirPath, DCSResourceManager.chSemaphoreFilename);
            
            while true
                if ~isfile(sSemaphoreFilePath)
                    fclose(fopen(sSemaphoreFilePath,'w'));
                    break;
                else
                    disp(['DCS Resource Manager is currently busy, another attempt will be made in ', num2str(DCSResourceManager.dSemaphoreCheckInTime_s), ' seconds.']);
                    pause(DCSResourceManager.dSemaphoreCheckInTime_s);
                end
            end
        end
        
        function ReleaseSemaphore()
            sDirPath = DCSResourceManager.GetOrSetPersistentVar();
            
            sSemaphoreFilePath = fullfile(sDirPath, DCSResourceManager.chSemaphoreFilename);
            
            delete(sSemaphoreFilePath);
        end
        
        function obj = LoadManager(sFilePath)
            sManagerFilePath = fullfile(sFilePath, DCSResourceManager.chManagerFilename);
            
            if ~isfile(sManagerFilePath)
                error(...
                    'DCSResourceManager:LoadManager:InvalidPath',...
                    'No file exsits at path.');
            end
            
            try
                obj = FileIOUtils.LoadMatFile(sManagerFilePath, DCSResourceManager.chFileVarName);
            catch
                error(...
                    'DCSResourceManager:LoadManager:InvalidMatFile',...
                    'Invalid .mat file.');
            end
            
            if ~isa(obj, 'DCSResourceManager')
                error(...
                    'DCSResourceManager:LoadManager:InvalidVar',...
                    'Invalid variable type in .mat file.');
            end
        end
        
        function [oPool, bCreatedNewPool] = CreatePoolForRequestBySubmittingComputerNameAndProcessId(chSubmittingComputerName, dProcessId)
            obj = DCSResourceManager.GetConnectedManager();
            
            oError = [];
            
            try
                obj.UpdateRequests();
                
                vdCurrentJobIds = obj.vdCurrentJobIds;
                
                oUser = obj.GetUserByUsername(ComputingEnvironmentUtils.GetCurrentUsername());
                
                [oPool, bCreatedNewPool] = oUser.CreatePoolForRequestBySubmittingComputerNameAndProcessId(chSubmittingComputerName, dProcessId, vdCurrentJobIds);
                
                obj.UpdateRequests();
            catch e
                oError = e;
            end
            
            if isempty(oError)
                obj.SetConnectedManager();
            else
                obj.RecoverFromError(oError);
            end
        end
        
        function [bWorkersAreAvailable, dNumWorkersAvailable] = CheckIfRequestedWorkersAreAvailable(chSubmittingComputerName, dProcessId)
            obj = DCSResourceManager.GetConnectedManager();
            
            oError = [];
            
            try
                obj.UpdateRequests();
                
                oUser = obj.GetUserByUsername(ComputingEnvironmentUtils.GetCurrentUsername());
                
                [bWorkersAreAvailable, dNumWorkersAvailable] = oUser.CheckIfRequestedWorkersAreAvailable(chSubmittingComputerName, dProcessId);
                
                obj.UpdateRequests();
            catch e
                oError = e;
            end
            
            if isempty(oError)
                obj.SetConnectedManager();
            else
                obj.RecoverFromError(oError);
            end
        end
        
        function [eRequestType, dNumberOfWorkers, c1xRequestConstructorVarargin] = ParseInputForRequestSubmitOrUpdate(c1xVarargin)
            dLengthVarargin = length(c1xVarargin);
            
            if dLengthVarargin < 1
                error(...
                    'DCSResourceManager:ParseInputForRequestSubmitOrUpdate:SyntaxError',...
                    'See documentation.');
            else
                xFirstVar = c1xVarargin{1};
                
                dNextVarIndex = 2;
                
                if isnumeric(xFirstVar)
                    dNumberOfWorkers = double(xFirstVar);
                    
                    ValidationUtils.MustBeScalar(dNumberOfWorkers);
                    mustBeInteger(dNumberOfWorkers);
                    mustBePositive(dNumberOfWorkers);
                    
                    eRequestType = DCSResourceManagerRequestTypes.NumberOfWorkers;
                elseif isstring(xFirstVar) || ischar(xFirstVar)
                    sRequestString = string(xFirstVar);
                    
                    ValidationUtils.MustBeScalar(sRequestString);
                    mustBeMember(sRequestString, ["AsManyAsPossible", "AsManyAsPossibleMinus"]);
                    
                    if sRequestString == "AsManyAsPossible"
                        eRequestType = DCSResourceManagerRequestTypes.AsManyAsPossible;
                        dNumberOfWorkers = [];
                    else
                        if dLengthVarargin == 1
                            error(...
                                'DCSResourceManager:ParseInputForRequestSubmitOrUpdate:SyntaxError',...
                                'See documentation.');
                        end
                        
                        xSecondVar = c1xVarargin{2};
                        
                        mustBeNumeric(xSecondVar);
                        
                        dNumberOfWorkers = double(xSecondVar);
                        
                        ValidationUtils.MustBeScalar(dNumberOfWorkers);
                        mustBeInteger(dNumberOfWorkers);
                        mustBePositive(dNumberOfWorkers);
                        
                        eRequestType = DCSResourceManagerRequestTypes.AsManyAsPossibleMinus;
                        
                        dNextVarIndex = 3;
                    end
                    
                else
                    error(...
                        'DCSResourceManager:ParseInputForRequestSubmitOrUpdate:SyntaxError',...
                        'See documentation.');
                end
                
                
                if dLengthVarargin == dNextVarIndex || dLengthVarargin > dNextVarIndex + 1
                    error(...
                        'DCSResourceManager:ParseInputForRequestSubmitOrUpdate:SyntaxError',...
                        'See documentation.');
                end
                
                if dLengthVarargin == dNextVarIndex + 1
                    xName = c1xVarargin(dNextVarIndex);
                    xValue = c1xVarargin(dNextVarIndex+1);
                    
                    if isstring(xName) || ischar(xName)
                        sName = string(xName);
                        
                        ValidationUtils.MustBeScalar(sName);
                        mustBeMember(sName, "Timeout");
                    else
                        error(...
                            'DCSResourceManager:ParseInputForRequestSubmitOrUpdate:SyntaxError',...
                            'See documentation.');
                    end
                    
                    if isnumeric(xValue)
                        dTimeout_hr = double(xValue);
                        
                        ValidationUtils.MustBeScalar(dTimeout_hr);
                        mustBeNonnegative(dTimeout_hr);
                        mustBeFinite(dTimeout_hr);
                    end
                    
                    c1xRequestConstructorVarargin = {dTimeout_hr};
                else
                    c1xRequestConstructorVarargin = {};
                end
            end
        end
    end
    
    
    methods (Access = {?DCSResourceManagerRequest}, Static = true)
        
        function [oPool, bNewPoolCreated] = CreatePoolWhenAvailable()
            chSubmittingComputerName = ComputingEnvironmentUtils.GetCurrentComputerName();
            dSubmittingProcessId = ComputingEnvironmentUtils.GetCurrentProcessId();
            
            while true
                tic;
                [oPool, bNewPoolCreated] = DCSResourceManager.CreatePoolForRequestBySubmittingComputerNameAndProcessId(chSubmittingComputerName, dSubmittingProcessId);
                dTimeTaken_seconds = round(toc);
                
                if ~isempty(oPool)
                    break;
                else
                    dPauseLength_s = (DCSResourceManager.dCreatePoolCheckInTime_minutes*60) - dTimeTaken_seconds;
                    
                    dtNextCheckTime = datetime + duration(0,0,dPauseLength_s);
                    
                    disp(['The allocated workers for the request are not yet free. Another attempt will be made at ', char(dtNextCheckTime), '.']);
                    pause((DCSResourceManager.dCreatePoolCheckInTime_minutes*60) - dTimeTaken_seconds);
                end
            end
        end
        
        function UpdateRequest(oRequest, varargin)
            arguments
                oRequest (1,1) DCSResourceManagerRequest
            end
            arguments (Repeating)
                varargin
            end
            
            [eRequestType, dNumberOfWorkers] = DCSResourceManager.ParseInputForRequestSubmitOrUpdate(varargin);% ignore the timeout
            
            DCSResourceManager.UpdateRequest_private(oRequest, eRequestType, dNumberOfWorkers);
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

