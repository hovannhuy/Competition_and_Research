clear all 
set more off

* Set directory

global datadir "..."

cd $datadir


global dw6m "$datadir/w6/modified"

global dw8m "$datadir/w8/modified"


use "shocks_conference.dta", clear
keep if crime==1

	gen date = ym(year1,month)
	format date %tm


gen year_ = 2016 if inrange(date, tm(2015,7), tm(2016,6))

replace year_ = 2019 if inrange(date, tm(2018,7), tm(2019,6))

foreach y in 2016 2019 {
	preserve
	keep if year_==`y'
	
foreach num in 7 8 46 70 71 72 73 74 75 76 {
	gen crime_`num' = (_x31002==`num')
	replace crime_7 = crime_`num' if year_==2013 & inrange(`num',70,76) & crime_`num'==1
	replace crime_`num' = 0 if year_==2013 & inrange(`num',70,76)

	bysort crime_`num': egen severity_`num' = mean(_x31004) if crime_`num'==1
	egen temp_severity_`num' = max(severity_`num')
	replace severity_`num' = temp_severity_`num'
}
	
cap desctable crime_7 crime_8 crime_46 crime_70 crime_71 crime_72 crime_73 crime_74 crime_75 crime_76 year_, ///
	filename("descr_stat_crime_`y'_conference") stats(N mean sd min max)

cap desctable severity_7 severity_8 severity_46 severity_70 severity_71 severity_72 severity_73 severity_74 severity_75 severity_76 year_, ///
	filename("descr_stat_crime2_`y'_conference") stats(N mean sd min max)
	
restore
}


use "$datadir/migrant_conference.dta", clear

// comparing 16, 19
foreach var in female age pyinccap farm nonfarm thai edu_yrs unemp healthy outlabor urban {
	gen `var'=.
}


foreach yr in 16 19 {
	gen female_`yr' = _x21003_`yr'-1 if year_`yr'==1
	gen age_`yr' = _x21004_`yr' if year_`yr'==1
	replace urban_`yr' = . if year_`yr'==1&retmig_all_`yr'!=1
}

	
	preserve
	keep if retmig_all_19==1
	gen ID = _n
	reshape long female_ age_ farm_ nonfarm_ outlabor_ thai_ edu_yrs_ unemp_ healthy_ urban_, i(ID) j(year)

	egen group_ = group(urban_)

	cap desctable female_ age_ farm_ nonfarm_ outlabor_ thai_ edu_yrs_ unemp_ healthy_ urban_, ///
	filename("diff_urban_rural_conference_19") stats(N mean sd min max) group(group_)

	estpost ttest female_ age_ farm_ nonfarm_ outlabor_ thai_ edu_yrs_ unemp_ healthy_ urban_, by(group_)
	esttab . using "$datadir/diff_urban_rural_conference_19.csv", replace cells("mu_1 mu_2 b(star) t p") label nonotes compress
	restore
