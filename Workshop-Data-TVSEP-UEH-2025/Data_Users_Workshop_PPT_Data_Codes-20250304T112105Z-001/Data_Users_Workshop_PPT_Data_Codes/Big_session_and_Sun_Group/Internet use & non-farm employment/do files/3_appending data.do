*this do file is for appending two waves that we generated before. both data files are in the folder "datafinal". Please set up your directory before open data files.

cd "C:\Users\nguyettran_L\Dropbox\tvsep conference\TVSEP data-users presentations\internet&non-farm\dataout"

use household2016.dta, replace
append using household2017.dta

**check the panel
xtset QID year
/*

. xtset QID year
       panel variable:  QID (strongly balanced)
        time variable:  year, 2016 to 2017
                delta:  1 unit

*/
***************generate interaction term between internet and other variables: age, gender, ethnic member
gen inter_age=internet_work*age
replace inter_age=0 if inter_age==.

gen inter_gender=internet_work*gender
replace inter_gender=0 if inter_gender==.

gen inter_ethnic=internet_work*ethnicity
replace inter_ethnic=inter_ethnic==.

gen log_land=ln(pc_land+0.001)
replace log_land=0 if log_land==.

gen pc_nonfarm=income_nonfarm/HH_size
replace pc_nonfarm=0 if pc_nonfarm==.

***************************1. Instrumental variables estimation using heteroskedasticity-based instruments
xtset QID year
***************************
global household gender age married ethnicity year_school HH_size share_labor no_tv no_phone
preserve

ivreg2h pc_nonfarm (internet_work= ) $household,  gmm2s
eststo model1

ivreg2h non_farm (internet_work= ) $household,  gmm2s
eststo model2

restore

esttab using internet_work_example.rtf, se replace star(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)) se(par(( )) fmt(%9.3f))) stats(N ll chi2 p r2_p r2 r2_a idp jp cdf F Fdf1 Fdf2 Fp, fmt(%4.0f %4.2f %4.2f %6.3f))


*****2. fixed effect regression or random effect can be regressed when you could find external instruments for internet use variables
eststo clear

xtreg non_farm internet gender age married ethnicity year_school HH_size share_labor average_plot_distance log_land, fe 
eststo fe

xtreg non_farm internet gender age married ethnicity year_school HH_size share_labor average_plot_distance log_land, re 
eststo re

hausman fe re  // rule of thumb: Significant p-value (< 0.05): Use the fixed-effects model.


******************************************************************************************************************save the data
save panel_example_internet.dta, replace 
