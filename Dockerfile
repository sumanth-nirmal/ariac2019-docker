# Ubuntu 18.04 with nvidia-docker2 beta opengl support
FROM nvidia/opengl:1.0-glvnd-devel-ubuntu18.04

# Some tools for development
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y \
        wget \
        lsb-release \
        sudo \
        mercurial \
        git \
        git-gui \
        vim \
        cmake \
        gdb \
        software-properties-common \
        python3-dbg \
        python3-pip \
        python3-venv \
        build-essential \
        ccache \
        mesa-utils \
        htop \
        terminator \
 && apt-get clean

# Setup ccache
ARG ccache_size=2000000k
RUN /usr/sbin/update-ccache-symlinks \
 && touch /etc/ccache.conf \
 && /bin/sh -c 'echo "cache_dir = /ccache\n" >> /etc/ccache.conf' \
 && /bin/sh -c 'echo "max_size = ${ccache_size}" >> /etc/ccache.conf'

# Add a user with the same user_id as the user on the host
ENV USERNAME developer
RUN useradd -ms /bin/bash $USERNAME \
 && echo "$USERNAME:$USERNAME" | chpasswd \
 && adduser $USERNAME sudo \
 && echo "$USERNAME ALL=NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME

# Commands below run as the developer user
USER $USERNAME

# Add paths for ccache
RUN /bin/sh -c 'echo "export PATH=/usr/lib/ccache:\$PATH" >> ~/.bashrc'

# When running a container start in the developer's home folder
WORKDIR /home/$USERNAME

RUN sudo apt-get update \
 && sudo -E apt-get install -y \
    tzdata \
 && sudo ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && sudo dpkg-reconfigure --frontend noninteractive tzdata \
 && sudo apt-get clean

# Install ROS and Gazebo9
RUN sudo /bin/sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
 && sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 \
 && sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list \
 && wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -' \
 && sudo apt-get update \
 && sudo apt-get install -y \
    ros-melodic-desktop-full \
    python-catkin-tools \
    python-rosinstall \
    gazebo9 \
    libgazebo9-dev \
 && sudo rosdep init \
 && sudo apt-get clean

RUN rosdep update

# Install ariac3 (ariac2019)
RUN sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable bionic main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN sudo /bin/sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-prerelease bionic main" > /etc/apt/sources.list.d/gazebo-prerelease.list' \
 && wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - \
 && sudo apt-get update \
 && sudo apt-get install -y \
    ariac3 \
&& sudo apt-get clean

RUN /bin/sh -c 'echo ". /opt/ros/melodic/setup.bash" >> ~/.bashrc' \
 && /bin/sh -c 'echo ". /usr/share/gazebo/setup.sh" >> ~/.bashrc'
