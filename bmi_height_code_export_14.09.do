// setting up
clear all
set more off
capture log close

// setting the working directory
cd "scratch" // filepath removed
log using "log_file", replace


// setting up data for covariates and BMI PGS:
use "reshaped_linkable_adultbmi_genetic_pgs.dta", clear
keep PREG_ID_2306 BARN_NR c_sex c_yob c_PC* c_genotyping_center1  c_genotyping_center2 m_genotyping_center1  m_genotyping_center2 f_genotyping_center1 f_genotyping_center2 c_genotyping_chip1 c_genotyping_chip3 c_genotyping_chip4 c_genotyping_chip6 m_genotyping_chip2  m_genotyping_chip3 m_genotyping_chip4 m_genotyping_chip5 m_genotyping_chip6 f_genotyping_chip2 f_genotyping_chip3 f_genotyping_chip4 f_genotyping_chip5 f_genotyping_chip6 c_iid f_iid m_iid mid fid c_z_adultbmi_pgs f_z_adultbmi_pgs m_z_adultbmi_pgs

// preparing to merge:
sort PREG_ID_2306 BARN_NR

// merging in phenotypic data for bmi and height extracted from phenotools:
merge 1:1 PREG_ID_2306 BARN_NR using height_bmi_pheno_data.dta

tab _merge
// since some of this data came from phenotools, dropping those which are not in phenotools should remove those who have revoked their consent from MoBA at the time of extracting data in R. Therefore, I want to remove data which was not matched as a result of not being available in the using file:
drop if _merge == 1
// but I will double check that all unconsents have been removed later:

// merging in data for height PGS
drop _merge
sort PREG_ID_2306 BARN_NR
merge 1:1 PREG_ID_2306 BARN_NR using all_pgs.dta
tab _merge
// this time, data which are in the master are the ones which were in the using file from phenotools, and therefore accounted for retracted consent. This means that on this merge, we want to drop observations which were only in the using file, as these likely contain unconsents:
drop if _merge == 2

drop _merge
sort PREG_ID_2306 BARN_NR
merge 1:1 PREG_ID_2306 BARN_NR using cov_MBRN.dta
tab _merge
drop if _merge == 2

// standardizing the height PGSs:
egen c_z_height_pgs = std(c_height_pgs)
egen m_z_height_pgs = std(m_height_pgs)
egen f_z_height_pgs = std(f_height_pgs)

// setting up data for exam scores:
drop _merge
sort PREG_ID_2306 BARN_NR
merge 1:1 PREG_ID_2306 BARN_NR using exam_dta_for_merge.dta
tab _merge
drop if _merge == 2

drop _merge
sort PREG_ID_2306 BARN_NR
merge 1:1 PREG_ID_2306 BARN_NR using parents_eduyears.dta
tab _merge
drop if _merge == 2

drop _merge
sort PREG_ID_2306 BARN_NR
merge 1:1 PREG_ID_2306 BARN_NR using income_covs.dta
tab _merge
drop if _merge == 2

drop _merge
sort PREG_ID_2306
merge m:1 PREG_ID_2306 using PDB2306_SV_INFO_v12.dta
// all matched, so phenotools has adequately controlled for revoked consents.

// CREATING SUMMARY STATISTICS:
// For phenotypes:
  // For height:
  
postfile summary_results mean sd min max using sum_heightcm_m_q1_pheno.dta, replace
summarize heightcm_derived_m_q1
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results


postfile summary_results mean sd min max using sum_heightcm_f_q1_pheno.dta, replace
summarize heightcm_derived_f_q1
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results


postfile summary_results mean sd min max using sum_heightcm_c_5yr_pheno.dta, replace
summarize heightcm_derived_c_5yr
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results


postfile summary_results mean sd min max using sum_heightcm_c_7yr_pheno.dta, replace
summarize heightcm_derived_c_7yr
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results


postfile summary_results mean sd min max using sum_heightcm_c_8yr_pheno.dta, replace
summarize heightcm_derived_c_8yr
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results





// for BMI
postfile summary_results mean sd min max using sum_bmi_m_q1_pheno.dta, replace
summarize bmi_derived_m_q1
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_bmi_f_q1_pheno.dta, replace
summarize bmi_derived_f_q1
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_bmi_c_5yr_pheno.dta, replace
summarize bmi_derived_c_5yr
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_bmi_c_7yr_pheno.dta, replace
summarize bmi_derived_c_7yr
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_bmi_c_8yr_pheno.dta, replace
summarize bmi_derived_c_8yr
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results





