function [] = scourImagingDirectoriesForDicomFieldValue(rootPath, field, value, isNumeric)
%[] = scourImagingDirectoriesForDicomFieldValue(rootPath, field, value, isNumeric)

entries = dir(rootPath);
entries = entries(3:end);

% assmble imaging data
for i=1:length(entries)
    disp(i);
    
    scourPatientDirectories([rootPath, '/', entries(i).name], field, value, isNumeric);
end

end

function [] = scourPatientDirectories(directory, field, value, isNumeric)
        
    entries = dir(directory);
    entries = entries(3:end); % dump '.' and '..'
        
    for i=1:length(entries)        
        if isValidStudyFolderName(entries(i).name)            
            path = [directory, '/', entries(i).name];
            
            scourImagingStudyDirectories(path, field, value, isNumeric);            
        end
    end
end

function [] = scourImagingStudyDirectories(path, field, value, isNumeric)
    % get all files/folders in the imaging study directory
    entries = dir(path);
    entries = entries(3:end); % dump '.' and '..'
    
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
                metadata = dicominfo([seriesDirectory, '\', firstFilename]);
                
                found = false;
                
                if isNumeric
                    if all(metadata.(field) == value)
                        found = true;
                    end
                else
                    if strcmp(metadata.(field), value)
                        found = true;
                    end
                end
                
                if found
                    disp(['Match at: ', seriesDirectory]);
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


