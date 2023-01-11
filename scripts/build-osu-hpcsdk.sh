#!/bin/bash


# HPE Grenoble benchmark center
export HPC_SDK="/opt/nvidia/hpc_sdk/Linux_x86_64/current"
export PATH=${HPC_SDK}/cuda/bin:${HPC_SDK}/compilers/bin:$PATH
export CUDA_ROOT=${HPC_SDK}/cuda
export NCCL_ROOT=${HPC_SDK}/comm_libs/nccl
export LD_LIBRARY_PATH=${HPC_SDK}/comm_libs/nccl/lib:$LD_LIBRARY_PATH


source ${HPC_SDK}/comm_libs/hpcx/latest/hpcx-init-ompi.sh
hpcx_load


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
#./configure -v CC=mpicc CXX=mpicxx CXXFLAGS="-I${NCCL_ROOT}/include" CFLAGS="-I${NCCL_ROOT}/include" CPPFLAGS="-I${NCCL_ROOT}/include" -prefix="${curdir}/osu-micro-benchmarks-7.0-hpcx/release" --enable-ncclomb --with-nccl=${NCCL_ROOT}  --with-nccl-include=${NCCL_ROOT}/include --enable-cuda --with-cuda="${CUDA_HOME}"
./configure -v CC=mpicc CXX=mpicxx -prefix="${curdir}/osu-micro-benchmarks-7.0-hpcx/release" --enable-ncclomb --with-nccl=${NCCL_ROOT}  --with-nccl-include=${NCCL_ROOT}/include --enable-cuda --with-cuda="${CUDA_HOME}"

make -j
make install
