#!/usr/bin/env bash

WD=`pwd`
DEPLOYMENT="$WD/deploy"
WORK="$WD/work"

prep_LogIt()
{
cd $WORK
LOGIT_URL="https://github.com/quasar-team/LogIt.git"
LOGIT_TAG="OPCUA-1710-install-target-for-LogIt"
rm -fr LogIt
git clone $LOGIT_URL --depth=1 -b $LOGIT_TAG LogIt || exit
cd LogIt
mkdir build && cd build
cmake -DLOGIT_BUILD_STAND_ALONE=ON -DLOGIT_BUILD_STATIC_LIB=ON -DCMAKE_INSTALL_PREFIX=$DEPLOYMENT/LogIt  ../
make || exit
make install || exit
# there we should have make install, but doesn't yet exist in open62541-compat
cd $WD
}

prep_open62541compat()
{
cd $WORK
OPEN62541_COMPAT_URL="https://github.com/quasar-team/open62541-compat.git"
OPEN62541_COMPAT_TAG="master"
rm -fr open62541-compat
git clone $OPEN62541_COMPAT_URL --depth=1 -b $OPEN62541_COMPAT_TAG || exit
cd open62541-compat
mkdir build && cd build
cmake -DSTANDALONE_BUILD=ON -DLOGIT_BUILD_OPTION=LOGIT_AS_EXT_STATIC -DOPEN62541-COMPAT_BUILD_CONFIG_FILE=boost_lcg.cmake -DLOGIT_INCLUDE_DIR=$DEPLOYMENT/LogIt/LogIt/include -DLOGIT_EXT_LIB_DIR=$DEPLOYMENT/LogIt/lib -DCMAKE_INSTALL_PREFIX=$DEPLOYMENT/open62541-compat -DSKIP_TESTS=ON  ../ || exit
make || exit
make install || exit
cd $WD
}

rm -Rf $DEPLOYMENT $WORK
mkdir $DEPLOYMENT $WORK
cd $WORK

prep_LogIt
prep_open62541compat


