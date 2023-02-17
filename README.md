# `envcas` Examples

[envcas](https://sconedocs.github.io/envcas/) provides a convenient way to launch a native subprocess with

- environment variables und arguments populated from SCONE CAS,
- configuration files automatically generated and populated from SCONE CAS.

The tool is inspired by envconsul, envdir and envchain. However, envcas runs as a confidential application and we perform an attestation of envcas first. Hence, one can even require an OTP (One Time Password) to be able to execution of envcas with the help of the policy of envcas.

This repository contains examples on how to use `envcas` in the `example-bash` and `example-python` directories.

## Python Example

In the `example-python` directory, there is a `run.sh` script that

1. Builds a docker image with `docker build --no-cache -t  demo-python-envcas:latest .` command, using the `Dockerfile` in that directory;
2. Detects the SGX device to be used, and
3. Runs a containers with `envcas` that will create a Python3.9 child process to execute `app.py`.

The `session.yaml` describes the policy that one uploads to CAS, with env vars and args got from a SCONE CAS instance.

In the environment section of the `session.yaml`, we list the env vars that will be passed to the Python3.9 native app.

```yaml
     environment:
        # get TRUSTED_ENV from CAS
        TRUSTED_ENV: trusted_env
        # get UNTRUSTED_ENV from the untrusted environment
        \@\@UNTRUSTED_ENV: IGNORED_VALUE_BECAUSE_IT_GETS_FROM_OUTSIDE
```

We also inject a `/etc/envcas/config.yaml` file. This file contains the configuration for the envcas. In this example it shows how to say which native app will be executed.

```yaml
images:
  - name: envcas_image
    injection_files:
     - path: /etc/envcas/config.yaml
       content: |
          program:  /usr/bin/python3.9
```

For the Python3.9 to get an environment variable from the container (not from CAS), we can use the `\@\@` escape before the environment variable name. Note that, in this case, the value of the environment variable in the policy will be ignored. The example is like as follows:

```yaml
\@\@UNTRUSTED_ENV: IGNORED_VALUE_BECAUSE_IT_GETS_FROM_OUTSIDE
```

In this way, the value for `UNTRUSTED_ENV` is got from the `docker run` command: `-e UNTRUSTED_ENV="this environment is from the untrusted world!"`.
