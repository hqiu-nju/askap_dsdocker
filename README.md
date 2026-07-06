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

Open a shell with X11 forwarding enabled on Linux:

```sh
docker run --rm -it \
  -e DISPLAY \
  -e XAUTHORITY=/tmp/.docker.xauth \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "${XAUTHORITY:-$HOME/.Xauthority}":/tmp/.docker.xauth:ro \
  -v "$PWD":/workspace \
  askap_ds
```

Open a shell with X11 forwarding enabled on macOS with XQuartz:

1. Install and start XQuartz.
2. In XQuartz settings, enable "Allow connections from network clients", then restart XQuartz.
3. Allow local X11 clients:

```sh
xhost +localhost
```

4. Start the container with `DISPLAY` pointing at the macOS host:

```sh
docker run --rm -it \
  -e DISPLAY=host.docker.internal:0 \
  -v "$PWD":/workspace \
  askap_ds
```

Inside the container, test X11 before launching a GUI:

```sh
xclock
```

If `xclock` opens, GUI programs such as `rfigui` should be able to connect to the same display.

## Singularity / Apptainer

Build the Singularity image from the Docker-bootstrap definition:

```sh
apptainer build askap_ds.sif Singularity.def
```

Open a shell with the current directory mounted as `/workspace`:

```sh
apptainer shell --bind "$PWD":/workspace askap_ds.sif
```
