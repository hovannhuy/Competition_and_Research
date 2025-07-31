clear all 
set more off

global dir "..." // change to the folder with saved data

global path_clean "$dir/cleaned"
global path_results "$dir/Results/"


global ctrl_no_income age i.healthy college_exp farm i.wave

use "$path_clean/panel_regression_conference.dta", clear


encode panel_individual_id, gen(group)


duplicates drop panel_individual_id int_date, force
bys panel_individual_id int_date: egen count_individual=count(panel_individual_id)
tab count_individual

*****  Estimations  ******


***** Pooled Sample *****

preserve


bys panel_individual_id: egen temp_count=count(panel_individual_id)
drop if temp_count<2



/* Risk Taking - Time Gap */

  reg risk_taking disaster_6 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_6) replace dec(3) sdec(3)  nor2 nocons
	
  reghdfe risk_taking disaster_6 $ctrl_no_income, absorb(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_6) append dec(3) sdec(3)  nor2 nocons
	
	reg risk_taking disaster_12 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_12) append dec(3) sdec(3)  nor2 nocons
	
  reghdfe risk_taking disaster_12 $ctrl_no_income, absorb(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_12) append dec(3) sdec(3)  nor2 nocons

  reg risk_taking disaster_18 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_18) append dec(3) sdec(3)  nor2 nocons
	
  reghdfe risk_taking disaster_18 $ctrl_no_income, absorb(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_18) append dec(3) sdec(3)  nor2 nocons

  reg risk_taking disaster_24 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_24) append dec(3) sdec(3)  nor2 nocons
	
  reghdfe risk_taking disaster_24 $ctrl_no_income, absorb(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results/risk_taking_general.doc", keep(disaster_24) append dec(3) sdec(3) nor2 nocons
	
	
sum 	disaster_6 disaster_12 disaster_18 disaster_24 if e(sample)


	
	
/* Risk taking - rain	*/
	
  reg risk_taking  rain_6 drought_6 slide_6 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_6 drought_6 slide_6) replace dec(3) sdec(3)  nor2 nocons	
	
  reghdfe risk_taking rain_6 drought_6 slide_6 $ctrl_no_income, a(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_6 drought_6 slide_6) append dec(3) sdec(3)  nor2 nocons	
	
  reg risk_taking  rain_12 drought_12 slide_12 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_12 drought_12 slide_12) append dec(3) sdec(3)  nor2 nocons	
	
  reghdfe risk_taking rain_12 drought_12 slide_12 $ctrl_no_income, a(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_12 drought_12 slide_12) append dec(3) sdec(3)  nor2 nocons
	
  reg risk_taking  rain_18 drought_18 slide_18 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_18 drought_18 slide_18) append dec(3) sdec(3)  nor2 nocons	
	
  reghdfe risk_taking rain_18 drought_18 slide_18 $ctrl_no_income, a(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_18 drought_18 slide_18) append dec(3) sdec(3)  nor2 nocons	
	
  reg risk_taking  rain_24 drought_24 slide_24 $ctrl_no_income, cluster(group) // without individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_24 drought_24 slide_24) append dec(3) sdec(3)  nor2 nocons	
	
  reghdfe risk_taking rain_24 drought_24 slide_24 $ctrl_no_income, a(group) cluster(group) // with individual fixed effects
    outreg2 using "$path_results_benchmark/risk_taking_detailed.doc", keep(rain_24 drought_24 slide_24) append dec(3) sdec(3)  nor2 nocons	
				
		
	restore
	








