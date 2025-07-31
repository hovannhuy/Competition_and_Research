

/***********************************************************************************************************
* EXPLORING SELF-EMPLOYMENT DYNAMICS AND WEATHER SHOCKS IN THAILAND AND VIETNAM
************************************************************************************************************/

* GOAL 1: Understand teh dynamcis of Non-farm self-employment in Thailand and Vietnam
* GOAL 2: Explore how the exposure opposite natural disasters in Thailand and Vietnam varies over space and time

*set your path:
global masterfolder "/Users/OleLueck/Dropbox/TVSEP data-users presentations/natural_disasters_entrepreneurship/3_data" // set path to the data folder here

global vietnam "$masterfolder/Data_VN"
global thailand "$masterfolder/Data_TH"

/***********************************************************************************************************
Creating business dataset - information on activities: Business: yes/no in each survey wave
************************************************************************************************************/

/*
********* 2022 *********
*VN
use "$vietnam/2022/TVSEP2022SurveyV1.dta", clear
keep QID v61001c v10003 v10004
destring QID, replace
format QID %15.0f
gen year = 2022
save "$vietnam/2022/TVSEP2022SurveyV1_selfemplonly.dta", replace

*TH
use "$thailand/2022/TVSEP2022SurveyV1.dta", clear
keep QID v61001c v10003 v10004
gen year = 2022
save "$thailand/2022/TVSEP2022SurveyV1_selfemplonly.dta", replace


********* 2019 *********
*TH
use "$thailand/2019/selfempl.dta", clear
keep interview__key interview__id
duplicates drop interview__key, force
gen v61001c = 1
merge 1:m interview__key using "$thailand/2019/TVSEP2019.dta"
replace v61001c = 2 if _merge==2
gen year = 2019
keep QID v61001c year v10003 v10004
save "$thailand/2019/TVSEP2019_selfemplonly.dta", replace


********* 2017 *********
*VN
use "$vietnam/2017/hhclean.dta", clear
describe QID
gen year = 2017
keep _x60001 QID year
rename  _x60001 v61001c
destring QID, replace
format QID %15.0f
save "$vietnam/2017/hhclean_selfemplonly.dta", replace

*TH
use "$thailand/2017/hhclean.dta", clear
describe QID
gen year = 2017
keep _x60001 QID year
rename  _x60001 v61001c
destring QID, replace
format QID %10.0g
save "$thailand/2017/hhclean_selfemplonly.dta", replace


********* 2016 *********
*VN
use "$vietnam/2016/hhclean.dta", clear
describe QID
gen year = 2016
keep _x60001 QID year subdistr vill
rename  _x60001 v61001c
destring QID, replace
format QID %15.0f
save "$vietnam/2016/hhclean_selfemplonly.dta", replace


*TH
use "$thailand/2016/hhclean.dta", clear
describe QID
gen year = 2016
keep _x60001 QID year subdistr vill
rename  _x60001 v61001c
destring QID, replace
format QID %10.0g
save "$thailand/2016/hhclean_selfemplonly.dta", replace


********* 2013 *********
*VN
use "$vietnam/2013/hhclean.dta", clear
tostring  QID, replace format(%15.0f)
save "$vietnam/2013/hhclean_stringQID.dta", replace

use "$vietnam/2013/selfemplclean.dta", clear
keep QID
duplicates drop QID, force
gen v61001c = 1
merge 1:m QID using "$vietnam/2013/hhclean_stringQID.dta"
replace v61001c = 2 if _merge==2
gen year = 2013
keep QID v61001c year
destring QID, replace
save "$vietnam/2013/hhclean_selfemplonly.dta", replace

*TH
use "$thailand/2013/hhclean.dta", clear
tostring  QID, replace format(%10.0f)
save "$thailand/2013/hhclean_stringQID.dta", replace

use "$thailand/2013/selfemplclean.dta", clear
keep QID
duplicates drop QID, force
gen v61001c = 1
merge 1:m QID using "$thailand/2013/hhclean_stringQID.dta"
replace v61001c = 2 if _merge==2
gen year = 2013
keep QID v61001c year
destring QID, replace
save "$thailand/2013/hhclean_selfemplonly.dta", replace


********* 2010 *********
*VN
use "$vietnam/2010/hhclean.dta", clear
tostring  QID, replace format(%10.0f)
save "$vietnam/2010/hhclean_stringQID.dta", replace

use "$vietnam/2010/selfemplclean.dta", clear
keep QID
duplicates drop QID, force
gen v61001c = 1
merge 1:m QID using "$vietnam/2010/hhclean_stringQID.dta"
replace v61001c = 2 if _merge==2
drop if _merge == 1 //weird case for which QID is in selfemployment chapter but not in general
gen year = 2010
keep QID v61001c year
destring QID, replace
save "$vietnam/2010/hhclean_selfemplonly.dta", replace

*TH
use "$thailand/2010/hhclean.dta", clear
tostring  QID, replace format(%10.0f)
save "$thailand/2010/hhclean_stringQID.dta", replace

use "$thailand/2010/selfemplclean.dta", clear
keep QID
duplicates drop QID, force
gen v61001c = 1
merge 1:m QID using "$thailand/2010/hhclean_stringQID.dta"
replace v61001c = 2 if _merge==2
gen year = 2010
keep QID v61001c year
destring QID, replace
save "$thailand/2010/hhclean_selfemplonly.dta", replace


********* 2008 *********
*VN
use "$vietnam/2008/selfemplclean.dta", clear
duplicates drop QID, force

merge 1:1 QID using "$vietnam/2008/hhclean.dta"
gen v61001c = 1
replace v61001c = 2 if _merge==2
gen year = 2008
keep QID v61001c year
destring QID, replace
format QID %10.0g
save "$vietnam/2008/hhclean_selfemplonly.dta", replace

*TH
use "$thailand/2008/selfemplclean.dta", clear
duplicates drop QID, force

merge 1:1 QID using "$thailand/2008/hhclean.dta"
gen v61001c = 1
replace v61001c = 2 if _merge==2
gen year = 2008
keep QID v61001c year
destring QID, replace
format QID %10.0g
save "$thailand/2008/hhclean_selfemplonly.dta", replace

********* 2007 *********
*VN
use "$vietnam/2007/hhclean.dta", clear
drop if _x60001 == 98
keep QID _x60001 _x10003 _x10004
gen year = 2007
rename  _x60001 v61001c
destring QID, replace
format QID %10.0g

replace v61001c = 3 if v61001c == . | v61001c == 90
save "$vietnam/2007/hhclean_selfemplonly.dta", replace

*TH
use "$thailand/2007/hhclean.dta", clear
drop if _x60001 == 98
keep QID _x60001 _x10003 _x10004
gen year = 2007
rename  _x60001 v61001c
destring QID, replace
format QID %10.0g
save "$thailand/2007/hhclean_selfemplonly.dta", replace


************************
* merging all waves VN
************************
use "$vietnam/2022/TVSEP2022SurveyV1_selfemplonly.dta", clear
append using "$vietnam/2017/hhclean_selfemplonly.dta"
append using "$vietnam/2016/hhclean_selfemplonly.dta"
append using "$vietnam/2013/hhclean_selfemplonly.dta"
append using "$vietnam/2010/hhclean_selfemplonly.dta"
append using "$vietnam/2008/hhclean_selfemplonly.dta"
append using "$vietnam/2007/hhclean_selfemplonly.dta"
sort QID  year 
order QID  year
format QID %15.0f

reshape wide v61001c v10003 v10004 subdistr vill _x10003 _x10004, i(QID) j(year)

* missing year means that HH information IN GENERAL is not available

keep QID v61001c*

gen country = "VN"
save "$vietnam/Aggregates/selfemplonly_07to22_QID_VN.dta", replace

************************
* merging all waves TH
************************
use "$thailand/2022/TVSEP2022SurveyV1_selfemplonly.dta", clear
append using "$thailand/2019/TVSEP2019_selfemplonly.dta"
append using "$thailand/2017/hhclean_selfemplonly.dta"
append using "$thailand/2016/hhclean_selfemplonly.dta"
append using "$thailand/2013/hhclean_selfemplonly.dta"
append using "$thailand/2010/hhclean_selfemplonly.dta"
append using "$thailand/2008/hhclean_selfemplonly.dta"
append using "$thailand/2007/hhclean_selfemplonly.dta"
sort QID  year 
order QID  year
format QID %15.0f

reshape wide v61001c v10003 v10004 subdistr vill _x10003 _x10004, i(QID) j(year)

* missing year means that HH information IN GENERAL is not available

keep QID v61001c*

gen country = "TH"
save "$thailand/Aggregates/selfemplonly_07to22_QID_TH.dta", replace

*****************************
* merging all waves VN + TH
*****************************

use "$vietnam/Aggregates/selfemplonly_07to22_QID_VN.dta", clear
append using "$thailand/Aggregates/selfemplonly_07to22_QID_TH.dta"

order QID country v61001c2007 v61001c2008 v61001c2010 v61001c2013 v61001c2016 v61001c2017 v61001c2019 v61001c2022
save "$masterfolder/Data_Aggregates/selfemplonly_07to22_QID_VN_TH.dta", replace

*/ 


