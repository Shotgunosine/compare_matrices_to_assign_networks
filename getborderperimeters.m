function [network_lengths_for_each_sub] = getborderperimeters(dlabel_conc,L_surf_conc,R_surf_conc,remove_border_files,remove_hemigii_files,output_folder,output_name,get_compactness,varargin)
%This code calculates the perimenter of the networks in a a conc of label files. Surface files are necessary to calculate inter-greylength.

%R. Hermosillo 10/22/2020

%This function calculates the border length (perimenter) of all the
%clusters in your cifti file and outputs as matlab table of perimeters.

%Required Inputs are:
%1)input_cifti_list (e.g. a conc file) a list of paths to your dlabel files.  If you have dscalar
%files, you'll need to convert them to dlabels first. Use: "wb_command
%-cifti-label-import mydscalar.nii mylabeltable.txt mydlabel.nii"

%2) L_surf_conc: A .conc file (a list) of the paths to the left midthickness surface

%3) R_surf_conc: A .conc file (a list) of the paths to the right midthickness surface
% Note on surface files: mapping must match the dlabel mapping (e.g. surface greyordinates must be the same number)

%4) remove_border_files: border files are created as an intermediate step
%to be able to calculate the perimeter.  Set to "1" if you want to remove
%the intermediate files.  Set to "0" if you want to keep them.

%5) remove_hemigii_files: intermediate files that are created from the
%dlabel.  Border files can only be generated from 1 hemisphere at a time.

%6) Calculate network compactness using Polsby-Popper: Set to 1 if you want to calculate
%compactness. Set to 0 you just want the border perimeters.

%7) Varagin1 = Path to surface areas.  This can be a .mat file.  It is assumed that the .mat
%file is the same length and the same order as the dlabel conc file.

%Outputs are p x 2 a cell array where p is the number of subjects and the
%first column is the left hemiphere and the right is the second
%resepctively.

% Within each cell contains another cell array that a network x measure array, four columns:
% 1) Network name
% 2) number of patches in the network
% 3) The length of each patch (as a vector)
% 4) the total border length of all patches.

%--------------
% Updates
% R. Hermosillo update 01/21/2022 - Added verbose messages and added
% additional clean up option to remove intermediate files.

%% Start  - add dependencies
run_locally =0;
seperate_pieces =1;

if run_locally ==1
    %Some hardcodes:
    wb_command = ('C:\Users\hermosir\Desktop\workbench\bin_windows64\wb_command');
    addpath(genpath('C:\Users\hermosir\Documents\repos\HCP_MATLAB'));
    addpath('C:\Users\hermosir\Documents\repos\MSCcodebase-master\Utilities\read_write_cifti\utilities')
    addpath('C:\Users\hermosir\Documents\repos\MSCcodebase-master\Utilities\read_write_cifti\gifti')
    addpath('C:\Users\hermosir\Documents\repos\MSCcodebase-master\Utilities\read_write_cifti\fileio')
    %     Dlabelconc = ''
    %     L_surf = 'C:\Users\hermosir\Documents\repos\MSCcodebase-master\Utilities\Conte69_atlas-v2.LR.32k_fs_LR.wb\Conte69.L.midthickness.32k_fs_LR.surf.gii';
    %     R_surf = 'C:\Users\hermosir\Documents\repos\MSCcodebase-master\Utilities\Conte69_atlas-v2.LR.32k_fs_LR.wb\Conte69.R.midthickness.32k_fs_LR.surf.gii';
else
    %% Adding paths for this function
    this_code = which('getborderperimeters');
    [code_dir,~] = fileparts(this_code);
    support_folder=[code_dir '/support_files']; %find support files in the code directory.
    addpath(genpath(support_folder));
    settings=settings_comparematrices;%
    np=size(settings.path,2);
    
    disp('Attempting to add neccesaary paths and functions.')
    warning('off') %supress addpath warnings to nonfolders.
    for i=1:np
        addpath(genpath(settings.path{i}));
    end
    addpath(genpath('/home/exacloud/lustre1/fnl_lab/code/internal/utilities/plotting-tools'));
    addpath(genpath('/mnt/max/shared/code/internal/utilities/plotting-tools'));
    warning('on')
    wb_command=settings.path_wb_c; %path to wb_command
