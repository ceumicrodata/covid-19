import delimited "currencies.csv", varnames(5) rowrange(5) clear 

forval i = 5/54{
drop v`i'
} 

drop v64 v65

ren (v55 v56 v57 v58 v59 v60 v61 v62 v63)  (y2010 y2011 y2012 y2013 y2014 y2015 y2016 y2017 y2018) 

cap gen euro = 0
local euro_zone Austria Belgium Cyprus Estonia Finland France Germany Greece Ireland Italy Latvia Lithuania Luxemburg Malta Netherlands Portugal Slovakia Slovania Spain
foreach country of local euro_zone{
replace euro = 1 if countryname == "`country'"
}


forval i = 10/18{
cap gen euro_exchange = 0
replace euro_exchange = y20`i' if countryname == "Euro area"
qui sum euro_exchange
replace y20`i'=r(max) if euro
}
drop euro_exchange euro

export delimited currencies_clean.csv, replace
save currencies_clean.dta, replace
