****************************************************************************
************ Data User Workshop ********************************************
************ Coding of Natural Resource Extraction *************************
****************************************************************************



use "C:\Users\eseewald_L\Desktop\HomeOffice\Vietnam\DataUserWorkshop\EnvironmentalResources\AllWaves_AllCountries_hhinc.dta" 

describe

* _x10086 --> income from hunting --> income from natural resource extraction


******* Generating dummy for natural resource extraction ******************
gen d_extract=0
replace d_extract=1 if _x10086>0

sum d_extract

bys year T: sum d_extract

******** Generating relative natural resource income **********************
sum _x10086

gen nat_inc=_x10086
replace nat_inc=0 if _x10086<0

replace nat_inc=nat_inc*0.06 if year==2007 & T==1
replace nat_inc=nat_inc*0.1976 if year==2007 & T==0

replace nat_inc=nat_inc*0.0582 if year==2008 & T==1
replace nat_inc=nat_inc*0.1812 if year==2008 & T==0

replace nat_inc=nat_inc*0.0552 if year==2010 & T==1
replace nat_inc=nat_inc*0.1419 if year==2010 & T==0

replace nat_inc=nat_inc*0.0496 if year==2013 & T==1
replace nat_inc=nat_inc*0.0999 if year==2013 & T==0


replace nat_inc=nat_inc*0.0485 if year==2016 & T==1
replace nat_inc=nat_inc*0.0920 if year==2016 & T==0

replace nat_inc=nat_inc*0.0478 if year==2017 & T==1
replace nat_inc=nat_inc*0.0878 if year==2017 & T==0


******** Generating relative natural resource income **********************

gen RNI=nat_inc/_x10100P

bys year T: sum RNI 


******** Generating imcome poverty ****************************************

** Poverty line: 3.20 USD per capita and day
gen poor=0
replace poor=1 if PDIncCap<3.20





******** Very basic regressions *******************************************
corr poor d_extract RNI

reg poor d_extract
reg poor RNI

xtset hhid year
xtreg poor d_extract, fe
xtreg poor RNI, fe

clear


use "C:\Users\eseewald_L\Desktop\HomeOffice\ResearchProjects\NaturalResourceDependence_MPI_Oetjen\MPI_Data.dta" 

xtset hhid year


preserve
keep if country==0

xtlogit monetary_poverty_new d_extract RFI age_head female_head minority_head mean_education hh_size log_assets log_area off_farm self_emp hh_health_shock hh_envir_shock district_distance, fe 
margins, dydx(*)


xtheckmanfe log_env_inc age_head female_head minority_head mean_education hh_size log_assets log_area off_farm self_emp hh_health_shock hh_envir_shock district_distance made_road i.year, select(d_extract=age_head female_head minority_head mean_education hh_size log_assets log_area off_farm self_emp  district_distance made_road i.year)


restore


preserve
keep if country==1

xtlogit monetary_poverty_new d_extract RFI age_head female_head minority_head mean_education hh_size log_assets log_area off_farm self_emp hh_health_shock hh_envir_shock district_distance, fe 
margins, dydx(*)


xtheckmanfe log_env_inc age_head female_head minority_head mean_education hh_size log_assets log_area off_farm self_emp hh_health_shock hh_envir_shock district_distance made_road i.year, select(d_extract=age_head female_head minority_head mean_education hh_size log_assets log_area off_farm self_emp  district_distance made_road i.year)


restore



