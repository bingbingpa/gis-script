@echo off

set restapi=http://localhost:8080/geoserver/rest
set login=admin:geoserver
set workspace=hmd
set store=hmd


FOR /r %%f in (%1\*.sld) do (
	echo %%~nf
	echo %%~nf%%~xf
	
	rem style
	echo -v -u %login% -XPOST -H "Content-type: text/xml" -d "<style><name>%%~nf</name><filename>%sldfile%</filename></style>" %restapi%/workspaces/%workspace%/styles
			
	rem upload the SLD definition to the style
	echo -v -u %login% -XPUT -H "Content-type: application/vnd.ogc.sld+xml" -d @%%~nf%%~xf %restapi%/workspaces/%workspace%/styles/%%~nf

	rem apply style
	echo -v -u %login% -XPUT -H "Content-type: text/xml" -d "<layer><enabled>true</enabled><defaultStyle><name>%%~nf</name><workspace>%workspace%</workspace></defaultStyle></layer>" %restapi%/layers/%workspace%:%%~nf

)