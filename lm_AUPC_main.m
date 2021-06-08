function lm_results=lm_AUPC_main(dfw_c,lm_base_formula)
%% GLM analysis %AUCP
% Staging %
%z-Score versions of continuous variables for analysis in standardized
%units

boot_reps=10000; %repetitions for bootci's
perm_reps=50000; %repetitions for permutation testing

% Null-hypothesis versions of Grouping variable "treat" 
dfw_c.placebo_treat=dfw_c.treat~='0'; % Placebo Treatment vs No Treatment Effect (Bitter & Sweet & Neutral Taste Groups Pooled)
dfw_c.taste_placebo_treat=mergecats(dfw_c.treat,{'2','3'},'2');% Flavour Treatment vs Neutral Flavour vs No Treatment Effect (Bitter & Sweet Groups Pooled)
dfw_c.taste_placebo_treat_ref_neutral=reordercats(dfw_c.taste_placebo_treat,{'1','0','2'});
% Grouping variable "treat" with  
dfw_c.treat_ref_no_treat=reordercats(dfw_c.treat,{'0','1','2','3'}); %change order of categories to set "no-treatment" as reference 
dfw_c.treat_ref_tasteless=reordercats(dfw_c.treat,{'1','0','2','3'}); %change order for contrasts to set "tasteless-treatment" as reference 
dfw_c.treat_ref_bitter=reordercats(dfw_c.treat,{'2','0','1','3'}); %change order for contrasts to set "tasteless-treatment" as reference 
%Export of for Analysis in R
%dfw_c_exp=dfw_c(:,{'aucrating_perc_post','aucrating_perc_pre','AUC_diff','study','treat','placebo_treat','taste_placebo_treat','TT_TU','maxtimers','maxtime_pre','maxtime_post','maxtime_diff'});
%writetable(dfw_c_exp,'/Users/matthiaszunhammer/Desktop/dfw_c.csv','Delimiter',';');

%% Determine outcome to be analyzed

%%%%%%%% Main Analysis%%%%%%%
% Flavoured Placebo Treatment MODEL (H1: bitter vs sweet vs neutral flavour effect vs no treatment)

% Main Model (no-treatment as reference)
function [coef,mdl]=AUPC_lm_main_ref_no_treat(df) % linear models are defined as in-line functions, with coefficients as outputs to allow for used in bootci, since tbat  function does only allow one argument
    mdl=fitlm(df,[lm_base_formula,'+treat_ref_no_treat'],'RobustOpts','on');
    coef=mdl.Coefficients.Estimate;
end
[~,AUPC_lm_main_ref_no_treat_result]=AUPC_lm_main_ref_no_treat(dfw_c); % for contrasts against "no placebo treatment"
AUPC_lm_main_ref_no_treat_CI=bootci(boot_reps,{@AUPC_lm_main_ref_no_treat,dfw_c},'alpha',0.05,'type','bca');
    
% Main Model (tasteless-placebo as reference)
function [coef,mdl]=AUPC_lm_main_ref_neutral(df)
    mdl=fitlm(df,[lm_base_formula,'+treat_ref_tasteless'],'RobustOpts','on');
    coef=mdl.Coefficients.Estimate;
end
[~,AUPC_lm_main_ref_tasteless_result]=AUPC_lm_main_ref_neutral(dfw_c); % for contrasts against "no placebo treatment"
AUPC_lm_main_ref_tasteless_CI=bootci(boot_reps,{@AUPC_lm_main_ref_neutral,dfw_c},'alpha',0.05,'type','bca');

% Main Model (bittr-placebo as reference)
function [coef,mdl]=AUPC_lm_main_ref_bitter(df)
    mdl=fitlm(df,[lm_base_formula,'+treat_ref_bitter'],'RobustOpts','on');
    coef=mdl.Coefficients.Estimate;
end
[~,AUPC_lm_main_ref_bitter_result]=AUPC_lm_main_ref_bitter(dfw_c); % for contrasts against "no placebo treatment"
AUPC_lm_main_ref_bitter_CI=bootci(boot_reps,{@AUPC_lm_main_ref_bitter,dfw_c},'alpha',0.05,'type','bca');

