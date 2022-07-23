# -*- coding: utf-8 -*-
"""
Created on Fri Jun  5 17:50:16 2020

@author: ddv99
"""

from CentralLibraryLabelledImageCollectionDataGenerator import CentralLibraryLabelledImageCollectionDataGenerator
from CentralLibraryBinaryClassificationSampleLabels import CentralLibraryBinaryClassificationSampleLabels
import scipy.io as sio
import numpy as np
import pickle

def CreateCentralLibraryDataGeneratorFromMatFile(sInputMatFilePath):
    # get properities to for imaging/mask data
    oFileDictionary = sio.loadmat(sInputMatFilePath, variable_names = ['vsFilePaths', 'viRegionOfInterestNumbers', 'm2iImageBoundingBoxTopLeftCornerIndices', 'viImageBoundingBoxDimensions', 'm2iMaskBoundingBoxTopLeftCornerIndices', 'viMaskBoundingBoxDimensions', 'iBatchSize', 'bLoadAllDataIntoRam', 'bUseImageData', 'bUseMaskData', 'bUseMaskAsImagingChannel', 'chLabelType'])
        
    vsFilePaths = __ConvertMatFileCellArrayOfCharStringsToNumpyArrayOfStrings(oFileDictionary['vsFilePaths'])
    viRegionOfInterestNumbers = oFileDictionary['viRegionOfInterestNumbers']
    m2iImageBoundingBoxTopLeftCornerIndices = oFileDictionary['m2iImageBoundingBoxTopLeftCornerIndices']
    viImageBoundingBoxDimensions = oFileDictionary['viImageBoundingBoxDimensions']
    m2iMaskBoundingBoxTopLeftCornerIndices = oFileDictionary['m2iMaskBoundingBoxTopLeftCornerIndices']
    viMaskBoundingBoxDimensions = oFileDictionary['viMaskBoundingBoxDimensions']
    iBatchSize = oFileDictionary['iBatchSize']
    bLoadAllDataIntoRam = oFileDictionary['bLoadAllDataIntoRam']
    bUseImageData = oFileDictionary['bUseImageData']
    bUseMaskData = oFileDictionary['bUseMaskData']
    bUseMaskAsImagingChannel = oFileDictionary['bUseMaskAsImagingChannel']
    sLabelType = oFileDictionary['chLabelType']
    
    # get labels
    sLabelType = sLabelType[0]
    
    if sLabelType == 'BinaryClassification':
        oCentralLibraryLabels = CentralLibraryBinaryClassificationSampleLabels.CreateFromMatFile(sInputMatFilePath)
    else:
        raise Exception('Invalid value for chLabelType')
        
    # construct generator and return
    oGenerator = CentralLibraryLabelledImageCollectionDataGenerator(vsFilePaths, viRegionOfInterestNumbers, oCentralLibraryLabels, m2iImageBoundingBoxTopLeftCornerIndices, viImageBoundingBoxDimensions[0], m2iMaskBoundingBoxTopLeftCornerIndices, viMaskBoundingBoxDimensions[0], iBatchSize[0][0], bool(bLoadAllDataIntoRam[0][0]), bool(bUseImageData[0][0]), bool(bUseMaskData[0][0]), bool(bUseMaskAsImagingChannel[0][0]))
    
    return oGenerator
    
    

def __ConvertMatFileCellArrayOfCharStringsToNumpyArrayOfStrings(oObjFromMatFile):
    iNumStrs = len(oObjFromMatFile)
    
    vsStrs = []
    
    for dStrIndex in range(iNumStrs):
        vsStrs.append(oObjFromMatFile[dStrIndex][0][0])
    
    return vsStrs