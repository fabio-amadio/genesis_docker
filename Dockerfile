FROM nvidia/cuda:12.6.3-cudnn-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CUDNN_ARCH="linux-x86_64"

ENV TZ="Europe/Paris"

# Set the default shell to bash instead of sh
SHELL ["/bin/bash", "-c"]

ENV SHELL=/bin/bash
ENV TERM=xterm

RUN echo "export PATH=/usr/local/cuda-12.6/bin${PATH:+:${PATH}}" >> ~/.bashrc 
RUN echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >> ~/.bashrc 

# install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    software-properties-common \
    git \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# install genesis and torch    
RUN pip install genesis-world torch torchvision torchaudio tensorboard "pybind11[global]"

# install OMPL wheel
RUN wget "https://github.com/ompl/ompl/releases/download/prerelease/ompl-1.6.0-cp310-cp310-manylinux_2_28_x86_64.whl"
RUN pip install ompl-1.6.0-cp310-cp310-manylinux_2_28_x86_64.whl

# install genesis dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    manpages-dev \
    software-properties-common \
    cmake \
    libvulkan-dev \
    zlib1g-dev \
    xorg-dev \
    libglu1-mesa-dev \
    libsnappy-dev
    
# upgrade g++ and gcc to version 11
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-11 \
    g++-11 
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 110
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
RUN apt-get install patchelf

WORKDIR /home/
RUN git clone https://github.com/leggedrobotics/rsl_rl
WORKDIR /home/rsl_rl
RUN git checkout v1.0.2 && pip install -e .

WORKDIR /home/examples/

ENTRYPOINT [ "/bin/bash" ]
