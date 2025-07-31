****************************************************************************
************ Data User Workshop ********************************************
************ Coding of the MPI in 2017 *************************************
****************************************************************************


***** 1. Dimension: Monetary Poverty ***************************************
**** 1. Indicator - Income Poverty
use "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\hhinc.dta"


clonevar hhinc = _x10100  // total annual household income
clonevar ppp_hhinc = _x10100

replace ppp_hhinc = _x10100 * 0.0478  if year==2017
bysort year: sum ppp_hhinc


clonevar hhsize = _x12122 

*gen PDIncCap = ppp_hhinc/hhsize/365

gen monetary_poverty = 0
replace monetary_poverty = 1 if PDIncCap<3.2

save "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\MPI_data.dta", replace
clear



***** 2. Dimension: Education *********************************************
**** 1. Indicator - Child Missing School
use "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\memclean.dta" 

tab _x21004 _x22004 if inrange(_x21004,5,15)
* Children seem to be enrolled first between the age of 5 and 7

// https://en.wikipedia.org/wiki/Education_in_Thailand
// At the age of six, education begins. It lasts for nine years, consisting of primary, prathom (Thai: ประถม) (grades P1-6), 
// and lower secondary, matthayom (Thai: มัธยม) (grades M1-3), starting at the age of 12. 
// Upper secondary education, grades 4-6, is also not compulsory. It is divided into general and vocational tracks

// UNESCO
// http://uis.unesco.org/en/country/th
// "Compulsory education lasts 9 years from age 6 to age 14" 
// "Pre-primary 3-5, primary 6-11, secondary 12-17, tertiary 18-22
// -> Look only at pupils 5-14
// If they start at the age of 6, they have completed 8th grade by the age of 14
gen school_age 	= cond(inrange(_x21004,5,14),1,0)
gen below_age	= cond(_x21014==11, 1, 0)										
replace school_age = 0 if below_age==1											// If the child's employment data is "Below schoolage", then I replace the variable based on age I constructed

gen nucleus_child = cond(_x21022==1,1,0)
										
gen enrolled	= cond(_x22004==1,1,0)


* WHICH VARIABLES HAVE I CONSTRUCTED NOW? 
* School Age: A child is between 5 and 14 				-> Value of 1
* School Age: A family says a child is below school age -> Value of 0 

* Nucleus Child: The child is a nucleus household member -> Value of 1

* Enrolled: Child is currently enrolled in school 		 -> Value of 1
tab enrolled if school_age==1 & nucleus_child==1


* Check the students who are in school age but not enrolled
gen dropouts = cond(enrolled==0 & school_age==1 & nucleus_child==1,1,.)


egen hh_child_missing_school = max(cond(dropouts==1 & nucleus_child==1),1,0) , by(hhid)
preserve
bysort hhid: keep if _n==1
sum(hh_child_missing_school)
restore 




**** 2. Indicator - Years of Education
gen edu_10   = _x22007 if (_x21004>= 10 & _x21004<= 150 &  _x21022==1)
* No HH member (10 years or older) has completed 5/6/9 years of education
egen hh_members_edu_aux6 = max(edu_10>=6 & !missing(edu_10)), by(hhid)   // nucleus==1 is already condition in the creation of edu_adult  edu_adult<5, !missing(edu_adult) ADULTS OR ALL AGES?

* Express in deprivation (=1) rather than achievement
gen hh_members_edu_deprived6 = cond(hh_members_edu_aux6==1,0,1)





***** 3. Dimension: Health **************************************************
**** 1. Indicator - Malnourished Child
* "Children are considered malnourished if their z-score of either height-for-age (stunting)
*	or weight-for-age (underweight) is below minus two standard deviations from the medium of the reference population."

