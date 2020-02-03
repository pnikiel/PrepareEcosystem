#!/usr/bin/env bash

WD=`pwd`

DEPLOYMENT="$WD/deploy"



prep_LogIt()
{
LOGIT_URL="https://github.com/quasar-team/LogIt.git"
LOGIT_TAG="OPCUA-1671-compile-as-stand-alone-static-lib-with-LCG-96"
rm -fr LogIt
git clone $LOGIT_URL --depth=1 -b $LOGIT_TAG LogIt || exit
cd LogIt
mkdir build && cd build
cmake -DLOGIT_BUILD_STAND_ALONE=ON -DLOGIT_BUILD_STATIC_LIB=ON -DCMAKE_INSTALL_PREFIX=$DEPLOYMENT  ../
make || exit
# there we should have make install, but doesn't yet exist in open62541-compat
cd ../
}

# prep open62541-compat
OPEN62541_COMPAT_URL="https://github.com/quasar-team/open62541-compat.git"
OPEN62541_COMPAT_TAG="OPCUA-1708_reorganize_how_pulls_LogIt"
rm -fr open62541-compat
git clone $OPEN62541_COMPAT_URL --depth=1 -b $OPEN62541_COMPAT_TAG || exit
cd open62541-compat
mkdir build && cd build
cmake -DSTANDALONE_BUILD=ON -DLOGIT_BUILD_OPTION=LOGIT_AS_EXT_STATIC -DOPEN62541-COMPAT_BUILD_CONFIG_FILE=boost_lcg.cmake -DLOGIT_INCLUDE_DIR=../../LogIt/include -DLOGIT_EXT_LIB_DIR=../../LogIt/build   ../ || exit
make || exit


