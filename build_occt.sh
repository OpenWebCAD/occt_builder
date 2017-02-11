

function create_deb {
rm -rf /tmp/$1-$2
mkdir /tmp/$1-$2
mkdir /tmp/$1-$2/DEBIAN
echo "Package:$1" >> /tmp/$1-$2/DEBIAN/control
echo "Version:$2" >> /tmp/$1-$2/DEBIAN/control
echo "Section:base" >> /tmp/$1-$2/DEBIAN/control
echo "Priority:optional" >> /tmp/$1-$2/DEBIAN/control
echo "Architecture:amd64" >> /tmp/$1-$2/DEBIAN/control
echo "Depends:"$3 >> /tmp/$1-$2/DEBIAN/control
echo "Maintainer:verdun@splitted-desktop.com" >> /tmp/$1-$2/DEBIAN/control
echo "Homepage:http://ruggedpod.qyshare.com" >> /tmp/$1-$2/DEBIAN/control
echo "Description:TEST PACKAGE" >> /tmp/$1-$2/DEBIAN/control
file_list=`ls -ltd $(find /usr/bin) | awk '{ print $9}'`
file_list2=`ls -ltd $(find /usr/share) | awk '{ print $9}'`
file_list3=`ls -ltd $(find /usr/include) | awk '{ print $9}'`
file_list4=`ls -ltd $(find /usr/lib) | awk '{ print $9}'`
for file in $file_list $file_list2 $file_list3 $file_list4
do
  new_file=`printf "%q" "$file"`
  new_file=`echo $new_file | sed 's/\+/\\\\+/g'`
  is_done=`cat /tmp/stage | grep -E "$new_file"`
if [ "$is_done" == "" ]
then
# The file must be integrated into the new deb
    cp --parents $file /tmp/$1-$2
    echo $file >> /tmp/stage
fi    
done
current_dir=`pwd`
cd /tmp
dpkg-deb --build $1-$2
mv $1-$2.deb $1-$2_${TRAVIS_OS_NAME}.deb
cd $current_dir
}


curl  -L -o occt7.1.0.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=89aebdea8d6f4d15cfc50e9458cd8e2e25022326;sf=tgz"

tar -xf occt7.1.0.tgz

mv occt-89aebde occt-7.1.0

echo -----------------------------------------------------------------
echo          PATCHING 7.1.0 TO SPEEDUP BUILD
echo -----------------------------------------------------------------
cd occt-7.1.0
patch -p1 < ../add_cotire_to_7.1.0.patch
cd ..



# We must prestage existing file to avoid inserting them into the deb package
# Files are going to be installed there bin  include  lib  share

file_list=`ls -ltd $(find /usr/bin) | awk '{ print $9}'`
for file in $file_list
do
        echo $file >> /tmp/stage
done
file_list=`ls -ltd $(find /usr/include) | awk '{ print $9}'`
for file in $file_list
do
        echo $file >> /tmp/stage
done
file_list=`ls -ltd $(find /usr/lib) | awk '{ print $9}'`
for file in $file_list
do
        echo $file >> /tmp/stage
done
file_list=`ls -ltd $(find /usr/share) | awk '{ print $9}'`
for file in $file_list
do
        echo $file >> /tmp/stage
done

mkdir build
cd build
export CCACHE_SLOPPINESS="pch_defines;time_macros"

cmake -DINSTALL_DIR:STRING="/usr" \
          -DCMAKE_SUPPRESS_REGENERATION:BOOL=ON  \
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
          ../occt-7.1.0

make -j 5  | grep -v "Building CXX"
# Normally this is what we put at FreeCAD but in our cases Visualization is off so we
# are not dependant of all these lib
# create_deb OCCT 7.0 "tcl8.5-dev,tk8.5-dev,libcoin80-dev,libglu1-mesa-dev,g++,cmake"
create_deb OCCT 7.1.0 ""
