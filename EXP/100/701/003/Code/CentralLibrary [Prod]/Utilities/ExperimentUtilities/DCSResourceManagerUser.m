classdef DCSResourceManagerUser < handle
    %DCSResourceManagerUser
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: August 26, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        sUsername (1,1) string
    end
    
    properties (SetAccess = private, GetAccess = public)        
        voRequests (1,:) DCSResourceManagerRequest
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = DCSResourceManagerUser(sUsername)
            %obj = DCSResourceManagerUser(sUsername)
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
            
            arguments
                sUsername (1,1) string
            end
            
            obj.sUsername = sUsername;
        end     
        
        function sUsername = GetUsername(obj)
            sUsername = obj.sUsername;
        end
        
        function DisplayRows(obj, dNumCharsForUsername, dNumCharsForComputerName, dNumCharsForProcessId, dNumCharsForRequestId, dNumCharsForRequest, dNumCharsForNumWorkersAllocated, dNumCharsForNumWorkersInUse, dNumCharsForJobId, dNumCharsForWorkersReady, sCurrentUsername, chCurrentComputerName, dCurrentProcessId)
            if isempty(obj.voRequests)
                fprintf(['%', num2str(dNumCharsForUsername), 's | %', num2str(dNumCharsForComputerName), 's | %', num2str(dNumCharsForProcessId), 's | %', num2str(dNumCharsForRequestId), 's | %', num2str(dNumCharsForRequest), 's | %', num2str(dNumCharsForNumWorkersAllocated), 's | %', num2str(dNumCharsForNumWorkersInUse), 's | %', num2str(dNumCharsForJobId), 's | %', num2str(dNumCharsForWorkersReady), 's', newline],...
                obj.sUsername', '-', '-', '-', '-', '-', '-', '-', '-');
            else
                for dRequestIndex=1:length(obj.voRequests)
                    if dRequestIndex == 1
                        sUsername = obj.sUsername;
                        
                        if sUsername == sCurrentUsername
                            sUsername = sUsername + "*";
                        end
                    else
                        sUsername = "";
                    end
                    
                    oRequest = obj.voRequests(dRequestIndex);
                    
                    dJobId = oRequest.GetJobId();
                    
                    if isempty(dJobId)
                        chJobIdString = '-';
                        chNumberOfWorkersInUseString = '-';
                    else
                        chJobIdString = num2str(dJobId);
                        chNumberOfWorkersInUseString = num2str(oRequest.GetNumberOfWorkersInUse());
                    end   
                    
                    if oRequest.AreAllocatedWorkersReady()
                        chReadyString = 'Y';
                    else
                        chReadyString = 'N';
                    end
                    
                    
                    chSubmittingComputerName = oRequest.GetSubmittingComputerName();
                    
                    if strcmp(chSubmittingComputerName, chCurrentComputerName)
                        chSubmittingComputerName = [chSubmittingComputerName, '*'];
                    end
                    
                    dSubmittingProcessId = oRequest.GetSubmittingProcessId();
                    chSubmittingProcessId = num2str(dSubmittingProcessId);
                    
                    if dSubmittingProcessId == dCurrentProcessId
                        chSubmittingProcessId = [chSubmittingProcessId, '*'];
                    end
                    
                                        
                    fprintf(['%', num2str(dNumCharsForUsername), 's | %', num2str(dNumCharsForComputerName), 's | %', num2str(dNumCharsForProcessId), 's | %', num2str(dNumCharsForRequestId), 's | %', num2str(dNumCharsForRequest), 's | %', num2str(dNumCharsForNumWorkersAllocated), 'u | %', num2str(dNumCharsForNumWorkersInUse), 's | %', num2str(dNumCharsForJobId), 's | %', num2str(dNumCharsForWorkersReady), 's', newline],...
                        sUsername, chSubmittingComputerName, chSubmittingProcessId, oRequest.GetId(), oRequest.GetRequestStringForDisplay(), oRequest.GetNumberOfWorkersAllocated(), chNumberOfWorkersInUseString, chJobIdString, chReadyString);
                end
            end
        end
        
        function obj = AddOrUpdateRequest(obj, oRequest)
            arguments
                obj (1,1) DCSResourceManagerUser
                oRequest (1,1) DCSResourceManagerRequest
            end
            
            bUpdateRequest = false;
            dUpdateIndex = [];
            
            % validate
            for dRequestIndex=1:length(obj.voRequests)
                if strcmp(obj.voRequests(dRequestIndex).GetSubmittingComputerName(), oRequest.GetSubmittingComputerName()) && obj.voRequests(dRequestIndex).GetSubmittingProcessId() == oRequest.GetSubmittingProcessId()
                    bUpdateRequest = true;
                    dUpdateIndex = dRequestIndex;
                elseif oRequest.IsRequestingAsManyAsPossible() && obj.voRequests(dRequestIndex).IsRequestingAsManyAsPossible()
                    error(...
                        'DCSResourceManagerUser:AddOrUpdateRequest:MultipleAsManyAsPossibleRequests',...
                        'A request for as many as possible workers is already active for your username.');
                end
            end
            
            
            if bUpdateRequest
                obj.voRequests(dUpdateIndex).UpdateRequestForWorkers(oRequest);
            else
                % add request
                obj.voRequests = [obj.voRequests, oRequest];
            end
        end
        
        function DeleteRequestBySubmittingComputerNameAndProcessId(obj, chComputerName, dProcessId)
            arguments
                obj (1,1) DCSResourceManagerUser
                chComputerName (1,:) char
                dProcessId (1,1) double
            end
            
            dDeleteIndex = 0;
            
            for dRequestIndex=1:length(obj.voRequests)
                if strcmp(obj.voRequests(dRequestIndex).GetSubmittingComputerName(), chComputerName) && obj.voRequests(dRequestIndex).GetSubmittingProcessId() == dProcessId
                    dDeleteIndex = dRequestIndex;
                    break;
                end
            end
            
            if dDeleteIndex ~= 0    
                obj.voRequests(dDeleteIndex).PrepareForDelete();
                obj.voRequests(dDeleteIndex) = [];
            end            
        end
        
        function UpdateRequests(obj, vdRunningJobIds)
            dNumRequests = length(obj.voRequests);
            vbKeepRequest = true(1, dNumRequests);
            
            for dRequestIndex=1:dNumRequests
                if obj.voRequests(dRequestIndex).IsTimedOut(vdRunningJobIds)
                    vbKeepRequest(dRequestIndex) = false;
                else
                    obj.voRequests(dRequestIndex).UpdateRequest(vdRunningJobIds);
                end
            end
            
            obj.voRequests = obj.voRequests(vbKeepRequest);
        end
        
        function [bUserWantsAsManyWorkersAsPossible, dNumberOfWorkersUserWantsToLeaveFree, dNumberOfOtherWorkersUserWants] = GetWorkerRequestSummary(obj)
            bUserWantsAsManyWorkersAsPossible = false;
            dNumberOfWorkersUserWantsToLeaveFree = 0;
            dNumberOfOtherWorkersUserWants = 0;
            
            for dRequestIndex=1:length(obj.voRequests)
                oRequest = obj.voRequests(dRequestIndex);
                
                if oRequest.IsRequestingAsManyAsPossible()
                    bUserWantsAsManyWorkersAsPossible = true;
                end
                
                switch oRequest.GetRequestType()
                    case DCSResourceManagerRequestTypes.AsManyAsPossibleMinus
                        dNumberOfWorkersUserWantsToLeaveFree = max(dNumberOfWorkersUserWantsToLeaveFree, oRequest.GetNumberOfWorkersInRequest());
                    case DCSResourceManagerRequestTypes.NumberOfWorkers
                        dNumberOfOtherWorkersUserWants = dNumberOfOtherWorkersUserWants + oRequest.GetNumberOfWorkersInRequest();
                end
            end
            
        end
        
        function SetNumberOfWorkersAllocatedForRequests(obj, dNumWorkersForUser)
            dAsManyAsPossibleIndex = 0;
            
            for dRequestIndex=1:length(obj.voRequests)
                oRequest = obj.voRequests(dRequestIndex);
                
                if oRequest.IsRequestingAsManyAsPossible()
                    dAsManyAsPossibleIndex = dRequestIndex;
                else
                    dNumOfWorkersRequested = oRequest.GetNumberOfWorkersInRequest();
                    oRequest.SetNumberOfWorkersAllocated(dNumOfWorkersRequested);
                    dNumWorkersForUser = dNumWorkersForUser - dNumOfWorkersRequested;
                    
                    if dNumWorkersForUser < 0
                        error(...
                            'DCSResourceManagerUser:SetNumberOfWorkersAllocatedForRequests:TooManyWorkersRequested',...
                            'You have requested too many workers.');
                    end
                end
            end
            
            if dAsManyAsPossibleIndex ~= 0
                if dNumWorkersForUser <= 0
                        error(...
                            'DCSResourceManagerUser:SetNumberOfWorkersAllocatedForRequests:TooManyOtherRequests',...
                            'Your other requests have used up all your available workers.');                    
                end
                
                obj.voRequests(dAsManyAsPossibleIndex).SetNumberOfWorkersAllocated(dNumWorkersForUser);
            end
        end
        
        function [oPool, bCreatedNewPool] = CreatePoolForRequestBySubmittingComputerNameAndProcessId(obj, chSubmittingComputerName, dSubmittingProcessId, vdCurrentJobIds)
            oRequest = obj.GetRequestBySubmittingComputerNameAndProcessId(chSubmittingComputerName, dSubmittingProcessId);
            
            [oPool, bCreatedNewPool] = oRequest.CreatePool(vdCurrentJobIds);
        end
        
        function [bWorkersAreAvailable, dNumWorkersAvailable] = CheckIfRequestedWorkersAreAvailable(obj, chSubmittingComputerName, dSubmittingProcessId)
            oRequest = obj.GetRequestBySubmittingComputerNameAndProcessId(chSubmittingComputerName, dSubmittingProcessId);
            
            [bWorkersAreAvailable, dNumWorkersAvailable] = oRequest.CheckIfRequestedWorkersAreAvailable();
        end
        
        function ResetTimeoutForRequestBySubmittingComputerNameAndProcessId(obj, chSubmittingComputerName, dSubmittingProcessId)
            oRequest = obj.GetRequestBySubmittingComputerNameAndProcessId(chSubmittingComputerName, dSubmittingProcessId);
            
            oRequest.ResetTimeout();
        end
        
        function oRequest = GetRequestById(obj, sId)
            oRequest = DCSResourceManagerRequest.empty;
            
            for dRequestIndex=1:length(obj.voRequests)
                if obj.voRequests(dRequestIndex).GetId() == sId
                    oRequest = obj.voRequests(dRequestIndex);
                    break;
                end
            end
        end
        
        function oRequest = GetRequestBySubmittingComputerNameAndProcessId(obj, chSubmittingComputerName, dSubmittingProcessId)
            oRequest = DCSResourceManagerRequest.empty;
            
            for dRequestIndex=1:length(obj.voRequests)
                if strcmp(obj.voRequests(dRequestIndex).GetSubmittingComputerName(), chSubmittingComputerName) && obj.voRequests(dRequestIndex).GetSubmittingProcessId == dSubmittingProcessId
                    oRequest = obj.voRequests(dRequestIndex);
                    break;
                end
            end
        end
        
        function dNumWorkersInUse = GetNumberOfWorkersInUse(obj)
            dNumWorkersInUse = 0;
            
            for dRequestIndex=1:length(obj.voRequests)
                dNumWorkersInUse = dNumWorkersInUse + obj.voRequests(dRequestIndex).GetNumberOfWorkersInUse();
            end
        end
        
        function SetAllRequestsLosingWorkersToHaveAllocatedWorkersReady(obj)
            for dRequestIndex=1:length(obj.voRequests)
                obj.voRequests(dRequestIndex).IfLosingWorkersSetAllocatedWorkersReady();
            end
        end
        
        function voRequests = GetAllRequestsRequiringMoreWorkers(obj)
            dNumRequests = length(obj.voRequests);
            vbRequestRequiresMoreWorkers = false(dNumRequests,1);
            
            for dRequestIndex=1:dNumRequests
                vbRequestRequiresMoreWorkers(dRequestIndex) =  obj.voRequests(dRequestIndex).DoesRequireMoreWorkers();
            end
            
            voRequests = obj.voRequests(vbRequestRequiresMoreWorkers);
        end
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