// for education outcomes:
postfile summary_results mean sd min max using sum_zNPENG05.dta, replace
summarize zNPENG05
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_zNPENG08.dta, replace
summarize zNPENG08
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_zNPLES05.dta, replace
summarize zNPLES05
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_zNPLES08.dta, replace
summarize zNPLES08
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_zNPLES09.dta, replace
summarize zNPLES09
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_zNPREG05.dta, replace
summarize zNPREG05
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_zNPREG08.dta, replace
summarize zNPREG08
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_zNPREG09.dta, replace
summarize zNPREG09
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results




// setting up covariates, the same selection of which will be used in all regressions (phenotypic and MR)
// first, sex and birth year
global cov_parent_child = " c_sex c_yob"

// then, for genetic covariates, starting with principal components
global cov_PC = " c_PC* "

// and then the genotyping centre of the child, mother, and father:
global cov_GC = " c_genotyping_center1  c_genotyping_center2 m_genotyping_center1  m_genotyping_center2 f_genotyping_center1 f_genotyping_center2 "

// and finally the genotyping chip, again for all members of the parent-offspring trio:
global cov_CHIP = " c_genotyping_chip1 c_genotyping_chip3 c_genotyping_chip4 c_genotyping_chip6 m_genotyping_chip2  m_genotyping_chip3 m_genotyping_chip4 m_genotyping_chip5 m_genotyping_chip6 f_genotyping_chip2 f_genotyping_chip3 f_genotyping_chip4 f_genotyping_chip5 f_genotyping_chip6"





// summary statistics for covariates:
//contract $cov_parent_child, zero
//save sum_cov_parent_child.dta, replace
postfile summary_results mean sd min max using sum_cov_parent_child.dta, replace
summarize $cov_parent_child
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_cov_PC.dta, replace
summarize $cov_PC
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_cov_GC.dta, replace
summarize $cov_GC
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_cov_CHIP.dta, replace
summarize $cov_CHIP
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_cov_parity.dta, replace
summarize cov_num_previous_preg
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_cov_father_age.dta, replace
summarize cov_father_age
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_cov_mother_age.dta, replace
summarize cov_mother_age
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_mother_eduyears.dta, replace
summarize mother_eduyears
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_father_eduyears.dta, replace
summarize father_eduyears
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results

postfile summary_results mean sd min max using sum_par_income.dta, replace
summarize cov_parental_income
post summary_results (r(mean)) (r(Var)) (r(min)) (r(max))
postclose summary_results



// setting up files where regression results will be saved: 

//phenotypic regression, unrelated indivuduals, with principal components:
reg zNPENG05 bmi_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg $cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave bmi_derived_c_8yr using "pheno_bmi", replace detail(all) pval //filepath removed

// MR with unrelated individuals
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave bmi_derived_c_8yr using "mr_bmi_unrel", replace detail(all) pval //filepath removed

// MR with unrelated individuals and principal components
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave bmi_derived_c_8yr using "mr_bmi_unrel_PCs", replace detail(all) pval //filepath removed

// MR within-family
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) f_z_adultbmi_pgs m_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave bmi_derived_c_8yr using "mr_bmi_wf", replace detail(all) pval //filepath removed

// MR within-family and principal components
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) f_z_adultbmi_pgs m_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave bmi_derived_c_8yr using "mr_bmi_wf_PCs", replace detail(all) pval //filepath removed

// now that the files are set up, I will run this regression for all different exam score variables, and repeat this for all different child height and BMI variables


ds zNPENG05  zNPLES05 zNPLES08 zNPLES09 zNPREG05 zNPREG08 zNPREG09
foreach i in `r(varlist)'{
	
	// phenotypic regressions: with principal components
	reg `i' bmi_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "pheno_bmi", replace detail(all) pval append //filepath removed
	
		// unrelated MR
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave bmi_derived_c_8yr using "mr_bmi_unrel", replace detail(all) pval append //filepath removed
	
	// unrelated MR with PCs
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave bmi_derived_c_8yr using "mr_bmi_unrel_PCs", replace detail(all) pval append //filepath removed
	
		// Within-family MR
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) m_z_adultbmi_pgs f_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave bmi_derived_c_8yr using "mr_bmi_wf", replace detail(all) pval append //filepath removed
	
	// Within-family MR with PCs
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) m_z_adultbmi_pgs f_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave bmi_derived_c_8yr using "mr_bmi_wf_PCs", replace detail(all) pval append //filepath removed
}







//////////////////////// REGRESSIONS FOR HEIGHT:
// setting up files where regression results will be saved: 
//phenotypic regression, unrelated indivuduals, with principal components:
reg zNPENG05 heightcm_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave heightcm_derived_c_8yr using "pheno_height", replace detail(all) pval //filepath removed

// MR with unrelated individuals
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave heightcm_derived_c_8yr using "mr_height_unrel", replace detail(all) pval //filepath removed

// MR with unrelated individuals and principal components
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave heightcm_derived_c_8yr using "mr_height_unrel_PCs", replace detail(all) pval //filepath removed

