/*******************************************************************************
  Title:          Methodology for the calculation of Covid19 Rt in Canada
  Task:           Calculate Reproduction Numbers with Nonparametric Kernel
                  Regressions for Canada.
  Author:         Daniel Yupanqui
  Created:        2025/03/03
  Last update:    2026/01/08
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
  format date %td
  drop date_report

 *Encode health region names
  encode hrname, gen(hr)
  
 *Summation of cumulative, total cases by date
  collapse(sum) cases (max) pop, by(date)
 
 *Cumulative cases 
  generate cumulative_cases = sum(cases)
 
 *Create the New Cases variable
  generate new_cases = cumulative_cases[_n] - cumulative_cases[_n - 1]
 
 *tsset the data
  tsset date, daily 
}

*3. Set globals the Infectious Perdiod Rate(in days) for calculating R
{
 /*
   Create a global macro to store .
   
   Gamma   = Transition rate from infectious to recovered   
   1/Gamma = Average infectious period, i.e. on average, how many days 
             an infected person stays infectious. 
 */
 
  global gamma = 1/7

}
		
*4. Select the appropriate range for analysis
{
 *Clean up of lagged variables at the beginning of the series  
   keep if inrange(date, td(01mar2020), td(30nov2021))
}

*5. Active cases Arroyo-Marioli
{
 /*Active cases calculation according to equation (4), where:
   
   I_t = (1 - gamma) * I_t-1 + new_cases_t
   
  "We initialize I_t by I_0 = C_0 where C_0 is the total number 
   of infectious cases at some initial date, and then construct 
   subsequent values of I_t recursively."
 */
  
 *I_0 = C_0
  generate id = _n 
  generate cases_am = cases if id == 1
  replace  cases_am = (1 - $gamma) * cases_am[_n-1] + new_cases if id != 1
}

*6. Calculate the growth rate of infectious cases
{
 *Calculate growth rate using difference in logs 
  generate growth_rate_am = ln(cases_am[_n]) - ln(cases_am[_n-1])		
  replace  growth_rate_am = 0 if missing(growth_rate)
}

*7. Non Parametric Kernel Estimation and Reproduction Number
{
 /*Reproduction number according to equation (3), where:
   
   Rt = 1 + 1/gamma * growth_rate_I_t
   
   I_t was calculated in Section 6 of this do-file.
   The growth rate of I_t is estimated in this section 
   using a kernel regression smoother.
 */
 
 *Sort data
  sort date
  
 *Non Parametric Kernel Estimation 
  foreach x in epanechnikov ///
               epan2        ///
			   biweight     ///    
			   cosine       ///
			   gaussian     ///
			   parzen       ///
			   rectangle    ///
			   triangle {
  npregress kernel growth_rate_am date, predict(mean_am`x' deriv_am`x') ///
            kernel(`x') 
 
 *Reproduction Number
  generate r_`x'_am = 1 + (1/$gamma)*mean_am`x'  
  }
  
 *Save Rt dta and xlsx
  save ${data}/canada_rt, replace
   
   *To be used in EpiEstim
    export excel date cases new_cases                                  ///
	       using "${data}/canada_rt.xlsx",                             ///
           sheet("canada") firstrow(variables) sheetreplace
}	

*9. R vs growth_rates
{
 *Graph for Canada
  sort date
 
    twoway (line r_epanechnikov_am date) ||        ///
           (line r_epan2_am        date) ||        ///
    	   (line r_biweight_am     date) ||        ///
    	   (line r_cosine_am       date) ||        ///
    	   (line r_gaussian_am     date) ||        ///
    	   (line r_parzen_am       date) ||        ///
    	   (line r_rectangle_am    date) ||        ///
    	   (line r_triangle_am     date)
		   
	graph save ${results}/canada_allkernels_am, replace
}




