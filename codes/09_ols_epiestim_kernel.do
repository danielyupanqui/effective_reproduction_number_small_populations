/*
  Title:          Elasticity of Rt Variability with Respect to Active Cases
  Task:           Regression and Visualization for Provinces and Health Regions 
  Author:         Daniel Yupanqui
  Initial update: 10/12/2025
  Last update:    10/12/2025
*/

*0. Set up
{
  clear all
  cd "/Users/camila/Documents/daniel_yupanqui/work/covid_waves"
}

*1. Load and prepare provincial data
{
  use ${results}/stats_provinces, clear
  
 *Run regression and extract elasticity
  regress cv_ratio cases_mean

 *Store elasticity (slope)
  local slope : display %10.4f _b[cases_mean]

 *Compute fitted values
  predict yhat if e(sample)

 *Pick the maximum X for placing text
  summarize cases_mean
  local xmax = r(max)

 *Compute corresponding Yhat for label
  local ymax = _b[_cons] + _b[cases_mean] * `xmax'
}

*2. Provincial Graph: scatter + linear fit + elasticity text label
{	
  twoway                                                           /// 
        /// Scatter plot      
        (scatter cv_ratio cases_mean,                              ///
             mcolor(blue%40) msymbol(Oh) msize(medium))            ///
                                                                   ///
        /// Linear fitted line      
        (lfit cv_ratio cases_mean,                                 ///
             lcolor(red) lwidth(medthick))                         ///
                                                                   ///
        ,                                                          ///
        /// Axis titles
        xtitle("Mean Active Cases", size(medlarge))                ///
        ytitle("Rt Variability (CV Ratio)", size(medlarge))        ///
                                                                   ///
        /// Title and graph style
        title("Rt Variability with Respect to Case Incidence",     ///
               size(large))                                        ///
        graphregion(color(white))                                  ///
        plotregion(lcolor(none))                                   ///
        ylabel(, angle(horizontal))                                ///
                                                                   ///
        /// Add elasticity annotation
        text(`ymax' `xmax' "Slope = `slope'",                      ///
             color(red) size(medlarge) place(e))
}

*3. Load and prepare regions data
{
  use ${results}/stats_regions, clear
  
 *Run regression and extract elasticity
  regress cv_ratio cases_mean

 *Store elasticity (slope)
  local slope : display %10.4f _b[cases_mean]

 *Compute fitted values
  predict yhat if e(sample)

 *Pick the maximum X for placing text
  summarize cases_mean
  local xmax = r(max)

 *Compute corresponding Yhat for label
  local ymax = _b[_cons] + _b[cases_mean] * `xmax'
}

*4. Provincial Graph: scatter + linear fit + elasticity text label
{	
  twoway                                                            /// 
        /// Scatter plot   
        (scatter cv_ratio cases_mean,                               ///
             mcolor(blue%40) msymbol(Oh) msize(small))              ///
                                                                    ///
        /// Linear fitted line   
        (lfit cv_ratio cases_mean,                                  ///
             lcolor(red) lwidth(med))                               ///
                                                                    ///
        ,                                                           ///
        /// Axis titles   
        xtitle("Daily mean of active cases", size(med))             ///
        ytitle("CV Ratio", size(med))                               ///
                                                                    ///
        /// Graph style   
        graphregion(color(white))                                   ///
        plotregion(lcolor(none))                                    ///
        ylabel(, angle(horizontal))                                 ///
                                                                    ///
        /// Legend labels   
        legend(label(1 "CV Ratio") label(2 "Fitted values"))        ///
                                                                    ///
        /// Add slope annotation   
        text(`ymax' `xmax' "Slope = `slope'",                       ///
             color(red) size(medlarge) place(e))
}
