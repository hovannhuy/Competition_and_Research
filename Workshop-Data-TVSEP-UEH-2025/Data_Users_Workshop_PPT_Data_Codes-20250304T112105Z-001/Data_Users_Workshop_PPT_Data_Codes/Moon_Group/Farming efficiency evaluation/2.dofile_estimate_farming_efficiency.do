

*********************************************
// Append all datasets 2007-2017
*********************************************
 cd "E:\TVSEP data updated 2022\data workshop\dataclean_crop"
clear all
use "crop_2007.dta", replace
destring prov distr subdistr vill, replace

append using "crop_2010.dta"
append using "crop_2013.dta"
append using "crop_2017.dta"

// Merge with labor data
merge 1:1 QID year using "labor_farm2007-2017.dta"

// Drop unmatched cases
drop if _merge == 2

drop _merge



***********************************************
//final data set
***********************************************


***make to per ha 
 local source PValue_Crop_per_crop  Pcost_seed Pcost_hand_weed Pcost_preparation Pcost_fertilizer Pcost_pesticides Pcost_harvesting Pcost_irrigation Pcost_hiredlabor 
foreach x of varlist `source' {
   replace `x' = `x' * 0.16 
   lab var `x' "`: var lab `x''(PPP USD/Ha)"	 
  
}
*


// Generating log-transformed variables for production function
gen Y1 = ln(PValue_Crop_per_crop + 0.001)  // Log of crop output value
gen x1 = ln(crop_land_ha + 0.001)    // Log of land cultivated
gen x2 = ln(labor_farm)                 // Log of farm labor
gen x3 = ln(Pcost_hiredlabor + 0.001)   // Log of hired labor cost
gen x4 = ln(Pcost_seed + 0.001)          // Log of seed cost
gen x5 = ln(Pcost_hand_weed + 0.001)       // Log of weeding cost
gen x6 = ln(Pcost_preparation + 0.001)     // Log of land preparation cost
gen x7 = ln(Pcost_fertilizer + 0.001)    // Log of fertilizer cost
gen x8 = ln(Pcost_pesticides + 0.001)    // Log of pesticide cost
gen x9 = ln(Pcost_harvesting + 0.001)       // Log of harvest cost
gen x10 = ln(Pcost_irrigation + 0.001)   // Log of irrigation cost


//Regression Results and Multicollinearity Check

 corr Y1 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10
 
 reg Y1 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10
 vif
 
 
 
 // Generate Quadratic Terms (Squared Inputs)
foreach var in x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 {
    gen `var'_sq = `var'^2
}


//Generate Interaction Terms (Cross-Products of Inputs)
 gen x1_x2 = x1*x2
 gen x1_x3 = x1*x3
 gen x1_x4 = x1*x4
 gen x1_x5 = x1*x5
 gen x1_x6 = x1*x6
 gen x1_x7 = x1*x7
 gen x1_x8 = x1*x8
 gen x1_x9 = x1*x9
 gen x1_x10 = x1*x10
 gen x2_x3 = x2*x3
 gen x2_x4 = x2*x4
 gen x2_x5 = x2*x5
 gen x2_x6 = x2*x6
 gen x2_x7 = x2*x7
 gen x2_x8 = x2*x8
 gen x2_x9 = x2*x9
 gen x2_x10 = x2*x10
 gen x3_x4 = x3*x4
 gen x3_x5 = x3*x5
 gen x3_x6 = x3*x6
 gen x3_x7 = x3*x7
 gen x3_x8 = x3*x8
 gen x3_x9 = x3*x9
 gen x3_x10 = x3*x10
 gen x4_x5 = x4*x5
 gen x4_x6 = x4*x6
 gen x4_x7 = x4*x7
 gen x4_x8 = x4*x8
 gen x4_x9 = x4*x9
 gen x4_x10 = x4*x10
 gen x5_x6 = x5*x6
 gen x5_x7 = x5*x7
 gen x5_x8 = x5*x8
 gen x5_x9 = x5*x9
 gen x5_x10 = x5*x10
 gen x6_x7 = x6*x7
 gen x6_x8 = x6*x8
 gen x6_x9 = x6*x9
 gen x6_x10 = x6*x10
 gen x7_x8 = x7*x8
 gen x7_x9 = x7*x9
 gen x7_x10 = x7*x10
 gen x8_x9 = x8*x9
 gen x8_x10 = x8*x10
 gen x9_x10 = x9*x10



 // Calculate CRE Household-Level Means for Inputs
