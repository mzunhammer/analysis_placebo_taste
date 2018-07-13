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

%% Exclude excluded and outlier
excluded=dfw.subject_no(dfw.exclusion==1|dfw.aucrating_perc_pre<5);

dfl.lab_time_before_pre_treat_CPT=(dfl.time_pre_treat_CPT-dfl.arrival_time)*24*60;
dfl.lab_time_before_post_treat_CPT=(dfl.time_post_treat_CPT-dfl.arrival_time)*24*60;
dfl.waiting_time=(dfl.time_post_treat_CPT-dfl.time_drug_administration)*24*60;
dfl.between_cpt_time=(dfl.time_post_treat_CPT-dfl.time_pre_treat_CPT)*24*60;

dfl.lab_time_since_arrival(dfl.prepost=="1")=dfl.lab_time_before_pre_treat_CPT(dfl.prepost=="1");
dfl.lab_time_since_arrival(dfl.prepost=="2")=dfl.lab_time_before_post_treat_CPT(dfl.prepost=="2");

dfl_c=dfl;
dfw_c=dfw;

dfl_c(ismember(dfl.subject_no,excluded),:)=[];
dfl_c_taste=dfl_c(dfl_c.treat~='0',:);
dfl_c_taste.treat = removecats(dfl_c_taste.treat);

dfw_c(ismember(dfw.subject_no,excluded),:)=[];
dfw_c_taste=dfw_c(dfw_c.treat~='0',:);
dfw_c_taste.treat = removecats(dfw_c_taste.treat);

df_ultra_w=[dfl_c,array2table([dfl_c.rating180_full{:}]')];
rating180vars=strsplit(sprintf('Var%d\n',(1:180)'));
df_ultra_l=stack(df_ultra_w,...
                 rating180vars(~cellfun(@isempty,rating180vars)),...
                 'NewDataVariableName','rating_per_s',...
                 'IndexVariableName','crf_second');

%% Explore all data (CAVE! MANY, MANY FIGURES!)

% for i=1:width(dfw_c)
%     figure
%     if isnumeric(dfw_c{:,i})
%     %histogram(dfw_c{:,i},round(height(dfw_c)/5))
%     elseif iscategorical(dfw_c{:,i})
%     histogram(dfw_c{:,i})
%     end
%     title(dfw_c.Properties.VariableNames(i))
% end

%% DESCRIPTIVE RESULTS (TABLES) %%%%%%%%%%%%%%%
%% Basic sample descriptives
n=length(dfw_c.treat);
n0=sum(dfw_c.treat=='0');
n1=sum(dfw_c.treat=='1');
n2=sum(dfw_c.treat=='2');

n_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff));
n0_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff) & dfw_c.treat=='0');
n1_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff) & dfw_c.treat=='1');
n2_HR=sum(~isnan(dfw_c.CPT_HR_mean_diff) & dfw_c.treat=='2');

demovars={'treat',...
          'age','male','height_in_cm','body_weight_in_kg','waiting_time'};
grpstats(dfw_c(:,demovars),'treat',{'mean','std'})
demovars={'healthy',demovars{2:end}};
grpstats(dfw_c(:,demovars),'healthy',{'mean','std'})

% Handedness
handed_treat0=countcats(dfw_c.handedness(dfw_c.treat=='0'));
handed_treat1=countcats(dfw_c.handedness(dfw_c.treat=='1'));
handed_treat2=countcats(dfw_c.handedness(dfw_c.treat=='2'));
handed_all=countcats(dfw_c.handedness);

table(categories(dfw_c.handedness),handed_treat0/n0)
table(categories(dfw_c.handedness),handed_treat1/n1)
table(categories(dfw_c.handedness),handed_treat2/n2)
table(categories(dfw_c.handedness),handed_all/n)

%% Treatment descriptives / Treatment related beliefs
% CAVE I: "treat_expect_post" was obtained just BEFORE post-treatment CPT
% the other treat_ variables were obtained just AFTER post-treatment CPT
% CAVE II: "non-treatment" group was not asked these questions, as they
% obviously made no sense. Exclude "non-treatment" group to avoud wrong n
% and averages
treatvars={'treat',...
          'treat_expect_post','treat_efficacy_post','taste_intensity_post','taste_valence_post','sumUAW_post'};
grpstats(dfw_c_taste(:,treatvars),'treat',{'mean','std'})

