/*************************************************
** (C) Keisuke Kondo
** Uploaded Date: 20 March 2025
** 
** [NOTES]
** Stata 15 or later is required to use the Sp commands.
** ssc install moransi
** net install sg162.pkg, replace
** ssc install splagvar
*************************************************/


** LOG START
log using "log/LOG_moransi_mesh_1km.log", replace text


/*************************************************
** SHAPE2DTA
** Convert Shapefiles to Stata DTA
*************************************************/

** Line of Railroad in Tokyo Metropolitan Area
spshape2dta "shp/SHP_line_railroad.shp", replace

** Polygon of Prefectures in Tokyo Metropolitan Area
spshape2dta "shp/SHP_pref_greater_tokyo.shp", replace

** Add Prefecture Code in Shapefile
use "SHP_pref_greater_tokyo.dta", clear
gen id_pref = prefCode
save "data/DTA_id_pref.dta", replace

** Add Prefecture Code in Shapefile
use "SHP_pref_greater_tokyo_shp.dta", clear
merge m:1 _ID using "data/DTA_id_pref.dta", keepusing(id_pref)
save "SHP_pref_greater_tokyo_shp.dta", replace

** Mesh Shapefile in Tokyo Metropolitan Area
spshape2dta "shp/SHP_mesh_1km_greater_tokyo.shp", replace

/*************************************************
** CSV2DTA
** Convert CSV to Stata DTA
*************************************************/

** Mesh data of 2015 population census
import delimited "data/CSV_mesh3_data_pc2015.csv", clear
save "data/DTA_mesh3_data_pc2015.dta", replace

/*************************************************
** Dataset
** 
** 
*************************************************/

** 
use "SHP_mesh_1km_greater_tokyo.dta", clear

** Delete Small Islands
drop if id_pref == 13 & lat < 35

** Number of Mesh Grid
count

** SPSET
spset

** Mesh ID
gen id_mesh3 = KEY_CODE
destring id_mesh3, replace
duplicates report id_mesh3 id_pref
duplicates report id_mesh3 
duplicates tag id_mesh3, gen(id_mesh3_multiple)
duplicates drop id_mesh3, force

** Merge Population Data
merge 1:1 id_mesh3 using "data/DTA_mesh3_data_pc2015.dta"
drop if _merge == 2
drop _merge 

** 
replace pop_total_all = 0 if pop_total_all == .
replace pop_total_male = 0 if pop_total_male == .
replace pop_total_female = 0 if pop_total_female == .

**
tab id_pref


** Moran's I
moransi pop_total_all, lon(lon) lat(lat) swm(pow 4) dist(.) dunit(km) large approx graph replace


** ==============================
** Map of Population 
** ==============================

** Map
grmap pop_total_all, ///
	fcolor(Blues) ///
	clmethod(quantile) ///
	clnumber(9) ///
	ocolor(none ...) ///
	ndocolor(none ...) ///
	legtitle("Population") ///
	legend(size(small) position(5)) ///
	legstyle(1) ///
	legcount /// 
	osize(vvthin .. vvthin) ///
	polygon(data("SHP_pref_greater_tokyo_shp.dta") osize(medthick) select(drop if _Y < 34.839))
graph export "fig/FIG_mesh_1km_pop.png", as(png) width(1600) replace

** ==============================
** Map of Statistical Significance
** ==============================

** Map
grmap lmoran_p_pop_total_all_p, ///
	clmethod(custom) ///
	clbreak(0 0.01 0.05 0.1 1) ///
	fcolor("green" "green%70" "green%30" none) ///
	osize(vvthin ...) ///
	ocolor(gs12 ...) ///
	ndocolor(none ...) ///
	legend(size(medium) position(2) order(2 "< 1 %" 3 "< 5 %" 4 "< 10 %" 5 "Not Significant")) ///
	legstyle(1) ///
	legcount /// 
	polygon(data("SHP_pref_greater_tokyo_shp.dta") osize(medthick) select(drop if _Y < 34.839))
graph export "fig/FIG_mesh_1km_localmoransi_significance.png", as(png) width(1600) replace


** ==============================
** Map of Statistical Significance
** ==============================

** Map
grmap lmoran_cat_pop_total_all_p if lmoran_p_pop_total_all_p < 0.10 , ///
	clmethod(custom) ///
	clbreak(0 1 2 3 4) ///
	fcolor("red" "red%40" "blue%40" "blue") ///
	osize(none ...) ///
	ocolor(none ...) ///
	ndocolor(none ...) ///
	legend(size(medium) position(2) order(2 "High-High" 3 "High-Low" 4 "Low-High" 5 "Low-Low" 6 "Not Significant" )) ///
	legstyle(1) ///
	legcount /// 
	line(data("SHP_line_railroad_shp.dta") size(vthin) color(gray)) ///
	polygon(data("SHP_pref_greater_tokyo_shp.dta") osize(medthick) select(drop if _Y < 34.839))
graph export "fig/FIG_mesh_1km_localmoransi_category.png", as(png) width(1600) replace
	

** ==============================
** Moran Scatter Plot
** ==============================

** 
qui: sum splag_pop_total_all_p
qui: local mean_wy = r(mean)
qui: sum pop_total_all
qui: local mean_y = r(mean)

** 
twoway ///
	(scatter splag_pop_total_all_p pop_total_all, msymbol(oh) yaxis(1 2) xaxis(1 2)) ///
	(lfit splag_pop_total_all_p pop_total_all, lw(thick)) ///
	, ///
	ytitle("Spatial Lag of Population in Mesh Grid", tstyle(size(medium)) axis(1)) ///
	xtitle("Population in Mesh Grid", tstyle(size(medium)) height(6) axis(1)) ///
	ytitle("", axis(2)) ///
	xtitle("", axis(2)) ///
	ylabel(, ang(h) labsize(medium) format(%2.0f) grid axis(1)) ///
	xlabel(, labsize(medium) format(%2.0f) grid axis(1)) ///
	ylabel(, axis(2)) ///
	xlabel(, axis(2)) ///
	ysize(2.5) ///
	xsize(4) ///
	yline(`mean_wy', lwidth(thin) lcolor(red) lpattern(dash)) ///
	xline(`mean_y', lwidth(thin) lcolor(red) lpattern(dash)) ///
	legend(off) ///
	graphregion(color(white) fcolor(white))
graph export "fig/FIG_scatter_1km_pop.png", as(png) width(1600) replace



** LOG END
log close
