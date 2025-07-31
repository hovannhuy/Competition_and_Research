******** TVSEP DATA USER WORKSHOP in UEH 2025 ********


*/
clear
set more off
set scrollbufsize 2000000
global main "C:\Users\mdo_L\Desktop\Manh Hung Do_Session" //Please change this path to the location where you store the data files
cd "$main" // set the working directory
global YEAR "${main}\Year" 
global DATA "${main}\Data"

**************** Extracting data for Vietnam
******** Demographic variables: 2022
****** 2022
use "${YEAR}\wave_2022_VN\MembersRoster.dta", replace

* hh_size
* living in the household for at least 180 days (absent from the household less than 180 days)

gen nucleus_mem = 1 if v21016>=180
egen hh_size = sum(nucleus_mem), by (interview__key)
tab hh_size
label var hh_size "Household nucleus size"

gen u6child_mem  = 0
replace u6child_mem = 1 if nucleus_mem==1&v21004>=0&v21004<6
egen no_children_under6 = sum(u6child_mem), by(interview__key)
label var no_children_under6 "Number of children under 6 years old"

gen child_mem  = 0
replace child_mem = 1 if nucleus_mem==1&v21004>=6&v21004<=18
egen no_children_schoolage = sum(child_mem), by(interview__key)
label var no_children_schoolage "Number of children from 6 to 18 years old"

gen adult_mem  = 0
replace adult_mem = 1 if nucleus_mem==1&v21004>18&v21004<=60
egen no_adult = sum(adult_mem), by(interview__key)
label var no_adult "Number of adults (From 19 to 60 years old)"

gen elderly_mem  = 0
replace elderly_mem = 1 if nucleus_mem==1&v21004>60
egen no_elderly = sum(elderly_mem), by(interview__key)
label var no_elderly "Number of elderly (Older than 60 years old)"

keep if v21005==1

ren v22007 head_highest_edu
label var head_highest_edu "Educational attainment of household head"
tab head_highest_edu

label var v21003 "Gender of household head; male = 1; female = 2"
label var v21004 "Age of household head; years old"
label var v21006 "Marital status of household head"
label var v21011 "Ethnicity of head"

ren v21003 head_gender
ren v21004 head_age
ren v21006 head_marital_status
ren v21011 head_ethnicity

keep interview__key head_gender head_age head_marital_status head_ethnicity head_highest_edu hh_size no_children_under6 no_children_schoolage no_adult no_elderly

gen year = 2022

save "${DATA}\demo_2022_VN.dta", replace


******** Shock variables:
****** 2022
use "${YEAR}\wave_2022_VN\shocks_detail.dta", replace

tab v31103

drop if v31103==1|v31103==2|v31103==3|v31103==4|v31103==9999
drop if v31103a<=4&v31103==5
drop if v31103a>4&v31103==6

tab v31103a v31103 

drop if v31103a==99

*Keep only the shocks that happended with in the reference period (12 months; May 2021 - April 2022)

gen no_shocks = 1

gen loss_shocks = v31105a + v31105b + v31106a

*replace loss_shocks = loss_shocks/12819.4176	
replace loss_shocks = (loss_shocks/1000)*0.0780
* https://www.tvsep.de/fileadmin/tvsep/Materials_ab_2023/Documentation/ppp_factors/PPP_Conversion_Factors_07_23.pdf


**** Classifying shocks by types:
* https://doi.org/10.1016/j.worlddev.2013.11.005
gen weather_shock = 1 if shocks__id==10 | shocks__id==11 | shocks__id==16 | shocks__id==55
gen health_shock = 1 if shocks__id==1 | shocks__id==2 | shocks__id==24
gen economic_shock = 1 if shocks__id==21 | shocks__id==22 | shocks__id==46 | shocks__id==62 | shocks__id==70|shocks__id==71|shocks__id==72|shocks__id==74|shocks__id==75|shocks__id==76 
gen pests_diseases_shock = 1 if shocks__id==63


label var no_shocks "Number of reported shocks in the last 12 months"
label var loss_shocks "Income and asset losses from reported shocks in the last 12 months (PPP USD)"
label var weather_shock "Number of reported weather shocks in the last 12 months"
label var health_shock "Number of reported health shocks in the last 12 months"
label var economic_shock "Number of reported economic shocks in the last 12 months"
label var pests_diseases_shock "Number of reported pest and disease shocks in the last 12 months"

gen year = 2022

collapse (sum) no_shocks loss_shocks weather_shock health_shock economic_shock pests_diseases_shock , by(interview__key)

save "${DATA}\shock_2022_VN.dta", replace


******** To merge file between sections in the same wave: "interview__key" is the key variable to merge
use "${DATA}\demo_2022_VN.dta", replace

merge 1:1 interview__key using "${DATA}\shock_2022_VN.dta"

drop _merge

foreach x of varlist no_shocks loss_shocks weather_shock health_shock economic_shock pests_diseases_shock {
	replace `x'=0 if `x'==.
}


merge 1:1 interview__key using "${DATA}\access_credit_2022_VN.dta"

