clear all

tempfile unido
generate country = .
generate isic = .
generate year = .
save `unido', replace emptyok

foreach v in gross_output value_added {
	import delimited using "`v'.csv", clear

	destring value, force replace
	
	* in API, isiccomb is only filled in if different
	replace isiccomb = isic if missing(isiccomb)

	do split_by_isic isic isiccomb 
	replace value = value_interpolated if isic!=isiccomb

	drop value_interpolated
	generate aggr = cond(!missing(value), isic, "0")

	tempvar total D diff
	egen `D' = mean(cond(isic=="D", value, .)), by(country year)
	egen `total' = sum(cond(isic!="D", value, .)), by(country year)
	generate `diff' = max(0,`D'-`total')

	do split_by_isic isic aggr `diff'
	replace value = value_interpolated if missing(value)

	keep country isic year value
	rename value `v'
	
	drop if isic == "D"
	destring isic, force replace
	
	merge 1:1 country isic year using `unido', nogen 
	save `unido', replace
}
format gross_output value_added %12.0f

* balance panel
reshape wide gross_output value_added, i(country isic) j(year)
reshape long
reshape wide gross_output value_added, i(country year) j(isic)
reshape long

sort country isic year
export delimited unido.csv, replace

