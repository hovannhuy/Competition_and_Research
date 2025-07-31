/*****************************************************************
		*********************
		Return migrant & Crime/Conflict
		*********************		
Outline:


*****************************************************************/

***************************
***** Creating essential variables  *****
***************************

clear all 
set more off

* Set directory

global datadir "..."

cd $datadir


global dw6m "$datadir/w6"
global dw8m "$datadir/w8"


use "$datadir/migrant_conference.dta", clear


local years 16 19
local n = wordcount("`years'")
forval i = 1/`n' {
    local yee = word("`years'", `i')
	
	egen count_retmig_hh_`yee' = total((retmig_all_`yee'==1)), by(qid year_`yee')
	bysort qid year_`yee': egen count_retmig_hh1_`yee' = total(inrange(count_retmig_hh_`yee',1,20)) if _n==1
	
	egen count_urban_retmig_hh_`yee' = total((retmig_all_`yee'==1&urban_`yee'==1)), by(qid year_`yee')
	bysort qid year_`yee': egen count_urban_retmig_hh1_`yee' = total(inrange(count_urban_retmig_hh_`yee',1,20)) if _n==1
	
	egen count_rural_retmig_hh_`yee' = total((retmig_all_`yee'==1&rural_`yee'==1)), by(qid year_`yee')
	bysort qid year_`yee': egen count_rural_retmig_hh1_`yee' = total(inrange(count_rural_retmig_hh_`yee',1,20)) if _n==1
	
	egen total_retmig_hh_`yee' = total(count_retmig_hh1_`yee'!=.), by(subdistr year_`yee')
	save $datadir/retmigrant_all1.dta, replace
	
	preserve
	keep if year_`yee'==1
	keep subdistr qid year_`yee'
	duplicates drop
	collapse (count) total_hh_`yee'=qid if (qid!=.), by(subdistr year_`yee')
	merge 1:m subdistr year_`yee' using $datadir/retmigrant_all1.dta, nogenerate
	
	save $datadir/retmigrant_conference.dta, replace
	restore
	use $datadir/retmigrant_conference.dta, replace

}


*** Create analysis sample from wave 6 with hh's with or without experience of crimes:
foreach path in $dw6m $dw8m {
 if "`path'" == "$dw6m" {
 	 use "`path'/shocksclean.dta", clear
 }
 if "`path'" == "$dw8m" {
 	use "`path'/shocks.dta", clear
	rename shocks__id _x31002
	recode _x31103 (4=2017) (5=2018) (6=2019), generate(_x31003a)
	rename _x31103a _x31003
	rename _x31104 _x31004
	rename _x31105a _x31005a
 }
 
 
 if inlist("`path'","$dw8m") {
		cap confirm variable _x10001 _x10002 _x10003 _x10004 _x10005
		if _rc == 0 {
 		local oldnames _x10001 _x10002 _x10003 _x10004 _x10005
		local newnames prov distr subdistr vill hid
		
			forval i = 1/5 {
				local oldvar : word `i' of `oldnames'
				local newname : word `i' of `newnames'

				cap confirm variable `newname'
				if _rc != 0 {
					clonevar `newname' = `oldvar'
				}
			}
		}
 }
	
	keep qid prov distr subdistr vill _x31002 _x31003 _x31003a _x31004


	codebook, compact
	tab _x31002, miss


*label list _x31002
* crimes coded as 7: Theft in general, ///
70: Theft of transportation (car, moterbike, bicycle), ///
71: Theft of livestocks, ///
72: Theft of crops or agricultural products, ///
73: Theft of other items, ///
74: Burglary, 75:Robbery, 76:Vandalism, ///
8: Conflict with neighbours in the village, ///
46: Being cheated at work/business for shocks variable _x31002



* Create dummies for experiences of crimes:
gen crime= (inlist(_x31002,7,70,71,72,73,74,75,76,8,46))

gen rural_crime= (inlist(_x31002,71,72))
gen other_crime= (inlist(_x31002,70,73,74,75,76))
gen conflict= (inlist(_x31002,46,8))


label variable crime "Dummy for crime victimization"

label variable rural_crime "Dummy for rural_style crime victimization"
label variable other_crime "Dummy for other crime victimization"
label variable conflict "Dummy for social conflicts"



*** Create dummies and count variables for crimes for each hh:
	egen hind = total((_x31004 == 1 & crime == 1)), by(qid)
	egen mednd = total((_x31004 == 2 & crime == 1)), by(qid)
	egen lownd = total((_x31004 == 3 & crime == 1)), by(qid)
	
	egen tot_cri = total(crime==1), by(qid) // total # of crimes
	
	egen tot_cri_subdistr = total(crime==1), by(subdistr) // total # of crimes

	label variable hind "Total high impact crime"
	label variable mednd "Total medium impact crime"
	label variable lownd "Total low impact crime"

	label variable tot_cri "Total number of crimes experienced"

	egen rural_nd = total((rural_crime == 1)), by(qid)
	egen other_nd = total((other_crime == 1)), by(qid)
	egen confl_nd = total((conflict == 1)), by(qid)


	label variable rural_nd "Total rural-style crime"
	label variable other_nd "Total other crime"
	label variable confl_nd "Total social conflicts"

	
	g int year1 = _x31003a
	g int month = _x31003

	* Save new data
	save "`path'/shocksclean_conference.dta", replace

	
* Trim down unnecessary variables for analysis:
	keep qid prov distr subdistr vill hind mednd lownd tot_cri tot_cri_subdistr ///
	other_nd rural_nd confl_nd

	duplicates drop qid prov distr subdistr vill, force
	codebook, compact

* Save new data
	save "`path'/shocksclean_conference_a.dta", replace
}

foreach path in $dw6m $dw8m {
	use "`path'/shocksclean_conference.dta", clear

	if "`path'" == "$dw8m" {
		append using "shocks_conference.dta"

	replace month = 4 if inlist(month,.,99) & crime==1

	
	egen hind_subdistr1 = total((_x31004 == 1 & crime == 1)), by(subdistr year1)
	egen mednd_subdistr1 = total((_x31004 == 2 & crime == 1)), by(subdistr year1)
	egen lownd_subdistr1 = total((_x31004 == 3 & crime == 1)), by(subdistr year1)
	
	egen tot_cri_subdistr1 = total(crime==1), by(subdistr year1) //total # of crimes

	egen other_nd_subdistr1 = total((other_crime == 1)), by(subdistr year1)
	egen rural_nd_subdistr1 = total((rural_crime == 1)), by(subdistr year1)
	egen confl_nd_subdistr1 = total((conflict == 1)), by(subdistr year1)
	}
	save "shocks_conference.dta", replace
}

	use "shocks_conference.dta", clear
	duplicates drop subdistr year1 month, force
	keep prov distr subdistr tot_cri_subdistr year1 month ///
	hind_subdistr1 mednd_subdistr1 lownd_subdistr1 tot_cri_subdistr1 ///
	other_nd_subdistr1 rural_nd_subdistr1 confl_nd_subdistr1
	
	gen date = ym(year1,month)
	format date %tm
	
	preserve
	keep if inrange(date,ym(2015,7),ym(2016,6))
	foreach var of varlist _all {
		if !inlist("`var'","prov","distr","subdistr"){
			rename `var' `var'_16
		}
	}
	save "$datadir/crimeclean_w6.dta", replace
	restore
	
	
	preserve
	keep if inrange(date,ym(2018,7),ym(2019,6))
	foreach var of varlist _all {
		if !inlist("`var'","prov","distr","subdistr"){
			rename `var' `var'_19
		}
	}
	save "$datadir/crimeclean_w8.dta", replace
	restore
