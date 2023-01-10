#!/bin/bash


# HPE Grenoble benchmark center
export GCC_VER=8.5.0
export GCC_ROOT="/usr"

export CUDA_VER=11.7
export CUDA_ROOT=/apps/cuda/${CUDA_VER}/cuda
export NCCL_VER=2.12.12
export NCCL_ROOT=/apps/cuda/NCCL/cuda11.7-latest # ${CUDA_ROOT}/nccl
export HOROVOD_NCCL_HOME=${NCCL_ROOT}
export CUDNN_VER=8.4.1
export CUDNN_ROOT=/apps/cuda/CUDNN/cuda-11.7-latest # ${CUDA_ROOT}/cudnn


export PATH="$GCC_ROOT/bin:${CUDA_ROOT}/bin:${NCCL_HOME}/include:$PATH"
export LD_LIBRARY_PATH="${CUDA_ROOT}/targets/x86_64-linux/lib64:${CUDNN_ROOT}/lib64:${NCCL_ROOT}/lib:$GCC_ROOT/lib64:${CUDA_ROOT}/lib64:/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH"

export MPI_VER=4.1.4
export MPI_HOME="/apps/gpu/openmpi/openmpi-${MPI_VER}-gcc${GCC_VER}-cuda${CUDA_VER}"
export LD_LIBRARY_PATH="$MPI_HOME/lib:$LD_LIBRARY_PATH"
export PATH=${MPI_HOME}/bin:$PATH

export CUDA_HOME=${CUDA_ROOT}
export NCCL_HOME=${NCCL_ROOT}

# From HPL tunings
export OMP_WAIT_POLICY=active
export KMP_AFFINITY=scatter
ulimit -c 0
ulimit -s unlimited

#UCX 
#ucx_info -d | grep -i transport
#sleep 5
export OMPI_MCA_btl=^openib
export UCX_LOG_LEVEL=error
export UCX_TLS=cuda,dc_x,cma,mm,knem,self
export UCX_NET_DEVICES=all


# get lastest version 
OSU="osu-micro-benchmarks-7.0.tar.gz"
if [[ ! -f "$OSU" ]]
then
    wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.0.tar.gz
fi
rm -rf osu-micro-benchmarks-7.0 > /dev/null
tar xf osu*gz

export curdir=$PWD

cd osu-micro-benchmarks-7.0
./configure CC=mpicc CXX=mpicxx -prefix="${curdir}/osu-micro-benchmarks-7.0/release" --enable-ncclomb --with-nccl=${NCCL_ROOT} --enable-cuda --with-cuda="${CUDA_HOME}"

make -j
make install
