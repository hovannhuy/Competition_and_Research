***2016 this do file is used for extracting variable from wave 2016 for data users workshop within program of TVSEP conference
*** created by Nguyet Tran, March 2025


set more off																	// STATA shows all results without pausing
capture clear all 																// clears the memory so that a new dataset may be inputted

* Computer of Nguyet (change to your working directory)   //you have to change when you use this dofile according to your directory

global datain "C:\Users\nguyettran_L\Dropbox\tvsep conference\TVSEP data-users presentations\internet&non-farm\datain\wave_6_2016_VN"  //this path is for all original data sets which were sent by TVSEP owner

global dataout "C:\Users\nguyettran_L\Dropbox\tvsep conference\TVSEP data-users presentations\internet&non-farm\dataout\dta_2016" // this path is for extracted variables that we cleaned and generated for our study

global datafinal "C:\Users\nguyettran_L\Dropbox\tvsep conference\TVSEP data-users presentations\internet&non-farm\dataout"

********************************************
*1. Extracting variables
********************************************
use "$datain\houseclean.dta", replace  // open the corresponding .dta-file

***INTERNET  (yes/no)
tab _x92019
/*
  Major device used when hh uses |
                        internet |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                  1 - Smartphone |        493       26.15       26.15
 2 - Computer (PC and/or laptop) |        180        9.55       35.70
                      3 - Tablet |          8        0.42       36.13
4 - Device in internet cafe/shop |         28        1.49       37.61
  5 - Does not apply (no access) |      1,172       62.18       99.79
             90 - Other, specify |          4        0.21      100.00
---------------------------------+-----------------------------------
                           Total |      1,885      100.00
*/
gen internet=0

replace internet =1 if inlist(_x92019, 1,2,3,4)

br QID _x92020a _x92020b _x92021a _x92021b if _x92019==90  // to see how they explain for code "90"

replace internet =1 if QID=="60503030212" & _x92019==90
replace internet =1 if QID=="40513830903" & _x92019==90
lab var internet "household used internet in the last 12 months, =1 if yes"

***internet use on productive purpose (which means all )
tab _x92020a,m
tab _x92020b,m
tab _x92021a,m 
tab _x92021b,m

gen internet_work= 0 // except using entertainment

replace internet_work = 1 if inlist(_x92020a,1,3, 4,5,6,7,8,10,11,12)
replace internet_work=1 if inlist(_x92020b,3,4,5,6,7,8,9,11,12,13) 
replace internet_work=1 if inlist(_x92021a,3,4,5,6,7,8,9,11,12,13) 
replace internet_work=1 if inlist(_x92021b,1,3,4,5,6,7,8,9,11,12,13) 

lab var internet_work "internet using for non-entertainment purpose, =1 if yes"

keep QID hhid prov distr subdistr vill internet_work internet //keep only needed variables

save "$dataout\1_internet.dta", replace 
*************************************************************************************
****member section will include all information in demographic structure of the households ///
***(age, gender, ethinicity, education... it may also contain some information from other sections depending on wave, the team that cleaned data...)
**************************************************************************************
use "$datain\memclean.dta"

keep if _x21022==1 //7201 obs and 1893 hh

**gender of hh head
gen gender=0
replace gender=1 if _x21003==1
lab var gender "gender of household member, male=1"


***Age
gen age = _x21004
lab var age "age of household members, years" // 4 missing values are died in the reference period, not head 


*** Marrital status
gen married= 0
replace married =1 if _x21006==2
lab var married " marital status of household member, =1 if married"


**household head belongs to one of the ethnic minorities

gen ethnicity=0
replace ethnicity=1 if _x12111!=1
lab var ethnicity "household head belongs to an ethnic group, yes=1"


***years of education
gen year_school =0
replace year_school=_x22014 
replace year_school=0 if year_school ==.
lab var year_school "years of schooling of household members, years"
br hhid _x21001 _x22004 _x22005 _x22006 _x22007 _x22007a _x22008 _x22009 _x22014 if year_school ==-2
replace year_school=15 if hhid ==3016& _x21001==11 //finished school at 21


