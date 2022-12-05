function [] = S01x_applyDatabaseCorrections_Round1()
%[] = S01x_applyDatabaseCorrections_Round1()

% ROW 2:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient18_282\2009_07_27',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient18_282\2009_07_23');

% ROW 3:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient18_282\2011_01_27',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient18_282\2009_09_28');

% ROW 4:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient1_361\2010_08_12',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient1_361\2010_12_08');

% ROW 5:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient1_361\2012_08_03',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient1_361\2012_03_08');

% ROW 6:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient20_212\2008_05_22',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient20_212\2008_05_21');

% ROW 7:
changeDicomMetadataField(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC/Patient23_300/2009_11_17/GdT1wMR',...
    'StudyDate', '20091116');

movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient23_300\2009_11_17',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient23_300\2009_11_16');

% ROW 8:
rmdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient24_109\2006_01_23\T2_TSE_axial\T1_SE_axial_Gd');

% ROW 9:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient25_344\2010_08_06',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient25_344\2010_08_04');

% ROW 10:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002004.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002005.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002006.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002007.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002008.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002009.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002010.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002011.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002012.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002013.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002014.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002015.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002016.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient27_25\2003_12_03\T1_SE_axial\MR.1.3.12.2.1107.5.2.4.7636.20031203112907000002017.dcm');

% ROW 11:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient2_60\2004_08_04\GdT1wMR\RS.1.2.246.352.71.4.550843352655.322452.20140519153335.mat');

% ROW 12:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient2_60\2004_08_04\MPRAGE_3D_coronal\RS.1.2.246.352.71.4.550843352655.322452.20140519153335.mat');

% ROW 13:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient2_60\2004_08_04\T1_Gd_axial\RS.1.2.246.352.71.4.550843352655.322452.20140519153335.mat');

% ROW 14:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient2_60\2004_08_04\T1_MPR_Gd_sagittal\RS.1.2.246.352.71.4.550843352655.322452.20140519153335.mat');

% ROW 15:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient2_60\2004_08_04\T2_TSE_axial\RS.1.2.246.352.71.4.550843352655.322452.20140519153335.mat');

% ROW 16:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC/Patient39_159/2007_07_01/MPRAGE_3D_coronal',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC/Patient39_159/2007_01_11/MPRAGE_3D_coronal');

% ROW 17:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient40_283\2010_01_27',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient40_283\2010_08_16');

% ROW 18:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002004.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002005.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002006.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002007.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002008.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002009.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002010.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002011.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002012.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002013.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002014.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002015.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002016.dcm');
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient41_4\2003_10_06\T1_SE_axial\MR.1.3.12.2.1107.5.2.2.9008.20031006154225000002017.dcm');

% ROW 19:
newFolder = 'DWI ASSET';
mkdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient49_378\2011_09_02', newFolder);

for fileNum=696:717
    movefile(...
        ['D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient49_378\2011_09_02\DWI\MR.1.2.840.113619.2.244.3596.14152012.32429.1314857226.',num2str(fileNum),'.dcm'],...
        ['D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient49_378\2011_09_02\', newFolder, '\MR.1.2.840.113619.2.244.3596.14152012.32429.1314857226.',num2str(fileNum),'.dcm']);
end

% ROW 20:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient51_237\2008_08_19',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient51_237\2008_08_18');

% ROW 21:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient54_199\2007_10_22',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient54_199\2007_10_04');

% ROW 22:
for fileNum = 556:582
    delete(['D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient59_162\2006_11_09\T1_SE_axial_Gd\MR.1.3.12.2.1107.5.2.12.21103.30000007012807142756200002', num2str(fileNum), '.dcm']);
end

% ROW 23:
newFolder = 'FLAIR TRA';
mkdir('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient63_335\2011_02_11', newFolder);

for fileNum = 3:51
    if fileNum <= 17
        endNum = 4;
    elseif fileNum >= 40
        endNum = 6;
    else
        endNum = 5;
    end
    
    movefile(...
        ['D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient63_335\2011_02_11\FLAIR_SAG\MR.1.2.840.113619.2.80.47706444.30478.129743249', num2str(endNum), '.', num2str(fileNum), '.dcm'],...
        ['D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient63_335\2011_02_11\', newFolder, '\MR.1.2.840.113619.2.80.47706444.30478.129743249', num2str(endNum), '.', num2str(fileNum), '.dcm']);
end
    
% ROW 24:
for fileNum = 34:61
    delete(['D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient66_107\2006_11_24\T2_TSE_axial\MR.1.3.12.2.1107.5.2.2.9008.200604110921410000040', num2str(fileNum), '.dcm']);
end

% ROW 25:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient6_216\2008_02_26',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient6_216\2008_02_25');

% ROW 26:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient72_27\2004_04_02',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient72_27\2004_04_01');

% ROW 27:
delete('D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient84_219\2008_06_20\MPRAGE_3D_coronal\MR.1.3.12.2.1107.5.2.30.26420.30010008031710115409300001518.dcm');

% ROW 28:
% ** NO CORRECTION REQUIRED **

% ROW 29:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient88_330\2010_04_20',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient88_330\2010_04_19');

% ROW 30:
movefile(...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient91_277\2008_05_27',...
    'D:\Users\ddevries\Data\Working Data\VUMC SRS study\VUMC Data from VUMC\Patient91_277\2008_05_19');

end

function [] = changeDicomMetadataField(seriesDir, metadataField, newValue)
    entries = dir(seriesDir);
    
    for i=3:length(entries)
        filename = entries(3).name;
        
        metadata = dicominfo([seriesDir, '/', filename]);
        metadata.(metadataField) = newValue;
        
        imagingData = dicomread([seriesDir, '/', filename]);
        
        dicomwrite(imagingData, [seriesDir, '/', filename], metadata, 'CreateMode', 'copy');
    end
end