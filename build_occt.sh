if [ ! -f occt7.2.0.tgz ]
then 
  curl  -L -o occt7.2.0.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=8662560e2c9c83de9ed97b522bebcad2cfc87b92;sf=tgz"
  tar -xf occt7.2.0.tgz
  mv occt-8662560 occt-7.2.0

  echo -----------------------------------------------------------------
  echo          PATCHING 7.2.0 TO SPEEDUP BUILD
  echo -----------------------------------------------------------------
  cd occt-7.2.0
  patch -p1 < ../add_cotire_to_7.2.0.patch
  cd ..
fi

mkdir -p build_linux
cd build_linux
export CCACHE_SLOPPINESS="pch_defines;time_macros"

cmake -DINSTALL_DIR:STRING="../dist/occt-7.2.0" \
          -DCMAKE_SUPPRESS_REGENERATION:BOOL=ON  \
          -DBUILD_USE_PCH:BOOLEAN=ON \
          -DBUILD_SHARED_LIBS:BOOL=OFF \
          -DBUILD_TESTING:BOOLEAN=OFF \
          -DBUILD_MODULE_ApplicationFramework:BOOLEAN=OFF \
          -DBUILD_MODULE_DataExchange:BOOLEAN=ON \
          -DBUILD_MODULE_DataExchange2:BOOLEAN=OFF \
          -DBUILD_MODULE_Draw:BOOLEAN=OFF \
          -DBUILD_MODULE_FoundationClasses:BOOLEAN=ON \
          -DBUILD_MODULE_MfcSamples:BOOLEAN=OFF \
          -DBUILD_MODULE_ModelingAlgorithms:BOOLEAN=ON \
          -DBUILD_MODULE_ModelingData:BOOLEAN=ON \
          -DBUILD_MODULE_Visualization:BOOLEAN=OFF \
          ../occt-7.2.0

make -j 5  | grep -v "Building CXX"