[tbl,chi2,p]=crosstab(dfw_c_taste.sumUAW_post>0,dfw_c_taste.treat=='2')
% Exploratory: Plots corresponding to table values
% for i=2:length(treatvars)
%     figure
%     [~,h_means]=groupplot(dfw_c_taste.treat,dfw_c_taste.(treatvars{i}));
%     title(treatvars(i), 'Interpreter', 'none')
%     ylabel(treatvars(i), 'Interpreter', 'none')
%     xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
%     xtickangle(45)
%     hline(0,'color',[0 0 0])
%     pbaspect([1 2 1])
%     hgexport(gcf, ['~/Desktop/',treatvars{i},'.png'], hgexport('factorystyle'), 'Format', 'png'); 
%     crop(['~/Desktop/',treatvars{i},'.png']);
% end
treatvars={'healthy',treatvars{2:end}};
grpstats(dfw_c_taste(:,treatvars),'healthy',{'mean','std'})

%% Treatment CPT-related experimental timing
CPT_timing_vars={'treat',...
          'lab_time_before_pre_treat_CPT','lab_time_before_post_treat_CPT',...
          'waiting_time','between_cpt_time'};
grpstats(dfw_c(:,CPT_timing_vars),'treat',{'mean','std'})
%Exploratory: Plots for each table value:
% for i=2:length(CPT_timing_vars)
%     figure
%     [~,h_means]=groupplot(dfw_c.treat,dfw_c.(CPT_timing_vars{i}));
%     title(CPT_timing_vars(i), 'Interpreter', 'none')
%     ylabel(CPT_timing_vars(i), 'Interpreter', 'none')
%     xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
%     xtickangle(45)
%     hline(0,'color',[0 0 0])
%     pbaspect([1 2 1])
%     hgexport(gcf, ['~/Desktop/',CPT_timing_vars{i},'.png'], hgexport('factorystyle'), 'Format', 'png'); 
%     crop(['~/Desktop/',CPT_timing_vars{i},'.png']);
% end
%% Basic CPT descriptives
CPTvars={'treat',...
          'aucrating_perc_pre','aucrating_perc_post','AUC_diff',...
          'maxtime_pre','maxtime_post','maxtime_diff',...
          'maxtimers_pre','maxtimers_post',...
          'CPT_HR_mean_pre','CPT_HR_mean_post','CPT_HR_mean_diff',...
          'DIA_after_CPT_pre','DIA_after_CPT_post',...
          'SYS_after_CPT_pre','SYS_after_CPT_post',...
          };
grpstats(dfw_c(:,CPTvars),'treat',{'mean','std'})

% For exploratory purposes and group meeting presentation
% for i=2:length(CPTvars)
%     figure
%     [~,h_means]=groupplot(dfw_c.treat,dfw_c.(CPTvars{i}));
%     title(CPTvars(i), 'Interpreter', 'none')
%     ylabel(CPTvars(i), 'Interpreter', 'none')
%     xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
%     xtickangle(45)
%     hline(0,'color',[0 0 0])
%     pbaspect([1 2 1])
%     hgexport(gcf, ['~/Desktop/',CPTvars{i},'.png'], hgexport('factorystyle'), 'Format', 'png'); 
%     crop(['~/Desktop/',CPTvars{i},'.png']);
% end

CPTvars={'healthy',CPTvars{2:end}};
grpstats(dfw_c(:,CPTvars),'healthy',{'mean','std'})

%% DESCRIPTIVE RESULTS (FIGURES) %%%%%%%%%%%%%%%
%% SUPPLEMENT 1a: plot FULL pain rating curves
h_means=cpt_timeplot2(dfl_c.prepost,dfl_c.treat,dfl_c.rating180_full,50);
hs = findall(gcf,'Type','axes');
xticks(hs(4:6),[])
yticks(hs([1,2,4,5]),[])
title(hs(6),{'No treatment'});
title(hs(5),{'Tasteless placebo'});
title(hs(4),{'Bitter placebo'});
ylabel(hs(3),'VAS pain rating');
ylabel(hs(6),'VAS pain rating');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
text(hs(3),-0.5, 0.5, 'post','Units','normalized','FontWeight','bold','FontSize',11)
text(hs(6),-0.5, 0.5, 'pre','Units','normalized','FontWeight','bold','FontSize',11)

hgexport(gcf, '../paper_placebo_taste/figure1Sa.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure1Sa.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure1Sa.png');