**from years of education for each household members, you can generating mean years of education for adults (or all members)
bysort hhid: egen mean_schoolyear= mean (_x22014) if _x21004>=15
lab var mean_schoolyear "mean of schooling years of adult members, years"
replace mean_schoolyear=0 if mean_schoolyear==. //1576


***household nucleus size - HH SIZE
replace _x12122=5 if hhid ==2625
replace _x12122=3 if hhid ==3486
br if _x12122==0
replace _x12122=1 if _x21005==1& _x12122==0
gen HH_size=_x12122 //nucleus size


***share of children (%) (only calculated nucleus household members)
bysort hhid: gen child=1 if _x21004<=15&_x21004!=.&_x21016>=180
replace child=0 if child==.
bysort hhid:egen number_child=total(child)
gen share_child=number_child*100/HH_size
replace share_child=0 if share_child ==.
lab var share_child "share of children in total household members %"
drop child

******number of working laborers & share of laborers in household
gen X=0 
replace X=1 if inlist(_x21014,1,2,3,4,5,7,8,9,13,15)| inlist(_x21015,1,2,3,4,5,6,7,8,9,13,15)
bysort hhid: egen No_labor= total (X)
gen share_labor=No_labor*100/ HH_size
lab var share_labor "share of labor in HH, %"
replace share_labor=0 if share_labor==.
lab var No_labor "number of labor in the household"
drop X

******************************************************************************
***non-farm related variables--------------------------------------------
******************************************************************************
****dummy variable of non-farm participation
gen non_farm = 0
replace non_farm = 1 if inlist(_x21014,3,5,7,8)| inlist(_x21015, 3,5,7,8)
lab var non_farm "member participation in non-farm employment, = 1 if yes"
bysort hhid: egen No_nonfarm= total (non_farm)
lab var No_nonfarm "number of household member engaged in non-farm employment"

*****number of non-farm laborers in the households
gen nonfarm_labor = 0
replace nonfarm_labor=1 if  _x21014==3|_x21014==5|_x21014==7|_x21014==8|_x21015==3|_x21015==5|_x21015==7|_x21015==8 
replace nonfarm_labor=0 if _x21022==0
bys hhid: egen No_nonfarm_labor=total(nonfarm_labor)
lab var No_nonfarm_labor "number of nonfarm labor"

*share of nonfarm labor
gen share_NF_labor=No_nonfarm_labor*100/No_labor
lab var share_NF_labor "share of nonfarm labor in the household labor, %"


**number of selfemployment labor &share of non-farm self-employment labors
gen nf_self =0
replace nf_self=1 if _x21014==3|_x21015==3
lab var nf_self " nonfarm self employment, =1 if yes"

bysort hhid: egen no_selflb= total (nf_self)
gen share_selflb=no_selflb*100/ HH_size

lab var share_selflb "share of nf selfemployment labor in HH, %"
replace share_selflb=0 if share_selflb==.
lab var no_selflb "number of self employment labor"
lab var share_selflb "share of self employment labor"

***number of off-farm laborers and share of off-farm laborers
gen nf_wage =0
replace nf_wage=1 if _x21014==4|_x21014==5|_x21014==7|_x21014==8|_x21015==5|_x21015==7|_x21015==8
lab var nf_wage "wage employment, = 1 if yes"

bysort hhid: egen no_wagelb=total(nf_wage)
lab var no_wagelb "number of wage labor in household"
gen share_wagelb=no_wagelb*100/ HH_size
lab var share_wagelb " share of wage labor in the household, %"


**********************************************************************************
keep if _x21005==1 // keep only households' head

#delimit;
keep QID hhid gender ethnicity HH_size age
married year_school non_farm No_nonfarm_labor share_NF_labor No_labor share_labor nf_wage nf_self no_selflb no_wagelb share_selflb share_wagelb
; 
#delimit cr
replace share_NF_labor=0 if share_NF_labor==.

distinct QID //1837hh

distinct hhid
save "$dataout\2_HH_head_info.dta", replace 


*** ASSETS
use "$datain\assetsclean.dta", replace

gen no_phone = _x91002 if _x91001==31|_x91001==49
replace no_phone = 0 if no_phone==.

