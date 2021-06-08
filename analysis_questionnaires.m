function analysis_questionnaires(dfl_c,dfw_c, treatlabels, varargin)
treatcolors={[0,0,0],[0.6,0.6,0.6],[0,0.3,0.7],[0.7,0,0.3]};

%Select Variables for correlation analysis
dfw_c.CPT_HR_max_change_from_BL_mean=mean([dfw_c.CPT_HR_max_change_from_BL_pre,dfw_c.CPT_HR_max_change_from_BL_post],2);
dfw_c.aucrating_perc_mean=mean([dfw_c.aucrating_perc_pre,dfw_c.aucrating_perc_post],2);
vars={...
    'aucrating_perc_pre',...
    'aucrating_perc_post',...
    'AUC_diff',...
    'CPT_HR_mean_pre_pre',...
    'CPT_HR_mean_pre_post',...
    'CPT_HR_max_change_from_BL_pre',...
    'CPT_HR_max_change_from_BL_post',...
    df_questionnaire.Properties.VariableNames{3:end}};

vars_summary={...
    'aucrating_perc_pre',...
    'CPT_HR_mean_pre_pre',...
    'CPT_HR_max_change_from_BL_pre',...
    'POMS_Total_Mood_Disturbance',...
    'ADSk',...
    'STAI_G_X1',...
    'STAI_G_X2',...
    'PainSQ',...
    'PSQ20_Total',...
    'PSQI_Total',...
    'NEOFFI_Agreeableness',...
    'NEOFFI_Conscientiousness',...
    'NEOFFI_Extraversion',...        
    'NEOFFI_Neuroticism',...         
    'NEOFFI_Openness'};

%Correlation analysis
[R,P]=corr(dfw_c{:,vars},'rows','pairwise','type','Pearson');
xvalues = strrep(vars,'_',' ');
yvalues = strrep(vars,'_',' ');

%% Xorrelation Matrix for Questionnaires, main scores only

%Correlation analysis
[R,P]=corr(dfw_c{:,vars},'rows','pairwise','type','Pearson');
xvalues = strrep(vars,'_',' ');
yvalues = strrep(vars,'_',' ');

halfmatrix=tril(ones(size(R)),-1);
halfmatrix(halfmatrix==0) = NaN;
h = heatmap(xvalues,yvalues,R.*halfmatrix,'ColorMethod','None',...
    'Colormap',cbrewer('div', 'BrBG', 21, 'linear')); 
caxis([-0.2,0.2])


%% List top correlations
var_of_interest='CPT_HR_max_change_from_BL_pre';

namatrix=repmat(vars,size(R,1),1);
for i=1:size(namatrix,1)
  for j=1:size(namatrix,2)  
      namatrix(i,j)={[namatrix{i,j},' / ',vars{i}]};
  end
end

R_diag = R(find(tril(ones(size(R)),-1)));
P_diag = P(find(tril(ones(size(P)),-1)));
namatrix_diag=namatrix(find(tril(ones(size(namatrix)),-1)));

selection_index_diag=strfind(namatrix_diag,var_of_interest);
selection_index_diag=~cellfun(@isempty,selection_index_diag);

CorrelationResults_HR_max_pre=table(namatrix_diag(selection_index_diag),R_diag(selection_index_diag), P_diag(selection_index_diag),'VariableNames', {'Combi' 'r' 'p'})
[B,index]=sort(CorrelationResults_HR_max_pre.p)
CorrelationResults_HR_max_pre=CorrelationResults_HR_max_pre(index,:)


%% Follow-up: Robust regression excluding sub-study effects
dfw_c.z_CPT_HR_max_change_from_BL_pre=nanzscore(dfw_c.CPT_HR_max_change_from_BL_pre);
dfw_c.z_POMS_Depression=nanzscore(dfw_c.POMS_Depression);
dfw_c.z_POMS_Vigor=nanzscore(dfw_c.POMS_Vigor);


lm_HR_vs_POMS_depr=fitlm(dfw_c,'CPT_HR_max_change_from_BL_pre~study+POMS_Depression','RobustOpts','on')
z_lm_HR_vs_POMS_depr=fitlm(dfw_c,'z_CPT_HR_max_change_from_BL_pre~study+z_POMS_Depression','RobustOpts','on')

lm_HR_vs_POMS_vigor=fitlm(dfw_c,'CPT_HR_max_change_from_BL_pre~study+POMS_Vigor','RobustOpts','on')
z_lm_HR_vs_POMS_vigor=fitlm(dfw_c,'z_CPT_HR_max_change_from_BL_pre~study+z_POMS_Vigor','RobustOpts','on')

end