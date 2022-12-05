classdef (Abstract) OpenCVClassifier < Classifier
    %OpenCVClassifier
    %
    % OpenCV Classifier is an ABSTRACT class (cannot be instantiated) that
    % describes the user interface of any OpenCV classifier in this
    % library. We have shifted away from OpenCV so this class will simply
    % act as a guide for future developers who require an OpenCV classifier.
    
    % Primary Author: Salma Dammak
    % Created: Feb 31, 2019
    
    properties
        % All properties are defined in the superclass or subclass
    end
    
    methods 
       %% Consructor
       function obj = OpenCVClassifier(chClassifierHypersParametersFileName,chOptimizationOptionsFileName)
            if nargin == 1
                chOptimizationOptionsFileName = [];
            end
            obj = obj@Classifier(chClassifierHyperParametersFileName,chOptimizationOptionsFileName);

            % The Classifier class sets all implementations to false, this line flip it to "true"
            % for the appropriate implementation
%             obj.stImplementation.bOpenCV = true;          
       end
        %% Train
        function obj = Train (obj,~)
                disp(['Classifier ', obj.GetClassifierName(),' uses an OpenCV implementation.'])
                error('OpenCV is not yet implemented in BOLT, please choose a different implementation.')
        end
    end
end