# MORANSI: Stata module to compute Moran's I

The `moransi` command computes global and local Moran's *I* statistics in Stata.

## Install

### GitHub

```
net install moransi, replace from("https://raw.githubusercontent.com/keisukekondokk/moransi/main/")
```

### SSC

```
ssc install moransi, replace
```

## Manual
See the PDF manual in [`doc`](./doc) directory.

<pre>
.
|-- moransi.pdf //Manual
</pre>

## Demo Files
See three applied examples in  [`demo`](./demo) directory.

<pre>
.
|-- columbus //Stata replication code and data
|-- japan_mesh_pop //Stata replication code and data
|-- japan_muni_unemp //Stata replication code and data
</pre>

## Source Files
See [`ado`](./ado) directory. There are `moransi.ado` and `moransi.sthlp` files. 

<pre>
.
|-- moransi.ado //Stata ado file
|-- moransi.sthlp //Stata help file
</pre>

## Terms of Use
Users (hereinafter referred to as the User or Users depending on context) of the content on this web site (hereinafter referred to as the "Content") are required to conform to the terms of use described herein (hereinafter referred to as the Terms of Use). Furthermore, use of the Content constitutes agreement by the User with the Terms of Use. The contents of the Terms of Use are subject to change without prior notice.

### Copyright
The copyright of the developed code belongs to Keisuke Kondo.

### Copyright of Third Parties
The statistical data and shapefile of the Grid Square Statistics in the demo files were taken from the Portal Site of Official Statistics of Japan, e-Stat. The shapefiles of the railroad network were taken from the National Land Information of Ministry of Land, Infrastructure, Transport and Tourism. Users must confirm the terms of use of the e-Stat and National Land Information, prior to using the Content.

### Licence
The developed code is released under the MIT Licence.

### Disclaimer 
- Keisuke Kondo makes the utmost effort to maintain, but nevertheless does not guarantee, the accuracy, completeness, integrity, usability, and recency of the Content.
- Keisuke Kondo and any organization to which Keisuke Kondo belongs hereby disclaim responsibility and liability for any loss or damage that may be incurred by Users as a result of using the Content. 
- Keisuke Kondo and any organization to which Keisuke Kondo belongs are neither responsible nor liable for any loss or damage that a User of the Content may cause to any third party as a result of using the Content
- The Content may be modified, moved or deleted without prior notice.

## Author
Keisuke Kondo  
Senior Fellow, Research Institute of Economy, Trade and Industry  
Email: kondo-keisuke@rieti.go.jp  
URL: https://keisukekondokk.github.io/  

## Reference
Kondo, Keisuke (2018) "MORANSI: Stata module to compute Moran's *I*," Statistical Software Components S458473, Boston College Department of Economics.  
URL: https://ideas.repec.org/c/boc/bocode/s458473.html  

Kondo, Keisuke (2025) "Testing for Spatial Autocorrelation in Stata," RIEB Discussion Paper Series No.2025-03.  
URL: https://www.rieb.kobe-u.ac.jp/academic/ra/dp/English/DP2025-03.pdf  
