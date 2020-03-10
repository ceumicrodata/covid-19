
*************************NOTES*********************************
/*
Australia and  Malaysia do not have output at basic prices only value added, 
that's why they dont have output in the consistent data and so does Chile in 
the first 3 years. Malaysia also does not reported the services.

sample: ALB AZE BEL BLR BRA BWA CAN CHE CHN CYP CZE DEU DNK ECU EGY ESP FRA GBR GRC HKG///
HRV HUN IDN IND IRN ITA JPN KAZ KGZ LAO LTU MEX MKD MYS NLD NZL PRT RUS SAU SGP SRB SWE///
TUR TWN USA VNM

Following 12 are not in the db:BWA,CHN,EGY,IDN,IRN,LAO,RUS,SAU,SGP,TWN,VNM
*/
import delimited using "UNNA_consistent.csv", clear

local sample ALB AZE BEL BLR BRA BWA CAN CHE CHN CYP CZE DEU DNK ECU EGY ESP FRA GBR GRC /// 
HKG HRV HUN IDN IND IRN ITA JPN KAZ KGZ LAO LTU MEX MKD MYS NLD NZL PRT RUS SAU SGP SRB ///
SWE TUR TWN USA VNM 
foreach country of local sample{
preserve
keep if country=="`country'"
save temp/`country'.dta, replace
restore
}
clear
foreach country of local sample{
append using temp/`country'.dta
rm temp/`country'.dta
}


*interpolate missing output data from value_added and vice-versa
tempvar ratio 
egen `ratio' = mean(value_added / gross_output), by(subitem year)
replace value_added = `ratio' * gross_output if value_added==. & gross_output!=.
replace gross_output = value_added / `ratio' if gross_output==. & value_added!=.

export delimited using "../../../analysis/UNNA_sample.csv", replace
