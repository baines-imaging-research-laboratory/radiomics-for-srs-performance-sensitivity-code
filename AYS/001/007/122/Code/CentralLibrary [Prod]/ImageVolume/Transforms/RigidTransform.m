classdef RigidTransform < IndependentImagingObjectTransform
    %RigidTransform
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Nov 25, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        m2dAffineTransformMatrix
    end    
        
       
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public, Static = true)
        
        function m2dAffineTransformMatrix = GetAffineTransformMatrixFromDicomRegFile(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            stMetadata = dicominfo(chFilePath);
            
            m2dMatrix1 = stMetadata.RegistrationSequence.Item_1.MatrixRegistrationSequence.Item_1.MatrixSequence.Item_1.FrameOfReferenceTransformationMatrix;
            m2dMatrix2 = stMetadata.RegistrationSequence.Item_2.MatrixRegistrationSequence.Item_1.MatrixSequence.Item_1.FrameOfReferenceTransformationMatrix;
            
            m2dMatrix1 = reshape(m2dMatrix1,4,4)';
            m2dMatrix2 = reshape(m2dMatrix2,4,4)';
            
            if all(m2dMatrix1 == eye(4))
                m2dAffineTransformMatrix = m2dMatrix2;
            elseif all(m2dMatrix2 == eye(4))
                m2dAffineTransformMatrix = m2dMatrix1;
            else
                error(...
                    'RigidTransform:GetAffineTransformMatrixFromDicomRegFile:InvalidFile',...
                    'At least one of the transform matrices need to be the identity matrix.')
            end
            
            m2dAffineTransformMatrix = m2dAffineTransformMatrix .* [... % this transform converts DICOM LPS to BOLT RAS
                1 1 -1 -1; 
                1 1 -1 -1; 
                -1 -1 1 1; 
                0 0 0 1]; 
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject})
        
        function obj = RigidTransform(oCurrentImageVolumeGeometry, m2dAffineTransformMatrix)
            arguments
                oCurrentImageVolumeGeometry (1,1) ImageVolumeGeometry
                m2dAffineTransformMatrix (4,4) double
            end
                        
            oPostTransformImageVolumeGeometry = oCurrentImageVolumeGeometry.ApplyRigidTransform(m2dAffineTransformMatrix);
            
            % Super-class Constructor
            obj@IndependentImagingObjectTransform(oPostTransformImageVolumeGeometry, oPostTransformImageVolumeGeometry);
                
            % Set properities
            obj.m2dAffineTransformMatrix = m2dAffineTransformMatrix;
        end
        
        function Apply(obj, oImagingObject)
            %nothing required, just the ImageVolumeGeometry is moving
            %around
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