* load weights-data in order to integrate village and year specific weigths and to get province information
use "$masterfolder/Weights/Weights_TH_VN.dta", clear

destring QID, replace
format QID %15.0f

merge 1:1 QID using "$masterfolder/Data_Aggregates/selfemplonly_07to22_QID_VN_TH.dta"

drop if _merge == 1
drop _merge


order QID v61001c2007 v61001c2008 v61001c2010 v61001c2013 v61001c2016 v61001c2017 v61001c2022

reshape long v61001c, i(QID) j(year)
drop if v61001c == .
drop if v61001c == 3

* reduce dataset: no weights used today
keep QID year v61001c _x10001 _x10002 _x10003 _x10004 _x10005 country

/***********************************************************************************************************
I DESCRIPTIVES: SELF-EMPLOYMENT DYNAMICS
************************************************************************************************************/

gen has_firm = .
replace has_firm = 1 if v61001c == 1
replace has_firm = 0 if v61001c == 2

bysort QID (year): gen year_count = _N if _n == 1

egen sum_has_firm = sum(has_firm), by(QID)
gen relative_years_used = (sum_has_firm/year_count) *100

* binning relative years for better overview
gen relative_years_used_bins = .
replace relative_years_used_bins = 0 if relative_years_used == 0
replace relative_years_used_bins = 1 if relative_years_used <= 50 & relative_years_used > 0 
replace relative_years_used_bins = 2 if relative_years_used < 100 & relative_years_used > 50
replace relative_years_used_bins = 3 if relative_years_used == 100

