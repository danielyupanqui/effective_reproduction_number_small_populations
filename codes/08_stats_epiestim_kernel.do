/*******************************************************************************
  Title:          Methodology for the calculation of Covid19 Rt in Canada
  Task:           Descriptive statistics for Epiestim and Kernel Triangle
  Author:         Daniel Yupanqui
  Initial update: 2025/03/29
  Last update:    2026/01/06
*******************************************************************************/

*1. Canada: Merge Epiestim with Kernels
{
  use ${data}/canada_rt, clear
  joinby id using ${results}/r_canada_epiestim, unm(b)
  
 *Create the correlation variable 
  egen corr_epi_kernel = corr(r_rectangle_am r_epiestim)
  
 *Create the variable with counts of zeros or missing of cases 
  generate zeros = cases_am == 0 | cases_am == .
  
 *Collapse and calculate stats
  collapse(max)  corr_epi_kernel									 ///
                 max_epiestim     = r_epiestim                       ///
				 max_kernel       = r_rectangle_am                   ///
		  (min)  min_epiestim     = r_epiestim                       ///
		         min_kernel       = r_rectangle_am                   ///
          (sum)  cases_am zeros          						     /// 
		         cases                                               ///
          (mean) cases_am_mean    = cases_am                         ///
				 cases_mean       = cases 						     ///
		         rt_epiestim_mean = r_epiestim                       ///
				 rt_kernel_mean   = r_rectangle_am                   ///
		  (sd)   cases_am_sd      = cases_am                         ///
		         rt_epiestim_sd   = r_epiestim                       ///
				 rt_kernel_sd     = r_rectangle_am 
 
 *Calculate CV
  generate cv_epiestim = rt_epiestim_sd/rt_epiestim_mean
  generate cv_kernel   = rt_kernel_sd/rt_kernel_mean
  generate cv_ratio    = cv_epiestim/cv_kernel	
	
 *Save in dta and excel
  save ${results}/stats_canada, replace
  export excel using "${results}/stats_rt_results.xlsx", ///
         sheet("canada") firstrow(variables) sheetreplace
}

*2. Provinces: Merge Epiestim with Kernels
{
  use ${data}/province_rt, clear
  forvalues x = 1/13 {	
    joinby id using ${results}/r_prov_epiestim_`x', unm(b)
    tab _merge
    drop _merge
  }
  
 *Create a variable with Rt_epiestim for all provinces
  generate rt_epiestim  = .
  forvalues x = 1/13 {	
    replace rt_epiestim = r_epiestim_`x' if province_code == `x'
  }

 *Create a variable with Rt_Kernelk_Rectangle for all provinces
  generate rt_kernel_rect   = .
  forvalues x = 1/13 {	
    replace rt_kernel_rect  = r_rectangle_`x'_am if province_code == `x'
  }
 
 *Create the correlation variable
  bysort province_code: egen corr_epi_kernel = corr(rt_epiestim rt_kernel_rect) 
   
 *Create the variable with counts of zeros or missing of cases 
  generate zeros = cases_am == 0 | cases_am == .
 
 *Counting Rt lower than zeros
  generate rt_negative = rt_kernel_rect < 0
 
 *Generate Rt kernel excluding negatives
  generate min_kernel = rt_kernel_rect if rt_kernel_rect > 0    
 
 *Collapse and calculate stats
  collapse(max)  corr_epi_kernel									 ///
                 max_epiestim     = rt_epiestim                      ///
				 max_kernel       = rt_kernel_rect                   ///
		  (min)  min_epiestim     = rt_epiestim                      ///
		         min_kernel                                          ///
          (sum)  cases_am zeros          						     ///
                 rt_negative                                         ///
				 cases 											     ///
          (mean) cases_am_mean    = cases_am                         ///
		         cases_mean       = cases 						     ///
		         rt_epiestim_mean = rt_epiestim                      ///
				 rt_kernel_mean   = rt_kernel_rect                   ///
		  (sd)   cases_am_sd      = cases_am                         ///
		         rt_epiestim_sd   = rt_epiestim                      ///
				 rt_kernel_sd     = rt_kernel_rect,                  ///
		   by    (province_code)
 
 *Calculate CV
  generate cv_epiestim = rt_epiestim_sd/rt_epiestim_mean
  generate cv_kernel   = rt_kernel_sd/rt_kernel_mean
  generate cv_ratio    = cv_epiestim/cv_kernel	

 *Sort provinces and territories
  generate order = .
  replace order  = 1  if province_code == 2
  replace order  = 2  if province_code == 1
  replace order  = 3  if province_code == 12
  replace order  = 4  if province_code == 3
  replace order  = 5  if province_code == 9
  replace order  = 6  if province_code == 11
  replace order  = 7  if province_code == 6
  replace order  = 8  if province_code == 4
  replace order  = 9  if province_code == 10
  replace order  = 10 if province_code == 7
  replace order  = 11 if province_code == 13
  replace order  = 12 if province_code == 5
  replace order  = 13 if province_code == 8
  
  sort order
  
 *Save dta and excel 
  save ${results}/stats_provinces, replace	
  export excel using "${results}/stats_rt_results_02.xlsx", ///
         sheet("provinces") firstrow(variables) sheetreplace
}

