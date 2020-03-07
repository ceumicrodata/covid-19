confirm exist `1'
confirm exist `2'

local detailed `1'
local aggregate `2'
if ("`3'"!="") {
	local sum `3'
}
else {
	local sum value
}

* clean, non-aggregated sectors
tempvar clean
generate byte `clean' = (`detailed'==`aggregate')

* total manufacturing
tempvar total
egen `total' = mean(cond(isic=="D", value, .)), by(country year)

* average share of each clean sector
tempvar share mean_share
generate `share' = value / `total' if `clean'
egen `mean_share' = mean(`share'), by(`detailed' year)

* create aggregates
tempvar sum_actual sum_share
egen double `sum_actual' = sum(`sum'), by(country `aggregate' year)
egen `sum_share' = sum(`mean_share'), by(country `aggregate' year)

* interpolate values
generate double value_interpolated = `sum_actual' * `mean_share' / `sum_share' if `detailed' != `aggregate'