// MR within-family
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) f_z_height_pgs m_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave heightcm_derived_c_8yr using "mr_height_wf", replace detail(all) pval //filepath removed

// MR within-family and principal components
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) f_z_height_pgs m_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)

regsave heightcm_derived_c_8yr using "mr_height_wf_PCs", replace detail(all) pval //filepath removed

// now that the files are set up, I will run this regression for all different exam score variables, and repeat this for all different child height and BMI variables



ds zNPENG05  zNPLES05 zNPLES08 zNPLES09 zNPREG05 zNPREG08 zNPREG09
foreach i in `r(varlist)'{
	
	// phenotypic regressions: with principal components
	reg `i' heightcm_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "pheno_height", replace detail(all) pval append //filepath removed
	
		// unrelated MR
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave heightcm_derived_c_8yr using "mr_height_unrel", replace detail(all) pval append //filepath removed
	
	// unrelated MR with PCs
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave heightcm_derived_c_8yr using "mr_height_unrel_PCs", replace detail(all) pval append //filepath removed
	
		// Within-family MR
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) m_z_height_pgs f_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave heightcm_derived_c_8yr using "mr_height_wf", replace detail(all) pval append //filepath removed
	
	// Within-family MR with PCs
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) m_z_height_pgs f_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	
	regsave heightcm_derived_c_8yr using "mr_height_wf_PCs", replace detail(all) pval append //filepath removed
}


//////////////// F-TESTS FOR INSTURMENT RELEVANCE AND STRENGTH
// for the BMI instrument
postfile results str32 description float fstat float pvalue using "bmi_f_stat", replace //filepath removed


regress bmi_derived_c_8yr c_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears
test c_z_adultbmi_pgs
local fstat = r(F)
local pvalue = r(p)
post results ("Description of test") (`fstat') (`pvalue')
postclose results

// for the height instrument
postfile results str32 description float fstat float pvalue using "height_f_stat", replace //filepath removed


regress heightcm_derived_c_8yr c_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears
test c_z_height_pgs
local fstat = r(F)
local pvalue = r(p)
post results ("Description of test") (`fstat') (`pvalue')
postclose results



//////////////////////// SEX STRATIFICATION:
save pre_split.dta, replace
tab c_sex
keep if c_sex == 1

/////////// FOR SEX NUMBER 1

// setting up files where regression results will be saved: 
//phenotypic regression, unrelated indivuduals, with principal components:

reg zNPENG05 bmi_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "pheno_bmi_sex1", replace detail(all) pval //filepath removed

// MR with unrelated individuals
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_unrel_sex1", replace detail(all) pval //filepath removed

// MR with unrelated individuals and principal components
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_unrel_PCs_sex1", replace detail(all) pval //filepath removed

// MR within-family
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) f_z_adultbmi_pgs m_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_wf_sex1", replace detail(all) pval //filepath removed

// MR within-family and principal components
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) f_z_adultbmi_pgs m_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_wf_PCs_sex1", replace detail(all) pval

// now that the files are set up, I will run this regression for all different exam score variables, and repeat this for all different child height and BMI variables

ds zNPENG05  zNPLES05 zNPLES08 zNPLES09 zNPREG05 zNPREG08 zNPREG09
foreach i in `r(varlist)'{
	
	// phenotypic regressions: with principal components
	reg `i' bmi_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "pheno_bmi_sex1", replace detail(all) pval append //filepath removed
	
		// unrelated MR
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_unrel_sex1", replace detail(all) pval append //filepath removed
	
	// unrelated MR with PCs
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_unrel_PCs_sex1", replace detail(all) pval append //filepath removed
	
		// Within-family MR
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) m_z_adultbmi_pgs f_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_wf_sex1", replace detail(all) pval append //filepath removed
	
	// Within-family MR with PCs
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) m_z_adultbmi_pgs f_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_wf_PCs_sex1", replace detail(all) pval append //filepath removed
}


// height
reg zNPENG05 heightcm_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "pheno_height_sex1", replace detail(all) pval //filepath removed

// MR with unrelated individuals
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_unrel_sex1", replace detail(all) pval //filepath removed

// MR with unrelated individuals and principal components
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_unrel_PCs_sex1", replace detail(all) pval //filepath removed

// MR within-family
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) f_z_height_pgs m_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_wf_sex1", replace detail(all) pval //filepath removed

// MR within-family and principal components
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) f_z_height_pgs m_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_wf_PCs_sex1", replace detail(all) pval //filepath removed

// now that the files are set up, I will run this regression for all different exam score variables, and repeat this for all different child height and BMI variables

