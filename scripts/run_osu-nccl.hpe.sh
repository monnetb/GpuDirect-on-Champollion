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
export LD_LIBRARY_PATH="${CUDA_ROOT}/targets/x86_64-linux/lib64:${CUDNN_ROOT}/lib:${NCCL_ROOT}/lib:$GCC_ROOT/lib64:${CUDA_ROOT}/lib64:/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH"

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
#export UCX_TLS=cuda,dc_x,cma,mm,knem,self
export UCX_TLS=rc_x,cuda,sm,self
#export UCX_TLS=cma,rc_x,mm,cuda_copy,cuda_ipc,gdr_copy
export UCX_NET_DEVICES=all
export UCX_RNDV_SCHEME=get_zcopy


export curdir=$PWD

export OSU_ROOT="${PWD}/osu-micro-benchmarks-7.0/release/libexec/osu-micro-benchmarks"
#osu-micro-benchmarks-7.0/release/libexec/osu-micro-benchmarks/nccl/pt2pt/

export UCX_RNDV_THRESH=1024 #16384 #1024

#export NCCL_DEBUG=INFO

echo "NCCL bandwidth: device to device"
#-npernode 1

export MAX_MSG_SIZE=33554432 # 16777216 #8388608
mpirun -v -np 2  \
    --mca pml ucx -bind-to none \
    --report-bindings \
    -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  \
    -x UCX_IB_GPU_DIRECT_RDMA=1 \
    -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ./scripts/bind.osu.sh ${OSU_ROOT}/nccl/pt2pt/osu_nccl_bw -m ${MAX_MSG_SIZE}  -d cuda D D

echo ""
echo "NCCL Bidirectional bandwidth: device to device"
#-npernode 1
mpirun -v -np 2  \
    --mca pml ucx -bind-to none \
    --report-bindings \
    -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  \
    -x UCX_IB_GPU_DIRECT_RDMA=1 \
    -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ./scripts/bind.osu.sh ${OSU_ROOT}/nccl/pt2pt/osu_nccl_bibw -m ${MAX_MSG_SIZE} -d cuda D D

echo ""
echo "NCCL Latency: device to device"
#-npernode 1
mpirun -v -np 2  \
    --mca pml ucx -bind-to none \
    --report-bindings \
    -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  \
    -x UCX_IB_GPU_DIRECT_RDMA=1 \
    -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ./scripts/bind.osu16cores.sh ${OSU_ROOT}/nccl/pt2pt/osu_nccl_latency -d cuda D D

echo ""
echo "OSU Latency: host to host"
mpirun -v -np 2  \
    --mca pml ucx -bind-to none \
    --report-bindings \
    -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  \
    -x UCX_TLS \
    ./scripts/bind.core48.sh ${OSU_ROOT}/mpi/pt2pt/osu_latency 

echo "OSU Latency: host to host : core 48"
mpirun -v -np 2  \
    --mca pml ucx -bind-to none \
    --report-bindings \
    -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  \
    -x UCX_TLS \
    ./scripts/bind.core48.sh ${OSU_ROOT}/mpi/pt2pt/osu_latency 


echo ""
echo "OSU Latency: device to device"
#-npernode 1
mpirun -v -np 2  \
    --mca pml ucx -bind-to none \
    --report-bindings \
    -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  \
    -x UCX_IB_GPU_DIRECT_RDMA=1 \
    -x UCX_TLS -x UCX_RNDV_THRESH -x UCX_MEMTYPE_CACHE=n \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ./scripts/bind.core48.sh ${OSU_ROOT}/mpi/pt2pt/osu_latency  -d cuda D D 
