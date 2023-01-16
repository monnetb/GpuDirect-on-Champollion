#!/bin/bash


# HPE Grenoble benchmark center
export GCC_VER=4.8.5
export GCC_ROOT="/usr"




# Karolina  benchmark center
module purge
module load  OpenMPI/4.1.2-NVHPC-22.2-CUDA-11.6.0-v2
export GCC_ROOT="/usr"

export CUDA_VER=11.7
export CUDA_ROOT=/apps/all/CUDAcore/11.7.0
export NCCL_VER=2.13.4
export NCCL_ROOT=/home/it4i-monnet/libs/nccl_2.13.4-1-cuda11.7
export HOROVOD_NCCL_HOME=${NCCL_ROOT}
export CUDNN_VER=8.4.1
export CUDNN_ROOT=/home/it4i-monnet/libs/cudnn_8.4.1.50_cuda11.6


export GDRDRV_ROOT=/home/it4i-monnet/libs/gdrcopy-cuda11.7
export UCX_ROOT=/home/it4i-monnet/UCX/ucx-gcc4.8.5-cuda11.7

export PATH=.:${UCX_ROOT}/bin:${CUDA_ROOT}/bin:${GCC_ROOT}/bin:${NCCL_HOME}/include:$PATH
export LD_LIBRARY_PATH=${GDRDRV_ROOT}/lib:${CUDA_ROOT}/lib64:${UCX_ROOT}/lib:${NCCL_ROOT}/lib:${CUDA_ROOT}/targets/x86_64-linux/lib:$LD_LIBRARY_PATH

export MPI_VER=4.1.4
export MPI_HOME="/home/it4i-monnet/openmpi/openmpi-4.1.4-gcc4.8.5-cuda11.7"
export LD_LIBRARY_PATH="$MPI_HOME/lib:$LD_LIBRARY_PATH"
export PATH=${MPI_HOME}/bin:$PATH
echo "Running `which mpirun` : `mpirun --version`"

export CUDA_HOME=${CUDA_ROOT}
export NCCL_HOME=${NCCL_ROOT}


# From HPL tunings
export OMP_WAIT_POLICY=active
export KMP_AFFINITY=scatter
ulimit -c 0
ulimit -s unlimited

#UCX 
UCX_LOG_LEVEL=debug ucx_info -d | grep -i gdr
UCX_LOG_LEVEL=debug ucx_info -d | grep -i transport

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

ldd ${OSU_ROOT}/mpi/pt2pt/osu_latency

export NCCL_DEBUG=info #INFO
export UCX_LOG_LEVEL=debug

echo ""
echo "OSU bandwidth: host to host"
mpirun -v -np 2  \
    -host acn23:1,acn31:1\
    --mca pml ucx -bind-to numa \
    --report-bindings \
    -x CUDA_VISIBLE_DEVICES=0 -x LD_LIBRARY_PATH  \
    -x UCX_TLS \
    -x PATH -x LD_LIBRARY_PATH \
    ${OSU_ROOT}/mpi/pt2pt/osu_bw 


exit
echo "NCCL bandwidth: device to device"
#-npernode 1

    #-npernode 1\

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
    -npernode 1\
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
