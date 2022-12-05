classdef ValidateSpecificRtStructPolygonsTask < ImageVolumeViewerTask
    %ValidateSpecificRtStructPolygonsTask
    %
    
    
    % Primary Author: David DeVries
    % Created: Nov 28, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = public)
        chStudyDatabaseLoadPath
    end
    
    properties (SetAccess = private, GetAccess = public)
        chStudyDatabaseSavePath
        
        oStudyDatabase
        
        oCurrentPatient
        oCurrentImagingStudy
        oCurrentDatabaseImageVolume
        
        oCurrentRASImageVolume
        
        dCurrentImageVolumeIndex = 0
        dCurrentRegionOfInterestNumber = 0
        dCurrentPolygonNumber = 0
        
        dCurrentNumberOfImageVolumes = 0
        dCurrentNumberOfRegionsOfInterest = 0
        dCurrentNumberOfPolygons = 0
        
        vdPatientNumbers
        vdStudyNumbers
        
        dCurrentPatientStudyIndex = 0
        dCurrentNumberOfPatientStudies = 0
    end
    
    properties (Constant = true, GetAccess = private)
        vdCurrentRegionOfInterestColour_rgb = [0 0.4 1];
        
        vdCurrentPolygonEnabledColour_rgb = [1 0 0];
        vdCurrentPolygonDisabledColour_rgb = [1 0.3 0.3];
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ValidateSpecificRtStructPolygonsTask(chProgressCacheFilePath, chStudyDatabaseLoadPath, chStudyDatabaseSavePath, vdPatientNumbers, vdStudyNumbers)
            % obj = ImageVolumeViewerTask(chProgressCacheFilePath, vsHotkeyLabels, vfnHotkeyCallbacks, c1chHotkeys)
            arguments
                chProgressCacheFilePath (1,:) char
                chStudyDatabaseLoadPath (1,:) char
                chStudyDatabaseSavePath (1,:) char
                vdPatientNumbers (1,:) double {mustBePositive, mustBeInteger}
                vdStudyNumbers (1,:) double {mustBePositive, mustBeInteger}
            end
            
            vsHotkeyLabels = [...
                "Next Polygon",...
                "Enable/Disable Polygon",...
                "Previous Polygon"];
            
            c1fnHotkeyCallbacks = {...
                @(x) x.NextPolygon(),...
                @(x) x.EnableDisablePolygon(),...
                @(x) x.PreviousPolygon()};
            
            c1chHotkeys = {...
                'rightarrow',...
                'space',...
                'leftarrow'};
            
            % super-class call
            obj@ImageVolumeViewerTask(chProgressCacheFilePath, vsHotkeyLabels, c1fnHotkeyCallbacks, c1chHotkeys);
            
            % set properities
            obj.chStudyDatabaseLoadPath = chStudyDatabaseLoadPath;
            obj.chStudyDatabaseSavePath = chStudyDatabaseSavePath;
            
            obj.vdPatientNumbers = vdPatientNumbers;
            obj.vdStudyNumbers = vdStudyNumbers;
            obj.dCurrentNumberOfPatientStudies = length(obj.vdPatientNumbers);
        end
        
        function Resume(obj, chNewProgressCacheFilePath, chNewStudyDatabaseSavePath)
            arguments
                obj (1,1) ValidateSpecificRtStructPolygonsTask
                chNewProgressCacheFilePath (1,:) char = ''
                chNewStudyDatabaseSavePath (1,:) char = ''
            end
            
            if ~isempty(chNewStudyDatabaseSavePath)
                obj.chStudyDatabaseSavePath = chNewStudyDatabaseSavePath;
            end
            
            Resume@ImageVolumeViewerTask(obj, chNewProgressCacheFilePath);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function InitializeForBegin(obj)
            obj.oStudyDatabase = StudyDatabase.Load(obj.chStudyDatabaseLoadPath);
            
            obj.NextPolygon();
        end
        
        function InitializeForResume(obj)
            obj.GetImageVolumeViewerApp().SetNewImageVolume(obj.oCurrentRASImageVolume);
            obj.SetCurrentRegionOfInterestColourAndVisibility();
            obj.CentreImageVolumeViewerAndSetColourForCurrentPolygon();
        end
        
        function c1chProgressText = GetProgressText(obj)
            if isempty(obj.oCurrentRASImageVolume)
                chRoiName = 'No Image Volume';
                chRoiLabel = 'No Image Volume';
                chRoiType = 'No Image Volume';
                chImageVolumePath = 'No Image Volume';
            else
                vsNames = obj.oCurrentRASImageVolume.GetRegionsOfInterest().GetRegionsOfInterestNames();
                vsLabels = obj.oCurrentRASImageVolume.GetRegionsOfInterest().GetRegionsOfInterestObservationLabels();
                vsTypes = obj.oCurrentRASImageVolume.GetRegionsOfInterest().GetRegionsOfInterestInterpretedTypes();
                
                chRoiName = char(vsNames(obj.dCurrentRegionOfInterestNumber));
                chRoiLabel = char(vsLabels(obj.dCurrentRegionOfInterestNumber));
                chRoiType = char(vsTypes(obj.dCurrentRegionOfInterestNumber));
                chImageVolumePath = obj.oCurrentDatabaseImageVolume.GetImageDatabaseFilePath();
            end
            
            c1chProgressText = {...
                ['Patient #: ', num2str(obj.vdPatientNumbers(obj.dCurrentPatientStudyIndex)), '/', num2str(obj.dCurrentNumberOfPatientStudies)],...
                ['Study #: ', num2str(obj.vdStudyNumbers(obj.dCurrentPatientStudyIndex)), '/', num2str(obj.dCurrentNumberOfPatientStudies)],...
                ['Image Volume #: ', num2str(obj.dCurrentImageVolumeIndex), '/', num2str(obj.dCurrentNumberOfImageVolumes)],...
                ['ROI #: ', num2str(obj.dCurrentRegionOfInterestNumber), '/', num2str(obj.dCurrentNumberOfRegionsOfInterest)],...
                ['Poly #: ', num2str(obj.dCurrentPolygonNumber) , '/', num2str(obj.dCurrentNumberOfPolygons)],...
                ' ',...
                ['ROI Name: ', chRoiName],...
                ['ROI Label: ', chRoiLabel],...
                ['ROI Type: ', chRoiType],...
                ' ',...
                ['Volume File Path: ', chImageVolumePath]};
        end
        
        function SaveProgress_ChildClass(obj)
            obj.SaveCurrentImageVolume();
        end
        
        function ProcessCallback(obj, fnCallback)
            fnCallback(obj);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> KEY CALLBACKS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function EnableDisablePolygon(obj)
            bCurrentPolygonEnabled = obj.oCurrentRASImageVolume.GetRegionsOfInterest.IsPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber);
            
            % back change on local copy in task and viewer copy
            obj.oCurrentRASImageVolume.GetRegionsOfInterest.SetPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber, ~bCurrentPolygonEnabled);
            obj.GetImageVolumeViewerController().GetRASImageVolume().GetRegionsOfInterest.SetPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber, ~bCurrentPolygonEnabled);
            obj.GetImageVolumeViewerController().GetImageVolume().GetRegionsOfInterest.SetPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber, ~bCurrentPolygonEnabled);
            
            % Colour current polygon
            if ~bCurrentPolygonEnabled
                vdPolyColour_rgb = ValidateSpecificRtStructPolygonsTask.vdCurrentPolygonEnabledColour_rgb;
            else
                vdPolyColour_rgb = ValidateSpecificRtStructPolygonsTask.vdCurrentPolygonDisabledColour_rgb;
            end
            
            oRoiRenderer = obj.GetImageVolumeViewerController.GetImageVolumeRenderer().GetRegionsOfInterestRenderer();
            
            oRoiRenderer.SetPolygonColour(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber, vdPolyColour_rgb);
            
            
            obj.GetImageVolumeViewerController.SetOnPlaneRegionsOfInterestPolygonsLineStyle();
            obj.GetImageVolumeViewerController.UpdateOnPlaneRegionsOfInterestOverlays();
            
            obj.GetImageVolumeViewerController.UpdateInteractiveImagingPlaneSlice(ImagingPlaneTypes.Sagittal);
            obj.GetImageVolumeViewerController.UpdateInteractiveImagingPlaneSlice(ImagingPlaneTypes.Coronal);
            obj.GetImageVolumeViewerController.UpdateInteractiveImagingPlaneSlice(ImagingPlaneTypes.Axial);
        end
        
        function NextPolygon(obj)
            bTaskComplete = false;
            bNoPolygons = false;
            bNoImageVolumes = false;
            
            if obj.dCurrentPolygonNumber < obj.dCurrentNumberOfPolygons
                % increment polygon
                obj.dCurrentPolygonNumber = obj.dCurrentPolygonNumber + 1;
            else
                % new Region of Interest
                obj.dCurrentPolygonNumber = 1;
                
                if obj.dCurrentRegionOfInterestNumber < obj.dCurrentNumberOfRegionsOfInterest
                    % increment Region of Interest
                    obj.dCurrentRegionOfInterestNumber = obj.dCurrentRegionOfInterestNumber + 1;
                else
                    % new Image Volume
                    obj.dCurrentRegionOfInterestNumber = 1;
                    
                    if obj.dCurrentImageVolumeIndex < obj.dCurrentNumberOfImageVolumes
                        % increment Image Volume
                        obj.dCurrentImageVolumeIndex = obj.dCurrentImageVolumeIndex + 1;
                    else
                        % new Patient / Imaging Study 
                        obj.dCurrentImageVolumeIndex = 1;
                        
                        if obj.dCurrentPatientStudyIndex < obj.dCurrentNumberOfPatientStudies
                            % increment Patient / Imaging Study
                            
                            obj.dCurrentPatientStudyIndex = obj.dCurrentPatientStudyIndex+ 1;
                        else
                            % task complete
                            bTaskComplete = true;
                        end
                        
                        % new Patient / Imaging Study wrap-up
                        if ~bTaskComplete
                            obj.oCurrentPatient = obj.oStudyDatabase.GetPatientByPrimaryId(obj.vdPatientNumbers(obj.dCurrentPatientStudyIndex));
                            obj.oCurrentImagingStudy = obj.oCurrentPatient.GetImagingStudyByStudyNumber(obj.vdStudyNumbers(obj.dCurrentPatientStudyIndex));
                            voContourImageVolumes = obj.oCurrentImagingStudy.GetContouredImageVolumes();
                            obj.dCurrentNumberOfImageVolumes = length(voContourImageVolumes);
                            
                            bNoImageVolumes = (obj.dCurrentNumberOfImageVolumes == 0);
                        end
                    end
                    
                    
                    % new Image Volume wrap-up
                    if ~bTaskComplete
                        if bNoImageVolumes
                            % 1) No contoured image volumes in study
                            % - save current image volume
                            % - wipe out image volume objects
                            % - do nothing to viewer
                            % - show pop-up to user (pressing "ok" will go
                            % to next polygon)
                            
                            obj.SaveCurrentImageVolume();
                            
                            obj.oCurrentDatabaseImageVolume = DatabaseImageVolume.empty;
                            obj.oCurrentRASImageVolume = MATLABImageVolume.empty;
                            
                            obj.dCurrentNumberOfRegionsOfInterest = 0;
                            
                            fnCloseFunc = @(oEventSource, stEventStruct) obj.NextPolygon();
                            uialert(obj.GetImageVolumeViewerController().GetFigure(), 'No contoured image volumes in study.', 'No Image Volumes!', 'CloseFcn', fnCloseFunc);
                        else
                            % 2) There is an available image volume
                            % - save current iamge volume
                            % - load up new image volume objects
                            % - set new image volume to viewer
                            
                            hProgressBar = uiprogressdlg(obj.GetImageVolumeViewerController().GetFigure(), 'Message', 'Loading Image Volume...', 'Indeterminate', 'on');
                            
                            obj.SaveCurrentImageVolume();
                            
                            voContouredImageVolumes = obj.oCurrentImagingStudy.GetContouredImageVolumes();
                            obj.oCurrentDatabaseImageVolume = voContouredImageVolumes(obj.dCurrentImageVolumeIndex);
                            
                            obj.oCurrentRASImageVolume = obj.oCurrentDatabaseImageVolume().GetImageVolumeObject();
                            
                            oApp = obj.GetImageVolumeViewerApp();
                            oApp.SetNewImageVolume(obj.oCurrentRASImageVolume);
                            
                            obj.dCurrentNumberOfRegionsOfInterest = obj.oCurrentDatabaseImageVolume.GetNumberOfRegionsOfInterest();
                            
                            delete(hProgressBar);
                        end
                    end
                end
                
                
                % new Region of Interest wrap-up
                if ~bTaskComplete
                    if bNoImageVolumes
                        % 1) There is no image volume
                        % - set number of polygons to 0
                        
                        obj.dCurrentNumberOfPolygons = 0;
                        bNoPolygons = true;
                    else
                        % 2) There is an image volume
                        % - Find number of polygons in current ROI
                        
                        obj.dCurrentNumberOfPolygons = obj.oCurrentRASImageVolume.GetRegionsOfInterest().GetNumberOfPolygonsByRegionOfInterestNumber(obj.dCurrentRegionOfInterestNumber);
                        
                        if obj.dCurrentNumberOfPolygons == 0
                            % 2.1) No polygons
                            % - show pop-up to user
                            
                            fnCloseFunc = @(oEventSource, stEventStruct) obj.NextPolygon();
                            uialert(obj.GetImageVolumeViewerController().GetFigure(), 'No polygons in ROI', 'No Polygons!', 'CloseFcn', fnCloseFunc);
                            
                            bNoPolygons = true;
                        else
                            % 2.2) Are polygons
                            % - set ROI in viewer
                            
                            
                            obj.SetCurrentRegionOfInterestColourAndVisibility();
                            bNoPolygons = false;
                        end
                    end
                end
            end
            
            
            % new Polygon wrap-up:
            % % - Task Complete OR Update Console/Centre on Current Polygon
            if bTaskComplete
                obj.SaveCurrentImageVolume();
                obj.TaskComplete();
            else
                if ~bNoPolygons
                    % if there are polygons, set the current in centre FOV
                    obj.CentreImageVolumeViewerAndSetColourForCurrentPolygon();
                end
                
                obj.UpdateConsoleProgressText();
            end
        end
        
        function PreviousPolygon(obj)
            bNoImageVolumes = false;
            bNoPolygons = false;
            
            if obj.dCurrentPolygonNumber > 1
                % decrement polygon
                obj.dCurrentPolygonNumber = obj.dCurrentPolygonNumber - 1;
            else
                % new Region of Interest
                
                if obj.dCurrentRegionOfInterestNumber > 1
                    % decrement Region of Interest
                    obj.dCurrentRegionOfInterestNumber = obj.dCurrentRegionOfInterestNumber - 1;
                else
                    % new Image Volume
                    
                    if obj.dCurrentImageVolumeIndex > 1
                        % decrement Image Volume
                        obj.dCurrentImageVolumeIndex = obj.dCurrentImageVolumeIndex - 1;
                    else
                        % new Patient / Imaging Study
                        
                        if obj.dCurrentPatientStudyIndex > 1
                            % decrement Patient / Imaging Study
                            obj.dCurrentPatientStudyIndex = obj.dCurrentPatientStudyIndex - 1;
                        else
                            % error
                            error('At the first polygon already');
                        end
                        
                        % new patient / imaging study wrap-up
                        obj.oCurrentPatient = obj.oStudyDatabase.GetPatientByPrimaryId(obj.vdPatientNumbers(obj.dCurrentPatientStudyIndex));
                        obj.oCurrentImagingStudy = obj.oCurrentPatient.GetImagingStudyByStudyNumber(obj.vdStudyNumbers(obj.dCurrentPatientStudyIndex));
                        voContourImageVolumes = obj.oCurrentImagingStudy.GetContouredImageVolumes();
                        obj.dCurrentNumberOfImageVolumes = length(voContourImageVolumes);
                        
                        bNoImageVolumes = (obj.dCurrentNumberOfImageVolumes == 0);
                        
                        if bNoImageVolumes
                            obj.dCurrentImageVolumeIndex = 1;
                        else
                            obj.dCurrentImageVolumeIndex = obj.dCurrentNumberOfImageVolumes;
                        end
                    end
                    
                    % new Image Volume wrap-up
                    if bNoImageVolumes
                        % 1) No contoured image volumes in study
                        % - save current image volume
                        % - wipe out image volume objects
                        % - do nothing to viewer
                        % - show pop-up to user (pressing "ok" will go
                        % to next polygon)
                        
                        obj.SaveCurrentImageVolume();
                        
                        obj.oCurrentDatabaseImageVolume = DatabaseImageVolume.empty;
                        obj.oCurrentRASImageVolume = MATLABImageVolume.empty;
                        
                        obj.dCurrentNumberOfRegionsOfInterest = 0;
                        obj.dCurrentRegionOfInterestNumber = 1;
                        
                        fnCloseFunc = @(oEventSource, stEventStruct) obj.PreviousPolygon();
                        uialert(obj.GetImageVolumeViewerController().GetFigure(), 'No contoured image volumes in study.', 'No Image Volumes!', 'CloseFcn', fnCloseFunc);
                    else
                        % 2) There is an available image volume
                        % - save current iamge volume
                        % - load up new image volume objects
                        % - set new image volume to viewer
                        
                        hProgressBar = uiprogressdlg(obj.GetImageVolumeViewerController().GetFigure(), 'Message', 'Loading Image Volume...', 'Indeterminate', 'on');
                        
                        obj.SaveCurrentImageVolume();
                        
                        voContouredImageVolumes = obj.oCurrentImagingStudy.GetContouredImageVolumes();
                        obj.oCurrentDatabaseImageVolume = voContouredImageVolumes(obj.dCurrentImageVolumeIndex);
                        
                        obj.oCurrentRASImageVolume = obj.oCurrentDatabaseImageVolume().GetImageVolumeObject();
                        
                        oApp = obj.GetImageVolumeViewerApp();
                        oApp.SetNewImageVolume(obj.oCurrentRASImageVolume);
                        
                        obj.dCurrentNumberOfRegionsOfInterest = obj.oCurrentDatabaseImageVolume.GetNumberOfRegionsOfInterest();
                        obj.dCurrentRegionOfInterestNumber = obj.dCurrentNumberOfRegionsOfInterest;
                        
                        delete(hProgressBar);
                    end
                end
                
                % new Region of Interest wrap-up
                if bNoImageVolumes
                    % 1) There is no image volume
                    % - set number of polygons to 0
                    
                    obj.dCurrentNumberOfPolygons = 0;
                    obj.dCurrentPolygonNumber = 1;
                    
                    bNoPolygons = true;
                else
                    % 2) There is an image volume
                    % - Find number of polygons in current ROI
                    
                    obj.dCurrentNumberOfPolygons = obj.oCurrentRASImageVolume.GetRegionsOfInterest().GetNumberOfPolygonsByRegionOfInterestNumber(obj.dCurrentRegionOfInterestNumber);
                    
                    if obj.dCurrentNumberOfPolygons == 0
                        % 2.1) No polygons
                        % - show pop-up to user
                        
                        obj.dCurrentPolygonNumber = 1;
                        
                        fnCloseFunc = @(oEventSource, stEventStruct) obj.PreviousPolygon();
                        uialert(obj.GetImageVolumeViewerController().GetFigure(), 'No polygons in ROI', 'No Polygons!', 'CloseFcn', fnCloseFunc);
                        
                        bNoPolygons = true;
                    else
                        % 2.2) Are polygons
                        % - set ROI in viewer
                        
                        obj.dCurrentPolygonNumber = obj.dCurrentNumberOfPolygons;
                        
                        obj.SetCurrentRegionOfInterestColourAndVisibility();
                        bNoPolygons = false;
                    end
                end
                
            end
            
            if ~bNoPolygons
                % if there are polygons, set the current in centre FOV
                obj.CentreImageVolumeViewerAndSetColourForCurrentPolygon();
            end
            
            obj.UpdateConsoleProgressText();
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> HELPER FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function SaveCurrentImageVolume(obj)
            if ~isempty(obj.oCurrentRASImageVolume)
                % force all transforms and save
                obj.oCurrentRASImageVolume.ForceApplyAllTransforms();
                obj.oCurrentRASImageVolume.Save();
                
                oCurrentImageVolumeViewRecord = obj.GetImageVolumeViewerApp.GetCurrentImageVolumeView();
                
                obj.oCurrentDatabaseImageVolume.SetPreferredImageVolumeDisplayThreshold(oCurrentImageVolumeViewRecord.GetImageDataDisplayThreshold());
                obj.SaveDatabase();
            end
        end
        
        function SaveDatabase(obj)
            obj.oStudyDatabase.Save(obj.chStudyDatabaseSavePath);
        end
        
        % % % % %         function LoadCurrentImageVolume(obj)
        % % % % %             obj.SaveCurrentImageVolume();
        % % % % %
        % % % % %             obj.oCurrentRASImageVolume = obj.oCurrentDatabaseImageVolume.GetImageVolumeObject();
        % % % % %         end
        
        function SetCurrentRegionOfInterestColourAndVisibility(obj)
            for dRoiIndex=1:obj.dCurrentNumberOfRegionsOfInterest
                if dRoiIndex == obj.dCurrentRegionOfInterestNumber
                    bVisible = true;
                else
                    bVisible = false;
                end
                
                obj.GetImageVolumeViewerApp().SetRegionOfInterestVisibility(dRoiIndex, bVisible);
            end
            
            obj.GetImageVolumeViewerApp().SetRegionOfInterestColour(obj.dCurrentRegionOfInterestNumber, ValidateSpecificRtStructPolygonsTask.vdCurrentRegionOfInterestColour_rgb);
        end
        
        function CentreImageVolumeViewerAndSetColourForCurrentPolygon(obj)
            % Colour current polygon
            obj.GetImageVolumeViewerApp().SetRegionOfInterestColour(obj.dCurrentRegionOfInterestNumber, ValidateSpecificRtStructPolygonsTask.vdCurrentRegionOfInterestColour_rgb);
            
            if obj.oCurrentRASImageVolume.GetRegionsOfInterest().IsPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber)
                vdPolyColour_rgb = ValidateSpecificRtStructPolygonsTask.vdCurrentPolygonEnabledColour_rgb;
            else
                vdPolyColour_rgb = ValidateSpecificRtStructPolygonsTask.vdCurrentPolygonDisabledColour_rgb;
            end
            
            oRoiRenderer = obj.GetImageVolumeViewerController.GetImageVolumeRenderer().GetRegionsOfInterestRenderer();
            
            oRoiRenderer.SetPolygonColour(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber, vdPolyColour_rgb);
            oRoiRenderer.UpdateAllPolygons();
            
            % Centre on current polygon
            m2dVertexVoxelCoords = obj.oCurrentRASImageVolume.GetRegionsOfInterest().GetPolygonVertexVoxelIndicesByRoiNumberAndPolygonIndex(obj.dCurrentRegionOfInterestNumber, obj.dCurrentPolygonNumber);
            vdVoxelDimensions_mm = obj.oCurrentRASImageVolume.GetVoxelDimensions_mm();
            
            vdCentre = mean(m2dVertexVoxelCoords,1);
            
            vdMaxs = max(m2dVertexVoxelCoords,[],1);
            vdMins = max(m2dVertexVoxelCoords,[],1);
            
            vdAnatomicalPlaneIndices = round(vdCentre);
            
            dFovVoxelPadding = 5;
            
            % Sagittal FOV
            vdSagDimensionSelect = ImagingPlaneTypes.Sagittal.GetRASVolumeDimensionSelect();
            
            [vdSagRowCoords_mm, vdSagColCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(...
                m2dVertexVoxelCoords(:,vdSagDimensionSelect(1)), m2dVertexVoxelCoords(:,vdSagDimensionSelect(2)),...
                vdVoxelDimensions_mm(vdSagDimensionSelect(1)), vdVoxelDimensions_mm(vdSagDimensionSelect(2)));
            
            vdSagCentre_mm = [mean(vdSagRowCoords_mm), mean(vdSagColCoords_mm)];
            dHeight_mm = max(vdSagRowCoords_mm) - min(vdSagRowCoords_mm) + dFovVoxelPadding*vdVoxelDimensions_mm(vdSagDimensionSelect(1));
            dWidth_mm = max(vdSagColCoords_mm) - min(vdSagColCoords_mm) + dFovVoxelPadding*vdVoxelDimensions_mm(vdSagDimensionSelect(2));
            
            oSagFov = ImageVolumeFieldOfView2D(vdSagCentre_mm, dHeight_mm, dWidth_mm);
            
            % Coronal FOV
            vdCorDimensionSelect = ImagingPlaneTypes.Coronal.GetRASVolumeDimensionSelect();
            
            [vdCorRowCoords_mm, vdCorColCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(...
                m2dVertexVoxelCoords(:,vdCorDimensionSelect(1)), m2dVertexVoxelCoords(:,vdCorDimensionSelect(2)),...
                vdVoxelDimensions_mm(vdCorDimensionSelect(1)), vdVoxelDimensions_mm(vdCorDimensionSelect(2)));
            
            vdCorCentre_mm = [mean(vdCorRowCoords_mm), mean(vdCorColCoords_mm)];
            dHeight_mm = max(vdCorRowCoords_mm) - min(vdCorRowCoords_mm) + dFovVoxelPadding*vdVoxelDimensions_mm(vdCorDimensionSelect(1));
            dWidth_mm = max(vdCorColCoords_mm) - min(vdCorColCoords_mm) + dFovVoxelPadding*vdVoxelDimensions_mm(vdCorDimensionSelect(2));
            
            oCorFov = ImageVolumeFieldOfView2D(vdCorCentre_mm, dHeight_mm, dWidth_mm);
            
            % Axial FOV
            vdAxialDimensionSelect = ImagingPlaneTypes.Axial.GetRASVolumeDimensionSelect();
            
            [vdAxialRowCoords_mm, vdAxialColCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(...
                m2dVertexVoxelCoords(:,vdAxialDimensionSelect(1)), m2dVertexVoxelCoords(:,vdAxialDimensionSelect(2)),...
                vdVoxelDimensions_mm(vdAxialDimensionSelect(1)), vdVoxelDimensions_mm(vdAxialDimensionSelect(2)));
            
            vdAxialCentre_mm = [mean(vdAxialRowCoords_mm), mean(vdAxialColCoords_mm)];
            dHeight_mm = max(vdAxialRowCoords_mm) - min(vdAxialRowCoords_mm) + dFovVoxelPadding*vdVoxelDimensions_mm(vdAxialDimensionSelect(1));
            dWidth_mm = max(vdAxialColCoords_mm) - min(vdAxialColCoords_mm) + dFovVoxelPadding*vdVoxelDimensions_mm(vdAxialDimensionSelect(2));
            
            oAxialFov = ImageVolumeFieldOfView2D(vdAxialCentre_mm, dHeight_mm, dWidth_mm);
            
            % Make image volume record
            oCurrentImageVolumeViewRecord = obj.GetImageVolumeViewerApp.GetCurrentImageVolumeView();
            
            oNewImageVolumeViewRecord = ImageVolumeViewRecord(...
                vdAnatomicalPlaneIndices,...
                [oSagFov, oCorFov, oAxialFov],...
                oCurrentImageVolumeViewRecord.GetImageDataDisplayThreshold());
            
            obj.GetImageVolumeViewerApp.SetCurrentImageVolumeView(oNewImageVolumeViewRecord);
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