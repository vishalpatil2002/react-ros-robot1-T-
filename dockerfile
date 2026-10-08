# ============================================================
# Ubuntu 20.04 + ROS 1 Noetic
# React Frontend + Node.js Backend + Python + ROS
# ============================================================

FROM ubuntu:20.04


# ============================================================
# Environment
# ============================================================

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata
ENV ROS_DISTRO=noetic


# ============================================================
# 1. Basic Ubuntu packages
# ============================================================

RUN apt-get update && apt-get install -y \
    apt-utils \
    curl \
    wget \
    git \
    vim \
    nano \
    build-essential \
    net-tools \
    htop \
    tree \
    lsof \
    usbutils \
    iputils-ping \
    ca-certificates \
    gnupg2 \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python3-yaml \
    libusb-1.0-0-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1-mesa \
    libceres-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 2. Add ROS 1 Noetic repository
# ============================================================

RUN curl -sSL \
    https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu focal main" \
    > /etc/apt/sources.list.d/ros1.list


# ============================================================
# 3. Install ROS 1 Noetic Desktop Full
# ============================================================

RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 4. Install ROS dependencies
# ============================================================

RUN apt-get update && apt-get install -y \
    ros-noetic-rplidar-ros \
    ros-noetic-laser-filters \
    ros-noetic-rosbridge-server \
    ros-noetic-serial \
    ros-noetic-robot-localization \
    ros-noetic-realsense2-camera \
    ros-noetic-realsense2-description \
    ros-noetic-imu-tools \
    ros-noetic-gmapping \
    ros-noetic-map-server \
    ros-noetic-amcl \
    ros-noetic-move-base \
    ros-noetic-dwa-local-planner \
    ros-noetic-robot-state-publisher \
    ros-noetic-costmap-converter \
    ros-noetic-mbf-costmap-core \
    ros-noetic-mbf-msgs \
    ros-noetic-libg2o \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 5. Python dependencies
# ============================================================

RUN pip3 install --no-cache-dir \
    rospkg \
    pyyaml \
    pymodbus \
    opcua \
    python-dotenv \
    opencv-contrib-python==3.4.18.65


# ============================================================
# 6. Install Node.js 16
# ============================================================

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm@8 \
    && node --version \
    && npm --version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 7. Global Node.js packages
# ============================================================

RUN npm install -g \
    roslib \
    js-yaml \
    redis \
    node-opcua


# ============================================================
# 8. Create application directory
# ============================================================

WORKDIR /app


# ============================================================
# 13. Copy backend package files
# ============================================================

COPY backend/package.json backend/package-lock.json /app/backend/


# ============================================================
# 14. Install backend dependencies
# ============================================================

WORKDIR /app/backend

RUN --mount=type=cache,target=/root/.npm \
    npm config set registry https://registry.npmjs.org/ \
    && npm config set fetch-retries 10 \
    && npm config set fetch-retry-mintimeout 30000 \
    && npm config set fetch-retry-maxtimeout 300000 \
    && npm config set fetch-timeout 1800000 \
    && npm ci --no-audit --no-fund --prefer-offline

# ============================================================
# 15. Copy complete backend source
# ============================================================

COPY backend/ /app/backend/


#=============================================================
# Copy React production build
# ============================================================

COPY frontend/build/ /app/frontend/build/

# ============================================================
# 16. Configure ROS environment
# ============================================================

RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc

RUN echo "source /opt/ros/noetic/setup.bash" >> /etc/bash.bashrc


# ============================================================
# 17. ROS environment for Docker RUN/CMD
# ============================================================

ENV PATH="/opt/ros/noetic/bin:${PATH}"


# ============================================================
# 18. Expose ports
# ============================================================

# React
EXPOSE 3000

# Node.js backend
EXPOSE 5000

# ROSBridge WebSocket
EXPOSE 9090

# MongoDB
EXPOSE 27017

# Additional application service
EXPOSE 3001


# ============================================================
# 19. Working directory
# ============================================================

WORKDIR /app


# ============================================================
# 20. Start container
# ============================================================

CMD ["bash"]