model_diagnostics(AUPC_lm_main_ref_no_treat_result) % note that diagnostics and F-tests do not depend on contrast coding and are therefore only required once
AUPC_lm_main_F_test=anova(AUPC_lm_main_ref_no_treat_result)

% Auxiliary Model, where bitter and sweet taste are pooled, to estimate "taste effect", tasteless-placebo as reference)
function [coef,mdl]=AUPC_lm_aux_taste_effect(df)
    mdl=fitlm(df,[lm_base_formula,'+taste_placebo_treat_ref_neutral'],'RobustOpts','on');
    coef=mdl.Coefficients.Estimate;
end
[~,AUPC_lm_aux_taste_effect_results]=AUPC_lm_aux_taste_effect(dfw_c); % for contrasts against "no placebo treatment"
AUPC_lm_aux_taste_effect_CI=bootci(boot_reps,{@AUPC_lm_aux_taste_effect,dfw_c},'alpha',0.05,'type','bca');

% Auxiliary Model, where bitter and sweet taste are pooled, to estimate "placebo effect", no treatment as reference)
function [coef,mdl]=AUPC_lm_aux_placebo_effect(df)
    mdl=fitlm(df,[lm_base_formula,+'+placebo_treat'],'RobustOpts','on');
    coef=mdl.Coefficients.Estimate;
end
[~,AUPC_lm_aux_placebo_effect_result]=AUPC_lm_aux_placebo_effect(dfw_c); % for contrasts against "no placebo treatment"
AUPC_lm_aux_placebo_effect_CI=bootci(boot_reps,{@AUPC_lm_aux_placebo_effect,dfw_c},'alpha',0.05,'type','bca');

% TO SAFEGUARD AGAINST FLAWED INFERENCE DUE TO HETEROSCEDASTICITY: PERMUTATION TEST
perms=perm_reps;
t_perm_ref_no_treat=NaN(7,perms);
t_perm_ref_tasteless=NaN(7,perms);
t_perm_ref_bitter=NaN(7,perms);
t_perm_ref_taste_effect=NaN(6,perms);
t_perm_ref_placebo_effect=NaN(5,perms);
F_perm=NaN(3,perms);
tic
f = waitbar(0,'%','Name','Permuting...');
i=0;
warningcount=0;
while i<perms
    waitbar(i/perms,f)

    lastwarn('', ''); %In some cases robustfit will not converge on iterations and throw a warning message. This occurs especially when using Matlab's Standard Bisquare Robust Weighting option
    dfw_c.treat_reordered_rand_ref_no_treat=shuffle(dfw_c.treat_ref_no_treat);
    dfw_c.treat_reordered_rand_ref_tasteless=shuffle(dfw_c.treat_ref_tasteless);
    dfw_c.treat_reordered_rand_ref_bitter=shuffle(dfw_c.treat_ref_bitter);
    dfw_c.treat_reordered_rand_taste_effect=shuffle(dfw_c.taste_placebo_treat_ref_neutral);
    dfw_c.treat_reordered_rand_placebo_effect=shuffle(dfw_c.placebo_treat);

    curr_mdl_no_treat=fitlm(dfw_c,[lm_base_formula,'+treat_reordered_rand_ref_no_treat']);
    curr_mdl_no_bitter=fitlm(dfw_c,[lm_base_formula,'+treat_reordered_rand_ref_tasteless']);
    curr_mdl_no_tasteless=fitlm(dfw_c,[lm_base_formula,'+treat_reordered_rand_ref_bitter']);
    curr_mdl_taste_effect=fitlm(dfw_c,[lm_base_formula,'+treat_reordered_rand_taste_effect']);
    curr_mdl_placebo_effect=fitlm(dfw_c,[lm_base_formula,'+placebo_treat']);

    [warnMsg, warnId] = lastwarn();
    if~isempty(warnId)
        warnMsg
        warningcount=warningcount+1
                continue;
    else
        i=i+1;
    end
    t_perm_ref_no_treat(:,i)=curr_mdl_no_treat.Coefficients.Estimate;
    t_perm_ref_tasteless(:,i)=curr_mdl_no_tasteless.Coefficients.Estimate;
    t_perm_ref_bitter(:,i)=curr_mdl_no_bitter.Coefficients.Estimate;
    t_perm_ref_taste_effect(:,i)=curr_mdl_taste_effect.Coefficients.Estimate;
    t_perm_ref_placebo_effect(:,i)=curr_mdl_placebo_effect.Coefficients.Estimate;
    curr_anova=anova(curr_mdl_no_treat);
    F_perm(:,i)=curr_anova.F(1:end-1);