%% SUPPLEMENT 1b: plot MEAN pain rating curves
h_means=cpt_timeplot_means(dfl_c.treat,dfl_c.prepost,dfl_c.rating180_full,dfl_c.maxtime,[0,100],50);
hs = findall(gcf,'Type','axes');
title(hs(3),{'No treatment'});
title(hs(2),{'Tasteless placebo'});
title(hs(1),{'Bitter placebo'});
yticks(hs([1,2]),[])
ylabel(hs(3),'VAS pain rating ± 95% CI');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
text(hs(3),0.85, 0.85, 'pre','Units','normalized','FontSize',11)
text(hs(3),0.85, 0.55, 'post','Units','normalized','FontSize',11)
text(hs(2),0.85, 0.85, 'pre','Units','normalized','FontSize',11)
text(hs(2),0.85, 0.55, 'post','Units','normalized','FontSize',11)
text(hs(1),0.85, 0.85, 'pre','Units','normalized','FontSize',11)
text(hs(1),0.85, 0.55, 'post','Units','normalized','FontSize',11)

hgexport(gcf, '../paper_placebo_taste/figure1Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure1Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure1Sb.png');

%% Figure 1a: plot %AUCP pre versus post
subplot(1,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.aucrating_perc);
title('Area under the pain curve',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('% area under the pain curve ± 95% CI')
h=gca;
text(h,0.3125, 100, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,0.6875, 100, 'post','FontSize',9,'HorizontalAlignment','right')
text(h,0.8125, 100, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,1.1875, 100, 'post','FontSize',9,'HorizontalAlignment','right')
text(h,1.3175, 100, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,1.6875, 100, 'post','FontSize',9,'HorizontalAlignment','right')

xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
pbaspect([1 2 1])

% Figure 1b: plot %AUCP change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])

[~,h_means]=groupplot(dfw_c.treat,dfw_c.AUC_diff);
title('Change in area under the pain curve',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('% area under the pain curve ± 95% CI')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
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
hgexport(gcf, '../paper_placebo_taste/figure1.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure1.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure1.png');

%% GLM analysis %AUCP
% Mixed model version (too complicated to communicate, equivalent results):
% AUPCmm1=fitlme(dfl_c,'aucrating_perc~prepost*treat+(1|subject_no)',...
%                'CheckHessian',1,...
%                'DummyVarCoding','effects')
dfw_c.z_aucrating_perc_pre=nanzscore(dfw_c.aucrating_perc_pre);
dfw_c.z_aucrating_perc_post=nanzscore(dfw_c.aucrating_perc_post);
dfw_c.z_=nanzscore(dfw_c.aucrating_perc_post);
dfw_c.z_=nanzscore(dfw_c.aucrating_perc_post);
dfw_c.z_=nanzscore(dfw_c.aucrating_perc_post);

AUPClm1=fitlm(dfw_c,'z_aucrating_perc_post~z_aucrating_perc_pre+treat','DummyVarCoding','effects')
anova(AUPClm1)
anova(AUPClm1,'summary')
%% SUPPLEMENT 2a: plot FULL HR curves
h_means=cpt_timeplot2(dfl_c.prepost,dfl_c.treat,dfl_c.CPT_HR,80);
hs = findall(gcf,'Type','axes');
xticks(hs(4:6),[])
yticks(hs([1,2,4,5]),[])
title(hs(6),{'No treatment'});
title(hs(5),{'Tasteless placebo'});
title(hs(4),{'Bitter placebo'});
ylabel(hs(3),'Heart rate (bpm)');
ylabel(hs(6),'Heart rate (bpm)');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
text(hs(3),-0.5, 0.5, 'post','Units','normalized','FontWeight','bold','FontSize',11)
text(hs(6),-0.5, 0.5, 'pre','Units','normalized','FontWeight','bold','FontSize',11)
hgexport(gcf, '../paper_placebo_taste/figure2Sa.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2Sa.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2Sa.png');

%% SUPPLEMENT 2b: plot MEAN HR curves
h_means=cpt_timeplot_means(dfl_c.treat,dfl_c.prepost,dfl_c.CPT_HR,dfl_c.maxtime,[60,100],80);
hs = findall(gcf,'Type','axes');
title(hs(3),{'No treatment'});
title(hs(2),{'Tasteless placebo'});
title(hs(1),{'Bitter placebo'});
yticks(hs([1,2]),[])
ylabel(hs(3),'Mean heart rate (bpm) ± 95% CI');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
text(hs(3),0.85, 0.45, 'pre','Units','normalized','FontSize',11)
text(hs(3),0.85, 0.15, 'post','Units','normalized','FontSize',11)
text(hs(2),0.85, 0.45, 'pre','Units','normalized','FontSize',11)
text(hs(2),0.85, 0.15, 'post','Units','normalized','FontSize',11)
text(hs(1),0.85, 0.45, 'pre','Units','normalized','FontSize',11)
text(hs(1),0.85, 0.15, 'post','Units','normalized','FontSize',11)
hgexport(gcf, '../paper_placebo_taste/figure2Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2Sb.png');

%% Figure 2a: plot HR pre versus post
subplot(1,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.CPT_HR_mean);
title('Mean heart rate',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
h=gca;
text(h,0.3125, 120, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,0.6875, 120, 'post','FontSize',9,'HorizontalAlignment','right')
text(h,0.8125, 120, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,1.1875, 120, 'post','FontSize',9,'HorizontalAlignment','right')
text(h,1.3175, 120, 'pre','FontSize',9,'HorizontalAlignment','left')
text(h,1.6875, 120, 'post','FontSize',9,'HorizontalAlignment','right')
ylabel('Mean heart rate (bpm) ± 95% CI')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
pbaspect([1 2 1])

% Figure 2b: plot HR change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])