ds zNPENG05  zNPLES05 zNPLES08 zNPLES09 zNPREG05 zNPREG08 zNPREG09
foreach i in `r(varlist)'{
	
	// phenotypic regressions: with principal components
	reg `i' heightcm_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "pheno_height_sex1", replace detail(all) pval append //filepath removed
	
		// unrelated MR
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_unrel_sex1", replace detail(all) pval append //filepath removed
	
	// unrelated MR with PCs
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_unrel_PCs_sex1", replace detail(all) pval append //filepath removed
	
		// Within-family MR
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) m_z_height_pgs f_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_wf_sex1", replace detail(all) pval append //filepath removed
	
	// Within-family MR with PCs
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) m_z_height_pgs f_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_wf_PCs_sex1", replace detail(all) pval append //filepath removed
}


////// FOR SEX NUMBER 2
use pre_split.dta, clear
keep if c_sex == 2

// setting up files where regression results will be saved: 
//phenotypic regression, unrelated indivuduals, with principal components:




reg zNPENG05 bmi_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "pheno_bmi_sex2", replace detail(all) pval

// MR with unrelated individuals
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_unrel_sex2", replace detail(all) pval //filepath removed

// MR with unrelated individuals and principal components
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_unrel_PCs_sex2", replace detail(all) pval //filepath removed

// MR within-family
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) f_z_adultbmi_pgs m_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_wf_sex2", replace detail(all) pval //filepath removed

// MR within-family and principal components
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (bmi_derived_c_8yr=c_z_adultbmi_pgs) f_z_adultbmi_pgs m_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave bmi_derived_c_8yr using "mr_bmi_wf_PCs_sex2", replace detail(all) pval //filepath removed

// now that the files are set up, I will run this regression for all different exam score variables, and repeat this for all different child height and BMI variables

ds zNPENG05  zNPLES05 zNPLES08 zNPLES09 zNPREG05 zNPREG08 zNPREG09
foreach i in `r(varlist)'{
	
	// phenotypic regressions: with principal components
	reg `i' bmi_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "pheno_bmi_sex2", replace detail(all) pval append //filepath removed
	
		// unrelated MR
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_unrel_sex2", replace detail(all) pval append
	
	// unrelated MR with PCs
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_unrel_PCs_sex2", replace detail(all) pval append //filepath removed
	
		// Within-family MR
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) m_z_adultbmi_pgs f_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_wf_sex2", replace detail(all) pval append //filepath removed
	
	// Within-family MR with PCs
	ivregress 2sls `i' (bmi_derived_c_8yr=c_z_adultbmi_pgs) m_z_adultbmi_pgs f_z_adultbmi_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave bmi_derived_c_8yr using "mr_bmi_wf_PCs_sex2", replace detail(all) pval append //filepath removed
}

// height



reg zNPENG05 heightcm_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "pheno_height_sex2", replace detail(all) pval //filepath removed

// MR with unrelated individuals
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_unrel_sex2", replace detail(all) pval //filepath removed

// MR with unrelated individuals and principal components
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_unrel_PCs_sex2", replace detail(all) pval //filepath removed

// MR within-family
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) f_z_height_pgs m_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_wf_sex2", replace detail(all) pval //filepath removed

// MR within-family and principal components
// assuming that to get to within family design, we condition on both of the parent's BMI Pcs
ivregress 2sls zNPENG05 (heightcm_derived_c_8yr=c_z_height_pgs) f_z_height_pgs m_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
regsave heightcm_derived_c_8yr using "mr_height_wf_PCs_sex2", replace detail(all) pval

// now that the files are set up, I will run this regression for all different exam score variables, and repeat this for all different child height and BMI variables

ds zNPENG05  zNPLES05 zNPLES08 zNPLES09 zNPREG05 zNPREG08 zNPREG09
foreach i in `r(varlist)'{
	
	// phenotypic regressions: with principal components
	reg `i' heightcm_derived_c_8yr $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "pheno_height_sex2", replace detail(all) pval append //filepath removed
	
		// unrelated MR
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_unrel_sex2", replace detail(all) pval append //filepath removed
	
	// unrelated MR with PCs
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_unrel_PCs_sex2", replace detail(all) pval append //filepath removed
	
		// Within-family MR
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) m_z_height_pgs f_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_wf_sex2", replace detail(all) pval append //filepath removed
	
	// Within-family MR with PCs
	ivregress 2sls `i' (heightcm_derived_c_8yr=c_z_height_pgs) m_z_height_pgs f_z_height_pgs $cov_parent_child $cov_PC $cov_GC $cov_CHIP cov_num_previous_preg cov_father_age cov_mother_age father_eduyears mother_eduyears cov_parental_income, vce(cluster fid)
	regsave heightcm_derived_c_8yr using "mr_height_wf_PCs_sex2", replace detail(all) pval append //filepath removed
}