end
toc
warningcount
 % Permuted p-values, see: ﻿doi:10.4172/2167-0870.1000145
pPerm_ref_no_treat=(sum(abs(t_perm_ref_no_treat)>repmat(abs(AUPC_lm_main_ref_no_treat_result.Coefficients.Estimate),[1,length(t_perm_ref_no_treat)]),2)+1)...
                    /(length(t_perm_ref_no_treat)+1);
pPerm_ref_tasteless=(sum(abs(t_perm_ref_tasteless)>repmat(abs(AUPC_lm_main_ref_tasteless_result.Coefficients.Estimate),[1,length(t_perm_ref_tasteless)]),2)+1)...
                    /(length(t_perm_ref_tasteless)+1);
pPerm_ref_bitter=(sum(abs(t_perm_ref_bitter)>repmat(abs(AUPC_lm_main_ref_bitter_result.Coefficients.Estimate),[1,length(t_perm_ref_bitter)]),2)+1)...
                    /(length(t_perm_ref_bitter)+1);
pPerm_taste_effect=(sum(abs(t_perm_ref_taste_effect)>repmat(abs(AUPC_lm_aux_taste_effect_results.Coefficients.Estimate),[1,length(t_perm_ref_taste_effect)]),2)+1)...
                    /(length(t_perm_ref_taste_effect)+1);
pPerm_placebo_effect=(sum(abs(t_perm_ref_placebo_effect)>repmat(abs(AUPC_lm_aux_placebo_effect_result.Coefficients.Estimate),[1,length(t_perm_ref_placebo_effect)]),2)+1)...
                    /(length(t_perm_ref_placebo_effect)+1);
p_ANOVA_perm=(sum(F_perm>repmat(AUPC_lm_main_F_test.F(1:end-1),[1,length(F_perm)]),2)+1)...
                    /(length(F_perm)+1);
%[AUPC_lm_full_ref_neutral.Coefficients.Estimate,AUPC_lm_full_ref_neutral.Coefficients.Estimate-AUPC_lm_full_ref_neutral.Coefficients.SE*1.96,AUPC_lm_full_ref_neutral.Coefficients.Estimate+AUPC_lm_full_ref_neutral.Coefficients.SE*1.96]
%[AUPC_lm_full_ref_neutral.Coefficients.Estimate,quantile(b,0.05)',quantile(b,0.95)']

%Add Permutation p-Value to ANOVA Results
AUPC_lm_main_F_test.pPerm=NaN(size(AUPC_lm_main_F_test,1),1); AUPC_lm_main_F_test.pPerm(3)=p_ANOVA_perm(3);

%Format Contrast Table
AUPC_lm_main_ref_no_treat_coef=AUPC_lm_main_ref_no_treat_result.Coefficients;
AUPC_lm_main_ref_tasteless_coef=AUPC_lm_main_ref_tasteless_result.Coefficients;
AUPC_lm_main_ref_bitter_coef=AUPC_lm_main_ref_bitter_result.Coefficients;
AUPC_lm_aux_taste_effect_coef=AUPC_lm_aux_taste_effect_results.Coefficients;
AUPC_lm_aux_placebo_effect_coef=AUPC_lm_aux_placebo_effect_result.Coefficients;

AUPC_lm_main_ref_no_treat_coef.CIboot=AUPC_lm_main_ref_no_treat_CI';
AUPC_lm_main_ref_tasteless_coef.CIboot=AUPC_lm_main_ref_tasteless_CI';
AUPC_lm_main_ref_bitter_coef.CIboot=AUPC_lm_main_ref_bitter_CI';
AUPC_lm_aux_taste_effect_coef.CIboot=AUPC_lm_aux_taste_effect_CI';
AUPC_lm_aux_placebo_effect_coef.CIboot=AUPC_lm_aux_placebo_effect_CI';

