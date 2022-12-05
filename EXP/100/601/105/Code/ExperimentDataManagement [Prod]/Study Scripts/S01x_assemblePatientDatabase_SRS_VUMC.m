function [] = S01x_assemblePatientDatabase_SRS_VUMC(roundNum, writeDatabase)
%[] = S01x_assemblePatientDatabase_SRS_VUMC(roundNum, writeDatabase)

patientDataExcelPath = Constants.patientDataExcelPath;
imagingRoot = Constants.imagingDataRoot;

writePath = Constants.databasePath;
errorWritePath = Constants.S01_root;

database = PatientDatabase();

idPrefix = 'Patient';

% first gather patient primary and secondary IDs

entries = dir(imagingRoot);
entries = entries(3:end); % dump '.' and '..'

for i=1:length(entries)
    entry = entries(i);
    
    if contains(entry.name, idPrefix)
        [primaryId, secondaryId] = parseIds(entry.name, idPrefix);
        
        patient = Patient(primaryId, secondaryId);
        
        database.addPatient(patient);
    end
end

allErrors = {};

% assmble imaging data
for i=1:length(entries)
    disp(i);
    
    [primaryId, secondaryId] = parseIds(entries(i).name, idPrefix);
    
    [imagingStudies, errors] = createImagingStudiesFromDirectory([imagingRoot, '/', entries(i).name], primaryId, secondaryId);
    
    allErrors = [allErrors, errors];
    
    patient = database.findPatientByPrimaryId(primaryId);
    patient.setImagingStudies(imagingStudies);
end

% trawl patient database Excel spreadsheet
[~,~,excelData] = xlsread(patientDataExcelPath);

dims = size(excelData);
numRows = dims(1);

for i=2:numRows
    updateDatabaseWithExcelSheetRow(database, excelData(i,:));
end

% sort database to be ordered by primary ID
database.sortPatientsByPrimaryId;

% export errors
exportErrors([errorWritePath,'/Imaging Data Errors (Round ',num2str(roundNum),').xls'], allErrors);

% save
if writeDatabase
    save(writePath, 'database');
end

end

function [primaryId, secondaryId] = parseIds(folderName, idPrefix)
    k = strfind(folderName, idPrefix);
    
    prefixIndex = k(1);
    
    k = strfind(folderName, '_');
    
    splitterIndex = k(1);
    
    % want primary ID as a double, secondary ID as string (could be
    % alphanumeric)
    primaryId = str2double(folderName(prefixIndex + length(idPrefix) : splitterIndex-1));
    secondaryId = folderName(splitterIndex+1 : end);
end

function [imagingStudies, allErrors] = createImagingStudiesFromDirectory(directory, primaryId, secondaryId)
    imagingStudies = {};
    counter = 1;
    
    entries = dir(directory);
    entries = entries(3:end); % dump '.' and '..'
    
    allErrors = {};
    
    for i=1:length(entries)        
        if isValidStudyFolderName(entries(i).name)            
            path = [directory, '/', entries(i).name];
            
            folderImagingDate = datetime(entries(i).name, 'InputFormat', 'yyyy_MM_dd');
            
            [imagingSeries, imagingDates, errorData] = createImagingSeriesFromDirectory(path, primaryId, secondaryId);
            
            if isempty(errorData)
                numImagingDates = length(imagingDates);
                numFolderMatches = 0;
                
                for j=1:numImagingDates
                    if folderImagingDate == imagingDates{j}
                        numFolderMatches = numFolderMatches + 1;
                    end
                end
                
                mostMatches = 0;
                mostMatchesIndex = 0;
                
                leastMatches = Inf;
                leastMatchesIndex = 0;
                
                for j=1:numImagingDates
                    numMatches = 0;
                    
                    date = imagingDates{j};
                    
                    for k=1:numImagingDates
                        if date == imagingDates{k}
                            numMatches = numMatches + 1;
                        end
                    end
                    
                    if numMatches > mostMatches
                        mostMatchesIndex = j;
                        mostMatches = numMatches;
                    end
                    
                    if numMatches < leastMatches
                        leastMatchesIndex = j;
                        leastMatches = numMatches;
                    end
                end
                
                if numFolderMatches < numImagingDates
                    if mostMatches == numImagingDates
                        error = struct;
                        
                        error.typeString = 'Incorrect Directory Name';
                        error.seriesDirectory = imagingSeries{j}.directoryPath;
                        
                        error.folderDate = datestr(folderImagingDate,'dd/mm/yyyy');
                        error.seriesDate = datestr(imagingDates{1},'dd/mm/yyyy');
                        
                        allErrors = [allErrors, {error}];
                    else                        
                        error = struct;
                        
                        error.typeString = ['Misplaced Imaging Series (',...
                            num2str(numFolderMatches), '/', num2str(numImagingDates),...
                            '; Max: ', num2str(mostMatches), '/', num2str(numImagingDates), ')'];
                        error.seriesDirectory = imagingSeries{leastMatchesIndex}.directoryPath;
                        
                        error.folderDate = datestr(folderImagingDate,'dd/mm/yyyy');
                        error.seriesDate = datestr(imagingDates{leastMatchesIndex},'dd/mm/yyyy');
                        
                        allErrors = [allErrors, {error}];
                    end
                end
            else
                for j=1:length(errorData)
                    errorData{j}.folderDate = datestr(folderImagingDate,'dd/mm/yyyy');
                    errorData{j}.seriesDate = 'N/A';
                    
                    allErrors = [allErrors, errorData(j)];
                end
            end
            
            imagingDate = folderImagingDate;
            
            imagingStudies{counter} = ImagingStudy(counter, imagingDate, imagingSeries, path);
            counter = counter + 1;
        end
    end
end