foreach var in x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 {
    bysort QID: egen mean_`var' = mean(`var')
}


// Set Panel Data Structure
destring QID, replace
xtset QID year


///Estimating farming efficiency

///(1)Translog stochastic frontier production estimation from the true random-effects model

sfpanel Y1 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x1_sq x2_sq x3_sq x4_sq x5_sq x6_sq x7_sq ///
 x8_sq x9_sq x10_sq x1_x2 x1_x3 x1_x4 x1_x5 x1_x6 x1_x7 x1_x8 x1_x9 x1_x10 x2_x3 ///
 x2_x4 x2_x5 x2_x6 x2_x7 x2_x8 x2_x9 x2_x10 x3_x4 x3_x5 x3_x6 x3_x7 x3_x8 x3_x9 x3_x10 ///
 x4_x5 x4_x6 x4_x7 x4_x8 x4_x9 x4_x10 x5_x6 x5_x7 x5_x8 x5_x9 x5_x10 x6_x7 x6_x8 x6_x9 x6_x10 ///
 x7_x8 x7_x9 x7_x10 x8_x9 x8_x10 x9_x10, model(tre) rescale  base(7) simtype(genhalton) nsim(50) difficult cluster(vill)

predict farm_efficiency_model1, jlms
hist farm_efficiency_model1 , normal
kdensity farm_efficiency_model1, normal
 
 /*
 
initial:       Log simulated-likelihood = -9205.2136
rescale:       Log simulated-likelihood = -9205.2136
rescale eq:    Log simulated-likelihood = -9199.3594
Iteration 0:   Log simulated-likelihood = -9199.3594  
Iteration 1:   Log simulated-likelihood = -9181.8121  
Iteration 2:   Log simulated-likelihood = -9175.0452  
Iteration 3:   Log simulated-likelihood = -9175.0044  
Iteration 4:   Log simulated-likelihood = -9175.0044  

True random-effects model (exponential)              Number of obs =      6800
Group variable: QID                               Number of groups =      2027
Time variable: year                             Obs per group: min =         1
                                                               avg =       3.4
                                                               max =         4

                                                     Prob > chi2   =    0.0000
Log simulated-likelihood = -9175.0044                Wald chi2(65)  =  10690.73

Number of Randomized Halton Sequences = 50
Base for Randomized Halton Sequences  = 7
                                 (Std. Err. adjusted for 220 clusters in vill)
------------------------------------------------------------------------------
             |               Robust
          Y1 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
Frontier     |
          x1 |   .4304821   .0787478     5.47   0.000     .2761392    .5848249
          x2 |   .2583236   .1053286     2.45   0.014     .0518834    .4647639
          x3 |   .0488283   .0121892     4.01   0.000     .0249378    .0727187
          x4 |   .0384687   .0171491     2.24   0.025     .0048572    .0720803
          x5 |   .0420833   .0169492     2.48   0.013     .0088635    .0753032
          x6 |   .0062802   .0140619     0.45   0.655    -.0212806     .033841
          x7 |   .0339523    .027645     1.23   0.219    -.0202309    .0881355
          x8 |   .0694248   .0151071     4.60   0.000     .0398153    .0990342
          x9 |   .0390661   .0110012     3.55   0.000     .0175042     .060628
         x10 |   .0473165   .0243725     1.94   0.052    -.0004527    .0950856
       x1_sq |   .0549073   .0156446     3.51   0.000     .0242444    .0855701
       x2_sq |  -.0467757   .0356601    -1.31   0.190    -.1166682    .0231167
       x3_sq |    .009052   .0009489     9.54   0.000     .0071921    .0109119
       x4_sq |   .0048941     .00258     1.90   0.058    -.0001625    .0099508
       x5_sq |   .0060243   .0021293     2.83   0.005      .001851    .0101976
       x6_sq |  -.0043473   .0014323    -3.04   0.002    -.0071545     -.00154
       x7_sq |   .0251002   .0019795    12.68   0.000     .0212204    .0289799
       x8_sq |   .0067352   .0018806     3.58   0.000     .0030493     .010421
       x9_sq |    .007991   .0012691     6.30   0.000     .0055036    .0104784
      x10_sq |   .0036002    .002935     1.23   0.220    -.0021523    .0093528
       x1_x2 |  -.0025292   .0398197    -0.06   0.949    -.0805744    .0755161
       x1_x3 |  -.0063423   .0042476    -1.49   0.135    -.0146673    .0019828
       x1_x4 |   -.014369    .005926    -2.42   0.015    -.0259838   -.0027542
       x1_x5 |  -.0081693   .0048794    -1.67   0.094    -.0177327    .0013941
       x1_x6 |   .0045401    .005807     0.78   0.434    -.0068415    .0159217
       x1_x7 |  -.0175721   .0085571    -2.05   0.040    -.0343436   -.0008006
       x1_x8 |   .0024604   .0048576     0.51   0.613    -.0070604    .0119811
       x1_x9 |   .0002302   .0037336     0.06   0.951    -.0070875    .0075478
      x1_x10 |  -.0089747   .0062902    -1.43   0.154    -.0213033    .0033539
       x2_x3 |  -.0026405   .0058391    -0.45   0.651    -.0140848    .0088039
       x2_x4 |  -.0000945   .0071608    -0.01   0.989    -.0141294    .0139403
       x2_x5 |   .0016898   .0058579     0.29   0.773    -.0097915    .0131711
       x2_x6 |  -.0071893   .0061851    -1.16   0.245    -.0193119    .0049333
       x2_x7 |  -.0128168   .0147496    -0.87   0.385    -.0417254    .0160919
       x2_x8 |  -.0055588   .0050639    -1.10   0.272     -.015484    .0043663
       x2_x9 |   .0023373   .0044545     0.52   0.600    -.0063934     .011068
      x2_x10 |   .0055589   .0072472     0.77   0.443    -.0086454    .0197633
       x3_x4 |  -.0012911   .0009773    -1.32   0.186    -.0032066    .0006244
       x3_x5 |   .0017798   .0009891     1.80   0.072    -.0001587    .0037183
       x3_x6 |   .0010931    .000934     1.17   0.242    -.0007375    .0029237
       x3_x7 |  -.0004021    .001457    -0.28   0.783    -.0032577    .0024535
       x3_x8 |   .0001173   .0005781     0.20   0.839    -.0010158    .0012503
       x3_x9 |   .0001954   .0005181     0.38   0.706    -.0008201    .0012109
      x3_x10 |  -.0004389   .0007072    -0.62   0.535    -.0018249    .0009472
       x4_x5 |  -.0007647   .0006911    -1.11   0.269    -.0021191    .0005898
       x4_x6 |   .0010718   .0009035     1.19   0.235    -.0006989    .0028426
       x4_x7 |  -.0003274   .0023334    -0.14   0.888    -.0049007     .004246
       x4_x8 |  -.0002315   .0005996    -0.39   0.699    -.0014068    .0009438
       x4_x9 |  -.0007321   .0006357    -1.15   0.249     -.001978    .0005138
      x4_x10 |  -.0000639   .0007389    -0.09   0.931    -.0015122    .0013844
       x5_x6 |   .0008695   .0007644     1.14   0.255    -.0006286    .0023677
       x5_x7 |  -.0022754   .0019268    -1.18   0.238    -.0060518     .001501
       x5_x8 |     .00005   .0006929     0.07   0.942    -.0013079     .001408
       x5_x9 |   .0011569   .0005729     2.02   0.043      .000034    .0022797
      x5_x10 |   .0015389    .001025     1.50   0.133    -.0004701    .0035479
       x6_x7 |  -.0029739   .0015319    -1.94   0.052    -.0059764    .0000286
       x6_x8 |  -.0005617   .0007535    -0.75   0.456    -.0020386    .0009153
       x6_x9 |   -.000491   .0006129    -0.80   0.423    -.0016924    .0007103
      x6_x10 |   .0018146   .0007997     2.27   0.023     .0002472    .0033821
       x7_x8 |  -.0051928   .0020565    -2.53   0.012    -.0092236   -.0011621
       x7_x9 |  -.0001934   .0013975    -0.14   0.890    -.0029324    .0025456
      x7_x10 |  -.0028059   .0024729    -1.13   0.257    -.0076528    .0020409
       x8_x9 |   .0001445   .0005097     0.28   0.777    -.0008546    .0011435
      x8_x10 |   .0008867   .0006948     1.28   0.202    -.0004751    .0022484
      x9_x10 |   .0008757   .0006033     1.45   0.147    -.0003068    .0020581
       _cons |   4.982325   .1479512    33.68   0.000     4.692345    5.272304
-------------+----------------------------------------------------------------
Usigma       |
       _cons |  -.1328673   .1027245    -1.29   0.196    -.3342037    .0684692
-------------+----------------------------------------------------------------
Vsigma       |
       _cons |  -1.795698   .0727206   -24.69   0.000    -1.938228   -1.653169
-------------+----------------------------------------------------------------
Theta        |
       _cons |   .2574565   .0222682    11.56   0.000     .2138116    .3011014
-------------+----------------------------------------------------------------
     sigma_u |    .935725    .048061    19.47   0.000     .8461134    1.034827
     sigma_v |   .4074451   .0148148    27.50   0.000      .379419    .4375413
      lambda |   2.296567   .0508584    45.16   0.000     2.196887    2.396248

 *//
 
 
 

