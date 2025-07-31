
global mydir "E:\TVSEP data updated 2022"
cd "E:\TVSEP data updated 2022\data workshop\dataset_crop"


***************************************
* Load and summarize 2007 crop data
***************************************

clear all
set more off  // Prevents Stata from pausing output

* Load dataset
use "crop2007-02.dta", clear



* Summarize data
describe
summarize



** Calculate net income from crop production **

gen Value_Crop_per_crop = _x42010n * _x42016n
replace Value_Crop_per_crop = 0 if Value_Crop_per_crop == .

** Generate area planted **
gen crop_land = _x42005
replace crop_land = 0 if crop_land == .

gen crop_land_ha = crop_land 

** Generate expenditure variables **
**cost of seeds and seedling
gen cost_seed = _x42020n
replace cost_seed = 0 if cost_seed == .

**cost of hand weeding
gen cost_hand_weed = _x42022n
replace cost_hand_weed = 0 if cost_hand_weed == .

**cost of land preparation machine
gen cost_preparation = _x42018n
replace cost_preparation = 0 if cost_preparation == .

**cost of fertilizer
gen cost_fertilizer = _x42023n
replace cost_fertilizer = 0 if cost_fertilizer == .

*cost of pesticides =  Expenditures pesticides materials
gen cost_pesticides = _x42025n
replace cost_pesticides = 0 if cost_pesticides == .

*cost of harvesting = Expenditures harvesting machinery costs (n) + Expenditures harvesting hired labor (n)
gen cost_harvesting = _x42027n
replace cost_harvesting = 0 if cost_harvesting == .

*cost Expenditures irrigation
gen cost_irrigation = _x42029n
replace cost_irrigation = 0 if cost_irrigation == .

*generate cost of hiredlabor
egen cost_hiredlabor = rowtotal(_x42021n _x42019n _x42024n _x42026n _x42028n)
replace cost_hiredlabor = 0 if cost_hiredlabor == .


