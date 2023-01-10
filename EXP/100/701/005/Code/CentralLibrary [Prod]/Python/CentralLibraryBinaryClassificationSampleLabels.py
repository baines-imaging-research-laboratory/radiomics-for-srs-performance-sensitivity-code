# -*- coding: utf-8 -*-
"""
Created on Thu May 28 10:52:51 2020

@author: ddevries
"""

import tensorflow as tf
import numpy as np
import scipy.io as sio
from tensorflow import keras

class CentralLibraryBinaryClassificationSampleLabels:
    # member properities
    __m2iOneHotEncodedLabels = [] # (:,2) numpy array of integers # stores the labels as one-hot encoded vectors. A "1" in col 0 is a positive sample. A "1" in col 1 is a negative sample
    __iPositiveLabelInCentralLibrary = [] # (1,1) integer holding the value for a positive label in the CentralLibrary
    __iNegativeLabelInCentralLibrary = [] # (1,1) integer holding the value for a negative label in the CentralLibrary
    
     
    def __init__(self, viLabels, iPositiveLabel, iNegativeLabel):
        self.__m2iOneHotEncodedLabels = keras.utils.to_categorical(viLabels != iPositiveLabel, 2);
        
        self.__iPositiveLabelInCentralLibrary = iPositiveLabel;
        self.__iNegativeLabelInCentralLibrary = iNegativeLabel;
               
        
    @staticmethod
    def CreateFromMatFile(sMatFilePath):
        oFileDictionary = sio.loadmat(sMatFilePath, variable_names = ['viLabels', 'iPositiveLabel', 'iNegativeLabel'])
        
        viLabels = oFileDictionary['viLabels']
        iPositiveLabel = oFileDictionary['iPositiveLabel']
        iNegativeLabel = oFileDictionary['iNegativeLabel']
        
        return CentralLibraryBinaryClassificationSampleLabels(viLabels, iPositiveLabel, iNegativeLabel)
            
    def GetLabelsForSampleIndices(self, viSampleIndices):
        return self.__m2iOneHotEncodedLabels[viSampleIndices, :]
            
    def GetNumberOfSamples(self):
        return size(self.__m2iOneHotEncodedLabels)
    
    def GetTestingResultsMatFileDictionary(self, m2xPredictResults):
        m2xPredictResults = np.squeeze(m2xPredictResults);
        
        if m2xPredictResults.ndim == 1 and m2xPredictResults.shape == (2): # only a single sample, so need to add the 0th dimension back, since squeeze would have removed it
            m2xPredictResults = np.expand_dims(m2xPredictResults,0)  
        elif m2xPredictResults.ndim == 2 and m2xPredictResults.shape[1] == 2: # multiple samples for binary classification, we're good to go
            # do nothing
            m2xPredictResults = m2xPredictResults
        else: # is not correct dimensions for binary classification
            error('Incorrect results shape for binary classification. When squeeze is applied, must be of dimensionality (,2)')            
            
        
        vdPositiveLabelConfidences = m2xPredictResults[:,0]
        vdNegativeLabelConfidences = m2xPredictResults[:,1]
        
        vdPositiveLabelConfidences = vdPositiveLabelConfidences[np.newaxis]
        vdNegativeLabelConfidences = vdNegativeLabelConfidences[np.newaxis]
        
        vdPositiveLabelConfidences = vdPositiveLabelConfidences.T
        vdNegativeLabelConfidences = vdNegativeLabelConfidences.T
        
        return {"vdPositiveLabelConfidences": vdPositiveLabelConfidences, "vdNegativeLabelConfidences": vdNegativeLabelConfidences}