ECHO ON

SET OCCT_VER=occt-7.1.0
SET PLATFORM=win64
SET ROOTFOLDER=%~dp0
SET ARCHIVE_FOLDER=%ROOTFOLDER%dist\%PLATFORM%
SET DISTFOLDER=%ARCHIVE_FOLDER%\%OCCT_VER%
SET ARCHIVE=%OCCT_VER%-%PLATFORM%.zip
SET FULL_ARCHIVE=%ARCHIVE_FOLDER%\%ARCHIVE%

ECHO ---------------------------------------------------------------------------
ECHO  Compiling with Visual Studio 2015 - X64
ECHO ---------------------------------------------------------------------------
SET VSVER=2015
REM CALL "%~dp0"/SETENV.BAT  64
set GENERATOR=Visual Studio 14 2015 Win64
set VisualStudioVersion=14.0
CALL "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" amd64



ECHO skip downloading if %OCCT_VER% folder exists
if exist %OCCT_VER% ( goto generate_solution )
ECHO OFF
ECHO 
ECHO -----------------------------------------------------------------
ECHO        DOWNLOADING OFFICIAL OCCT 7.1.0 SOURCE
ECHO -----------------------------------------------------------------
ECHO ON
CALL curl  -L -o %OCCT_VER%.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=89aebdea8d6f4d15cfc50e9458cd8e2e25022326;sf=tgz"
CALL tar -xf %OCCT_VER%.tgz
CALL mv occt-89aebde %OCCT_VER%

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO          PATCHING 7.1.0 TO SPEEDUP BUILD
ECHO -----------------------------------------------------------------
ECHO ON
CD %OCCT_VER%
CALL patch -p1 < ../add_cotire_to_7.1.0.patch
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
CALL cmake -INSTALL_DIR:STRING="%DISTFOLDER%" ^
          -DCMAKE_SUPPRESS_REGENERATION:BOOL=OFF  ^
          -DBUILD_SHARED_LIBS:BOOL=OFF ^
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
CALL msbuild /m occt.sln /p:Configuration=Debug /verbosity:%VERBOSITY% /consoleloggerparameters:Summary;ShowTimestamp
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
CALL msbuild /m INSTALL.vcxproj /p:Configuration=Release /verbosity:%VERBOSITY% /consoleloggerparameters:Summary;ShowTimestamp
ECHO ERROR LEVEL = %ERRORLEVEL%
if NOT '%ERRORLEVEL%'=='0' goto handle_install_error

ECHO OFF
ECHO -----------------------------------------------------------------
ECHO       CREATING ARCHIVE %DISTFOLDER%
ECHO -----------------------------------------------------------------
ECHO ON
CD %ARCHIVE_FOLDER%
7z a %ARCHIVE% %OCCT_VER%\
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