** Convert values to PPP USD **
local source  Value_Crop_per_crop cost_seed cost_hand_weed cost_preparation ///
cost_fertilizer cost_pesticides cost_harvesting cost_irrigation cost_hiredlabor 
foreach x of varlist `source' {
    gen P`x' = `x' * 0.06
    label var P`x' "`: var label `x'' (PPP USD)"
}

** Collapse data by household and location **
collapse (sum)  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed ///
Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting ///
Pcost_irrigation Pcost_hiredlabor  crop_land_ha, by(QID _x10001 _x10002 _x10003 _x10004)

** Rename variables **
ren _x10001 prov 
ren _x10002 distr 
ren _x10003 subdistr
ren _x10004 vill

** Summary statistics **
sum  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed Pcost_preparation ///
 Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor  crop_land_ha

** Add year variable and reorder **
gen year = 2007
order year, after(QID)

** Save dataset **
save "E:\TVSEP data updated 2022\data workshop\dataclean_crop\crop_2007.dta", replace


***************************************
* Load and summarize 2010 crop data
***************************************


clear all
use "crop2010-02.dta" 


  *revenue of each crop = Total production (n)*Price for quantity sold (n)
 gen Value_Crop_per_crop = grossInc*0.0582
 replace Value_Crop_per_crop=0 if Value_Crop_per_crop==.
  
*generate  Area planted =  the areas are uesed to plant 
gen crop_land = _x42005
replace crop_land = 0 if crop_land==.
*generate  Area planted convert Ha =  the areas are uesed to plant convert Ha
generate crop_land_ha = crop_land /6.25
 
 *generate cost of seeds and seedling
 gen cost_seed =_x42020 
 replace cost_seed =0 if cost_seed==.

 
 *generale cost of hand weeding 
gen cost_hand_weed = _x42022
replace cost_hand_weed =0 if cost_hand_weed==.


  *generate cost of land preparation 
gen cost_preparation = _x42018 
replace cost_preparation = 0 if cost_preparation==.

 
*generate cost of for fertilizer materials

gen cost_fertilizer = _x42023 
replace cost_fertilizer = 0 if cost_fertilizer==.

 
 
 *generate cost of pesticides  
gen cost_pesticides = _x42025  
replace cost_pesticides=0 if cost_pesticides==.


*generate cost of harvesting
gen cost_harvesting =  _x42027 
replace cost_harvesting = 0 if cost_harvesting==.



*generate cost of irrigation

gen cost_irrigation = _x42029 
replace cost_irrigation = 0 if cost_irrigation==.


 *generate cost of hiredlabor
 egen cost_hiredlabor = rowtotal(_x42021  _x42019 _x42024 _x42026 _x42028)
 replace cost_hiredlabor = 0 if cost_hiredlabor==.



local source  Value_Crop_per_crop cost_seed cost_hand_weed cost_preparation ///
cost_fertilizer cost_pesticides cost_harvesting cost_irrigation cost_hiredlabor 
foreach x of varlist `source' {
   clonevar P`x' = `x' 
   lab var P`x' "`: var lab P`x''(PPP USD)"
    
}
*


collapse (sum)  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor  crop_land_ha , by(QID prov distr subdistr vill)
sum  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor  crop_land_ha

gen year=2010
order year, after(QID)


** Save dataset **
save "E:\TVSEP data updated 2022\data workshop\dataclean_crop\crop_2010.dta", replace

***************************************
* Load and summarize 2013 crop data
***************************************

clear all
use "crop2013-02.dta"
 


  *revenue of each crop = Total production (n)*Price for quantity sold (n)

*edit
egen Value_Crop_per_crop01 = max(  grossinc) ,by(QID)
egen ct = count ( Value_Crop_per_crop01) ,by (QID)
sort QID
by QID : gen ttt1=(_n)
gen Value_Crop_per_crop = Value_Crop_per_crop01 if ttt1==1
replace Value_Crop_per_crop=0 if Value_Crop_per_crop==. 
 drop ttt1 ct 
  
*generate  Area planted =  the areas are uesed to plant 
gen crop_land = _x42005

*generate  Area planted convert Ha =  the areas are uesed to plant convert Ha
generate crop_land_ha = crop_land /6.25
 
 *generate cost of seeds and seedling
 gen cost_seed =_x42020 
 replace cost_seed =0 if cost_seed==.

 
*generale cost of hand weeding 
gen cost_hand_weed = _x42022
replace cost_hand_weed =0 if cost_hand_weed==.


 
*generate cost of land preparation 
gen cost_preparation = _x42018 
replace cost_preparation = 0 if cost_preparation==.

*generate cost of for fertilizer materials
gen cost_fertilizer = _x42023  
replace cost_fertilizer = 0 if cost_fertilizer==.

 
 *generate cost of pesticides  
egen cost_pesticides = rowtotal ( _x42025a _x42025b _x42025c )
replace cost_pesticides=0 if cost_pesticides==.


*generate cost of harvesting
gen cost_harvesting = _x42027 
replace cost_harvesting = 0 if cost_harvesting==.



*generate cost of irrigation  
gen cost_irrigation = _x42029 
replace cost_irrigation = 0 if cost_irrigation==.


 *generate cost of hiredlabor 
 egen cost_hiredlabor = rowtotal(_x42021  _x42019 _x42024 _x42026 _x42028)
 replace cost_hiredlabor = 0 if cost_hiredlabor==.

 

local source  Value_Crop_per_crop cost_seed cost_hand_weed cost_preparation cost_fertilizer cost_pesticides cost_harvesting cost_irrigation cost_hiredlabor 
foreach x of varlist `source' {
   clonevar P`x' = `x' 
   lab var P`x' "`: var lab P`x''(PPP USD)"
    
}
*

collapse (sum)  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor crop_land_ha , by(QID prov distr subdistr vill)
sum  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor  crop_land_ha

gen year=2013
order year, after(QID)

** Save dataset **
save "E:\TVSEP data updated 2022\data workshop\dataclean_crop\crop_2013.dta", replace




***************************************
* Load and summarize 2017 crop data
***************************************


clear all
use "crop2017-02.dta"


  *revenue of each crop = Total production (n)*Price for quantity sold (n)
 gen Value_Crop_per_crop = grossInc
 replace Value_Crop_per_crop=0 if Value_Crop_per_crop==.

  
*generate  Area planted =  the areas are uesed to plant 
gen crop_land = _x42005
replace crop_land = 0 if crop_land==.
*generate  Area planted convert Ha =  the areas are uesed to plant convert Ha
generate crop_land_ha = crop_land /6.25
 
*generate cost of seeds and seedling
 gen cost_seed =_x42020 
 replace cost_seed =0 if cost_seed==.

 
*generale cost of hand weeding  
gen cost_hand_weed = _x42022
replace cost_hand_weed =0 if cost_hand_weed==.


*generate cost of land preparation 
gen cost_preparation = _x42018 
replace cost_preparation = 0 if cost_preparation==.

 
*generate cost of for fertilizer materials
gen cost_fertilizer = _x42023  
replace cost_fertilizer = 0 if cost_fertilizer==.

 
 *generate cost of pesticides 
egen cost_pesticides = rowtotal ( _x42025a _x42025b _x42025c )
replace cost_pesticides=0 if cost_pesticides==.

*generate cost of harvesting
gen cost_harvesting = _x42027 
replace cost_harvesting = 0 if cost_harvesting==.



*generate cost of irrigation  
gen cost_irrigation = _x42029 
replace cost_irrigation = 0 if cost_irrigation==.



  *generate cost of hiredlabor 
 egen cost_hiredlabor = rowtotal(_x42021  _x42019 _x42024 _x42026 _x42028)
 replace cost_hiredlabor = 0 if cost_hiredlabor==.



*convert value from thaibale to PPP USD

local source  Value_Crop_per_crop cost_seed cost_hand_weed cost_preparation cost_fertilizer cost_pesticides cost_harvesting cost_irrigation cost_hiredlabor   
foreach x of varlist `source' {
   gen P`x' = `x' * 0.0478
   lab var P`x' "`: var lab `x''(PPP USD)"	 
  
}
*

collapse (sum)  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor  crop_land_ha , by(QID prov distr subdistr vill)
sum  PValue_Crop_per_crop Pcost_seed Pcost_hand_weed Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor  crop_land_ha

gen year=2017
order year, after(QID)



save "E:\TVSEP data updated 2022\data workshop\dataclean_crop\crop_2017.dta", replace

**********************************************************************