end

    %% Step 0) validate input file existence
    conc = strsplit(dlabel_conc, '.');
    conc = char(conc(end));
    if strcmp('conc',conc) == 1
        input_cifti_list = importdata(dlabel_conc);
    else
        input_cifti_list = {dlabel_conc};
    end
   
 if exist([output_folder filesep output_name '_perimeters.mat'],'file') ==0
    disp(['Final perimeter file (.mat) not found. Expected name: ' output_folder filesep output_name '_perimeters.mat'])
    disp('Starting from the beginning...')   
    
    for i = 1:length(input_cifti_list)
        if exist(input_cifti_list{i},'file') == 0
             error(['Subject Series ' num2str(i) ' does not exist'])
            %return
        else
        end
    end
    disp('All dlabel files exist continuing ...')
    
    if strcmp('conc',conc) == 1
        Lsurfs = importdata(L_surf_conc);
    else
        Lsurfs = {L_surf_conc};
    end
    
    for i = 1:length(Lsurfs)
        if exist(Lsurfs{i},'file') == 0
            error(['Subject left surface ' num2str(i) ' does not exist'])
            %return
        else
        end
    end
    disp('All left surface files exist continuing ...')
    
    if strcmp('conc',conc) == 1
        Rsurfs = importdata(R_surf_conc);
    else
        Rsurfs = {R_surf_conc};
    end
    
