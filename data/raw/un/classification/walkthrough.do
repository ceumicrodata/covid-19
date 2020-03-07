import delimited "CPC2-SITC4.csv", clear case(preserve)
tempfile SITC
save `SITC'

import delimited "CPC2-ISIC4.csv", clear case(preserve)

joinby CPC2code using `SITC'

* try different aggregations
generate str ISIC = substr(ISIC4code, 1, 2)

generate division = substr(SITC4code, 1, 2)
generate group = substr(SITC4code, 1, 3)
generate subgroup = substr(SITC4code, 1, 5)

foreach X of var division group subgroup {
	egen mode_`X' = mode(ISIC), by(`X') minmode
	egen modal_`X' = mean(ISIC==mode_`X'), by(`X')
}
summarize modal_*

collapse (firstnm) mode_group, by(group)

rename group SITC4
rename mode_group ISIC4

foreach X of var SITC ISIC {
	destring `X', force replace
	drop if missing(`X')
}
export delimited "SITC4-ISIC4.csv", replace
