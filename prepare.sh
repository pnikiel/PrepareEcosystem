#!/usr/bin/env bash

WD=`pwd`

DEPLOYMENT="$WD/deploy"

# prep LogIt
LOGIT_URL="ssh://git@gitlab.cern.ch:7999/quasar-team/LogIt.git"
LOGIT_TAG="OPCUA-1671-compile-as-stand-alone-static-lib-with-LCG-96"
rm -fr LogIt
git clone $LOGIT_URL --depth=1 -b $LOGIT_TAG LogIt || exit
cd LogIt
mkdir build && cd build
cmake -DLOGIT_BUILD_STAND_ALONE=ON -DLOGIT_BUILD_STATIC_LIB=ON  ../
