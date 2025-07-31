***created by Nguyet Tran: on 1st March 2025
***this do file is using for running estimation with Instrumental variables estimation using heteroskedasticity-based instruments
****this data file in the folder "dataout", please set your directory before open the dataset

cd "C:\Users\nguyettran_L\Dropbox\tvsep conference\TVSEP data-users presentations\internet&non-farm\dataout"

use full_final_panel.dta, clear

**** transformation to log 
gen log_land=ln( pc_land+0.0001)
gen log_sav=ln(pc_saving+0.0001)

lab var log_land "land area per capita, log"
lab var log_sav "saving amount per capita, log"

****interaction terms
gen inter_age=internet_work*head_age
gen inter_educ=internet_work*mean_school

****grouping variables so that we dont need to repeat in every commands
#delimit ;
global hh_control head_age head_gender married mean_school HH_size share_labor no_shocks social_mem ethnicity no_phone log_sav log_land vill_dishos vill_forest Hue Daklak 
;
#delimit cr


***regression 1: Impact of internet use on non-farm employment
* dependent variables: non-farm: a dummy variable equals 1 if household has members engaging in non-farm employment
                      * pc_nonfarm: per capita non-farm income in PPP USD
eststo clear
preserve  //using this method might center the data, we therefore have to preserve before running


ivreg2h non_farm (internet_work = vil_inteshare ) $hh_control ,  gmm2s robust cluster(vill) 
eststo est1

ivreg2h pc_nonfarm (internet_work =  vil_inteshare ) $hh_control ,  gmm2s  robust cluster(vill) 
eststo est2

restore

esttab using internet_work.rtf, se replace star(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)) se(par(( )) fmt(%9.3f))) stats(N ll chi2 p r2_p r2 r2_a idp jp cdf F Fdf1 Fdf2 Fp, fmt(%4.0f %4.2f %4.2f %6.3f))


********regression 2: adding interaction term between internet use variable and other variables: inter_age inter_gender inter_ethnic /// please make sure that when adding these interactions, both component variables are included in the models. For example: internet_work, head_age and inter_age; internet_work, head_gender and inter_gender


eststo clear

preserve  //using this method might center the data, we therefore have to preserve before running

ivreg2h non_farm (internet_work inter_age = vil_inteshare ) $hh_control ,  gmm2s robust cluster(vill) 
eststo est1

ivreg2h pc_nonfarm (internet_work inter_age =  vil_inteshare ) $hh_control ,  gmm2s  robust cluster(vill) 
eststo est2

restore

esttab using internet_work_age.rtf, se replace star(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)) se(par(( )) fmt(%9.3f))) stats(N ll chi2 p r2_p r2 r2_a idp jp cdf F Fdf1 Fdf2 Fp, fmt(%4.0f %4.2f %4.2f %6.3f))


*****inter_educ
eststo clear

preserve  //using this method might center the data, we therefore have to preserve before running

ivreg2h non_farm (internet_work inter_educ = vil_inteshare ) $hh_control ,  gmm2s robust cluster( vill) 
eststo est1

ivreg2h pc_nonfarm (internet_work inter_educ =  vil_inteshare ) $hh_control ,  gmm2s  robust cluster( vill ) 
eststo est2

restore

esttab using internet_work_edu.rtf, se replace star(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(%9.3f)) se(par(( )) fmt(%9.3f))) stats(N ll chi2 p r2_p r2 r2_a idp jp cdf F Fdf1 Fdf2 Fp, fmt(%4.0f %4.2f %4.2f %6.3f))


