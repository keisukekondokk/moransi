
/*************************************************
** Dataset
** 
** 
*************************************************/

** 
spshape2dta "shp/SHP_pref_greater_tokyo.shp", replace

**
use "SHP_pref_greater_tokyo.dta", clear
gen id_pref = prefCode
save "data/DTA_id_pref.dta", replace

**
use "SHP_pref_greater_tokyo_shp.dta", clear
merge m:1 _ID using "data/DTA_id_pref.dta", keepusing(id_pref)
save "SHP_pref_greater_tokyo_shp.dta", replace


/*************************************************
** Dataset
** 
** 
*************************************************/


import delimited "data/CSV_mesh3_data_pc2015.csv", clear
save "data/DTA_mesh3_data_pc2015.dta", replace


** 
spshape2dta "shp/SHP_mesh_1km_greater_tokyo.shp", replace

/*************************************************
** Dataset
** 
** 
*************************************************/

**
use "SHP_mesh_1km_greater_tokyo.dta", clear
drop if id_pref == 13 & lat < 35

count

**
spset

** 
gen id_mesh3 = KEY_CODE
destring id_mesh3, replace
duplicates report id_mesh3 id_pref
duplicates report id_mesh3 
duplicates tag id_mesh3, gen(id_mesh3_multiple)
duplicates drop id_mesh3, force

**
merge 1:1 id_mesh3 using "data/DTA_mesh3_data_pc2015.dta"
drop if _merge == 2
drop _merge 

**
replace pop_total_all = 0 if pop_total_all == .
replace pop_total_male = 0 if pop_total_male == .
replace pop_total_female = 0 if pop_total_female == .

**
tab id_pref

/*************************************************
** Moran's I
** 
** 
*************************************************/

** Moran's I
moransi pop_total_all, lon(lon) lat(lat) swm(bin) dist(5) dunit(km) approx

** Spatial Lag
egen std_pop_total_all = std(pop_total_all)
spgen std_pop_total_all, lon(lon) lat(lat) swm(bin) dist(5) dunit(km) large replace

/*************************************************
** Map
** 
** 
*************************************************/

** Map
grmap pop_total_all, ///
	fcolor(Blues) ///
	clmethod(quantile) clnumber(9) ///
	osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin) ///
	polygon(data(SHP_pref_greater_tokyo_shp.dta) select(drop if _Y < 34.839))
graph export "fig/FIG_mesh_1km_pop.png", as(png) replace


/*************************************************
** Moran Scatter Plot
** 
** 
*************************************************/

** 
twoway (scatter splag1_std_pop_total_all_b std_pop_total_all, yaxis(1 2) xaxis(1 2)) ///
	(lfit splag1_std_pop_total_all_b std_pop_total_all, lw(thick) estopts(nocons)) ///
	, ///
	ytitle("W.Standardized Population", tstyle(size(large)) axis(1)) ///
	xtitle("Standardized Population", tstyle(size(large)) height(6) axis(1)) ///
	ytitle("", axis(2)) ///
	xtitle("", axis(2)) ///
	ylabel(-2(2)6, ang(h) labsize(large) format(%2.0f) nogrid axis(1)) ///
	xlabel(-2(2)6, labsize(large) format(%2.0f) nogrid axis(1)) ///
	ylabel(-2(2)6, ang(h) labsize(large) format(%2.0f) nogrid axis(2)) ///
	xlabel(-2(2)6, labsize(large) format(%2.0f) nogrid axis(2)) ///
	ysize(3) ///
	xsize(4) ///
	yline(0, lwidth(thin) lcolor(gray) lpattern(dash)) ///
	xline(0, lwidth(thin) lcolor(gray) lpattern(dash)) ///
	legend(off) ///
	graphregion(color(white) fcolor(white))
graph export "fig/FIG_scatter_1km_pop.png", as(png) replace

