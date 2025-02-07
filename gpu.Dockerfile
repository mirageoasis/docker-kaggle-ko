# local 빌드시
FROM tensorflow/tensorflow:2.6.0-gpu-jupyter
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04 AS nvidia

# CUDA
ENV CUDA_MAJOR_VERSION=11
ENV CUDA_MINOR_VERSION=3

ENV CUDA_VERSION=$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/opt/bin:${PATH}

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
ENV LD_LIBRARY_PATH_NO_STUBS="/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/opt/conda/lib"
ENV LD_LIBRARY_PATH="/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:/opt/conda/lib"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION"

# 카카오 ubuntu archive mirror server 추가. 다운로드 속도 향상
RUN sed -i 's@archive.ubuntu.com@mirror.kakao.com@g' /etc/apt/sources.list && \
    apt-get update

# openjdk java vm 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    g++ \
    gcc \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    curl \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libssl-dev \
    libzmq3-dev \
    vim \
    git

RUN apt-get update

ARG CONDA_DIR=/opt/conda

# add to path
ENV PATH $CONDA_DIR/bin:$PATH

# Install miniconda
RUN echo "export PATH=$CONDA_DIR/bin:"'$PATH' > /etc/profile.d/conda.sh && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh -o ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# Conda 가상환경 생성
RUN conda config --set always_yes yes --set changeps1 no && \
    conda create -y -q -n py37 python=3.7

ENV PATH /opt/conda/envs/py37/bin:$PATH
ENV CONDA_DEFAULT_ENV py37
ENV CONDA_PREFIX /opt/conda/envs/py37

# 패키지 설치
RUN pip install setuptools && \
    pip install mkl && \
    pip install pymysql && \
    pip install numpy && \
    pip install scipy && \
    pip install pandas==1.2.5 && \
    pip install jupyter notebook && \
    pip install matplotlib && \
    pip install seaborn && \
    pip install hyperopt && \
    pip install optuna && \
    pip install missingno && \
    pip install mlxtend && \
    pip install catboost && \
    pip install kaggle && \
    pip install folium && \
    pip install librosa && \
    pip install nbconvert && \
    pip install Pillow && \
    pip install tqdm && \
    pip install tensorflow==2.6.0 && \
    pip install tensorflow-datasets && \
    pip install gensim && \
    pip install nltk && \
    pip install wordcloud && \
    apt-get install -y graphviz && pip install graphviz && \
    pip install cupy-cuda112 && \
    pip install kiwipiepy && \
    pip install emoji && \
    pip install sentence_transformers && \
    pip install soynlp && \
    pip install stopwords


# Pytorch 설치
RUN pip install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu113


RUN pip install --upgrade cython && \
    pip install --upgrade cysignals && \
    pip install pyfasttext && \
    pip install fasttext && \
    pip install transformers

RUN pip install pystan==2.19.1.1 && \
    pip install fbprophet

RUN pip install "sentencepiece<0.1.90" wandb tensorboard albumentations pydicom opencv-python scikit-image pyarrow kornia \
    catalyst captum

RUN pip install fastai && \
    conda install -c rapidsai -c nvidia -c numba -c conda-forge cudf=21.08 python=3.7 cudatoolkit=11.2

# cmake 설치 (3.16)
RUN wget https://cmake.org/files/v3.16/cmake-3.16.2.tar.gz && \
    tar -xvzf cmake-3.16.2.tar.gz && \
    cd cmake-3.16.2 && \
    ./bootstrap && \
    make && \
    make install

ENV PATH=/usr/local/bin:${PATH}

