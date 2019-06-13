%% Clean workspace, load packets
clear
close all

load df.mat
% add permuted two-sample t-test
addpath('/Users/matthiaszunhammer/Documents/MATLAB/mult_comp_perm_t2')
addpath('/Users/matthiaszunhammer/Documents/MATLAB/subaxis')
addpath('/Users/matthiaszunhammer/Documents/MATLAB/crop')
addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/linstats'))

addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/boundedline'))

treatlabels={'No treatment','Tasteless placebo','Bitter placebo','Sweet placebo'};
study_select={'1','2','3'};

%% Select substudy
dfl=dfl(ismember(dfl.study,study_select),:);
dfw=dfw(ismember(dfw.study,study_select),:);
%% Exclude excluded and outlier
dfl_c=apply_exclusion_criteria(dfl);
dfw_c=apply_exclusion_criteria(dfw);
%% Create sub-dfs limited to placebo-conditions
dfl_c_pla=dfl_c(dfl_c.treat~='0',:);
dfl_c_pla.treat = removecats(dfl_c_pla.treat);
dfw_c_pla=dfw_c(dfw_c.treat~='0',:);
dfw_c_pla.treat = removecats(dfw_c_pla.treat);

%% Actual analysis functions
% analysis_basic_exploration(dfw_c) %lots of histograms
analysis_descriptives(dfl_c,dfw_c, dfw_c_pla, treatlabels)
analysis_explore_temp_effects_CPT(dfw_c);
analysis_intervention_checks(dfw_c,dfw_c_pla);
analysis_side_effects(dfw_c);
% Main analyses
analysis_CPT(dfl_c,dfw_c,treatlabels,'temp_correct');
analysis_explore_associations(dfw_c,dfw_c_pla) % to be revisited
analysis_HR(dfl_c,dfw_c,treatlabels);
% analysis_BP(dfw_c,dfl_c) not yet completed

% For pairwise testing of group differences:
% Bootstrapped t-tests (uncorrected for multiple
% comparisons), graphs, Bayes Factors 

% analysis_pairwise_pla_vs_control_w_BL(dfw_c)
% analysis_pairwise_taste_vs_notaste_w_BL(dfw_c_pla)
% analysis_pairwise_taste_vs_notaste_no_BL(dfw_c_pla)
