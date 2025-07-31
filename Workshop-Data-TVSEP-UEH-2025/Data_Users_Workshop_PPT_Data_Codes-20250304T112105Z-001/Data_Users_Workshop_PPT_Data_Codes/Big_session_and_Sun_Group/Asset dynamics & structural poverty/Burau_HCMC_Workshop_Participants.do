set more off
capture clear all
global DATAINPATH "C:\Users\olive\Desktop\Promotion\Paper_3_Poverty_Traps\HCMC_2025"
global LOG "C:\Users\olive\Desktop\Promotion\Paper_3_Poverty_Traps\HCMC_2025"
global DATAOUT "C:\Users\olive\Desktop\Promotion\Paper_3_Poverty_Traps\HCMC_2025"
cd "$DATAINPATH"

use Burau_workshop.dta, clear


* Define globals to rapidly access and change list of variables
global financial any_remit hh_access_credit
global human hh_size dependency_ratio mean_education age_head off_farm self_emp
global natural hh_land_owned lst_value_av count_index_hh
global physical hh_transport_assets hh_agri_assets hh_appliances hh_other_productive_assets house_size
global social hh_comm_assets minority_head hh_spo female_head
global village hh_any_irrigation nat_dummy made_road improved_sanitation ///
safe_drinking electricity_lighting district_distance 
global shocks hh_econ_shock hh_envir_shock hh_health_shock

* If you want to check the specification of your globals and get a feeling for the corresponding variables
des $financial $human $natural $physical $social $village $shocks
sum $financial  $human $natural $physical $social $village $shocks

/* For the full specification, you would create a global for the 190 interaction terms
qui { //definition of interaction globals
global interactions_abi int_rem_credit int_rem_hh_size int_rem_dep_ratio int_rem_edu int_rem_age int_rem_wage int_rem_self int_rem_land int_rem_lst ///
int_rem_count int_rem_tra int_rem_agri int_rem_app int_rem_oth int_rem_hou int_rem_com int_rem_min int_rem_spo int_rem_fem /// 
int_cre_hh_size int_cre_dep_ratio int_cre_edu int_cre_age int_cre_wage int_cre_self int_cre_land int_cre_lst int_cre_count /// 
int_cre_tra int_cre_agri int_cre_app int_cre_oth int_cre_hou int_cre_com int_cre_min int_cre_spo int_cre_fem int_hh_size_dep_ratio ///
int_hh_size_edu int_hh_size_age int_hh_size_wage int_hh_size_self int_hh_size_land int_hh_size_lst int_hh_size_count int_hh_size_tra ///
int_hh_size_agri int_hh_size_app int_hh_size_oth int_hh_size_hou int_hh_size_com int_hh_size_min int_hh_size_spo int_hh_size_fem ///
int_dep_edu int_dep_age int_dep_wage int_dep_self int_dep_land int_dep_lst int_dep_count int_dep_tra int_dep_agri int_dep_app ///
int_dep_oth int_dep_hou int_dep_com int_dep_min int_dep_spo int_dep_fem int_edu_age int_edu_wage int_edu_self int_edu_land ///
int_edu_lst int_edu_count int_edu_tra int_edu_agri int_edu_app int_edu_oth int_edu_hou int_edu_com int_edu_min int_edu_spo ///
int_edu_fem int_age_wage int_age_self int_age_land int_age_lst int_age_count int_age_tra int_age_agri int_age_app int_age_oth ///
int_age_hou int_age_com int_age_min int_age_spo int_age_fem int_off_self int_off_land int_off_lst int_off_count int_off_tra ///
int_off_agri int_off_app int_off_oth int_off_hou int_off_com int_off_min int_off_spo int_off_fem int_self_land int_self_lst ///
int_self_count int_self_tra int_self_agri int_self_app int_self_oth int_self_hou int_self_com int_self_min int_self_spo ///
int_self_fem int_land_lst int_land_count int_land_tra int_land_agri int_land_app int_land_oth int_land_hou int_land_com ///
int_land_min int_land_spo int_land_fem int_lst_count int_lst_tra int_lst_agri int_lst_app int_lst_oth int_lst_hou int_lst_com ///
int_lst_min int_lst_spo int_lst_fem int_count_tra int_count_agri int_count_app int_count_oth int_count_hou int_count_com ///
int_count_min int_count_spo int_count_fem int_tra_agri int_tra_app int_tra_oth int_tra_hou int_tra_com int_tra_min int_tra_spo ///
int_tra_fem int_agr_app int_agr_oth int_agr_hou int_agr_com int_agr_min int_agr_spo int_agr_fem int_app_oth int_app_hou ///
int_app_com int_app_min int_app_spo int_app_fem int_other_hou int_other_com int_other_min int_other_spo int_other_fem ///
int_house_com int_house_min int_house_spo int_house_fem int_com_min int_com_spo int_com_fem int_min_spo int_min_fem int_spo_fem
des $interactions_abi, numbers
}
*/

