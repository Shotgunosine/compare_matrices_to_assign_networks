function settings=settings_comparematrices()

%% Define the paths for support functions
str = computer;
code_dir = pwd;
server_name=code_dir(1:10);

switch server_name
    case '/mnt/max/s' %rushmore
        path{1}='/mnt/max/shared/code/external/utilities/MSCcodebase/Utilities/';
        path{2}='/mnt/max/shared/code/external/utilities/Matlab_CIFTI';
        path{3}='/mnt/max/shared/code/external/utilities/Matlab_effect_size_toolbox/';
        path{4}='/mnt/max/shared/code/internal/utilities/hcp_comm_det_damien/Gordan_subcortical_template_ptseries.conc_AVG.pconn.nii';
        %templates:
        path{5}='/mnt/max/shared/code/internal/utilities/community_detection/fair/supporting_files/Networks_template_cleaned.pscalar.nii';
        path{6}='/mnt/max/shared/code/internal/utilities/community_detection/fair/supporting_files/Networks_template_cleaned.dscalar.nii';
        path{7}='/mnt/max/shared/data/study/ADHD/HCP/processed/ADHD_NoFMNoT2/10050-1/20100430-SIEMENS_TrioTim-Nagel_K_Study/HCP_release_20161027/10050-1/MNINonLinear/Results/10050-1_FNL_preproc_Gordon_subcortical.ptseries.nii_5_minutes_of_data_at_FD_0.2.pconn.nii_to_Gordan_subcortical_template_ptseries.conc_AVG.pconn.nii.pscalar.nii';
        path{8}='/mnt/max/shared/code/internal/pipelines/HCP_release_20170910_v1.4/global/templates/91282_Greyordinates/91282_Greyordinates.dscalar.nii'; 
        path{9}='/mnt/max/shared/code/internal/utilities/hcp_comm_det_damien/Merged_HCP_best80_dtseries.conc_AVG.dconn.nii';
        path{10}='/mnt/max/shared/code/internal/utilities/community_detection/fair/supporting_files/120_LR_minsize400_recolored_manualconsensus4.dtseries.nii';              
        path{11}='/mnt/max/shared/code/external/utilities/gifti-1.6';
        path{12}='/mnt/max/shared/code/internal/utilities/Zscore_dconn/';
        path{13}='/mnt/max/shared/code/internal/analyses/compare_matrices/support_files/91282_Greyordinates.dtseries.nii';
        %path{12}='/mnt/max/shared/code/internal/analyses/compare_martices/support_files/seedmaps_ADHD_Control_20_subs_dtseries_all_networks_fromsurfonly.mat';
        
        path_template_nets='/mnt/max/shared/code/internal/analyses/compare_matrices/support_files/seedmaps_ADHD_smoothed_dtseries315_all_networks_fromsurfonly.mat';
        path_wb_c='LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/local/bin/wb_command'; % workbench command path
  
    case '/home/exac' %lustre filesystem
        path{1}='/home/exacloud/lustre1/fnl_lab/code/external/utilities/MSCcodebase/Utilities';
        path{2}='/home/exacloud/lustre1/fnl_lab/code/external/utilities/Matlab_CIFTI';
        path{3}='/home/exacloud/lustre1/fnl_lab/code/external/utilities/Matlab_effect_size_toolbox/';
        path{4}='/home/exacloud/lustre1/fnl_lab/code/internal/utilities/hcp_comm_det_damien/Gordan_subcortical_template_ptseries.conc_AVG.pconn.nii';
        %templates:
        path{5}='/home/exacloud/lustre1/fnl_lab/code/internal/utilities/community_detection/fair/supporting_files/Networks_template_cleaned.pscalar.nii';
        path{6}='/home/exacloud/lustre1/fnl_lab/code/internal/utilities/community_detection/fair/supporting_files/Networks_template_cleaned.dscalar.nii';
        path{7}='/home/exacloud/lustre1/fnl_lab/data/study/ADHD/HCP/processed/ADHD_NoFMNoT2/10050-1/20100430-SIEMENS_TrioTim-Nagel_K_Study/HCP_release_20161027/10050-1/MNINonLinear/Results/10050-1_FNL_preproc_Gordon_subcortical.ptseries.nii_5_minutes_of_data_at_FD_0.2.pconn.nii_to_Gordan_subcortical_template_ptseries.conc_AVG.pconn.nii.pscalar.nii';
        path{8}='/home/exacloud/lustre1/fnl_lab/code/internal/pipelines/HCP_release_20170910_v1.4/global/templates/91282_Greyordinates/91282_Greyordinates.dscalar.nii'; 
        path{9}='/home/exacloud/lustre1/fnl_lab/code/internal/utilities/hcp_comm_det_damien/Merged_HCP_best80_dtseries.conc_AVG.dconn.nii';
        path{10}='/home/exacloud/lustre1/fnl_lab/code/internal/utilities/community_detection/fair/supporting_files/120_LR_minsize400_recolored_manualconsensus4.dtseries.nii';
        path{11}='/home/exacloud/lustre1/fnl_lab/code/external/utilities/gifti-1.6';
        path{12}='/home/exacloud/lustre1/fnl_lab/code/internal/utilities/Zscore_dconn/';
        path{13}='/home/exacloud/lustre1/fnl_lab/code/internal/analyses/compare_matrices/support_files/91282_Greyordinates.dtseries.nii';
        %path_template_nets='/home/exacloud/lustre1/fnl_lab/code/internal/analyses/compare_matrices/support_files/seedmaps_ADHD_smoothed_dtseries315_all_networks_fromsurfonly.mat';
        path_template_nets='/home/exacloud/lustre1/fnl_lab/code/internal/analyses/compare_matrices/support_files/seedmaps_ADHD_smoothed_dtseries315_all_networks_Zscored.mat';
        
        %path_wb_c='/home/exacloud/lustre1/fnl_lab/code/external/utilities/workbench-9253ac2/bin_rh_linux64/wb_command'; % workbench command path
        path_wb_c='/home/exacloud/lustre1/fnl_lab/code/external/utilities/workbench-1.2.3-HCP/bin_rh_linux64/wb_command';
        %Beastpaths
        %path{1}='/group_shares/PSYCH/code/external/utilities/gifti-1.6';
        %path{2}='/group_shares/PSYCH/code/external/utilities/Matlab_CIFTI';
        %path_wb_c='/usr/global/hcp_workbench/bin_linux64/wb_command'; %path to wb_command       
        
    case '/home/exacloud/tempwo' 
        path{1}='/home/exacloud/tempwork/fnl_lab/code/external/utilities/gifti-1.6';
        path{2}='/home/exacloud/tempwork/fnl_lab/code/external/utilities/Matlab_CIFTI';
        path{3}='/home/exacloud/tempwork/fnl_lab/code/external/utilities/Matlab_effect_size_toolbox/';
        path{4}='/home/exacloud/tempwork/fnl_lab/code/internal/utilities/hcp_comm_det_damien/Gordan_subcortical_template_ptseries.conc_AVG.pconn.nii';
        %templates:
        path{5}='/home/exacloud/tempwork/fnl_lab/code/internal/utilities/community_detection/fair/supporting_files/Networks_template_cleaned.pscalar.nii';
        path{6}='/home/exacloud/tempwork/fnl_lab/code/internal/utilities/community_detection/fair/supporting_files/Networks_template_cleaned.dscalar.nii';
        path{7}='/home/exacloud/tempwork/fnl_lab/data/study/ADHD/HCP/processed/ADHD_NoFMNoT2/10050-1/20100430-SIEMENS_TrioTim-Nagel_K_Study/HCP_release_20161027/10050-1/MNINonLinear/Results/10050-1_FNL_preproc_Gordon_subcortical.ptseries.nii_5_minutes_of_data_at_FD_0.2.pconn.nii_to_Gordan_subcortical_template_ptseries.conc_AVG.pconn.nii.pscalar.nii';
        path{8}='/home/exacloud/tempwork/fnl_lab/code/internal/pipelines/HCP_release_20170910_v1.4/global/templates/91282_Greyordinates/91282_Greyordinates.dscalar.nii'; 
        path{9}='/home/exacloud/tempwork/fnl_lab/code/internal/utilities/hcp_comm_det_damien/Merged_HCP_best80_dtseries.conc_AVG.dconn.nii';        
        path_wb_c='/home/exacloud/tempwork/fnl_lab/code/external/utilities/workbench-9253ac2/bin_rh_linux64/wb_command'; % workbench command path
        
        
        
    case 'PCWIN64'
        path{1}='P:\code\external\utilities\gifti-1.6';
        path{2}='P:\code\external\utilities\Matlab_CIFTI';   
        path_wb_c='C:\Program Files\workbench-windows64-v1.1.1\workbench\bin_windows64\wb_command'; %path to wb_command
end

settings.path=path;
settings.path_template_nets=path_template_nets;
settings.path_wb_c=path_wb_c;
