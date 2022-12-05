classdef ContourValidationResult < matlab.mixin.Copyable
    %ContourValidationResult
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dContourGroupNumber % 0 for invalid/delete, 1-Inf valid contour, empty if new contour created
        bCreatedNewContourGroup % T/F
        c1chNotes = {} % cell array of lines of c1chNotes text area
        
        c1chDropDownResults = {} % cell array of strings of chosen options
        vbCheckboxResults = [] % array of boolean values        
        
        c1oDropDownQuestions = {} % cell array of DropDownQuestion objects for reference
        c1oCheckboxQuestions = {} % cell array of CheckBoxQuestion objects for reference
    end
    
    
% % % % % checkboxQuestions = {...
% % % % %     CheckboxQuestion('Is there a necrotic core?',           false, 'f1'),...
% % % % %     CheckboxQuestion('Is the necrotic core contoured?',     true,  'f2'),...
% % % % %     CheckboxQuestion('Is there edema around the tumour?',   false, 'f3'),...
% % % % %     CheckboxQuestion('Inaccurate contour?',                 false, 'f4'),...
% % % % %     CheckboxQuestion('Inaccurate contour label?',           false, 'f5'),...
% % % % %     CheckboxQuestion('Non-Sagittal Acquisition?',           false, 'f6'),...
% % % % %     CheckboxQuestion('Acquisition not well aligned?',       false, 'f7'),...    
% % % % %     CheckboxQuestion('General revisit required?',           false, 'f8')
% % % % %     };
% % % % % 
% % % % % dropDownQuestions = {...
% % % % %     DropDownQuestion('Type of Contour:',...
% % % % %     {'GTV','CTV','PTV','Unsure','Other'},...
% % % % %     'GTV',...
% % % % %     'numpad4'),...
% % % % %     DropDownQuestion('Contour Label Interpretation:',...
% % % % %     {'GTV','CTV','PTV','Other'},...
% % % % %     'GTV',...
% % % % %     'numpad5')};
% % % % % 
% % % % % notesDefault = {'CONTOUR NOTES: ', '', 'NECROTIC CORE NOTES: ', '', 'OTHER: ', ''};
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ContourValidationResult(dContourGroupNumber, bCreatedNewContourGroup, c1chNotes, c1chDropDownResults, vbCheckboxResults)
            %ContourValidationResult
            
            obj.dContourGroupNumber = dContourGroupNumber;
            obj.bCreatedNewContourGroup = bCreatedNewContourGroup;
            obj.c1chNotes = c1chNotes;            
            obj.c1chDropDownResults = c1chDropDownResults;
            obj.vbCheckboxResults = vbCheckboxResults;            
        end
        
        function update(obj)              
        end
        
        function applyCurrentContourResultFromApp(obj, app)
            % contourNumber & bCreatedNewContour
            chContourNumListBoxVal = app.ContourGroupNumberListBox.Value;
            
            if strcmp(chContourNumListBoxVal, 'New Group')
                obj.bCreatedNewContourGroup = true;
                
                if isempty(app.c1oContourDisplays)
                    obj.dContourGroupNumber = 1;
                else
                    obj.dContourGroupNumber = app.c1oContourDisplays{end}.dContourGroupNumber + 1;
                end
                
                ContourValidation_createNewContourDisplay(app);                    
            else
                obj.bCreatedNewContourGroup = false;
                
                if strcmp(chContourNumListBoxVal, 'Invalid (Reject)')
                    obj.dContourGroupNumber = 0;
                else
                    dContourGroupNumber = str2double(chContourNumListBoxVal(length('Group ')+1 : end));
                    
                    obj.dContourGroupNumber = dContourGroupNumber;
                    
                    ContourValidation_addContourToContourDisplay(app);
                end
            end
            
            % c1chNotes
            obj.c1chNotes = app.NotesTextArea.Value;
            
            % check-box results
            dNumCheckboxQuestions = length(app.c1oCheckboxQuestions);
            vbCheckboxResults = false(dNumCheckboxQuestions,1);
            
            for dCheckboxIndex=1:dNumCheckboxQuestions
                oCheckboxHandle = app.(['BooleanQuestion', num2str(dCheckboxIndex), 'CheckBox']);
                
                vbCheckboxResults(dCheckboxIndex) = oCheckboxHandle.Value;
            end
            
            obj.vbCheckboxResults = vbCheckboxResults; 
            obj.c1oCheckboxQuestions = ObjectUtilities.copyObjectCellArray(app.c1oCheckboxQuestions);
            
            % set drop-down questions
            dNumDropDownQuestions = length(app.c1oDropDownQuestions);
            c1chDropDownResults = cell(dNumDropDownQuestions,1);
            
            for dDropDownIndex=1:dNumDropDownQuestions
                oDropDownHandle = app.(['DropDown', num2str(dDropDownIndex)]);
                
                c1chDropDownResults{dDropDownIndex} = oDropDownHandle.Value;
            end
            
            obj.c1chDropDownResults = c1chDropDownResults;
            obj.c1oDropDownQuestions = ObjectUtilities.copyObjectCellArray(app.c1oDropDownQuestions);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dContourGroupNumber = GetContourGroupNumber(obj)
            dContourGroupNumber = obj.dContourGroupNumber;
        end
        
        function bCreatedNewContourGroup = GetCreatedNewContourGroup(obj)
            bCreatedNewContourGroup = obj.bCreatedNewContourGroup;
        end
        
        function c1chNotes = GetNotes(obj)
            c1chNotes = obj.c1chNotes;
        end        
        
        function c1chDropDownResults = GetDropDownResults(obj)
            c1chDropDownResults = obj.c1chDropDownResults;
        end        
        
        function chDropDownResult = GetDropDownResultsByIndex(obj, dIndex)
            if isempty(obj)
                chDropDownResult = [];
            else                
                chDropDownResult = obj.c1chDropDownResults{dIndex};
            end
        end       
        
        function vbCheckboxResults = GetCheckboxResults(obj)
            vbCheckboxResults = obj.vbCheckboxResults;
        end        
        
        function bCheckboxResult = GetCheckboxResultsByIndex(obj, dIndex)
            if isempty(obj)
                bCheckboxResult = [];
            else
                bCheckboxResult = obj.vbCheckboxResults(dIndex);
            end
        end      
        
        function c1oDropDownQuestions = GetDropDownQuestions(obj)
            c1oDropDownQuestions = obj.c1oDropDownQuestions;
        end 
        
        function c1oCheckboxQuestions = GetCheckboxQuestions(obj)
            c1oCheckboxQuestions = obj.c1oCheckboxQuestions;
        end 
    end    
    
    
    methods (Access = public, Static)
        
        function obj = createDefault(app)
            dContourNumber = [];
            bCreatedNewContourGroup = true; % default to creating a new contour number
            
            % c1chNotes default
            c1chNotes = app.c1chNotesDefault;
            
            % drop down defaults
            numDropDowns = length(app.c1oDropDownQuestions);            
            c1chDropDownResults = cell(numDropDowns,1);
            
            for dDropDownIndex=1:numDropDowns
                c1chDropDownResults{dDropDownIndex} = app.c1oDropDownQuestions{dDropDownIndex}.getDefault();
            end
            
            % checkbox defaults
            dNumCheckboxes = length(app.c1oCheckboxQuestions);            
            vbCheckboxResults = false(dNumCheckboxes,1);
            
            for dCheckboxIndex=1:dNumCheckboxes
                vbCheckboxResults(dCheckboxIndex) = app.c1oCheckboxQuestions{dCheckboxIndex}.getDefault();
            end
            
            % create object
            obj = ContourValidationResult(...
                dContourNumber, bCreatedNewContourGroup, c1chNotes,...
                c1chDropDownResults, vbCheckboxResults);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
        end 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
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

