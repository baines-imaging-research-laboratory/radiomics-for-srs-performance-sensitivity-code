function [] = S01_constructAndValidatePatientDatabase()
%[] = S01_constructAndValidatePatientDatabase()

% ROUND 1
S01x_assemblePatientDatabase_SRS_VUMC(1, false);

S01x_applyDatabaseCorrections_Round1();

% ROUND 2
S01x_assemblePatientDatabase_SRS_VUMC(2, false);

S01x_applyDatabaseCorrections_Round2();

% ROUND 3
S01x_assemblePatientDatabase_SRS_VUMC(3, false);

% ALL ERRORS REMOVED, WRITE DATABASE
S01x_assemblePatientDatabase_SRS_VUMC(4, true);

end

