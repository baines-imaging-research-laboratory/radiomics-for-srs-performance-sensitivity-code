classdef GuessResult < MatrixContainer
    %GuessResult
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)        
        oSampleIds (:,1) SampleIds = SampleIds(int8(1), int8(1), "") % TODO figure out SampleIds.empty
        
        oGroundTruthSampleLabels (:,1) SampleLabels = BinaryClassificationSampleLabels(int8(1),int8(1),int8(0)) % TODO figure out BinaryClassifcationSampleLabels.empty
        oGuessResultSampleLabels (:,1) GuessResultSampleLabels = BinaryClassificationGuessResultSampleLabels(1,0,int8(1),int8(0)) % TODO figure out BinaryClassifcationSampleLabels.empty
        
        voGuessResultModelRecords (1,:) GuessResultModelRecord = GuessResultModelRecord.empty(1,0)
        vdGuessResultModelRecordIndexPerSample (:,1) double {mustBeInteger, mustBePositive}
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = GuessResult(varargin)
            %obj = GuessResult(varargin)
            %
            % SYNTAX:
            %  obj = GuessResult(oTestingDataSet, oGuessResultSampleLabels, oModel)
            %  obj = GuessResult(obj, vdRowSelection)
            %
            % DESCRIPTION:
            %  Constructor for GuessResult
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
           
            if nargin == 3
                % For:
                %  obj = GuessResult(oTestingDataSet, oGuessResultSampleLabels, oModel)
                
                oTestingDataSet = varargin{1};
                oGuessResultSampleLabels = varargin{2};
                oModel = varargin{3};
                                                
                ValidationUtils.MustBeA(oTestingDataSet, 'LabelledMachineLearningDataSet');
                MustNotContainDuplicatedSamples(oTestingDataSet.GetSampleIds()); % duplicated samples should NEVER be used during testing
                
                oSampleIds = oTestingDataSet.GetSampleIds();
                oGroundTruthSampleLabels = oTestingDataSet.GetSampleLabels();
                
                ValidationUtils.MustBeA(oGuessResultSampleLabels, 'GuessResultSampleLabels');
                ValidationUtils.MustBeSameSize(oGuessResultSampleLabels, oGroundTruthSampleLabels);
                
                ValidationUtils.MustBeA(oModel, 'MachineLearningModel');
                ValidationUtils.MustBeScalar(oModel);
                
                voGuessResultModelRecords = GuessResultModelRecord(oModel);
                vdGuessResultModelRecordIndexPerSample = ones(size(oSampleIds));
                
            elseif nargin == 2
                % For:
                %  obj = GuessResult(obj, vdRowSelection)
                
                objCurrent = varargin{1};
                vdRowSelection = varargin{2};
                
                ValidationUtils.MustBeA(objCurrent, 'GuessResult');
                
                ValidationUtils.MustBeA(vdRowSelection, 'double');
                mustBeInteger(vdRowSelection);
                mustBePositive(vdRowSelection);
                
                if max(vdRowSelection) > objCurrent.GetNumberOfSamples()
                    error(...
                        'GuessResult:Constructor:InvalidRowSelection',...
                        'The row selection indices must not exceed the number of samples.');
                end
                
                oSampleIds = objCurrent.oSampleIds(vdRowSelection);
                oGroundTruthSampleLabels = objCurrent.oGroundTruthSampleLabels(vdRowSelection);
                oGuessResultSampleLabels = objCurrent.oGuessResultSampleLabels(vdRowSelection);
                
                [vdGuessResultModelRecordIndexPerSample, vbKeepRecord] = MatrixUtils.ApplySelectionToIndexMappingVectorWithMappingRemoval(objCurrent.vdGuessResultModelRecordIndexPerSample, vdRowSelection);
                voGuessResultModelRecords = objCurrent.voGuessResultModelRecords(vbKeepRecord);
                
            elseif nargin == 1
                % For
                %  obj = GuessResult(c1oObjectsForVertcat)
                
                % To validate:
                % 1) All objs in varargin are GuessResult objects
                % 2) All objs have same class type in oGroundTruthSampleLabels
                % 3) oGroundTruthSampleLabels objs can be vertcat'ed
                % 4) All objs have same class type in oGuessResultSampleLabels
                % 5) oGuessResultSampleLabels objs can be vertcat'ed
                % 6) SampleIds do not contain duplicated values
                
                c1oObjectsForVertcat = varargin{1};
                
                dNumGuessResults = length(c1oObjectsForVertcat);
                vdNumSamplesPerGuessResultObj = zeros(1,dNumGuessResults);
                
                c1oGroundTruthSampleLabelsObjs = cell(1,dNumGuessResults);
                c1oGuessResultSampleLabelsObjs = cell(1,dNumGuessResults);
                c1oSampleIdsObjs = cell(1,dNumGuessResults);
                c1oModelRecords = cell(1,dNumGuessResults);
                c1vdGuessResultModelRecordIndexPerSample = cell(1,dNumGuessResults);
                
                dModelRecordMaxIndex = 0;
                
                for dObjIndex = 1:dNumGuessResults
                    oGuessResultObj = c1oObjectsForVertcat{dObjIndex};
                    
                    % validate
                    ValidationUtils.MustBeA(oGuessResultObj, 'GuessResult');
                    
                    % get number of samples
                    vdNumSamplesPerGuessResultObj(dObjIndex) = oGuessResultObj.GetNumberOfSamples();
                    
                    % assign sub-objects in cell arrays
                    c1oGroundTruthSampleLabelsObjs{dObjIndex} = oGuessResultObj.oGroundTruthSampleLabels;
                    c1oGuessResultSampleLabelsObjs{dObjIndex} = oGuessResultObj.oGuessResultSampleLabels;
                    c1oSampleIdsObjs{dObjIndex} = oGuessResultObj.oSampleIds;
                    c1oModelRecords{dObjIndex} = oGuessResultObj.voGuessResultModelRecords;
                    c1vdGuessResultModelRecordIndexPerSample{dObjIndex} = oGuessResultObj.vdGuessResultModelRecordIndexPerSample + dModelRecordMaxIndex; % got bump up each set of indices that are being added or else they'll be 1s
                    
                    dModelRecordMaxIndex = dModelRecordMaxIndex + length(oGuessResultObj.voGuessResultModelRecords);
                end
                                
                % concatenate sub-objects (errors will spool if this is
                % invalid)
                oGroundTruthSampleLabels = vertcat(c1oGroundTruthSampleLabelsObjs{:});
                oGuessResultSampleLabels = vertcat(c1oGuessResultSampleLabelsObjs{:});
                oSampleIds = vertcat(c1oSampleIdsObjs{:});
                
                % check for duplicated entries
                if oSampleIds.ContainsDuplicatedSamples()
                    error(...
                        'GuessResult:Constructor:InvalidSampleIdsForVertcat',...
                        'The SampleIds objects across the objects being concatenated must contain unique Group/Sub-Group ID pairs.');
                end
                
                % sort out the GuessResultModelRecords
                voGuessResultModelRecords = horzcat(c1oModelRecords{:});
                vdGuessResultModelRecordIndexPerSample = vertcat(c1vdGuessResultModelRecordIndexPerSample{:});
                
                [vdGuessResultModelRecordIndexPerSample, voGuessResultModelRecords] = MatrixUtils.RemoveDuplicatedIndicesInVectorOfObjectsAndUpdateIndexingVector(vdGuessResultModelRecordIndexPerSample, voGuessResultModelRecords);
            
            else
                error(...
                    'GuessResult:Constructor:InvalidNumberOfArguments',...
                    'See constructor documentation for more details.');
            end
                   
            % super-class constructor
            obj@MatrixContainer(oSampleIds);
            
            % local constructor
            obj.oSampleIds = oSampleIds;
            
            obj.oGroundTruthSampleLabels = oGroundTruthSampleLabels;
            obj.oGuessResultSampleLabels = oGuessResultSampleLabels;
            
            obj.voGuessResultModelRecords = voGuessResultModelRecords;
            obj.vdGuessResultModelRecordIndexPerSample = vdGuessResultModelRecordIndexPerSample;
        end      
                
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function oSampleLabels = GetGroundTruthSampleLabels(obj)
            %oSampleLabels = GetGroundTruthSampleLabels(obj)
            %
            % SYNTAX:
            %  oSampleLabels = obj.GetGroundTruthSampleLabels()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: GuessResult object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleLabels = obj.oGroundTruthSampleLabels;
        end  
        
        function oGuessResultSampleLabels = GetGuessResultSampleLabels(obj)
            %oGuessResultSampleLabels = GetGuessResultSampleLabels(obj)
            %
            % SYNTAX:
            %  oGuessResultSampleLabels = obj.GetGuessResultSampleLabels()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: GuessResult object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oGuessResultSampleLabels = obj.oGuessResultSampleLabels;
        end  
        
        function oSampleIds = GetSampleIds(obj)
            %oSampleIds = GetSampleIds(obj)
            %
            % SYNTAX:
            %  oSampleIds = obj.GetSampleIds()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: GuessResult object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleIds = obj.oSampleIds;
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            %dNumSamples = GetNumberOfSamples(obj)
            %
            % SYNTAX:
            %  dNumSamples = obj.GetNumberOfSamples()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: GuessResult object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = obj.oSampleIds.GetNumberOfSamples();
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Displays a LabelledImageCollection
            %
            % INPUT ARGUMENTS:
            %  obj: LabelledImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Headers
            obj.GetSampleIds().PrintHeaders();
            obj.GetGroundTruthSampleLabels().PrintHeaders();
            obj.GetGuessResultSampleLabels().PrintHeaders();
            
            fprintf(' %20s | %36s', 'Guess Timestamp', 'Model UUID');
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                obj.GetGroundTruthSampleLabels().PrintRowForSample(dSampleIndex);
                obj.GetGuessResultSampleLabels().PrintRowForSample(dSampleIndex);
                
                fprintf(' %20s | %36s',...
                    string(obj.voGuessResultModelRecords(obj.vdGuessResultModelRecordIndexPerSample(dSampleIndex)).GetCreationTimestamp()),...
                    obj.voGuessResultModelRecords(obj.vdGuessResultModelRecordIndexPerSample(dSampleIndex)).GetModelUuid());
                fprintf(newline);
            end     
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
            %  varargout: If is was a selection, a LabelledImageCollection object
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
                    varargout{1} = GuessResult(obj, varargout{1}.GetRowSelection());
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        function obj = vertcat(varargin)
            
            % create new obj (constuctor to do the heavy lifting)
            obj = GuessResult(varargin);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidForBinaryClassification(obj)
            if ~isa(obj.oGroundTruthSampleLabels, 'BinaryClassificationSampleLabels') || ~isa(obj.oGuessResultSampleLabels, 'BinaryClassificationGuessResultSampleLabels')
                error(...
                    'GuessResult:MustBeValidForBinaryClassification:Invalid',...
                    'Both the GroundTruthSampleLabels and GuessResultSampleLabels must be for Binary Classification for the GuessResult to be used for binary classification.');
            end
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

