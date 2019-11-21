@ECHO OFF

SET ERROR=0
SET RUN_PSQL=
SET PG_USER=postgres
SET PG_DATABASE=test
SET "SQL_FILE=%tmp%\dbinit~%RANDOM%.sql"
  
PUSHD %~dp0
SET CUR_PATH=%CD%
POPD

:trySystemPsql
  FOR /f "delims=" %%i IN ('where /R "C:\Program Files\PostgreSQL" psql.exe') DO SET RUN_PSQL=%%i
  rem --- we might be on amd64 having only x86 installed ---

  IF "%RUN_PSQL%"=="" IF DEFINED ProgramFiles(x86) IF NOT "%PROCESSOR_ARCHITECTURE%"=="x86" (
      rem --- restart the batch in x86 mode---
      ECHO Warning: No psql found in path.
      ECHO Retry using Wow64 filesystem [32bit environment] redirection.
      %SystemRoot%\SysWOW64\cmd.exe /c %0 %*
      exit /b %ERRORLEVEL%
  )

  IF "RUN_PSQL%"=="" GOTO noPsql
GOTO createdb

:noPsql
    ECHO no psql executable could be found.
GOTO end

:run
  ECHO %RUN_PSQL%
  ECHO Please wait while initializing database ...
  ECHO.

  ECHO %CUR_PATH%
  ECHO %SQL_FILE%
GOTO createdb

:createdb
  ECHO CREATE DATABASE "%PG_DATABASE%" > %SQL_FILE%
  ECHO     WITH                        >> %SQL_FILE%
  ECHO         OWNER = "%PG_USER%"     >> %SQL_FILE%
  ECHO         ENCODING = 'UTF8'       >> %SQL_FILE%
  ECHO         LC_COLLATE = 'C'        >> %SQL_FILE%
  ECHO         LC_CTYPE = 'C'          >> %SQL_FILE%
  ECHO         TEMPLATE=template0      >> %SQL_FILE%
  ECHO         TABLESPACE = pg_default >> %SQL_FILE%
  ECHO         CONNECTION LIMIT = -1;  >> %SQL_FILE%
  ECHO.                                >> %SQL_FILE%
  
  "%RUN_PSQL%" -U "%PG_USER%"  -f "%SQL_FILE%"

rem  del "%SQL_FILE%"
GOTO createtb

:createtb
  ECHO CREATE EXTENSION postgis; > %SQL_FILE%
  ECHO CREATE EXTENSION pgrouting; >> %SQL_FILE%
  FOR %%d IN ("ddl","index","trigger","dml") DO (
    FOR /f %%i IN ('dir %%d\*.sql /B /A:-D-H /S') DO (
      echo %%i
      type "%%i" >> "%SQL_FILE%"
    )
  )
  
  "%RUN_PSQL%" -U "%PG_USER%" -d "%PG_DATABASE%" -f "%SQL_FILE%"
  
rem  del "%SQL_FILE%"
GOTO end

:end
  IF %error% == 1 ECHO Database initialization failed.
  ECHO.
PAUSE