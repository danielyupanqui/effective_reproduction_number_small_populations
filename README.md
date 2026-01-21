# A Simplified Approach for Estimating the Effective Reproduction Number in Small Populations

Charles Plante and I have develop a methodology for estimating daily reproduction numbers of infectious diseases in small population areas by focusing on the growth rate defined by the SIR model. The daily growth rate of COVID-19 is estimated using non-parametric kernel regression for Canada at the national level, across its provinces and territories, and within 99 health regions, and these estimates are compared directly with those produced by EpiEstim. Our results show that kernel regression yields smoother and more reliable growth-rate estimates in both large and small populations, particularly in settings with sparse or volatile case data. Consequently, our approach produces more stable and robust daily reproduction-number estimates in small population areas than EpiEstim. Overall, the findings indicate that standard methods often rely on assumptions that do not hold in low-incidence settings, and that non-parametric kernel regression offers a more consistent framework for estimating disease spread across heterogeneous population sizes.

## Instructions

1. Download the data and code from this GitHub repository.

2. Save the project folder in any location on your computer.

3. Open **Stata**.

4. In Stata, open [**run_all.do**](https://github.com/danielyupanqui/effective_reproduction_number_small_populations/blob/main/run_all.do):
   - Double-click the file, or  
   - Use **File → Open**

5. Run the pipeline by typing: do run_all.do
