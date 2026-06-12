# askap_dsdocker
a docker build for analysing ASKAP data with dstools

## Docker

Build the Docker image:

```sh
docker build -t askap_ds .
```

Open a shell with the current directory mounted as `/workspace`:

```sh
docker run --rm -it -v "$PWD":/workspace askap_ds
```

## Singularity / Apptainer

Build the Singularity image from the Docker-bootstrap definition:

```sh
apptainer build askap_ds.sif Singularity.def
```

Open a shell with the current directory mounted as `/workspace`:

```sh
apptainer shell --bind "$PWD":/workspace askap_ds.sif
```
