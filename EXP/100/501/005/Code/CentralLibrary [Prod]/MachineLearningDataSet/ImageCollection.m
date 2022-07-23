classdef ImageCollection < MachineLearningDataSet & MatrixContainer
    %ImageCollection
    %
    % Joins up ImageVolume objects with SampleIds
    
    % Primary Author: David DeVries
    % Created: June 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)        
        oSampleIds (:,1) SampleIds = SampleIds(int8(1), int8(1), "") % TODO figure out SampleIds.empty
        
        vdImageVolumeHandlerIndexPerSample (:,1) double {mustBeInteger, mustBePositive}
        voImageVolumeHandlers (1,:) ImageVolumeHandler
        
        vdRegionOfInterstNumberPerSample (:,1) double {mustBeInteger, mustBePositive}
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = ImageCollection(varargin)
            %obj = ImageCollection(varargin)
            %
            % SYNTAX:
            %  obj = ImageCollection(voImageVolumeHandlers)
            %  obj = ImageCollection(obj, vdRowSelection)
            %  obj = ImageCollection(obj)
            %
            % DESCRIPTION:
            %  Constructor for ImageCollection
            %
            % INPUT ARGUMENTS:
            %  voImageVolumeHandlers: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
           
            if nargin == 1 && isa(varargin{1}, 'ImageVolumeHandler')
                % For:
                %  obj = ImageCollection(voImageVolumeHandlers)
                
                voImageVolumeHandlers = varargin{1};
                
                ValidationUtils.MustBeA(voImageVolumeHandlers, 'ImageVolumeHandler');
                ValidationUtils.MustBeRowVector(voImageVolumeHandlers);
                
                % get sample IDs across all handlers
                oSampleIds = ImageVolumeHandler.GetSampleIdsForAll(voImageVolumeHandlers);
                
                dNumSamples = oSampleIds.GetNumberOfSamples();
                
                vdImageVolumeHandlerIndexPerSample = zeros(dNumSamples,1);
                vdRegionOfInterestNumberPerSample = zeros(dNumSamples,1);
                
                dSampleInsertIndex = 1;
                
                for dHandlerIndex=1:length(voImageVolumeHandlers)
                    vdSampleOrder = voImageVolumeHandlers(dHandlerIndex).GetSampleOrder();
                    
                    dNumSamplesFromHandler = length(vdSampleOrder);
                    
                    vdImageVolumeHandlerIndexPerSample(dSampleInsertIndex : dSampleInsertIndex + dNumSamplesFromHandler - 1) = dHandlerIndex;
                    vdRegionOfInterestNumberPerSample(dSampleInsertIndex : dSampleInsertIndex + dNumSamplesFromHandler - 1) = vdSampleOrder;
                    
                    dSampleInsertIndex = dSampleInsertIndex + dNumSamplesFromHandler;
                end
                
            elseif nargin == 1
                % For:
                %  obj = ImageCollection(obj)
                
                oCurrentObj = varargin{1};
                
                oSampleIds = oCurrentObj.oSampleIds;
                voImageVolumeHandlers = oCurrentObj.voImageVolumeHandlers;
                vdImageVolumeHandlerIndexPerSample = oCurrentObj.vdImageVolumeHandlerIndexPerSample;
                vdRegionOfInterestNumberPerSample = oCurrentObj.vdRegionOfInterstNumberPerSample;
                
            elseif nargin == 2
                % For:
                %  obj = ImageCollection(objCurrent, vdRowSelection)
                
                objCurrent = varargin{1};
                vdRowSelection = varargin{2};
                
                ValidationUtils.MustBeA(objCurrent, 'ImageCollection');
                
                ValidationUtils.MustBeA(vdRowSelection, 'double');
                mustBeInteger(vdRowSelection);
                mustBePositive(vdRowSelection);
                
                if max(vdRowSelection) > objCurrent.GetNumberOfSamples()
                    error(...
                        'ImageCollection:Constructor:InvalidRowSelection',...
                        'The row selection indices must not exceed the number of samples.');
                end
                
                oSampleIds = objCurrent.oSampleIds(vdRowSelection);
                
                vdRegionOfInterestNumberPerSample = objCurrent.vdRegionOfInterstNumberPerSample(vdRowSelection);
                
                [vdImageVolumeHandlerIndexPerSample, vbKeepHandler] = MatrixUtils.ApplySelectionToIndexMappingVectorWithMappingRemoval(objCurrent.vdImageVolumeHandlerIndexPerSample, vdRowSelection);
                voImageVolumeHandlers = objCurrent.voImageVolumeHandlers(vbKeepHandler);
            else
                error(...
                    'ImageCollection:Constructor:InvalidNumberOfArguments',...
                    'See constructor documentation for more details.');
            end
            
            % super-class constructor
            obj@MachineLearningDataSet();
            obj@MatrixContainer(oSampleIds);
            
            % local constructor
            obj.oSampleIds = oSampleIds;
            
            obj.voImageVolumeHandlers = voImageVolumeHandlers;
                        
            obj.vdImageVolumeHandlerIndexPerSample = vdImageVolumeHandlerIndexPerSample;
            obj.vdRegionOfInterstNumberPerSample = vdRegionOfInterestNumberPerSample;
        end 
        
        function newObj = Label(obj, oSampleLabels)
            %newObj = Label(obj, oSampleLabels)
            %
            % SYNTAX:
            %  newObj = Label(obj, oSampleLabels)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %  oSampleLabels: SampleLabels object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: 
            
            newObj = LabelledImageCollection(obj, oSampleLabels);
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
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
            %  obj: ImageCollection object
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
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = obj.oSampleIds.GetNumberOfSamples();
        end
        
        function [oRASImageVolume, dRoiNumber] = GetImageVolumeAndRegionOfInterestNumberForSample(obj, dSampleNumber)
            oHandler = obj.voImageVolumeHandlers(obj.vdImageVolumeHandlerIndexPerSample(dSampleNumber));
            
            oRASImageVolume = oHandler.GetRASImageVolume();
            dRoiNumber = obj.vdRegionOfInterstNumberPerSample(dSampleNumber);
        end
        
        function sImageSource = GetImageSource(obj)
            sImageSource = obj.voImageVolumeHandlers(1).GetImageSource();
        end        
        
        function oRecord = GetRecordForModel(obj)
            %oRecord = GetRecordForModel(obj)
            %
            % SYNTAX:
            %  oRecord = obj.GetRecordForModel()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oRecord = ImageCollectionRecordForModel(obj);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Displays a ImageCollection
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Headers
            obj.GetSampleIds().PrintHeaders();
            
            dNumFilePathChars = 40;
            
            fprintf([' %', num2str(dNumFilePathChars), 's | %5s '], 'Filepath', 'ROI #');
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                
                [oRASImageVolume, dRoiNumber] = obj.GetImageVolumeAndRegionOfInterestNumberForSample(dSampleIndex);
                
                chFilePath = char(oRASImageVolume.GetMatFilePath());
                
                if isempty(chFilePath)
                    chFilePath = char(oRASImageVolume.GetOriginalFilePath());
                end
                
                dPathLength = length(chFilePath);
                
                dStartIndex = max(1, dPathLength - dNumFilePathChars + 1);
                
                chFilePath = chFilePath(dStartIndex:end);
                
                fprintf([' %', num2str(dNumFilePathChars), 's | %5i '], chFilePath, dRoiNumber);
                
                fprintf(newline);
            end     
            
            fprintf(newline);
            fprintf("Image Source: " + obj.GetImageSource());
            fprintf(newline);
            
            obj.GetSampleIds().PrintFooter();
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
                    varargout{1} = ImageCollection(obj, varargout{1}.GetRowSelection());
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
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
        
        function sStr = GetMultiModalityDataSetDispSummaryString(obj)
            sStr = "Image Source: " + obj.GetImageSource();
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

