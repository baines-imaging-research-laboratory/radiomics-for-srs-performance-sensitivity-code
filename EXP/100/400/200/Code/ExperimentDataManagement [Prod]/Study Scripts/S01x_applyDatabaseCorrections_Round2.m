function [] = S01x_applyDatabaseCorrections_Round2()
%[] = S01x_applyDatabaseCorrections_Round2()

% ROW 1:

for fileNum=514:685
    delete(['D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\MPRAGE_3D_sagittal\MR.1.2.840.113619.2.207.6945.201092.9649.1222325722.', num2str(fileNum), '.dcm']);
end

rmdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\MPRAGE_3D_sagittal');

% ROW 2:
% ** NO CORRECTION REQUIRED **


end