%     for i = 1:length(Rsurfs)
%         if exist(Rsurfs{i},'file') == 0
%             error(['Subject right surface ' num2str(i) ' file does not exist'])
%             %return
%         else
%         end
%     end
    disp('All required files exist continuing ...')
    
    if length(input_cifti_list)==length(Lsurfs) || length(Lsurfs)==length(Rsurfs) || length(input_cifti_list)==length(Rsurfs)
    else
        error('One of your conc files is a different length than the others. Subject data will not be corresponding across input files.')
    end
    
    network_lengths_for_each_sub =cell(length(input_cifti_list),2);
    %% Start
    for k = 1:length(input_cifti_list)
        disp(k)
        input_cifti = char(input_cifti_list(k));
        L_surf = char(Lsurfs(k));
        R_surf = char(Rsurfs(k));
        
        [label_path, label_rootWlabel, ~] = fileparts(input_cifti);
        [~, label_root, ~] = fileparts(label_rootWlabel);
        
        if strcmp(input_cifti(end-9:end-4),'dlabel')==1 % check if extention is label.
            fileisdlabel =1;
        else
            fileisdlabel =0;
        end
        %step 1 - check input file type to see if it's a dlabel
        if fileisdlabel ==1
        else
            disp('Convert dscalars into dlabel files first.')
            return
        end
        
        %step 2 % seperate dlabels into 2 label .giis
        cmd = [wb_command ' -cifti-separate ' label_path filesep label_root '.dlabel.nii COLUMN -label CORTEX_LEFT ' label_path filesep label_root '.L.label.gii -label CORTEX_RIGHT ' label_path filesep label_root '.R.label.gii'];
        disp(cmd);
        system(cmd);
        
        %step 3 % convert labels to borders.
        cmd = [wb_command ' -label-to-border ' L_surf  ' ' label_path filesep label_root '.L.label.gii ' label_path filesep label_root '.L.border'];
        disp(cmd);
        system(cmd);
        cmd = [wb_command ' -label-to-border ' R_surf  ' ' label_path filesep label_root '.R.label.gii ' label_path filesep label_root '.R.border'];
        disp(cmd);
        system(cmd);
        
        %step 4 % Calculate border lenth.
        %Left hemisphere
        if seperate_pieces ==1
            cmd = [wb_command ' -border-length -separate-pieces ' label_path filesep label_root '.L.border ' L_surf ];
        else
            cmd = [wb_command ' -border-length ' label_path filesep label_root '.L.border ' L_surf ];
        end
        
        disp(cmd);
        [~,L_net_length_concat] = system(cmd);
        L_net_length = strsplit(L_net_length_concat,'\n');
        
        L_net_length = L_net_length';
        L_net_length(end) = [];
        
        %net_table =table(size(L_net_length,1),2);
        %net_table =array2table(zeros(size(L_net_length,1),2)); % create empty table.
        
        for i =1: size(L_net_length,1)
            %disp(i)
            this_line = char(L_net_length(i));
            [net_name] = strsplit(this_line,' ');
            Lnet_table{i,1} = net_name{1};
            for j = 2:length(net_name)
                this_nets_lenths(j-1) =  str2double(net_name(j));
            end
            if seperate_pieces ==1
                Lnet_table{i,2} = length(net_name)-1;
                Lnet_table{i,3} = this_nets_lenths'; %convert to numeric.
                Lnet_table{i,4} = sum(this_nets_lenths);
            else
                Lnet_table{i,2} = this_nets_lenths'; %convert to numeric.
            end
            
            clear this_nets_lenths
        end
        
        
        
        %Right Hemisphere
        if seperate_pieces ==1
            cmd = [wb_command ' -border-length -separate-pieces ' label_path filesep label_root '.R.border ' R_surf ];
        else
            cmd = [wb_command ' -border-length ' label_path filesep label_root '.R.border ' R_surf ];
        end
        disp(cmd);
        
        [~,R_net_length_concat] = system(cmd);
        R_net_length = strsplit(R_net_length_concat,'\n');
        R_net_length = R_net_length';
        R_net_length(end) = [];
        
        for i =1: size(R_net_length,1)
            this_line = char(R_net_length(i));
            [net_name] = strsplit(this_line,' ');
            Rnet_table{i,1} = net_name{1};
            for j = 2:length(net_name)
                this_nets_lenths(j-1) =  str2double(net_name(j));
            end
            if seperate_pieces ==1
                Rnet_table{i,2} = length(net_name)-1;
                Rnet_table{i,3} = this_nets_lenths'; %convert to numeric.
                Rnet_table{i,4} = sum(this_nets_lenths);
            else
                Rnet_table{i,2} = this_nets_lenths'; %convert to numeric.
            end
            clear this_nets_lenths
        end
        
        network_lengths_for_each_sub{k,1} = Lnet_table;
        network_lengths_for_each_sub{k,2} = Rnet_table;
        
        % x = cell2mat(Lnet_table(:,2));
        % y = cell2mat(Rnet_table(:,2));
        % scatter(x,y);
        disp(['Done getting border length for subject: ' num2str(k)]);
        
        %Step 5a Optional -remove border files.
        if remove_border_files ==1
            cmd = [ ' rm ' label_path filesep label_root '.L.border'];
            disp(cmd);
            system(cmd);
            cmd = [ ' rm ' label_path filesep label_root '.R.border'];
            disp(cmd);
            system(cmd);
        else
            %do nothing.  Be mindful of space.
        end
        %Step 5b Optional -remove hemispheric label files.
        if remove_hemigii_files ==1
            cmd = [ ' rm ' label_path filesep label_root '.L.label.gii'];
            disp(cmd);
            system(cmd);
            cmd = [ ' rm ' label_path filesep label_root '.R.label.gii'];
            disp(cmd);
            system(cmd);
        else
            %do nothing.  Be mindful of space.
        end
        
        clear Lnet_table Rnet_table
    end
    

    
    save([output_folder filesep output_name '_perimeters.mat'],'input_cifti_list','network_lengths_for_each_sub')
    
    disp('Done getting border length for all subjects')
else
    disp('Perimter file (.mat) already found. Loading...')
    load([output_folder filesep output_name '_perimeters.mat'],'network_lengths_for_each_sub');
end
%% Step6 -Optional - calculate compactness
if get_compactness ==1
    network_suface_area_mat_file_or_var =varargin{1};
    % Get compactness score:
    [scores,cluster_num_pvalue, compactness_pvalue,avg_compact_pval,avg_num_clusters_pval] = calculate_network_compactness(network_suface_area_mat_file_or_var,[output_folder filesep output_name '_perimeters.mat'],'polsbypopper',0);
    save([output_folder filesep output_name '_PPcompactness_scores.mat'],'input_cifti_list','scores')
    
    [bad_subs, ~] = find(scores >1);
    if isempty(bad_subs) ==1
        disp('Good news: All subjects have a compactness below 1.')
    else
        disp(['Number of subjects with compactness scores above 1:' num2str(size(bad_subs))]);
    end
    scores_withoutbadsubs = scores;
    scores_withoutbadsubs(bad_subs) = [];
    save([output_folder filesep output_name '_PPcompactness_scores.mat'],'input_cifti_list','scores','bad_subs','scores_withoutbadsubs')
end



disp('Done getting border length for all subjects')
end
