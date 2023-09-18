sort pval

// generating BH adjusted p-values
generate rank = _n
generate n_tests = _N
generate bh_pval = (pval * n_tests) / _n

// determining which results remain significant under the adjusted p-value:
generate significant = bh_pval <= 0.05

keep if significant == 0

save bh_insig.dta, replace