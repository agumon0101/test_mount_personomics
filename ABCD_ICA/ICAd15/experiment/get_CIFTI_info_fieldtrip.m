%% FIELDTRIP and CIFTI visualizations
% 
% trying to use fieldtrip to see headers in CIFTI file and ideally replace 
% template with out ABCD melodic group ICA stuff

chpc_root='/Users/snaranjo/Desktop/neurotranslate/mount_point#/ceph/chpc/shared/janine_bijsterbosch_group/naranjorincon_scratch/NeuroTranslate/';
ABCD_melodic_d15 = 'ty_script_ABCD_ICA/ABCD_ICA/ICAd15/experiment';
files_in_ABCD_pth = dir([chpc_root filesep ABCD_melodic_d15 '/*.nii']);
choose_file_HCP = files_in_ABCD_pth(strcmp({files_in_ABCD_pth.name}, 'HCPYA_melodic_IC.dscalar.nii'));
choose_file_ABCD = files_in_ABCD_pth(strcmp({files_in_ABCD_pth.name}, 'ABCD_melodic_IC.dscalar.nii'));

% example if the existing HCP melodic gro avg
get_HCP_melodic = ft_read_cifti([choose_file_HCP.folder filesep choose_file_HCP.name]);
get_ABCD_melodic = ft_read_cifti([choose_file_ABCD.folder filesep choose_file_ABCD.name]);

% histogram to see if my assumption is correct: ABCD.dscalar.nii is uniform
% and random because of how I transformed original into dscalar

figure;
histogram(get_ABCD_melodic.x10)
% so yes, its uniform now need to figrue out how to make better
