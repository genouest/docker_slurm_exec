Inspired from https://github.com/abretaud/docker-sf-blast

# Docker Image for launching slurm jobs

## Configuring the Container

The following environment variables are available:

```
SLURMGID: '992' # the gid of the slurm group (should be the same as on your slurm cluster)
SLURMUID: '992' # the uid of the slurm user (should be the same as on your slurm cluster)
MUNGEGID: '991' # the gid of the munge group (should be the same as on your slurm cluster)
MUNGEUID: '991' # the uid of the munge user (should be the same as on your slurm cluster)
DRMAA_LIBRARY_PATH: '/etc/slurm/drmaa/lib/libdrmaa.so.1'
```

## Using DRMAA

To use DRMAA, you need to pay attention to several things:

### Slurm

Slurm libraries are installed in version 21.08 (from Debian Buster). It should match the version installed on your cluster to work properly.

#### Environment variables

If you're using Slurm, you should set the `DRMAA_METHOD` environment variable to `slurm`

#### Mounts

Make sure that the folder from where the jobs are launched is available on all cluster nodes!

You need to mount the slurm configuration files from your cluster to the /etc/slurm/ directory.
You also need to mount the libdrmaa.so.1 library to $DRMAA_LIBRARY_PATH path (/etc/slurm/drmaa/lib/libdrmaa.so.1 by default).
And you need to mount the munge conf directory which stores the munge key specific to your cluster.
All this should look something like that:

```
volumes:
  - /etc/slurm/slurm.conf:/etc/slurm/slurm.conf:ro
  - /etc/slurm/gres.conf:/etc/slurm/gres.conf:ro
  - /etc/slurm/cgroup.conf:/etc/slurm/cgroup.conf:ro
  - /etc/slurm/slurmdbd.conf:/etc/slurm/slurmdbd.conf:ro
  - /etc/slurm/drmaa/:/etc/slurm/drmaa/:ro
  - /etc/munge/:/etc/munge/:ro
```

#### DRMAA user

Jobs will probably need to be launched by a user known by the scheduler. You will need to use the following options to configure this:

```
UID: the uid of the user
GID: the gid of the user
RUN_USER: the username of the user
RUN_GROUP: the group of the user
```
