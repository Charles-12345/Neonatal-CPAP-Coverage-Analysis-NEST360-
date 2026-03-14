# Setting up the environment

install.packages(c("readxl","dplyr","tidyr","lubridate","ggplot2","writexl","scales"))

# Loading libraries

library(readxl)
library(dplyr)
library (tidyr)
library(lubridate)
library(ggplot2)
library(writexl)

# Saving Data file (NID.) before loading for operation

setwd("C:\\Users\\DANIEL\\Desktop\\DATA MANAGER")
getwd()
raw <- read_excel("NID.xlsx")

list.files()
raw <- read_excel("NID.xlsx")   
list.files(pattern = "xlsx")
#Verifying ater loading the file
#Reading the Excel file

nrow(raw)      # number of rows
ncol(raw)      # number of columns
glimpse (raw)  # columns types and first values
head (raw,10)  # first 10 rows

#SECTION A-DQA

# ASSESSING COMPLETENESS

df<- raw %>%
   mutate(
     in_doa = as.Date (in_doa),          # Admission date
     in_dob = as.Date (in_dob),          # Date of birth
     in_dis_dod = as.Date (in_dis_dod)   # Discharge date
   )
# Testing if conversion has worked
class(df$in_doa) # should reflect 'Date'
   
class(df$in_dob) # should reflect 'Date'

class(df$in_dis_dod) # should reflect 'Date'

# CHECKING FOR MISSING VALUES PER COLUMN

missing_summary <- df %>%
  summarise(
    across(everything (),
           list(n_miss = ~ sum(is.na(.)),
           pct_miss = ~ round(mean(is.na(.)) * 100, 2)))
)%>%
tidyr::pivot_longer(
  everything(),
  names_to = c("variable", '.value'),
  names_sep = "_(?=[^_]+$)"
)
print(missing_summary)

#FLAGGING QUALITY ISSUES
df <- df %>%
  mutate(
    # Flag 1: Birthweight outside neonatal range (100-6000 g) 
    flag_bwt_range = case_when(
      is.na(in_bwt)         ~ NA,
      in_bwt <100 | in_bwt > 6000 ~ TRUE,
      TRUE                        ~ FALSE
    ),
    # Flag 2: Admission weight outside range (100-6000 g)
    flag_adnwt_range = case_when (
    is.na(in_admwt)                  ~NA,
    in_admwt <100 | in_admwt > 6000  ~TRUE,
    TRUE                             ~ FALSE
    ),
    # Flag 3: Admission weight > birth weight
      flag_admwt_gt_bwt = case_when(
        is.na(in_admwt) | is.na(in_bwt)  ~ NA,
        in_admwt > in_bwt               ~ TRUE,
        TRUE                            ~ FALSE
      ),
    # Flag 4: Discharge date before admission date
    flag_dis_before_adm = case_when(
      is.na(in_dis_dod) | is.na(in_doa) ~ NA,
      in_dis_dod < in_doa               ~TRUE,
      TRUE                             ~ FALSE
    
    ),
    # Flag 5: Discharge date before admission date
    flag_adm_before_dob = case_when(
      is.na(in_doa) | is.na(in_dob)  ~ NA,
      in_doa < in_dob               ~ TRUE,
      TRUE                          ~ FALSE
    ),
    # Flag 6: Discharge date of birth (impossible)
    flag_dis_before_dob = case_when (
      is.na(in_dis_dod) | is.na (in_dob)  ~ NA,
      in_dis_dod < in_dob                 ~ TRUE, 
      TRUE                               ~ FALSE
    )
  )

# SUMMARY OF FLAGS

flag_vars <- names(df)[grepl("^flag_", names(df))]

flag_summary <- df %>%
  summarise(
    across(all_of(flag_vars),
           list(n  = ~ sum(.,na.rm = TRUE),
                pct = ~ round(mean(., na.rm = TRUE) * 100, 2)))
  ) %>%
  tidyr::pivot_longer(
    everything(),
    names_to = c("flag",".value"),
    names_sep = "_(?=[^_]+$)"
    )
print(flag_summary)

# SECTION B :Derrived Variables

df<-df %>%
  mutate(
    age_at_adm = if_else(
      # If flag_adm_before_dob is TRUE, the value is impossible
      !is.na(flag_adm_before_dob) & flag_adm_before_dob == TRUE,
      NA_real_,
      as.numeric(in_doa-in_dob) # difference in days
    )
  )
summary (df$age_at_adm) # check min/max/mean

