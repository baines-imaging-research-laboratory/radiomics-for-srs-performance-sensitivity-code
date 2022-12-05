function S12b_CreateImageDatabase_CombinePatients()

chS12aRoot = Constants.chS12a_root;

oPatient = FileIOUtils.LoadMatFile(fullfile(chS12aRoot, 'Patient 1.mat'), 'oPatient');

voPatients = repmat(oPatient, 1, 100);

for dPatientIndex=1:100
    voPatients(dPatientIndex) = FileIOUtils.LoadMatFile(fullfile(chS12aRoot, ['Patient ', num2str(dPatientIndex),'.mat']), 'oPatient');
end

oStudyDatabase = StudyDatabase();
oStudyDatabase.AddPatients(voPatients);

oStudyDatabase.Save(fullfile(Constants.chS12b_root, Constants.chStudyDatabaseFilename));

end

