#!/bin/bash

if [ ! -z "$1" ]; then
   EVEREST_HOME=$1
else
   EVEREST_HOME=.
fi

if [ ! -z "$2" ]; then
    DEST=$2
else
    DEST=.
fi

export FSTAR_HOME=$EVEREST_HOME/FStar
export KREMLIN_HOME=$EVEREST_HOME/kremlin
export HACL_HOME=$EVEREST_HOME/hacl-star
export VALE_HOME=$EVEREST_HOME/vale
export MITLS_HOME=$EVEREST_HOME/mitls-fstar

# export KOPTS="-falloca -ftail-calls $KOPTS"
# Note: the Makefiles in secure_api and src/tls know about KRML_NOUINT128 and
# will flip KOPTS accordingly
# export KRML_NOUINT128=1
# Note: the Makefile in code/curve25519 has no such customization and we nudge
# it via a set of KOPTS specified here.
# export HACL_KOPTS="-fnouint128 -drop FStar.UInt128,FStar.Int.Cast.Full -add-early-include '\"FStar_UInt128.h\"' $KOPTS"

# Choose C89!
export KOPTS="-fc89 $KOPTS"
export HACL_KOPTS="-fc89 $HACL_KOPTS"
export KREMLIN_ARGS=$KOPTS

J=-j8 

make $J -C $FSTAR_HOME/src/ocaml-output
make $J -C $FSTAR_HOME/ulib install-fstarlib
make $J -C $KREMLIN_HOME
HACL_NO_TESTLIB=true make $J -C $HACL_HOME/code/uint128 extract-c
HACL_NO_TESTLIB=true make $J -C $HACL_HOME/code/curve25519 extract-c

mkdir -p $DEST/include
cp $HACL_HOME/code/uint128/uint128-c/FStar_UInt128.h $DEST/include
cp $HACL_HOME/code/curve25519/x25519-c/Hacl_Curve25519.h $DEST/include
cp -r $KREMLIN_HOME/include/kremlin $DEST/include/

mkdir -p $DEST/library
cp $HACL_HOME/code/uint128/uint128-c/FStar_UInt128.c $DEST/library
cp $HACL_HOME/code/curve25519/x25519-c/Hacl_Curve25519.c $DEST/library

