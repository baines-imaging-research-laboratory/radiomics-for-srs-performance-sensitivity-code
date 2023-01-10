classdef (Abstract) DevUtils
    %DevUtils
    %
    % Provides useful functions used during development
    
    % Primary Author: David DeVries
    % Created: Nov 14, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Static = true)
        
        function UpdateFeatureExtractionParameterFile(chFilePath)
            %UpdateFeatureExtractionParameterFile(chFilePath)
            %
            % SYNTAX:
            %  UpdateFeatureExtractionParameterFile(chFilePath)
            %
            % DESCRIPTION:
            %   ???
            %
            % INPUT ARGUMENTS:
            %  chFilePath: File path to the Feature Extraction parameters
            %  file.
            %
            % OUTPUT ARGUMENTS:
            %  None
            
            
            chMasterFilePath = fullfile('DefaultInputs','FeatureExtraction','FeatureExtractionParameters.xlsx');
            
            % CAUTION: The range for column C may change over time
            c1xData = readcell(chFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet','Sheet1',...
                'Range','C1:C74');
            
            delete(chFilePath);
            copyfile(chMasterFilePath, chFilePath);
            
            for dIndex=1:length(c1xData)
                if isa(c1xData{dIndex}, 'missing')
                    c1xData{dIndex} = '';
                end
            end
            
            writecell(c1xData, chFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', 'Parameters',...
                'Range', 'C3');
            
            
        end
        
        function [dNumLinesOfCode, dNumLinesOfDocs] = CountLinesOfCode(chDirPath)
            %[dNumLinesOfCode, dNumLinesOfDocs] = CountLinesOfCode(chDirPath)
            %
            % SYNTAX:
            %  [dNumLinesOfCode, dNumLinesOfDocs] = CountLinesOfCode(chDirPath)
            %
            % DESCRIPTION:
            %   Given a path to a directory, return the number of lines of
            %   code and the number of lines of documentation in that
            %   directory and all subdirectories.
            %
            % INPUT ARGUMENTS:
            %  chDirPath: Path to the folder where counting of lines of
            %  documentation and code are to begin.
            %
            % OUTPUT ARGUMENTS:
            %  dNumLinesOfCode: double value holding number of lines of
            %  code
            %  dNumLinesOfDocs: double value holding number of lines of
            %  documentation

            arguments
                chDirPath (1,:) char = pwd
            end
            
            voDirEntries = dir(chDirPath);
            
            dNumLinesOfCode = 0;
            dNumLinesOfDocs = 0;
            
            for dEntryIndex=3:length(voDirEntries)
                oEntry = voDirEntries(dEntryIndex);
                
                if oEntry.isdir % recurse
                    [dEntryNumLinesOfCode, dEntryNumLinesOfDocs] = DevUtils.CountLinesOfCode(fullfile(chDirPath, oEntry.name));
                else
                    chFileName = oEntry.name;
                    
                    if length(chFileName) >= 3 && strcmp(chFileName(end-1:end), '.m') % only count .m file lines
                        [dEntryNumLinesOfCode, dEntryNumLinesOfDocs] = DevUtils.CountLinesOfCodeInMatlabFile(fullfile(chDirPath, chFileName));
                    elseif length(chFileName) >= 3 && strcmp(chFileName(end-2:end), '.py') % only count .m file lines
                        [dEntryNumLinesOfCode, dEntryNumLinesOfDocs] = DevUtils.CountLinesOfCodeInPythonFile(fullfile(chDirPath, chFileName));
                    else
                        dEntryNumLinesOfCode = 0;
                        dEntryNumLinesOfDocs = 0;
                    end
                end
                
                dNumLinesOfCode = dNumLinesOfCode + dEntryNumLinesOfCode;
                dNumLinesOfDocs = dNumLinesOfDocs + dEntryNumLinesOfDocs;
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = private, Static = true)
        
        function [dEntryNumLinesOfCode, dEntryNumLinesOfDocs] = CountLinesOfCodeInMatlabFile(chFilePath)
            dEntryNumLinesOfCode = 0;
            dEntryNumLinesOfDocs = 0;
            
            dFid = fopen(chFilePath);
            chLine = fgetl(dFid);
            
            while ischar(chLine)
                chLine = strtrim(chLine);
                
                if isempty(chLine)
                    dEntryNumLinesOfCode = dEntryNumLinesOfCode + 1;
                else
                    if chLine(1) == '%'
                        dEntryNumLinesOfDocs = dEntryNumLinesOfDocs + 1;
                    else
                        dEntryNumLinesOfCode = dEntryNumLinesOfCode + 1;
                    end
                end
                
                chLine = fgetl(dFid);
            end
            
            fclose(dFid);
        end
        
        function [dEntryNumLinesOfCode, dEntryNumLinesOfDocs] = CountLinesOfCodeInPythonFile(chFilePath)
            dEntryNumLinesOfCode = 0;
            dEntryNumLinesOfDocs = 0;
            
            dFid = fopen(chFilePath);
            chLine = fgetl(dFid);
            
            while ischar(chLine)
                chLine = strtrim(chLine);
                
                if isempty(chLine)
                    dEntryNumLinesOfCode = dEntryNumLinesOfCode + 1;
                else
                    if chLine(1) == '#'
                        dEntryNumLinesOfDocs = dEntryNumLinesOfDocs + 1;
                    else
                        dEntryNumLinesOfCode = dEntryNumLinesOfCode + 1;
                    end
                end
                
                chLine = fgetl(dFid);
            end
            
            fclose(dFid);
        end
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

