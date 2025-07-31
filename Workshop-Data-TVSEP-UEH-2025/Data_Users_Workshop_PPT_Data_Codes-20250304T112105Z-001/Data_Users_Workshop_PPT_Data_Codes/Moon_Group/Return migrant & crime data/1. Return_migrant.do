/*****************************************************************
		*********************
		Return migrant in Nakhon Phanom
		*********************		
Outline:


*****************************************************************/

***************************
***** Creating analysis sample of return migrant *****
***************************

clear all 
set more off

* Set directory

global datadir "..."

cd $datadir


global dw6m "$datadir/w6"

global dw8m "$datadir/w8"


* Add extension to variable names & merge new ID var GID to each survey
foreach path in $dw6m $dw8m {

use "`path'/migrant1_conference.dta", clear


foreach var of varlist _all {
	if !inlist("`var'","qid","prov","distr","subdistr","vill","hid","_x21001") {
		if "`path'" == "$dw6m" {
		cap rename `var' `var'_16
		}
		else if "`path'" == "$dw8m" {
		cap rename `var' `var'_19
		}
	}
}

cap confirm variable qid
if _rc == 0 {
	if "`path'" == "$dw6m" {
		save "$datadir/migrant_conference.dta", replace
	}
	else {
		cap merge 1:1 _x21001 qid using "$datadir/migrant_conference.dta"
		if "`path'" == "$dw8m" {
		cap rename _merge _merge_19
		}
	}
}
		save "$datadir/migrant_conference.dta", replace
}


	merge 1:1 _x21001 qid using "$datadir/migrant_w5.dta", keep(master match) nogenerate
	merge 1:1 _x21001 qid using "$datadir/migrant_w6.dta", keep(master match) nogenerate


	gen retmig_work_16 = (mig_work_13==1)&(((belong_16==1|inrange(_x21016_16,330,366))&inrange(_x21016_16,0.0001,366)& /// 
					inlist(_x21018_16,.,26,98,99) & inlist(_x21019_16,.,1,2,3,4,98,99))| ///
					mig_all_16==0) if year_16==1
					
	gen retmig_other_16 = (mig_other_13==1)&(((belong_16==1|inrange(_x21016_16,330,366))&inrange(_x21016_16,0.0001,366)& ///
					inlist(_x21018_16,.,26,98,99) & inlist(_x21019_16,.,1,2,3,4,98,99))| ///
					mig_all_16==0) if year_16==1

	replace retmig_work_16=1 if retmig_work_16==.&inlist(_x21018_13,4,41,42,5,6)& ///
					(_x21008_16<=_x21004_16)&mig_all_16==0&year_16==1& ///
					(!inrange(_x21010_19,6,97)|inrange(_x21010_16,6,97))
					
	replace retmig_other_16=1 if retmig_work_16==.&retmig_other_16==.& ///
					(_x21008_16<=_x21004_16)& mig_all_16==0&year_16==1& ///
					(!inrange(_x21010_19,6,97)|inrange(_x21010_16,6,97))

	replace retmig_work_16=0 if retmig_work_16==.&_x21004_16>=_x21008_16& ///
						_x21008_16!=.&inrange(_x21016_16,0,30)&mig_all_16==1& ///
						year_16==1
	replace retmig_other_16=0 if retmig_other_16==.&_x21004_16>=_x21008_16& ///
						_x21008_16!=.&inrange(_x21016_16,0,30)&mig_all_16==1& ///
						year_16==1

	replace retmig_other_16=0 if (retmig_work_16==1|retmig_other_16==.)&year_16==1
	replace retmig_work_16=0 if (retmig_other_16==1|retmig_work_16==.)&year_16==1
								
	egen retmig_all_16 = rowtotal(retmig_work_16 retmig_other_16) if year_16==1

	gen rural_16 = (retmig_all_16==1&year_16==1&!(inrange(_x21019_16,7,97)))
	replace rural_16 = . if !(retmig_all_16==1&year_16==1)
	replace rural_16 = 0 if retmig_all_16==1&year_16==1&inrange(_x21019_16,7,97)
	
	gen urban_16 = 1-rural_16 if retmig_all_16==1&year_16==1
	

	merge 1:1 _x21001 qid using "$datadir/migrant_w8.dta", keep(master match) nogenerate

	
	gen retmig_work_19= (mig_work_16==1)&(((belong_19==1|inrange(_x21016_19,330,370))&inrange(_x21016_19,0.0001,366) & /// 
					inlist(_x21018_19,.,26,98,99) & inlist(_x21019_19,.,1,2,3,4,5,98,99))|mig_work_19==0) ///
					if year_19==1
					
	gen retmig_other_19 = (mig_other_16==1)&(((belong_19==1|inrange(_x21016_19,330,370))&inrange(_x21016_19,0.0001,366) & ///
					inlist(_x21018_19,.,26,98,99) & inlist(_x21019_19,.,1,2,3,4,5,98,99))|mig_all_19==0) ///
					if year_19==1


	replace retmig_work_19=1 if retmig_work_19==.&inlist(_x21018_16,4,41,42,5,6)& ///
							(_x21008_19<=_x21004_19)&mig_all_19==0&year_19==1& ///
							(inrange(_x21010_19,6,90))

	replace retmig_other_19=1 if retmig_other_19==.&retmig_work_19==.&year_19==1& ///
							(_x21008_19<=_x21004_19)&mig_all_19==0& ///
							(inrange(_x21010_19,6,97))

	replace retmig_work_19=0 if retmig_work_19==.&year_19==1&mig_all_19==1& ///
							_x21004_19==_x21008_19&_x21008_19!=.&inrange(_x21016_19,0,30)
	replace retmig_other_19=0 if retmig_other_19==.&year_19==1&mig_all_19==1& ///
							_x21004_19==_x21008_19&_x21008_19!=.&inrange(_x21016_19,0,30)

	replace retmig_other_19=0 if (retmig_work_19==1|retmig_other_19==.)&year_19==1
	replace retmig_work_19=0 if (retmig_other_19==1|retmig_work_19==.)&year_19==1
							
	egen retmig_all_19 = rowtotal(retmig_work_19 retmig_other_19) if year_19==1

	gen rural_19 = (retmig_all_19==1&year_19==1&!(inrange(_x21019_19,7,97)))
	replace rural_19 = . if !(retmig_all_19==1&year_19==1)
	replace rural_19 = 0 if retmig_all_19==1&year_19==1&(inrange(_x21019_19,7,97))
	
	gen urban_19 = 1-rural_19 if retmig_all_19==1&year_19==1


save "$datadir/migrant_conference.dta", replace


* Check migrant and return migrant for all waves
foreach yr in 16 19 {
	preserve
	keep if year_`yr'==1
foreach var in retmig_work_`yr' retmig_other_`yr' {
  tab `var', mi
}
	restore
}
