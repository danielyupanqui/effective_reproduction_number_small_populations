/*******************************************************************************
  Title:           Methodology for the calculation of Covid19 Waves in Canada
  Task:            Calculate Reproduction Numbers with Nonparametric Kernel
                   Regressions for all health regions
  Author:          Daniel Yupanqui
  Created:         2025/03/03
  Last update:     2026/01/06
*******************************************************************************/

*1. Import data
{
 *Import the dta file
  use ${data}/local_covid_cases, clear	
}

*2. Prepare data
{
 *Date format 
  generate date = date(date_report, "YMD")
  format   date %td
  drop     date_report

 *Encode health region names
  encode hrname, gen(hr)

 *Sort
  sort prov hr date
  
 *Region level
  collapse(sum) cases (max)pop, by(hr date)

 *Cumulartive cases
  sort   hr date
  bysort hr: generate cumulative_cases = sum(cases) 
  
 *Create the New Cases variable
  bysort hr: generate new_cases = cumulative_cases[_n] -    ///
                                  cumulative_cases[_n  - 1]
}

*3. Select the appropriate range for analysis
{
 *Clean up of lagged variables at the beginning of the series  
   keep if inrange(date, td(01mar2020), td(30nov2021))
}

*4. Active cases Arroyo-Marioli
{
 /*Active cases calculation according to equation (4), where:
   
   I_t = (1 - gamma) * I_t-1 + new_cases_t
   
  "We initialize I_t by I_0 = C_0 where C_0 is the total number 
   of infectious cases at some initial date, and then construct 
   subsequent values of I_t recursively."
 */
  
 *I_0 = C_0
  bysort   hr: generate id = _n 
  generate cases_am = cases if id == 1
  replace  cases_am = (1 - $gamma) * cases_am[_n-1] + new_cases if id != 1  
} 

*5. Calculate the growth rate of infectious cases
{
 *Calculate growth rate using difference in logs 
  bysort  hr: generate growth_rate_am = ln(cases_am[_n]) - ///
                                        ln(cases_am[_n-1])		
  replace growth_rate_am = 0 if missing(growth_rate_am)
}

*6. Non Parametric Kernel Estimation and Reproduction Number over regions
{
 *Sort data
  sort hr date
 
 *Non Parametric Kernel Estimation - All types
  foreach x in epanechnikov ///
               epan2        ///
			   biweight     ///    
			   cosine       ///
			   gaussian     ///
			   parzen       ///
			   rectangle    ///
			   triangle {
    forvalues y = 1/99 { 		   	
      npregress kernel growth_rate_am date if hr == `y',                 ///
	            predict(mean_am_`x'_`y' deriv_am_`x'_`y')                ///
				kernel(`x')
      
 *Reproduction Number
  generate r_`x'_`y'_am = 1 + (1/$gamma)*mean_am_`x'_`y'
 }
 }
 
 *Save Rt dta and xlsx
  save ${data}/region_rt, replace
  
  forvalues y = 1/99 {
	 use hr date cases new_cases if hr == `y'                           ///
	     using ${data}/region_rt, clear
	  
	  *To be used in R to run EpiEstim
	   export excel using "${data}/regions_rt.xlsx",                    ///
              sheet("hr_`y'") firstrow(variables) sheetreplace
	}
}

*7. Graphs for both types of Rt
{
 *Import dta 
  use ${data}/region_rt, clear
  
 *Loop over health regions	 
  forvalues x=1/99 { 
	
    twoway (line r_epanechnikov_`x'_am date if hr == `x') || ///  
           (line r_epan2_`x'_am        date if hr == `x') || ///  
    	   (line r_biweight_`x'_am     date if hr == `x') || ///  
    	   (line r_cosine_`x'_am       date if hr == `x') || ///  
    	   (line r_gaussian_`x'_am     date if hr == `x') || ///  
    	   (line r_parzen_`x'_am       date if hr == `x') || ///  
    	   (line r_rectangle_`x'_am    date if hr == `x') || ///  
    	   (line r_triangle_`x'_am     date if hr == `x')    ///  
		    , title("hr = `x'") 
	
	graph save ${results}/region_`x'_allkernels_am, replace
}
}  

