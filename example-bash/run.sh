#!/usr/bin/env bash

echo $PWD:/work
export MRENCLAVE=$(docker run --rm -v $PWD:/work registry.scontain.com/edge/envcas sh -c "SCONE_HASH=1 /bin/envcas")

function determine_sgx_device {
    export SGXDEVICE="/dev/sgx_enclave"
    export MOUNT_SGXDEVICE="--device=/dev/sgx_enclave"
    if [[ ! -e "$SGXDEVICE" ]] ; then
        export SGXDEVICE="/dev/sgx"
        export MOUNT_SGXDEVICE="--device=/dev/sgx"
        if [[ ! -e "$SGXDEVICE" ]] ; then
            export SGXDEVICE="/dev/isgx"
            export MOUNT_SGXDEVICE="--device=/dev/isgx"
            if [[ ! -c "$SGXDEVICE" ]] ; then
                echo "Warning: No SGX device found! Will run in SIM mode." > /dev/stderr
                export MOUNT_SGXDEVICE=""
                export SGXDEVICE=""
            fi
        fi
    fi
}

determine_sgx_device

docker run $MOUNT_SGXDEVICE  --rm -v $PWD:/work -e MRENCLAVE="$MRENCLAVE" registry.scontain.com/edge/envcas sh /work/build.sh
