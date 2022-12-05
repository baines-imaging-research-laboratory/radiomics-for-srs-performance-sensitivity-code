classdef IntensityHistogramMatchingTransform < DependentImagingObjectTransform
    %IntensityHistogramMatchingTransform 
    %
    % The intensity values for an image are altered to match the histogram
    % of a reference image using the Matlab "imhistmatch" function.
    % This transform is a DependentImagingObject, since it requires a
    % reference image to be computed.
    
    % Primary Author: David DeVries
    % Created: June 21, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        chReferenceImageVolumeOriginalFilePath (1,:) char
        chReferenceImageVolumeMatFilePath (1,:) char
        
        dNumBins (1,1) double {mustBePositive, mustBeInteger} = 1
    end    
        
       
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public) % None
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function ApplyWithDependentInputs(obj, oImageVolume, oReferenceImageVolume)
            % setup
            m3xCurrentImageData = oImageVolume.GetCurrentImageDataForTransform();
            
            m3xReferenceImageData = oReferenceImageVolume.GetImageData();
            
            chReferenceImageDataClass = class(m3xReferenceImageData);
            
            dMin = min(m3xReferenceImageData(:));
            dMax = max(m3xReferenceImageData(:));
            
            vdReferenceImageValueCounts = zeros(1,dMax-dMin+1);
            
            for dDataIndex=1:numel(m3xReferenceImageData)
                dCountIndex = m3xReferenceImageData(dDataIndex) - dMin + 1;
                vdReferenceImageValueCounts(dCountIndex) = vdReferenceImageValueCounts(dCountIndex) + 1;
            end
                      
            % apply transform
            if ~isa(m3xCurrentImageData, chReferenceImageDataClass)
                chCurrentImageDataClass = class(m3xCurrentImageData);
                bError = true;
                
                if length(chReferenceImageDataClass) >= 4 && strcmp(chReferenceImageDataClass(1:4), 'uint')
                    if length(chCurrentImageDataClass) >= 3 && strcmp(chCurrentImageDataClass(1:3), 'int')
                        if strcmp(chReferenceImageDataClass(end-1:end), chCurrentImageDataClass(end-1:end))
                            if min(m3xCurrentImageData(:)) >= 0
                                m3xCurrentImageData = cast(m3xCurrentImageData, chReferenceImageDataClass);
                                bError = false;
                            end
                        end
                    end
                end
                
                if bError
                    error(...
                        'IntensityHistogramMatchingTransform:ApplyIntensityTransformToImageDataMatrix:ClassTypeMismatch',...
                        'The reference image data matrix type does not match that of the image volume image data matrix. See MATLAB docs on "imhistmatchn" for more details and look into why this would not be a great idea.');
                end
            end
            
            m3xReferenceImageData = zeros(1,sum(vdReferenceImageValueCounts), chReferenceImageDataClass);
            
            dInsertIndex = 1;
            xInsertValue = cast(dMin, chReferenceImageDataClass);
            
            for dValueIndex=1:length(vdReferenceImageValueCounts)
                dNumToInsert = vdReferenceImageValueCounts(dValueIndex);
                
                m3xReferenceImageData(dInsertIndex : dInsertIndex + dNumToInsert - 1) = xInsertValue;
                
                dInsertIndex = dInsertIndex + dNumToInsert;
                xInsertValue = xInsertValue + 1;
            end
            
            m3xTransformedImageData = imhistmatch(m3xCurrentImageData(:), m3xReferenceImageData, obj.dNumBins, 'Method', 'Polynomial');
            m3xTransformedImageData = reshape(m3xTransformedImageData, size(m3xCurrentImageData));
            
            oImageVolume.ApplyImagingObjectIntensityTransform(m3xTransformedImageData);
        end
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject})
        
        function obj = IntensityHistogramMatchingTransform(oImageVolume, oReferenceImageVolume, dNumBins)
            arguments
                oImageVolume (1,1) ImageVolume
                oReferenceImageVolume (1,1) ImageVolume
                dNumBins (1,1) double {mustBeInteger, mustBePositive}
            end
            
            % super-class call
            oImageVolumeGeometry = oImageVolume.GetImageVolumeGeometry();
            
            obj@DependentImagingObjectTransform(oImageVolumeGeometry, oImageVolumeGeometry, oReferenceImageVolume); % target and post-transform geometry will be equal
            
            % local call
            obj.chReferenceImageVolumeOriginalFilePath = oReferenceImageVolume.GetOriginalFilePath();
            obj.chReferenceImageVolumeMatFilePath = oReferenceImageVolume.GetMatFilePath();
            
            obj.dNumBins = dNumBins;
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

