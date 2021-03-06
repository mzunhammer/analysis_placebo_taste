function analysis_COMT(dfl_c,dfw_c,treatlabels, varargin)
% Flags for varargin:
% 'temp_correct': Will plot ambient temperature-corrected data where
% appropriate. !! Does not affect 'singlecurves' and 'averagecurves' and outcome: 'maxtime'!!
% 'exploratory': Will plot exploratory graphs
% 'singlecurves': Will create a plot of all CPT rating curves
% 'averagecurves': Will create a plot of averaged CPT rating curves
% 'prepost_figure1': Will create a plot of main results including pre-post
% spaghetti plot.

comtlabels={'AA','AG','GG','unknown'};
comtcolors={[0.8,0,0],[0.6,0.0,0.6],[0,0,0.8],[0.3,0.3,0.3]};
treatcolors={[0,0,0],[0.6,0.6,0.6],[0,0.3,0.7],[0.7,0,0.3]};


dfw_c.COMT_treat=dfw_c.COMT_genotype_pre.*dfw_c.treat;
comt_treat_colors=repmat(treatcolors,[1,4]);
comt_treat_labels= {'AA untreated','AA tasteless','AA bitter', 'AA sweet','AG untreated','AG tasteless','AG bitter','AG sweet','GG untreated','GG tasteless','GG bitter','GG sweet','unknown untreated','unknown tasteless','unknown bitter','unknown sweet'};


%% GLM correct %AUCP
dfw_c.z_aucrating_perc_pre=nanzscore(dfw_c.aucrating_perc_pre);
dfw_c.z_aucrating_perc_post=nanzscore(dfw_c.aucrating_perc_post);
dfw_c.z_AUC_diff=nanzscore(dfw_c.AUC_diff);
dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);
dfl_c.z_TT_TU=nanzscore(dfl_c.TT_TU);

AUPC_temp=fitlm(dfl_c,'aucrating_perc~z_TT_TU','RobustOpts','fair')

AUPC_pre_temp=fitlm(dfw_c,'aucrating_perc_pre~z_TT_TU','RobustOpts','fair')
AUPC_post_temp=fitlm(dfw_c,'aucrating_perc_post~z_TT_TU','RobustOpts','fair')
AUPC_diff_temp=fitlm(dfw_c,'AUC_diff~z_TT_TU','RobustOpts','fair')

dfl_c.aucrating_perc_temp_correct=AUPC_temp.Residuals.Raw+AUPC_temp.Coefficients.Estimate(1);

dfw_c.aucrating_perc_pre_temp_correct=AUPC_pre_temp.Residuals.Raw+AUPC_pre_temp.Coefficients.Estimate(1);
dfw_c.aucrating_perc_post_temp_correct=AUPC_post_temp.Residuals.Raw+AUPC_post_temp.Coefficients.Estimate(1);
dfw_c.aucrating_perc_diff_temp_correct=AUPC_diff_temp.Residuals.Raw+AUPC_diff_temp.Coefficients.Estimate(1);

%% GLM correct maxtime
maxtimers=dfw_c.subject_no(dfw_c.maxtime_pre>179);
dfl_c_aborters=dfl_c(~ismember(dfl_c.subject_no,maxtimers),:);
dfw_c_aborters=dfw_c(~ismember(dfw_c.subject_no,maxtimers),:);

dfl_c_aborters.z_maxtime=nanzscore(dfl_c_aborters.maxtime);
dfw_c_aborters.z_maxtime_pre=nanzscore(dfw_c_aborters.maxtime_pre);
dfw_c_aborters.z_maxtime_post=nanzscore(dfw_c_aborters.maxtime_post);
dfw_c_aborters.z_maxtime_diff=nanzscore(dfw_c_aborters.maxtime_diff);

dfw_c_aborters.z_TT_TU=nanzscore(dfw_c_aborters.TT_TU);
dfl_c_aborters.z_TT_TU=nanzscore(dfl_c_aborters.TT_TU);

maxtime_temp=fitlm(dfl_c_aborters,'maxtime~z_TT_TU','RobustOpts','fair')

