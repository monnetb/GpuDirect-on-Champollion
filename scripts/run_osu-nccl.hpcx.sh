#!/bin/bash


# HPE Grenoble benchmark center
export HPC_SDK="/opt/nvidia/hpc_sdk/Linux_x86_64/current"
export CUDA_ROOT=${HPC_SDK}/cuda
export NCCL_ROOT=${HPC_SDK}/comm_libs/nccl
export UCX_ROOT=${HPC_SDK}/comm_libs/hpcx/latest/ucx/

export PATH=${HPC_SDK}/cuda/bin:${HPC_SDK}/compilers/bin:${HPC_SDK}/comm_libs/hpcx/latest/ucx/bin:$PATH
export LD_LIBRARY_PATH=${HPC_SDK}/comm_libs/nccl/lib:hpcx:${HPC_SDK}/comm_libs/hpcx/latest/ucx/lib:$LD_LIBRARY_PATH


source ${HPC_SDK}/comm_libs/hpcx/latest/hpcx-init-ompi.sh
hpcx_load

export CUDA_HOME=${CUDA_ROOT}
export NCCL_HOME=${NCCL_ROOT}
export LD_LIBRARY_PATH="/usr/lib64:${UCX_ROOT}/lib:$LD_LIBRARY_PATH"
export PATH=${UCX_ROOT}/bin:$PATH

# From HPL tunings
export OMP_WAIT_POLICY=active
export KMP_AFFINITY=scatter
ulimit -c 0
ulimit -s unlimited

#UCX
which ucx_info
ucx_info -v
ucx_info -d | grep -i transport
sleep 5
export OMPI_MCA_btl=^openib
export UCX_LOG_LEVEL=info
#export UCX_TLS=cuda,dc_x,cma,mm,knem,self
export UCX_TLS=rc_x,cuda,sm,self
#export UCX_TLS=cma,rc_x,mm,cuda_copy,cuda_ipc,gdr_copy
export UCX_NET_DEVICES=all
export UCX_RNDV_SCHEME=get_zcopy


export curdir=$PWD

export OSU_ROOT="${PWD}/osu-micro-benchmarks-7.0-hpcx/release/libexec/osu-micro-benchmarks"

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

exit

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
