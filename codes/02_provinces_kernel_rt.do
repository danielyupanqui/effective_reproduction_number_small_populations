/*******************************************************************************
  Title:          Methodology for the calculation of Covid19 Waves in Canada
  Task:           Calculate Reproduction Numbers with Nonparametric Kernel
                  Regressions by Provinces.
  Author:         Daniel Yupanqui
  Created:        2025/03/29
  Last update:    2026/01/06
*******************************************************************************/

*1. Import data
{
 *Import the dta file
  use ${data}/local_covid_cases, clear	
}

*2. Prepare data
{
 *Date format 
  gen date = date(date_report, "YMD")
  format date %td
  drop date_report

 *Encode health region names
  encode prov, gen(province_code)

 *Sort
  sort province_code date
  
 *Provincial level
  collapse(sum) cases (max) pop, by(province_code prov date)
 
 *Cumulative cases
  bys province_code: generate cumulative_cases = sum(cases)
 
 *Create the New Cases variable
  sort   province_code date
  bysort province_code: generate new_cases = cumulative_cases[_n] -    ///
                                             cumulative_cases[_n  - 1]
}
		
*4. Select the appropriate range for analysis
{
 *Clean up of lagged variables at the beginning of the series  
   keep if inrange(date, td(01mar2020), td(30nov2021))
}

*6. Active cases Arroyo-Marioli
{
 /*
   Active cases calculation according to equation (4), where:
   
     I_t = (1 - gamma) * I_t-1 + new_cases_t
   
  "We initialize I_t by I_0 = C_0 where C_0 is the total number 
   of infectious cases at some initial date, and then construct 
   subsequent values of I_t recursively."
 */
  
 *I_0 = C_0
  bysort   province_code: generate id = _n 
  generate cases_am = cases if id == 1
  replace  cases_am = (1 - $gamma) * cases_am[_n-1] + new_cases if id != 1  
}

*7. Calculate the growth rate of infectious cases
{
 *Calculate growth rate using difference in logs 
  bysort province_code: generate growth_rate_am = ln(cases_am[_n]) - ///
                                                  ln(cases_am[_n-1])		
  replace  growth_rate_am = 0 if missing(growth_rate_am)
}

*9. Parametric Kernel Estimation and Reproduction Number over provinces
{
 /*
   Reproduction number according to equation (3), where:
   
     Rt = 1 + 1/gamma * growth_rate_I_t
   
   I_t was calculated in Section 6 of this do-file.
   The growth rate of I_t is estimated in this section 
   using a kernel regression smoother.
 */
    
 *Sort data
  sort province_code date

 *Non Parametric Kernel Estimation - All type
  foreach x in epanechnikov ///
               epan2        ///
			   biweight     ///    
			   cosine       ///
			   gaussian     ///
			   parzen       ///
			   rectangle    ///
			   triangle { 
  
  forvalues    y=1/13   { 	
  
  npregress    kernel growth_rate_am date if province == `y', ///
               predict(mean_am`x'_`y' deriv_am`x'_`y')        ///
               kernel(`x') 
 
 *Reproduction Number
  generate r_`x'_`y'_am = 1 + (1/$gamma)*mean_am`x'_`y'
 
  }
  }
 
 *Save Rt in dta abd xlsx
  save ${data}/province_rt, replace
  
  forvalues y = 1/13 {
    use province_code date cases new_cases if province_code == `y'         ///
	    using ${data}/province_rt, clear 	 
	  
	   *To be used in R to run EpiEstim
	    export excel using "${data}/provinces_rt.xlsx",                    ///
               sheet("prov_`y'") firstrow(variables) sheetreplace
	}
}

*10. Graphs per province 
{
 *Import dta
  use ${data}/province_rt, clear
  
 *Loop to make provincial graphs 
  forvalues    y=1/13   {
	
    twoway (line r_epanechnikov_`y'_am date if province == `y') || ///  
           (line r_epan2_`y'_am        date if province == `y') || ///  
    	   (line r_biweight_`y'_am     date if province == `y') || ///  
    	   (line r_cosine_`y'_am       date if province == `y') || ///  
    	   (line r_gaussian_`y'_am     date if province == `y') || ///  
    	   (line r_parzen_`y'_am       date if province == `y') || ///  
    	   (line r_rectangle_`y'_am    date if province == `y') || ///  
    	   (line r_triangle_`y'_am     date if province == `y')    ///  
		    , title("province = `y'") 
	   
	graph save ${results}/province_`y'_allkernels_am, replace
  }
}	  

