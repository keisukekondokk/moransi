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

** 
drop if id_pref == 13 & lat < 35

** Number of Mesh Grid
count

** SPSET
spset

** 
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
sjlog using "log/output_moransi_mesh_1km", replace
** Moran's I
moransi pop_total_all, lon(lon) lat(lat) swm(pow 4) dist(.) dunit(km) ///
	large approx graph replace
sjlog close, replace



** Moran's I
sjlog using "log/output_moransi_mesh_1km_grmap", replace
** Map
grmap lmoran_cat_pop_total_all_p if lmoran_p_pop_total_all_p < 0.10 , ///
	clmethod(custom) ///
	clbreak(0 1 2 3 4) ///
	fcolor("red" "red%40" "blue%40" "blue") ///
	osize(none ...) ///
	ocolor(none ...) ///
	ndocolor(none ...) ///
	legend(size(medium) position(2) ///
		order(2 "High-High" 3 "High-Low" 4 "Low-High" 5 "Low-Low" ///
		6 "Not Significant" )) ///
	legstyle(1) ///
	legcount /// 
	line(data("SHP_line_railroad_shp.dta") size(vthin) color(gray)) ///
	polygon(data("SHP_pref_greater_tokyo_shp.dta") ///
		osize(medthick) select(drop if _Y < 34.839))
sjlog close, replace