[~,h_means]=groupplot(dfw_c.treat,dfw_c.CPT_HR_mean_diff);
title('Change in mean heart rate',...
      'Units','Normalized',...
      'Position',[0.5,1.02])
ylabel('Mean heart rate (bpm) ± 95% CI')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
hline(0,'color',[0 0 0])
pbaspect([1 2 1])

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
       
hgexport(gcf, '../paper_placebo_taste/figure2.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2.png');

%% GLM analysis mean HR
% Mixed model version (too complicated to communicate, equivalent results):
% HRmm1=fitlme(dfl_c,'CPT_HR_mean~prepost*treat+(1|subject_no)',...
%                'CheckHessian',1,...
%                'DummyVarCoding','effects')
dfw_c.z_CPT_HR_mean_pre=nanzscore(dfw_c.CPT_HR_mean_pre);
dfw_c.z_CPT_HR_mean_post=nanzscore(dfw_c.CPT_HR_mean_post);
dfw_c.z_lab_time_before_pre_treat_CPT=nanzscore(dfw_c.lab_time_before_pre_treat_CPT);

HRlm1=fitlm(dfw_c,'z_CPT_HR_mean_post~z_CPT_HR_mean_pre+treat',...
            'DummyVarCoding','effects')
anova(HRlm1)
anova(HRlm1,'summary')
plot(predict(HRlm1),HRlm1.Residuals.Studentized,'.')

HRlm2=fitlm(dfw_c,'z_CPT_HR_mean_post~z_CPT_HR_mean_pre+z_lab_time_before_pre_treat_CPT+treat',...
            'DummyVarCoding','effects')
anova(HRlm2)
anova(HRlm2,'summary')
plot(predict(HRlm2),HRlm1.Residuals.Studentized,'.')

%% Figure S4a: plot BP pre versus post
% Figure S4a: plot BP SYS pre and post
subplot(2,2,1)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.SYS_after_CPT);
title('Mean systolic BP, pre vs post')
ylabel('Mean systolic BP (bpm) ± 95% CI')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
% Figure S4b: plot BP SYS difference: post-pre
subplot(2,2,2)
pbaspect([2 1 1])
[~,h_means]=groupplot(dfw_c.treat,dfw_c.SYS_after_CPT_post-dfw_c.SYS_after_CPT_pre);
title(['Mean systolic BP, post ' unicodeminus ' pre'])
ylabel('Change systolic BP (bpm) ± 95% CI (post-pre)')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
hline(0,'color',[0 0 0])
% Figure S4c: plot BP DIA pre and post
subplot(2,2,3)
[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.DIA_after_CPT);
title('Mean diastolic BP, pre vs post')
ylabel('Mean diastolic BP (bpm) ± 95% CI')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
% Figure S4d: plot BP DIA difference: post-pre
subplot(2,2,4)
[~,h_means]=groupplot(dfw_c.treat,dfw_c.DIA_after_CPT_post-dfw_c.DIA_after_CPT_pre);
title(['Mean diastolic BP, post ' unicodeminus ' pre']);