*fixing error in dataset
replace _x10001 = "411" if _x10001 == ""

* tabulate for first insights for Vietnam
tab relative_years_used
tab relative_years_used if _x10001 == "405"
tab relative_years_used if _x10001 == "411"
tab relative_years_used if _x10001 == "605"

* tabulate for first insights for Thailand
tab relative_years_used
tab relative_years_used if _x10001 == "31"
tab relative_years_used if _x10001 == "34"
tab relative_years_used if _x10001 == "48"

*label provinces: number to name
replace _x10001 = "Buriram" if _x10001 == "31"
replace _x10001 = "Ubon Ratchathani" if _x10001 == "34"
replace _x10001 = "Nakhon Phanom" if _x10001 == "48"

replace _x10001 = "Thua Thien Hue" if _x10001 == "411"
replace _x10001 = "Ha Tinh" if _x10001 == "405"
replace _x10001 = "Dak Lak" if _x10001 == "605"



******************
* Creating Graphs
******************

*Vietnam*

* country	
	histogram relative_years_used_bins if country == "VN", horizontal discrete fraction ///
	xlabel(0(0.1)0.5) ///
	ylabel(0 "Never self-employed" 1 "<= 50% of Survey Waves self-employed" 2 "> 50% of Survey Waves self-employed" ///
	3 "Always self-employed", angle(0)) ///
	color(gray) ///
	scheme(s2color) ///
	lcolor(black) ///
	xtitle("Fraction of Households", size(small)) ///
	ytitle("") ///
	barwidth(1)

graph export "$masterfolder/Output/Self_Employment_VN_country.png", as(png) replace	 
	 
	 
* provinces
histogram relative_years_used_bins if country == "VN", horizontal discrete fraction by(_x10001, row(1) title("")) ///
	xlabel(0(0.1)0.5) ///
	ylabel(0 "Never self-employed" 1 "<= 50% of time self-employed" 2 "> 50% of time self-employed" ///
	3 "Always self-employed", angle(0)) ///
	color(gray) ///
	scheme(s2color) ///
	lcolor(black) ///
	xtitle("Fraction of Households", size(small)) ///
	ytitle("") ///
	barwidth(1)

graph export "$masterfolder/Output/Self_Employment_VN_provinces.png", as(png) replace	 	 



*Thailand*

* country

	histogram relative_years_used_bins, horizontal discrete fraction ///
	xlabel(0(0.1)0.5) ///
	ylabel(0 "Never self-employed" 1 "<= 50% of time self-employed" 2 "> 50% of time self-employed" ///
	3 "Always self-employed", angle(0)) ///
	color(gray) ///
	scheme(s2color) ///
	lcolor(black) ///
	xtitle("Fraction of Households", size(small)) ///
	ytitle("") ///
	barwidth(1)
	 
graph export "$masterfolder/Output/Self_Employment_TH_country.png", as(png) replace	 	 
	 
