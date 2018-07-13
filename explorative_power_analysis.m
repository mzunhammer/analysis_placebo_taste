%% POWER ANALYSIS: HOW MANY PEOPLE DO WE NEED TO CAPTURE PLACEBO EFFECT?

clear
close all

load df.mat
% add permuted two-sample t-test
addpath('/Users/matthiaszunhammer/Documents/MATLAB/mult_comp_perm_t2')

%% Exclude excluded and outlier
excluded=dfw.subject_no(dfw.exclusion==1|dfw.aucrating_perc_pre<5)

dfl_c=dfl;
dfw_c=dfw;

dfl_c(ismember(dfl.subject_no,excluded),:)=[];
dfw_c(ismember(dfw.subject_no,excluded),:)=[];
dfw_c_taste=dfw_c(dfw_c.treat~='0',:);

%% 

sample_size=10:10:100;
repeats=10000;

AUC_diff_no_treatment=dfw_c.AUC_diff(dfw_c.treat=='0');
n1=length(AUC_diff_no_treatment);
AUC_diff_placebo=dfw_c.AUC_diff(dfw_c.treat~='0');
n2=length(AUC_diff_placebo);
j=0;
for n=sample_size
    j=j+1;
    for i=1:repeats
        iy1 = randsample(n1,n,true);
        iy2 = randsample(n2,n,true);
        y1=AUC_diff_no_treatment(iy1);
        y2=AUC_diff_placebo(iy2);
        [~,P(j,i),~,~] = ttest(y1,y2);
    end
end