maxtime_pre_temp=fitlm(dfw_c_aborters,'maxtime_pre~z_TT_TU','RobustOpts','fair')
maxtime_post_temp=fitlm(dfw_c_aborters,'maxtime_post~z_TT_TU','RobustOpts','fair')
maxtime_diff_temp=fitlm(dfw_c_aborters,'maxtime_diff~z_TT_TU','RobustOpts','fair')

dfl_c_aborters.maxtime_temp_correct=maxtime_temp.Residuals.Raw+maxtime_temp.Coefficients.Estimate(1);

dfw_c_aborters.maxtime_pre_temp_correct=maxtime_pre_temp.Residuals.Raw+maxtime_pre_temp.Coefficients.Estimate(1);
dfw_c_aborters.maxtime_post_temp_correct=maxtime_post_temp.Residuals.Raw+maxtime_post_temp.Coefficients.Estimate(1);
dfw_c_aborters.maxtime_diff_temp_correct=maxtime_diff_temp.Residuals.Raw+maxtime_diff_temp.Coefficients.Estimate(1);

%% Select if temperature correction is applied in graphs (excludes optional graphs)
if any(strcmp(varargin,'temp_correct'))
long_outcome=dfl_c.aucrating_perc_temp_correct;
wide_outcome=dfw_c.aucrating_perc_diff_temp_correct;
y_label='Change in area under the pain curve (%)* ± 95% CI';

long_maxtime=dfl_c_aborters.maxtime_temp_correct;
wide_maxtime=dfw_c_aborters.maxtime_diff_temp_correct;
maxtime_y_label='Change in CPT hand retention time* (s) ± 95% CI';
else
long_outcome=dfl_c.aucrating_perc;
wide_outcome=dfw_c.AUC_diff;
y_label='Change in area under the pain curve (%) ± 95% CI';

long_maxtime=dfl_c_aborters.maxtime;
wide_maxtime=dfw_c_aborters.maxtime_diff;
maxtime_y_label='Change in CPT hand retention time (s) ± 95% CI';
end

%% PLOT %AUPC change vs COMT polymorphisms
figure
[~,h_means]=groupplot(dfw_c.COMT_genotype_pre,dfw_c.aucrating_perc_diff_temp_correct,'group_color',comtcolors);
ylabel(y_label)
xticklabels(comtlabels);
hline(0,'color',[0 0 0])
%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/COMT_placebo.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/COMT_placebo.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/COMT_placebo.png');

%% PLOT %AUPC change vs COMT polymorphisms
figure
[~,h_means]=groupplot(dfw_c.COMT_treat,dfw_c.aucrating_perc_diff_temp_correct,'group_color',comt_treat_colors);
ylabel(y_label)
xticklabels(comt_treat_labels);
hline(0,'color',[0 0 0])
%set(gcf, 'Position', [0 0 960 540])
xtickangle(45)
hgexport(gcf, '../paper_placebo_taste/COMT_n_treat_placebo.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/COMT_n_treat_placebo.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/COMT_n_treat_placebo.png');


%% GLM analysis %AUCP
dfw_c.placebo_treat=dfw_c.treat~='0';
dfw_c.taste_placebo_treat=mergecats(dfw_c.treat,{'2','3'},'2');
dfw_c.taste_placebo_treat=reordercats(dfw_c.taste_placebo_treat,{'0','1','2'});
dfw_c.z_aucrating_perc_pre=nanzscore(dfw_c.aucrating_perc_pre);
dfw_c.z_aucrating_perc_post=nanzscore(dfw_c.aucrating_perc_post);
dfw_c.z_AUC_diff=nanzscore(dfw_c.AUC_diff);
dfw_c.z_TT_TU=nanzscore(dfw_c.TT_TU);

dfw_c.treat_reordered=reordercats(dfw_c.treat,{'0','1','2','3'}); %change order for contrasts

