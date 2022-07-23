classdef RecistMeasurements
    %RecistMeasurements
    
    properties (Access = private)
        dPreTreatmentMeasurement_mm
        dPostTreatmentMeasurement_mm
    end
    
    methods (Access = public)
        function obj = RecistMeasurements(dPreTreatmentMeasurement_mm, dPostTreatmentMeasurement_mm)
            %obj = RecistMeasurements(preTreatmentMeasurement_mm, postTreatmentMeasurement_mm)
            obj.dPreTreatmentMeasurement_mm = dPreTreatmentMeasurement_mm;
            obj.dPostTreatmentMeasurement_mm = dPostTreatmentMeasurement_mm;
        end
    end
    
    methods (Access = public, Static)
        function eResponse = evaulateResponse(c1oTumours)
            dNumTumours = length(c1oTumours);
            
            dPreTreatmentSum = 0;
            dPostTreatmentSum = 0;
            
            for dTumourIndex=1:dNumTumours
                dPreTreatmentSum = dPreTreatmentSum + c1oTumours{dTumourIndex}.RecistMeasurements.preTreatmentMeasurement_mm;
                dPostTreatmentSum = dPostTreatmentSum + c1oTumours{dTumourIndex}.RecistMeasurements.postTreatmentMeasurement_mm;
            end
            
            dPercentChange = (dPostTreatmentSum ./ dPreTreatmentSum) - 1;
            
            if dPostTreatmentSum == 0
                eResponse = RecistResponseEvaluation.CR; % Complete Response
            elseif dPercentChange <= -0.3
                eResponse = RecistResponseEvaluation.PR; % Partial Response
            elseif dPercentChange >= 0.2
                eResponse = RecistResponseEvaluation.PD; % Progressive Disease
            else
                eResponse = RecistResponseEvaluation.SD; % Stable Disease
            end
        end
    end
end

