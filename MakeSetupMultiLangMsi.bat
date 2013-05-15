: MakeSetupMultiLangMsi.bat [ToBaseMsiFile]

@echo off
setlocal

IF NOT DEFINED SCRIPT_PATH SET SCRIPT_PATH=C:\Program Files\Microsoft Platform SDK\Samples\SysMgmt\Msi\Scripts\

set BaseDir=
set BaseFn=
IF NOT "%1"=="" call :DIV_DIR "%~dp1" "%~n1"
IF "%BaseDir%" == "" (
  FOR /d %%d in (.\*) DO IF EXIST "%%d\*.msi" CALL :FIND_MSI_DIR "%%d"
)

echo BaseDir: "%BaseDir%"
echo BaseFn:  "%BaseFn%"

set BaseMsi=%BaseDir%%BaseFn%.msi
set TargetMsi=%BaseDir%%BaseFn%.mlt.msi
:
: Check Base Msi File
:
IF NOT EXIST "%BaseMsi%" (
 echo not exists "%BaseMsi%"
 EXIT /B
)
echo BaseMsi is "%BaseMsi%"
COPY /Y "%BaseMsi%" "%TargetMsi%"

::
:: Check Default Locale
:: 
SET DefLang=en-us
IF EXIST "%BaseDir%\default_locale.txt" SET /P DefLang=<"%BaseDir%\default_locale.txt"
echo Default Locale is "%DefLang%"

SET langs=
SET DefLcid=
for /F %%i in ( ' type "%~dp0LocaleIds.txt" ' ) do call :DIV %%i

IF NOT "%langs%"=="" (
  "%SCRIPT_PATH%WiLangId.vbs" "%TargetMsi%" Package %DefLcid%%langs%
  echo ok: rename "%TargetMsi%" to "%BaseMsi%" for deploy
) ELSE (
  echo fail: Not MultiLangMsi
)
endlocal
exit /b

:DIV_DIR
 SET BaseDir=%~1
 SET BaseFn=%~2
EXIT /B

:DIV
   echo %1:: %2
 IF /i "%2"=="%DefLang%" (
  SET DefLcid=%1
 ) ELSE (
  IF EXIST "%BaseDir%\%BaseFn%.%2.msi" (
   echo %1: %2
   "%SCRIPT_PATH%WiGenXfm.vbs" "%TargetMsi%" "%BaseDir%%BaseFn%.%2.msi" %1.mst
   ADDSUMINFO4MST.vbs "%TargetMsi%" "%BaseDir%%BaseFn%.%2.msi" %1.mst
   "%SCRIPT_PATH%WiSubStg.vbs" "%TargetMsi%" %1.mst %1
   SET langs=%langs%,%1
  )
 )
EXIT /B

:FIND_MSI_DIR
  SET BaseDir=%~f1\
  SET BaseFn=
  SET /a BaseFnLen=1000
  FOR %%f in ("%BaseDir%*.msi") do call :FIND_MSI_FILE "%%f"

EXIT /B
:: call :FIND_MSI_FILE "%%f"

:FIND_MSI_FILE
 SET Fn=%~n1
 call :STRLEN "%Fn%"
 IF NOT ""%BaseFn%""=="""" IF %BaseFnLen% LEQ %str_len%  EXIT /B
 SET /A BaseFnLen=%str_len%
 SET BaseFn=%Fn%
EXIT /B



:STRLEN
  SET /A str_len=0
  SET temp_str=%1
:STRLENL
  if defined temp_str (
    SET /A str_len += 1
    SET temp_str=%temp_str:~1%
    GOTO STRLENL
  )
EXIT /B