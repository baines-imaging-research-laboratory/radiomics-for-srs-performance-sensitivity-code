# -*- coding: utf-8 -*-
"""
Created on Thu May 28 10:52:51 2020

@author: ddevries
"""
import tensorflow as tf
import numpy as np
import scipy.io as sio
from tensorflow import keras
import os
import random

class CentralLibraryLabelledImageCollectionDataGenerator(keras.utils.Sequence):
    # member properities
    __vsFilePaths = [] # (:,1) numpy array of strings # holds the file path to each sample's imaging data (must be 1-to-1 relationship of samples to files)
    __viRegionOfInterestNumbers = [] # (:,1) numpy array of doubles # holds the ROI numbers of each sample. If empty, no ROIs are used, and the entire image in the file is used
    
    __oLabels = [] # (1,1) object of class CentralLibraryLabels # holds the labels (for binary classification, etc.) in a class object
    
    __m2iImageBoundingBoxTopLeftCornerIndices = [] # (:,3) numpy array of integers # holds the bounding box starting indices for each sample's image
    __viImageBoundingBoxDimensions = [] # (1,3) numpy array of integers # holds the size of the bounding box for the images (in # of voxels) in each dimension. This needs to be constant for all samples such that all volumes are the same size for input into the network
    
    __m2iMaskBoundingBoxTopLeftCornerIndices = [] # (:,3) numpy array of integers # holds the bounding box starting indices for each sample's mask (is empty if no masks are being used)
    __viMaskBoundingBoxDimensions = [] # (1,3) numpy array of integers # holds the size of the bounding box for the masks (in # of voxels) in each dimension. This needs to be constant for all samples such that all volumes are the same size for input into the network
    
    __iBatchSize = []
    __bStoreAllImagesInRam = []
    
    __bUseImageData = []
    __bUseMaskData = []
    __bUseMaskAsImagingChannel = []
    
    __viShuffledIndicesForEpoch = []
    
    __m5xTensorCacheForAllImages = []
    __m5xTensorCacheForAllMasks = []
    
    __sCentralLibraryImageVolumeImageDataMatFileVarName = "m3xImageData"
    __sCentralLibraryImageVolumeLabelMapDataMatFileVarName = "m3uiLabelMaps"
    
    
    def __init__(self, vsFilePaths, viRegionOfInterestNumbers, oLabels, m2iImageBoundingBoxTopLeftCornerIndices, viImageBoundingBoxDimensions, m2iMaskBoundingBoxTopLeftCornerIndices, viMaskBoundingBoxDimensions, iBatchSize=32, bStoreAllImagesInRam = False, bUseImageData = True, bUseMaskData = False, bUseMaskAsImagingChannel = False):
        self.__viShuffledIndicesForEpoch = np.random.permutation(len(vsFilePaths))     
        
        self.__vsFilePaths = np.array(vsFilePaths)
        self.__viRegionOfInterestNumbers = viRegionOfInterestNumbers
        
        self.__oLabels = oLabels;
        
        self.__m2iImageBoundingBoxTopLeftCornerIndices = np.array(m2iImageBoundingBoxTopLeftCornerIndices)
        self.__viImageBoundingBoxDimensions = np.array(viImageBoundingBoxDimensions)
        
        self.__m2iMaskBoundingBoxTopLeftCornerIndices = np.array(m2iMaskBoundingBoxTopLeftCornerIndices)
        self.__viMaskBoundingBoxDimensions = np.array(viMaskBoundingBoxDimensions)
        
        self.__iBatchSize = iBatchSize
        self.__bStoreAllImagesInRam = bStoreAllImagesInRam
        
        self.__bUseImageData = bUseImageData
        self.__bUseMaskData = bUseMaskData
        self.__bUseMaskAsImagingChannel = bUseMaskAsImagingChannel
        
        self.on_epoch_end()
        
        # if self.bStoreAllImagesInRam:
        #     iNumImages = len(vsFilePaths)
            
        #     m5xTensorForAllImages = np.empty([iNumImages, self.vdImageSize[0], self.vdImageSize[1], self.vdImageSize[2], 1])
            
        #     for dImageIndex, sFilePath in enumerate(vsFilePaths):
        #         m3xImageData = self.__load__(sFilePath[0])
            
        #         m5xTensorForAllImages[dImageIndex,:,:,:,0] = m3xImageData
                
        #     self.m5xTensorForAllImages = m5xTensorForAllImages
                
            
        
    def __load__(self, iSampleIndex):
        sFilePath = self.__vsFilePaths[iSampleIndex]
        iRoiNumber = self.__viRegionOfInterestNumbers[iSampleIndex]
        
        if not(self.__bUseMaskData) and self.__bUseImageData: # load images, no ROIs
            oFileDictionary = sio.loadmat(sFilePath, variable_names = [self.__sCentralLibraryImageVolumeImageDataMatFileVarName])
            
            m3xImageData = oFileDictionary[self.__sCentralLibraryImageVolumeImageDataMatFileVarName]
            m3bMaskData = np.array([])
        elif self.__bUseMaskData and self.__bUseImageData: # load images and ROIs
            oFileDictionary = sio.loadmat(sFilePath, variable_names = [self.__sCentralLibraryImageVolumeImageDataMatFileVarName, self.__sCentralLibraryImageVolumeLabelMapDataMatFileVarName])
            
            m3xImageData = oFileDictionary[self.__sCentralLibraryImageVolumeImageDataMatFileVarName]
            
            m3uiLabelMaps = oFileDictionary[self.__sCentralLibraryImageVolumeLabelMapDataMatFileVarName]
            m3bMaskData = self.__ExtractMaskFromBitMap(m3uiLabelMaps, iRoiNumber)
        elif self.__bUseMaskData and not(self.__bUseImageData): # load ROIs no images
            oFileDictionary = sio.loadmat(sFilePath, variable_names = [self.__sCentralLibraryImageVolumeLabelMapDataMatFileVarName])
            
            m3xImageData = np.array([])
            
            m3uiLabelMaps = oFileDictionary[self.__sCentralLibraryImageVolumeLabelMapDataMatFileVarName]
            m3bMaskData = self.__ExtractMaskFromBitMap(m3uiLabelMaps, iRoiNumber)
        
        # check dimensionality
        if self.__bUseImageData:
            if m3xImageData.ndim == 2:
                m3xImageData = np.expand_dims(m3xImageData, 2)
        
        if self.__bUseMaskData:
            if m3bMaskData.ndim == 2:
                m3bMaskData = np.expand_dims(m3bMaskData, 2)
        
        # apply bounding box if needed
        if self.__bUseImageData:  # apply bounding box to image
            m3xImageData = CentralLibraryLabelledImageCollectionDataGenerator.__ApplyBoundingBoxSelection(m3xImageData, self.__m2iImageBoundingBoxTopLeftCornerIndices[iSampleIndex,:], self.__viImageBoundingBoxDimensions)
            
        if self.__bUseMaskData:  # apply bounding box to ROI
            m3bMaskData = CentralLibraryLabelledImageCollectionDataGenerator.__ApplyBoundingBoxSelection(m3bMaskData, self.__m2iMaskBoundingBoxTopLeftCornerIndices[iSampleIndex,:], self.__viMaskBoundingBoxDimensions)
        
        return m3xImageData, m3bMaskData
        
    
    
    def __getitem__(self, dIndex):        
        # calculate indices for batch (need to access shuffled indices):
            
        if (dIndex+1)*self.__iBatchSize > self.__GetNumberOfSamples():
            viIndicesForBatch = self.__viShuffledIndicesForEpoch[dIndex*self.__iBatchSize : len(self.__viShuffledIndicesForEpoch)]
        else:
            viIndicesForBatch = self.__viShuffledIndicesForEpoch[dIndex*self.__iBatchSize : (dIndex+1)*self.__iBatchSize]
        
        iNumImagesInBatch = len(viIndicesForBatch)
        
        # construct data tensor for input into the network:
        if self.__bUseMaskAsImagingChannel:
            iNumChannels = self.__bUseImageData + self.__bUseMaskData
            
            m5xTensorForBatch = np.empty([iNumImagesInBatch, self.__viImageBoundingBoxDimensions[0], self.__viImageBoundingBoxDimensions[1], self.__viImageBoundingBoxDimensions[2], iNumChannels]) # [# images in batch, x dim, y dim, z dim, # channels]
        else:
            if ~(self.__bUseImageData and self.__bUseMaskData):
                m5xTensorForBatch = np.empty([iNumImagesInBatch, self.__viImageBoundingBoxDimensions[0], self.__viImageBoundingBoxDimensions[1], self.__viImageBoundingBoxDimensions[2], 1]) # [# images in batch, x dim, y dim, z dim, # channels]                
            else:
                raise Exception('Under construction')  
                    
                          
        # load data depending on memory settings
        ## load from RAM cache
        if self.__bStoreAllImagesInRam:
            if self.__bUseMaskAsImagingChannel:
                iCurrentChannelNumber = 0
                
                if self.__bUseImageData:
                    m5xTensorForBatch[:,:,:,:,iCurrentChannelNumber] = self.m5xTensorForAllImages[viIndicesForBatch,:,:,:,:]
                    iCurrentChannelNumber = iCurrentChannelNumber + 1
                
                if self.__bUseMaskData:
                    m5xTensorForBatch[:,:,:,:,iCurrentChannelNumber] = self.m5xTensorForAllMasks[viIndicesForBatch,:,:,:,:]
                    
            else:
                if ~(self.__bUseImageData and self.__bUseMaskData):
                    if self.__bUseImageData:
                        m5xTensorForBatch[:,:,:,:,0] = self.m5xTensorForAllImages[viIndicesForBatch,:,:,:,:]
                    else:
                        m5xTensorForBatch[:,:,:,:,0] = self.m5xTensorForAllMasks[viIndicesForBatch,:,:,:,:]
                else:
                    raise Exception('Under construction') 
        
        ## load from disk    
        else:                        
            for iBatchIndex, iSampleIndex in enumerate(viIndicesForBatch):
                m3xImageData, m3bMaskData = self.__load__(iSampleIndex)
                
                if self.__bUseMaskAsImagingChannel:
                    iCurrentChannelNumber = 0
                    
                    if self.__bUseImageData:
                        m5xTensorForBatch[iBatchIndex,:,:,:,iCurrentChannelNumber] = m3xImageData
                        iCurrentChannelNumber = iCurrentChannelNumber + 1
                    
                    if self.__bUseMaskData:
                        m5xTensorForBatch[iBatchIndex,:,:,:,iCurrentChannelNumber] = m3bMaskData
                        
                else:
                    if ~(self.__bUseImageData and self.__bUseMaskData):
                        if self.__bUseImageData:
                            m5xTensorForBatch[iBatchIndex,:,:,:,0] = m3xImageData
                        else:
                            m5xTensorForBatch[iBatchIndex,:,:,:,0] = m3bMaskData
                    else:
                        raise Exception('Under construction') 
                
                
        # Get labels:
        m2xLabelsForBatch = self.__oLabels.GetLabelsForSampleIndices(viIndicesForBatch)
        
        # Return:
        return m5xTensorForBatch, m2xLabelsForBatch
        
    
    
    def on_epoch_end(self):
        self.__viShuffledIndicesForEpoch = np.random.permutation(self.__GetNumberOfSamples())  
        
        
        
    def __len__(self):
        return int(np.ceil(len(self.__vsFilePaths)/float(self.__iBatchSize)))
    
    
    
    def __ExtractMaskFromBitMap(self, m3uiLabelMaps, iRegionOfInterestNumber):
        m3bMaskData = (m3uiLabelMaps >> (iRegionOfInterestNumber) & 1) != 0
        
        return m3bMaskData
    
        
    @staticmethod        
    def __ApplyBoundingBoxSelection(m3xMatrix, viBoundingBoxTopLeftCornerIndices, viBoundingBoxDimensions):
        m3xSelectedMatrix = m3xMatrix[viBoundingBoxTopLeftCornerIndices[0]:viBoundingBoxTopLeftCornerIndices[0]+viBoundingBoxDimensions[0], viBoundingBoxTopLeftCornerIndices[1]:viBoundingBoxTopLeftCornerIndices[1]+viBoundingBoxDimensions[1], viBoundingBoxTopLeftCornerIndices[2]:viBoundingBoxTopLeftCornerIndices[2]+viBoundingBoxDimensions[2]]
          
        return m3xSelectedMatrix
        
        
    def __GetNumberOfSamples(self):
        return len(self.__vsFilePaths)
    
    
    def GetNumberOfSamples(self):
        return self.__GetNumberOfSamples()
    
    
    def GetBatchSize(self):
        return self.__iBatchSize
    
    
    def GetItem(self, dIndex):
        return self.__getitem__(dIndex)
    
    def Len(self):
        return self.__len__()
    
    def __GenerateMaskData(self):
        return False
    
    
    def GetLabels(self):
        return self.__oLabels
    
    def GetShuffledIndicesForEpoch(self):
        return self.__viShuffledIndicesForEpoch
    
    def Load(self, iSampleIndex):
        m3xImageData, m3bMaskData = self.__load__(iSampleIndex)
        
        return m3xImageData, m3bMaskData
    
    def UseForGuess(self):
        self.__viShuffledIndicesForEpoch = np.arange(0, len(self.__vsFilePaths)) # turn off shuffled indices (if you don't it hard to compare network outputs to expected)