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
## editors: nano vim
## linux utils: git file tree
RUN sudo apt-get update && \
    sudo apt-get install -y \
    nano vim \
    git file tree

## ros: ros-$ROS_DISTRO-...
## note: installed using separate run commands for layered pulls
### ros-$ROS_DISTRO-rqt*: rqt and its plugins
RUN sudo apt install -y ros-$ROS_DISTRO-rqt*
RUN sudo apt install -y ros-$ROS_DISTRO-rviz2

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