gen no_tv = _x91002 if _x91001==26
replace no_tv = 0 if no_tv==.

collapse (sum) no_phone no_tv  , by(QID)

label var no_phone "Number of mobile phones that the hh owns"
label var no_tv "Number of TVs that the hh owns"

save "$dataout\3_hh_assets.dta", replace


******LAND VARIABLES

use "$datain\Landclean.dta", replace

drop if _x41003a==5
gen land_location = 1 if _x41012==1
replace land_location = 0 if land_location==.
gen HH_land_plot = 1
order QID hhid _x41003 _x41009a land_location HH_land_plot
collapse (sum) _x41003 _x41009a land_location HH_land_plot, by(QID)

gen land_loca = 1 if land_location== HH_land_plot
replace land_loca = 0 if land_loca==.
drop land_location
rename land_loca (land_location)
replace _x41003 = _x41003/10 //convert to Ha
rename _x41003 total_area
label variable total_area "Ha"
rename _x41009a land_value
replace land_value = land_value*0.092
label variable land_value "PPPUSD"
label variable land_location "All land plots in the village = 1"
label variable HH_land_plot "Total number of land plots"

save "$dataout\land_2016.dta", replace


use "$datain\Landclean.dta", replace

collapse (mean) _x41013 , by(QID)
merge m:m QID using "$dataout\land_2016.dta"
label variable _x41013 "average distance from house (km)"
rename _x41013 average_plot_distance
drop _merge

save "$dataout\4_land_2016.dta", replace



 ***MERGING
use "$dataout\1_internet.dta", clear

merge 1:1 QID hhid using "$dataout\2_HH_head_info.dta"
drop  if _merge==2 //49
drop _merge

merge 1:1 QID using "$dataout\3_hh_assets.dta"
drop  if _merge==2 //49
drop _merge

***Land per capita
merge 1:1 QID using "$dataout\4_land_2016_VN.dta"
drop _merge
gen pc_land= total_area/ HH_size
lab var pc_land "total land area per capita, ha"
**************there are some cases QID stay in numeric or string variables, we have to use command destring/tostring to convert into the same types so that we can merge
destring QID, gen (qid)
drop QID
ren qid QID

merge 1:1 QID using "$datain\w6_hhinc_vn_v2.dta"
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                           106
        from master                       106  (_merge==1)
        from using                          0  (_merge==2)

    matched                             1,787  (_merge==3)
    -----------------------------------------

*/


drop if _merge!=3 //missing information about income 
drop _merge

replace P_x10085=0 if P_x10085<0|P_x10085==.
replace P_x10084=0 if P_x10084<0| P_x10084==.
replace P_x10088=0 if P_x10088<0| P_x10088==.
replace _x10100P=0 if _x10100P<0| _x10100P==.
replace P_x10087=0 if P_x10087<0| P_x10087==.

egen inc_total = rowtotal(P_x10080 P_x10081 P_x10083 P_x10084 P_x10085 P_x10086 P_x10087 P_x10088 P_x10092 P_x10093 P_x10094)
label var inc_total "total household income PPP USD"

gen share_NF= (P_x10087 + P_x10088)* 100/inc_total
replace share_NF=0 if share_NF<0
replace share_NF=0 if share_NF==.
lab var share_NF " share of nonfarm income in total household income, %"

gen income_nonfarm= P_x10087 + P_x10088
lab var income_nonfarm "household income nonfarm employment, PPP USD"


gen inc_wage=0
replace inc_wage=P_x10087 if P_x10087>=0
lab var inc_wage "income from wage employment, PPP USD"

gen inc_self=0 
replace inc_self=P_x10088 if P_x10088>=0
lab var inc_self "income from nonfarm self employment, PPP USD"

gen sha_inc_wage=inc_wage*100/inc_total
gen sha_inc_self=inc_self*100/inc_total
lab var sha_inc_wage "share of wage employment, %"
lab var sha_inc_self "share of self employment, %"
replace sha_inc_wage=0 if sha_inc_wage==.
replace sha_inc_self=0 if sha_inc_self==.


save "$datafinal\household2016", replace