* Estimation of Asset-Based-Income 
xtreg PDIncCap $financial $human $natural $physical $social $village $shocks i.prov i.year i.prov#i.year, fe
est store FE_ABI
/* Diversion which we leave out, you can check this for yourself if you are interested
xtreg PDIncCap $financial_abi $human_abi $natural_abi $physical_abi $social_abi $village_abi $shocks_abi $interactions_abi i.prov i.year i.prov#i.year, fe
est store FE_ABI_INT
test $interactions_abi
*/

* FE specification as preferred estimation as basis for prediction of ABI values
predict income_abi_ppp, xbu
lab var income_abi_ppp "Daily ABI in PPP US$"

esttab FE_ABI ///
using $DATAOUT/Table_ABI_FE_Regressions.rtf, varwidth(25) b(%6.3f) label scalars(F) t r2 ar2 nonumber  ///
drop($village_abi) noomitted mtitles("FE") replace 

* Supplementary Material: SHARE OF STRUCTURAL POOR
gen structural_poor = 0
replace structural_poor = 1 if PDIncCap < 1.90 & income_abi_ppp < 1.90

gen structural_nonpoor = 0
replace structural_nonpoor = 1 if PDIncCap > 1.90 & income_abi_ppp > 1.90

gen stochastic_poor = 0
replace stochastic_poor = 1 if PDIncCap < 1.90 & income_abi_ppp > 1.90

gen stochastic_nonpoor = 0
replace stochastic_nonpoor = 1 if PDIncCap > 1.90 & income_abi_ppp < 1.90

* All households
estpost sum structural_poor structural_nonpoor stochastic_poor stochastic_nonpoor if year==2010
est sto poor_2010
estpost sum structural_poor structural_nonpoor stochastic_poor stochastic_nonpoor if year == 2013
est sto poor_2013
estpost sum structural_poor structural_nonpoor stochastic_poor stochastic_nonpoor if year == 2016
est sto poor_2016

* If you are interested: You can run a loop for this to make it more efficient
foreach year in 2010 2013 2016 {
	estpost sum structural_poor structural_nonpoor stochastic_poor stochastic_nonpoor if year==`year'
	est sto poor_`year'
}

* Table Structural Poverty: ADAPT COLUMN LABELS
esttab poor_2010 poor_2013 poor_2016 using $DATAOUT/Table_poverty_trends.rtf, varwidth(25) cell(mean(label(""))) mtitles("2010" "2013" "2016") nonumber replace


********************************************************************************
******************** Generate lagged-values of the asset-based income***********
********************************************************************************
sort hhid year
bysort hhid: gen income_abi_ppp_t_1=income_abi_ppp[_n-1]
sort hhid year
bysort hhid: gen income_abi_ppp_t_2=income_abi_ppp[_n-2]

* Restriction to area based on past assets -5- 25 leads to the exclusion of 29 HHs
drop if income_abi_ppp_t_2<-5 		// 4
drop if income_abi_ppp_t_2>25 & !missing(income_abi_ppp_t_2)	// 25
* Further restricting for current asset holdings further drops 40
drop if income_abi_ppp<-5 & !missing(income_abi_ppp)&year==2016	// 0
drop if income_abi_ppp>25 & !missing(income_abi_ppp)&year==2016	// 40
* -> In total, 69 households are excluded

* To show you the working of the parametric smooth
twoway lpoly income_abi_ppp income_abi_ppp_t_2

* Restrict to a meaningful area of display
twoway lpoly income_abi_ppp income_abi_ppp_t_2, ///
xscale(range(-5 25)) xlabel(-5[5]25) yscale(range(-5 25)) ylabel(-5[5]25)
 
* Make it look a bit nicer
twoway lpoly income_abi_ppp income_abi_ppp_t_2, ///
xscale(range(-5 25)) xlabel(-5[5]25) yscale(range(-5 25)) ylabel(-5[5]25) ///
ytitle("Daily p.c. ABI in 2005PPP US$, 2016") ///
xtitle("Daily p.c. ABI in 2005PPP US$, 2010") ///
title("Kernel, Entire Sample")

