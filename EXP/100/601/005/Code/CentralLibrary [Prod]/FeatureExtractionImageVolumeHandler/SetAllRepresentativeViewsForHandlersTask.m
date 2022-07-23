classdef SetAllRepresentativeViewsForHandlersTask < ImageVolumeViewerTask
    %SetAllRepresentativeViewsForHandlersTask
    %
    
    
    % Primary Author: David DeVries
    % Created: Oct 25, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        vsFeatureExtractionImageVolumeHandlersPaths
        voHandlers
        
        sObjectVarName
    end    
    
    properties (SetAccess = private, GetAccess = public)
        dCurrentHandlerIndex = 1
        dCurrentSampleIndex = 1
        
        vdLockedHandlerStartingImageDataDisplayThreshold = []
        bChangeImageDataDisplayThreshold = true % set to false for all ROIs of a handler once it's window/level has been changed        
    end
    
    properties (Constant = true, GetAccess = private)
        vdCurrentRegionOfInterestColour_rgb = [1 0 0] % red
        
        bVoxelMaskOverlayVisibility = false
        dVoxelMaskOutlineLineWidth = 1
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = SetAllRepresentativeViewsForHandlersTask(chProgressCacheFilePath, vsFeatureExtractionImageVolumeHandlersPaths, sObjectVarName)
            % obj = ImageVolumeViewerTask(chProgressCacheFilePath, vsHotkeyLabels, vfnHotkeyCallbacks, c1chHotkeys)
            arguments
               chProgressCacheFilePath (1,:) char
               vsFeatureExtractionImageVolumeHandlersPaths (1,:) string
               sObjectVarName (1,1) string
            end
            
            vsHotkeyLabels = [...
                "Next ROI",...
                "Previous ROI"];
                
            c1fnHotkeyCallbacks = {...
                @(x) x.NextRegionOfInterest(),...
                @(x) x.PreviousRegionOfInterest()};
            
            c1chHotkeys = {...
                'rightarrow',...
                'leftarrow'};
            
            % super-class call
            obj@ImageVolumeViewerTask(chProgressCacheFilePath, vsHotkeyLabels, c1fnHotkeyCallbacks, c1chHotkeys);
            
            % set properities
            obj.vsFeatureExtractionImageVolumeHandlersPaths = vsFeatureExtractionImageVolumeHandlersPaths;
            obj.sObjectVarName = sObjectVarName;
            
            dNumHandlers = length(vsFeatureExtractionImageVolumeHandlersPaths);
            
            c1oHandlers = cell(dNumHandlers,1);
            
            for dHandlerIndex=1:dNumHandlers
                c1oHandlers{dHandlerIndex} = FileIOUtils.LoadMatFile(vsFeatureExtractionImageVolumeHandlersPaths(dHandlerIndex), sObjectVarName);
            end
            
            obj.voHandlers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oHandlers);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function InitializeForBegin(obj)
            obj.SetImageVolumeViewerForCurrentState(true);            
        end
        
        function InitializeForResume(obj)
            obj.SetImageVolumeViewerForCurrentState(true);
        end
        
        function c1chProgressText = GetProgressText(obj)
            c1chProgressText = {...
                ['Handler #: ', num2str(obj.dCurrentHandlerIndex), '/', num2str(length(obj.vsFeatureExtractionImageVolumeHandlersPaths))],...
                ['ROI #: ', num2str(obj.dCurrentSampleIndex), '/', num2str(obj.voHandlers(obj.dCurrentHandlerIndex).GetNumberOfRegionsOfInterest())],...
                ['ROI Label: ', char(obj.voHandlers(obj.dCurrentHandlerIndex).GetUserDefinedSampleStringByExtractionIndex(obj.dCurrentSampleIndex))],...
                ['ROIs in Handler: [', num2str(obj.voHandlers(obj.dCurrentHandlerIndex).GetRegionOfInterestNumbersInExtractionOrder()'), ']'],...
                ['Handler Path: ', char(obj.vsFeatureExtractionImageVolumeHandlersPaths(obj.dCurrentHandlerIndex))]};            
        end
        
        function SaveProgress_ChildClass(obj)
            for dHandlerIndex=1:length(obj.voHandlers)
                FileIOUtils.SaveMatFile(obj.vsFeatureExtractionImageVolumeHandlersPaths(dHandlerIndex), obj.sObjectVarName, obj.voHandlers(dHandlerIndex));
            end
        end
        
        function ProcessCallback(obj, fnCallback)
            fnCallback(obj);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
            
        function SetImageVolumeViewerForCurrentState(obj, bNewImageVolume)            
            oApp = obj.GetImageVolumeViewerApp();
            
            if bNewImageVolume
                hProgressBar = uiprogressdlg(obj.GetImageVolumeViewerController().GetFigure(), 'Message', 'Loading Image Volume...', 'Indeterminate', 'on');
                                
                oApp.SetNewImageVolume(obj.voHandlers(obj.dCurrentHandlerIndex).GetRASImageVolume());
                
                delete(hProgressBar);
            end
            
            
            oFieldOfView = obj.voHandlers(obj.dCurrentHandlerIndex).GetRepresentativeFieldsOfViewForExtractionIndex(obj.dCurrentSampleIndex);
            oApp.SetCurrentImageVolumeView(oFieldOfView);
            
            dCurrentRoiIndex = obj.voHandlers(obj.dCurrentHandlerIndex).GetRegionOfInterestNumberBySampleIndex(obj.dCurrentSampleIndex);
            dTotalNumberRois = obj.voHandlers(obj.dCurrentHandlerIndex).GetRASImageVolume().GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dTotalNumberRois
                if dRoiIndex == dCurrentRoiIndex
                    oApp.SetRegionOfInterestVisibility(dRoiIndex, true);
                    oApp.SetRegionOfInterestColour(dRoiIndex, SetAllRepresentativeViewsForHandlersTask.vdCurrentRegionOfInterestColour_rgb);
                    oApp.SetRegionOfInterestVoxelMaskOverlayVisibility(SetAllRepresentativeViewsForHandlersTask.bVoxelMaskOverlayVisibility);
                    oApp.SetRegionOfInterestVoxelMaskOutlineLineWidth(SetAllRepresentativeViewsForHandlersTask.dVoxelMaskOutlineLineWidth);
                else
                    oApp.SetRegionOfInterestVisibility(dRoiIndex, false);
                end
            end
            
            obj.UpdateConsoleProgressText();
        end
        
        function NextRegionOfInterest(obj)
            oCurrentFov = obj.GetImageVolumeViewerApp().GetCurrentImageVolumeView();
            obj.voHandlers(obj.dCurrentHandlerIndex).SetRepresentativeFieldsOfViewForExtractionIndex(obj.dCurrentSampleIndex, oCurrentFov);
            
            bTaskComplete = false;
            bNewImageVolume = [];
            
            dStartingHandlerIndex = obj.dCurrentHandlerIndex;
            
            if obj.dCurrentSampleIndex < obj.voHandlers(obj.dCurrentHandlerIndex).GetNumberOfRegionsOfInterest()
                obj.dCurrentSampleIndex = obj.dCurrentSampleIndex + 1;
                bNewImageVolume = false;
            else
                if obj.dCurrentHandlerIndex == length(obj.voHandlers)
                    bTaskComplete = true;
                else
                    obj.dCurrentSampleIndex = 1;
                    obj.dCurrentHandlerIndex = obj.dCurrentHandlerIndex + 1;
                    bNewImageVolume = true;
                end
            end
            
            if bTaskComplete || bNewImageVolume
                obj.voHandlers(dStartingHandlerIndex).UnloadVolumeData();
            end
            
            if bTaskComplete
                obj.TaskComplete();
            else
                obj.SetImageVolumeViewerForCurrentState(bNewImageVolume);
            end
        end
           
        function PreviousRegionOfInterest(obj)
            oCurrentFov = obj.GetImageVolumeViewerApp().GetCurrentImageVolumeView();
            obj.voHandlers(obj.dCurrentHandlerIndex).SetRepresentativeFieldsOfViewForExtractionIndex(obj.dCurrentSampleIndex, oCurrentFov);
            
            bAlreadyAtStart = false;
            bNewImageVolume = [];
            
            dStartingHandlerIndex = obj.dCurrentHandlerIndex;
            
            if obj.dCurrentSampleIndex > 1
                obj.dCurrentSampleIndex = obj.dCurrentSampleIndex - 1;
                bNewImageVolume = false;
            else
                if obj.dCurrentHandlerIndex == 1
                    bAlreadyAtStart = true;
                else
                    obj.dCurrentHandlerIndex = obj.dCurrentHandlerIndex -1;
                    bNewImageVolume = true;
                    
                    obj.dCurrentSampleIndex = obj.voHandlers(obj.dCurrentHandlerIndex).GetNumberOfRegionsOfInterest();
                end
            end
            
            if bNewImageVolume
                obj.voHandlers(dStartingHandlerIndex).UnloadVolumeData();
            end
            
            if bAlreadyAtStart
                % no nothing
            else
                obj.SetImageVolumeViewerForCurrentState(bNewImageVolume);
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