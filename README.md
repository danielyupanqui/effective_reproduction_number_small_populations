# A Simplified Approach for Estimating the Effective Reproduction Number in Small Populations

## Overview

Charles Plante and I develop a methodology to estimate **daily reproduction numbers** of infectious diseases in **small population areas** by focusing on the growth rate derived from the **SIR model**.

We estimate the daily growth rate of COVID-19 using **non-parametric kernel regression** for Canada at multiple geographic levels, including:
- The national level  
- Provinces and territories  
- 99 public health regions  

These estimates are directly compared with those produced by **EpiEstim**, a widely used standard method.

## Key Findings

- Kernel regression produces **smoother and more reliable growth-rate estimates** in both large and small populations.
- The advantages are especially pronounced in settings with **sparse or volatile case data**.
- As a result, our approach yields **more stable and robust daily reproduction-number estimates** in small population areas than EpiEstim.
- The findings suggest that standard methods often rely on assumptions that may not hold in **low-incidence settings**.

## Contribution

Overall, this work demonstrates that **non-parametric kernel regression** provides a more consistent and flexible framework for estimating disease transmission dynamics across **heterogeneous population sizes**, improving inference where traditional methods perform poorly.


## Instructions

Do not change the working directory manually.
This pipeline is designed to use a portable directory structure, meaning all file paths are defined relative to the project root. You can place the project folder anywhere on your system and run **run_all.do** without modifying paths or settings. All required directories and file references are handled internally.
Follow the next steps for replicate this project:

1. Download the folders and files from this GitHub repository, i.e. **Code** → **Downlad ZIP**.

2. Save the project folder in any location on your computer.

3. Open **Stata**.

4. In Stata, open [**run_all.do**](https://github.com/danielyupanqui/effective_reproduction_number_small_populations/blob/main/run_all.do):
   - Double-click the file, or  
   - Use **File → Open**

5. Run the pipeline by typing: do run_all.do

## Data

This paper utilizes a case study of the COVID-19 pandemic in Canada, employing data publicly available from the **COVID-19 Canada Open Data Working Group**.

The data are sourced from the group’s public GitHub repository, which provides harmonized, regularly updated COVID-19 epidemiological data for Canada:
- https://github.com/ccodwg/Covid19Canada

### Citation

COVID-19 Canada Open Data Working Group. (2022). *COVID-19 Canada Open Data Working Group dataset*.  

### Data License and Availability

The data are openly available and distributed under an open-data license, permitting use, redistribution, and adaptation with appropriate attribution. Users should consult the original repository for the most current version of the data and detailed licensing information.
