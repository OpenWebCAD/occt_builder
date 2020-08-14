export VERSION=7.4.0
export HASH=fd47711d682be943f0e0a13d1fb54911b0499c31
export PATCHFILE="../add_cotire_to_${VERSION}.patch"

echo "version = ${VERSION}"
echo "HASH    = ${HASH}"
echo "          ${HASH:0:7}"

if [ ! -d occt-${VERSION} ]
then 
  curl  -L -o occt${VERSION}.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${HASH};sf=tgz"
  tar -xf occt${VERSION}.tgz
  mv occt-${HASH:0:7} occt-${VERSION}

  echo -----------------------------------------------------------------
  echo          PATCHING ${VERSION} TO SPEEDUP BUILD
  echo -----------------------------------------------------------------
  cd occt-${VERSION}
  if [ -f ${PATCHFILE }]
  then
     echo patching source with ${PATCHFILE} 
     patch -p1 < ${PATCHFILE}

     # note diff -uraN b a > patch_from_a_to_b.patch 
  fi 
  cd ..
fi

export INSTALL_DIR=`pwd`/dist/occt-${VERSION}

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
          ../occt-${VERSION}

make -j 5  | grep -v "Building CXX"

