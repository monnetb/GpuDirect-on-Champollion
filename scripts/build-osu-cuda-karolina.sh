#!/bin/bash


# Karolina  benchmark center
module purge
#module load  OpenMPI/4.1.2-NVHPC-22.2-CUDA-11.6.0-v2 


export GCC_VER=4.8.5
export GCC_ROOT=/
export CUDA_VER=11.7
export CUDA_ROOT=/apps/all/CUDA/11.7.0

export GDRDRV_ROOT=/home/it4i-monnet/libs/gdrcopy-cuda11.7
export UCX_ROOT=/home/it4i-monnet/libs/UCX/ucx-gcc4.8.5-cuda11.7


export NCCL_VER=2.13.4
export NCCL_ROOT=/home/it4i-monnet/libs/nccl_2.13.4-1-cuda11.7
export HOROVOD_NCCL_HOME=${NCCL_ROOT}
export CUDNN_VER=8.4.1
export CUDNN_ROOT=/home/it4i-monnet/libs/cudnn_8.4.1.50_cuda11.6

export PATH=.:${UCX_ROOT}/bin:${CUDA_ROOT}/bin:${GCC_ROOT}/bin:${NCCL_HOME}/include:$PATH
export LD_LIBRARY_PATH=${GDRDRV_ROOT}/lib:${CUDA_ROOT}/lib64:${UCX_ROOT}/lib:${CUDA_ROOT}/targets/x86_64-linux/lib:$LD_LIBRARY_PATH

export MPI_VER=4.1.4
export MPI_HOME="/home/it4i-monnet/openmpi/openmpi-4.1.4-gcc4.8.5-cuda11.7"
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