replace access_credit = 0 if access_credit==.
replace borr_amount = 0 if borr_amount==.

drop _merge

save "${DATA}\Full_2022_VN.dta", replace


******** To merge file across waves: "QID" is the key variable to merge
use "${YEAR}\wave_2022_VN\TVSEP2022SurveyV1.dta", replace

keep QID interview__key v10001 v10002 v10003 v10004

merge 1:1 interview__key using "${DATA}\Full_2022_VN.dta"

drop _merge

format %16.0g QID
format %16s interview__key
format %26.0f v10001-v10004

order year, after(QID)

save "${DATA}\Full_2022_VN.dta", replace


*********
****** 2017
use "${YEAR}\wave_7_2017_VN\memclean.dta", replace

* hh_size
* living in the household for at least 180 days (absent from the household less than 180 days)

gen nucleus_mem = 1 if _x21016>=180
egen hh_size = sum(nucleus_mem), by (QID)
tab hh_size
label var hh_size "Household nucleus size"

gen u6child_mem  = 0
replace u6child_mem = 1 if nucleus_mem==1&_x21004>=0&_x21004<6
egen no_children_under6 = sum(u6child_mem), by(QID)
label var no_children_under6 "Number of children under 6 years old"

gen child_mem  = 0
replace child_mem = 1 if nucleus_mem==1&_x21004>=6&_x21004<=18
egen no_children_schoolage = sum(child_mem), by(QID)
label var no_children_schoolage "Number of children from 6 to 18 years old"

gen adult_mem  = 0
replace adult_mem = 1 if nucleus_mem==1&_x21004>18&_x21004<=60
egen no_adult = sum(adult_mem), by(QID)
label var no_adult "Number of adults (From 19 to 60 years old)"

gen elderly_mem  = 0
replace elderly_mem = 1 if nucleus_mem==1&_x21004>60
egen no_elderly = sum(elderly_mem), by(QID)
label var no_elderly "Number of elderly (Older than 60 years old)"


tab _x22007
tab _x22005 if _x21005==1&_x22007==.

replace _x22007 = _x22005 if _x21005==1&_x22007==.

replace _x22007 = _x22007t if _x22007==78

#delimit ;
recode _x22007 (72 73 = 4) 
(65 66 67 68 69 70 74 75 76 77 = 7) 
(51 52 53 54 55 = 8) (56 57 58 59 = 9) (60 61 62 = 10)  , gen(head_highest_edu)
;
#delimit cr

replace head_highest_edu = 30 if _x22007==30

label var head_highest_edu "Educational attainment of household head"

#delimit ;
label define head_highest_edu 0 "Below primary level" 1 "Primary level (TH)" 2 "Lower-secondary level (TH)" 3 "Upper-secondary level (TH)" 
4 "Vocational school" 7 "University" 8 "Primary level (VN)" 9 "Secondary level (VN)" 10 "Highschool level (VN)" 30 "Adult education"
32 "Non-formal education" 33 "Diploma of vocational certificate"  90 "Others" 97 "Don't know" 98 "No answer" 99 "Not applicable", modify
;
#delimit cr

label values head_highest_edu head_highest_edu
order head_highest_edu, after(_x21011)

tab head_highest_edu

keep if _x21005==1

***
label var _x21003 "Gender of household head; male = 1; female = 2"
label var _x21004 "Age of household head; years old"
label var _x21006 "Marital status of household head"
label var _x21011 "Ethnicity of head"

ren _x21003 head_gender
ren _x21004 head_age
ren _x21006 head_marital_status
ren _x21011 head_ethnicity

keep QID hhid prov distr subdistr vill head_gender head_age head_marital_status head_ethnicity head_highest_edu hh_size no_children_under6 no_children_schoolage no_adult no_elderly

gen year = 2017

save "${DATA}\demo_2017_VN.dta", replace


******** Shock variables: 2017
use "${YEAR}\wave_7_2017_VN\shocksclean.dta", replace

tab _x31003 _x31003a

drop if _x31003<=4&_x31003a==2016
drop if _x31003>4&_x31003a==2017

tab _x31003 _x31003a

*Keep only the shocks that happended with in the reference period (12months; May 2016 - April 2017)

gen no_shocks = 1
gen loss_shocks = _x31005a + _x31005b + _x31006a

gen weather_shock = 1 if _x31002==10 | _x31002==11 | _x31002==16 | _x31002==55
gen health_shock = 1 if _x31002==1 | _x31002==2 | _x31002==24
gen economic_shock = 1 if _x31002==21 | _x31002==22 | _x31002==46 | _x31002==62 | _x31002==70|_x31002==71|_x31002==72|_x31002==74|_x31002==75|_x31002==76 
gen pests_diseases_shock = 1 if _x31002==63

collapse (sum) no_shocks loss_shocks weather_shock health_shock economic_shock pests_diseases_shock , by(QID)

*replace loss_shocks = (loss_shocks*1000)/11390.2157
replace loss_shocks = loss_shocks*0.0878
* https://www.tvsep.de/fileadmin/tvsep/Materials_ab_2023/Documentation/ppp_factors/PPP_Conversion_Factors_07_23.pdf

