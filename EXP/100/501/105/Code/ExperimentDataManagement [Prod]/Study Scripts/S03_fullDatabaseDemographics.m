function [] = S03_fullDatabaseDemographics()
% this script runs a variety of analyzes on the original patient database
% (distribution of imaging and patients stats)

% load database
data = load(Constants.databasePath);
database = data.database;

writePathRoot = Constants.S03_root;

% *************************************************************************
% 1) pre-treatment lead-up
filename = 'Pre-Treatment Imaging Period.png';

studyIdentifier = ImagingStudyIdentifier.preTreatment;
parameterIdentifier = ImagingStudyParameter.numberOfDaysFromTreatment;

[patientIds, studyNumbers, numDays] = database.getImagingStudyParameter(parameterIdentifier, studyIdentifier);

fig = figure();
histogram(numDays);

title('Distribution of Pre-Treatment Imaging Lead-up');
xlabel('Days');
ylabel('Num. of Patients');

grid('on');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


% *************************************************************************
% 2) post-treatment lead-up
filename = 'Post-Treatment Imaging Period.png';

studyIdentifier = ImagingStudyIdentifier.postTreatment;
parameterIdentifier = ImagingStudyParameter.numberOfDaysFromTreatment;

[patientIds, studyNumbers, numDays] = database.getImagingStudyParameter(parameterIdentifier, studyIdentifier);

fig = figure();
histogram(numDays);

title('Distribution of Post-Treatment Imaging Lead-up');
xlabel('Days');
ylabel('Num. of Patients');

grid('on');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


% *************************************************************************
% 3) In-plane resolution of pre-treatment studies
filename = 'Pre-Treatment Inplane Pixel Size.png';

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

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


% *************************************************************************
% 4) In-plane resolution of post-treatment studies
filename = 'Post-Treatment Inplane Pixel Size.png';

studyIdentifier = ImagingStudyIdentifier.postTreatment;
seriesIdentifier = ImagingSeriesIdentifier.contoured;
parameterIdentifier = ImagingSeriesParameter.inPlaneResolution;

[patientIds, studyNumbers, seriesNumbers, pixelSizes] = database.getImagingSeriesParameter(parameterIdentifier, studyIdentifier, seriesIdentifier);

fig = figure();
histogram(pixelSizes);

title('Distribution of Post-Treatment Imaging In-Plane Pixel Spacing');
xlabel('mm');
ylabel(['Num. of Patients [NaN=', num2str(sum(isnan(pixelSizes))), ']']);

grid('on');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


% *************************************************************************
% 5) Slice Thickness of pre-treatment studies
filename = 'Pre-Treatment Slice Thickness.png';

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

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


% *************************************************************************
% 6) Slice Thickness of post-treatment studies
filename = 'Post-Treatment Slice Thickness.png';

studyIdentifier = ImagingStudyIdentifier.postTreatment;
seriesIdentifier = ImagingSeriesIdentifier.contoured;
parameterIdentifier = ImagingSeriesParameter.sliceThickness;

[patientIds, studyNumbers, seriesNumbers, sliceThicknesses] = database.getImagingSeriesParameter(parameterIdentifier, studyIdentifier, seriesIdentifier);

fig = figure();
histogram(sliceThicknesses);

title('Distribution of Post-Treatment Imaging Slice Thickness');
xlabel('mm');
ylabel(['Num. of Patients [NaN=', num2str(sum(isnan(sliceThicknesses))), ']']);

grid('on');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


% *************************************************************************
% 7) Slice Thickness of all post-treatment studies
filename = 'All Post-Treatment Slice Thickness.png';

studyIdentifier = ImagingStudyIdentifier.allPostTreatment;
seriesIdentifier = ImagingSeriesIdentifier.contoured;
parameterIdentifier = ImagingSeriesParameter.sliceThickness;

[patientIds, studyNumbers, seriesNumbers, sliceThicknesses] = database.getImagingSeriesParameter(parameterIdentifier, studyIdentifier, seriesIdentifier);

fig = figure();
histogram(sliceThicknesses);

title('Distribution of All Post-Treatment Imaging Slice Thickness');
xlabel('mm');
ylabel(['Num. of Studies [NaN=', num2str(sum(isnan(sliceThicknesses))), ']']);

grid('on');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


% *************************************************************************
% 8) Pixel Sizing of all post-treatment studies
filename = 'All Post-Treatment Inplane Pixel Size.png';

studyIdentifier = ImagingStudyIdentifier.allPostTreatment;
seriesIdentifier = ImagingSeriesIdentifier.contoured;
parameterIdentifier = ImagingSeriesParameter.inPlaneResolution;

[patientIds, studyNumbers, seriesNumbers, pixelSpacing] = database.getImagingSeriesParameter(parameterIdentifier, studyIdentifier, seriesIdentifier);

fig = figure();
histogram(pixelSpacing);

title('Distribution of All Post-Treatment Imaging In-plane Pixel Spacing');
xlabel('mm');
ylabel(['Num. of Studies [NaN=', num2str(sum(isnan(pixelSpacing))), ']']);

grid('on');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);



% *************************************************************************
% 9) Imaging Period of ALL post-treatment studies
% show distribution of imaging periods, and plot of imaging timepoints

param = ImagingStudyParameter.numberOfDaysFromTreatment;

studyIdentifier = ImagingStudyIdentifier.allPostTreatment;
seriesIdentifier = ImagingSeriesIdentifier.all;

[patientIds, studyIndices, imagingPeriods] = database.getImagingStudyParameter(param, studyIdentifier, seriesIdentifier);

% plot of all patients as line plot
filename = 'All Post-Treatment Imaging Timepoints by Patient.png';
fig = figure();

for id=1:max(patientIds)
    mask = patientIds == id;
    
    %indices = studyIndices(mask);
    x = imagingPeriods(mask);
    y = id * ones(size(x));
    
    plot(x,y,'*-');
    hold('on');
end

grid('on');

title('Post-Treatment Imaging Timepoints');
xlabel('Days Since Treatment');
ylabel('Patient ID');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);

% histogram
filename = 'All Post-Treatment Imaging Period.png';
fig = figure();

if param.isNumerical
    histogram(imagingPeriods);
else
    cellArrayHistogram(imagingPeriods);
end

grid('on');

title('Distribution of All Post-Treatment Imaging Lead-up');
xlabel('Days');
ylabel('Num. of Studies');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);

% *************************************************************************
% 10) Find how many studies do not have a contoured imaging series

filename = 'Number of Contoured Series Within Studies.png';

studyIdentifier = ImagingStudyIdentifier.all;
seriesIdentifier = ImagingSeriesIdentifier.contoured;

param = ImagingStudyParameter.numberOfSeries;

[patientIds, studyNumbers, numContouredSeries] = database.getImagingStudyParameter(param, studyIdentifier, seriesIdentifier);


fig = figure();
histogram(numContouredSeries);

title('Distribution of Number of Contoured Series within Studies');
xlabel('Num. Contoured Series Within Study');
ylabel('Num. of Studies');

grid('on');

saveas(fig, [writePathRoot, '/', filename]);

close(fig);


end