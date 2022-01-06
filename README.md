Inspired from https://github.com/abretaud/docker-sf-blast

# Docker Image for launching slurm jobs

## Configuring the Container

The following environment variables are available:

```
SLURMGID: '992' # the gid of the slurm group (should be the same as on your slurm cluster)
SLURMUID: '992' # the uid of the slurm user (should be the same as on your slurm cluster)
MUNGEGID: '991' # the gid of the munge group (should be the same as on your slurm cluster)
MUNGEUID: '991' # the uid of the munge user (should be the same as on your slurm cluster)
```

## Using DRMAA

To use DRMAA, you need to pay attention to several things (only tested with SGE and Slurm):

### Slurm

Slurm libraries are installed in version 18.08 (from Debian Buster). It should match the version installed on your cluster to work properly.

#### Environment variables

If you're using Slurm, you should set the `DRMAA_METHOD` environment variable to `slurm`

#### Mounts

You need to mount the slurm configuration files from your cluster to the /etc/slurm-llnl/ directory.
You also need to mount the libdrmaa.so library to $DRMAA_LIB_DIR directory (/etc/slurm-llnl/drmaa/ by default).
And you need to mount the munge conf directory which stores the munge key specific to your cluster.
All this should look something like that:

```
volumes:
  - /etc/slurm/slurm.conf:/etc/slurm-llnl/slurm.conf:ro
  - /etc/slurm/gres.conf:/etc/slurm-llnl/gres.conf:ro
  - /etc/slurm/cgroup.conf:/etc/slurm-llnl/cgroup.conf:ro
  - /etc/slurm/slurmdbd.conf:/etc/slurm-llnl/slurmdbd.conf:ro
  - /etc/slurm/drmaa/:/etc/slurm-llnl/drmaa/:ro
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