*3. Health Regions: Merge Epiestim with Kernels
{
  use ${data}/region_rt, clear
  forvalues x = 1/99 {	
    joinby id using ${results}/r_region_epiestim_`x', unm(b)
    tab _merge
    drop _merge
  }
  
 *Create a variable with Rt_epiestim for all provinces
  generate rt_epiestim  = .
  forvalues x = 1/99 {	
    replace rt_epiestim = r_epiestim_`x' if hr == `x'
  }

 *Create a variable with Rt_Kernelk_Rectangle for all provinces
  generate rt_kernel_rect   = .
  forvalues x = 1/99 {	
    replace rt_kernel_rect  = r_rectangle_`x'_am if hr == `x'
  }
 
 *Create the correlation variable
  bysort hr: egen corr_epi_kernel = corr(rt_epiestim rt_kernel_rect) 
   
 *Create the variable with counts of zeros or missing of cases 
  generate zeros = cases_am == 0 | cases_am == .

 *Counting Rt lower than zeros
  generate rt_negative = rt_kernel_rect < 0
 
 *Generate Rt kernel excluding negatives
  generate min_kernel = rt_kernel_rect if rt_kernel_rect > 0     
 
 *Collapse and calculate stats
  collapse(max)  corr_epi_kernel									 ///
                 max_epiestim     = rt_epiestim                      ///
				 max_kernel       = rt_kernel_rect                   ///
		  (min)  min_epiestim     = rt_epiestim                      ///
		         min_kernel                                          ///
          (sum)  cases_am zeros          						     ///
		         rt_negative                                         ///
				 cases 												 ///
          (mean) cases_am_mean    = cases_am                         ///
		         cases_mean       = cases 						     ///
		         rt_epiestim_mean = rt_epiestim                      ///
				 rt_kernel_mean   = rt_kernel_rect                   ///
		  (sd)   cases_am_sd      = cases_am                         ///
		         rt_epiestim_sd   = rt_epiestim                      ///
				 rt_kernel_sd     = rt_kernel_rect,                  ///
		   by    (hr)
 
 *Calculate CV
  generate cv_epiestim = rt_epiestim_sd/rt_epiestim_mean
  generate cv_kernel   = rt_kernel_sd/rt_kernel_mean
  generate cv_ratio    = cv_epiestim/cv_kernel	

 *Save dta and excel
  sort corr_epi_kernel
  save results/stats_regions, replace
  export excel using "results/stats_rt_results_02.xlsx", ///
         sheet("hr") firstrow(variables) sheetreplace
}

*4. Summary of statistics for health regions
{
 *Import dta
  use results/stats_regions, clear
  
 *Create % for group of cases counts
  gsort    - cases
  egen     total_cases        = sum(cases)
  generate perc_cases         = cases/total_cases
  generate cum_cases          = sum(perc_cases)
  generate int perc_cum_cases = cum_cases * 100
  
 *Generate group of cases counts
  generate group = .
  replace  group = 1 if inrange(perc_cum_cases,  0,  25)
  replace  group = 2 if inrange(perc_cum_cases, 26, 50)
  replace  group = 3 if inrange(perc_cum_cases, 51, 75)
  replace  group = 4 if inrange(perc_cum_cases, 76, 100)

 *Collapse and generate statistics 
  collapse(count) hr                		                               ///
          (sum)   cases                     			                   ///
		  (max)   max_epiestim max_kernel                 			       ///
		  (mean)  corr_epi_kernel cv_epiestim cv_kernel cv_ratio,          /// 
           by(group)

 *Save dta and excel
  save ${results}/summary_stats_regions, replace
  export excel using "${results}/stats_rt_results.xlsx", ///
         sheet("summary_hr") firstrow(variables) sheetreplace
}
