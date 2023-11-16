#!/bin/bash

openfoam="/usr/lib/openfoam/openfoam2306/etc/bashrc"
source $openfoam
nprocs=60

# Directory related things
wdir=$(pwd)
cd
home=$(pwd)
cd $wdir
git_root=$(git rev-parse --show-toplevel)

# Apptainer related
image="$home/mb-42/infrastructure/containers/openfoam/versions/v1706/pmi2-openfoam-v1706.sif"

if [[ $1 == "surf" ]]; then
  surfaceFeatureExtract
elif [[ $1 == "mesh" ]]; then
  rm -rf proc* *e-* 0.0*
  blockMesh
#   decomposePar -decomposeParDict system/decomposeParDict.snappy -force | tee log/decomposePar
#   mpirun -np $nprocs snappyHexMesh -parallel -overwrite | tee log/snappy
#   reconstructParMesh -mergeTol 1e-6 -constant | tee log/reconstructMesh
#   checkMesh | tee log/checkMesh
#   foamToVTK -latestTime -noPointValues
  # apptainer run $image snappyHexMesh -overwrite
  # sbatch slurm/mesh
elif [[ $1 == "pre" ]]; then
  # If directory doesn't already exist, reconstruct
  if [ ! -d "0" ]; then
    cp -r 0.orig 0
  fi

  # Remove old velocity field if `setFields` was used
  rm -f 0/U
  cp 0/ref/U.orig 0/U
  sed -i "/numberOfSubdomains/c\numberOfSubdomains $nprocs;" system/decomposeParDict
  apptainer run $image setFields
  apptainer run $image decomposePar -force | tee log/decomposePar
    mpirun -np $procs snappyHexMesh -parallel -overwrite | tee out.snappy
elif [[ $1 == "run" ]]; then
  sbatch slurm/hystrath
elif [[ $1 == "test" ]]; then
  apptainer run $image hy2Foam
elif [[ $1 == "post" ]]; then
  rm -rf VTK
  t="latestTime"
  apptainer run $image reconstructPar -$t
  apptainer run $image foamToVTK -latestTime -noPointValues
elif [[ $1 == "plot" ]]; then
  python3 src/plot_residuals.py
fi

# Scratch
  # singularity exec $container src/singularity/reconstruct.sh
  # mpirun -np 6 singularity exec $container src/singularity/snappyHexMesh.sh
  # singularity exec $container src/singularity/snappyHexMesh.sh
  # singularity exec $container src/singularity/blockMesh.sh
  # snappyHexMesh -overwrite | tee out.snappy
  # reconstructParMesh -mergeTol 1e-6 -constant
  # yes | cp -rf constant/polyMesh $git_root/$target_dir/constant/.
  # setFields | tee log/setFields
