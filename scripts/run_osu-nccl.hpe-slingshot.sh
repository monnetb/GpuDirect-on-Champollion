#!/bin/bash


# HPE Grenoble benchmark center
export GCC_VER=8.5.0
export GCC_ROOT="/usr"

export CUDA_VER=11.7
export CUDA_ROOT=/apps/cuda/${CUDA_VER}/cuda
export NCCL_VER=2.12.12
export NCCL_ROOT=/apps/cuda/NCCL/cuda11.7-latest # ${CUDA_ROOT}/nccl
#export NCCL_VER=2.16.2
#export NCCL_ROOT=/apps/gpu/nccl/nccl_2.16.2-1+cuda11.7_x86_64 # Local build
export HOROVOD_NCCL_HOME=${NCCL_ROOT}
export CUDNN_VER=8.4.1
export CUDNN_ROOT=/apps/cuda/CUDNN/cuda-11.7-latest # ${CUDA_ROOT}/cudnn


export PATH="$GCC_ROOT/bin:${CUDA_ROOT}/bin:${NCCL_HOME}/include:$PATH"
export LD_LIBRARY_PATH="${CUDA_ROOT}/targets/x86_64-linux/lib64:${CUDNN_ROOT}/lib:${NCCL_ROOT}/lib:$GCC_ROOT/lib64:${CUDA_ROOT}/lib64:/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH"

export OFI_ROOT=/opt/cray/libfabric/1.15.2.0

export MPI_VER=4.1.4
export MPI_HOME="/apps/gpu/openmpi/openmpi-${MPI_VER}-gcc${GCC_VER}-cuda${CUDA_VER}-ofi"
export LD_LIBRARY_PATH="${OFI_ROOT}/lib64:$MPI_HOME/lib:$LD_LIBRARY_PATH"
export PATH=${OFI_ROOT}/bin:${MPI_HOME}/bin:$PATH

# Adding AWS ofi plugin for NCCL
export AWS_OFI_NCCL=/apps/gpu/ofi-nccl/release
export LD_LIBRARY_PATH=${AWS_OFI_NCCL}/lib:$LD_LIBRARY_PATH

echo "Running `which mpirun` : `mpirun --version`"

export CUDA_HOME=${CUDA_ROOT}
export NCCL_HOME=${NCCL_ROOT}

# From HPL tunings
export OMP_WAIT_POLICY=active
export KMP_AFFINITY=scatter
ulimit -c 0
ulimit -s unlimited


export curdir=$PWD

export OSU_ROOT="${PWD}/osu-micro-benchmarks-7.0/release-ofi/libexec/osu-micro-benchmarks"

export OMPI_MCA_btl=^openib

export NCCL_DEBUG=INFO
#export NCCL_MIN_NCHANNELS=16
export NCCL_IB_HCA=hsn0,hsn1,hsn2,hsn3 #^eth*
#export NCCL_TOPO_DUMP_FILE=$PWD/6500-nccl-topo-ss.xml
#export NCCL_TOPO_FILE=6500-nccl-topo-ss-only.xml
export FI_LOG_LEVEL=warn #info #debug #warn


# Diana tuning
export FI_LOG_PROV=cxi
export FI_CXI_COMPAT=0
export FI_CXI_LLRING_MODE=never
export FI_CXI_EQ_ACK_BATCH_SIZE=64

#export FI_CXI_RX_MATCH_MODE=software
export FI_CXI_REQ_BUF_MIN_POSTED=10
export FI_CXI_REQ_BUF_SIZE=25165824
export FI_CXI_DEFAULT_CQ_SIZE=131072
export FI_PROVIDER="^ofi_rxm"
#export FI_PROVIDER="cxi"
#export FI_PROVIDER_PATH=${OFI_ROOT}/lib
export NCCL_NET_GDR_LEVEL=3
export FI_CXI_ATS=0
export FI_HMEM_CUDA_USE_GDRCOPY=1

export MAX_MSG_SIZE=2097152 #33554432 # 16777216 #8388608

export MPI_PARAM=" -x FI_LOG_PROV -x FI_CXI_COMPAT -x FI_CXI_EQ_ACK_BATCH_SIZE -x FI_CXI_REQ_BUF_MIN_POSTED -x FI_CXI_REQ_BUF_SIZE -x FI_CXI_DEFAULT_CQ_SIZE -x FI_PROVIDER -x NCCL_NET_GDR_LEVEL -x FI_CXI_ATS -x FI_HMEM_CUDA_USE_GDRCOPY "
echo ""
echo "AWS test "
    #--mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
