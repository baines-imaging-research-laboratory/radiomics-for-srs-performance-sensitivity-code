function [] = createCodeRepositoryVersionLog(c1chCodeLibraryPaths, chScriptRootPath)
%[] = createCodeRepositoryVersionLog(c1chCodeLibraryPaths, chScriptRootPath)

oFile = fopen([chScriptRootPath, '/', Constants.chCodeRepositoryVersionLogFilename],'w');

root = pwd;

for dLibraryIndex=1:length(c1chCodeLibraryPaths)
    text = fileread(FileUtilities.makePath(root, c1chCodeLibraryPaths{dLibraryIndex}, '.git\refs\heads\master'));
    
    fprintf(oFile, [c1chCodeLibraryPaths{dLibraryIndex}, ': ', text(1:end-1),'\r\n']);
end

fclose(oFile);

end

