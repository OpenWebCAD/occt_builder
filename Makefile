prebuild:
	bash build_occt.sh
make: 
	cd build_linux && make -j4
install: 
	cd build_linux && make install -j4 > /dev/null
package: install 
	cd dist && tar -cf occt-7.2.0-${TRAVIS_OS_NAME}.tgz occt-7.2.0
.PHONY: prebuild make install package
