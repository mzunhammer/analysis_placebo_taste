function analysis_descriptives(dfl_c,dfw_c, dfw_c_pla)

%% DESCRIPTIVE RESULTS (TABLES) %%%%%%%%%%%%%%%
%% Basic sample descriptives
n=length(dfw_c.treat);
n0=sum(dfw_c.treat=='0');
n1=sum(dfw_c.treat=='1');
n2=sum(dfw_c.treat=='2');
n3=sum(dfw_c.treat=='3');

n_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff));
n0_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff) & dfw_c.treat=='0');
n1_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff) & dfw_c.treat=='1');
n2_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff) & dfw_c.treat=='2');
n3_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff) & dfw_c.treat=='3');

demovars={'treat',...
          'age','male','height_in_cm','body_weight_in_kg','waiting_time'};
grpstats(dfw_c(:,demovars),'treat',{'mean','std'})
demovars={'healthy',demovars{2:end}};
grpstats(dfw_c(:,demovars),'healthy',{'mean','std'})

% Handedness
handed_treat0=countcats(dfw_c.handedness(dfw_c.treat=='0'));
handed_treat1=countcats(dfw_c.handedness(dfw_c.treat=='1'));
handed_treat2=countcats(dfw_c.handedness(dfw_c.treat=='2'));
handed_treat3=countcats(dfw_c.handedness(dfw_c.treat=='3'));
handed_all=countcats(dfw_c.handedness);

table(categories(dfw_c.handedness),handed_treat0/n0)
table(categories(dfw_c.handedness),handed_treat1/n1)
table(categories(dfw_c.handedness),handed_treat2/n2)
table(categories(dfw_c.handedness),handed_treat3/n3)
table(categories(dfw_c.handedness),handed_all/n)

%% Treatment descriptives / Treatment related beliefs
% CAVE I: "treat_expect_post" was obtained just BEFORE post-treatment CPT
% the other treat_ variables were obtained just AFTER post-treatment CPT
% CAVE II: "non-treatment" group was not asked these questions, as they
% obviously made no sense. Exclude "non-treatment" group to avoud wrong n
% and averages
treatvars={'treat',...
          'treat_expect_post','treat_efficacy_post','taste_intensity_post','taste_valence_post','sumUAW_post'};
grpstats(dfw_c_pla(:,treatvars),'treat',{'mean','std'})

[tbl,chi2,p]=crosstab(dfw_c_pla.sumUAW_post>0,dfw_c_pla.treat=='2');
% Exploratory: Plots corresponding to table values
for i=2:length(treatvars)
    figure
    [~,h_means]=groupplot(dfw_c_pla.treat,dfw_c_pla.(treatvars{i}));
    title(treatvars(i), 'Interpreter', 'none')
    ylabel(treatvars(i), 'Interpreter', 'none')
    xticklabels(treatlabels(2:end));
    xtickangle(45)
    hline(0,'color',[0 0 0])
    pbaspect([1 2 1])
    hgexport(gcf, ['~/Desktop/',treatvars{i},'.png'], hgexport('factorystyle'), 'Format', 'png'); 
    crop(['~/Desktop/',treatvars{i},'.png']);
end
treatvars={'healthy',treatvars{2:end}};
grpstats(dfw_c_pla(:,treatvars),'healthy',{'mean','std'})
end