ylabel('Change diastolic BP (bpm) ± 95% CI (post-pre)')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
hline(0,'color',[0 0 0])
set(gcf, 'Position', [0 0 960 960])
hgexport(gcf, '../paper_placebo_taste/figureS4.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figureS4.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figureS4.png');

%% GLM analysis mean blood pressure
% No effect whatsoever
dfw_c.z_DIA_after_CPT_pre=nanzscore(dfw_c.DIA_after_CPT_pre);
dfw_c.z_DIA_after_CPT_post=nanzscore(dfw_c.DIA_after_CPT_post);
dfw_c.z_SYS_after_CPT_pre=nanzscore(dfw_c.SYS_after_CPT_pre);
dfw_c.z_SYS_after_CPT_post=nanzscore(dfw_c.SYS_after_CPT_post);

dfw_c.z_DIA_change_CPT_pre=nanzscore(dfw_c.DIA_after_CPT_pre-dfw_c.DIA_before_CPT_pre);
dfw_c.z_DIA_change_CPT_post=nanzscore(dfw_c.DIA_after_CPT_post-dfw_c.DIA_before_CPT_post);
dfw_c.z_SYS_change_CPT_pre=nanzscore(dfw_c.SYS_after_CPT_pre-dfw_c.SYS_before_CPT_pre);
dfw_c.z_SYS_change_CPT_post=nanzscore(dfw_c.SYS_after_CPT_post-dfw_c.SYS_before_CPT_post);


DIAlm1=fitlm(dfw_c,'z_DIA_after_CPT_post~z_DIA_after_CPT_pre+treat',...
            'DummyVarCoding','effects')
anova(DIAlm1)
anova(DIAlm1,'summary')
plot(predict(DIAlm1),DIAlm1.Residuals.Studentized,'.')

SYSlm1=fitlm(dfw_c,'z_SYS_after_CPT_post~z_SYS_after_CPT_pre+treat',...
            'DummyVarCoding','effects')
anova(SYSlm1)
anova(SYSlm1,'summary')
plot(predict(SYSlm1),SYSlm1.Residuals.Studentized,'.')

%% Pairwise t-Tests for PLACEBO VS CONTROL measures with baseline differences
testvars={'AUC_diff','maxtime_diff','CPT_HR_mean_diff'};
forSD1={'aucrating_perc_pre','maxtime_pre','CPT_HR_mean_pre'};
forSD2={'aucrating_perc_post','maxtime_post','CPT_HR_mean_post'};
% Note: for valid Cohen's d, SD's have to be calcualted from SD of original
% measurements, not SD of difference between pre- and post- treatment.
for i=1%:length(testvars)
    disp(['##### Ttest and permuted ttest for: ',testvars{i},'#####']);
    x=dfw_c{dfw_c.treat=='0',testvars(i)};
    y=dfw_c{dfw_c.treat~='0',testvars(i)};
    x=x(~isnan(x));
    y=y(~isnan(y));

    x_SD=dfw_c{dfw_c.treat=='0',forSD1(i)};
    y_SD=dfw_c{dfw_c.treat~='0',forSD2(i)};
    %[h,p,ci,stats] = ttest2(x,y) %classic t-test
    x_CI=bootci(10000,{@nanmean,x},'type','cper');
    y_CI=bootci(10000,{@nanmean,y},'type','cper');

    %Cohen's d_s, according to Lakens 2013 (Formula 1)
    n1=length(x);
    n2=length(y);
    df1=n1-1;
    df2=n2-1;
    sd_pooled=(nanstd(x_SD)+nanstd(y_SD))./2;
    effect=mean(x)-mean(y);
    se_effect=sqrt((std(x)^2)./n1+(std(y)^2)./n2);
    d=(effect)/sd_pooled;
    var_d=(n1+n2)./(n1.*n2)+(d.^2)./(2.*(df1+df2));
    se_d= sqrt(var_d);

    sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(x),x_CI)
    sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(y),y_CI)
    sprintf([testvars{i},': Cohen''s d: %f, SD-pooled: %f'],d,sd_pooled)

    [pval, t_orig, crit_t, est_alpha, ~]=mult_comp_perm_t2(x,y,10000)
    bayes_factor(abs(d),se_d,0,[0,0.5,2])
    bayes_factor(abs(d),se_d,0,[1.00,0.5,2]) % Bayes Factor for experimental placebo analgesia based on Vase et al. 2009
end