dfw_c_known=dfw_c(dfw_c.COMT_genotype_pre~='unknown',:)
dfw_c_known.COMT_genotype_pre=reordercats(dfw_c_known.COMT_genotype_pre,{'AG','AA','GG','unknown'});
% GLM analysis %AUCP - UNCORRECTED
AUPClm1=fitlm(dfw_c,'z_aucrating_perc_post~z_aucrating_perc_pre+treat_reordered','RobustOpts','fair')
anova(AUPClm1)
%anova(AUPClm1,'summary')
% GLM analysis %AUCP - STUDY CORRECTED
AUPClm1=fitlm(dfw_c,'z_aucrating_perc_post~z_aucrating_perc_pre+treat_reordered+study','RobustOpts','fair')
anova(AUPClm1)
%anova(AUPClm1,'summary')
figure, title('Residuals')
plot(dfw_c.z_aucrating_perc_post,AUPClm1.Residuals.Studentized,'.')
% GLM analysis %AUCP - TEMPERATURE
AUPClm1=fitlm(dfw_c,'z_aucrating_perc_post~z_aucrating_perc_pre+treat_reordered+z_TT_TU','RobustOpts','fair')
anova(AUPClm1)
%anova(AUPClm1,'summary')
figure, title('Residuals')
plot(dfw_c.z_aucrating_perc_post,AUPClm1.Residuals.Studentized,'.')

% GLM analysis %AUCP - TEMPERATURE + COMT
AUPClm1=fitlm(dfw_c,'z_aucrating_perc_post~z_aucrating_perc_pre+treat_reordered*COMT_genotype_pre+z_TT_TU','RobustOpts','fair')
anova(AUPClm1)
%anova(AUPClm1,'summary')
figure, title('Residuals')
plot(dfw_c.z_aucrating_perc_post,AUPClm1.Residuals.Studentized,'.')


AUPC_all_placebo=fitlm(dfw_c,'z_aucrating_perc_post~z_aucrating_perc_pre+placebo_treat+z_TT_TU','RobustOpts','fair')
anova(AUPC_all_placebo)

AUPC_taste_placebo=fitlm(dfw_c,'z_aucrating_perc_post~z_aucrating_perc_pre+taste_placebo_treat+z_TT_TU','RobustOpts','fair')
anova(AUPC_taste_placebo)
%% Figure Xa: plot maxtime pre versus post
if any(strcmp(varargin,'prepost_figure1'))
figure
subplot(1,2,1)
[~,h_means]=groupplot2(dfl_c_aborters.treat,dfl_c_aborters.prepost,long_maxtime);
title('CPT hand retention time',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('CPT hand retention time in seconds (pre/post treatment')
h=gca;
% text(h,0.15, 100, 'pre','FontSize',9,'HorizontalAlignment','left')
% text(h,0.75, 100, 'post','FontSize',9,'HorizontalAlignment','right')
% text(h,0.8, 100, 'pre','FontSize',9,'HorizontalAlignment','left')
% text(h,1.25, 100, 'post','FontSize',9,'HorizontalAlignment','right')
% text(h,1.25, 100, 'pre','FontSize',9,'HorizontalAlignment','left')
% text(h,1.7, 100, 'post','FontSize',9,'HorizontalAlignment','right')
% text(h,1.8, 100, 'pre','FontSize',9,'HorizontalAlignment','left')
% text(h,2.2, 100, 'post','FontSize',9,'HorizontalAlignment','right')

xticklabels(treatlabels);
xtickangle(45)
pbaspect([1 2 1])

% Figure 1b: plot maxtime change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])