* provinces
histogram relative_years_used_bins if country == "TH", horizontal discrete fraction by(_x10001, row(1) title("")) ///
	xlabel(0(0.1)0.5) ///
	ylabel(0 "Never self-employed" 1 "<= 50% of time self-employed" 2 "> 50% of time self-employed" ///
	3 "Always self-employed", angle(0)) ///
	color(gray) ///
	scheme(s2color) ///
	lcolor(black) ///
	xtitle("Fraction of Households", size(small)) ///
	ytitle("") ///
	barwidth(1)

graph export "$masterfolder/Output/Self_Employment_TH_provinces.png", as(png) replace	





/***********************************************************************************************************
II DESCRIPTIVES: EXTREME WEATHER EXPOSURE
************************************************************************************************************/

* external weather data processed with "R"
* load weather data (on village-level)
use "$masterfolder/External Weather Data/weather_data.dta", clear



******************
* Creating Graphs
******************

* DROUGHTS *
*SPEI 12 by country

*pooled
graph hbox spei12, by(year,cols(1) title("Pooled", size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red)) name(pooled, replace) scheme(s2mono)
*TH
graph hbox spei12 if T == 1, by(year,cols(1) title("Thailand", size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
 yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red))  name(T, replace)  scheme(s2mono)
*VN
graph hbox spei12 if T == 0, by(year,cols(1) title("Vietnam",size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red)) yscale(range(-3 2)) name(V, replace) scheme(s2mono)

*combine graphs
graph combine pooled T V, ycommon nocopies rows(1)

graph export "$masterfolder/Output/SPEI12_TH_VN.png", as(png) replace	


*OPTIONAL by provinces
/*
*SPEI 12 by province: TH

*Buriram
graph hbox spei12 if prov == 31, by(year,cols(1) title("Buriram", size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red)) name(B, replace) scheme(s2mono)
*Ubon Ratchathani
graph hbox spei12 if prov == 34, by(year,cols(1) title("Ubon Ratchathani", size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
 yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red))  name(U, replace)  scheme(s2mono)
*Nakhon Phanom
graph hbox spei12 if prov == 48, by(year,cols(1) title("Nakhon Phanom",size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red)) yscale(range(-3 2)) name(N, replace) scheme(s2mono)

*combine graphs
graph combine B U N, ycommon nocopies rows(1)




*SPEI 12 by province: VN
*Ha Tinh
graph hbox spei12 if prov == 405, by(year,cols(1) title("Ha Tinh", size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red))  yscale(range(-3 2)) name(H, replace) scheme(s2mono)
*Thua Thien Hue
graph hbox spei12 if prov == 411, by(year,cols(1) title("Thua Thien Hue", size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
 yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red))  yscale(range(-3 2)) name(T, replace)  scheme(s2mono)
*Dak Lak
graph hbox spei12 if prov == 605, by(year,cols(1) title("Dak Lak",size(mediumsmall)) note("")) yline(-1.28, lwidth(thin) lpattern(solid) lcolor(orange)) ///
yline(-1.65, lwidth(thin) lpattern(solid) lcolor(red)) yscale(range(-3 2)) name(D, replace) scheme(s2mono)

*combine graphs
graph combine H T D, ycommon nocopies rows(1)
*/



* STORMS *
*Storms by province

gen severe_storm = 0 // severe_storm = > 33m/s
replace severe_storm = 1 if sum_severe_storm > 0

tostring prov, force replace
replace prov = "Buriram" if prov == "31"
replace prov = "Ubon Ratchathani" if prov == "34"
replace prov = "Nakhon Phanom" if prov == "48"

replace prov = "Thua Thien Hue" if prov == "411"
replace prov = "Ha Tinh" if prov == "405"
replace prov = "Dak Lak" if prov == "605"

* Table showing storm-affected provinces by year
tab prov year if severe_storm == 1

/*
                 |                                     year
     Province ID |      2007       2010       2013       2016       2017       2019       2022 |     Total
-----------------+-----------------------------------------------------------------------------+----------
         Dak Lak |         6          0          0          0         76         76          0 |       158 
         Ha Tinh |        72         66         72         72         72          0          0 |       354 
   Nakhon Phanom |        40          0         40          0         40          0          0 |       120 
  Thua Thien Hue |        72         24         72          0         72          0         72 |       312 
Ubon Ratchathani |        16          0         20          0         18          0         67 |       121 
-----------------+-----------------------------------------------------------------------------+----------
           Total |       206         90        204         72        278         76        139 |     1,065 

No storm-affected HH in Buriram	  
*/