/* Construct z-scores : https://www.wikihow.com/Calculate-Z-Scores
						https://www.khanacademy.org/math/statistics-probability/modeling-distributions-of-data/z-scores/a/z-scores-review
To calculate a Z score, start by calculating the mean, or average, of your data set. 
Then, subtract the mean from each number in the data set, square the differences, 
and add them all together. Next, divide that number by n minus 1, where n equals how 
many numbers are in the sample, to get the variance. */
/*
Use the following format to find a z-score: z = X - μ / σ. 
This formula allows you to calculate a z-score for any data point in your sample. 
Remember, a z-score is a measure of how many standard deviations a data point is away from the mean.
In the formula X represents the figure you want to examine. 
In the formula, μ stands for the mean. 
In the formula, σ stands for the standard deviation. 
*/

tab _x21004 if inrange(_x21004,2,19)
replace _x21004=2 if inrange(_x21004,2.01,2.49)
replace _x21004=3 if inrange(_x21004,2.50,3.49)
replace _x21004=4 if inrange(_x21004,3.50,4.49)
replace _x21004=5 if inrange(_x21004,4.50,5.49)

* https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
* https://www.itl.nist.gov/div898/handbook/eda/section3/eda356.htm#MAD
* Iglewicz and Hoaglin recommend using the modified Z-score: Mi=0.6745(xi−x~) / MAD
* with MAD denoting the median absolute deviation and x~ denoting the median.	
* MAD=median(|Yi−Y~|)

