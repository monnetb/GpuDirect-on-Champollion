#!/bin/bash

export workDir="$PWD"


rm -rf ${workDir}/nccl-tests
git clone https://github.com/NVIDIA/nccl-tests.git


cd ${workDir}/nccl-tests

export GCC_VER=8.5.0
export GCC_ROOT="/usr"

export CUDA_VER=11.7
export CUDA_ROOT=/apps/cuda/${CUDA_VER}/cuda
export NCCL_VER=2.13.4
export NCCL_ROOT=/apps/cuda/NCCL/cuda11.7-latest # ${CUDA_ROOT}/nccl
export HOROVOD_NCCL_HOME=${NCCL_ROOT}
export CUDNN_VER=8.4.1
export CUDNN_ROOT=/apps/cuda/CUDNN/cuda-11.7-latest # ${CUDA_ROOT}/cudnn


export PATH="$GCC_ROOT/bin:${CUDA_ROOT}/bin:${NCCL_HOME}/include:$PATH"
export LD_LIBRARY_PATH="${CUDA_ROOT}/targets/x86_64-linux/lib64:${CUDNN_ROOT}/lib64:${NCCL_ROOT}/lib:$GCC_ROOT/lib64:${CUDA_ROOT}/lib64:/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH"

export MPI_VER=4.1.4
export MPI_HOME="/apps/gpu/openmpi/openmpi-${MPI_VER}-gcc${GCC_VER}-cuda${CUDA_VER}"
export LD_LIBRARY_PATH="$MPI_HOME/lib:$LD_LIBRARY_PATH"

export CUDA_HOME=${CUDA_ROOT}
export NCCL_HOME=${NCCL_ROOT}

export CFLAGS="-I${NCCL_HOME}/include"
export CPPFLAGS="-I${NCCL_HOME}/include"
export CXXFLAGS="-I${NCCL_HOME}/include"


echo "Using NCCL : $NCCL_ROOT and CUDA : $CUDA_ROOT"
sleep 2

make clean
#make MPI=1 VERBOSE=1 NVCC_GENCODE='-gencode=arch=compute_70,code=sm_70' # CFLAGS=$CFLAGS CPPFLAGS=$CPPFLAGS # MPI_HOME=$MPI_HOME NCCL_HOME=$NCCL_HOME CUDA_HOME=$CUDA_HOME
make MPI=1 VERBOSE=1  MPI_HOME=$MPI_HOME NCCL_HOME=$NCCL_HOME CUDA_HOME=$CUDA_HOME

cd ${workDir}
