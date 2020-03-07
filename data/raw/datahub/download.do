copy "https://datahub.io/core/country-codes/r/country-codes.csv" "country-codes.csv"

import delimited "country-codes.csv", bindquote(strict) encoding("utf-8") varnames(1) case(preserve) clear

save "country-codes.dta", replace
