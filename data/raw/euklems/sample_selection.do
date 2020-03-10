****Sample selection****
/*
sample: ALB AZE BEL BLR BRA BWA CAN CHE CHN CYP CZE DEU DNK ECU EGY ESP FRA GBR GRC HKG///
HRV HUN IDN IND IRN ITA JPN KAZ KGZ LAO LTU MEX MKD MYS NLD NZL PRT RUS SAU SGP SRB SWE///
TUR TWN USA VNM

Out of the sample 17-18 are in the database.
*/
local files Capital Growth-Accounts National-Accounts Labour
local sample ALB AZE BEL BLR BRA BWA CAN CHE CHN CYP CZE DEU DNK ECU EGY ESP FRA GBR GRC /// 
HKG HRV HUN IDN IND IRN ITA JPN KAZ KGZ LAO LTU MEX MKD MYS NLD NZL PRT RUS SAU SGP SRB ///
SWE TUR TWN USA VNM 
foreach file of local files{
import delimited Statistical_`file'_clean.csv, clear
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

export delimited `file'_sample.csv, replace
}

