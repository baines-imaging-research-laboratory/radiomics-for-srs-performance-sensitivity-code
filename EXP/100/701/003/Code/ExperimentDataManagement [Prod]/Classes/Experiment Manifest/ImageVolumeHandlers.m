classdef ImageVolumeHandlers
    %ImageVolumeHandlers
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        vsHandlerFileNames (:,1) string
        
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oImageVolumeHandlers'
        chCentralLibraryMatFileVarName = 'oHandler'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImageVolumeHandlers(sIdTag, vsHandlerFileNames)
            arguments
                sIdTag (1,1) string
                vsHandlerFileNames (:,1) string
            end
            
            obj.sIdTag = sIdTag;
            obj.vsHandlerFileNames = vsHandlerFileNames;
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function vsFilePaths = GetImageVolumeHandlerFilePaths(obj)
            dNumHandlers = length(obj.vsHandlerFileNames);
            
            sImageVolumeHandlersRootPath = ExperimentManager.GetImageVolumeHandlersRootPath();            
            sImageDatabaseRootPath = ExperimentManager.GetImageDatabaseRootPath();
                        
            vsFilePaths = strings(dNumHandlers,1);
                        
            for dHandlerIndex=1:dNumHandlers
                vsFilePaths(dHandlerIndex) = string(fullfile(sImageVolumeHandlersRootPath, obj.sIdTag, obj.vsHandlerFileNames(dHandlerIndex)));
            end
        end
        
        function voImageVolumeHandlers = GetImageVolumeHandlers(obj)
            dNumHandlers = length(obj.vsHandlerFileNames);
                  
            sImageDatabaseRootPath = ExperimentManager.GetImageDatabaseRootPath();
                        
            c1oImageVolumeHandlers = cell(dNumHandlers,1);
                        
            for dHandlerIndex=1:dNumHandlers
                oHandler = FileIOUtils.LoadMatFile(obj.vsHandlerFileNames(dHandlerIndex), ImageVolumeHandlers.chCentralLibraryMatFileVarName);
                                
                c1oImageVolumeHandlers{dHandlerIndex} = oHandler;
            end
            
            voImageVolumeHandlers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oImageVolumeHandlers);
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) ImageVolumeHandlers
                chFilePath (1,:) char = fullfile(Experiment.GetResultsDirectory(), obj.GetIdTag()+".mat")
            end
            
            FileIOUtils.SaveMatFile(chFilePath, ImageVolumeHandlers.chMatFileVarName, obj);
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ImageVolumeHandlers.chMatFileVarName);
        end
        
        function chVarName = GetCentralLibraryMatFileVarName()
            chVarName = ImageVolumeHandlers.chCentralLibraryMatFileVarName;
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
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

