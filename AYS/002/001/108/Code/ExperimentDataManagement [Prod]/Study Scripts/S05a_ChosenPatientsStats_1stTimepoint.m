function [] = S04a_ChosenPatientsStats_1stTimepoint()
%[] = S04a_ChosenPatientsStats_1stTimepoint()

% load database
data = load(Constants.databasePath);
database = data.database;

writePathRoot = Constants.S04a_root;

% exclude patients not within first timepoint

week = days(7);

timepointStarts_days = Constants.chosen1stTimepoint_weeks * week;
timepointBracket_days = Constants.chosenTimepointBracket_weeks * week;

patients = database.getPatientsWithImagingStudiesWithinTimepointsFromTreatment(...
    timepointStarts_days, timepointBracket_days);

database.patients = patients;

% produce stats graphs

% *************************************************************************
% 1) pre-treatment lead-up
filename = 'Pre-Treatment Imaging Period';

studyIdentifier = ImagingStudyIdentifier.preTreatment;
parameterIdentifier = ImagingStudyParameter.numberOfDaysFromTreatment;

[patientIds, studyNumbers, numDays] = database.getImagingStudyParameter(parameterIdentifier, studyIdentifier);

fig = figure();
histogram(numDays);

title('Distribution of Pre-Treatment Imaging Lead-up');
xlabel('Days');
ylabel('Num. of Patients');

grid('on');

saveas(fig, [writePathRoot, '/', filename, '.png']);
savefig(fig, [writePathRoot, '/', filename, '.fig']);

close(fig);

% *************************************************************************
% 2) In-plane resolution of pre-treatment studies
filename = 'Pre-Treatment Inplane Pixel Size';

studyIdentifier = ImagingStudyIdentifier.preTreatment;
seriesIdentifier = ImagingSeriesIdentifier.contoured;
parameterIdentifier = ImagingSeriesParameter.inPlaneResolution;

[patientIds, studyNumbers, seriesNumbers, pixelSizes] = database.getImagingSeriesParameter(parameterIdentifier, studyIdentifier, seriesIdentifier);

fig = figure();
histogram(pixelSizes);

title('Distribution of Pre-Treatment Imaging In-Plane Pixel Spacing');
xlabel('mm');
ylabel(['Num. of Patients [NaN=', num2str(sum(isnan(pixelSizes))), ']']);

grid('on');

saveas(fig, [writePathRoot, '/', filename, '.png']);
savefig(fig, [writePathRoot, '/', filename, '.fig']);

close(fig);


% *************************************************************************
% 3) Slice Thickness of pre-treatment studies
filename = 'Pre-Treatment Slice Thickness';

studyIdentifier = ImagingStudyIdentifier.preTreatment;
seriesIdentifier = ImagingSeriesIdentifier.contoured;
parameterIdentifier = ImagingSeriesParameter.sliceThickness;

[patientIds, studyNumbers, seriesNumbers, sliceThicknesses] = database.getImagingSeriesParameter(parameterIdentifier, studyIdentifier, seriesIdentifier);

fig = figure();
histogram(sliceThicknesses);

title('Distribution of Pre-Treatment Imaging Slice Thickness');
xlabel('mm');
ylabel(['Num. of Patients [NaN=', num2str(sum(isnan(sliceThicknesses))), ']']);

grid('on');

saveas(fig, [writePathRoot, '/', filename, '.png']);
savefig(fig, [writePathRoot, '/', filename, '.fig']);

close(fig);

% *************************************************************************
% 1ST TIMEPOINT STUDIES
% *************************************************************************

studyIdentifier = ImagingStudyIdentifier.withinTimepointsFromTreatmentDate;
studyIdentifier.setWithinTimepointsFromTreatmentDateParams(timepointStarts_days, timepointStarts_days + timepointBracket_days);

% 4) Number of studies within first timepoint bracket
filename = 'Number of Studies in First Timepoint';

parameterIdentifier = PatientParameter.numberOfImagingStudies;

[patientsIds, numStudies] = database.getPatientParameter(parameterIdentifier, studyIdentifier);

fig = figure();
histogram(numStudies);

title('Distribution of Number of Studies within First Timepoint Bracket');
xlabel('Number of Studies within Timepoint Bracket');
ylabel('Num. of Patients');

grid('on');

saveas(fig, [writePathRoot, '/', filename, '.png']);
savefig(fig, [writePathRoot, '/', filename, '.fig']);

close(fig);

% 5)

end

