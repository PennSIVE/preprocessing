#!/bin/bash

set -euf

# for example
for subj in $(ls /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all | grep ^sub)
do
    mkdir -p /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/derivatives/${subj}/ses-001 || true
    qsub -b y -cwd -l h_vmem=8G -o \$JOB_ID.preproc -e \$JOB_ID.preproc env -i singularity run \
    -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-001_T2w.nii.gz:/flair.nii.gz:ro \
    -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/${subj}/ses-001/anat/${subj}_ses-001_run-001_T1w.nii.gz:/T1.nii.gz:ro \
    -B /cbica/projects/UVMdata/bids/datasets/2020-06-07/Nifti_all/derivatives/${subj}/ses-001:/out \
    /cbica/home/robertft/singularity_images/preprocessing_latest.sif --out /out/${subj}_flair_n4_reg2t1n4_brain_ws
done