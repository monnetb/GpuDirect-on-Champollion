#!/bin/bash


export APP=$@

CPU_CORES_PER_RANK=8  
export KMP_AFFINITY=scatter
export OMP_NUM_THREADS=$CPU_CORES_PER_RANK
export MKL_NUM_THREADS=$CPU_CORES_PER_RANK
export OMP_WAIT_POLICY=active

lrank=$OMPI_COMM_WORLD_LOCAL_RANK

case ${lrank} in
[0])
  BINDING="--physcpubind=48-55 --membind=3"
  export UCX_NET_DEVICES=mlx5_0:1
  ;;
[1])
  BINDING="--physcpubind=56-63 --membind=3"
  export UCX_NET_DEVICES=mlx5_0:1
  ;;
[2])
  BINDING="--physcpubind=16-23 --membind=1"
  export UCX_NET_DEVICES=mlx5_1:1
  ;;
[3])
  BINDING="--physcpubind=16-23 --membind=1"
  export UCX_NET_DEVICES=mlx5_1:1
  ;;
[4])
  BINDING="--physcpubind=48-55 --membind=3"
  export UCX_NET_DEVICES=mlx5_0:1
  ;;
[5])
  BINDING="--physcpubind=56-63 --membind=3"
  export UCX_NET_DEVICES=mlx5_0:1
  ;;
[6])
  BINDING="--physcpubind=16-23 --membind=1"
  export UCX_NET_DEVICES=mlx5_1:1
  ;;
[7])
  BINDING="--physcpubind=16-23 --membind=1"
  export UCX_NET_DEVICES=mlx5_1:1
  ;;
esac

export CUDA_VISIBLE_DEVICES=${lrank}

if [[ ${lrank} -eq 0 ]]
then
    echo "Running on `hostname`"
fi
numactl ${BINDING} $APP