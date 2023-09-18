clear all
set more off

capture log close

cd "C:\Users\poppa\Desktop\bmi_08.09\BMI"
use "pheno_bmi.dta", clear

gen regression = "phenotypic"
drop if df_m != 46

append using mr_bmi_unrel.dta
append using mr_bmi_unrel_PCs.dta
duplicates drop
append using mr_bmi_wf.dta

append using mr_bmi_wf_PCs.dta
duplicates drop

keep coef stderr pval N cmdline  depvar df_m regression

save bmi_8yrs_results.dta, replace

drop cmdline
sort depvar

// Computing standard confidence intervals:
gen lower_ci = coef - 1.96*stderr
gen upper_ci = coef + 1.96*stderr

browse

// Computing Bonferroni confidence intervals:
local g = 2
local df = df_m
local alpha = 0.05
local t_value = invttail(`df', `alpha'/(2*`g'))

save "all_bmi_results.dta", replace

