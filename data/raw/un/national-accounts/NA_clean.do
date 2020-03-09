
import delimited "UNNA.csv", clear

drop if countryorarea=="Lativa" & snasystem!=2008
drop if countryorarea=="Malta" & snasystem!=2008
drop  sna93tablecode valuefootnotes fiscalyeartype snasystem series subgroup sna93itemcode
*drop unncessary variables and duplicates because of the snasystem versions

gen output=0
replace output=1 if item=="Output, at basic prices"
gen va=0
replace va=1 if item=="Equals: VALUE ADDED, GROSS, at basic prices"
* generate dummies for value added and output
gen subitem_code=substr(subitem, -3, .)
replace subitem_code="" if substr(subitem_code,1,1)!="("
replace subitem_code=substr(subitem_code,2,1)
* generate subitem code for easier reference
gen services_OP_sect=0
gen services_VA_sect=0
*generate auxiliary variables for aggregation of services

 *************************************
 ********Aggregate Services**********
 *************************************
 /* services
H-S:
Transportation and storage (H)
Accommodation and food service activities (I)
Information and communication (J)
Financial and insurance activities (K)
Real estate activities (L)
Professional, scientific and technical activities (M)
Administrative and support service activities (N)
Public administration and defence; compulsory social security (O)
Education (P)
Human health and social work activities (Q)
Arts, entertainment and recreation (R)
Other service activities (S)
*/

local services H I J K L M N O P Q R S

foreach l of local services {
	replace services_OP_sect=value if subitem_code=="`l'" & output==1
	replace services_VA_sect=value if subitem_code=="`l'" & va==1
} 

bysort country year: gen services_OP=sum(services_OP_sect)
bysort country year: egen service_OP=max(services_OP)
bysort country year: gen services_VA=sum(services_VA_sect)
bysort country year: egen service_VA=max(services_VA)

drop services_*_sect services_OP services_VA 
ren (service_OP service_VA) (services_OP services_VA)

replace value= services_OP if output==1 & subitem_code=="S"
replace value= services_VA if va==1 & subitem_code=="S"
replace subitem="Services" if subitem_code=="S" & output==1
replace subitem="Services" if subitem_code=="S" & va==1
 *************************************
 ******Convert Country Names*******
 *************************************
gen official_name_en = countryorarea
merge m:1 official_name_en using "../../datahub/country-codes.dta", keepusing(ISO31661Alpha3) keep(master match) nogen
replace ISO31661Alpha3="MKD" if countryorarea=="North Macedonia"
replace ISO31661Alpha3="GBR" if countryorarea=="United Kingdom"
replace ISO31661Alpha3="USA" if countryorarea=="United States"
gen country = ISO31661Alpha3



 *************************************
 ********Convert Currencies**********
 *************************************
 
gen countrycode=country
merge m:1 countrycode using "currencies_clean.dta", keepusing(y*) keep(master match) nogen
forval i = 10/18 {
replace value = value/y20`i' if year == 20`i' & y20`i'!=.
}


*they are in the country-codes with a different offical name

 *************************************
 **********Select Sample*************
 *************************************
keep if (subitem_code == "A" | subitem_code == "B" | subitem_code == "C" | subitem_code == "S") & (output==1 | va==1)
gen gross_output= value if output
gen value_added=value if va

bys country subitem year: egen gross_op=max(gross_output)
bys country subitem year: egen value_ad=max(value_added)
replace gross_output=gross_op
replace value_added=value_ad

duplicates drop  country subitem year, force
keep country subitem subitem_code year gross_output value_added

reshape wide gross_output value_added, i(country subitem) j(year)
reshape long

/* works with subitem_code only bc subitem is the name of the sector aggragte
reshape wide gross_output value_added, i(country year) j(subitem_code) string
reshape long
*/

export delimited using "UNNA_consistent.csv", replace

