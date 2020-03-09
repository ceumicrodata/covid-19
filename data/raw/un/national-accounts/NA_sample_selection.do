
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
save sample_selection_dta/`country'.dta, replace
restore
}
clear
foreach country of local sample{
append using /sample_selection_dta/`country'.dta
}

*interpolate 2018 data

export delimited using "../../../analysis/UNNA_sample.csv", replace
