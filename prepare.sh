#!/usr/bin/env bash

WD=`pwd`

DEPLOYMENT="$WD/deploy"
WORK="$WD/work"
WITH_LOGIT=false
WITH_O6COMPAT=false
WITH_UAOSCA=false
WITH_ALL=false

usage()
{
echo "This script will build different components of quasar and quasar-related ecosystem mostly for TDAQ groups"
echo "Usage:"
echo "--with_all           if you want to deploy all possible components (implies all --with_XXX switches)"
echo "--with_LogIt         include LogIt"
echo "--with_o6compat      include open62541-compat"
echo "--with_UaoSca        include UaoClientForOpcUaSca"
echo "--install_prefix     where to deploy your things (if skipped it will default to deploy/ dir created here"
}

prep_LogIt()
{
cd $WORK
LOGIT_URL="https://github.com/quasar-team/LogIt.git"
LOGIT_TAG="v0.1.3"
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
cmake -DSTANDALONE_BUILD=ON -DLOGIT_BUILD_OPTION=LOGIT_AS_EXT_STATIC -DOPEN62541-COMPAT_BUILD_CONFIG_FILE=boost_lcg.cmake -DLOGIT_INCLUDE_DIR=$DEPLOYMENT/LogIt/include -DLOGIT_EXT_LIB_DIR=$DEPLOYMENT/LogIt/lib -DCMAKE_INSTALL_PREFIX=$DEPLOYMENT/open62541-compat -DSKIP_TESTS=ON  ../ || exit
make || exit
make install || exit
cd $WD
}

prep_UaoClientForOpcUaSca()
{
cd $WORK
UAOCLIENTFOROPCUASCA_URL="ssh://git@gitlab.cern.ch:7999/atlas-dcs-opcua-servers/UaoClientForOpcUaSca.git"
UAOCLIENTFOROPCUASCA_TAG="OPCUA-1714_deployable_as_INSTALL_target"
rm -fr UaoClientForOpcUaSca
git clone $UAOCLIENTFOROPCUASCA_URL --depth=1 -b $UAOCLIENTFOROPCUASCA_TAG || exit
cd UaoClientForOpcUaSca
mkdir build && cd build
cmake -DBUILD_CONFIG=open62541_config.cmake -DBUILD_STANDALONE=ON -DOPEN62541_COMPAT_DIR=$DEPLOYMENT/open62541-compat -DLOGIT_INCLUDE_DIR=$DEPLOYMENT/LogIt/include -DCMAKE_INSTALL_PREFIX=$DEPLOYMENT/UaoClientForOpcUaSca ../
make || exit
make install || exit
cd $WD

}

# parse params
while [[ "$#" > 0 ]]; do case $1 in
  --install_prefix) INSTALL_PREFIX="$2"; shift;shift;;
  --with_all) WITH_ALL=true; shift;;
  --with_LogIt) WITH_LOGIT=true; shift;;
  --with_o6compat) WITH_O6COMPAT=true; shift;;
  --with_UaoSca) WITH_UAOSCA=true; shift;;
  -h|--help) usage; exit;;
  *) echo "Unknown parameter passed: $1"; exit; shift; shift;;
esac; done

if [ ! -z "$INSTALL_PREFIX" ]; then
  DEPLOYMENT=$INSTALL_PREFIX
fi

echo "Will deploy your suff to $DEPLOYMENT"

if [ $WITH_ALL == "true" ]; then
    WITH_LOGIT=true
    WITH_O6COMPAT=true
    WITH_UAOSCA=true
fi

echo "Component selection: (see with --help or try --with_all) "
echo "LogIt ..................... $WITH_LOGIT"
echo "open62541-compat .......... $WITH_O6COMPAT"
echo "UaoClientForOpcUaSca ...... $WITH_UAOSCA"

rm -Rf $WORK
mkdir $WORK
cd $WORK

if [ $WITH_LOGIT == "true" ]; then
    prep_LogIt
fi

if [ $WITH_O6COMPAT == "true" ]; then
    prep_open62541compat
fi

if [ $WITH_UAOSCA == "true" ]; then
    prep_UaoClientForOpcUaSca
fi


