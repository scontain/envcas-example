#!/usr/bin/env bash

docker build --no-cache -t  demo-python-envcas:latest .

echo $PWD:/work
export MRENCLAVE=$(docker run --rm -v $PWD:/work demo-python-envcas:latest sh -c "SCONE_HASH=1 /bin/envcas")

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

docker run $MOUNT_SGXDEVICE  --rm -v $PWD:/work -e UNTRUSTED_ENV="this environment is from the untrusted world!" -e MRENCLAVE="$MRENCLAVE" demo-python-envcas:latest sh /work/entrypoint.sh