AUPC_lm_main_ref_no_treat_coef.pPerm=pPerm_ref_no_treat; %note that only group was permuted!!
AUPC_lm_main_ref_tasteless_coef.pPerm=pPerm_ref_tasteless; %note that only group was permuted!!
AUPC_lm_main_ref_bitter_coef.pPerm=pPerm_ref_bitter; %note that only group was permuted!!
AUPC_lm_aux_taste_effect_coef.pPerm=pPerm_taste_effect; %note that only group was permuted!!
AUPC_lm_aux_placebo_effect_coef.pPerm=pPerm_placebo_effect; %note that only group was permuted!!

contast_table=...
[AUPC_lm_main_ref_no_treat_coef(:,:)
AUPC_lm_main_ref_tasteless_coef(startsWith(AUPC_lm_main_ref_tasteless_coef.Properties.RowNames,'treat_ref_tasteless_2')|...
                                startsWith(AUPC_lm_main_ref_tasteless_coef.Properties.RowNames,'treat_ref_tasteless_3'),:)
AUPC_lm_main_ref_bitter_coef(startsWith(AUPC_lm_main_ref_bitter_coef.Properties.RowNames,'treat_ref_bitter_3'),:)
AUPC_lm_aux_taste_effect_coef(startsWith(AUPC_lm_aux_taste_effect_coef.Properties.RowNames,'taste_placebo_treat_ref_neutral_2'),:)
AUPC_lm_aux_placebo_effect_coef(startsWith(AUPC_lm_aux_placebo_effect_coef.Properties.RowNames,'placebo_treat_1'),:)];

% contast_table.Properties.RowNames=...
%      {
%      'Intercept (vs No Treat Only)';
%      'Baseline (Covariate)';
%      'Study 2 > Study 1';
%      'Study 3 > Study 1';
%      'Neutral Placebo > No Treatment';
%      'Bitter Placebo > No Treatment';
%      'Sweet Placebo > No Treatment';
%      'Bitter Placebo > Neutral Placebo';
%      'Sweet Placebo > Neutral Placebo';
%      'Sweet Placebo > Bitter Placebo';
%      'Flavoured Placebo > Neutral Placebo';
%      'All Placebo > No Treatment'};
 
lm_results.ANOVA=AUPC_lm_main_F_test;
lm_results.ANOVA.partial_eta_sq=lm_results.ANOVA.SumSq./(lm_results.ANOVA.SumSq+lm_results.ANOVA.SumSq('Error'));
lm_results.contrasts=contast_table;
lm_results.AUPC_lm_main_ref_no_treat_result=AUPC_lm_main_ref_no_treat_result;
lm_results.AUPC_lm_main_ref_tasteless_result=AUPC_lm_main_ref_tasteless_result;
lm_results.AUPC_lm_main_ref_bitter_result=AUPC_lm_main_ref_bitter_result;
lm_results.AUPC_lm_aux_taste_effect_results=AUPC_lm_aux_taste_effect_results;
lm_results.AUPC_lm_aux_placebo_effect_result=AUPC_lm_aux_placebo_effect_result;
lm_results.AUPC_lm_main_ref_no_treat_bootCI=AUPC_lm_main_ref_no_treat_CI;
lm_results.AUPC_lm_main_ref_tasteless_bootCI=AUPC_lm_main_ref_tasteless_CI;
lm_results.AUPC_lm_main_ref_bitter_bootCI=AUPC_lm_main_ref_bitter_CI;
lm_results.AUPC_lm_aux_taste_effect_bootCI=AUPC_lm_aux_taste_effect_CI;
lm_results.AUPC_lm_aux_placebo_effect_bootCI=AUPC_lm_aux_placebo_effect_CI;
lm_results.t_dist_perm_ref_no_treat=t_perm_ref_no_treat;
lm_results.t_dist_perm_ref_tasteless=t_perm_ref_tasteless;
lm_results.t_dist_perm_taste_effect=t_perm_ref_taste_effect;
lm_results.t_dist_perm_placebo_effect=t_perm_ref_placebo_effect;
lm_results.pPerm_ref_no_treat=pPerm_ref_no_treat;
lm_results.pPerm_ref_tasteless=pPerm_ref_tasteless;
lm_results.pPerm_taste_effect=pPerm_taste_effect;
lm_results.pPerm_placebo_effect=pPerm_placebo_effect;
lm_results.p_ANOVA_perm=p_ANOVA_perm;

end