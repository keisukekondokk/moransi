/**********************************************************
** (C) Keisuke Kondo
** Upload Date: March 20, 2025
** 
** [NOTES]
** Stata 15 or later is required to use the Sp commands.
** ssc install moransi
** net install sg162.pkg, replace
** ssc install splagvar
** 
** [Reference]
** Kondo, K (2015) "Spatial persistence of Japanese unemployment rates,"
** Japan and the World Economy, 36, pp. 113-122, 2015.
** NOTE: The replication data are used here.
**********************************************************/


/************************
** Moran's I Statistic
** Spatial Weight Matrix from Distance Matrix
************************/

** Load Dataset
use "data/DTA_ur_1980_2005_all.dta", clear

** 
egen std_ur2005 = std(ur2005)

** MORNASI Command by Kondo
sjlog using "log/output_moransi_unemp", replace
moransi std_ur2005, lon(lon) lat(lat) swm(pow 2) dist(.) dunit(km) det graph replace
graph export "fig/FIG_moran_ur2005.svg", replace
sjlog close, replace

** Moran Scatterplot
sjlog using "log/output_moransi_unemp_scatter", replace
twoway (scatter splag_std_ur2005_p std_ur2005, ms(oh) yaxis(1 2) xaxis(1 2)) ///
	(lfit splag_std_ur2005_p std_ur2005, lw(medthick) estopts(nocons)), ///
	ytitle("W.Standardized Unemployment Rates", tstyle(size(large)) axis(1)) ///
	xtitle("Standardized Unemployment Rates", tstyle(size(large)) height(6) axis(1)) ///
	ytitle("", axis(2)) ///
	xtitle("", axis(2)) ///
	ylabel(-2(2)6, ang(h) labsize(large) format(%2.0f) nogrid axis(1)) ///
	xlabel(-4(2)8, labsize(large) format(%2.0f) nogrid axis(1)) ///
	ylabel(-2(2)6, ang(h) labsize(large) format(%2.0f) nogrid axis(2)) ///
	xlabel(-4(2)8, labsize(large) format(%2.0f) nogrid axis(2)) ///
	ysize(3) xsize(4) ///
	yline(0, lwidth(thin) lcolor(gray) lpattern(dash)) ///
	xline(0, lwidth(thin) lcolor(gray) lpattern(dash)) ///
	legend(off) ///
	graphregion(color(white) fcolor(white))
graph export "FIG_moran_ur2005.svg", replace
sjlog close, replace

