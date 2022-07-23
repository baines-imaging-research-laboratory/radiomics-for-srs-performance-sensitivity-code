classdef BinaryClassificationGuessResultSampleLabels < GuessResultSampleLabels
    %BinaryClassificationSampleLabels
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
          
    properties (SetAccess = immutable, GetAccess = public)
        vdPositiveLabelConfidences (:,1) double {mustBeNonnegative(vdPositiveLabelConfidences), mustBeLessThanOrEqual(vdPositiveLabelConfidences,1)} % between 0 and 1
        vdNegativeLabelConfidences (:,1) double {mustBeNonnegative(vdNegativeLabelConfidences), mustBeLessThanOrEqual(vdNegativeLabelConfidences,1)} % between 0 and 1
        
        iPositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0)
        iNegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0)
    end
                
    properties (Access = private, Constant = true)
        dNotNormalizedThreshold = 0.001 % if |1-(a+b)| < 0.001, a and b are normalized 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = BinaryClassificationGuessResultSampleLabels(vdPositiveLabelConfidences, vdNegativeLabelConfidences, iPositiveLabel, iNegativeLabel)
            %obj = BinaryClassificationSampleLabels(vdPositiveLabelConfidences, vdNegativeLabelConfidences, iPositiveLabel, iNegativeLabel)
            %
            % SYNTAX:
            %  obj = BinaryClassificationSampleLabels(vdPositiveLabelConfidences, vdNegativeLabelConfidences, iPositiveLabel, iNegativeLabel)
            %
            % DESCRIPTION:
            %  Constructor for BinaryClassificationGuessResultSampleLabels
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                vdPositiveLabelConfidences (:,1) double {mustBeNonnegative(vdPositiveLabelConfidences), mustBeLessThanOrEqual(vdPositiveLabelConfidences,1)}
                vdNegativeLabelConfidences (:,1) double {mustBeNonnegative(vdNegativeLabelConfidences), mustBeLessThanOrEqual(vdNegativeLabelConfidences,1), ValidationUtils.MustBeSameSize(vdPositiveLabelConfidences, vdNegativeLabelConfidences)}
                iPositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass}
                iNegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeSameClass(iNegativeLabel, iPositiveLabel), ValidationUtils.MustBeNotEqual(iPositiveLabel, iNegativeLabel)}
            end
                        
            % super-class constructor
            obj@GuessResultSampleLabels(vdPositiveLabelConfidences)
            
            % check normalization
            if any(abs((vdPositiveLabelConfidences + vdNegativeLabelConfidences) - 1) > BinaryClassificationGuessResultSampleLabels.dNotNormalizedThreshold)
                warning(...
                    'BinaryClassificationGuessResultSampleLabels:Constructor:PositiveAndNegativeLabelConfidencesNotNormalized',...
                    'One or more of the positive and negative label confidences pairs are not normalized (do not sum to 1)');
            end
            
            % set properities
            obj.vdPositiveLabelConfidences = vdPositiveLabelConfidences;
            obj.vdNegativeLabelConfidences = vdNegativeLabelConfidences;
            obj.iPositiveLabel = iPositiveLabel;
            obj.iNegativeLabel = iNegativeLabel;
        end   
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
         function vdPositiveLabelConfidences = GetPositiveLabelConfidences(obj)
            %vdPositiveLabelConfidences = GetPositiveLabelConfidences(obj)
            %
            % SYNTAX:
            %  vdPositiveLabelConfidences = GetPositiveLabelConfidences(obj)
            %
            % DESCRIPTION:
            %  Provides the sample positive label confidences
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdPositiveLabelConfidences: Column vector of confidences
            %  (between 0 and 1)
            
            vdPositiveLabelConfidences = obj.vdPositiveLabelConfidences;
         end
         
         function vdNegativeLabelConfidences = GetNegativeLabelConfidences(obj)
             %vdNegativeLabelConfidences = GetNegativeLabelConfidences(obj)
             %
             % SYNTAX:
             %  vdNegativeLabelConfidences = GetNegativeLabelConfidences(obj)
             %
             % DESCRIPTION:
             %  Provides the sample negative label confidences
             %
             % INPUT ARGUMENTS:
             %  obj: Class object
             %
             % OUTPUTS ARGUMENTS:
             %  vdNegativeLabelConfidences: Column vector of confidences
             %  (between 0 and 1)
             
             vdNegativeLabelConfidences = obj.vdNegativeLabelConfidences;
         end
         
        function iPositiveLabel = GetPositiveLabel(obj)
            %iPositiveLabel = GetPositiveLabel(obj)
            %
            % SYNTAX:
            %  iPositiveLabel = GetPositiveLabel(obj)
            %
            % DESCRIPTION:
            %  Provides the positive label
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  iPositiveLabel: The positive label
            
            iPositiveLabel = obj.iPositiveLabel;
        end    
        
        function iNegativeLabel = GetNegativeLabel(obj)
            %iNegativeLabel = GetNegativeLabel(obj)
            %
            % SYNTAX:
            %  iNegativeLabel = GetNegativeLabel(obj)
            %
            % DESCRIPTION:
            %  Provides the negative label
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  iNegativeLabel: The negative label
            
            iNegativeLabel = obj.iNegativeLabel;
        end 
        
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function obj = vertcat(varargin)
            c1oSampleLabels = varargin;
            
            dNumSampleLabels = length(c1oSampleLabels);
            vdNumSamplesPerSampleLabelsObj = zeros(1,dNumSampleLabels);
                        
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                ValidationUtils.MustBeA(oSampleLabelsObj, 'BinaryClassificationGuessResultSampleLabels');
                
                % get number of samples
                vdNumSamplesPerSampleLabelsObj(dObjIndex) = oSampleLabelsObj.GetNumberOfSamples();
            end
            
            dTotalNumSamples = sum(vdNumSamplesPerSampleLabelsObj);
            
            oMasterSampleLabels = oSampleLabelsObj;
                        
            vdPositiveLabelConfidences = zeros(dTotalNumSamples,1);
            vdNegativeLabelConfidences = zeros(dTotalNumSamples,1);
            dInsertIndex = 1;
            
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                BinaryClassificationGuessResultSampleLabels.MustBeValidForVertcat(oMasterSampleLabels, oSampleLabelsObj);
                
                % insert labels
                dNumToInsert = vdNumSamplesPerSampleLabelsObj(dObjIndex);
                
                vdPositiveLabelConfidences(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleLabelsObj.GetPositiveLabelConfidences();
                vdNegativeLabelConfidences(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleLabelsObj.GetNegativeLabelConfidences();
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
            
            % create new obj
            obj = BinaryClassificationGuessResultSampleLabels(vdPositiveLabelConfidences, vdNegativeLabelConfidences, oMasterSampleLabels.iPositiveLabel, oMasterSampleLabels.iNegativeLabel);
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
            %  varargout: If is was a selection, a BinaryClassificationGuessResultSampleLabels object
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
                    vdPositiveLabelConfidences = obj.vdPositiveLabelConfidences(varargout{1}.GetRowSelection());
                    vdNegativeLabelConfidences = obj.vdNegativeLabelConfidences(varargout{1}.GetRowSelection());
                    
                    varargout{1} = BinaryClassificationGuessResultSampleLabels(vdPositiveLabelConfidences, vdNegativeLabelConfidences, obj.iPositiveLabel, obj.iNegativeLabel);
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> PRINT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function PrintHeaders(obj)
            fprintf(' %7s | %7s |', '+ Conf.', '- Conf.');
        end
        
        function PrintRowForSample(obj, dSampleIndex)
                
            fprintf(' %7.5f | %7.5f |', obj.vdPositiveLabelConfidences(dSampleIndex), obj.vdNegativeLabelConfidences(dSampleIndex));
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
                
        function MustBeValidForVertcat(obj1, obj2)
            if...
                    ~strcmp(class(obj1.iPositiveLabel), class(obj2.iPositiveLabel)) ||...
                    obj1.iPositiveLabel ~= obj2.iPositiveLabel ||...
                    obj1.iNegativeLabel ~= obj2.iNegativeLabel
                error(...
                    'BinaryClassificationGuessResultSampleLabels:MustBeValidForVertcat:Invalid',...
                    'For two BinaryClassificationGuessResultSampleLabels objects to be concatenated, the positive/negative label definitions must be identical.');
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

