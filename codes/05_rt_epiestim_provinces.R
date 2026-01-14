 #Title:          Calculation of Covid19 Rt for provinces using Epiestim
 #Task:           Calculate Rt using parametric Epiestim package
 #Author:         Daniel Yupanqui
 #Initial update: 29/03/2025
 #Last update:    30/12/2025

 #Imports packages
  library(readxl)
  library(EpiEstim)
  library(writexl)

 #Relative paths from project root
  data_file   <- "data/provinces_rt.xlsx"
  results_dir <- "results"
  output_file <- "results/r_prov_epiestim.xlsx"
  
 #Get sheet names once (faster + cleaner)
  sheets <- excel_sheets(data_file)
  
 #Loop through provinces 1 to 13
  for (i in 1:13) {
    sheet_name <- paste0("prov_", i)
    
   #Check sheet exists
    if (!sheet_name %in% sheets) {
      cat("Skipping:", sheet_name, " (Sheet not found)\n")
      next
    }
    
    cat("Processing:", sheet_name, "\n")
    
   #Load the dataset
    data <- read_excel(data_file, sheet = sheet_name)
    
   #Check if 'new_cases' exists
    if (!"new_cases" %in% colnames(data)) {
      cat("Skipping:", sheet_name, " (No 'new_cases' column)\n")
      next
    }
    
   #Clean new_cases
    data$new_cases <- as.numeric(data$new_cases)
    data$new_cases[is.na(data$new_cases)] <- 0
    incid <- data.frame(I = data$new_cases)
    
    if (sum(incid$I) == 0) {
      cat("Skipping:", sheet_name, " (All cases are zero)\n")
      next
    }
    
   #Estimate R
    R_si_parametric <- estimate_R(
      incid = incid,
      method = "parametric_si",
      config = make_config(mean_si = 5.2, std_si = 5.1)
    )
    
   #Save results
    output_filename <- file.path(results_dir, paste0("r_prov_epiestim_", i, ".xlsx"))
    write_xlsx(as.data.frame(R_si_parametric$R), output_filename)
    
    cat("Saved results for", sheet_name, "->", output_filename, "\n")
  }