#!/bin/bash

DOCKER_IMG="ariac2019_docker"
DOCKER_CONATINER_NAME="ariac2019_docker_container"
HOME_DIRECTORY="/home/$USER/ariac2019_home"

docker_start() {
# if ariac2019_home directory presents
if [ -d "$HOME_DIRECTORY" ]; then

# Make sure processes in the container can connect to the x server
# Necessary so gazebo can create a context for OpenGL rendering (even headless)
XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

# X forwarding
xhost +

# docker run
CONTAINER_ID=$(docker run -it --detach \
  -v "/dev/dri:/dev/dri" \
  -v "/dev/shm:/dev/shm" \
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -v /home/$USER/ariac2019_home:/home/developer/ \
  -v "/home/$USER/.ssh:/home/developer/.ssh" \
  -e DISPLAY=$DISPLAY  \
  -e QT_X11_NO_MITSHM=1 \
  -e XAUTHORITY=$XAUTH \
  -v "$XAUTH:$XAUTH" \
  -v "/etc/localtime:/etc/localtime:ro" \
  -u $(id -u) \
  --net=host \
  --privileged \
  --rm \
  --runtime=nvidia \
  --security-opt seccomp=unconfined \
  --name $DOCKER_CONATINER_NAME \
  $DOCKER_IMG)

# check if the docker is running
if [ "$(docker inspect -f {{.State.Running}} $CONTAINER_ID)" = "true" ]; then
echo "$DOCKER_IMG startup completed
      $DOCKER_IMG has been started, enter using: bash ariac2019_docker.sh enter"
else
  echo "ERROR: Failed to start $DOCKER_IMG"
fi
else
  echo "ariac2019_home directory is not available
        create a directory 'ariac2019_home' in '/home/$USER'"
fi
}

docker_enter() {
# docker exec
docker exec -ti -u $(id -u) $DOCKER_CONATINER_NAME bash -li
}

docker_stop() {
 docker stop -t 0 $DOCKER_CONATINER_NAME
}

if [ "$1" = "start" ]; then 
 echo "Starting $DOCKER_IMG container"
 docker_start
elif [ "$1" = "enter" ] 
then
  docker_enter
elif [ "$1" = "stop" ]
then
  docker_stop
else
  echo "Options:
  --help     Show this message and exit.

Commands:
  start  Start ariac2019 docker environment.
  enter  Enter ariac2019 docker environment.
  stop   Stop ariac2019 docker environment."
fi