* Now, we construct the underlying design and diagonal convergence line
twoway scatteri 25 25 -5 -5, connect(l) msymbol(i) lpattern(dash) lcolor(black) ///
||scatteri 3.2 25 3.2 -5, connect(l) msymbol(i) lpattern(dot) lwidth(thick) lcolor(black) ///
||scatteri 25 3.2 -5 3.2, connect(l) msymbol(i) lpattern(dot) lwidth(thick) lcolor(black)

* Put everything together
twoway scatteri 25 25 -5 -5, connect(l) msymbol(i) lpattern(dash) lcolor(black) ///
||scatteri 3.2 25 3.2 -5, connect(l) msymbol(i) lpattern(dot) lwidth(thick) lcolor(black) ///
||scatteri 25 3.2 -5 3.2, connect(l) msymbol(i) lpattern(dot) lwidth(thick) lcolor(black) ///
||lpoly income_abi_ppp income_abi_ppp_t_2, lpattern(solid) lwidth(medthick) lcolor(black) ///
legend(off) ///
xscale(range(-5 25)) xlabel(-5[5]25) yscale(range(-5 25)) ylabel(-5[5]25) ///
ytitle("Daily p.c. ABI in 2005PPP US$, 2016") ///
xtitle("Daily p.c. ABI in 2005PPP US$, 2010") ///
title("Kernel, Entire Sample") ///
saving(Figure_poly)

* Same command, but LOWESS Smoothing
twoway scatteri 25 25 -5 -5, connect(l) msymbol(i) lpattern(dash) lcolor(black) ///
||scatteri 3.2 25 3.2 -5, connect(l) msymbol(i) lpattern(dot) lwidth(thick) lcolor(black) ///
||scatteri 25 3.2 -5 3.2, connect(l) msymbol(i) lpattern(dot) lwidth(thick) lcolor(black) ///
|| lowess income_abi_ppp income_abi_ppp_t_2, lpattern(solid) lwidth(medthick) lcolor(black) ///
legend(off) ///
xscale(range(-5 25)) xlabel(-5[5]25) yscale(range(-5 25)) ylabel(-5[5]25) ///
ytitle("Daily p.c. ABI in 2005PPP US$, 2016") ///
xtitle("Daily p.c. ABI in 2005PPP US$, 2010") ///
title("Lowess, Entire Sample") ///
saving(Figure_lowess) 



graph combine "Figure_poly" "Figure_lowess", ///
rows(2) cols(1) ///
ycommon xcommon iscale(0.5) ///
saving(Figure_Kernel_Lowess)
graph export "C:\Users\olive\Desktop\Promotion\Paper_3_Poverty_Traps\HCMC_2025\Figure_Kernel_Lowess.png", replace


********************************************************************************
* PARAMETRIC ANALYSIS
********************************************************************************
* Set correct differences between time periods
xtset hhid year, delta(3)
* Generate global with explanatory variables
global variables_growth_1 L.age_head L.age_head_squared L.female_head L.minority_head ///
L.dependency_ratio L.hh_size L.mean_education L.hh_spo L.hh_econ_shock L.hh_envir_shock L.hh_health_shock
* Generate global with explanatory variables, two lags
global variables_growth_2 L2.age_head L2.age_head_squared L2.female_head L2.minority_head ///
L2.dependency_ratio L2.hh_size L2.mean_education L2.hh_spo L2.hh_econ_shock L2.hh_envir_shock L2.hh_health_shock

* Generate variables on asset growth
sort hhid year
bysort hhid: gen abi_growth_2016_2010			=	income_abi_ppp - income_abi_ppp[_n-2] 
bysort hhid: gen abi_growth_2016_2013_2010 		= 	income_abi_ppp - income_abi_ppp[_n-1] 

* Generation of ABI polynomials
gen income_abi_ppp_squared 	= income_abi_ppp * income_abi_ppp
gen income_abi_ppp_cubic	= income_abi_ppp_squared * income_abi_ppp
gen income_abi_ppp_fourth	= income_abi_ppp_cubic * income_abi_ppp


reg abi_growth_2016_2010 L2.income_abi_ppp L2.income_abi_ppp_squared L2.income_abi_ppp_cubic L2.income_abi_ppp_fourth ///
$variables_growth_2 i.prov
est store para_ols

xtreg abi_growth_2016_2013_2010 L1.income_abi_ppp L1.income_abi_ppp_squared L1.income_abi_ppp_cubic L1.income_abi_ppp_fourth $variables_growth_1 i.prov i.year i.prov#i.year, fe cluster(village)
est store para_fe

esttab para_ols para_fe using $DATAOUT/Table_ols_fe.rtf, varwidth(25) b(%6.3f) label ///
scalars(F) t r2 ar2 nonumber mtitles("OLS ABI Growth 2010-2016" "FE ABI Growth 2010-2013-2016") replace