# Lentgh of Stay (Or Number of Days) =dicharge date minus admission date
df <-df %>%
  mutate(
    los = if_else(
      !is.na(flag_dis_before_adm) & flag_dis_before_adm == TRUE,
      NA_real_,
      as.numeric(in_dis_dod-in_doa)
    )
)
  summary(df$los)
  
  # WEITGH Catgory Variables
  
  weight_breaks <- c(0, 999, 1499,1999, Inf)
  weight_labels <- c("<1000g","1000-1499","1500-1999g",">=2000g")
  df <- df %>%
    mutate(
      # Birthweight category
      bwt_cat = cut (
      in_bwt,
      breaks                       = weight_breaks,
      labels                       = weight_labels, 
      right                        = TRUE,
      include.lowest               = TRUE
      ),
      # Admission weight category
      admwt_cat = cut(
        in_admwt,
        breaks                   = weight_breaks,
        labels                   = weight_labels,
        riGht                    = TRUE,
        include.lowest           = TRUE
      )
    )
  # Check distributions
  table (df$bwt_cat, useNA = 'ifany')
  table(df$admwt_cat,useNA = 'ifany')
  
  # SECTION C, DESCRIPTIVE ANALYIS 
  
  # Overall Summary Data
  # Total Admission
  cat('Total admission: ',nrow(df),'\n')
  #Median birthweight with IQR
  cat(sprintf("Median BWT: %.0f g(IQR: %.0f-%.0f g)\n",
              median(df$in_bwt, na.rm = TRUE),
              quantile(df$in_bwt, 0.25,na.rm = TRUE),
              quantile(df$in_bwt, 0.75, na.rm = TRUE)))

# Median length of stay with IQR
cat(sprintf("Median LOS: %.0f days (IQR: %.0f-%.0f days\n",
             median(df$los, na.rm = TRUE),
             quantile(df$los, 0.25, na.rm = TRUE),
             quantile(df$los,0.75, na.rm =TRUE)))

# CPAP proportion ( exclude missing in_cp_admin from denominator)
n_cpap_known <- sum(!is.na(df$in_cp_admin))
n_cpap_yes <- sum(df$in_cp_admin == 1, na.rm = TRUE)
cat(sprintf("CPAP proportion: %d / %d (%.1f%%)\n",
             n_cpap_yes, n_cpap_known,
             n_cpap_yes / n_cpap_known * 100))
          
# Varriable for CPAP Aanalysis 
df <- df %>%
  mutate(
   # Primary: admission weight; fallback: birthweight
    weight_for_cpap = if_else(!is.na(in_admwt), in_admwt, in_bwt),
   # Track which source was used (useful for reporting)
   weight_source = case_when(
     !is.na(in_admwt) ~ 'admission_weight',
     !is.na(in_bwt)   ~ 'birthweight_substituted',
     TRUE             ~ NA_character_
   ),
   # Flag records in the 1000-1499 g hand
   wt_1000_1499 = weight_for_cpap >= 1000 & weight_for_cpap <= 1499
  )
# How many used birthweight as sustitutes?
table(df$weight_source, useNA = 'ifany')

# Calcculated CPAP Coverage for the 1000-1499 g band
cpap_overall <- df %>%
  filter(wt_1000_1499 == TRUE, !is.na(in_cp_admin)) %>%
  summarise(
    denominator = n(),
    numerator = sum(in_cp_admin == 1),
    coverage_pct = round(numerator/denominator * 100, 1)
  )
print(cpap_overall)
  
#CALCULATED CPAP COVERAGE BY HOSITAL

cpap_overall <- df %>%
  filter(wt_1000_1499 == TRUE, !is.na (in_cp_admin)) %>%
  summarise(
    denominator = n(),
   numerator = sum(in_cp_admin == 1),
    coverage_pct = round (numerator/denominator * 100, 1)
  )
print(cpap_overall)

# CPAP COVERAGE BY HOSPITAL
cpap_by_hosp <- df %>%
  filter (wt_1000_1499 == TRUE, !is.na(in_cp_admin)) %>%
  group_by(hosp_id) %>%
  summarise(
    denominator = n(),
    numerator   = sum(in_cp_admin == 1),
    coverage_pct = round(numerator/denominator * 100, 1),
    .groups = 'drop'
  ) %>%
  arrange(desc(coverage_pct))
print(cpap_by_hosp, n = Inf) # show all hospitals
  
  # SECTION D: TARGET SETTING-BASELINE -2028 TARGETS

#Add admission year using lubricate
df<-df%>%
  mutate(adm_year = year(in_doa))
# Check what years are present in the data
table ( df$adm_year)

# CALCULATING 2025 BASELINE CPAP COVERAGE PER HOSPITAL
baseline_2025 <- df %>%
  filter(
    adm_year == 2025,      # 2025 records only
    wt_1000_1499 == TRUE,  # WEIGHT BAND 1000-1499 g
    !is.na(in_cp_admin)   # exclude missing CPAP
  ) %>%
  group_by(hosp_id) %>%
  summarise(
    baseline_denom = n(),
    baseline_num    = sum(in_cp_admin == 1),
    baseline_coverage = round(baseline_num/baseline_denom * 100, 1),
    .groups   = 'drop'
  ) %>%
  arrange(hosp_id)
print(baseline_2025)

# 2028 TARGET SETTING USING BENCHMARKING + EQUITY METHOD
# The target-setting logic uses four rules applied in order:
# •	75th percentile of 2025 hospital coverage = achievable benchmark (reflects what top peers already do)
# •	Equity boost: hospitals below 30% receive +30 percentage points to accelerate catch-up
# •	60% minimum floor — no hospital should target less than this
# •	95% ceiling — clinically realistic maximum (some neonates have contraindications to CPAP)

