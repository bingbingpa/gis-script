@echo off
setlocal ENABLEDELAYEDEXPANSION
REM 건물 shape 파일 prefix
set building_name=TL_SPBD_BULD_
set dbname=lhdt
set port=15432
set user=postgres
set password=postgres

FOR /r %%f in (%1\build*.txt) do (
	REM 파일명
	echo %%~nf 
	REM 파일명 + 확장자
	echo %%~nf%%~xf 
	set csv_name=%%~nf
	REM txt 파일 첫 라인읽기   
	set /p texte=< %%~nf%%~xf 
	REM 첫라인 행정구역코드 읽어서 2자리만 끊어서 shape 파일과 매칭 
	set shape_name=%building_name%!texte:~0,2!
	
	REM powershell로 csv 파일로 변환 
	Powershell.exe -executionpolicy remotesigned -File  exec.ps1 %%~nf%%~xf !csv_name!.csv
	
	set sql=SELECT^
			!shape_name!.BDTYP_CD as BDTYP_CD,^
			!shape_name!.BD_MGT_SN as BD_MGT_SN,^
			!shape_name!.BSI_INT_SN as BSI_INT_SN,^
			!shape_name!.BSI_ZON_NO as BSI_ZON_NO,^
			!shape_name!.BULD_MNNM as BULD_MNNM,^
			!shape_name!.BULD_NM as BULD_NM,^
			!shape_name!.BULD_NM_DC as BULD_NM_DC,^
			!shape_name!.BULD_SE_CD as BULD_SE_CD,^
			!shape_name!.BULD_SLNO as BULD_SLNO,^
			!shape_name!.BUL_DPN_SE as BUL_DPN_SE,^
			!shape_name!.BUL_ENG_NM as BUL_ENG_NM,^
			!shape_name!.BUL_MAN_NO as BUL_MAN_NO,^
			!shape_name!.EMD_CD as EMD_CD,^
			!shape_name!.EQB_MAN_SN as EQB_MAN_SN,^
			!shape_name!.GRO_FLO_CO as GRO_FLO_CO,^
			!shape_name!.LI_CD as LI_CD,^
			!shape_name!.LNBR_MNNM as LNBR_MNNM,^
			!shape_name!.LNBR_SLNO as LNBR_SLNO,^
			!shape_name!.MNTN_YN as MNTN_YN,^
			!shape_name!.MVMN_DE as MVMN_DE,^
			!shape_name!.MVMN_RESN as MVMN_RESN,^
			!shape_name!.MVM_RES_CD as MVM_RES_CD,^
			!shape_name!.NTFC_DE as NTFC_DE,^
			!shape_name!.OPERT_DE as OPERT_DE,^
			!shape_name!.POS_BUL_NM as POS_BUL_NM,^
			!shape_name!.RDS_MAN_NO as RDS_MAN_NO,^
			!shape_name!.RDS_SIG_CD as RDS_SIG_CD,^
			!shape_name!.RN_CD as RN_CD,^
			!shape_name!.SIG_CD as SIG_CD,^
			!shape_name!.UND_FLO_CO as UND_FLO_CO,^
			!csv_name!.bjd_cd as bjd_cd,^
			!csv_name!.ctprvn_nm as ctprvn_nm,^
			!csv_name!.sig_nm as sig_nm,^
			!csv_name!.emd_nm as emd_nm,^
			!csv_name!.li_nm as li_nm,^
			!csv_name!.rn as rn,^
			!csv_name!.ah_yn as ah_yn
			
		
	ogr2ogr -lco ENCODING=CP949 -sql "!sql! from !shape_name! left join '!csv_name!.csv'.!csv_name! on !shape_name!.BD_MGT_SN = !csv_name!.BD_MGT_SN" !shape_name!_merge.shp !shape_name!.shp
	
)

FOR /r %%f in (%1\*merge*.shp) do (
	echo %%~nf 
	echo %%~nf%%~xf 
	
	for /f "tokens=4 delims=_" %%a in ("%%~nf") do (
	  set table_name=TL_SPBD_BULD_%%a
	)
	
	ogr2ogr -s_srs EPSG:5179 -t_srs EPSG:4326 --config SHAPE_ENCODING CP949 --config GDAL_FILENAME_IS_UTF8 NO -f PostgreSQL PG:"host=localhost port=%port% dbname=%dbname% user=%user% password=%password%" %%~nf%%~xf -nln address_!table_name! -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -lco SCHEMA=public
	
	psql -h 127.0.0.1 -U %user% -p %port% -d %dbname% -c "VACUUM FULL address_!table_name!"	
	
)

FOR /r %%f in (%1\LSMD_CONT_LDREG*.shp) do (
	echo %%~nf 
	echo %%~nf%%~xf 
	
	for /f "tokens=4 delims=_" %%a in ("%%~nf") do (
	  set table_name=LSMD_CONT_LDREG_%%a
	)
	
	ogr2ogr -s_srs EPSG:5174 -t_srs EPSG:4326 --config SHAPE_ENCODING CP949 --config GDAL_FILENAME_IS_UTF8 NO -f PostgreSQL PG:"host=localhost port=%port% dbname=%dbname% user=%user% password=%password%" %%~nf%%~xf -nln address_!table_name! -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -lco SCHEMA=public
	
	psql -h 127.0.0.1 -U %user% -p %port% -d %dbname% -c "VACUUM FULL address_!table_name!"	
	
)





