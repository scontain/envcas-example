#!/usr/bin/env sh

cd /work

unset SCONE_VERSION
export SCONE_CAS_ADDR=edge.scone-cas.cf
export SCONE_LAS_ADDR=172.17.0.1
export SESSION=envcas-example-$RANDOM-$RANDOM

scone cas attest $SCONE_CAS_ADDR --only_for_testing-trust-any --only_for_testing-debug  --only_for_testing-ignore-signer -C -G -S
export PREDECESSOR=$(scone session create -e SESSION=$SESSION -e MRENCLAVE=$MRENCLAVE session.yaml)

SCONE_CONFIG_ID=$SESSION/envcas /bin/envcas
