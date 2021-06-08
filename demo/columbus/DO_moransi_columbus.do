/*************************************************
** (C) Keisuke Kondo
** Uploaded Date: November 06, 2015
** Update Date: June 08, 2021
**
** [NOTES]
** ssc install esttab
** ssc install spgen
*************************************************/


/*************************************************
** Dataset
** 
** 
*************************************************/

** Load Dataset
import excel "data/columbus.xlsx", sheet("columbus") firstrow clear
save "data/columbus.dta", replace

** Load Dataset
use "data/columbus.dta", clear

** Call Mata to Make Spatial Weight Matrix
spgen CRIME, lon(x_cntrd) lat(y_cntrd) swm(pow 8) dunit(km) dist(.)
return list
matrix mDist = r(D)
matrix mW = r(W)

** Save Spatial Weight Matrix
clear 
svmat mW
save "data/columbus_swm_dist8_std.dta", replace

** Load Spatial Weigh Matrix
matrix drop _all
clear
spatwmat using "data/columbus_swm_dist8_std.dta", name(mW)


/*************************************************
** Estimation
** 
** 
*************************************************/

** Load Dataset
use "data/columbus.dta", clear

** Standardize Variable
egen std_CRIME = std(CRIME)

** Call Mata to Make Spatial Weight Matrix
spgen std_CRIME, lon(x_cntrd) lat(y_cntrd) swm(pow 8) dunit(km) dist(.)


** Coefficient is equal to Moran's I
reg splag1_std_CRIME_p std_CRIME

**
spatgsa std_CRIME, w(mW) moran

**
splagvar std_CRIME, wname(mW) wfrom(Stata) moran(std_CRIME) replace

**
moransi CRIME, lon(x_cntrd) lat(y_cntrd) swm(pow 8) dist(.) dunit(km)

