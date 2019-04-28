# ref:
# https://github.com/Valian/docker-python-opencv-ffmpeg/blob/master/Dockerfile-py3-cuda
# TODO: python3.7 support

ARG CUDA_VERSION="10.0"
FROM nvidia/cuda:${CUDA_VERSION}-cudnn7-devel-ubuntu16.04
# ARG OPENCV_VERSION="4.1.0"
ARG OPENCV_VERSION="3.4.6"
ARG PYTHON_VERSION="3.7"

# Install all dependencies for OpenCV
RUN apt-get -y update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \ 
    apt-get update && \
    apt-get -y install \
      python${PYTHON_VERSION} \
      python${PYTHON_VERSION}-dev \
      git \
      wget \
      unzip \
      cmake \
      build-essential \
      pkg-config \
      libatlas-base-dev \
      gfortran \
      libjasper-dev \
      libgtk2.0-dev \
      libavcodec-dev \
      libavformat-dev \
      libswscale-dev \
      libjpeg-dev \
      libpng-dev \
      libtiff-dev \
      libv4l-dev \
    && \
# install python dependencies
    wget https://bootstrap.pypa.io/get-pip.py && \
    python${PYTHON_VERSION} get-pip.py && \
    rm get-pip.py && \
    python${PYTHON_VERSION} -m pip install numpy 
# Download OpenCV
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv3.zip && \
    unzip -q opencv3.zip && \
    mv /opencv-${OPENCV_VERSION} /opencv && \
    rm opencv3.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib3.zip && \
    unzip -q opencv_contrib3.zip && \
    mv /opencv_contrib-${OPENCV_VERSION} /opencv_contrib && \
    rm opencv_contrib3.zip
# Prepare build
RUN mkdir /opencv/build && cd /opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D BUILD_PYTHON_SUPPORT=ON \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
      -D BUILD_EXAMPLES=OFF \
      -D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python${PYTHON_VERSION} \
      -D BUILD_opencv_python3=ON \
      -D BUILD_opencv_python2=OFF \
      -D WITH_IPP=OFF \
      -D WITH_FFMPEG=ON \
      -D WITH_CUDA=ON \
      -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
      -D WITH_CUBLAS=ON \
      -D WITH_V4L=ON .. \
    && \
# Install
    cd /opencv/build && \
    make -j$(nproc) && \
    make install && \
    ldconfig \
    && \
# Clean
   apt-get -y remove \
      python${PYTHON_VERSION}-dev \
      libatlas-base-dev \
      gfortran \
      libjasper-dev \
      libgtk2.0-dev \
      libavcodec-dev \
      libavformat-dev \
      libswscale-dev \
      libjpeg-dev \
      libpng-dev \
      libtiff-dev \
      libv4l-dev \
    && \
    apt-get clean && \
rm -rf /opencv /opencv_contrib /var/lib/apt/lists/*