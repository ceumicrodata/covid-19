
import delimited "UNNA.csv", clear

drop  sna93tablecode valuefootnotes fiscalyeartype snasystem series subgroup sna93itemcode
*drop unncessary variables

gen output=0
replace output=1 if item=="Output, at basic prices"

gen va=0
replace va=1 if item=="Equals: VALUE ADDED, GROSS, at basic prices"
* generate usable dummies for value added and output


gen subitem_code=substr(subitem, -3, .)
replace subitem_code="" if substr(subitem_code,1,1)!="("
replace subitem_code=substr(subitem_code,2,1)
* generate subitem code for easier reference


gen services_OP_sect=0
gen services_VA_sect=0
*generate auxiliary variables for aggregation of services
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
bysort country year: gen services_VA=sum(services_VA_sect) 
bysort country year: egen services_OP1=max(services_OP)
bysort country year: egen services_VA1=max(services_VA)

*aggregating services

drop services_*_sect services_OP services_VA 
ren (services_OP1 services_VA1) (services_OP services_VA)

replace value= services_OP if output==1 & subitem_code=="S"
replace value= services_VA if va==1 & subitem_code=="S"
replace subitem="Services" if subitem_code=="S" & output==1
replace subitem="Services" if subitem_code=="S" & va==1

keep if (subitem_code == "C" | subitem_code == "A" | subitem_code == "S") & (output==1 | va==1)


keep country subitem year currency value va output

export delimited using "UNNA_consistent.csv", replace