# Step 1: Calculate the benchmark (75th percentile of 2025 coverage)
p75<-quantile(baseline_2025$baseline_coverage, 0.75, na.rm = TRUE)
cat ('75th percentile benchmark: ',p75, '%\n')
# Step2-4: Apply target logic
targets<-baseline_2025 %>%
  mutate(
    raw_target = case_when(
    baseline_coverage < 30 ~ pmin (baseline_coverage + 30, 95), # equity boost
      TRUE                  ~ pmin(p75, 95)
    ),
    # Appply floor of 60%
    target_2028 = pmax (raw_target, 60),
    # Apply ceiling of 95%
    target_2028 = pmin(target_2028, 95),
    # Metrics for monitoring
    abs_improvement  = round(target_2028-baseline_coverage, 1),
    monthly_improvement = round (abs_improvement/36, 2) # 36 months
  ) %>%
  select(hosp_id, baseline_denom, baseline_num,
         baseline_coverage, target_2028,
         abs_improvement, monthly_improvement)
print (targets, n = Inf)

# DATA VISUALIZATION-Baseline vs 2028 TARGET
# Reshap to long format for plotting
plot_data<- targets %>%
  tidyr::pivot_longer(
    cols = c(baseline_coverage,target_2028),
    names_to = "time_point", # avoid the lubridate clash
    values_to = "coverage"
  ) %>%
  mutate(
  time_point = recode(.data$time_point,
  baseline_coverage =  "2025 Baseline",
  target_2028       =  "Dec 2028 Target"), 
  time_point       = factor(time_point,
                            levels = c("2025 Baseline", "Dec 2028 Target")),
  hosp_id = factor(hosp_id)
  )
# Dot-and-line plot
ggplot(plot_data,
       aes(x      = coverage,
          y = reorder(hosp_id, coverage),
          colour = time_point,
          shape  = time_point)) +
  geom_line(aes(group = hosp_id), colour = 'grey70', linewidth = 0.8) +
  geom_point(size = 3) +
  scale_colour_manual(
  values = c('2025 Baseline' = '#E07B39',
          'Dec 2028 Target'= '#2F6690')
  ) +
  scale_shape_manual(
  values = c('2025 Baseline' = 16,
             'Dec 2028 Target' = 17) 
)+
  labs(
    title  = 'CPAP Coverage (1000_1499g): 2025 Baseline vs Dec 2028 Target',
    x      = 'CPAP Coverage (%)',
    y      = 'Hospital ID',
    colour = NULL, shape = NULL
    ) +
    theme_minimal(base_size = 12) +
    theme(legend.position = 'top')
    ggsave('NESTO360_targets_plot.png', width = 9, height = 6, dpi = 150)
          
# CPAP Coverage Distribution Histogram

hist_plot<-ggplot(cpap_by_hosp,
                  aes(x = coverage_pct)) +
  geom_histogram(
    binwidth = 5,
    fill = "#2F6690",
    colour = "white",
    alpha = 0.9
  )+
  geom_vline(
    aes(xintercept = mean(coverage_pct, na.rm = TRUE)),
    Color = "#E07B39",
    linewidth = 1,
    linetype = "dashed"
  ) +
  labs(
    title = "Distribution of CPAP Coverage Across Hospitals",
    subtitle = "Coverage among neonates weighing 1000-1499 g",
    x = "CPAP Coverage (%)",
    y = "Number of Hospitals"
  )+
  theme_minimal(base_size = 12)
hist_plot

# Save figure
ggsave ("CPAP_Covergae_historgram.png",
        hist_plot,
        with = 8,
        height = 5,
        dpi = 150)

# Hospital Performance Ranking Plot

ranking_plot<- ggplot(cpap_by_hosp,
                     aes(x = reorder(hosp_id, coverage_pct),
                         y = coverage_pct))+
  geom_col(fill = "#2F6690") +
  
  geom_text (
    aes(label = paste0(coverage_pct, "%")),
    hjust = -0.2,
    size = 3
  ) +
  coord_flip() +
  labs(
    title = "Hospital Ranking by CPAP Coverage",
    subtitle =  "Coverage among neonates weighing 1000-1499 g",
    x = "Hospital ID",
    y = "CPAP Coverage (%)"
  ) +
  expand_limits(y = 100) +
  theme_minimal(base_size = 12)

ranking_plot

# Save figure
ggsave("CPAP_hospital_ranking.png",
       ranking_plot,
       width = 9,
       height = 6,
       dpi = 150)

# EXPORTING ALL OUTPUTS TO EXCEL
write_xlsx(
  list(enriched_data = df,
       dg_flags      = flag_summary,
       cpap_by_hosp =  cpap_by_hosp,
       target_2028 = targets
  ),
  path = 'NEST360_outputs.xlsx'
)
cat("All don.outputs saved to NEST360_outputs.xlsx\n")




