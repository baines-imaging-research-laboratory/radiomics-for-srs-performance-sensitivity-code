function [] = S06a_SetContourCoordsToContours()

data = load(Constants.databasePath);
database = data.database;

% load polygon coords
for i=1:length(database.patients)
    disp(i);
    patient = database.patients{i};
    
    for j=1:length(patient.imagingStudies)
        study = patient.imagingStudies{j};
        
        for k=1:length(study.imagingSeries)
            series = study.imagingSeries{k};
            
            for l=1:length(series.contours)
                series.contours{l}.createPolygons();
            end
        end
    end
end

% save it back
save(Constants.databasePath, 'database');

end

