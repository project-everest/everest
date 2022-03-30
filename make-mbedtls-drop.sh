#!/bin/bash

# Note: mbedTLS requires C89, i.e. which does not support designated initializers. 
# Currently, this means that we need a patched version of Karamel 
# (see https://github.com/FStarLang/karamel/pull/95).

if [ ! -z "$1" ]; then
   EVEREST_HOME=$(realpath $1)
else
   EVEREST_HOME=.
fi

if [ ! -z "$2" ]; then
    DEST=$2
else
    DEST=.
fi

export FSTAR_HOME=$EVEREST_HOME/FStar
export KRML_HOME=$EVEREST_HOME/karamel
export HACL_HOME=$EVEREST_HOME/hacl-star
export VALE_HOME=$EVEREST_HOME/vale
export MITLS_HOME=$EVEREST_HOME/mitls-fstar

HDRTMP=$(realpath $(mktemp hdrXXX))
echo "/* Copyright (c) INRIA and Microsoft Corporation. All rights reserved." > $HDRTMP
echo "   Licensed under the Apache 2.0 License. */" >> $HDRTMP
echo "" >> $HDRTMP
echo "\$INVOCATION" >> $HDRTMP

export KOPTS="-fc89 -fparentheses -fno-shadow $KOPTS -header $HDRTMP"
export HACL_KOPTS="-fc89 -fparentheses -fno-shadow $HACL_KOPTS -header $HDRTMP"
export KRML_ARGS=$KOPTS

J=-j20

make $J -C $FSTAR_HOME/src/ocaml-output
make $J -C $FSTAR_HOME/ulib install-fstarlib
make $J -C $KRML_HOME minimal
make $J -C $KRML_HOME/krmllib
HACL_NO_TESTLIB=true make $J -C $HACL_HOME/code/curve25519 extract-c

INCDEST=$DEST/3rdparty/everest/include/everest
mkdir -p $INCDEST
cp $HACL_HOME/code/curve25519/x25519-c/Hacl_Curve25519.h $INCDEST
cp -r $KRML_HOME/include/krml $INCDEST
mkdir -p $INCDEST/krmllib
cp $KRML_HOME/krmllib/extracted/*.h $INCDEST/krmllib

LIBDEST=$DEST/3rdparty/everest/library
mkdir -p $LIBDEST
cp $HACL_HOME/code/curve25519/x25519-c/Hacl_Curve25519.c $LIBDEST
mkdir -p $LIBDEST/krmllib
for i in FStar_UInt64.c FStar_UInt128.c; do
    cp $KRML_HOME/krmllib/extracted/$i $LIBDEST/krmllib
done
mkdir -p $LIBDEST/krmllib/c
for i in fstar_uint64.c fstar_uint128.c fstar_uint128_msvc.c; do
    cp $KRML_HOME/krmllib/c/$i $LIBDEST/krmllib/c
done

rm $HDRTMP
