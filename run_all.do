/*******************************************************************************
 Title:          A Simplified Approach for Estimating the 
                 Rt in Small Populations 
 Task:           Master script to reproduce all results in the paper, and
                 supplemental material
 Author:         Daniel Yupanqui
 Created:        2026/01/04
 Last update:    2026/01/09

 
 Instructions:
 
 1. Download the data and code from the GitHub repository:
    https://github.com/danielyupanqui/
    effective_reproduction_number_small_populations

 2. Save the project folder in any location on your computer.

 3. Open Stata.

 4. In Stata, open run_all.do, e.g., by double-clicking the file or 
    via File, Open).

 5. Run the pipeline by typing: do run_all.do
 
 6. Do not change the working directory manually. This pipeline uses
    relative paths. Simply place the project folder in a location of 
	your choice and run run_all.do; all required paths are defined
	internally.
*******************************************************************************/

*0. General setup
{
  clear all
  set more off
  version 19.0

 *Define project root from execution location
  global root "`c(pwd)'"

 *Checking directory 
  pwd
}

*1. Install ados
{
  ssc install rscript	
}

*2. Defining globals 
{
  global codes      "${root}/codes"
  global data       "${root}/data"
  global results    "${root}/results"
}

*3. Run pipeline
{ 
  do ${codes}/01_canada_kernel_rt.do
  do ${codes}/02_provinces_kernel_rt.do
  do ${codes}/03_regions_kernel_rt.do
  
  rscript using ${codes}/04_rt_epiestim_canada.R 
  rscript using ${codes}/05_rt_epiestim_provinces.R 
  rscript using ${codes}/06_rt_epiestim_regions.R 

  do ${codes}/07_graphs_epiestim_kernel.do
  do ${codes}/08_stats_epiestim_kernel.do
  do ${codes}/09_ols_epiestim_kernel.do 	
}
