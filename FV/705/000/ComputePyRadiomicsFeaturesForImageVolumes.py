# -*- coding: utf-8 -*-
"""
Created on Mon Dec 13 09:03:55 2021

@author: ddevries
"""

import radiomics as pyrads
from scipy.io import loadmat, savemat
import SimpleITK as sitk
import numpy as np
import six as six
import sys

if __name__ == "__main__":
    # parse inputs
    sManifestLoadPath = sys.argv[1]
    sFeatureValuesSavePath = sys.argv[2]

    stMatFileData = loadmat(sManifestLoadPath)
    
    vdVoxelDimensions_mm = [0.5, 0.5, 0.5];
    
    dNumROIs = len(stMatFileData['vdRegionOfInterestNumberPerSample'])
    
    dNumFeatures = 2060;
    
    m2dFeatureValuesPerSamplePerFeature = np.zeros([dNumROIs,dNumFeatures])
    c1chFeatureNames = np.array(np.zeros([1,dNumFeatures]), dtype=object)
    
    for dROIIndex in range(0,dNumROIs):
        print('*****')
        print(dROIIndex);
        print('*****')
        
        stImageVolumeFileData = loadmat(stMatFileData['c1chImageVolumePathPerSample'][dROIIndex][0][0])
        m3xImageData = stImageVolumeFileData['m3xImageData']
        m3xImageData = np.int32(m3xImageData)
        m3xImageData = m3xImageData + 2**15
        m3xImageData = np.uint16(m3xImageData)
        
        stROIFileData = loadmat(stMatFileData['c1chRegionsOfInterestPathPerSample'][dROIIndex][0][0])
        m3uiLabelMapsData = stROIFileData['m3uiLabelMaps']
        
        dRoiBitNumber = stMatFileData['vdRegionOfInterestNumberPerSample'][dROIIndex]-1
        m3iMask = (np.uint8(m3uiLabelMapsData) & 2**dRoiBitNumber) == 2**dRoiBitNumber # extract mask for given channel using bitwise operations
        m3bMask = m3iMask == 1
        
        oImage = sitk.GetImageFromArray(m3xImageData)
        oImage.SetSpacing(vdVoxelDimensions_mm) 
        
        oMask = sitk.GetImageFromArray(np.uint8(m3iMask))
        oMask.SetSpacing(vdVoxelDimensions_mm)
        
        stSettings = {   
            'sigma' : np.array([5.,4.,3.,2.,1.]),
            
            'start_level' : 0,
            'level' : 1,
            'wavelet' : 'coif1',
            
            'gradientUseSpacing' : True,
            
            'lbp3DLevels' : 2,
            'lbp3DIcosphereRadius' : 1,
            'lbp3DIcosphereSubdivision' : 1,
            
            
            'Label' : 1,
            
            'binWidth' : 1024,
            
            'weightingNorm' : None,
            
            'voxelArrayShift' : 0,
            'symmetricalGLCM' : True,
            'gldm_a' : 0,
            }
        oExtract = pyrads.featureextractor.RadiomicsFeatureExtractor()
        
        # Shape & Size Features
        vdBoundingBox = pyrads.imageoperations.checkMask(oImage, oMask, minimumROIDimensions=3)
        stFeatureValues = oExtract.computeShape(oImage, oMask, vdBoundingBox[0])
        
        # Features on Original Image
        stOriginalImageFeatures = oExtract.computeFeatures(oImage, oMask, "original", **stSettings)
        stFeatureValues.update(stOriginalImageFeatures)
        
        # Features on LoG Images
        vdSigmaValues = np.array([5.,4.,3.,2.,1.])
        oLoGImageGenerator = pyrads.imageoperations.getLoGImage(oImage, oMask, **stSettings)
        
        iCount = 0
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oLoGImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
            
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)
            
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
        
        # Features on Wavelet Images
        oWaveletImageGenerator = pyrads.imageoperations.getWaveletImage(oImage, oMask, **stSettings)
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oWaveletImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
            
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)
                    
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
            
        # Features on Local Binary Pattern Images
        oLBPImageGenerator = pyrads.imageoperations.getLBP3DImage(oImage, oMask, **stSettings)
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oLBPImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
                    
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)        
            
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
            
        # Features on Squared Image
        oImageGenerator = pyrads.imageoperations.getSquareImage(oImage, oMask, **stSettings)
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
                    
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)        
            
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
            
        # Features on Square Root Image
        oImageGenerator = pyrads.imageoperations.getSquareRootImage(oImage, oMask, **stSettings)
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
                    
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)        
            
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
            
        # Features on Logarithm Image
        oImageGenerator = pyrads.imageoperations.getLogarithmImage(oImage, oMask, **stSettings)
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
                    
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)        
            
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
            
        # Features on Exponential Image
        oImageGenerator = pyrads.imageoperations.getExponentialImage(oImage, oMask, **stSettings)
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
                    
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)        
            
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
            
        # Features on Graident Image
        oImageGenerator = pyrads.imageoperations.getGradientImage(oImage, oMask, **stSettings)
        
        for oPreProcessedImage, sPreProcessedImageName, xInputKwargs in oImageGenerator:
            print(iCount)
            
            m3xData = sitk.GetArrayFromImage(oPreProcessedImage)
                    
            dMean = m3xData[m3bMask].mean()
            dStd = m3xData[m3bMask].std()
            
            m3xData = (m3xData - dMean) / dStd
            m3xData = (m3xData+1)*(2**15)
            m3xData[m3xData < 0] = 0
            m3xData[m3xData > 2**16] = 2**16
            m3xData = np.uint16(m3xData)
            
            oPreProcessedImage = sitk.GetImageFromArray(m3xData)
            oPreProcessedImage.SetSpacing(vdVoxelDimensions_mm)         
            
            xInputKwargs.update(stSettings)        
            
            stImageFeatures = oExtract.computeFeatures(oPreProcessedImage, oMask, sPreProcessedImageName, **xInputKwargs)
            stFeatureValues.update(stImageFeatures)
            
            iCount = iCount + 1
            
        # create vectors of data and feature names
        dFeatureIndex = 0
        
        for sKey, dValue in stFeatureValues.items():
            if dROIIndex == 0:
                c1chFeatureNames[0][dFeatureIndex] = sKey
                
            m2dFeatureValuesPerSamplePerFeature[dROIIndex, dFeatureIndex] = dValue
            
            dFeatureIndex = dFeatureIndex + 1
            
            
        if dFeatureIndex != dNumFeatures:
            raise Exception('Not enough features')
            
        
            
    savemat(sFeatureValuesSavePath, {"m2dFeatureValuesPerSamplePerFeature":m2dFeatureValuesPerSamplePerFeature, "c1chFeatureNames": c1chFeatureNames})