`which mpirun` -v -np 2  \
    ${MPI_PARAM} \
    -host o186i239:1,o186i240:1 \
    --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to none \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    ${AWS_OFI_NCCL}/bin/nccl_message_transfer

    
echo ""
echo "OSU multiple bandwidth: host to host - no binding"
    #--mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
`which mpirun` -v -np 16  \
    -host o186i239:8,o186i240:8 \
    ${MPI_PARAM} \
    --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to none \
    -x NCCL_IB_HCA \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x NCCL_DEBUG -x NCCL_IB_HCA \
    -x CUDA_VISIBLE_DEVICES=0 \
    ${OSU_ROOT}/mpi/pt2pt/osu_mbw_mr 


#echo ""
#echo "OSU multiple bandwidth: host to host - binding only cores"
#`which mpirun` -v -np 16  \
#    -host o186i239:8,o186i240:8 \
#    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
#    -bind-to none \
#    --report-bindings \
#    -x PATH -x LD_LIBRARY_PATH \
#    -x NCCL_DEBUG -x NCCL_IB_HCA \
#    -x CUDA_VISIBLE_DEVICES=0 \
#    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
#    ./scripts/bind.slingshot-only.sh ${OSU_ROOT}/mpi/pt2pt/osu_mbw_mr 
#
#
#echo ""
#echo "OSU multiple bandwidth: host to host - bind to cores & HCA"
#`which mpirun` -v -np 16  \
#    -host o186i239:8,o186i240:8 \
#    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
#    -bind-to none \
#    --report-bindings \
#    -x PATH -x LD_LIBRARY_PATH \
#    -x NCCL_DEBUG -x NCCL_IB_HCA \
#    -x CUDA_VISIBLE_DEVICES=0 \
#    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
#    ./scripts/bind.slingshot.sh ${OSU_ROOT}/mpi/pt2pt/osu_mbw_mr 
#
#echo ""
#
    #--mca mtl_ofi_provider_include "shm" \



export CXI_FORK_SAFE=1
export FI_CXI_OPTIMIZED_MRS=false

export CXI_FORK_SAFE_HP=1
export FI_CXI_DISABLE_CQ_HUGETLB=1
	    
echo "NCCL bandwidth: device to device"
`which mpirun` -v -np 2  \
    -host o186i239:1,o186i240:1 \
    ${MPI_PARAM} \
    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
    --mca mtl_base_verbose 100 \
    -bind-to numa \
    --report-bindings \
    -x NCCL_IB_HCA \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ${OSU_ROOT}/nccl/pt2pt/osu_nccl_bw -m ${MAX_MSG_SIZE}  -d cuda D D

exit

echo ""
echo "NCCL Bidirectional bandwidth: device to device"
`which mpirun` -v -np 2  \
    -host o186i239:1,o186i240:1 \
    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to numa \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ${OSU_ROOT}/nccl/pt2pt/osu_nccl_bibw -m ${MAX_MSG_SIZE} -d cuda D D

echo ""
echo "NCCL Latency: device to device"
`which mpirun` -v -np 2  \
    -host o186i239:1,o186i240:1 \
    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to numa \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ${OSU_ROOT}/nccl/pt2pt/osu_nccl_latency -d cuda D D

echo ""
echo "OSU bandwidth: host to host"
`which mpirun` -v -np 2  \
    -host o186i239:1,o186i240:1 \
    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to numa \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ${OSU_ROOT}/mpi/pt2pt/osu_bw 

echo ""
echo "OSU multiple bandwidth: host to host"
`which mpirun` -v -np 16  \
    -host o186i239:8,o186i240:8 \
    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to numa \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ${OSU_ROOT}/mpi/pt2pt/osu_mbw_mr 

echo ""
echo ""
echo "OSU Latency: host to host"
`which mpirun` -v -np 2  \
    -host o186i239:1,o186i240:1 \
    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to numa \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ${OSU_ROOT}/mpi/pt2pt/osu_latency 

echo ""
echo "OSU Latency: device to device"
#-npernode 1
`which mpirun` -v -np 2  \
    -host o186i239:1,o186i240:1 \
    --mca pml cm --mca mtl ofi --mca btl ^openib,ofi\
    -bind-to numa \
    --report-bindings \
    -x PATH -x LD_LIBRARY_PATH \
    -x CUDA_VISIBLE_DEVICES=0 \
    -x CUDA_DISABLE_UNIFIED_MEMORY=1 \
    ${OSU_ROOT}/mpi/pt2pt/osu_latency  -d cuda D D 