// Weight-for-age z-score 
gen z_score_weight_for_age 	= . 
gen median_weight			= .
gen sd_weight				= .
gen mad_weight				= .
forval i = 2/19 {
foreach gender in 1 2 {
qui sum _x23006 if _x21004==`i' & _x21003==`gender', detail		// Summarize weight by age and gender  	

replace mad_weight = _x23006 - `r(p50)' if _x21004==`i' & _x21003==`gender'			// Deviation from the gender-age-specific median
replace mad_weight = abs(mad_weight) 	if _x21004==`i' & _x21003==`gender'			// Absolute value of this deviation
qui sum mad_weight 						if _x21004==`i' & _x21003==`gender', detail	// Summarize deviation
replace mad_weight = `r(p50)' 			if _x21004==`i' & _x21003==`gender'			// Extract MAD: Median of the deviations ("median absolute deviation) 

qui sum _x23006 						if _x21004==`i' & _x21003==`gender', detail	// Summarize weight by age and gender 
replace z_score_weight_for_age = 0.6745* (_x23006 - `r(p50)') / mad_weight if _x21004==`i' & _x21003==`gender' 	// Calculate modified z-score

replace median_weight = `r(p50)' 		if _x21004==`i' & _x21003==`gender'			// Extract median of weight by age, year, and gender  			
replace sd_weight = `r(sd)' 			if _x21004==`i' & _x21003==`gender'			// Extract standard deviation of weight by age, year, and gender 	 
} 
}
sum z_score_weight_for_age 
count if z_score_weight_for_age<-2 & !missing(z_score_weight_for_age)  
sum z_score, detail 

tab _x21004 if _x21003==1, sum(median_weight)
tab _x21004 if _x21003==2, sum(median_weight)

********************************************************************************
// Height-for-age z-score 
gen z_score_height_for_age 	= . 
gen median_height			= .
gen sd_height				= .
gen mad_height				= .
forval i = 2/19 {
foreach gender in 1 2 {
qui sum _x23007 						if _x21004==`i' & _x21003==`gender', detail 

replace mad_height = _x23007 - `r(p50)'	if _x21004==`i' & _x21003==`gender'
replace mad_height = abs(mad_height)	if _x21004==`i' & _x21003==`gender'
qui sum mad_height 						if _x21004==`i' & _x21003==`gender', detail 
replace mad_height = `r(p50)'			if _x21004==`i' & _x21003==`gender' 

qui sum _x23007 						if _x21004==`i' & _x21003==`gender', detail 
replace z_score_height_for_age = 0.6745* (_x23007 - `r(p50)') / mad_height if _x21004==`i' & _x21003==`gender' 


replace median_height = `r(p50)' 		if _x21004==`i' & _x21003==`gender' 			
replace sd_height = `r(sd)' 			if _x21004==`i' & _x21003==`gender' 
}
} 
sum z_score_height_for_age  
count if z_score_height_for_age<-2 & !missing(z_score_height_for_age)
sum z_score_height_for_age, detail 

tab _x21004 if _x21003==1, sum(median_height)
tab _x21004 if _x21003==2, sum(median_height)

********************************************************************************
* I consider all children for the calculation of the z-scores. 
* Only HH nucleus members are coded for the MPI 
replace z_score_weight_for_age = . if _x21022!=1
replace z_score_height_for_age = . if _x21022!=1


// Child is considered malnourished if it its z-score of either weight-for-age or height-for-age is below minus two standard deviations 
// Weight for age and height for age is only non-missing for nucleus HH children, no worries there
gen child_malnourished = cond(z_score_weight_for_age<-2 & !missing(z_score_weight_for_age),1,.)
replace child_malnourished = 1 if z_score_height_for_age<-2 & !missing(z_score_height_for_age)

replace child_malnourished = 0 if z_score_height_for_age>=-2 & z_score_weight_for_age>=-2 & ///
!missing(z_score_weight_for_age) & !missing(z_score_height_for_age) 

bys hhid: egen hh_child_malnourished = max(cond(child_malnourished==1,1,0))

bys hhid: gen nvals=_n==1
keep if nvals==1
keep hhid hh_child_malnourished hh_members_edu_deprived6 hh_child_missing_school
*drop nvals

gen year=2017

save "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\educationhealth.dta", replace
clear

***** 4. Dimension: Living Standards **************************************************
**** 1. Indicator - No Electricity for Light
use "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\houseclean.dta"

tab _x92014
recode _x92014 (6 7 8 9 = 1) (1 2 3 4 5 10 90 = 0), gen(electricity_lighting)
tab _x92014 electricity_lighting
label var		electricity_lighting	"Light by Electricity"
notes electricity_lighting:		Light provided with electricity (net), electricity (generator), solar cell, or battery
notes electricity_lighting:		Firewood, charcoal, keosine, gas (bottle), and gas (pipe) not considered 


**** 2. Indicator - No Safe Sanitation
tab _x92013
recode _x92013 (1 3 = 1) (2 4 5 90 98 99 = 0), gen(safe_sanitation)
tab _x92013 safe_sanitation
label var		safe_sanitation	"Access to Improved Sanitation, not Shared"
notes safe_sanitation:			Flush toilet (private) and latrine (private) 
notes safe_sanitation:			Flush toilet (shared), latrine (shared), and none (outside) not considered safe 


**** 3. Indicator - No Safe Drinking Water
tab _x92012
recode _x92012 (1 2 3 7 = 1) (3 4 5 6 90 98 99 = 0), gen(safe_drinking)
tab _x92012 safe_drinking
label var		safe_drinking	"Access to Safe Drinking Water"
notes safe_drinking:			Tap inside house, tap in compound, tap outside shared, bottled and bought water 
notes safe_drinking:			Well, rain water, river/lake/pond, other not considered safe


**** 4. Indicator - No Adequate Housing
* Housing (OPHI)
* Housing materials for floor is inadequate: 
* the floor is of natural materials

tab _x92008a
tab _x92008a, nolabel	
labelbook _x92008a				// 1 Dirt, 2 Cement, 3 Granite, 4 Marble, 5 Wooden, 6 Tiles
recode _x92008a ( 2 3 4 6 = 1) (1 5 = 0) (90 98 = .), gen(adequate_floor)
tab _x92008a adequate_floor
// DO NOT BE CONFUSED BY THE LABELLING -> Checked cleaning files, it is just wrongly labeled, values are correct



gen adequate_housing = cond((adequate_floor==1 | missing(adequate_floor)),1,0)

label var		adequate_housing	"House of Adequate Materials"
notes adequate_housing:				Floor is of cement, granite, marble, or tiles, not of dirt or wood 
notes adequate_housing:				2007-2010 builds only on data on walls and roof, 2013-2017 only on data on floors 

sum(adequate_floor)
sum(adequate_housing) 



**** 5. Indicator - No Cooking Facilities
tab _x92015
recode _x92015 (4 5 6 7 = 1) (1 2 3 8 90 = 0), gen(electricity_gas_cooking)
tab _x92015 electricity_gas_cooking 
label var		electricity_gas_cooking	"Cooking with Gas or Electricity"
notes electricity_gas_cooking:	Cooking with gas (bottle), gas (pipe), electricity (net), or electricity (generator) 
notes electricity_gas_cooking:	Firewood, charcoal, keosine, leaf of the rice, and other not considered  	

bys hhid: gen nvals=_n==1
keep if nvals==1
drop nvals

gen year=2017

save "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\housing.dta", replace
clear


**** 6. Indicator - Insufficient Assets
use "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\assetsclean.dta"

************************* OPHI: OWNERSHIP OF ASSETS ****************************
* "The household does not own more than one of these assets: 
* radio, TV, telephone, computer, animal cart, bicycle, motorbike or refrigerator, 
* and does not own a car or truck"
egen radio   	= total(cond(_x91001==29,1,0)), by(hhid year) // radio: 29 
egen tv			= total(cond(_x91001==26,1,0)), by(hhid year) // tv: 26
egen phone		= total(cond(inlist(_x91001,30,31),1,0)), by(hhid year) // telephone: 30, Mobile Phone: 31
egen computer	= total(cond(_x91001==42,1,0)), by(hhid year) // computer: 42

* animal cart: ?
egen bike		= total(cond(_x91001==25,1,0)), by(hhid year) // bicycle: 25
egen moto		= total(cond(_x91001==24,1,0)), by(hhid year) // motorbike: 24
egen fridge		= total(cond(_x91001==32,1,0)), by(hhid year) // refridgerator: 32 

egen car_truck_pickup = total(cond(inlist(_x91001,51,22,23),1,0)), by(hhid year) // car: 51, truck: 22; I include pick-up: 23
// careful: cars only covered in 2016/2017

egen mpi_assets_aux = rowtotal(radio tv phone computer bike moto fridge) 		// Overall number of the respective items owned 
sum mpi_assets_aux
sum mpi_assets_aux, detail
tab mpi_assets_aux car_truck_pickup 


gen mpi_assets		= cond((inlist(mpi_assets_aux,0,1) & car_truck_pickup==0),0,1)	// Not more than one asset owned, and no car/truck/pickup
tab mpi_assets_aux mpi_assets
drop mpi_assets_aux

label var		mpi_assets "HH Owns Several Assets"
notes 			mpi_assets: Household owns more than one of the following assets: Radio, TV, Phone(I include Mobile Phones), ///
							Computer, Bicycles, Motorbikes, Refridgerators.
notes			mpi_assets:	TVSEP does not capture whether HHs have animal carts, therefore it is not included.
notes			mpi_assets:	If a HH owns a car or truck (I include pick-ups), the variable also takes on a value of 1. 


keep hhid mpi_assets radio tv phone computer bike moto fridge car_truck_pickup 

bysort hhid: keep if _n==1
count

gen year=2017

save "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\assets.dta", replace
clear

*************************** Merging ********************************************
use "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\MPI_data.dta"

merge 1:1 hhid year using "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\housing.dta", force // we recoded the hhid beforehand so that we can merge according to hhid and not use interviewer key or QID
drop _merge
merge 1:1 hhid year using "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\educationhealth.dta"
drop _merge
merge 1:1 hhid year using "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\assets.dta"
drop _merge

save "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\MPI_data.dta", replace

***************************** MULTIDIMENSIONAL POVERTY INDEX *******************
// Dummies take on value of 1 when household is deprived in the respective category	
foreach var in electricity_lighting safe_sanitation safe_drinking adequate_housing electricity_gas_cooking mpi_assets {
replace `var' = `var' - 1 
replace `var' = 1 if `var'==-1
}


rename (electricity_lighting safe_sanitation safe_drinking adequate_housing electricity_gas_cooking mpi_assets) ///
(no_electricity_lighting no_improved_sanitation no_safe_drinking inadequate_housing no_electricity_cooking asset_deprived)

label var no_electricity_lighting 	"No Light by Electricity"
label var no_improved_sanitation	"No Access to Improved Sanitation, or Shared"
label var no_safe_drinking			"No Access to Safe Drinking Water"
label var inadequate_housing		"House of Inadequate Materials"
label var no_electricity_cooking 	"Cooking Without Gas or Electricity"
label var asset_deprived			"HH Is Deprived in the Asset Indicator"
label var monetary_poverty			"HH Lives on Less Than 3.20 USD Per Day Per Capita"




label define deprivation 0 "0 - Not Deprived" 1  "1 - Deprived"
label value monetary_poverty hh_child_missing_school hh_members_edu_deprived6 hh_child_malnourished  ///
no_electricity_lighting no_improved_sanitation no_safe_drinking inadequate_housing no_electricity_cooking asset_deprived ///
deprivation  

/* 
https://mppn.org/paises_participantes/vietnam/
(i) Health. Indicators: nutrition and child mortality, each is weighted 1/6
(ii) Education. Indicators: adult education and children education, each is weighted 1/10
(iii) Housing. Indicators:  housing area per person and housing quality, each is weighted 1/10
(iv) Living standards. Indicators: water and sanitation, each is weighted 1/10
(v) Access information. Indicators: usage of telecom services and assets for accessing information, each is weighted 1/10.

https://mppn.org/paises_participantes/thailand/
https://mppn.org/wp-content/uploads/2019/12/unicef-Thailand-Child-MPI-Report-EN-low-res.pdf
The four dimensions and 10 indicators of Thailand’s Child MPI are a result of the consultation process.
In Thailand, the poverty cutoff was set at 25% or one dimension. Thus, in order to be considered multidimensionally
poor a child must be deprived in at least one full dimension or the weighted sum of indicators equal or
higher than 25%.  
-> Indicators have weights from 5 to 12.5 to 25 percent!
*/

* The construction of the index builds on the papers by Aguilar&Sumner(2020), and the World Bank (2018) 
* All dimensions are weighted equally, and within dimesions, the indicators are weighted equally 
gen mpi_self	=	1/4 * monetary_poverty	///
		+	1/8 * hh_child_missing_school	+	1/8 * hh_members_edu_deprived6 ///
		+	1/4 * hh_child_malnourished	///
		+	1/24 * no_electricity_lighting 	+	1/24 * no_improved_sanitation	+	1/24 * no_safe_drinking ///
		+	1/24 * inadequate_housing 		+ 	1/24 * no_electricity_cooking 	+ 	1/24 * asset_deprived


			
/* 6: Determining the poverty cutoff point (Alkire and Santos, 2014, 256)  
* This captures the incidence of poverty for a threshold of 0.3333
"When calculating MPI we implement the full range of possible poverty cutoffs; a k cutoff of 33.33%
was selected because it has a normative justification and provided a wide distribution of poverty results.
(AS, 2014, 257) */ */
gen mpi_025	= cond(mpi_self>=1/4,1,0)
gen mpi_033 = cond(mpi_self>=2/6,1,0) 
gen mpi_050 = cond(mpi_self>=1/2,1,0)


**** Alternative coding of the mpi
mpi d1(monetary_poverty) d2(hh_child_missing_school hh_members_edu_deprived6) d3(hh_child_malnourished)	d4(no_electricity_lighting no_improved_sanitation no_safe_drinking inadequate_housing no_electricity_cooking asset_deprived)w1(0.25) w2(0.125 0.125) w3(0.25) w4(0.041667 0.041667 0.041667 0.041667 0.041667 0.041667), cutoff(0.25)


save "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\MPI\MPI_data.dta", replace

