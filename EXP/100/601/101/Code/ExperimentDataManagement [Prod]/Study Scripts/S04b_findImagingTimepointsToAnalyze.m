function [] = S04b_findImagingTimepointsToAnalyze()
%[] = S04b_findImagingTimepointsToAnalyze()

% load database
data = load(Constants.databasePath);
database = data.database;

writePath = Constants.S04_root;

% S03a provides analysis to help the user choose which timepoints to use
% (first imaging timepoint and bracket size)
% With that chosen, let's get some more stats on using this

% from S04a (Jan 22, 2019)
% Choosing:
%   - 1st Timepoint: 10 - 20 weeks
%   - expected: 88 patients at 1st timepoint, 78 at 2nd timepoint

week = days(7);

chosenStartNumWeeks = [10 10 8];
chosenBracketSizeWeeks = [8 10 12];

plotColours = {...
    [0.8 0 0],...
    [0 0.6 0],...
    [0 0 0.8]};

legendLabels = {};

numTrials = length(chosenStartNumWeeks);

allNumWeeksFromTreatment = cell(numTrials,1);
allFirstTimepointNumPatients = zeros(numTrials,1);
allFirstAndSecondTimepointNumPatients = cell(numTrials,1);
    
imagingStudyIdentifier = ImagingStudyIdentifier.allPostTreatment;
    
maxDuration = database.getMaximumTimepointFromTreatment(imagingStudyIdentifier);

for i=1:numTrials
    disp(['Trial ', num2str(i)]);
    
    firstTimepointStart_days = chosenStartNumWeeks(i) * week;
    timepointBracket_days = chosenBracketSizeWeeks(i) * week;
    
    secondTimepointStart_days = firstTimepointStart_days + timepointBracket_days;
    secondTimepointIncrement_days = 1 * week;
    
    allFirstTimepointNumPatients(i) = length(database.getPatientsWithImagingStudiesWithinTimepointsFromTreatment(...
        imagingStudyIdentifier, firstTimepointStart_days, timepointBracket_days));
    legendLabels = [legendLabels, {[num2str(chosenBracketSizeWeeks(i)), ' Weeks Bracket @ ', num2str(chosenStartNumWeeks(i)), ' Weeks']}];
    
    % analyze number of patients at possible second time points
    
    numSecondTimepoints = floor( (maxDuration - secondTimepointStart_days) / secondTimepointIncrement_days) + 1;
    
    numWeeksFromTreatment = zeros(numSecondTimepoints,1);
    firstAndSecondTimepointNumPatients = zeros(numSecondTimepoints,1);
    
    counter = 1;
    
    while secondTimepointStart_days <= maxDuration        
        firstAndSecondTimepointPatients = database.getPatientsWithImagingStudiesWithinTimepointsFromTreatment(...
            imagingStudyIdentifier, [firstTimepointStart_days, secondTimepointStart_days], timepointBracket_days);
        
        firstAndSecondTimepointNumPatients(counter) = length(firstAndSecondTimepointPatients);
        
        numWeeksFromTreatment(counter) = secondTimepointStart_days ./ week;
        
        % increment
        secondTimepointStart_days = secondTimepointStart_days + secondTimepointIncrement_days;
        counter = counter + 1;
    end
    
    allNumWeeksFromTreatment{i} = numWeeksFromTreatment;
    
    allFirstAndSecondTimepointNumPatients{i} = firstAndSecondTimepointNumPatients;
    legendLabels = [legendLabels, {[num2str(chosenBracketSizeWeeks(i)), ' Weeks Bracket (1st & 2nd)']}];
end

% plot
fig = figure();

for i=1:numTrials
    x = [chosenStartNumWeeks(i), chosenStartNumWeeks(i), chosenStartNumWeeks(i)+chosenBracketSizeWeeks(i), chosenStartNumWeeks(i)+chosenBracketSizeWeeks(i)];
    y = [0, allFirstTimepointNumPatients(i), allFirstTimepointNumPatients(i), 0];
    
    plot(x, y,'--','Color',plotColours{i});
    hold('on');
    plot(allNumWeeksFromTreatment{i}, allFirstAndSecondTimepointNumPatients{i},'-','Color',plotColours{i});
end

legend(legendLabels);
grid('on');
title('Num. of Patients for 1st and 2nd Timepoints for Given Brackets');
xlabel('Num. Weeks Post-Treatment');
ylabel('Num. Patients');

saveas(fig, [writePath,'/','2nd Timepoints Detailed Analysis.png']);
savefig(fig, [writePath,'/','2nd Timepoints Detailed Analysis.fig']);

end