function [imagingSeries, imagingDates, errorData] = createImagingSeriesFromDirectory(path, primaryId, secondaryId)
    % initialize outputs/counters
    imagingSeries = {};
    imagingDates = {};
    counter = 1;
    
    errorData = {};

    % get all files/folders in the imaging study directory
    entries = dir(path);
    entries = entries(3:end); % dump '.' and '..'
    
    % get RT Struct (contouring) filename
    rtStructFilename = findRtStructName(entries);
    
    if isempty(rtStructFilename)
        matchSeriesUid = [];
    else
        rtStructMetadata = dicominfo([path, '/', rtStructFilename]);
        matchSeriesUid = rtStructMetadata.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID;
    end
    
    numSeriesMatches = 0; % counts number of matches between imaging series and RT struct file
    
    % loop through entries (folders containing individual imaging series)
    for i=1:length(entries)
        % don't want to work with any files, only folders (imaging series)
        if entries(i).isdir 
            % get imaging series path
            seriesFolderName = entries(i).name;
            seriesDirectory = [path, '/', seriesFolderName];
            
            imagingSeriesEntries = dir(seriesDirectory);
            firstFilename = imagingSeriesEntries(3).name; % skip '.' and '..'
            
            % check if MRI DICOM folder
            if strcmp(firstFilename(end-3:end),'.dcm') && strcmp(firstFilename(1:2),'MR')
                if ~validDicomSeriesDirectory(seriesDirectory)
                    error = struct;
                    
                    error.typeString = 'Invalid Imaging Series Directory';
                    error.seriesDirectory = seriesDirectory;
                                        
                    errorData = [errorData, {error}];
                end
                
                % get imaging series DICOM metadata
                imagingMetadata = dicominfo([seriesDirectory, '/', firstFilename]);
                
                % check that primaryId and secondaryId recorded in DICOM
                % metadata checks out
                if validateImagingSeriesMetadata(imagingMetadata, primaryId, secondaryId)
                    % get series imaging geometry (orientation, resolution,
                    % etc.)
                    [volumeDimensions, imagePosition, imageOrientation, pixelSpacing, centreOfSliceSeparation] =...
                        getDicomSeriesGeometry(seriesDirectory);
                        
                    % find contours if this series was contoured on in the RT
                    % struct file
                    if strcmp(imagingMetadata.SeriesInstanceUID, matchSeriesUid)
                        numSeriesMatches = numSeriesMatches + 1;
                        
                        if numSeriesMatches > 1 % two series both linked with a contour
                            error(['Multiple imaging series linked with RT Struct file: ', seriesDirectory]);
                        else
                            contours = Contour.createContoursFromRtStructMetadata([path, '/', rtStructFilename]);
                        end
                    else
                        contours = {};
                    end
                    
                    % find contast information, if the field exists
                    if isfield(imagingMetadata, 'ContrastBolusAgent')
                        seriesContrastAgent = imagingMetadata.ContrastBolusAgent;
                    else
                        seriesContrastAgent = '';
                    end
                    
                    % create Imaging Series object
                    imagingSeries{counter} = ImagingSeries(...
                        counter,...
                        seriesFolderName, imagingMetadata.SeriesDescription, seriesContrastAgent,...
                        imageOrientation, pixelSpacing, volumeDimensions(1:2),...
                        imagingMetadata.SliceThickness, centreOfSliceSeparation, volumeDimensions(3),...
                        contours, seriesDirectory);
                    
                    imagingDates{counter} = datetime(imagingMetadata.StudyDate, 'InputFormat', 'yyyyMMdd');
                    
                    counter = counter + 1;
                end
            end
        end
    end    
end

function bool = isValidStudyFolderName(name)
    bool = (length(name) == 10 && name(5) == '_' && name(8) == '_');
end

function bool = validateImagingSeriesMetadata(imagingMetadata, primaryId, secondaryId)
    bool = strcmp(imagingMetadata.PatientID, secondaryId) && ...
        strcmp(imagingMetadata.PatientName.FamilyName, ['Patient',num2str(primaryId)]);
end

function filename = findRtStructName(entries)
    filename = '';

    for i=1:length(entries)
        name = entries(i).name;
        
        if strcmp(name(1:2),'RS')
            filename = name;
            break;
        end
    end
end

function updateDatabaseWithExcelSheetRow(database, spreadsheetRow)
    idEntry = spreadsheetRow{1};
    primaryId = str2double(idEntry(8:end));
    
    patient = database.findPatientByPrimaryId(primaryId);

    if isempty(patient)
        error(['Cannot find patient primary ID in database: ', num2str(primaryId)]);
    else
        patient.updateFromDatabaseEntries_SRS_VUMC(spreadsheetRow);        
    end
    
end

function bool = validDicomSeriesDirectory(seriesDirectory)
    entries = dir(seriesDirectory);
    
    name = entries(3).name;
    
    indices = strfind(name, '.');    
    
    matchString = name(1:indices(end-2));
        
    bool = true;
    
    for i=4:length(entries)
        name = entries(i).name;
        
        indices = strfind(name, '.');
        
        if isempty(indices) || ~strcmp(matchString, name(1:indices(end-2)))
            bool = false;
            break;
        end
    end
end

function [] = exportErrors(writePath, errors)
    headers = {'Error Type', 'Folder Date', 'Series Date', 'Series Path'};

    numErrors = length(errors);
    
    sheet = cell(numErrors+1, length(headers));
    
    sheet(1,:) = headers;
    
    for i=1:numErrors
        sheet{i+1,1} = errors{i}.typeString;
        sheet{i+1,2} = errors{i}.folderDate;
        sheet{i+1,3} = errors{i}.seriesDate;
        sheet{i+1,4} = errors{i}.seriesDirectory;
    end
    
    xlswrite(writePath, sheet);
end


