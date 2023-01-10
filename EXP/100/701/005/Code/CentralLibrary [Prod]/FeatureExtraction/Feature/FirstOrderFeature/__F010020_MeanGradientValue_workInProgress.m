% % % % classdef F010020_MeanGradientValue < FirstOrderFeature
% % % %     %Image
% % % %     %
% % % %    
% % % %     % Primary Author: Salma Dammak
% % % %     % Created: May 13, 2019
% % % %     
% % % %     
% % % %     % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
% % % %     % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
% % % %     % *********************************************************************                               X.3 Private
% % % %      
% % % %     properties (Constant = true, GetAccess = public)
% % % %         sFeatureName = "F010020"
% % % %         sFeatureDisplayName = "90th Percentile"
% % % %     end    
% % % %     
% % % %     % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
% % % %     % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
% % % %     % *********************************************************************
% % % %          
% % % %     methods (Access = public)
% % % %         
% % % %         function obj = F010020_MeanGradientValue()
% % % %         end
% % % %     end
% % % %     methods (Access = protected)
% % % %         function dValue = ExtractFeature(obj,oImage, oFeatureExtractionParameters)
% % % %             % Get mean
% % % %             [m3xImageData, m3bMask] = GetCurrentRegionOfInterestImageDataAndMask(oImage);
% % % %             %%% WORK IN PROGRESS %%% 
% % % %             dValue = NaN;
% % % %             % Does not exist in PyRadiomics or Aerts
% % % %         end
% % % % 
% % % %     end
% % % %   
% % % %     % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
% % % %     % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
% % % %     % *********************************************************************
% % % % 
% % % %     % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
% % % %     % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
% % % %     % *********************************************************************
% % % % 
% % % %     % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% % % %     % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% % % %       
% % % %     % *********************************************************************
% % % %     % *                        UNIT TEST ACCESS                           *
% % % %     % *                  (To ONLY be called by tests)                     *
% % % %     % *********************************************************************
% % % %     
% % % %     methods (Access = {?matlab.unittest.TestCase}, Static = false)        
% % % %     end
% % % %     
% % % %     
% % % %     methods (Access = {?matlab.unittest.TestCase}, Static = true)        
% % % %     end
% % % % end
% % % % 
