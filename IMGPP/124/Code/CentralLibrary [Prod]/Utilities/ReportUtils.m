classdef (Abstract) ReportUtils
    %ReportUtils
    %   TODO

    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Static = true)
        
        function oReport = InitializePDF(sFilePath)
            %oReport = InitializePDF(sFilePath)
            %
            % SYNTAX:
            %  oReport = InitializePDF(sFilePath)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  sFilePath: 
            %
            % OUTPUT ARGUMENTS:
            %  oReport:
            
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            oReport = Report(sFilePath, 'pdf');
        end
        
        function oLink = CreateLinkToMatFileWithVarNames(sPreLinkText, sFilePath, vsVarDescriptors, vsVarNames)
            %oLink = CreateLinkToMatFileWithVarNames(sPreLinkText, sFilePath, vsVarDescriptors, vsVarNames)
            %
            % SYNTAX:
            %  oLink = CreateLinkToMatFileWithVarNames(sPreLinkText, sFilePath, vsVarDescriptors, vsVarNames)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  sPreLinkText:
            %  sFilePath:
            %  vsVarDescriptors:
            %  vsVarNames:
            %
            % OUTPUT ARGUMENTS:
            %  oLink:
            
            arguments
                sPreLinkText (1,1) string
                sFilePath (1,1) string
                vsVarDescriptors (:,1) string
                vsVarNames (:,1) string {ValidationUtils.MustBeSameSize(vsVarNames, vsVarDescriptors)}
            end
            
            oLink = ExperimentReportFileLink(sPreLinkText, sFilePath, vsVarDescriptors, vsVarNames);
        end
        
        function oLink = CreateLinkToFile(sPreLinkText, sFilePath)
            %oLink = CreateLinkToFile(sPreLinkText, sFilePath)
            %
            % SYNTAX:
            %  oLink = CreateLinkToFile(sPreLinkText, sFilePath)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  sPreLinkText:
            %  sFilePath:
            %
            % OUTPUT ARGUMENTS:
            %  oLink:
            
            arguments
                sPreLinkText (1,1) string
                sFilePath (1,1) string
            end
            
            oLink = ExperimentReportFileLink(sPreLinkText, sFilePath);
        end
        
        function oParagraph = CreateParagraph(sText)
            %oParagraph = CreateParagraph(sText)
            %
            % SYNTAX:
            %  oParagraph = CreateParagraph(sText)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  sText:
            %
            % OUTPUT ARGUMENTS:
            %  oParagraph:
            
            arguments
                sText (1,1) string
            end
            
            % import libraries
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            % make paragraph
            oParagraph = Paragraph(sText);
        end
        
        function oParagraph = CreateParagraphWithBoldLabel(sLabel, sText)
            %oParagraph = CreateParagraphWithBoldLabel(sLabel, sText)
            %
            % SYNTAX:
            %  oParagraph = CreateParagraphWithBoldLabel(sLabel, sText)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  sLabel:
            %  sText:
            %
            % OUTPUT ARGUMENTS:
            %  oParagraph:
            
            arguments
                sLabel (1,1) string
                sText (1,1) string
            end
            
            % import libraries
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            % make paragraph
            oParagraph = Paragraph();
            
            oLabel = Text(sLabel);
            oLabel.Bold = true;
            
            oText = Text(sText);
            
            oParagraph.append(oLabel);
            oParagraph.append(oText);
        end
        
        function oText = CreateText(sText)
            %oText = CreateText(sText)
            %
            % SYNTAX:
            %  oText = CreateText(sText)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  sText:
            %
            % OUTPUT ARGUMENTS:
            %  oText:
            
            arguments
                sText (1,1) string
            end
            
            % import libraries
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            % make paragraph
            oText = Text(sText);
        end
        
        function oSection = CreateSection(sSectionName)
            %oSection = CreateSection(sSectionName)
            %
            % SYNTAX:
            %  oSection = CreateSection(sSectionName)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  sSectionName:
            %
            % OUTPUT ARGUMENTS:
            %  oSection:
            
            arguments
                sSectionName (1,1) string
            end
            
            % import libraries
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            % make section
            oSection = Section(sSectionName);
        end
        
        function oFigure = CreateFigure(hFig)
            %oFigure = CreateFigure(hFig)
            %
            % SYNTAX:
            %  oFigure = CreateFigure(hFig)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  hFig:
            %
            % OUTPUT ARGUMENTS:
            %  oFigure:
            
            arguments
                hFig (1,1) {matlab.ui.Figure}
            end
            
            % import libraries
            import mlreportgen.report.*;
            import mlreportgen.dom.*;
            
            % make figure            
            oFigure = Figure(hFig);
        end
        
        function chFormat = GetTimestampDatestrFormat()
            %chFormat = GetTimestampDatestrFormat()
            %
            % SYNTAX:
            %  chFormat = GetTimestampDatestrFormat()
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUT ARGUMENTS:
            %  chFormat:
            
            chFormat = 'mmm dd, yyyy HH:MM:SS';
        end
        
        function chFormat = GetDurationDatestrFormat()
            %chFormat = GetDurationDatestrFormat()
            %
            % SYNTAX:
            %  chFormat = GetDurationDatestrFormat()
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUT ARGUMENTS:
            %  chFormat:
            
            chFormat = 'HH:MM:SS';
        end
        
        function oTable = CreateTable(tTable)            
            %oTable = CreateTable(tTable)
            %
            % SYNTAX:
            %  oTable = CreateTable(tTable)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  tTable:
            %
            % OUTPUT ARGUMENTS:
            %  oTable:
            
            import mlreportgen.dom.*;
            
            oTable = Table([tTable.Properties.VariableNames; table2cell(tTable)], 'rgMATLABTable');
            
            for dColIndex=1:length(oTable.Children(1).Entries)
                oTable.Children(1).Entries(dColIndex).Children.Bold = true;
                oTable.Children(1).Entries(dColIndex).Children.Underline = 'single';
            end
        end
    end
        
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    
    methods (Access = private, Static = true)
        
    end
end

