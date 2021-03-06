function analysis_explore_associations(dfw_c,dfw_c_pla, varargin)
% Optional:
% 'explore_all': will explore correlations between all CPT variables (permuted testing, will take a while)

%% Exploring associations
if any(strcmp(varargin,'explore_all'))
    CPTvars={'aucrating_perc_pre','aucrating_perc_post','AUC_diff',...
             'maxtime_pre','maxtime_post','maxtime_diff',...
             'CPT_HR_mean_pre','CPT_HR_mean_post','CPT_HR_mean_diff',...
             'treat_expect_post','treat_efficacy_post',...
             'taste_intensity_post','taste_valence_post',...
             'sumUAW_post',...
             'arrival_time',...
             'body_weight_in_kg','alcoholic_drinks_per_week',...
             'syst_rr','diast_rr','body_temperature',...
             'lab_time_before_pre_treat_CPT','between_cpt_time','lab_time_before_post_treat_CPT'};
    corrtable=dfw_c(:,CPTvars);
    corrtable.male=dfw_c{:,'male'};
    %corrtable.placebo=double(~(dfw_c{:,'treat'}=='0'));
    corrtable.taste=double((dfw_c{:,'treat'}=='2')-(dfw_c{:,'treat'}=='1'));
    all_correlations(corrtable,'Pearson',10000)


    % Bayes factors for 
    % Correlation expectation vs taste intensity
    bayes_factor(r2fishersZ(.04),... % correlations have to be transformed to Fisher's Z before Bayes Factor Calcultation
        n2fishersZse(length(dfw_c_pla.taste_intensity_post)),...
        0,...
        [0,r2fishersZ(0.3),2]) % r=.3 corresponds to a medium effect (d=.5) according to cohen 1992
    % Bayes factors for 
    % Correlation expectation vs taste valence
    bayes_factor(r2fishersZ(.12),... % correlations have to be transformed to Fisher's Z before Bayes Factor Calcultation
        n2fishersZse(length(dfw_c_pla.taste_valence_post)),...
        0,...
        [0,r2fishersZ(0.3),2]) % r=.3 corresponds to a medium effect (d=.5) according to cohen 1992
end

%% GLM analysis associations %AUPC vs taste ratings
%One participant shows very extreme post-pre changes in HR
dfw_c_pla.z_aucrating_perc_post=nanzscore(dfw_c_pla.aucrating_perc_post); 
dfw_c_pla.z_aucrating_perc_pre=nanzscore(dfw_c_pla.aucrating_perc_pre);
dfw_c_pla.z_AUC_diff=nanzscore(dfw_c_pla.AUC_diff);
dfw_c_pla.z_TT_TU=nanzscore(dfw_c_pla.TT_TU);
% dfw_c_pla.z_CPT_HR_mean_pre=nanzscore(dfw_c_pla.CPT_HR_mean_pre);
% dfw_c_pla.z_CPT_HR_mean_post=nanzscore(dfw_c_pla.CPT_HR_mean_post);
% dfw_c_pla.z_CPT_HR_mean_diff=nanzscore(dfw_c_pla.CPT_HR_mean_post-dfw_c_pla.CPT_HR_mean_pre);

dfw_c_pla.z_maxtime_pre=nanzscore(dfw_c_pla.maxtime_pre); %no
dfw_c_pla.z_maxtime_post=nanzscore(dfw_c_pla.maxtime_post); %no
dfw_c_pla.z_treat_expect_post=nanzscore(dfw_c_pla.treat_expect_post); %no
dfw_c_pla.z_taste_intensity_post=nanzscore(dfw_c_pla.taste_intensity_post); %no
dfw_c_pla.z_taste_valence_post=nanzscore(dfw_c_pla.taste_valence_post); %a little little
dfw_c_pla.z_treat_efficacy_post=nanzscore(dfw_c_pla.treat_efficacy_post); %yes, indeed
dfw_c_pla.z_sumUAW_post=nanzscore(dfw_c_pla.sumUAW_post); %pretty sure


% Ratings only, excluding GROUP (treat)
AUPClm1=fitlm(dfw_c_pla,...
    'aucrating_perc_post~aucrating_perc_pre+treat_expect_post+taste_intensity_post+taste_valence_post',...
    'DummyVarCoding','effects','RobustOpts','on')
lm1_anova=anova(AUPClm1)
anova(AUPClm1,'summary')
(lm1_anova.SumSq)/(lm1_anova.SumSq+lm1_anova.SumSq('Error')) % partial eta squared

zAUPClm1=fitlm(dfw_c_pla,...
    'z_aucrating_perc_post~z_aucrating_perc_pre+z_treat_expect_post+z_taste_intensity_post+z_taste_valence_post',...
    'DummyVarCoding','effects','RobustOpts','on')

% Unstandardized
% AUPClm1=fitlm(dfw_c_pla,...
%     'aucrating_perc_post~treat+TT_TU+aucrating_perc_pre+treat_expect_post+taste_intensity_post+taste_valence_post',...
%     'DummyVarCoding','effects','RobustOpts','fair')
% anova(AUPClm1)
% anova(AUPClm1,'summary')

% Including GROUP (treat)
AUPClm2=fitlm(dfw_c_pla,...
    'aucrating_perc_post~treat+aucrating_perc_pre+treat_expect_post+taste_intensity_post+taste_valence_post',...
    'DummyVarCoding','effects','RobustOpts','on')
anova(AUPClm2)
anova(AUPClm2,'summary')

zAUPClm2=fitlm(dfw_c_pla,...
    'z_aucrating_perc_post~treat+z_aucrating_perc_pre+z_treat_expect_post+z_taste_intensity_post+z_taste_valence_post',...
    'DummyVarCoding','effects','RobustOpts','on')

plot(dfw_c_pla.z_aucrating_perc_post,AUPClm2.Residuals.Studentized,'.')


HRlm2=fitlm(dfw_c_pla,...
    'z_CPT_HR_mean_post~z_CPT_HR_mean_pre+z_treat_expect_post+z_taste_intensity_post+z_taste_valence_post',...
    'DummyVarCoding','effects')
anova(HRlm2)
anova(HRlm2,'summary')


cpt_scatter(dfw_c_pla.taste_intensity_post,...
            dfw_c_pla.AUC_diff,...
            dfw_c_pla.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions treatment taste intensity rating')
ylabel('%AUPC difference post-pre')

cpt_scatter(dfw_c_pla.taste_valence_post,...
            dfw_c_pla.AUC_diff,...
            dfw_c_pla.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions treatment taste valence rating')
ylabel('%AUPC difference post-pre')

cpt_scatter(dfw_c_pla.treat_efficacy_post,...
            dfw_c_pla.AUC_diff,...
            dfw_c_pla.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions treatment efficacy rating')
ylabel('%AUPC difference post-pre')


cpt_scatter(dfw_c_pla.sumUAW_post,...
            dfw_c_pla.AUC_diff,...
            dfw_c_pla.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions side-effects score')
ylabel('%AUPC difference post-pre')


cpt_scatter(dfw_c_pla.taste_intensity_post,...
            dfw_c_pla.treat_expect_post,...
            dfw_c_pla.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Taste intensity')
ylabel('Treatment expectations')

cpt_scatter(dfw_c_pla.taste_valence_post,...
            dfw_c_pla.treat_expect_post,...
            dfw_c_pla.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Taste valence')
ylabel('Treatment expectations')

end