///(2)Translog stochastic frontier production estimation from the true random-effects model with Mundlak’s adjustments (CRE)
 ///Estimate Stochastic Frontier Model
  sfpanel Y1 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x1_sq x2_sq x3_sq x4_sq x5_sq x6_sq x7_sq ///
 x8_sq x9_sq x10_sq x1_x2 x1_x3 x1_x4 x1_x5 x1_x6 x1_x7 x1_x8 x1_x9 x1_x10 x2_x3 ///
 x2_x4 x2_x5 x2_x6 x2_x7 x2_x8 x2_x9 x2_x10 x3_x4 x3_x5 x3_x6 x3_x7 x3_x8 x3_x9 x3_x10 ///
 x4_x5 x4_x6 x4_x7 x4_x8 x4_x9 x4_x10 x5_x6 x5_x7 x5_x8 x5_x9 x5_x10 x6_x7 x6_x8 x6_x9 x6_x10 ///
 x7_x8 x7_x9 x7_x10 x8_x9 x8_x10 x9_x10 mean_x1 mean_x2 mean_x3 mean_x4 mean_x5 mean_x6 mean_x7 ///
 mean_x8 mean_x9 mean_x10, model(tre)  rescale  base(7) simtype(genhalton) nsim(50) difficult cluster(vill)

 
 
  
 /*
 
initial:       Log simulated-likelihood = -9180.2489
rescale:       Log simulated-likelihood = -9180.2489
rescale eq:    Log simulated-likelihood = -9173.7747
Iteration 0:   Log simulated-likelihood = -9173.7747  
Iteration 1:   Log simulated-likelihood = -9155.5157  
Iteration 2:   Log simulated-likelihood = -9149.3135  
Iteration 3:   Log simulated-likelihood = -9149.2722  
Iteration 4:   Log simulated-likelihood = -9149.2722  

True random-effects model (exponential)              Number of obs =      6800
Group variable: QID                               Number of groups =      2027
Time variable: year                             Obs per group: min =         1
                                                               avg =       3.4
                                                               max =         4

                                                     Prob > chi2   =    0.0000
Log simulated-likelihood = -9149.2722                Wald chi2(75)  =  12243.13

Number of Randomized Halton Sequences = 50
Base for Randomized Halton Sequences  = 7
                                 (Std. Err. adjusted for 220 clusters in vill)
------------------------------------------------------------------------------
             |               Robust
          Y1 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
Frontier     |
          x1 |   .3755144   .0826505     4.54   0.000     .2135225    .5375064
          x2 |   .2337097   .1063848     2.20   0.028     .0251994      .44222
          x3 |   .0524738   .0122444     4.29   0.000     .0284754    .0764723
          x4 |   .0340542   .0171616     1.98   0.047     .0004181    .0676904
          x5 |   .0444125   .0170146     2.61   0.009     .0110644    .0777606
          x6 |   .0110276   .0145154     0.76   0.447     -.017422    .0394773
          x7 |   .0230094   .0278973     0.82   0.409    -.0316683    .0776872
          x8 |   .0672584   .0156651     4.29   0.000     .0365553    .0979615
          x9 |   .0360841   .0109884     3.28   0.001     .0145473     .057621
         x10 |   .0443483   .0234778     1.89   0.059    -.0016672    .0903639
       x1_sq |    .054395   .0156441     3.48   0.001     .0237332    .0850568
       x2_sq |   -.029581   .0355768    -0.83   0.406    -.0993102    .0401483
       x3_sq |   .0092046   .0009471     9.72   0.000     .0073484    .0110609
       x4_sq |   .0046807   .0025061     1.87   0.062     -.000231    .0095925
       x5_sq |   .0061076   .0021011     2.91   0.004     .0019895    .0102256
       x6_sq |  -.0041191   .0014367    -2.87   0.004    -.0069351   -.0013031
       x7_sq |   .0245537   .0019466    12.61   0.000     .0207385     .028369
       x8_sq |   .0065744   .0019121     3.44   0.001     .0028267    .0103221
       x9_sq |   .0074905   .0012749     5.88   0.000     .0049918    .0099893
      x10_sq |    .003451   .0028778     1.20   0.230    -.0021894    .0090914
       x1_x2 |  -.0104147   .0396527    -0.26   0.793    -.0881325    .0673031
       x1_x3 |  -.0071396   .0040547    -1.76   0.078    -.0150866    .0008074
       x1_x4 |  -.0136787   .0058028    -2.36   0.018    -.0250521   -.0023053
       x1_x5 |  -.0078807   .0048819    -1.61   0.106     -.017449    .0016875
       x1_x6 |   .0043096   .0057776     0.75   0.456    -.0070142    .0156335
       x1_x7 |  -.0162491   .0085266    -1.91   0.057    -.0329609    .0004626
       x1_x8 |   .0023106   .0048727     0.47   0.635    -.0072398     .011861
       x1_x9 |   .0008221   .0037607     0.22   0.827    -.0065488     .008193
      x1_x10 |  -.0097291   .0061435    -1.58   0.113    -.0217701     .002312
       x2_x3 |  -.0017242   .0057305    -0.30   0.763    -.0129558    .0095073
       x2_x4 |    .000724   .0071601     0.10   0.919    -.0133096    .0147576
       x2_x5 |   .0015891    .005812     0.27   0.785    -.0098023    .0129805
       x2_x6 |  -.0057807   .0062939    -0.92   0.358    -.0181165     .006555
       x2_x7 |  -.0126112   .0145518    -0.87   0.386    -.0411323    .0159099
       x2_x8 |  -.0062373   .0051065    -1.22   0.222     -.016246    .0037713
       x2_x9 |    .002682   .0044428     0.60   0.546    -.0060256    .0113897
      x2_x10 |   .0053355   .0073014     0.73   0.465     -.008975    .0196459
       x3_x4 |  -.0012704   .0009583    -1.33   0.185    -.0031487    .0006079
       x3_x5 |   .0017113   .0010035     1.71   0.088    -.0002556    .0036782
       x3_x6 |   .0008617   .0009037     0.95   0.340    -.0009096     .002633
       x3_x7 |  -.0001358   .0013992    -0.10   0.923    -.0028782    .0026066
       x3_x8 |   .0001151   .0005806     0.20   0.843    -.0010228     .001253
       x3_x9 |   .0001417   .0005056     0.28   0.779    -.0008492    .0011326
      x3_x10 |  -.0005296    .000701    -0.76   0.450    -.0019036    .0008444
       x4_x5 |  -.0008059   .0006951    -1.16   0.246    -.0021683    .0005565
       x4_x6 |    .001056   .0009102     1.16   0.246     -.000728      .00284
       x4_x7 |  -.0004564   .0023326    -0.20   0.845    -.0050282    .0041153
       x4_x8 |  -.0002011    .000601    -0.33   0.738    -.0013791    .0009769
       x4_x9 |  -.0007271   .0006181    -1.18   0.239    -.0019385    .0004843
      x4_x10 |  -.0001914   .0007243    -0.26   0.792    -.0016111    .0012283
       x5_x6 |   .0008414   .0007611     1.11   0.269    -.0006503    .0023331
       x5_x7 |   -.002451   .0018828    -1.30   0.193    -.0061413    .0012392
       x5_x8 |   3.52e-06   .0006912     0.01   0.996    -.0013511    .0013582
       x5_x9 |   .0012366     .00058     2.13   0.033     .0000998    .0023734
      x5_x10 |   .0016302   .0010264     1.59   0.112    -.0003815    .0036419
       x6_x7 |  -.0029965   .0014604    -2.05   0.040    -.0058589   -.0001341
       x6_x8 |  -.0006037   .0007559    -0.80   0.424    -.0020852    .0008778
       x6_x9 |  -.0004947   .0006079    -0.81   0.416    -.0016862    .0006967
      x6_x10 |   .0017415   .0007843     2.22   0.026     .0002044    .0032786
       x7_x8 |  -.0053055   .0020451    -2.59   0.009    -.0093139   -.0012972
       x7_x9 |  -.0000796   .0013602    -0.06   0.953    -.0027456    .0025864
      x7_x10 |   -.002417   .0023824    -1.01   0.310    -.0070864    .0022524
       x8_x9 |   .0002048   .0005056     0.41   0.685    -.0007862    .0011958
      x8_x10 |   .0009091   .0006842     1.33   0.184     -.000432    .0022502
      x9_x10 |   .0007953   .0005956     1.34   0.182    -.0003719    .0019626
     mean_x1 |   .1006668   .0317948     3.17   0.002     .0383502    .1629835
     mean_x2 |  -.0249131   .0428997    -0.58   0.561    -.1089949    .0591687
     mean_x3 |  -.0172825   .0059683    -2.90   0.004    -.0289803   -.0055848
     mean_x4 |   .0065576   .0052655     1.25   0.213    -.0037625    .0168777
     mean_x5 |  -.0036779   .0076813    -0.48   0.632    -.0187329    .0113772
     mean_x6 |  -.0225349   .0094714    -2.38   0.017    -.0410985   -.0039713
     mean_x7 |   .0263759    .013494     1.95   0.051    -.0000718    .0528237
     mean_x8 |    .005612   .0057503     0.98   0.329    -.0056585    .0168824
     mean_x9 |   .0018107    .005207     0.35   0.728    -.0083949    .0120163
    mean_x10 |   .0096141    .006772     1.42   0.156    -.0036589     .022887
       _cons |   5.042856   .1560543    32.31   0.000     4.736995    5.348717
-------------+----------------------------------------------------------------
Usigma       |
       _cons |  -.1308363   .1028078    -1.27   0.203     -.332336    .0706634
-------------+----------------------------------------------------------------
Vsigma       |
       _cons |  -1.823904   .0722569   -25.24   0.000    -1.965525   -1.682283
-------------+----------------------------------------------------------------
Theta        |
       _cons |   .2563594   .0218386    11.74   0.000     .2135566    .2991622
-------------+----------------------------------------------------------------
     sigma_u |   .9366757   .0481488    19.45   0.000      .846904    1.035963
     sigma_v |   .4017392   .0145142    27.68   0.000     .3742757     .431218
      lambda |   2.331552   .0512153    45.52   0.000     2.231171    2.431932
------------------------------------------------------------------------------

 */
 
 
//sfpanel → Stochastic Frontier Panel Data Estimation.
//Y1 → Log-transformed output (dependent variable).
//x1, x2, ..., x10 → Main inputs.
//x1_sq, x2_sq, ..., x10_sq → Quadratic terms (capture non-linearity).
//x1_x2, ..., x9_x10 → Interaction terms (capture complementarities).
//mean_x1, ..., mean_x10 → Household-level means.
//model(tre) → Time-varying random effects (TRE) model.
//rescale base(7) → Rescales inefficiency estimates.
//simtype(genhalton) nsim(50) → Uses Halton sequences with 50 simulations.
//difficult → Helps when convergence is challenging.
//cluster(vill) → Adjusts standard errors at the village level.  //
 
 
predict farm_efficiency_model2, jlms
hist farm_efficiency_model2 , normal
kdensity farm_efficiency_model2, normal



*****************************************************************************************
