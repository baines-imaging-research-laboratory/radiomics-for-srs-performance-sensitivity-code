function [] = S04a_findImagingTimepointsToAnalyze()
%[] = S04a_findImagingTimepointsToAnalyze()

% load database
data = load(Constants.databasePath);
database = data.database;

writePath = Constants.S04_root;

% 1) Find first time-point

imagingStudyIdentifier = ImagingStudyIdentifier.allPostTreatment;

maxDuration = database.getMaximumTimepointFromTreatment(imagingStudyIdentifier);

week = days(7);

dayBracketStart = days(0);

numWeeks = 4:2:12;
weekPlotColours = {...
    [1 0 0],...
    [0 0.7 0],...
    [0 0 1],...
    [1 0.5 0],...
    [1 0 1]};

increment = 1 * week; % 1 week

numTrials = length(numWeeks);

allWeekNumBracketStart = cell(numTrials,1);
allWeekNumPatientsInBracket = cell(numTrials,1);
allWeekMaxNumPatientsInSecondBracket =  cell(numTrials,1);
allWeekOfMaxNumPatientsInSecondBracket = cell(numTrials,1);

legendLabels = cell(2*numTrials,1);

for i=1:numTrials
    disp(['Bracket Size: ', num2str(numWeeks(i))]);
    
    timepointStart_days = 0 * week;
    timepointBracketSize_days = numWeeks(i) * week;
    
    
    dayBracketSize = days(7 * numWeeks(i)); % the plus/minus bounds for the time points (2 weeks)
    
    numIncrements = floor( (maxDuration - timepointStart_days) ./ increment) + 1;
    
    weekNumBracketStart = zeros(numIncrements,1);
    numPatientsInFirstBracket = zeros(numIncrements,1);
    maxNumPatientsInSecondBracket = zeros(numIncrements,1);
    weekOfMaxNumPatientsInSecondBracket = zeros(numIncrements,1);
    
    counter = 1;
    
    while timepointStart_days <= maxDuration
        disp([' Week: ', num2str(timepointStart_days ./ week)]);
        
        weekNumBracketStart(counter) = timepointStart_days ./ week;
        
        % num of patients within first timepoint
        firstTimepointPatients = database.getPatientsWithImagingStudiesWithinTimepointsFromTreatment(...
            imagingStudyIdentifier, timepointStart_days, timepointBracketSize_days);
        
        numPatientsInFirstBracket(counter) = length(firstTimepointPatients);
        
        % max num of patients within first and second timepoint
        [maxNumPatients, weekOfMaxNumPatients] = findSecondTimepointMaxNumberOfPatients(...
            database, imagingStudyIdentifier, timepointStart_days, timepointBracketSize_days, increment, maxDuration);
        
        maxNumPatientsInSecondBracket(counter) = maxNumPatients;
        weekOfMaxNumPatientsInSecondBracket(counter) = weekOfMaxNumPatients;
        
        counter = counter + 1;
        timepointStart_days = timepointStart_days + increment;
    end
        
    allWeekNumBracketStart{i} = weekNumBracketStart;
    allWeekNumPatientsInBracket{i} = numPatientsInFirstBracket;
    allWeekMaxNumPatientsInSecondBracket{i} = maxNumPatientsInSecondBracket;
    allWeekOfMaxNumPatientsInSecondBracket{i} = weekOfMaxNumPatientsInSecondBracket;
    
    legendLabels{(2*i) - 1} = [num2str(numWeeks(i)), ' Weeks (1st)'];
    legendLabels{(2*i)} = [num2str(numWeeks(i)), ' Weeks (Max 2nd)'];
end

% Plot 1 (num of patients for 1st and 2nd timepoints)

fig = figure();

for i=1:numTrials
    plot(allWeekNumBracketStart{i}, allWeekNumPatientsInBracket{i}, '-', 'Color', weekPlotColours{i});
    hold('on');
    plot(allWeekNumBracketStart{i}, allWeekMaxNumPatientsInSecondBracket{i}, '--', 'Color', weekPlotColours{i});
end

legend(legendLabels);
grid('on');

title('Number of Patients within 1st and 2nd Timepoint Brackets');
xlabel('Num. Weeks');
ylabel('Num. Patients');

saveas(fig, [writePath,'/','1st and 2nd Timepoints Analysis.png']);
savefig(fig, [writePath,'/','1st and 2nd Timepoints Analysis.fig']);

close(fig);

% Plot 2 (weeks timepoints for max 2nd timepoint patient num.)

fig = figure();

for i=1:numTrials
    plot(allWeekNumBracketStart{i}, allWeekOfMaxNumPatientsInSecondBracket{i}, '-', 'Color', weekPlotColours{i});
    hold('on');    
end

legend(legendLabels(2:2:end));
grid('on');

title('Num of Weeks for Max Number of Patients within 1st and 2nd Timepoint Brackets');
xlabel('Num. Weeks for 1st Timepoint');
ylabel('Num. Weeks for Max Patients within 1st & 2nd Timepoints');

saveas(fig, [writePath,'/','2nd Timepoints Max Patient Weeks Analysis.png']);
savefig(fig, [writePath,'/','2nd Timepoints Max Patient Weeks Analysis.fig']);

close(fig);

end

% ** HELPER FUNCTION **
function [maxNumPatients, weekOfMaxNumPatients] = findSecondTimepointMaxNumberOfPatients(database, imagingStudyIdentifier, firstTimepointStart_days, timepointBracketSize_days, increment, maxDuration)
    week = days(7);
    
    secondTimepointStart_days = firstTimepointStart_days + timepointBracketSize_days; %start looking at timepoint brackets completely separate from the first
    
    numIncrements = floor( (maxDuration - secondTimepointStart_days)./ increment ) + 1;
    
    numPatientsInFirstAndSecondTimepoint = zeros(numIncrements,1);
    weekOfTimepoints = zeros(numIncrements,1);
    
    counter = 1;
    
    while secondTimepointStart_days <= maxDuration
        patients = database.getPatientsWithImagingStudiesWithinTimepointsFromTreatment(...
            imagingStudyIdentifier, [firstTimepointStart_days, secondTimepointStart_days], timepointBracketSize_days);
        
        numPatientsInFirstAndSecondTimepoint(counter) = length(patients);
        weekOfTimepoints(counter) = secondTimepointStart_days ./ week;
        
        counter = counter + 1;
        secondTimepointStart_days = secondTimepointStart_days + increment;
    end
    
    maxNumPatients = -Inf;
    weekOfMaxNumPatients = 0;
    
    for i=1:numIncrements
        if numPatientsInFirstAndSecondTimepoint(i) >= maxNumPatients
            maxNumPatients = numPatientsInFirstAndSecondTimepoint(i);
            weekOfMaxNumPatients = weekOfTimepoints(i);
        end
    end
end
        



