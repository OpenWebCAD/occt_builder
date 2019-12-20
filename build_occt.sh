if [ ! -d occt-7.4.0 ]
then 
  curl  -L -o occt7.4.0.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=fd47711d682be943f0e0a13d1fb54911b0499c31;sf=tgz"
  tar -xf occt7.4.0.tgz
  mv occt-fd47711 occt-7.4.0

  echo -----------------------------------------------------------------
  echo          PATCHING 7.4.0 TO SPEEDUP BUILD
  echo -----------------------------------------------------------------
  cd occt-7.4.0
  patch -p1 < ../add_cotire_to_7.4.0.patch
  cd ..
fi

export INSTALL_DIR=`pwd`/dist/occt-7.4.0

mkdir -p build_linux
cd build_linux
export CCACHE_SLOPPINESS="pch_defines;time_macros"

cmake -DINSTALL_DIR:STRING="${INSTALL_DIR}" \
          -DCMAKE_SUPPRESS_REGENERATION:BOOL=ON  \
          -DBUILD_USE_PCH:BOOLEAN=ON \
          -DUSE_TBB:BOOLEAN=ON \
          -DUSE_VTK:BOOLEAN=OFF \
          -DUSE_FREEIMAGE:BOOLEAN=OFF \
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
          ../occt-7.4.0

make -j 5  | grep -v "Building CXX"