%% Pairwise t-Tests for Taste VS No-Taste measures with baseline differences
testvars={'AUC_diff','maxtime_diff','CPT_HR_mean_diff'};
forSD1={'aucrating_perc_pre','maxtime_pre','CPT_HR_mean_pre'};
forSD2={'aucrating_perc_post','maxtime_post','CPT_HR_mean_post'};
% Note: for valid Cohen's d, SD's have to be calcualted from SD of original
% measurements, not SD of difference between pre- and post- treatment.
for i=1:length(testvars)
    disp(['##### Ttest and permuted ttest for: ',testvars{i},'#####']);
    x=dfw_c_taste{dfw_c_taste.treat=='1',testvars(i)};
    y=dfw_c_taste{dfw_c_taste.treat=='2',testvars(i)};
    x=x(~isnan(x));
    y=y(~isnan(y));

    x_SD=dfw_c_taste{dfw_c_taste.treat=='1',forSD1(i)};
    y_SD=dfw_c_taste{dfw_c_taste.treat=='2',forSD2(i)};
    %[h,p,ci,stats] = ttest2(x,y) %classic t-test
    x_CI=bootci(10000,{@nanmean,x},'type','cper');
    y_CI=bootci(10000,{@nanmean,y},'type','cper');

    %Cohen's d_s, according to Lakens 2013 (Formula 1)
    n1=length(x);
    n2=length(y);
    df1=n1-1;
    df2=n2-1;
    sd_pooled=(nanstd(x_SD)+nanstd(y_SD))./2;
    effect=mean(x)-mean(y);
    se_effect=sqrt((std(x)^2)./n1+(std(y)^2)./n2);
    d=(effect)/sd_pooled;
    var_d=(n1+n2)./(n1.*n2)+(d.^2)./(2.*(df1+df2));
    se_d= sqrt(var_d);

    sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(x),x_CI)
    sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(y),y_CI)
    sprintf([testvars{i},': Cohen''s d: %f, SD-pooled: %f'],d,sd_pooled)

    [pval, t_orig, crit_t, est_alpha, ~]=mult_comp_perm_t2(x,y,10000)
    bayes_factor(abs(d),se_d,0,[0,0.5,2])
end

    bayes_factor(abs(0.205694),0.2134,1,[0,0.2691])

%% Pairwise t-Tests for TASTE measures without baseline
testvars={'treat_expect_post','taste_intensity_post','taste_valence_post','treat_efficacy_post','sumUAW_post'};
for i=1:length(testvars)
disp(['##### Ttest and permuted ttest for: ',testvars{i},'#####']);
x=dfw_c_taste{dfw_c_taste.treat=='1',testvars(i)};
y=dfw_c_taste{dfw_c_taste.treat=='2',testvars(i)};
x=x(~isnan(x));
y=y(~isnan(y));

%[h,p,ci,stats] = ttest2(x,y) %classic t-test
x_CI=bootci(10000,{@nanmean,x},'type','cper');
y_CI=bootci(10000,{@nanmean,y},'type','cper');

%Cohen's d_s, according to Lakens 2013 (Formula 1)
n1=length(x);
n2=length(y);
df1=n1-1;
df2=n2-1;
sd_pooled=sqrt(((df1.*std(x).^2)+(df2.*std(y).^2))./(df1+df2));
effect=mean(x)-mean(y);
d=(effect)/sd_pooled;
var_d=(n1+n2)./(n1.*n2)+(d.^2)./(2.*(df1+df2));
se_d= sqrt(var_d);

sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(x),x_CI)
sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(y),y_CI)
sprintf([testvars{i},': Cohen''s d: %f, SD-pooled: %f'],d,sd_pooled)

[pval, t_orig, crit_t, est_alpha, ~] = mult_comp_perm_t2(x,y,10000)
% A half-Normal prior is used for all of these Bayes Factors, as we
% expected that Tasty-Placebo a) increases expectations b) tastes more
% intense and c) tastes more negative d) is perceived as more efficient e)
% leads to more side-effects
bayes_factor(abs(d),se_d,0,[0,0.5,2])
end



%% Exploring associations
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
corrtable=dfw(:,CPTvars);
corrtable.male=dfw{:,'male'};
%corrtable.placebo=double(~(dfw{:,'treat'}=='0'));
corrtable.taste=double((dfw{:,'treat'}=='2')-(dfw{:,'treat'}=='1'));
all_correlations(corrtable,'Pearson',10000)


