classdef SampleSelection
    %SampleSelection
    %
    % Provides a sub-selection of patients and lesions for use within a
    % given a study.
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        vdPatientIdPerSample (:,1) double {mustBeInteger, mustBePositive}
        vdBrainMetastasisNumberPerSample (:,1) double {mustBeInteger, mustBePositive}
        
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oSampleSelection'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = SampleSelection(vdPatientIdPerSample, vdBrainMetastasisNumberPerSample)
            arguments
                vdPatientIdPerSample (:,1) double {mustBeInteger, mustBePositive}
                vdBrainMetastasisNumberPerSample (:,1) double {mustBeInteger, mustBePositive}
            end
            
            vdUniquePatientIds = unique(vdPatientIdPerSample);
            dNumPatients = length(vdUniquePatientIds);
                        
            for dPatientIndex=1:dNumPatients
                vdBMNumbersForPatient = vdBrainMetastasisNumberPerSample(vdPatientIdPerSample == vdUniquePatientIds(dPatientIndex));
                
                if numel(vdBMNumbersForPatient) ~= numel(unique(vdBMNumbersForPatient))
                    error(...
                        'SampleSelection:Constructor:NonUniqueBMNumbers',...
                        'BM numbers for a patient must not be repeated.');
                end
            end
            
            
            obj.vdPatientIdPerSample = vdPatientIdPerSample;
            obj.vdBrainMetastasisNumberPerSample = vdBrainMetastasisNumberPerSample;
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            dNumSamples = length(obj.vdPatientIdPerSample);
        end
                
        function [vdPatientIdPerSample, vdBrainMetastasisNumberPerSample] = GetPatientIdAndBrainMetastasisNumberPerSample(obj)
            vdPatientIdPerSample = obj.vdPatientIdPerSample;
            vdBrainMetastasisNumberPerSample = obj.vdBrainMetastasisNumberPerSample;
        end
        
        function [vdPatientIds, c1vdBrainMetastasisNumbersPerPatient] = GetPatientIdsAndBrainMetastasisNumbersPerPatient(obj)
            vdPatientIds = unique(obj.vdPatientIdPerSample);
            dNumPatients = length(vdPatientIds);
            
            c1vdBrainMetastasisNumbersPerPatient = cell(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                c1vdBrainMetastasisNumbersPerPatient{dPatientIndex} = obj.vdBrainMetastasisNumberPerSample(obj.vdPatientIdPerSample == vdPatientIds(dPatientIndex));
            end
        end
        
        function oFeatureValues = ApplySampleSelectionToFeatureValues(obj, oFeatureValues)
            arguments
                obj (1,1) SampleSelection
                oFeatureValues FeatureValues
            end
            
            if ~isempty(oFeatureValues)
                viGroupIds = oFeatureValues.GetGroupIds();
                viSubGroupIds = oFeatureValues.GetSubGroupIds();
                
                vbKeepSample = false(size(viGroupIds));
                
                % Group ID = Patient ID, Sub-Group ID = BM Number
                for dSampleIndex=1:length(viGroupIds)
                    if any(obj.vdPatientIdPerSample == viGroupIds(dSampleIndex) & obj.vdBrainMetastasisNumberPerSample == viSubGroupIds(dSampleIndex))
                        vbKeepSample(dSampleIndex) = true;
                    else
                        vbKeepSample(dSampleIndex) = false;
                    end
                end
                
                oFeatureValues = oFeatureValues(vbKeepSample, :);
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = SampleSelection.LoadFromSpreadsheet(strrep(chFilePath, '.mat', '.xlsx'));
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    
    methods (Access = private, Static = true)
        
        function obj = LoadFromSpreadsheet(sPath)
            arguments
                sPath (1,1) string
            end
            
            c2xRawData = readcell(sPath, 'Sheet', 'Sample Selection');
            
            vdPatientIds = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xRawData(3:end,1));
            vdBMNumbers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xRawData(3:end,3));
            vsExclude = string(c2xRawData(3:end,4));
            
            vbKeepSample = ismissing(vsExclude);
            
            obj = SampleSelection(vdPatientIds(vbKeepSample), vdBMNumbers(vbKeepSample));
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

