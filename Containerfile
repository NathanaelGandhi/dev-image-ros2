FROM ghcr.io/nathanaelgandhi/base-image-ros2:main

ARG ROS_DISTRO=humble

################################################################################
# Adds non-root user
ARG USERNAME=builder
ARG USER_UID=2000
ARG USER_GID=$USER_UID

# Create the user
RUN if [ "$(id -un)" != "$USERNAME" ] ; then \
    groupadd --gid $USER_GID $USERNAME && \
    useradd --shell /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME; \
    fi
USER $USERNAME

################################################################################
# Install apt packages
## editors: vim, nano
## utils-core: git ...
## utils-n2h: tree ...
RUN sudo apt-get update && \
    sudo apt-get install -y \
    vim nano \
    git ssh curl \
    tree file htop \
    clang-format

## ros2: ros-$ROS_DISTRO-*
## note: use individual RUN commands to allow for caching
RUN sudo apt-get install -y ros-${ROS_DISTRO}-rviz2
### rqt and its plugins
RUN sudo apt-get install -y ros-${ROS_DISTRO}-rqt*
### gazebo & ros_gz
RUN sudo apt-get install -y ros-${ROS_DISTRO}-ros-gz

################################################################################
# Install pip packages
RUN pip install \
    pdm \
    pre-commit

################################################################################
# Extend bash shell
RUN if [ -d ~/.oh-my-bash ]; then \
    echo "Directory ~/.oh-my-bash already exists. Not installing"; \
else \
    echo "Downloading oh-my-bash" && \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended && \
    sed -i 's/OSH_THEME="font"/OSH_THEME="vscode"/g' ~/.bashrc && \
    if [ $? -eq 0 ]; then \
        echo "Oh My Bash installed and theme modified"; \
    fi; \
fi

################################################################################
ENTRYPOINT ["/bin/bash"]
