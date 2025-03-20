/*************************************************
** (C) Keisuke Kondo
** Uploaded Date: November 06, 2015
** Update Date: March 20, 2025
**
** [NOTES]
** Stata 15 or later is required to use the Sp commands.
** ssc install moransi
** net install sg162.pkg, replace
** ssc install splagvar
*************************************************/

** LOG START
log using "log/LOG_moransi_columbus.log", replace text


/*************************************************
** Dataset
** 
** 
*************************************************/

** Load Dataset
import excel "data/columbus.xlsx", sheet("columbus") firstrow clear
save "data/columbus.dta", replace


/*************************************************
** Estimation
** 
** 
*************************************************/

** Load Dataset
use "data/columbus.dta", clear

** Standardize Variable
egen std_CRIME = std(CRIME)

** Moran's I
moransi std_CRIME, lon(x_cntrd) lat(y_cntrd) swm(pow 8) dist(.) dunit(km) graph

** Save Spatial Weight Matrix
return list
matrix mDist = r(D)
matrix mW = r(W)
clear 
svmat mW
save "data/columbus_swm_dist8_std.dta", replace

/*************************************************
** Comparison with Other Commands
** 
** 
*************************************************/

** Load Spatial Weigh Matrix
matrix drop _all
clear
spatwmat using "data/columbus_swm_dist8_std.dta", name(mW)

** Load Dataset
use "data/columbus.dta", clear

** Standardize Variable
egen std_CRIME = std(CRIME)

** spatgsa
spatgsa std_CRIME, w(mW) moran

** splagvar
splagvar std_CRIME, wname(mW) wfrom(Stata) moran(std_CRIME) replace


** LOG END
log close
