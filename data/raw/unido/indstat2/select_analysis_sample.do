import delimited "unido.csv", clear

* use alpha3 codes
generate ISO31661numeric = country
merge m:1 ISO31661numeric using "../../datahub/country-codes.dta", keepusing(ISO31661Alpha3) keep(master match) nogen

* merge sectors 36 and 37
replace isic = 36 if isic == 37
collapse (sum) value_added gross_output, by(ISO31661Alpha3 year isic)
clonevar country = ISO31661Alpha3

tempvar tag ctag 
egen `tag' = tag(country year)
egen `ctag' = tag(country)

foreach X of var value_added gross_output {
	egen N_`X' = sum(`X'>0 & !missing(`X')), by(country year)
	egen complete_`X' = sum(`tag' & N_`X'==22), by(country)

	summarize N_`X', d
	tabulate complete_`X' if `ctag' 
}

* keep countries with at most 1 missing cell, which will be interpolated
keep if complete_value_added >= 7 & complete_gross_output >= 7
tempvar missing
egen `missing' = sum(value_added<=0 | gross_output<=0 | missing(value_added, gross_output)), by(country)
tabulate `missing'
keep if `missing'<=1

tabulate ISO31661Alpha3
return list

* interpolate value added OR gross output
tempvar ratio
egen `ratio' = mean(value_added / gross_output), by(isic year)
replace value_added = `ratio' * gross_output if value_added<=0 | missing(value_added)
replace gross_output = value_added / `ratio' if gross_output<=0 | missing(gross_output)

keep country isic year value_added gross_output
foreach X of var value_added gross_output {
	preserve
	keep country isic year `X'
	
	* whole dollars are sufficient
	replace `X' = int(`X')
	
	reshape wide `X', i(country year) j(isic)
	sort country year
	order country year
	export delimited "../../../analysis/`X'.csv", replace
	restore
}
