# reference: https://hub.docker.com/_/ubuntu/
FROM ubuntu:16.04

LABEL maintainer="Muhammad <www.github.com/m46f>"

##Set environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    build-essential \
    byobu \
    curl \
    git-core \
    htop \
    pkg-config \
    python3-dev \
    python3-pip \
    python-setuptools \
    python-virtualenv \
    unzip \
    && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

ENV PATH /opt/conda/bin:$PATH

RUN pip3 --no-cache-dir install --upgrade \
        altair \
        sklearn-pandas \
	matplotlib \
	notebook \
	wheel

# install xgboost
RUN git clone --recursive https://github.com/dmlc/xgboost && \
    cd xgboost && \
    make -j4 && \
    cd python-package; python setup.py install

# install lightgbm
RUN apt-get update && \
    apt-get install -y cmake build-essential gcc g++ git && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --recursive --branch stable https://github.com/Microsoft/LightGBM && \
    mkdir LightGBM/build && \
    cd LightGBM/build && \
    cmake .. && \
    make -j4 && \
    make install && \
    cd ../.. && \
    rm -rf LightGBM

RUN git clone --recursive https://github.com/Microsoft/LightGBM && \
    cd LightGBM/python-package && python setup.py install && cd ../.. && rm -rf LightGBM


ENV SHELL=/bin/bash

RUN mkdir /workdir
WORKDIR /workdir
#ENV PYTHONPATH='/workdir/:$PYTHONPATH'

EXPOSE 8080
CMD jupyter notebook --port=8080 --ip=0.0.0.0 --no-browser --allow-root
