@echo off
FOR /r %%f in (%1\*.tif) do (
	echo %%~nf
	echo %%~nf%%~xf
	
	C:\PROGRA~1\QGIS3~1.4\bin\gdalwarp -s_srs EPSG:5186 -t_srs EPSG:4326 -dstnodata 255.0 -r near -of GTiff D:/ndtp/basemap/origin/5000cut_10cm/%%~nf%%~xf D:/ndtp/basemap/translate/%%~nf%%~xf	
)