% Bayes factors for 
% Correlation expectation vs taste intensity
bayes_factor(r2fishersZ(.04),... % correlations have to be transformed to Fisher's Z before Bayes Factor Calcultation
    n2fishersZse(length(dfw_c_taste.taste_intensity_post)),...
    0,...
    [0,r2fishersZ(0.3),2]) % r=.3 corresponds to a medium effect (d=.5) according to cohen 1992
% Bayes factors for 
% Correlation expectation vs taste valence
bayes_factor(r2fishersZ(.12),... % correlations have to be transformed to Fisher's Z before Bayes Factor Calcultation
    n2fishersZse(length(dfw_c_taste.taste_valence_post)),...
    0,...
    [0,r2fishersZ(0.3),2]) % r=.3 corresponds to a medium effect (d=.5) according to cohen 1992


% GLM-style
%One participant shows very extreme post-pre changes in HR
dfw_c_taste.z_aucrating_perc_post=nanzscore(dfw_c_taste.aucrating_perc_post); 
dfw_c_taste.z_aucrating_perc_pre=nanzscore(dfw_c_taste.aucrating_perc_pre);
dfw_c_taste.z_CPT_HR_mean_pre=nanzscore(dfw_c_taste.CPT_HR_mean_pre);
dfw_c_taste.z_CPT_HR_mean_post=nanzscore(dfw_c_taste.CPT_HR_mean_post);
dfw_c_taste.z_CPT_HR_mean_diff=nanzscore(dfw_c_taste.CPT_HR_mean_post-dfw_c_taste.CPT_HR_mean_pre);

dfw_c_taste.z_maxtime_pre=nanzscore(dfw_c_taste.maxtime_pre); %no
dfw_c_taste.z_maxtime_post=nanzscore(dfw_c_taste.maxtime_post); %no
dfw_c_taste.z_treat_expect_post=nanzscore(dfw_c_taste.treat_expect_post); %no
dfw_c_taste.z_taste_intensity_post=nanzscore(dfw_c_taste.taste_intensity_post); %no
dfw_c_taste.z_taste_valence_post=nanzscore(dfw_c_taste.taste_valence_post); %a little little
dfw_c_taste.z_treat_efficacy_post=nanzscore(dfw_c_taste.treat_efficacy_post); %yes, indeed
dfw_c_taste.z_sumUAW_post=nanzscore(dfw_c_taste.sumUAW_post); %pretty sure

% Including covariates
AUPClm2=fitlm(dfw_c_taste,...
    'z_aucrating_perc_post~z_aucrating_perc_pre+z_treat_expect_post+z_taste_intensity_post+z_taste_valence_post',...
    'DummyVarCoding','effects')
anova(AUPClm2)
anova(AUPClm2,'summary')

HRlm2=fitlm(dfw_c_taste,...
    'z_CPT_HR_mean_post~z_CPT_HR_mean_pre+z_treat_expect_post+z_taste_intensity_post+z_taste_valence_post',...
    'DummyVarCoding','effects')
anova(HRlm2)
anova(HRlm2,'summary')


cpt_scatter(dfw_c_taste.taste_intensity_post,...
            dfw_c_taste.AUC_diff,...
            dfw_c_taste.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions treatment taste intensity rating')
ylabel('%AUPC difference post-pre')

cpt_scatter(dfw_c_taste.taste_valence_post,...
            dfw_c_taste.AUC_diff,...
            dfw_c_taste.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions treatment taste valence rating')
ylabel('%AUPC difference post-pre')

cpt_scatter(dfw_c_taste.treat_efficacy_post,...
            dfw_c_taste.AUC_diff,...
            dfw_c_taste.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions treatment efficacy rating')
ylabel('%AUPC difference post-pre')


cpt_scatter(dfw_c_taste.sumUAW_post,...
            dfw_c_taste.AUC_diff,...
            dfw_c_taste.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Post-sessions side-effects score')
ylabel('%AUPC difference post-pre')


cpt_scatter(dfw_c_taste.taste_intensity_post,...
            dfw_c_taste.treat_expect_post,...
            dfw_c_taste.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Taste intensity')
ylabel('Treatment expectations')

cpt_scatter(dfw_c_taste.taste_valence_post,...
            dfw_c_taste.treat_expect_post,...
            dfw_c_taste.treat)
legend({'Tasteless','','Bitter',''})
xlabel('Taste valence')
ylabel('Treatment expectations')