[~,h_means]=groupplot(dfw_c_aborters.treat,wide_maxtime);
title('Change in CPT hand retention time',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('CPT hand retention time in seconds ± 95% CI')
xticklabels(treatlabels);
xtickangle(45)
hline(0,'color',[0 0 0])
pbaspect([1 2 1])

unicodeminus = sprintf(strrep('\u2212', '\u', '\x'));
annotation('arrow',...
           [0.48 0.52],[.5 .5],...
           'HeadStyle','plain',...
           'Units','Normalized');
annotation('textbox',...
           [0.48, 0.58, .04, .04],...
           'String',['post ' unicodeminus ' pre'],...
           'Units','Normalized',...
           'FontWeight','bold',...
           'HorizontalAlignment','center',...
           'LineStyle','none');

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figure_maxtime.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure_maxtime.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure_maxtime.png');
end
%% Figure maxtime short version
figure
[~,h_means]=groupplot(dfw_c_aborters.treat,wide_maxtime,'group_color',treatcolors);

%title('Change in CPT hand retention time',...
%      'Units','Normalized',...
%      'Position',[0.5,1.02])
ylabel(maxtime_y_label)
xticklabels(treatlabels);
hline(0,'color',[0 0 0])

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figure_maxtimev2.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure_maxtimev2.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure_maxtimev2.png');

%% GLM analysis maxtime
% Mixed model version (too complicated to communicate, equivalent results):
% AUPCmm1=fitlme(dfl_c,'aucrating_perc~prepost*treat+(1|subject_no)',...
%                'CheckHessian',1,...
%                'DummyVarCoding','effects')
dfw_c_aborters.treat_reordered=reordercats(dfw_c_aborters.treat,{'2','1','3','0'});

maxtime_lm1=fitlm(dfw_c_aborters,'maxtime_post~z_maxtime_pre+treat_reordered+z_TT_TU','RobustOpts','fair')
maxtime_lm1
anova(maxtime_lm1)
anova(maxtime_lm1,'summary')
figure, title('Residuals')
plot(dfw_c_aborters.z_maxtime_post,maxtime_lm1.Residuals.Studentized,'.')

dfw_c_aborters.placebo_treat=dfw_c_aborters.treat~='0';
maxtimers_all_placebo=fitlm(dfw_c_aborters,'z_maxtime_post~z_maxtime_pre+placebo_treat+z_TT_TU','RobustOpts','fair')
anova(maxtimers_all_placebo)
maxtimers_all_placebo

dfw_c_aborters.taste_placebo_treat=mergecats(dfw_c_aborters.treat,{'2','3'},'2');
dfw_c_aborters.taste_placebo_treat=reordercats(dfw_c_aborters.taste_placebo_treat,{'1','2','0'});
maxtimers_placebo=fitlm(dfw_c_aborters,'z_maxtime_post~z_maxtime_pre+taste_placebo_treat+z_TT_TU','RobustOpts','fair')
anova(maxtimers_placebo)

%% Number needed to treat to achieve a AUPC reduction by 30% from baseline
%percentual_placebo_effect=dfw_c.AUC_diff./dfw_c.aucrating_perc_pre;
percentual_placebo_effect=dfw_c.aucrating_perc_diff_temp_correct./dfw_c.aucrating_perc_pre_temp_correct;

responders30=percentual_placebo_effect<(-.30); %30% reduction in AUPC from baseline

ratio_30_percent_reduction_no_treatment = sum(responders30(dfw_c.treat=='0'))/sum(dfw_c.treat=='0');
ratio_30_percent_reduction_tasteless_placebo = sum(responders30(dfw_c.treat=='1'))/sum(dfw_c.treat=='1');
ratio_30_percent_reduction_bitter_placebo = sum(responders30(dfw_c.treat=='2'))/sum(dfw_c.treat=='2');
ratio_30_percent_reduction_sweet_placebo = sum(responders30(dfw_c.treat=='3'))/sum(dfw_c.treat=='3');
ratio_30_percent_reduction_taste_placebos = sum(responders30(dfw_c.treat=='2'|dfw_c.treat=='3'))/sum(dfw_c.treat=='2'|dfw_c.treat=='3');

ARR_placebo=1/(ratio_30_percent_reduction_taste_placebos-ratio_30_percent_reduction_no_treatment)
ARR_taste=1/(ratio_30_percent_reduction_taste_placebos-ratio_30_percent_reduction_tasteless_placebo)
ARR_taste_vs_no_treat=1/(ratio_30_percent_reduction_taste_placebos-ratio_30_percent_reduction_no_treatment)

end