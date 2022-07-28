# radiomics-for-srs-performance-sensitivity-code
Open-source code associated with the results presented in the manuscript "Brain Metastasis Stereotactic Radiosurgery Outcome Prediction using MRI Radiomics: Performance Sensitivity to Primary Cancer, Metastasis Volume and Scanner Type"

## Code Description
The experiments and analysis described in the manuscript were performed in a number of discrete steps. Each step is contained with a separate folder within this repository. The "main.m" file within each folder contains the code performed, with any other reference code contained within the "Code" sub-folder. "codepaths.txt" and "datapaths.txt" contain references to the code and data used by each "main.m". "Experiment.m" contains a class allowing for completely reproducible execution of the "main.m" code, including random number generation regardless of a single processor or multi-processor (local or distributed) computation environment. To run each "main.m", the current directory should be set to the folder containing the "main.m" file in question, and then "Experiment.Run()" should be executed. "settings.mat" contains setting for the Experiment class that can be adjusted without impacting the computation results (e.g. single vs. multi-processor execution).

## Experiment Manifest
Below is a brief description of each experiment/analysis step in the code repository:

### Sample Selection
**SS-001:** Applies the exclusion criteria to remove punctate brain metastases

### Image Pre-Processing
**IMGPP-102:** Takes the original MRI image and produces a cropped image volume around the centre of each brain metastasis

**IMGPP-103:** Builds on IMGPP-102 by interpolating to 0.5x0.5x0.5 mm^3 resolution

**IMGPP-124:** Builds on IMGPP-103 by applying the Z-score intensity normalization

### Region-of-interest Pre-Processing
**ROIPP-102:** Takes the original regions-of-interest on the MRI and produces a cropped region-of-interest volume around the centre of each brain metastasis 

**ROIPP-105:** Builds on ROIPP-102 by interpolating to 0.5x0.5x0.5 mm^3 resolution

### Image Volume Handler
**IVH-307:** Links imaging and region-of-interest data from IMGPP-124 and ROIPP-105 together for each brain metastasis, along with giving each a sample ID

### Feature Values
**FV-500-000:** MRI acquisition parameters for each sample

**FV-500-100:** Clinical features for each sample

**FV-500-400:** Brain metastasis volume for each sample


**FV-705-000:** Extraction of radiomic features by calling PyRadiomics via Matlab

**FV-705-001:** Creation of Matlab feature values object from FV-705-000 for 1st order features

**FV-705-002:** Creation of Matlab feature values object from FV-705-000 for shape features

**FV-705-005:** Creation of Matlab feature values object from FV-705-000 for GLCM features

**FV-705-006:** Creation of Matlab feature values object from FV-705-000 for GLRLM features

**FV-705-007:** Creation of Matlab feature values object from FV-705-000 for GLDM features

**FV-705-008:** Creation of Matlab feature values object from FV-705-000 for GLSZM features

**FV-705-009:** Creation of Matlab feature values object from FV-705-000 for NGTDM features

### Labels
**LBL-201:** Ground-truth post-SRS progression labels for each brain metastasis

### Model
**MDL-100:** Random forest model as described in the manuscript

### Feature Selector
**FS-100:** Inter-feature correlation feature filter as described in the manuscript

### Hyper-Parameter Optimizer
**HPO-100:** Bayesian hyper-parameter optimizer as described in the manuscript

### Objective Function
**OFN-100:** Out-of-bag AUC hyper-parameter optimizer objective function as described in the manuscript

### Machine Learning Experiments
**EXP-100-400-100:** Bootstrapped machine learning experiment using only clinical features

**EXP-100-400-101:** Bootstrapped machine learning experiment using only radiomic features

**EXP-100-400-102:** Bootstrapped machine learning experiment using clinical and radiomic features


**EXP-100-500-010:** Bootstrapped machine learning experiment removing all volume correlated features at a cut-off of 0

**EXP-100-501-001:** Bootstrapped machine learning experiment removing all volume correlated features at a cut-off of 0.85

**EXP-100-501-002:** Bootstrapped machine learning experiment removing all volume correlated features at a cut-off of 0.70

**EXP-100-501-003:** Bootstrapped machine learning experiment removing all volume correlated features at a cut-off of 0.55

**EXP-100-501-004:** Bootstrapped machine learning experiment removing all volume correlated features at a cut-off of 0.40

**EXP-100-501-005:** Bootstrapped machine learning experiment removing all volume correlated features at a cut-off of 0.25

**EXP-100-501-006:** Bootstrapped machine learning experiment removing all volume correlated features at a cut-off of 0.10


**EXP-100-601-001:** Bootstrapped machine learning experiment using only data from the Vision & Expert MR scanners

**EXP-100-601-002:** Bootstrapped machine learning experiment using only data from the Vision & Avanto MR scanners (only sagittal acquisitions)

**EXP-100-601-003:** Bootstrapped machine learning experiment using only data from the Expert & Avanto MR scanners (only sagittal acquisitions)

**EXP-100-601-004:** Bootstrapped machine learning experiment using only data from the Vision & Avanto MR scanners (axial and sagittal acquisitions)

**EXP-100-601-005:** Bootstrapped machine learning experiment using only data from the Expert & Avanto MR scanners (axial and sagittal acquisitions)


### Analysis & Figure Creation
**AYS-001-006-004:** Computation of volume correlation coefficient values for each radiomic feature

**AYS-001-007-022:** Calculation of error metrics across primary cancer site groups

**AYS-001-007-023:** Calculation of error metrics across brain metastasis volume groups


**AYS-002-001-005-BW:** Creation of Figure 1 to compare of ROCs for using different feature types

**AYS-002-001-006:** Creation of figure to compare ROCs for different MR scanner pairs (only sagittal acquisitions)

**AYS-002-001-007:** Creation of Table 3 to compare error metrics across primary cancer site groups

**AYS-002-001-008:** Creation of Figure 2 to compare error metrics across brain metastasis volume groups and correlation cut-off values

**AYS-002-001-009:** Creation of figure and data for supplementary material on feature importance

**AYS-002-001-010:** Creation of Figure 3 to compare ROCs for different MR scanner pairs (axial and sagittal acquisitions)