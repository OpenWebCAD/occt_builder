ECHO ON

SET VERSION=7.6.2
SET OCCT_VER=occt-%VERSION%
SET HASH=bb368e271e24f63078129283148ce83db6b9670a
SET HASHL=bb368e2

if exist %VCINSTALLDIR% ( goto skip_vc_install )
CALL "C:/Program Files (x86)/Microsoft Visual Studio/2019/BuildTools/VC/Auxiliary/Build/vcvars64.bat"

:skip_vc_install

SET PLATFORM=win64
SET ROOTFOLDER=%~dp0
SET ARCHIVE_FOLDER=%ROOTFOLDER%dist\%PLATFORM%
SET DISTFOLDER=%ARCHIVE_FOLDER%\%OCCT_VER%
SET ARCHIVE=%OCCT_VER%-%PLATFORM%.zip
SET FULL_ARCHIVE=%ARCHIVE_FOLDER%\%ARCHIVE%
SET BUILDFOLDER=build_%OCCT_VER%
set GENERATOR=Visual Studio 16 2019

ECHO OFF

ECHO skip downloading if %OCCT_VER% folder exists
if exist %OCCT_VER% ( goto generate_solution )
ECHO OFF
ECHO 
ECHO -----------------------------------------------------------------
ECHO        DOWNLOADING OFFICIAL OCCT  %OCCT_VER% SOURCE
ECHO -----------------------------------------------------------------
ECHO ON
SET SNAPSHOT="http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=%HASH%;sf=tgz"
curl  -L -o %OCCT_VER%.tgz %SNAPSHOT%
tar -xf %OCCT_VER%.tgz

:generate_solution1
MOVE occt-%HASHL% %OCCT_VER%


ECHO OFF
ECHO -----------------------------------------------------------------
ECHO          PATCHING %OCCT_VER% TO SPEEDUP BUILD
ECHO -----------------------------------------------------------------
ECHO ON
CD %OCCT_VER%

REM patch -p1 < ../add_cotire_to_%VERSION%.patch

CD %ROOTFOLDER%

:generate_solution

MKDIR %DISTFOLDER%

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       GENERATING SOLUTION
ECHO -----------------------------------------------------------------
ECHO ON
mkdir %BUILDFOLDER%
cd %BUILDFOLDER%
ECHO "DISTFOLDER = "%DISTFOLDER%

cmake -DINSTALL_DIR:STRING="%DISTFOLDER%" ^
          -DCMAKE_INSTALL_PREFIX="%DISTFOLDER%" ^
          -DCMAKE_SUPPRESS_REGENERATION:BOOLEAN=OFF  ^
          -DUSE_TCL:BOOLEAN=OFF ^
          -DUSE_FREETYPE:BOOLEAN=OFF ^
          -DUSE_VTK:BOOLEAN=OFF ^
          -DBUILD_USE_PCH:BOOLEAN=ON ^
          -DBUILD_SHARED_LIBS:BOOLEAN=OFF ^
          -DBUILD_TESTING:BOOLEAN=OFF ^
          -DBUILD_MODULE_ApplicationFramework:BOOLEAN=OFF ^
          -DBUILD_MODULE_DataExchange:BOOLEAN=ON ^
          -DBUILD_MODULE_DataExchange2:BOOLEAN=OFF ^
          -DBUILD_MODULE_Draw:BOOLEAN=OFF ^
          -DBUILD_MODULE_FoundationClasses:BOOLEAN=ON ^
          -DBUILD_MODULE_MfcSamples:BOOLEAN=OFF ^
          -DBUILD_MODULE_ModelingAlgorithms:BOOLEAN=ON ^
          -DBUILD_MODULE_ModelingData:BOOLEAN=ON ^
          -DBUILD_MODULE_Visualization:BOOLEAN=OFF ^
          ../%OCCT_VER%

REM           -G "%GENERATOR%" ^

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       BUILDING SOLUTION
ECHO -----------------------------------------------------------------
ECHO ON
SET VERBOSITY=quiet
REM SET VERBOSITY=minimal

REM msbuild /m oce.sln
msbuild /m occt.sln /p:Configuration=Debug /p:Platform="x64" /verbosity:%VERBOSITY% ^
     /consoleloggerparameters:Summary;ShowTimestamp
ECHO ERROR LEVEL = %ERRORLEVEL%
if NOT '%ERRORLEVEL%'=='0' goto handle_msbuild_error

msbuild /m occt.sln /p:Configuration=Release /p:Platform="x64" /verbosity:%VERBOSITY% ^
     /consoleloggerparameters:Summary;ShowTimestamp
ECHO ERROR LEVEL = %ERRORLEVEL%
if NOT '%ERRORLEVEL%'=='0' goto handle_msbuild_error

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       BUILDING SOLUTION   -> DONE !
ECHO -----------------------------------------------------------------
ECHO ON


ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       INSTALING TO  %DISTFOLDER%
ECHO -----------------------------------------------------------------
ECHO ON
msbuild /m INSTALL.vcxproj /p:Configuration=Release  /p:Platform="x64" /verbosity:%VERBOSITY% ^
     /consoleloggerparameters:Summary;ShowTimestamp

ECHO ERROR LEVEL = %ERRORLEVEL%
if NOT '%ERRORLEVEL%'=='0' goto handle_install_error

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       CREATING ARCHIVE %DISTFOLDER% %ARCHIVE%
ECHO -----------------------------------------------------------------
ECHO ON
SET PATH=%PATH%;C:\Tools\7-Zip
CD %ARCHIVE_FOLDER%
7z a %ARCHIVE% %OCCT_VER%
CD %ROOTFOLDER%
DIR %FULL_ARCHIVE%

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO      DONE
ECHO -----------------------------------------------------------------



exit 0

:handle_install_error
:handle_msbuild_error
ECHO exit 1
exit 1
