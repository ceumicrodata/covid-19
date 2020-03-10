local files Capital Growth-Accounts

foreach file of local files{
	import delimited Statistical_`file'.csv, clear
	keep country var code v22-v29 
	ren (v22-v29) (y2010 y2011 y2012 y2013 y2014 y2015 y2016 y2017)
	reshape long y, i(country code var) j(year)
	ren y value
	reshape wide value, i(country code year) j (var) string
	gen ISO31661Alpha2 = country
	replace ISO31661Alpha2 = "GR" if country=="EL" // Greece is under EL identified by the flag
	replace ISO31661Alpha2 = "GB" if country=="UK" // Britain is under UK 
	merge m:1 ISO31661Alpha2 using "../datahub/country-codes.dta", keepusing(ISO31661Alpha3) keep(master match) nogen
	replace country = ISO31661Alpha3
	replace country = ISO31661Alpha2 if country==""
	drop ISO*
	sort country code year
	export delimited Statistical_`file'_clean.csv, replace
	}


*LABOUR has somewhat different structure
import delimited Statistical_Labour.csv, clear
keep country var code gender age edu v24-v31 
ren (v24-v31) (y2010 y2011 y2012 y2013 y2014 y2015 y2016 y2017)
foreach i in 16 17 {
	gen double y20`i'r=real(y20`i')
	drop y20`i'
	ren y20`i'r y20`i' 
}
reshape long y, i(country code var gender age edu) j(year)
ren y value
reshape wide value, i(country code year gender age edu) j(var) string
gen ISO31661Alpha2 = country
replace ISO31661Alpha2 = "GR" if country=="EL" // Greece is under EL identified by the flag
replace ISO31661Alpha2 = "GB" if country=="UK" // Britain is under UK 
merge m:1 ISO31661Alpha2 using "../datahub/country-codes.dta", keepusing(ISO31661Alpha3) keep(master match) nogen
replace country = ISO31661Alpha3
replace country = ISO31661Alpha2 if country==""
drop ISO*
sort country code year
export delimited Statistical_Labour_clean.csv, replace


*Modifications for NA the values were given in string
import delimited Statistical_National-Accounts.csv, clear
keep country var code v22-v29 
ren (v22-v29) (y2010 y2011 y2012 y2013 y2014 y2015 y2016 y2017)
reshape long y, i(country code var) j(year)
ren y value
gen double r_value=real(value) 
drop value 
ren r_value value
reshape wide value, i(country code year) j (var) string
gen ISO31661Alpha2 = country
replace ISO31661Alpha2 = "GR" if country=="EL" // Greece is under EL identified by the flag
replace ISO31661Alpha2 = "GB" if country=="UK" // Britain is under UK 
merge m:1 ISO31661Alpha2 using "../datahub/country-codes.dta", keepusing(ISO31661Alpha3) keep(master match) nogen
replace country = ISO31661Alpha3
replace country = ISO31661Alpha2 if country==""
drop ISO*
sort country code year
export delimited Statistical_National-Accounts_clean.csv, replace	
