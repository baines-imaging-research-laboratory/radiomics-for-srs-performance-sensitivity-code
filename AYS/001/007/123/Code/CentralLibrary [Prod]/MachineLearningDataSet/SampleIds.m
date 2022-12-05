classdef SampleIds < MatrixContainer
    %SampleIds
    %
    % Provides Group and Sub-Group IDs for samples, along with a custom
    % string the user can set as they want.
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        viGroupIds (:,1) {ValidationUtils.MustBeIntegerClass} = int8([]) % together Group and Sub-Group IDs form a unique key for a sample (may be duplicated though during balancing)
        viSubGroupIds (:,1) {ValidationUtils.MustBeIntegerClass} = int8([])    
        
        vsUserDefinedSampleStrings (:,1) string % custom string given for each sample by the user. Only for display/debugging purposes!
        
        vbIsSampleDuplicated (:,1) logical % flags whether sample was duplicated or not
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsSampleDuplicated)
            %obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsSampleDuplicated)
            %
            % SYNTAX:
            %  obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings)
            %  obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsSampleDuplicated)
            %
            % DESCRIPTION:
            %  Constructor for SampleIds
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                viGroupIds (:,1) {ValidationUtils.MustBeIntegerClass}
                viSubGroupIds (:,1) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeSameSize(viGroupIds, viSubGroupIds), ValidationUtils.MustBeSameClass(viGroupIds, viSubGroupIds)}
                vsUserDefinedSampleStrings (:,1) string {ValidationUtils.MustBeSameSize(vsUserDefinedSampleStrings, viGroupIds)}
                vbIsSampleDuplicated (:,1) logical {ValidationUtils.MustBeSameSize(vbIsSampleDuplicated, viGroupIds), SampleIds.GroupAndSubGroupIdsUniquenessMustMatchIsSampleDuplicated(viGroupIds, viSubGroupIds, vbIsSampleDuplicated)} = SampleIds.CreateDefaultIsSampleDuplicated(viGroupIds)
            end
            
            % super-class constructor
            obj@MatrixContainer(viGroupIds);
            
            % set properities
            obj.viGroupIds = viGroupIds;
            obj.viSubGroupIds = viSubGroupIds;
            obj.vsUserDefinedSampleStrings = vsUserDefinedSampleStrings;
            obj.vbIsSampleDuplicated = vbIsSampleDuplicated;
        end   
        
        
        % >>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
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
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = length(obj); % used overloaded length function
        end
        
        function dNumGroups = GetNumberOfGroups(obj)
            %dNumGroups = GetNumberOfGroups(obj)
            %
            % SYNTAX:
            %  dNumGroups = objGetNumberOfGroups()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumGroups = length(obj.GetUniqueGroupIds());
        end
        
        function viUniqueGroupIds = GetUniqueGroupIds(obj)
            %viUniqueGroupIds = GetUniqueGroupIds(obj)
            %
            % SYNTAX:
            %  viUniqueGroupIds = obj.GetUniqueGroupIds()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            viUniqueGroupIds = unique(obj.viGroupIds);
        end
        
        function viGroupIds = GetGroupIds(obj)
            %viGroupIds = GetGroupIds(obj)
            %
            % SYNTAX:
            %  viGroupIds = obj.GetGroupIds()
            %
            % DESCRIPTION:
            %  Getter for obj.viGroupIds
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            viGroupIds = obj.viGroupIds;
        end
        
        function viSubGroupIds = GetSubGroupIds(obj)
            %viSubGroupIds = GetSubGroupIds(obj)
            %
            % SYNTAX:
            %  viSubGroupIds = obj.GetSubGroupIds()
            %
            % DESCRIPTION:
            %  Getter for obj.viSubGroupIds
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            viSubGroupIds = obj.viSubGroupIds;
        end
        
        function vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
            %vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
            %
            % SYNTAX:
            %  vsUserDefinedSampleStrings = obj.GetUserDefinedSampleStrings()
            %
            % DESCRIPTION:
            %  Getter for obj.vsUserDefinedSampleStrings
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            vsUserDefinedSampleStrings = obj.vsUserDefinedSampleStrings;
        end
        
        function vbIsSampleDuplicated = IsSampleDuplicated(obj)
            %vbIsSampleDuplicated = IsSampleDuplicated(obj)
            %
            % SYNTAX:
            %  vbIsSampleDuplicated = obj.IsSampleDuplicated()
            %
            % DESCRIPTION:
            %  Getter for obj.vbIsSampleDuplicated
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            vbIsSampleDuplicated = obj.vbIsSampleDuplicated;
        end
        
        function bContainsDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %bContainsDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %
            % SYNTAX:
            %  bContainsDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            bContainsDuplicatedSamples = any(obj.vbIsSampleDuplicated);
        end
        
        function iGroupId = GetGroupIdForSample(obj, dSampleIndex)
            %iGroupId = GetGroupIdForSample(obj, dSampleIndex)
            %
            % SYNTAX:
            %  iGroupId = obj.GetGroupIdForSample(dSampleIndex)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            arguments
                obj
                dSampleIndex (1,1) double {MustBeValidSampleIndex(obj, dSampleIndex)}
            end            
            
            iGroupId = obj.viGroupIds(dSampleIndex);
        end
        
        function iSubGroupId = GetSubGroupIdForSample(obj, dSampleIndex)
            %iSubGroupId = GetSubGroupIdForSample(obj, dSampleIndex)
            %
            % SYNTAX:
            %  iSubGroupId = obj.GetSubGroupIdForSample(dSampleIndex)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            arguments
                obj
                dSampleIndex (1,1) double {MustBeValidSampleIndex(obj, dSampleIndex)}
            end            
            
            iSubGroupId = obj.viSubGroupIds(dSampleIndex);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidSampleIndex(obj, dSampleIndex)
            arguments
                obj
                dSampleIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            mustBeLessThanOrEqual(dSampleIndex, length(obj))
        end
        
        function MustNotContainDuplicatedSamples(obj)
            if obj.ContainsDuplicatedSamples
                error(...
                    'SampleIds:MustNotContainDuplicatedSamples:Invalid',...
                    'SampleIds object must not contain duplicated samples.');
            end
        end
        
        function MustBeEqual(obj1, obj2)
            arguments
                obj1 (:,1) 
                obj2 (:,1) {ValidationUtils.MustBeA(obj2, 'SampleIds'), ValidationUtils.MustBeSameSize(obj1, obj2)}
            end
            
            if ...
                    any(obj1.viGroupIds ~= obj2.viGroupIds) ||...
                    any(obj1.viSubGroupIds ~= obj2.viSubGroupIds) ||...
                    any(obj1.vbIsSampleDuplicated ~= obj2.vbIsSampleDuplicated) ||...
                    any(obj1.vsUserDefinedSampleStrings ~= obj2.vsUserDefinedSampleStrings)
                error(...
                    'SampleIds:MustBeEqual:Invalid',...
                    'SampleIds objects are not equivalent.');
            end
                
                
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> PRINT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function PrintHeaders(obj)
            dNumSamples = obj.GetNumberOfSamples();
            dSampleNumWidth = length(num2str(dNumSamples));
            
            if obj.ContainsDuplicatedSamples()
                dSampleNumWidth = dSampleNumWidth + 1;
            end
            
            fprintf([' %', num2str(dSampleNumWidth), 's | %5s | %7s |'], '#', 'Group', 'Sub Grp');
        end
        
        function PrintRowForSample(obj, dSampleIndex)
            dNumSamples = obj.GetNumberOfSamples();
            dSampleNumWidth = length(num2str(dNumSamples));
            
            chFormatString = ['%', num2str(dSampleNumWidth), 'i | %5i | %7i |'];
            c1xPrintVargs = {dSampleIndex, obj.viGroupIds(dSampleIndex), obj.viSubGroupIds(dSampleIndex)};
            
            if obj.ContainsDuplicatedSamples()
                chFormatString = ['%1s', chFormatString];
                
                if obj.vbIsSampleDuplicated(dSampleIndex)
                    c1xPrintVargs = [{'*'}, c1xPrintVargs];
                else
                    c1xPrintVargs = [{''}, c1xPrintVargs];
                end
            end
            
            chFormatString = [' ', chFormatString];
                        
            fprintf(chFormatString, c1xPrintVargs{:});
        end
        
        function PrintFooter(obj)
            if obj.ContainsDuplicatedSamples()
                fprintf('* - Duplicated Sample');
                fprintf(newline);
            end
        end
                
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function obj = vertcat(varargin)
            c1oSampleIds = varargin;
            
            dNumSampleIds = length(c1oSampleIds);
            vdNumSamplesPerSampleIdsObj = zeros(1,dNumSampleIds);
                        
            for dObjIndex = 1:dNumSampleIds
                oSampleIdsObj = c1oSampleIds{dObjIndex};
                
                % validate
                ValidationUtils.MustBeA(oSampleIdsObj, 'SampleIds');
                
                % get number of samples
                vdNumSamplesPerSampleIdsObj(dObjIndex) = oSampleIdsObj.GetNumberOfSamples();
            end
            
            dTotalNumSamples = sum(vdNumSamplesPerSampleIdsObj);
            
            oMasterSampleIdsObj = oSampleIdsObj;
            chMasterIdsClass = class(oMasterSampleIdsObj.GetGroupIds());
                        
            viGroupIds = zeros(dTotalNumSamples,1,chMasterIdsClass);
            viSubGroupIds = zeros(dTotalNumSamples,1,chMasterIdsClass);
            vsUserDefinedSampleStrings = strings(dTotalNumSamples,1);
            vbIsSampleDuplicated = false(dTotalNumSamples,1);
            
            dInsertIndex = 1;
            
            for dObjIndex = 1:dNumSampleIds
                oSampleIdsObj = c1oSampleIds{dObjIndex};
                
                % validate
                SampleIds.MustBeValidForVertcat(oMasterSampleIdsObj, oSampleIdsObj);
                
                % insert labels
                dNumToInsert = vdNumSamplesPerSampleIdsObj(dObjIndex);
                
                viGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.GetGroupIds();
                viSubGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.GetSubGroupIds();
                vsUserDefinedSampleStrings(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.GetUserDefinedSampleStrings();
                vbIsSampleDuplicated(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.IsSampleDuplicated();
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
            
            % create new obj
            obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsSampleDuplicated);
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: If is was a selection, a SampleIds object
            %             will be returned. If it was a obj.FnName() call,
            %             anything could be returned
            
            
            % call super-class method that has this call figured out
            switch stSelection(1).type
                case '.' % allow built in function to run (member methods, etc.)
                    [varargout{1:nargout}] = builtin('subsref',obj, stSelection);
                case '()'
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
                    
                    % if it was a selection, don't want to store the whole matrix
                    % as MatrixContainer does, since this is a waste of memory
                    % if we're passing by value
                    % We'll take the choosen selection, and apply it behind the
                    % scenes
                    vdRowSelection = varargout{1}.GetRowSelection();
                    
                    viGroupIds = obj.viGroupIds(vdRowSelection);
                    viSubGroupIds = obj.viSubGroupIds(vdRowSelection);
                    vsUserDefinedSampleStrings = obj.vsUserDefinedSampleStrings(vdRowSelection);
                    vbIsSampleDuplicated = obj.vbIsSampleDuplicated(vdRowSelection);
                    
                    [vdUniqueRowSelection,~,vdOriginalIndexMapping] = unique(vdRowSelection);
                    
                    if length(vdUniqueRowSelection) < length(vdRowSelection) % there's duplicates, mark as such
                        for dUniqueRowSelectionIndex = 1:length(vdUniqueRowSelection)
                            vdOriginalIndices = find(vdOriginalIndexMapping == dUniqueRowSelectionIndex);
                            
                            if length(vdOriginalIndices) > 1
                                vbIsSampleDuplicated(vdOriginalIndices) = true;
                            end
                        end
                    end
                    
                    varargout{1} = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsSampleDuplicated);
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
    end
    
    
    methods (Access = public, Static = true) 
        
        function bBool = DoSampleIdsHaveOverlappingGroupIds(obj1, obj2)
            arguments
                obj1 (:,1) {ValidationUtils.MustBeA(obj1, 'SampleIds')}
                obj2 (:,1) {ValidationUtils.MustBeA(obj2, 'SampleIds')}
            end
            
            bBool = ~isempty(intersect(obj1.viGroupIds, obj2.viGroupIds));
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected)    
        
        function newObj = CopyContainedMatrices(obj, newObj)
            %newObj = CopyContainedMatrices(obj, newObj)
            %
            % SYNTAX:
            %  newObj = CopyContainedMatrices(obj, newObj)
            %
            % DESCRIPTION:
            %  Copies any matrix contained in "obj" over to "newObj". If the
            %  contained matrices are handle objects they should be FULLY
            %  COPIED
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  newObj: Copied class object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copied class object
            
            newObj = obj;
        end
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
        
        function GroupAndSubGroupIdsUniquenessMustMatchIsSampleDuplicated(viGroupIds, viSubGroupIds, vbIsSampleDuplicated)
             m2iIdMatrix = [viGroupIds, viSubGroupIds];
             m2iUniqueIdMatrix = unique(m2iIdMatrix, 'first', 'rows');
             
             dNumUniqueIds = size(m2iUniqueIdMatrix,1);
             
             for dIdIndex = 1:dNumUniqueIds
                viSearchId = m2iUniqueIdMatrix(dIdIndex,:);
                
                vbFindIdMask = ismember(m2iIdMatrix, viSearchId, 'rows');
                
                if sum(vbFindIdMask) ~= 1 % is duplicated
                    vbIsSampleDuplicatedForId = vbIsSampleDuplicated(vbFindIdMask);
                    
                    if any(~vbIsSampleDuplicatedForId)
                        error(...
                            'SampleIds:GroupAndSubGroupIdsMustFormUniqueIds:Invalid',...
                            'Non-unique Group and Sub Group ID pairs were found without correct Sample Duplication flags were found.');
                    end
                end
             end
        end
        
        function MustBeValidForVertcat(obj1, obj2)
            if...
                    ~strcmp(class(obj1.viGroupIds), class(obj2.viGroupIds)) ||...
                    ~strcmp(class(obj1.viSubGroupIds), class(obj2.viSubGroupIds))
                error(...
                    'SampleIds:MustBeValidForVertcat:Invalid',...
                    'For two SampleIds objects to be concatenated, their Group and Sub-Group IDs must be of the same class.');
            end
        end
        
        function vbIsSampleDuplicated = CreateDefaultIsSampleDuplicated(viGroupIds)
            vbIsSampleDuplicated = false(size(viGroupIds));
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

