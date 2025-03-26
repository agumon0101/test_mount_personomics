#!/bin/sh -l
#SBATCH --job-name="dr-MASK_ABCD_ICAd15"
#SBATCH -o /ceph/chpc/shared/janine_bijsterbosch_group/naranjorincon_scratch/NeuroTranslate/ty_script_ABCD_ICA/batch/dr-MASK_ABCD_ICAd15.out%j
#SBATCH -e /ceph/chpc/shared/janine_bijsterbosch_group/naranjorincon_scratch/NeuroTranslate/ty_script_ABCD_ICA/batch/dr-MASK_ABCD_ICAd15.err%j
#SBATCH -t 0-24:55:00 
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --partition=tier2_cpu 
#SBATCH --account=janine_bijsterbosch
#SBATCH --mem-per-cpu 50G

# --mem=50gb
# --time=24:55:00

# constants
base_dir="/ceph/chpc/shared/janine_bijsterbosch_group/naranjorincon_scratch/NeuroTranslate/ty_script_ABCD_ICA"  #"/scratch/tyoeasley/WAPIAW3"
# mask_fpath="${base_dir}/final_GM_mask.nii.gz" 
mk_descon="${base_dir}/ICA_data/rand_design_con.py" # ty's script that makes the necesary .mat and .con files, idk the use/fcn but Ty says not important but needed to pass thorugh code?
# mk_flist="${base_dir}/utils/eid_to_fpath.sh"
# fpath_pattern="/ceph/biobank/derivatives/melodic/sub-%s/ses-01/sub-%s_ses-01_melodic.ica/filtered_func_data_clean_MNI152.nii.gz"

# user specifications
dim=15 #100
eid_list="/scratch/tyoeasley/WAPIAW3/subject_lists/combined_subj_eid/rmed_F0_eid_wapiaw.csv"
# derivatives
groupname=ABCD #rmed_F0_eid_wapiaw
melodic_out="${base_dir}/${groupname}_ICA/ICAd${dim}" # this is what we already have for ABCD melodic results
DR_out=${melodic_out/"melodic_output"/"dual_regression"}
design_fpath_type="${DR_out}/design"
data_flist="${base_dir}/ICA_data/raw_data_subj_lists/${groupname}.txt"

# if ! test -f "${data_flist}"
# then
# 	${mk_flist} -i ${eid_list} -o ${data_flist} -p ${fpath_pattern}
# fi
n_subj=8906 #$(cat ${data_flist} | wc -l )

# output
# echo "pulling from subject list: ${eid_list}"
# echo "pulling subject data from generalized filepath: ${fpath_pattern}"
# echo "        (list of filenames of preprocessed data can be found in): ${data_flist}"
# echo "computing ${dim} independent components"
echo "sending melodic outputs to: ${melodic_out}"
if ! test -d ${melodic_out}
then
	mkdir -p ${melodic_out}
fi
echo "Just made melodic_out dir: ${DR_out}"
if ! test -d ${DR_out}/groupICA${dim}.dr
then
	mkdir -p ${DR_out}/groupICA${dim}.dr
fi

# create (mock) design matrices
# module load python # not necesary anymore
# source activate neurotranslate # used to be module load python, but have issues importing numpy so gave my conda env instead which has numpy
python ${mk_descon} -n ${n_subj} --fpath_noext ${design_fpath_type}

# load FSL module
module load fsl
export DISPLAY=:1

# if ! compgen -G "${melodic_out}/melodic_IC.nii.gz" >> /dev/null
# then
# 	echo ""
# 	echo "(re?-)computing melodic data for ${groupname}..."
# 	echo "Start: $(date)"
# 	melodic -i ${data_flist} -o ${melodic_out} --tr=0.72 --nobet -a concat -m ${mask_fpath} --report --Oall -d ${dim}
# 	echo "Finish: $(date)"
# 	echo ""
# fi

# /scratch/tyoeasley/WAPIAW3/brainrep_data/ICA_data/FSL_slurm/stage1_DR_only_slurm "${melodic_out}/melodic_IC.nii.gz" ${dim} "${design_fpath_type}.mat" "${design_fpath_type}.con" 0 "${DR_out}/groupICA${dim}.dr" $(cat ${data_flist})
${base_dir}/ICA_data/FSL_slurm/mask_only_slurm.sh "${melodic_out}/melodic_IC.nii.gz" ${dim} "${design_fpath_type}.mat" "${design_fpath_type}.con" 0 "${DR_out}/groupICA${dim}.dr" # $(cat ${data_flist})

chmod -R 771 ${DR_out}

