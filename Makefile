prebuild:
	bash build_occt.sh
make: 
	cd build_linux && make -j4

install: 
	cd build_linux && ( make install -j4 > /dev/null ) && cd ..

package: install
	(export OCCT_VERSION=`ls -d occt-[[:digit:]].[[:digit:]].[[:digit:]]` ; echo "OCCT_VERSION=$${OCCT_VERSION}" ; 	cd dist && tar -cf $${OCCT_VERSION}-${RUNNER_OS}.tgz $${OCCT_VERSION} )
.PHONY: prebuild make install package
