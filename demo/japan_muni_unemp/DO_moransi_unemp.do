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


** LOG START
log using "log/LOG_moransi_columbus.log", replace text


/************************
** Moran's I Statistic
** Spatial Weight Matrix from Distance Matrix
************************/

** Load Dataset
use "data/DTA_ur_1980_2005_all.dta", clear

** 
egen std_ur2005 = std(ur2005)

** MORNASI Command by Kondo
moransi std_ur2005, lon(lon) lat(lat) swm(pow 2) dist(.) dunit(km) det graph replace
graph export "fig/FIG_moran_ur2005.svg", replace
rename splag_std_ur2005_p w_std_ur2005

** Call Mata to Make Spatial Weight Matrix
** NOTE: Take Distance Matrix from SPGEN Command
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

** 
egen std_ur2005 = std(ur2005)

** Load Spatial Weight Matrix for SPATGSA and SPLAGVAR
matrix drop _all
set matsize 2000
spatwmat using "data/SWM_ur_dist2_std.dta", name(mW)

** SPATGSA Command by Pisati
spatgsa std_ur2005, w(mW) moran

** SPLAGVAR Command by Jenty
splagvar std_ur2005, wname(mW) wfrom(Stata) moran(std_ur2005)



/************************
** Local Moran's I Statistics on Map
** 
************************/

** Shapfile of Municipality in Municipality
spshape2dta "shp/SHP_poly_muni_seirei_pc2011.shp", replace

** Shapfile of Prefecture in Japan
spshape2dta "shp/SHP_poly_pref_pc2011.shp", replace

** Use shapefiles
use "SHP_poly_muni_seirei_pc2011", clear

** Merge Local Moran's I
gen id_muni_new = cityCode
merge 1:1 id_muni_new using "data/DTA_ur_1980_2005_all_export.dta", keepusing(name* ur* std_* w_* lmoran_*)
gen d_nodata = (_merge == 1 )
drop _merge

** 
format %3.1f ur2005

** 
spset 

** ==============================
**　MAP: Unemployment Rates 2005
** ==============================
grmap ur2005, ///
	clmethod(quantile) ///
	clnum(9) ///
	fcolor(Reds) ///
	ocolor(none ...) ///
	ndocolor(none ...) ///
	legtitle("Unemployment Rates") ///
	legend(size(medium) position(11)) ///
	legstyle(1) ///
	legcount /// 
	polygon(data("SHP_poly_pref_pc2011_shp.dta") ocolor(black) osize(vthin)) 
graph export "fig/FIG_map_ur2005.svg", replace
graph export "fig/FIG_map_ur2005.png", as(png) width(1600) replace


** ==============================
**　MAP: Statistical Significance of Local Moran's I
** ==============================
grmap lmoran_p_std_ur2005_p, ///
	clmethod(custom) ///
	clbreak(0 0.01 0.05 0.1 1) ///
	fcolor("green" "green%70" "green%30" none) ///
	ocolor(none ...) ///
	ndocolor(none ...) ///
	legend(size(medium) position(11) order(2 "< 1 %" 3 "< 5 %" 4 "< 10 %" 5 "Not Significant")) ///
	legstyle(1) ///
	legcount /// 
	polygon(data("SHP_poly_pref_pc2011_shp.dta") ocolor(black) osize(vthin)) 
graph export "fig/FIG_map_ur2005_lmoransi_significance.svg", replace
graph export "fig/FIG_map_ur2005_lmoransi_significance.png", as(png) width(1600) replace


** ==============================
**　MAP: Category of Local Moran's I
** ==============================
grmap lmoran_cat_std_ur2005_p if lmoran_p_std_ur2005_p < 0.10 , ///
	clmethod(custom) ///
	clbreak(0 1 2 3 4) ///
	fcolor("red" "red%40" "blue%40" "blue") ///
	ocolor(none ...) ///
	ndocolor(none ...) ///
	legend(size(medium) position(11) order(2 "High-High" 3 "High-Low" 4 "Low-High" 5 "Low-Low" 6 "Not Significant" )) ///
	legstyle(1) ///
	legcount /// 
	polygon(data("SHP_poly_pref_pc2011_shp.dta") ocolor(black) osize(vthin)) 
graph export "fig/FIG_map_ur2005_lmoransi_cluster.svg", replace
graph export "fig/FIG_map_ur2005_lmoransi_cluster.png", as(png) width(1600) replace



** LOG END
log close
