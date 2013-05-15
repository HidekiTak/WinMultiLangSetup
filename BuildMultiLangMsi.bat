: BuildMultiLangMsi.bat [ToSlnFile [ToBaseVdprojFile]]

@echo off
setlocal 
:: enabledelayedexpansion


IF NOT DEFINED BuildConfiguration SET BuildConfiguration=Release
IF NOT DEFINED BuildPlatform SET BuildPlatform=Any CPU

: ----------------------------------------------------
: Set DevEnv
:
IF NOT DEFINED DevEnv SET DevEnv=devenv
"%DevEnv%" /version
if not "%ERRORLEVEL%" == "0" set DevEnv="C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"

IF NOT DEFINED MsBuild SET MsBuild=msbuild
"%MsBuild%" /version
if not "%ERRORLEVEL%" == "0" set MsBuild=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MsBuild.exe
 
: ----------------------------------------------------
: Set Solution File
:

set SlnDir=.\
set SlnFn=

IF NOT ""%1""=="""" call :SLN_DIR "%~dp1" "%~n1"
IF ""%SlnFn%"" == """" (
  FOR %%f in ("%SlnDir%*.sln") DO CALL :GET_SLN "%%f"
)


echo SlnDir="%SlnDir%"
echo SlnFn="%SlnFn%"
set BaseSln=%SlnDir%%SlnFn%.sln
echo BaseSln="%BaseSln%"

IF NOT EXIST "%BaseSln%" (
  echo Not Exist "%BaseSln%"
  Exit /B -1
)

: ----------------------------------------------------
: Set Vdproj File
:

set VdprojDir=
set VdprojFn=
set VdprojLn=10000

IF NOT ""%2""=="""" (
  IF NOT EXIST "%2" (
    echo Not Exist "%2"
    Exit /B -1
  )
  call :VDPROJ_DIR "%~dp2" "%~n2"
) else (
  FOR /d %%d in ("%SlnDir%\*") do (
    FOR %%f in ("%%d\*.vdproj") do call :VDPROJ_FIND "%%f"
  )
)

IF NOT defined VdprojFn (
  echo Not Exist Vdproj File
  Exit /B -1
)

echo VdprojDir="%VdprojDir%"
echo VdprojFn="%VdprojFn%"

set BaseVdproj=%VdprojDir%%VdprojFn%.vdproj
echo BaseVdproj="%BaseVdproj%"

IF NOT DEFINED DefaultLocale IF EXIST "%VdprojDir%\default_locale.txt" SET /P DefaultLocale=<"%VdprojDir%\default_locale.txt"
IF NOT DEFINED DefaultLocale SET DefaultLocale=en-us

SET DefLocVdproj="%VdprojDir%%VdprojFn%.%DefaultLocale%.vdproj"

"%MsBuild%" "%BaseSln%" /nologo /p:Configuration="%BuildConfiguration%" /p:Platform="%BuildPlatform%" /t:Rebuild

FOR %%f in ("%VdprojDir%*.vdproj") do (
  IF NOT "%BaseVdproj%" == "%%f" IF NOT %DefLocVdproj% == "%%f" (
    COPY /Y "%%f" "%BaseVdproj%"
    echo "%%f"
    %DevEnv% "%BaseSln%" /build "%BuildConfiguration%|%BuildPlatform%" /project "%BaseVdproj%" /Out "vs_errors.txt"
  )
)

COPY /Y %DefLocVdproj% "%BaseVdproj%"
echo %DefLocVdproj%
%DevEnv% "%BaseSln%" /build "%BuildConfiguration%|%BuildPlatform%" /project "%BaseVdproj%" /Out "vs_errors.txt"

endlocal
exit /b

:GET_SLN
 SET SlnFn=%~n1
EXIT /B

:SLN_DIR
 SET SlnDir=%~1
 SET SlnFn=%~2
EXIT /B

:VDPROJ_DIR
 SET VdprojDir=%~1
 SET VdprojFn=%~2
EXIT /B

:VDPROJ_FIND
 SET Fn=%~n1
 call :STRLEN "%Fn%"
 IF NOT ""%VdprojFn%""=="""" IF %VdprojLn% LEQ %str_len%  EXIT /B
 SET VdprojLn=%str_len%
 SET VdprojDir=%~dp1
 SET VdprojFn=%Fn%
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