label var no_shocks "Number of reported shocks in the last 12 months"
label var loss_shocks "Income and asset losses from reported shocks in the last 12 months (PPP USD)"
label var weather_shock "Number of reported weather shocks in the last 12 months"
label var health_shock "Number of reported health shocks in the last 12 months"
label var economic_shock "Number of reported economic shocks in the last 12 months"
label var pests_diseases_shock "Number of reported pest and disease shocks in the last 12 months"

gen year = 2017

save "${DATA}\shock_2017_VN.dta", replace


******** To merge file between sections in the same wave: "interview__key" is the key variable to merge
use "${DATA}\demo_2017_VN.dta", replace

merge 1:1 QID using "${DATA}\shock_2017_VN.dta"

drop _merge

foreach x of varlist no_shocks loss_shocks weather_shock health_shock economic_shock pests_diseases_shock {
	replace `x'=0 if `x'==.
}

merge 1:1 QID using "${DATA}\access_credit_2017_VN.dta"

replace access_credit = 0 if access_credit==.
replace borr_amount = 0 if borr_amount==.

drop if _merge==2
drop _merge

save "${DATA}\Full_2017_VN.dta", replace


******** Creating panel data
use "${DATA}\Full_2017_VN.dta", replace

append using "${DATA}\Full_2022_VN.dta"

save "${DATA}\Full_1722_VN.dta", replace


******** Recoding the variables
use "${DATA}\Full_1722_VN.dta", replace

replace head_gender = 0 if head_gender==2
label var head_gender "Male head = 1; otherwise = 0"
label define head_gender 1 "Male head" 0 "Otherwise"
label value head_gender head_gender

replace head_marital_status = 0 if head_marital_status!=2
replace head_marital_status = 1 if head_marital_status==2
label var head_marital_status "Married head = 1; otherwise = 0"
label define head_marital_status 1 "Married head" 0 "Otherwise"
label value head_marital_status head_marital_status

replace head_ethnicity = 0 if head_ethnicity!=3
replace head_ethnicity = 1 if head_ethnicity==3
label var head_ethnicity "Thai majority = 1; otherwise = 0" 
label define head_ethnicity 0 "Otherwise" 1 "Kinh majority"
label value head_ethnicity head_ethnicity

tab head_highest_edu
drop if head_highest_edu==98

gen head_secondary = 0
replace head_secondary = 1 if head_highest_edu==9|head_highest_edu==10|head_highest_edu==4|head_highest_edu==7
label var head_secondary "Head has at least a secondary education level = 1"

tab head_highest_edu head_secondary

save "${DATA}\Full_1722_VN.dta", replace


****** Descriptive table
use "${DATA}\Full_1722_VN.dta", replace

sum access_credit borr_amount no_shocks head_gender head_age head_marital_status head_ethnicity head_secondary hh_size

gen year_1 = 0
replace year_1 = 1 if year==2017

estpost sum access_credit borr_amount no_shocks head_gender head_age head_marital_status head_ethnicity head_secondary hh_size 
est store	Whole

estpost sum access_credit borr_amount no_shocks head_gender head_age head_marital_status head_ethnicity head_secondary hh_size  if year==2017
est store	y_2017

estpost sum access_credit borr_amount no_shocks head_gender head_age head_marital_status head_ethnicity head_secondary hh_size  if year==2022
est store	y_2022

estpost ttest access_credit borr_amount no_shocks head_gender head_age head_marital_status head_ethnicity head_secondary hh_size , by(year_1)
est store ttest

esttab Whole y_2017 y_2022 ttest using "${DATA}\Table_Descriptive_.rtf", varwidth(25) star(* 0.1 ** 0.05 *** 0.01) label cell(mean(label(Mean) fmt(%9.2f)) sd(label(SD) par fmt(%9.2f)) b(star fmt(%9.2f))) replace nonumber mtitle("Whole sample (n = 3123)" "2019 (n = 1897)" "2022 (n = 1226)" "Meandiff/2019-2022")


****** Estimations
use "${DATA}\Full_1722_VN.dta", replace

*** Shock and access to credit
xtset QID year
xtprobit access_credit no_shocks head_gender head_age head_marital_status head_ethnicity head_secondary hh_size no_adult no_elderly
margins, dydx(*) post

*** With shock types
xtprobit access_credit weather_shock health_shock economic_shock pests_diseases_shock head_gender head_age head_marital_status head_ethnicity head_secondary hh_size no_adult no_elderly
margins, dydx(*) post

*** With borrowed amount
gen ln_borramount = ln(borr_amount+sqrt(borr_amount*borr_amount+1))
* inverse hyperbolic sine approach from Huntington-Klein (2021) as ln⁡(a+√(a^2+1)).  https://doi.org/10.1201/9781003226055 

xtreg ln_borramount no_shocks head_gender head_age head_marital_status head_ethnicity head_secondary hh_size no_adult no_elderly, re

