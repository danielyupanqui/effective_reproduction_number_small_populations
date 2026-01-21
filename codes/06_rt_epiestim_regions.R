 #Title:          Calculation of Covid19 Rt for regions using Epiestim
 #Task:           Calculate Rt using parametric Epiestim package
 #Author:         Daniel Yupanqui
 #Initial update: 29/03/2025
 #Last update:    14/01/2026

 #Imports packages
  library(readxl)
  library(EpiEstim)
  library(writexl)

 #Loop through hr_1 to hr_99
  for (i in 1:99) {
    sheet_name <- paste0("hr_", i)  # Construct sheet name
  
 #Try reading the sheet
  if (!sheet_name %in% excel_sheets("data/regions_rt.xlsx")) {
    cat("Skipping:", sheet_name, " (Sheet not found)\n")
    next
  }
  
  cat("Processing:", sheet_name, "\n")  # Print progress
  
 #Load the dataset
  data <- read_excel("data/regions_rt.xlsx", sheet = sheet_name)
  
 #Check if 'new_cases' exists
  if (!"new_cases" %in% colnames(data)) {
    cat("Skipping:", sheet_name, " (No 'new_cases' column)\n")
    next
  }
  
 #Ensure new_cases is numeric and replace NAs
  data$new_cases <- as.numeric(data$new_cases)
  data$new_cases[is.na(data$new_cases)] <- 0
  
 #Ensure incid is a data frame
  incid <- data.frame(I = data$new_cases)
  
 #Check if incid has valid cases
  if (sum(incid$I) == 0) {
    cat("Skipping:", sheet_name, " (All cases are zero)\n")
    next
  }
  
 #Estimate R
  R_si_parametric <- estimate_R(
    incid = incid,
    method = "parametric_si",
    config = make_config(
      mean_si = 5.2,
      std_si = 5.1
    )
  )
  
 #Extract and save results
  new_data <- as.data.frame(R_si_parametric$R)
  output_filename <- paste0("results/r_region_epiestim_", i, ".xlsx")
  write_xlsx(new_data, output_filename)
  
  cat("Saved results for", sheet_name, "->", output_filename, "\n")
 }

  cat("Processing complete!\n")
