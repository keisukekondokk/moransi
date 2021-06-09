/**********************************************************
** (C) Keisuke Kondo
** Upload Date: March 31, 2018
** Updated Date: June 8, 2021
** 
** [Required Stata Modules]
** - spatgsa
** - splagvar
** - moransi
** - spgen
** NOTE: Install from SSC Archive
** 
** [Reference]
** Kondo, K (2015) "Spatial persistence of Japanese unemployment rates,"
** Japan and the World Economy, 36, pp. 113-122, 2015.
** NOTE: The replication data are used here.
**
**********************************************************/

/************************
** Spatial Weight Matrix
** from Distance Matrix
************************/

** Load Dataset
use "data/DTA_ur_1980_2005_all.dta", clear

** Call Mata to Make Spatial Weight Matrix
** NOTE: Take Distance Matrix from SPGEN Command
spgen ur2005, lon(lon) lat(lat) swm(pow 2) dunit(km) dist(.)
return list
matrix mW = r(W)

** Save Spatial Weight Matrix (Row-Standardized)
clear 
svmat mW
save "data/SWM_ur_dist2_std.dta", replace

/************************
** Moran's I Statistic
** Comparison using 3 commands
************************/

** Load Dataset
use "data/DTA_ur_1980_2005_all.dta", clear

** Load Spatial Weight Matrix for SPATGSA and SPLAGVAR
matrix drop _all
clear
set matsize 2000
spatwmat using "data/SWM_ur_dist2_std.dta", name(mW)

** Load Dataset
use "data/DTA_ur_1980_2005_all.dta", clear

** SPATGSA Command by Pisati
spatgsa ur2005, w(mW) moran

** SPLAGVAR Command by Jenty
splagvar ur2005, wname(mW) wfrom(Stata) moran(ur2005)

** MORNASI Command by Kondo
moransi ur2005, lon(lon) lat(lat) swm(pow 2) dist(.) dunit(km) det

/************************
** Moran Scatter Plot
** 
************************/

** Moran Scatter Plot
** NOTE: Coefficient is equal to Moran's I
egen std_ur2005 = std(ur2005)
spgen std_ur2005, lon(lon) lat(lat) swm(pow 2) dunit(km) dist(.)
rename splag1_std_ur2005_p w_std_ur2005

**
reg w_std_ur2005 std_ur2005, nocons

** Moran Scatte Plot
twoway (scatter w_std_ur2005 std_ur2005, ms(oh) yaxis(1 2) xaxis(1 2)) /*
	*/ (lfit w_std_ur2005 std_ur2005, lw(medthick) estopts(nocons)), /*
	*/ ytitle("W.Standardized Unemployment Rates", tstyle(size(large)) axis(1)) /*
	*/ xtitle("Standardized Unemployment Rates", tstyle(size(large)) height(6) axis(1)) /*
	*/ ytitle("", axis(2)) /*
	*/ xtitle("", axis(2)) /*
	*/ ylabel(-2(2)6, ang(h) labsize(large) format(%2.0f) nogrid axis(1)) /*
	*/ xlabel(-4(2)8, labsize(large) format(%2.0f) nogrid axis(1)) /*
	*/ ylabel(-2(2)6, ang(h) labsize(large) format(%2.0f) nogrid axis(2)) /*
	*/ xlabel(-4(2)8, labsize(large) format(%2.0f) nogrid axis(2)) /*
	*/ ysize(3) xsize(4) /*
	*/ yline(0, lwidth(thin) lcolor(gray) lpattern(dash)) /*
	*/ xline(0, lwidth(thin) lcolor(gray) lpattern(dash)) /*
	*/ legend(off) /*
	*/ graphregion(color(white) fcolor(white))
graph export "fig/FIG_moran_ur2005.png", as(png) replace
