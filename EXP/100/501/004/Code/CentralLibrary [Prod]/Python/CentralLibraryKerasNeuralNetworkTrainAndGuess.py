# -*- coding: utf-8 -*-
"""
Created on Tue Jun  9 17:09:13 2020

@author: ddv99
"""

# import libraries and all that jazz
import pickle
import importlib.util
from pathlib import Path
import sys
import CentralLibraryUtils
import scipy.io as sio
import numpy as np
import random
import tensorflow as tf
from tensorflow import keras

def Train(sKerasNetworkPythonScriptPath, sTrainingDataGeneratorMatFilePath, sValidationDataGeneratorMatFilePath, sHyperParametersMatFilePath, sTrainingResultsMatFilePath, sTrainedModelSavePath):
    sModuleName = Path(sKerasNetworkPythonScriptPath).stem    
    oSpec = importlib.util.spec_from_file_location(sModuleName, sKerasNetworkPythonScriptPath)
    oUserModule = importlib.util.module_from_spec(oSpec)
    oSpec.loader.exec_module(oUserModule)
    
    oTrainingGenerator = CentralLibraryUtils.CreateCentralLibraryDataGeneratorFromMatFile(sTrainingDataGeneratorMatFilePath)
    oValidationGenerator = CentralLibraryUtils.CreateCentralLibraryDataGeneratorFromMatFile(sValidationDataGeneratorMatFilePath)
        
    dictCentralLibraryHyperParameters = LoadHyperParametersFromMatFile(sHyperParametersMatFilePath)
    
    oModel = oUserModule.Train(oTrainingGenerator, oValidationGenerator, dictCentralLibraryHyperParameters, sTrainingResultsMatFilePath)   

    if sTrainedModelSavePath: # if string is not empty
        oModel.save(sTrainedModelSavePath)
                
    return oModel


def Guess(oTrainedModel, sKerasNetworkPythonScriptPath, sTestingDataGeneratorMatFilePath, sTestingResultsMatFilePath, sPredictedValuesMatFilePath):
    sModuleName = Path(sKerasNetworkPythonScriptPath).stem
    oSpec = importlib.util.spec_from_file_location(sModuleName, sKerasNetworkPythonScriptPath)
    oUserModule = importlib.util.module_from_spec(oSpec)
    oSpec.loader.exec_module(oUserModule)
    
    oTestingGenerator = CentralLibraryUtils.CreateCentralLibraryDataGeneratorFromMatFile(sTestingDataGeneratorMatFilePath)
    oTestingGenerator.UseForGuess() # prevents shuffling of indices for batches
    
    dictCentralLibraryHyperParameters = LoadHyperParametersFromMatFile(sHyperParametersMatFilePath)
    
    m2xPredictResults = oUserModule.Guess(oTrainedModel, oTestingGenerator, dictCentralLibraryHyperParameters, sTestingResultsMatFilePath)
    
    oMatFileDict = oTestingGenerator.GetLabels().GetTestingResultsMatFileDictionary(m2xPredictResults)
    
    sio.savemat(sPredictedValuesMatFilePath, oMatFileDict)


def LoadHyperParametersFromMatFile(sHyperParametersMatFilePath):
    dictCentralLibraryHyperParameters = sio.loadmat(sHyperParametersMatFilePath)

    return dictCentralLibraryHyperParameters

def LoadModel(sTrainedModelSavePath):
    oModel = keras.models.load_model(sTrainedModelSavePath)
    
    return oModel


if __name__ == "__main__":
    # parse inputs
    sOperation = sys.argv[1]
    dRandomSeed = int(sys.argv[2])
    sKerasNetworkPythonScriptPath = sys.argv[3]
    sHyperParametersMatFilePath = sys.argv[4]
    
    # set random seeds
    random.seed(dRandomSeed)
    np.random.seed(dRandomSeed)
    tf.random.set_seed(dRandomSeed)
    
    # read parameters and run functions as needed
    
    # - train/load model
    if sOperation == "Train" or sOperation == "TrainAndGuess":
        sTrainingDataGeneratorMatFilePath = sys.argv[5]
        sValidationDataGeneratorMatFilePath = sys.argv[6]
        sTrainedModelSavePath = sys.argv[7]
        sTrainingResultsMatFilePath = sys.argv[8]
        
        oTrainedModel = Train(sKerasNetworkPythonScriptPath, sTrainingDataGeneratorMatFilePath, sValidationDataGeneratorMatFilePath, sHyperParametersMatFilePath, sTrainingResultsMatFilePath, sTrainedModelSavePath)
    elif sOperation == "Guess":
        sTrainedModelSavePath = sys.argv[5]
        oTrainedModel = LoadModel(sTrainedModelSavePath)
    else:
        raise Exception('Invalid operation')
    
    # - guess using model
    if sOperation == "Guess":
        sTestingDataGeneratorMatFilePath = sys.argv[6]
        sPredictedValuesMatFilePath = sys.argv[7]
        sTestingResultsMatFilePath = sys.argv[8]
    elif sOperation == "TrainAndGuess":
        sTestingDataGeneratorMatFilePath = sys.argv[9]
        sPredictedValuesMatFilePath = sys.argv[10]
        sTestingResultsMatFilePath = sys.argv[11]
        
    if sOperation == "Guess" or sOperation == "TrainAndGuess":
        Guess(oTrainedModel, sKerasNetworkPythonScriptPath, sTestingDataGeneratorMatFilePath, sTestingResultsMatFilePath, sPredictedValuesMatFilePath)   
     
    
        
    
    