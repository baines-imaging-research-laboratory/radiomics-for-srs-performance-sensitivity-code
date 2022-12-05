classdef ExperimentReportFileLink
    %ExperimentReportFileLink
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: September 23, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        sPreLinkText (1,1) string
                
        vsVarDescriptors (:,1) string
        vsVarNames (:,1) string
    end
    
    properties (SetAccess = private, GetAccess = public)   
        sFilePath (1,1) string
    end
    
    properties (Constant = true, GetAccess = private)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
            
    methods (Access = public, Static = false)
        
        function obj = ExperimentReportFileLink(sPreLinkText, sFilePath, vsVarDescriptors, vsVarNames)
            %obj = ExperimentReportFileLink(sPreLinkText, sFilePath, vsVarDescriptors, vsVarNames)
            %
            % SYNTAX:
            %  TODO
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                sPreLinkText (1,1) string
                sFilePath (1,1) string
                vsVarDescriptors (:,1) string = string.empty(0,1)
                vsVarNames (:,1) string {ValidationUtils.MustBeSameSize(vsVarNames, vsVarDescriptors)} = string.empty(0,1)
            end
            
            obj.sPreLinkText = sPreLinkText;
            obj.sFilePath = sFilePath;
            
            obj.vsVarDescriptors = vsVarDescriptors;
            obj.vsVarNames = vsVarNames;
        end 
        
        function obj = UpdatePath(obj, chCurrentToSubSectionPath, chNewToSubSectionPath)
            arguments
                obj (1,1) ExperimentReportFileLink
                chCurrentToSubSectionPath (1,:) char
                chNewToSubSectionPath (1,:) char
            end
            
            chFilePath = char(obj.sFilePath);
            
            vdIndices = strfind(chFilePath, chCurrentToSubSectionPath);
            
            if isempty(vdIndices)
                error(...
                    'ExperimentReportFileLink:UpdatePath:InvalidPath',...
                    'The expected path was not found.');
            end
            
            chNewFilePath = [chNewToSubSectionPath, chFilePath(vdIndices(1)+length(chCurrentToSubSectionPath) : end)];
            
            obj.sFilePath = string(chNewFilePath);
        end
        
        function AddToReportSection(obj, oReportSection, chMargin, chResultsDirectoryRootPath)
            arguments
                obj (1,1) ExperimentReportFileLink
                oReportSection (1,1) mlreportgen.report.Section
                chMargin (1,:) char
                chResultsDirectoryRootPath (1,:) char
            end
            
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
                        
            if contains(obj.sFilePath, chResultsDirectoryRootPath)
                chFilePath = char(obj.sFilePath);
                
                sFilePathRelativeToResultsDirectory = string(chFilePath(length(chResultsDirectoryRootPath)+1 : end));
            else
                error(...
                    'ExperimentReportFileLink:AddToReportSection:InvalidFilePath',...
                    'The file path must be within the results directory of the experiment.');
            end
            
            
            oLinkParagraph = Paragraph();
            
            oLabel = Text(obj.sPreLinkText + " ");
            oLabel.Bold = true;
                        
            [~, chFileExtension] = FileIOUtils.SeparateFilePathExtension(obj.sFilePath);
            
            if strcmp(chFileExtension, '.pdf')
                oLink = ExternalLink(obj.sFilePath, sFilePathRelativeToResultsDirectory);
            else
                chPathToFolder = FileIOUtils.SeparateFilePathAndFilename(obj.sFilePath);
                
                oLink = ExternalLink(chPathToFolder, sFilePathRelativeToResultsDirectory);
            end
            
            oLinkParagraph.append(oLabel);
            oLinkParagraph.append(oLink);
            
            oLinkParagraph.OuterLeftMargin = chMargin;
            
            oReportSection.add(oLinkParagraph);
            
            if ~isempty(obj.vsVarNames)
                oVarHeader = Paragraph();
                oHeaderText = Text("Variables saved in file:");
                oHeaderText.Bold = true;
                
                oVarHeader.append(oHeaderText);
                oVarHeader.OuterLeftMargin = chMargin;
                
                oReportSection.add(oVarHeader)
                
                for dVarIndex=1:length(obj.vsVarNames)
                    oVarParagraph = ReportUtils.CreateParagraph(obj.vsVarDescriptors(dVarIndex) + ": " + obj.vsVarNames(dVarIndex));
                    oVarParagraph.OuterLeftMargin = chMargin;
                    
                    oReportSection.add(oVarParagraph);
                end
            end                
        end
    end
    
    
    methods (Access = public, Static = true) 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    methods (Access = protected) 
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
      
    methods (Access = private, Static = false)       
    end
    
    
    methods (Access = private, Static = true)
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

