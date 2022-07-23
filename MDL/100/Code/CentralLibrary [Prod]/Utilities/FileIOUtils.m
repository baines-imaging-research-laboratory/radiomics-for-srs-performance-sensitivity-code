classdef (Abstract) FileIOUtils
    %FileIOUtils
    %
    % This class provides the user with input/output utilities for files.
    %
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Access = private, Constant = true)
        c1chClassUpdateClassNameWhiteList = {'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'char', 'string', 'logical', 'function_handle'}
        c1chClassUpdatePrefixWhiteList = {'matlab.'}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function varargout = LoadMatFile(chPath, varargin)
            % varargout = LoadMatFile(chPath, varargin)
            
            % loads the specified variables from a .mat file
            % as many variable names can be specified and will be returned
            % as multiple variables. The number of returned parameters
            % should be equal to the number of specified variables.
            
            % Syntax:
            % [var1, var2, var3] = LoadMatFile('C:\Folder\File.mat', 'var1Name', 'var2Name', 'var3Name')            
            
            % Written by: David DeVries
            % Created: Mar 4, 2019
            % Modified: -
                            
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            if ~isempty(varargin)
                % find flag if given
                chFirstVar = varargin{1};
                
                if ischar(chFirstVar) && (chFirstVar(1) == '-')
                    bFlagFound = true;
                    chFlag = varargin{1};
                    
                    
                    c1chVarNames = varargin(2:end);
                else
                    bFlagFound = false;
                    chFlag = [];
                    
                    c1chVarNames = varargin;
                end
                
                % check and force that variable names are given
                % no loading of all variables
                dNumVariablesToLoad = length(c1chVarNames);
            else
                dNumVariablesToLoad = 0;
            end
            
            if dNumVariablesToLoad < 1
                error(...
                    'FileIOUtils:LoadMatFile:InvalidVariableNames',...
                    'At least one variable name to load must be specified');
            end
            
            % load data with/without optional flag
            if bFlagFound
                stLoadedData = load(chPath, chFlag, c1chVarNames{:});
            else
                stLoadedData = load(chPath, c1chVarNames{:});
            end
            
            % convert from struct to cell array for varargout
            varargout = cell(dNumVariablesToLoad,1);
            
            for dVarIndex=1:dNumVariablesToLoad
                if isfield(stLoadedData, c1chVarNames{dVarIndex}) % check if the field exists in the struct from the load call. If the variable wasn't in the file, Matlab will just shoot off a warning instead of error
                    varargout{dVarIndex} = stLoadedData.(c1chVarNames{dVarIndex});
                else
                    error(...
                        'FileIOUtils:LoadMatFile:NonExistentVariable',...
                        ['The requested variable ', c1chVarNames{dVarIndex}, ' was not found in the file when loaded.']);
                end
            end
        end
        
        function SaveMatFile(chPath, varargin)
            % SaveMatFile(chPath, varargin)
            
            % saves the given variable values into a .mat file under the
            % specified variable name
            % The variable names and value should be given as name value
            % pairs, followed by any of the same flags used for the builtin
            % "save" function.
            
            % Syntax:
            % SaveMatFile('C:\Folder\File.mat', 'var1Name', var1, 'var2Name', var2, 'var3Name', var 3)
            % SaveMatFile('C:\Folder\File.mat', 'var1Name', var1, 'var2Name', var2, 'var3Name', var 3, flags)
            
            % Written by: David DeVries
            % Created: Mar 4, 2019
            % Modified: -
            
            % find flags
            dNumFlags = 0;
            bFlagFound = false;
            
            for dVarIndex=1:length(varargin)
                oVar = varargin{dVarIndex};
                
                if ischar(oVar) && (oVar(1) == '-')
                    bFlagFound = true;
                    dNumFlags = dNumFlags + 1;
                else
                    if bFlagFound % can't have variables, flags, then variables
                        error(...
                            'FileIOUtils:SaveMatFile:InvalidParameterOrder',...
                            'All flags must be at the end of the parameter list');
                    end
                end
            end
            
            % separate flags and variable names and values
            c1oFlags = varargin(end-dNumFlags+1 : end);
            c1oVarNames = varargin(1 : 2 : end-dNumFlags-1);
            c1oVarValues = varargin(2 : 2 : end-dNumFlags);
            
            % check that name value pairs match up
            dNumVarNames = length(c1oVarNames);
            dNumVarValues = length(c1oVarValues);
            
            if dNumVarNames ~= dNumVarValues || length(varargin) ~= (length(c1oFlags) + 2*dNumVarNames)
                error(...
                    'FileIOUtils:SaveMatFile:VarNameValueMismatch',...
                    'The number of variable names must match the number of variable values');
            end
            
            % rename passed variables to their passed names
            for dNameValueIndex=1:length(c1oVarNames)
                chVarName = c1oVarNames{dNameValueIndex};
                
                if isstring(chVarName) && isrow(chVarName)
                    chVarName = char(chVarName);
                end
                
                if ischar(chVarName)
                    % rename variable
                    eval([chVarName, ' = c1oVarValues{dNameValueIndex};']);
                else
                    error(...
                        'FileIOUtils:SaveMatFile:InvalidVarName',...
                        'Variable names must be specified as a character array.');
                end
            end
            
            % perform save
            save(chPath, c1oVarNames{:}, c1oFlags{:});
        end
        
        function SaveFigure(hFig, chFilePath, vsFileTypes)
            % SaveFigure(hFig, chFilePath, vsFileTypes)
            
            % DESCRIPTION:
            %  Function to save a figure into a specified file type(s)
            % 
            % INPUT ARGUMENTS:
            %  hFig: handle to the figure being saved
            %  chFilePath: a character array holding the full path in which
            %  to save the figure
            %  vsFileTypes: a vector of strings holding the file types that
            %  the figure is to be saved in
            %
            % OUTPUT ARGUMENTS:
            %  None

            bOriginalInvertHardcopy = hFig.InvertHardcopy;
            hFig.InvertHardcopy = false;
            
            chFilePath = FileIOUtils.SeparateFilePathExtension(chFilePath);
           
            for dFileTypeIndex=1:length(vsFileTypes)
                chFileType = char(vsFileTypes(dFileTypeIndex));
                
                if strcmp(chFileType, '.fig')
                    savefig(hFig, [chFilePath, chFileType]);
                else
                    saveas(hFig, [chFilePath, chFileType]);
                end                
            end
            
            hFig.InvertHardcopy = bOriginalInvertHardcopy;
        end
    
    
        function [chFilePath, chFileExtension] = SeparateFilePathExtension(chFilePath)
            % [chFilePath, chFileExtension] = SeparateFilePathExtension(chFilePath)
            
            % DESCRIPTION:
            %  Function to separate the extension of the file from the full
            %  file path.
            % 
            % INPUT ARGUMENTS:
            %  chFilePath: a character array holding the full path to the
            %  file
            %
            % OUTPUT ARGUMENTS:
            %  chFilePath: character array holding the full path to the
            %  file without the extension
            %  chFileExtension: character array holding the extension of
            %  the file

            arguments
                chFilePath (1,:) char
            end
            
            vdDotIndices = strfind(chFilePath, '.');
            vdSlashIndices = strfind(chFilePath, filesep);
            
            if isempty(vdDotIndices)
                chFileExtension = '';
            elseif ~isempty(vdSlashIndices) && vdDotIndices(end) < vdSlashIndices(end) % no file extension
                chFileExtension = '';
            else
                chFileExtension = chFilePath(vdDotIndices(end) : end);
                chFilePath = chFilePath(1 : vdDotIndices(end)-1);
            end
        end
        
        function [chPath, chFilename] = SeparateFilePathAndFilename(chFilePath)
            % [chPath, chFilename] = SeparateFilePathAndFilename(chFilePath)
            
            % DESCRIPTION:
            %  Function to separate the file name from the full file path.
            % 
            % INPUT ARGUMENTS:
            %  chFilePath: a character array holding the full path to the
            %  file including the filename.
            %
            % OUTPUT ARGUMENTS:
            %  chPath: character array holding the full path to the
            %  file without the filename
            %  chFilename: character array holding the filename

            arguments
                chFilePath (1,:) char
            end
                        
            vdIndices = strfind(chFilePath, filesep);
            
            if isempty(vdIndices)
                chPath = '';
                chFilename = chFilePath;
            else
                chPath = chFilePath(1:(vdIndices(end)-1));
                chFilename = chFilePath((vdIndices(end)+1):end);
            end
        end
        
        function UpdateClassesInMatFiles(chDir, chUpdateMarker, chRegExp)
            %UpdateClassesInMatFiles(chDir, chUpdateMarker, chRegExp)
            %
            % SYNTAX:
            %  UpdateClassesInMatFiles(chDir, chUpdateMarker, chRegExp)
            %
            % DESCRIPTION:
            %   A function to update classes within .mat files. 
            %   The structure of a class may have been modified (e.g.,
            %   a property was added) and .mat files containing this
            %   class need to be updated
            %
            % INPUT ARGUMENTS:
            %   chDir:  a character array holding the root name of the
            %           directory tree to be searched.
            %   chUpdateMarker: a character array holding a unique string
            %                   to be inserted into the name of the file
            %                   being saved
            %   chRegExp: a character array holding the regular expression 
            %             for the files to be searched.
            %
            % OUTPUT ARGUMENTS:
            %  None

            arguments
                chDir (1,:) char
                chUpdateMarker (1,:) char
                chRegExp (1,:) char = '(/*?)\.(mat)$'
            end
            
            % file .mat files matching in the directory given
            c1chMatchingFilePaths = FileIOUtils.FindFilesInDirectory(chDir, chRegExp);
            
            % loop through files:
            for dFileIndex=1:length(c1chMatchingFilePaths)
                % get details of variables stored in file
                vstVarDetails = whos(matfile(c1chMatchingFilePaths{dFileIndex}));
                
                % check if any need updating (if the file is all primitive
                % types or are a matlab class, no need to update file)
                bUpdateRequired = false;
                
                dNumVars = length(vstVarDetails);
                
                for dVarIndex=1:dNumVars
                    chVarClassName = vstVarDetails(dVarIndex).class;
                    
                    if ~FileIOUtils.NameOnClassUpdateClassNameWhiteList(chVarClassName) && ~FileIOUtils.NameOnClassUpdatePrefixWhiteList(chVarClassName)
                        bUpdateRequired = true;
                        break;
                    end
                end
                
                % if update is required, load all the variables (updates
                % will occur during 'loadobj' calls), and then save back to
                % the same file
                if bUpdateRequired
                    stLoadedData = load(c1chMatchingFilePaths{dFileIndex});
                    
                    varargin = cell(1,2*dNumVars);
                    
                    for dVarIndex=1:dNumVars
                        chVarName = vstVarDetails(dVarIndex).name;
                        varargin{(2*dVarIndex) - 1} = chVarName;
                        varargin{(2*dVarIndex)} = stLoadedData.(chVarName);
                    end
                    
                    [chFilePath, chFileExtension] = FileIOUtils.SeparateFilePathExtension(c1chMatchingFilePaths{dFileIndex});
                    
                    FileIOUtils.SaveMatFile([chFilePath, chUpdateMarker, chFileExtension], varargin{:});
                end
            end
        end        
        
        function c1sMatchedFiles = FindFilesInDirectory(chDirName, chRegExp)
            %c1sMatchedFiles = FindFilesInDirectory(chDirName, chRegExp)
            %
            % SYNTAX:
            %  c1sMatchedFiles = FindFilesInDirectory(chDirName, chRegExp)
            %
            % DESCRIPTION:
            %   A function to search a directory tree for a given regular
            %   expression. This search is case insensitive.
            %
            % INPUT ARGUMENTS:
            %   chDirName:  a character array holding the root name of the
            %               directory tree to be searched.
            %   chRegExp:   a character array holding the regular expression for
            %               the files to be searched.
            %
            % OUTPUT ARGUMENTS:
            %   c1sMatchedFiles:    a cell array holding the filenames with full
            %                       the full path that match the given regular
            %                       expression.
            %
            % EXAMPLES FOR REGULAR EXPRESSIONS:
            %           1) look for all files with '.mat' extension
            %               '(/*?)\.(mat)$' 
            %           2) look for all files that begin with 'Classifier'
            %               '^Classifier\w+.*$' 
            %           3) look for all files that begin with 'Classifier' and end
            %              with the '.mat' extension
            %               '^Classifier\w+\.(mat)$'
            %           4) look for any files with the string 'matrix'
            %               'matrix'
            %           5) look for any files with the string 'matrix' and
            %              the file extensions '.m' or '.mat'
            %               'matrix.*\.(?:m|mat)$'
            %           6) look for any files with string 'matrix' and
            %               ignore extensions '.m' or '.mat'
            %                'matrix.*\.(?!(m|mat)$)'
            %

            % Primary Author: Carol Johnson
            % Created: Sep 26, 2019

            % initialize
            c1sMatchedFiles = {};

            % search the directory tree recursively for the given regular expression
            c1sMatchedFiles = FileIOUtils.SearchFilesForRegex(c1sMatchedFiles, chDirName, chRegExp);

        end
        
        function chAbsPath = GetAbsolutePath(chPath)
            % chAbsPath = GetAbsolutePath(chPath)
            
            % DESCRIPTION:
            %  Function that returns the absolute path for a given file.
            %  The file may or may not exist.
            % 
            % INPUT ARGUMENTS:
            %  chPath: a character array holding the file name
            %
            % OUTPUT ARGUMENTS:
            %  chAbsPath: character array holding the full path to the
            %  input file

            arguments
                chPath (1,:) char
            end
            
            chAbsPath = which(chPath);
            
            if isempty(chAbsPath)
                if length(chPath) >= 2
                    if ispc && chPath(2) == ':' % already is abs path
                        chAbsPath = chPath;
                    elseif isunix && chPath(1) == '/' %already is abs path
                        chAbsPath = chPath;
                    else
                        chAbsPath = fullfile(pwd, chPath);
                    end
                else
                    chAbsPath = chPath;
                end
            end
        end
        
        function chAbsPath = GetAbsolutePathForExistingFiles(chPath)
            % chAbsPath = GetAbsolutePathForExistingFiles(chPath)
            
            % DESCRIPTION:
            %  Function that returns the absolute path to a given file.
            %  If the file does not exist, an empty character array is
            %  returned.
            % 
            % INPUT ARGUMENTS:
            %  chPath: a character array holding the file name
            %
            % OUTPUT ARGUMENTS:
            %  chAbsPath: character array holding the full path to the
            %  input file. It is empty if the file does not exist.

            % Returns empty if file doesn't exist
            arguments
                chPath (1,:) char
            end
            
            % An absolute path is given
            if ispc
                if chPath(2) == ':'
                    if exist(chPath,'file') == 2
                        chAbsPath = chPath;
                        return
                    else
                        chAbsPath = '';
                        return
                    end
                end
            else
                if chPath(1) == '/'
                    if exist(chPath,'file') == 2
                        chAbsPath = chPath;
                        return
                    else
                        chAbsPath = '';
                        return
                    end
                end
            end
            
            chAbsPath = which(chPath);
            
            % A relative path or a filename is given
            if isempty(chAbsPath)
                chPath = fullfile(pwd, chPath);
                if exist(chPath,'file') == 2
                    chAbsPath = chPath;
                    return
                else
                    chAbsPath = '';
                    return
                end                
            end                     
            
        end
        
        function chFileName = GetRandomFileName(dNumChars)
            % chFileName = GetRandomFileName(dNumChars)
            
            % DESCRIPTION:
            %  Function that returns a filename with the number of
            %  characters requested. The characters are a mix of randomly 
            %  selected numbers and letters (upper and lower case)
            % 
            % INPUT ARGUMENTS:
            %  dNumChars: a double type value for the number of characters
            %  to be returned in the filename
            %
            % OUTPUT ARGUMENTS:
            %  chFileName: character array for a filename consisting of
            %  random digis and letter (upper and lower case)

            vdAvailableChars = [char(48:57), char(65:90), char(97:122)]; % all digits and letters (upper and lower case)
            
            dNumAvailableChars = length(vdAvailableChars);
            
            chFileName = vdAvailableChars(randi(dNumAvailableChars,1,dNumChars));
        end
        
        function DeleteFileIfItExists(chFilePath)
            % DeleteFileIfItExists(chFilePath)
            
            % DESCRIPTION:
            %  Function that deletes the file input if it exists.
            % 
            % INPUT ARGUMENTS:
            %  chFilePath: a character array holding the path to the file
            %  to be deleted.
            %
            % OUTPUT ARGUMENTS:
            %  None

            arguments
                chFilePath (1,:) char
            end
            
            if isfile(chFilePath)
                delete(chFilePath);
            end
        end
        
        function MkdirIfItDoesNotExist(chPath, chFolderName)
            % MkdirIfItDoesNotExist(chPath, chFolderName)
            
            % DESCRIPTION:
            %  Function that will create a directory with the given folder
            %  name if it doesn't already exist.
            % 
            % INPUT ARGUMENTS:
            %  chPath: a character array holding the path to where the
            %  folder is to be created
            %  chFolderName: name of folder to be created
            %
            % OUTPUT ARGUMENTS:
            %  None

            arguments
                chPath (1,:) char
                chFolderName (1,:) char
            end
            
            if ~isfolder(fullfile(chPath, chFolderName))
                mkdir(chPath, chFolderName);
            end
        end
        
        function bBool = IsDirectoryEmpty(chPath)
            % bBool = IsDirectoryEmpty(chPath)
            
            % DESCRIPTION:
            %  Function that will return True or False if the directory
            %  input is empty or not (respectively). (The 2 system 
            %  directories '.' and '..' are ignored.)

            % 
            % INPUT ARGUMENTS:
            %  chPath: a character array holding the path to folder to be
            %  tested whether it is empty or not
            %
            % OUTPUT ARGUMENTS:
            %  bBool: boolean result of whether the directory in question
            %  is empty (T) or not (F). 
            
            arguments
                chPath (1,:) char
            end
            
            bBool = (length(dir(chPath)) == 2);
        end
        
        function [vsNames, vbIsDir] = DirGetNamesAndIsDir(chPath)
            % [vsNames, vbIsDir] = DirGetNamesAndIsDir(chPath)
            
            % DESCRIPTION:
            %  Function that will return a vector of names for each item in
            %  the directory as well as a matching vector of flags
            %  indicating which item is a directory.

            % 
            % INPUT ARGUMENTS:
            %  chPath: a character array holding the path to folder to be
            %  inspected
            %
            % OUTPUT ARGUMENTS:
            %  vsNames: a vector of strings holding the names of the
            %  directory entities.
            %  vbIsDir: a vector of boolean flags reflecting which items in
            %  the vector of names are directories

            arguments
                chPath (1,:) char
            end
            
            voEntries = dir(chPath);
            dNumEntries = length(voEntries);
            
            vsNames = strings(dNumEntries,1);
            vbIsDir = false(dNumEntries,1);
            
            for dEntryIndex=1:dNumEntries
                vsNames(dEntryIndex) = string(voEntries(dEntryIndex).name);
                vbIsDir(dEntryIndex) = voEntries(dEntryIndex).isdir;
            end
            
            vbRemove = ( vsNames == "." | vsNames == ".." );
            
            vsNames = vsNames(~vbRemove);
            vbIsDir = vbIsDir(~vbRemove);
        end
    end
        
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function bBool = NameOnClassUpdateClassNameWhiteList(chVarClassName)
            bBool = false;
            
            for dWhiteListIndex=1:length(FileIOUtils.c1chClassUpdateClassNameWhiteList)
                if strcmp(FileIOUtils.c1chClassUpdateClassNameWhiteList{dWhiteListIndex}, chVarClassName)
                    bBool = true;
                    break;
                end
            end
        end
        
        function bBool = NameOnClassUpdatePrefixWhiteList(chVarClassName)
            bBool = false;
            dNameLength = length(chVarClassName);
            
            for dWhiteListIndex=1:length(FileIOUtils.c1chClassUpdatePrefixWhiteList)
                if ...
                        length(FileIOUtils.c1chClassUpdatePrefixWhiteList{dWhiteListIndex}) == dNameLength &&...
                        strcmp(FileIOUtils.c1chClassUpdatePrefixWhiteList{dWhiteListIndex}, chVarClassName)
                    bBool = true;
                    break;
                end
            end
        end
        
        function c1sMatchedFiles = SearchFilesForRegex(c1sMatchedFiles, chDirName, chRegExp)
            %c1sMatchedFiles = SearchFilesForRegex(c1sMatchedFiles, chDirName, chRegExp)
            %
            % SYNTAX:
            %  c1sMatchedFiles = SearchFilesForRegex(c1sMatchedFiles, chDirName, chRegExp)
            %
            % DESCRIPTION:
            %   A recursive function to search a directory tree for a given regular expression
            %   and collect the matched filenames.  This search is case insensitive.
            %
            % INPUT ARGUMENTS:
            %   c1sMatchedFiles: a cell array holding the filenames with full
            %                    the full path that match the given regular
            %                    expression. In each recursive pass, the
            %                    matching files are appended to this array.
            %   chDirName:  a character array holding the root name of the
            %               directory tree to be searched.
            %   chRegExp:   a character array holding the regular expression for
            %               the files to searched.
            %
            % OUTPUT ARGUMENTS:
            %   c1sMatchedFiles:    a cell array holding the filenames with full
            %                       the full path that match the given regular
            %                       expression for the root folder and all
            %                       subfolders.
            %                       

            % Primary Author: Carol Johnson
            % Created: Sep 26, 2019

            stDirInfo = dir(chDirName);
            c1sFileNames = {stDirInfo([stDirInfo.isdir] == 0).name};    % files only, ignore dirs

            % concatenate any files that match the regular expression to
            % the container holding all matched files
            c1sMatchedFiles = vertcat(c1sMatchedFiles, ...
                strcat(chDirName, filesep, c1sFileNames(~cellfun(@isempty, regexpi(c1sFileNames, chRegExp)))'));

            % isolate subdirectories folders and their names
            c1sSubDirFolders = {stDirInfo([stDirInfo.isdir] == 1).folder}';
            c1sSubDirNames   = {stDirInfo([stDirInfo.isdir] == 1).name}';
            c1sSubDirPathnames = {};

            % combine folder and name into a full path name
            dCtr = 1;
            for dIndex1 = 1:size(c1sSubDirFolders,1)
                if ~any(strcmp({'.','..','.git'},c1sSubDirNames{dIndex1,1})) %ignore these dirs
                   c1sSubDirPathnames{dCtr,1} = {strcat(c1sSubDirFolders{dIndex1,1}, filesep, c1sSubDirNames{dIndex1,1})};
                   dCtr = dCtr + 1;
               end
            end

            % recurse through each subdirectory
            for dIndex2 = 1 : size(c1sSubDirPathnames,1)
               c1sMatchedFiles = FileIOUtils.SearchFilesForRegex(c1sMatchedFiles, char(c1sSubDirPathnames{dIndex2,1}), chRegExp);
            end
        end
        
    end
end