# 나눔고딕 폰트 설치
# matplotlib에 Nanum 폰트 추가
RUN apt-get install fonts-nanum* && \
   cp /usr/share/fonts/truetype/nanum/Nanum* /opt/conda/envs/py37/lib/python3.7/site-packages/matplotlib/mpl-data/fonts/ttf/ && \
   fc-cache -fv && \
   rm -rf ~/.cache/matplotlib/*

# 나눔고딕 폰트 설치, D2Coding 폰트 설치
# matplotlib에 Nanum 폰트 추가
# RUN apt-get install fonts-nanum* && \
#     mkdir ~/.local/share/fonts && \
#     cd ~/.local/share/fonts && \
#     wget https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip && \
#     unzip D2Coding-Ver1.3.2-20180524.zip && \
#     mkdir /usr/share/fonts/truetype/D2Coding && \
#     cp ./D2Coding/*.ttf /usr/share/fonts/truetype/D2Coding/ && \
#     cp /usr/share/fonts/truetype/nanum/Nanum* /opt/conda/lib/python3.7/site-packages/matplotlib/mpl-data/fonts/ttf/ && \
#     fc-cache -fv && \
#     rm -rf D2Coding* && \
#     rm -rf ~/.cache/matplotlib/*


# konlpy, py-hanspell, soynlp 패키지 설치
RUN pip install konlpy
   

# 형태소 분석기 mecab 설치
RUN cd /tmp && \
    wget "https://www.dropbox.com/s/9xls0tgtf3edgns/mecab-0.996-ko-0.9.2.tar.gz?dl=1" && \
    tar zxfv mecab-0.996-ko-0.9.2.tar.gz?dl=1 && \
    cd mecab-0.996-ko-0.9.2 && \
    ./configure && \
    make && \
    make check && \
    make install && \
    ldconfig

RUN cd /tmp && \
    wget "https://www.dropbox.com/s/i8girnk5p80076c/mecab-ko-dic-2.1.1-20180720.tar.gz?dl=1" && \
    apt install -y autoconf && \
    tar zxfv mecab-ko-dic-2.1.1-20180720.tar.gz?dl=1 && \
    cd mecab-ko-dic-2.1.1-20180720 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# 형태소 분석기 mecab 파이썬 패키지 설치
RUN cd /tmp && \
    git clone https://bitbucket.org/eunjeon/mecab-python-0.996.git && \
    cd mecab-python-0.996 && \
    python setup.py build && \
    python setup.py install

# XGBoost (GPU 설치)
RUN git clone --recursive https://github.com/dmlc/xgboost && \
    cd xgboost && \
    mkdir build && \
    cd build && \
    cmake .. -DUSE_CUDA=ON && \
    make -j4 && \
    cd .. && \
    cd python-package && \
    python setup.py install --use-cuda --use-nccl

# Install OpenCL & libboost (required by LightGBM GPU version)
RUN apt-get install -y ocl-icd-libopencl1 clinfo libboost-all-dev && \
    mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# lightgbm (GPU 설치)
RUN pip uninstall -y lightgbm && \
    cd /usr/local/src && mkdir lightgbm && cd lightgbm && \
    git clone --recursive --branch stable --depth 1 https://github.com/microsoft/LightGBM && \
    cd LightGBM && mkdir build && cd build && \
    cmake -DUSE_GPU=1 -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include/ .. && \
    make -j$(nproc) OPENCL_HEADERS=/usr/local/cuda-11.2/targets/x86_64-linux/include LIBOPENCL=/usr/local/cuda-11.2/targets/x86_64-linux/lib && \
    cd /usr/local/src/lightgbm/LightGBM/python-package && python setup.py install --precompile

# Remove the CUDA stubs.
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH_NO_STUBS"

# locale 설정
# RUN apt-get update && apt-get install -y locales tzdata && \
#     locale-gen ko_KR.UTF-8 && locale -a && \
#     ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    conda clean -a -y

# LANG 환경변수 설정
ENV LANG ko_KR.UTF-8

# Jupyter Notebook config 파일 생성
RUN jupyter notebook --generate-config

# config 파일 복사 (jupyter_notebook_config.py 파일 참고)
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

# 설치 완료 후 테스트용 ipynb
COPY test.ipynb /home/jupyter/test.ipynb

# 기본
EXPOSE 8888
# jupyter notebook 의 password를 지정하지 않으면 보안상 취약하므로 지정하는 것을 권장
CMD jupyter notebook --allow-root