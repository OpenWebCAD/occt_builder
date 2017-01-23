ECHO 
ECHO -----------------------------------------------------------------
ECHO        DOWNLOADING OFFICIAL OCCT 7.1.0 SOURCE
ECHO -----------------------------------------------------------------
CALL curl  -L -C -o occt7.1.0.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=89aebdea8d6f4d15cfc50e9458cd8e2e25022326;sf=tgz"
CALL tar -xf occt7.1.0.tgz
CALL mv occt-89aebde occt-7.1.0

ECHO -----------------------------------------------------------------
ECHO          PATCHING 7.1.0 TO SPEEDUP BUILD
ECHO -----------------------------------------------------------------
CD occt-7.1.0
CALL patch -p1 < ../add_cotire_to_7.1.0.patch
CD ..

ECHO -----------------------------------------------------------------
ECHO       GENERATING SOLUTION
ECHO -----------------------------------------------------------------
CALL mkdir build
CALL cd build
CALL cmake -INSTALL_DIR:STRING="%PREFIX%" ^
          -DCMAKE_SUPPRESS_REGENERATION:BOOL=ON  ^
          -DBUILD_SHARED_LIBS:BOOL=OFF ^
          -DBUILD_TESTING:BOOLEAN=OFF ^
          -DBUILD_MODULE_ApplicationFramework:BOOLEAN=OFF ^
          -DBUILD_MODULE_DataExchange:BOOLEAN=OFF ^
          -DBUILD_MODULE_DataExchange2:BOOLEAN=OFF ^
          -DBUILD_MODULE_Draw:BOOLEAN=OFF ^
          -DBUILD_MODULE_FoundationClasses:BOOLEAN=ON ^
          -DBUILD_MODULE_MfcSamples:BOOLEAN=OFF ^
          -DBUILD_MODULE_ModelingAlgorithms:BOOLEAN=ON ^
          -DBUILD_MODULE_ModelingData:BOOLEAN=ON ^
          -DBUILD_MODULE_Visualization:BOOLEAN=OFF ^
          ../occt-7.1.0

ECHO -----------------------------------------------------------------
ECHO       BUILDING SOLUTION
ECHO -----------------------------------------------------------------
SET VERBOSITY=quiet
REM SET VERBOSITY=minimal

REM msbuild /m oce.sln
CALL msbuild /m occt.sln /p:Configuration=Release /verbosity:%VERBOSITY% /consoleloggerparameters:Summary;ShowTimestamp

ECHO -----------------------------------------------------------------
ECHO       BUILDING SOLUTION   -> DONE !
ECHO -----------------------------------------------------------------
