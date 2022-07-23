classdef Imaging3DRenderAxes < handle
    %Imaging3DRenderAxes
    % 
    % Primary Author: David DeVries
    % Created: Oct 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        chLightingStyle = 'flat'
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
       hAxes
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Imaging3DRenderAxes(hAxes)
            
            arguments
                hAxes (1,1) {ValidationUtils.MustBeAxes(hAxes)}
            end
            
            Imaging3DRenderAxes.PrepareAxesFor3DRender(hAxes);
            obj.hAxes = hAxes;
        end
        
        function hAxes = GetAxes(obj)
            hAxes = obj.hAxes;
        end
        
        function SetLightingStyle(obj, chLightingStyle)
            arguments
                obj
                chLightingStyle (1,:) char
            end
            
            obj.chLightingStyle = chLightingStyle;
        end
        
        function UpdateAxesWithLightingStyle(obj)
            lighting(obj.hAxes, obj.chLightingStyle);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)           
        
        function PrepareAxesFor3DRender(h3DAxes)
            h3DAxes.Color = [0 0 0]; % black background
            axis(h3DAxes, 'equal');
            axis(h3DAxes, 'off');
            h3DAxes.NextPlot = 'add';
            
            if isa(h3DAxes, 'matlab.ui.control.UIAxes')
                h3DAxes.BackgroundColor = [0 0 0];
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