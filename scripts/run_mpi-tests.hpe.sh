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
ucx_info -d | grep -i transport
#sleep 5
export OMPI_MCA_btl=^openib
export UCX_LOG_LEVEL=error #info
export UCX_TLS=cuda,dc_x,cma,mm,knem,self
#export UCX_TLS=cma,rc_x,mm,cuda_copy,cuda_ipc,gdr_copy
export UCX_NET_DEVICES=all
export UCX_RNDV_SCHEME=get_zcopy


export curdir=$PWD

export OSU_ROOT="${PWD}/osu-micro-benchmarks-7.0/release/libexec/osu-micro-benchmarks"

export UCX_RNDV_THRESH=16384 #1024

echo "bandwidth: device to device"
mpirun -v -np 2 -npernode 1 --mca pml ucx -bind-to none --report-bindings -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  -x UCX_IB_GPU_DIRECT_RDMA=1 -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n -x CUDA_DISABLE_UNIFIED_MEMORY=1 ./scripts/bind.osu.sh ${OSU_ROOT}/mpi/pt2pt/osu_bw -d cuda D D

echo ""
echo "bandwidth: host to host"
mpirun -v -np 2 -npernode 1 --mca pml ucx -bind-to none --report-bindings -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  -x UCX_IB_GPU_DIRECT_RDMA=1 -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n -x CUDA_DISABLE_UNIFIED_MEMORY=1 ./scripts/bind.osu.sh ${OSU_ROOT}/mpi/pt2pt/osu_bw -d cuda H H

echo ""
echo "latency: device to device"
mpirun -v -np 2 -npernode 1 --mca pml ucx -bind-to none --report-bindings -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  -x UCX_IB_GPU_DIRECT_RDMA=1 -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n -x CUDA_DISABLE_UNIFIED_MEMORY=1 ./scripts/bind.osu.sh ${OSU_ROOT}/mpi/pt2pt/osu_latency -d cuda D D

echo ""
echo "latency: host to host"
mpirun -v -np 2 -npernode 1 --mca pml ucx -bind-to none --report-bindings -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  -x UCX_IB_GPU_DIRECT_RDMA=1 -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n -x CUDA_DISABLE_UNIFIED_MEMORY=1 ./scripts/bind.osu.sh ${OSU_ROOT}/mpi/pt2pt/osu_latency -d cuda H H

echo ""
echo ""
echo "bandwidth: host to device"
mpirun -v -np 2 -npernode 1 --mca pml ucx -bind-to none --report-bindings -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  -x UCX_IB_GPU_DIRECT_RDMA=1 -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n -x CUDA_DISABLE_UNIFIED_MEMORY=1 ./scripts/bind.osu.sh ${OSU_ROOT}/mpi/pt2pt/osu_bw -d cuda H D

echo ""
echo "bandwidth: device to host"
mpirun -v -np 2 -npernode 1 --mca pml ucx -bind-to none --report-bindings -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  -x UCX_IB_GPU_DIRECT_RDMA=1 -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n -x CUDA_DISABLE_UNIFIED_MEMORY=1 ./scripts/bind.osu.sh ${OSU_ROOT}/mpi/pt2pt/osu_bw -d cuda D H

### Jump to folder
#path=$(readlink -f "${BASH_SOURCE:-$0}")
#dir_path=$(dirname "$path")

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$dir_path/../nccl-rdma-sharp-plugins

### nccl-tests
#cd $dir_path/../nccl-tests

### Build
#if [ "$1" != "run" ]; then
#	make -j MPI=1 NVCC_GENCODE=-gencode=arch=compute_80,code=sm_80 
#fi

### Run
#export NCCL_DEBUG=info 
#export NCCL_DEBUG_SUBSYS=NET

#export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
#mpirun --bind-to core --map-by socket ./build/all_gather_perf -b 32M -e 8192M -f 2 -g 1
