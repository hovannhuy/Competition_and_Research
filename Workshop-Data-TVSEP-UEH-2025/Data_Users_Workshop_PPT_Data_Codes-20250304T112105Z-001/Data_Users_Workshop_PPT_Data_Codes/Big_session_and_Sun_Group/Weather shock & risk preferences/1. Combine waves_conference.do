
clear all 
set more off

global dir "..." // change to the folder with saved data

global path_clean "$dir/cleaned"

/*
Cleaning ideas:

******** Shock Codes and Categories for Wave 5:
	recode shock_type (10 = 8 "Heavy Rain") ///
                     (11 = 9 "Drought") ///
                     (55 = 8 "Heavy Rain") ///
                     (16 = 10 "Landslide") ///
					 (90 = 6 "Other") ///
                     (98/99 = 7 "No Answer/Not Applicable") ///
                     (else = .), generate(shock_code)

					 
******** Identify natural disaster: 

    gen natural_disaster=0
	replace natural_disaster=1 if inlist(_x31002, 10, 11, 12, 16, 55, 57, 59) // 59=long frost period
	replace natural_disaster=. if _x31002==. | _x31002==90


drop if natural_disaster==.

replace shock_code=8 if natural_disaster==1 & shock_code==.

...
*/


* use "$path_clean/w6/w6_ready.dta", clear
* append using "$path_clean/w8/w8_ready.dta"


use "$path_clean/w6_w8_ready.dta", clear


gen int_date = ym(int_year,int_month)
* gen int_month = month(__10007a)
* gen int_year = 2013


gen shock_date = ym(shock_year,shock_month)
* _x31003a: shock_year; _x31003: shock_month
* rename (_x31003a _x31003) (shock_year shock_month)

gen time_gap = int_date - shock_date
replace time_gap=. if time_gap<0
drop if time_gap==.


foreach gap in 6 12 18 24  {
	
		gen disaster_`gap' = (inrange(time_gap,0,`gap') & natural_disaster==1)

	bysort panel_individual_id int_date : egen temp_`gap' = max(disaster_`gap')
	bysort panel_individual_id int_date : replace disaster_`gap' = temp_`gap'
	drop temp_`gap'
}


foreach gap in 6 12 18 24  {
	
		gen rain_`gap' = (inrange(time_gap,0,`gap') & shock_code==8)

	bysort panel_individual_id int_date : egen temp_rain_`gap' = max(rain_`gap')
	bysort panel_individual_id int_date : replace rain_`gap' = temp_rain_`gap'
	drop temp_rain_`gap'
}


foreach gap in 6 12 18 24  {
	
		gen drought_`gap' = (inrange(time_gap,0,`gap') & shock_code==9)

	bysort panel_individual_id int_date : egen temp_drought_`gap' = max(drought_`gap')
	bysort panel_individual_id int_date : replace drought_`gap' = temp_drought_`gap'
	drop temp_drought_`gap'
}


foreach gap in 6 12 18 24  {
	
		gen slide_`gap' = (inrange(time_gap,0,`gap') & shock_code==10)

	bysort panel_individual_id int_date : egen temp_slide_`gap' = max(slide_`gap')
	bysort panel_individual_id int_date : replace slide_`gap' = temp_slide_`gap'
	drop temp_slide_`gap'
}


save "$path_clean/panel_regression_conference.dta", replace
