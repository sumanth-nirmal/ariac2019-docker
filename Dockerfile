FROM osrf/ros:melodic-desktop-full

# Install some utils
RUN apt-get update \
 && apt-get install -y \
    wget \
    lsb-release \
    sudo \
    mesa-utils \
    git \ 
    git-gui \
    htop \
    vim \
    
&& apt-get clean

# Install gazebo 9
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list \
 && wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - \
 && apt-get update \
 && apt-get install -y \
    gazebo9 \
    libgazebo9-dev
&& apt-get clean

# Install ariac3 (ariac2019)
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable bionic main" > /etc/apt/sources.list.d/gazebo-stable.list \
 echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-prerelease bionic main" > /etc/apt/sources.list.d/gazebo-prerelease.list \
 && wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - \
 && apt-get update \
 && apt-get install -y \
    ariac3 
&& apt-get clean



