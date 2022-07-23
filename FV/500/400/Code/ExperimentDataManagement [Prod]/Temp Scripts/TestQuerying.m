function TestQuerying()


function dNumPreTreatmentStudies = GetNumberTreatmentStudies(oDatabasePatient)
    voStudies = oDatabasePatient.GetAllPreTreatmentImagingStudies;
    
    dNumPreTreatmentStudies = length(voStudies);
end


oDatabase = StudyDatabase.Load('Test Database\Test Study Database.mat');

oPatientQuery = ClassQuery(...
    ClassSelector('StudyDatabase',@GetPatients),...
    {@GetPrimaryId, @GetNumberTreatmentStudies},...
    {'ID', '# Pre-Treatment Studies'});

oQuery = DatabaseQuery(oPatientQuery, true);

[c2xResults, c2chHeaders] = oDatabase.ExecuteQuery(oQuery);

oDatabase.ExportQueryToXls('..\Temp Dump\Test.xls', 'Test123', oQuery);

end