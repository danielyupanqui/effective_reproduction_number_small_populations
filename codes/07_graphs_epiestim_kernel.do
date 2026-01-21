/*******************************************************************************
  Title:          Methodology for the calculation of Covid19 Waves in Canada
  Task:           Maps for kernel triangle and Epiestim by Canada, 
                  provinces, and regions.
  Author:         Daniel Yupanqui
  Initial update: 29/03/2025
  Last update:    08/12/2025
*******************************************************************************/

*1. Canada: Merge Epiestim with Kernels
{
 *Import excel and saving in dta
  import excel "${results}/r_canada_epiestim.xlsx", ///
         sheet("Sheet1") firstrow clear
  
  rename MeanR r_epiestim
  generate  id = t_end
  save ${results}/r_canada_epiestim.dta, replace
  
 *Make graph 	
  use ${data}/canada_rt, clear
  joinby id using ${results}/r_canada_epiestim, unm(b)
  tab _merge
  
 twoway ///
    (line r_rectangle_am date, lcolor(blue) lwidth(medthick)) ///
    (line r_epiestim     date, lcolor(red)  lwidth(medthick)) ///
    , ///
      legend( order(1 "Kernel" 2 "EpiEstim") ) ///
      title("Canada", size(medlarge)) ///
      xlabel(#8, format(%tdMonCCYY) angle(45)) ///
      ytitle("Rt") xtitle("") ///
      graphregion(color(white)) plotregion(lcolor(none))
		   
   graph save ${results}/canada_epiestim_kernel_rectangle, replace	
}

*2. Provinces: Merge Epiestim with Kernels
{
 *Import excel and saving in dta
  forvalues x = 1/13 {	 
  import excel "${results}/r_prov_epiestim_`x'.xlsx", ///
         sheet("Sheet1") firstrow clear  

  rename MeanR r_epiestim_`x'
  generate id  = t_end
  save ${results}/r_prov_epiestim_`x'.dta, replace
  }
  
 *Make graphs
  use ${data}/province_rt, clear
  forvalues x = 1/13 {	
  joinby id using ${results}/r_prov_epiestim_`x', unm(b)
  tab _merge
  drop _merge
   	
    twoway (line r_rectangle_`x'_am    date if province == `x') || ///  
		   (line r_epiestim_`x'        date if province == `x')  || ///
		    , title("province = `x'") 
	   
   graph save ${results}/province_epiestim_kernel_rect_`x', replace
  }
}

*3. Health Regions: Merge Epiestim with Kernels
{
 *Import excel and saving in dta
  forvalues x = 1/99 {	 
  import excel "${results}/r_region_epiestim_`x'.xlsx", ///
         sheet("Sheet1") firstrow clear  
 
  rename MeanR r_epiestim_`x'
  generate id = t_end
  save ${results}/r_region_epiestim_`x'.dta, replace
  }
  
 *Make graphs	
  use ${data}/region_rt, clear
  forvalues x = 1/99 {	
  joinby id using ${results}/r_region_epiestim_`x', unm(b)
  tab _merge
  drop _merge
   	
    twoway (line r_rectangle_`x'_am    date if  hr == `x') || ///    
		   (line r_epiestim_`x'        date if  hr == `x') || ///
		    , title("hr = `x'") 
	   
   graph save ${results}/region_epiestim_kernel_rect_`x', replace
  }
}
