@echo off
FOR /r %%f in (%1\*.shp) do (
	echo %%~nf
	echo %%~nf%%~xf
	
	ogr2ogr -a_srs EPSG:5187 --config SHAPE_ENCODING CP949 --config GDAL_FILENAME_IS_UTF8 NO -f PostgreSQL PG:"host=localhost port=5432 dbname=gis user=postgres password=postgres" %%~nf%%~xf -nln %%~nf -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -lco SCHEMA=public
	
	psql -h 127.0.0.1 -U postgres -d gis -c "VACUUM FULL %%~nf"
)