classdef (Abstract) ImageVolumeViewerTask < matlab.mixin.Copyable
    %ImageVolumeViewerTask
    %
    
    
    % Primary Author: David DeVries
    % Created: Oct 25, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        c1fnHotkeyCallbacks
        vsHotkeyLabels
    end    
    
    properties (SetAccess = protected, GetAccess = public)
        oImageVolumeViewer 
    end
    
    properties (SetAccess = private, GetAccess = public)
        chProgressCacheFilePath
        
        c1chHotkeys
                
        oConsoleApp
        
        bIsInitialized = false
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oTask'
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImageVolumeViewerTask(chProgressCacheFilePath, vsHotkeyLabels, c1fnHotkeyCallbacks, c1chHotkeys)
            % obj = ImageVolumeViewerTask(chProgressCacheFilePath, vsHotkeyLabels, c1fnHotkeyCallbacks, c1chHotkeys)
            arguments
               chProgressCacheFilePath (1,:) char
               vsHotkeyLabels (:,1) string 
               c1fnHotkeyCallbacks (:,1) cell
               c1chHotkeys (:,1) cell
            end
            
            obj.chProgressCacheFilePath = chProgressCacheFilePath;
            
            obj.vsHotkeyLabels = [...
                "Toggle Task Console";...
                "Save Progress";...
                vsHotkeyLabels];
            
            obj.c1fnHotkeyCallbacks = [...
                {@(x) x.ToggleConsoleVisibility()};...
                {@(x) x.SaveProgress()};...
                c1fnHotkeyCallbacks];
            
            obj.c1chHotkeys = [...
                {'f1'};...
                {'f2'};...
                c1chHotkeys];
        end
        
        function Begin(obj)
            obj.oImageVolumeViewer = ImageVolumeViewer();                   
            obj.oImageVolumeViewer.SetTask(obj);
            
            ImageVolumeViewerTaskConsole(obj);
            
            obj.InitializeForBegin();
            
            obj.UpdateConsoleProgressText();     
            
            obj.bIsInitialized = true;
            
            uiwait(obj.GetImageVolumeViewerController().GetFigure());
        end
        
        function Resume(obj, chNewProgressCacheFilePath)
            arguments
                obj (1,1) ImageVolumeViewerTask
                chNewProgressCacheFilePath (1,:) char = ''
            end
            
            if ~isempty(chNewProgressCacheFilePath)
                obj.chProgressCacheFilePath = chNewProgressCacheFilePath;
            end
            
            obj.oImageVolumeViewer = ImageVolumeViewer();                   
            obj.oImageVolumeViewer.SetTask(obj);
            
            ImageVolumeViewerTaskConsole(obj);
            
            obj.InitializeForResume();
            
            obj.UpdateConsoleProgressText(); 
            
            obj.bIsInitialized = true;
            
            uiwait(obj.GetImageVolumeViewerController().GetFigure());
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function oTask = Load(sFilePath)
            arguments
                sFilePath (1,1) string
            end
            
            oTask = FileIOUtils.LoadMatFile(sFilePath, ImageVolumeViewerTask.chMatFileVarName);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract = true)
        SaveProgress_ChildClass(obj)
        InitializeForBegin(obj)
        InitializeForResume(obj)
        c1chProgressText = GetProgressText(obj)
        ProcessCallback(obj, fnCallback);
    end
    
    methods (Access = protected)
        
        function SetImageVolumeViewer(obj, oImageVolumeViewer)
            arguments
                obj
                oImageVolumeViewer
            end
            
            obj.oImageVolumeViewer = oImageVolumeViewer;
        end
        
        function TaskComplete(obj)
            delete(obj.oImageVolumeViewer);
            delete(obj.oConsoleApp);
        end
        
        function oApp = GetImageVolumeViewerApp(obj)
            oApp = obj.oImageVolumeViewer;
        end
        
        function oController = GetImageVolumeViewerController(obj)
            if isempty(obj.oImageVolumeViewer)
                oController = [];
            else
                oController = obj.oImageVolumeViewer.oImageVolumeViewerController;
            end
        end
        
        function ToggleConsoleVisibility(obj)
            if strcmp(obj.oConsoleApp.MainFigure.Visible, 'on')
                obj.oConsoleApp.MainFigure.Visible = 'off';
            else
                obj.oConsoleApp.MainFigure.Visible = 'on';
            end
        end
        
        function UpdateConsoleProgressText(obj)
            obj.oConsoleApp.TaskProgressTextArea.Value = obj.GetProgressText();
        end
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            % local call
            
        end
        
        function saveObj = saveobj(obj)
            saveObj = copy(obj);
            
            saveObj.oImageVolumeViewer = [];
            saveObj.oConsoleApp = [];
            saveObj.bIsInitialized = false;
        end
                
        function SaveProgress(obj)
            FileIOUtils.SaveMatFile(obj.chProgressCacheFilePath, ImageVolumeViewerTask.chMatFileVarName, obj);
            
            obj.SaveProgress_ChildClass();
            
            uialert(obj.GetImageVolumeViewerController().GetFigure(), 'Progress Saved', 'Save Complete', 'Icon', 'success');
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = ?ImageVolumeViewerController)
        
        function ProcessKeyPress(obj, chKeyPress)
            for dHotkeyIndex=1:length(obj.c1chHotkeys)
                if strcmp(obj.c1chHotkeys{dHotkeyIndex}, chKeyPress)
                    fnCallback = obj.c1fnHotkeyCallbacks{dHotkeyIndex};
                    obj.ProcessCallback(fnCallback);
                    break;
                end
            end
        end
        
        function ImageVolumeViewerCloseRequest(obj)
            if obj.bIsInitialized
                obj.SaveProgress();
            end
            
            delete(obj.oConsoleApp);
        end
    end
    
    methods (Access = ?ImageVolumeViewerTaskConsole)
        
        function Console_startupFcn(obj, oApp)
            obj.oConsoleApp = oApp;
            
            dNumHotkeys = length(obj.c1chHotkeys);
            c1chTableData = cell(dNumHotkeys,2);
            
            for dHotkeyIndex=1:dNumHotkeys
                c1chTableData{dHotkeyIndex,1} = char(obj.vsHotkeyLabels(dHotkeyIndex));
                c1chTableData{dHotkeyIndex,2} = obj.c1chHotkeys{dHotkeyIndex};
            end
            
            oApp.TaskActionsUITable.Data = c1chTableData;
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