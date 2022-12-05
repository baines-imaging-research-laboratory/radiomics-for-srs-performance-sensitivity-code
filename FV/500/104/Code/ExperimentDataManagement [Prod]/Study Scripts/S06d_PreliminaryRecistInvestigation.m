function [] = S06d_PreliminaryRecistInvestigation()

% load database
data = load(Constants.databasePath);
database = data.database;


% extract RECIST measurements
studyId = ImagingStudyIdentifier.all;
seriesId = ImagingSeriesIdentifier.contoured;
contourId = ContourIdentifier.all;

param = ContourParameter.recistProtocolMeasurement;

[recistPatientId, recistStudyNum, recistSeriesNum, recistContourNum, recistVals] = ...
    database.getContourParameter(param, studyId, seriesId, contourId);

param = ImagingSeriesParameter.numberOfContours;

[numContoursPatientId, numContourStudyNum, numContoursSeriesNum, numContours] = ...
    database.getImagingSeriesParameter(param, studyId, seriesId);

param = ImagingStudyParameter.numberOfDaysFromTreatment;

[numDaysPatientId, numDaysStudyNum, numDaysFromTreatment] = ...
    database.getImagingStudyParameter(param, studyId);

% plot all
fig = figure;

for patientId=1:max(recistPatientId)
    if max(numContours(numContoursPatientId == patientId)) == 1 % let's only work with single contours for now
        patientRecistVals = recistVals(recistPatientId == patientId);
        
        studyNumsForVals = recistStudyNum(recistPatientId == patientId);
        numDaysFromTreatmentForVals = zeros(size(patientRecistVals));
        
        for i = 1:length(studyNumsForVals)
            numDaysFromTreatmentForVals(i) = ...
                numDaysFromTreatment( (numDaysPatientId == patientId) & (numDaysStudyNum == studyNumsForVals(i)) );
        end
        
        plot(numDaysFromTreatmentForVals, patientRecistVals, '*-');
        hold('on');
    end
end

xlabel('Days From Treatment');
ylabel('RECIST (mm)');
title('RECIST Trajectories of all Patients with Single Tumours');
grid('on');

% plot those that increase (no reponse)
fig = figure;

for patientId=1:max(recistPatientId)
    if max(numContours(numContoursPatientId == patientId)) == 1 % let's only work with single contours for now
        patientRecistVals = recistVals(recistPatientId == patientId);
        
        if patientRecistVals(2) > patientRecistVals(1) % no response        
            studyNumsForVals = recistStudyNum(recistPatientId == patientId);
            numDaysFromTreatmentForVals = zeros(size(patientRecistVals));
            
            for i = 1:length(studyNumsForVals)
                numDaysFromTreatmentForVals(i) = ...
                    numDaysFromTreatment( (numDaysPatientId == patientId) & (numDaysStudyNum == studyNumsForVals(i)) );
            end
            
            plot(numDaysFromTreatmentForVals, patientRecistVals, '*-');
            hold('on');
        end
    end
end

xlabel('Days From Treatment');
ylabel('RECIST (mm)');
title('RECIST Trajectories of all Non-Responding Patients with Single Tumours');
grid('on');

% plot those that decreased (reponsed)
fig = figure;

for patientId=1:max(recistPatientId)
    if max(numContours(numContoursPatientId == patientId)) == 1 % let's only work with single contours for now
        patientRecistVals = recistVals(recistPatientId == patientId);
        
        if length(patientRecistVals) == 2
            bool = patientRecistVals(2) <= patientRecistVals(1);
        else
            bool = patientRecistVals(2) <= patientRecistVals(1) && patientRecistVals(3) <= patientRecistVals(2);% responded
        end
        
        if bool
            studyNumsForVals = recistStudyNum(recistPatientId == patientId);
            numDaysFromTreatmentForVals = zeros(size(patientRecistVals));
            
            for i = 1:length(studyNumsForVals)
                numDaysFromTreatmentForVals(i) = ...
                    numDaysFromTreatment( (numDaysPatientId == patientId) & (numDaysStudyNum == studyNumsForVals(i)) );
            end
            
            plot(numDaysFromTreatmentForVals, patientRecistVals, '*-');
            hold('on');
        end
    end
end

xlabel('Days From Treatment');
ylabel('RECIST (mm)');
title('RECIST Trajectories of all Respond-Respond Patients with Single Tumours');
grid('on');

% plot those that decreased (reponsed)
fig = figure;

for patientId=1:max(recistPatientId)
    if max(numContours(numContoursPatientId == patientId)) == 1 % let's only work with single contours for now
        patientRecistVals = recistVals(recistPatientId == patientId);
        
        if length(patientRecistVals) == 2
            bool = false; % captured in Respond-Respond above
        else
            bool = patientRecistVals(2) <= patientRecistVals(1) && patientRecistVals(3) > patientRecistVals(2);% responded
        end
        
        if bool
            studyNumsForVals = recistStudyNum(recistPatientId == patientId);
            numDaysFromTreatmentForVals = zeros(size(patientRecistVals));
            
            for i = 1:length(studyNumsForVals)
                numDaysFromTreatmentForVals(i) = ...
                    numDaysFromTreatment( (numDaysPatientId == patientId) & (numDaysStudyNum == studyNumsForVals(i)) );
            end
            
            plot(numDaysFromTreatmentForVals, patientRecistVals, '*-');
            hold('on');
        end
    end
end

xlabel('Days From Treatment');
ylabel('RECIST (mm)');
title('RECIST Trajectories of all Respond-Non-Respond Patients with Single Tumours');
grid('on');

end

