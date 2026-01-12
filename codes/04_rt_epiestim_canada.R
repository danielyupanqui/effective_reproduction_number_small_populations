 #Title:          Calculation of Covid19 Rt for Canada using Epiestim
 #Task:           Calculate Rt using parametric Epiestim package
 #Author:         Daniel Yupanqui
 #Initial update: 29/03/2025
 #Last update:    30/12/2025

 #Imports packages
  library(readxl)
  library(EpiEstim)
  library(writexl)

 #Relative paths from project root
  data_file   <- "data/canada_rt.xlsx"
  output_file <- "results/rt_epiestim_canada.xlsx"

 #Load data
  data <- read_excel(data_file)

 #Validate column
  if (!"new_cases" %in% names(data)) {
    stop("Column 'new_cases' not found.")
  }

  data$new_cases <- as.numeric(data$new_cases)
  data$new_cases[is.na(data$new_cases)] <- 0
  incid <- data.frame(I = data$new_cases)
 
 #Estimate R
  R_si_parametric <- estimate_R(
    incid = incid,
    method = "parametric_si",
    config = make_config(mean_si = 5.2, std_si = 5.1)
  )

 #Save output
  write_xlsx(as.data.frame(R_si_parametric$R), output_file)
  cat("Saved to:", output_file, "\n")
