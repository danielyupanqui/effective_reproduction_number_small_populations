 #Title:          Calculation of Covid19 Rt for Canada using Epiestim
 #Task:           Calculate Rt using parametric Epiestim package
 #Author:         Daniel Yupanqui
 #Initial update: 29/03/2025
 #Last update:    30/12/2025

 #Install packages
  options(repos = c(CRAN = "https://cloud.r-project.org"))
  install.packages("readxl")
  install.packages("EpiEstim")
  install.packages("writexl")


 #Imports packages
  library(readxl)
  library(EpiEstim)
  library(writexl)

 #Relative paths from project root
  data_file   <- "data/canada_rt.xlsx"
  results_dir <- "results"
  output_file <- "results/r_canada_epiestim.xlsx"

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

 #Validate Rt output
  if (is.null(R_si_parametric$R) || nrow(R_si_parametric$R) == 0) {
    stop("Rt estimation failed: no results to save.")
  }
  
 #Save output
  write_xlsx(as.data.frame(R_si_parametric$R), output_file)
  cat("Saved to:", normalizePath(output_file), "\n")
  