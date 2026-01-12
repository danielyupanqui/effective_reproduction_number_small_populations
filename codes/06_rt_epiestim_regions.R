 #Title:          Calculation of Covid19 Rt for regions using Epiestim
 #Task:           Calculate Rt using parametric Epiestim package
 #Author:         Daniel Yupanqui
 #Initial update: 29/03/2025
 #Last update:    30/12/2025

 #Imports packages
  library(readxl)
  library(EpiEstim)
  library(writexl)

 #Relative paths from project root
  data_file   <- "data/regions_rt.xlsx"
  results_dir <- "results"
  output_file <- "results/rt_epiestim_regions.xlsx"

 #Create results folder if needed
  if (!dir.exists(results_dir)) dir.create(results_dir)

 #Get sheet names once (faster + cleaner)
  sheets <- excel_sheets(data_file)

 #Loop through hr_1 to hr_99
  for (i in 1:99) {
    sheet_name <- paste0("hr_", i)
    
   #Check sheet exists
    if (!sheet_name %in% sheets) {
      cat("Skipping:", sheet_name, "(Sheet not found)\n")
      next
  }
    
 #Load data
  data <- read_excel(data_file, sheet = sheet_name)
    
 #Validate column
  if (!"new_cases" %in% names(data)) {
    cat("Skipping:", sheet_name, "(No 'new_cases' column)\n")
    next
  }
    
 #Clean values
  data$new_cases <- as.numeric(data$new_cases)
  data$new_cases[is.na(data$new_cases)] <- 0
  incid <- data.frame(I = data$new_cases)
    
 #Skip if no cases
  if (sum(incid$I) == 0) {
    cat("Skipping:", sheet_name, "(All cases are zero)\n")
    next
  }
    
   #Estimate Rt
    R_si_parametric <- estimate_R(
      incid  = incid,
      method = "parametric_si",
      config = make_config(mean_si = 5.2, std_si = 5.1)
    )
    
   #Save output
    output_file <- file.path(results_dir, paste0("r_epiestim_", i, ".xlsx"))
    write_xlsx(as.data.frame(R_si_parametric$R), output_file)
    
    cat("Saved:", output_file, "\n")
  }