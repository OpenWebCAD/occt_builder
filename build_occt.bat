ECHO ON

SET OCCT_VER=occt-7.2.0
SET PLATFORM=win64
SET ROOTFOLDER=%~dp0
SET ARCHIVE_FOLDER=%ROOTFOLDER%dist\%PLATFORM%
SET DISTFOLDER=%ARCHIVE_FOLDER%\%OCCT_VER%
SET ARCHIVE=%OCCT_VER%-%PLATFORM%.zip
SET FULL_ARCHIVE=%ARCHIVE_FOLDER%\%ARCHIVE%

ECHO ---------------------------------------------------------------------------
ECHO  Compiling with Visual Studio 2017 - X64
ECHO ---------------------------------------------------------------------------
SET VSVER=2017
REM CALL "%~dp0"/SETENV.BAT  64
set GENERATOR=Visual Studio 15 2017 Win64
set VisualStudioVersion=15.0
CALL "%VS150COMNTOOLS%\..\..\VC\vcvarsall.bat" amd64

SET PATH="c:\Program Files\Git\mingw64\bin";%PATH%

ECHO skip downloading if %OCCT_VER% folder exists
if exist %OCCT_VER% ( goto generate_solution )
ECHO OFF
ECHO 
ECHO -----------------------------------------------------------------
ECHO        DOWNLOADING OFFICIAL OCCT  %OCCT_VER% SOURCE
ECHO -----------------------------------------------------------------
ECHO ON
SET SNAPSHOT="http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=8662560e2c9c83de9ed97b522bebcad2cfc87b92;sf=tgz"
CALL curl  -L -o %OCCT_VER%.tgz %SNAPSHOT%
CALL tar -xf %OCCT_VER%.tgz
CALL mv occt-8662560 %OCCT_VER%


ECHO OFF
ECHO -----------------------------------------------------------------
ECHO          PATCHING 7.1.0 TO SPEEDUP BUILD
ECHO -----------------------------------------------------------------
ECHO ON
CD %OCCT_VER%
REM CALL patch -p1 < ../add_cotire_to_7.2.0.patch
CD %ROOTFOLDER%

:generate_solution

MKDIR %DISTFOLDER%

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       GENERATING SOLUTION
ECHO -----------------------------------------------------------------
ECHO ON
CALL mkdir build
CALL cd build
ECHO "DISTFOLDER = "%DISTFOLDER%

CALL cmake -INSTALL_DIR:STRING="%DISTFOLDER%" ^
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
          -G "%GENERATOR%" ^
          ../%OCCT_VER%

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       BUILDING SOLUTION
ECHO -----------------------------------------------------------------
ECHO ON
SET VERBOSITY=quiet
REM SET VERBOSITY=minimal

REM msbuild /m oce.sln
CALL msbuild /m occt.sln /p:Configuration=Debug /p:Platform="x64" /verbosity:%VERBOSITY% ^
     /consoleloggerparameters:Summary;ShowTimestamp
ECHO ERROR LEVEL = %ERRORLEVEL%
if NOT '%ERRORLEVEL%'=='0' goto handle_msbuild_error

CALL msbuild /m occt.sln /p:Configuration=Release /p:Platform="x64" /verbosity:%VERBOSITY% ^
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
CALL msbuild /m INSTALL.vcxproj /p:Configuration=Release  /p:Platform="x64" /verbosity:%VERBOSITY% ^
     /consoleloggerparameters:Summary;ShowTimestamp

ECHO ERROR LEVEL = %ERRORLEVEL%
if NOT '%ERRORLEVEL%'=='0' goto handle_install_error

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       CREATING ARCHIVE %DISTFOLDER%
ECHO -----------------------------------------------------------------
ECHO ON
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
exit 1

