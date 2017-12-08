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

%% Basic sample descriptives
dfw_c.waiting_time=(dfw_c.time_second_rating-dfw_c.time_drug_administration)*24*60;
dfw_c.maxtimers_pre=dfw_c.maxtime_pre>179;
dfw_c.maxtimers_post=dfw_c.maxtime_post>179;

n=length(dfw_c.treat);
n0=sum(dfw_c.treat=='0');
n1=sum(dfw_c.treat=='1');
n2=sum(dfw_c.treat=='2');

demovars={'treat',...
          'age','male','height_in_cm','body_weight_in_kg','waiting_time'};
grpstats(dfw_c(:,demovars),'treat',{'mean','std'})
demovars={'healthy',demovars{2:end}};
grpstats(dfw_c(:,demovars),'healthy',{'mean','std'})

% Handedness
handed_treat0=countcats(dfw_c.handedness(dfw_c.treat=='0'))
handed_treat1=countcats(dfw_c.handedness(dfw_c.treat=='1'))
handed_treat2=countcats(dfw_c.handedness(dfw_c.treat=='2'))
handed_all=countcats(dfw_c.handedness)

table(categories(dfw_c.handedness),handed_treat0/n0)
table(categories(dfw_c.handedness),handed_treat1/n1)
table(categories(dfw_c.handedness),handed_treat2/n2)
table(categories(dfw_c.handedness),handed_all/n)

%% Basic treatment descriptives
% CAVE I: "treat_expect_post" was obtained just BEFORE post-treatment CPT
% the other treat_ variables were obtained just AFTER post-treatment CPT
% CAVE II: "non-treatment" group was not asked these questions, as they
% obviously made no sense. Exclude "non-treatment" group to avoud wrong n
% and averages

treatvars={'treat',...
          'treat_expect_post','treat_efficacy_post','taste_intensity_post','taste_valence_post'};
grpstats(dfw_c_taste(:,treatvars),'treat',{'mean','std'})
treatvars={'healthy',treatvars{2:end}};
grpstats(dfw_c_taste(:,treatvars),'healthy',{'mean','std'})
%% Basic CPT descriptives
CPTvars={'treat',...
          'aucrating_perc_pre','aucrating_perc_post','AUC_diff',...
          'maxtime_pre','maxtime_post','maxtime_diff',...
          'maxtimers_pre','maxtimers_post',...
          'CPT_HR_mean_pre','CPT_HR_mean_post'...
          };
grpstats(dfw_c(:,CPTvars),'treat',{'mean','std'})
CPTvars={'healthy',CPTvars{2:end}};
grpstats(dfw_c(:,CPTvars),'healthy',{'mean','std'})


%% SUPPLEMENT 1a: plot FULL pain rating curves
h_means=cpt_timeplot2(dfl_c.prepost,dfl_c.treat,dfl_c.rating180,50);
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
h_means=cpt_timeplot_means(dfl_c.treat,dfl_c.prepost,dfl_c.rating180,50);
hs = findall(gcf,'Type','axes');
title(hs(3),{'No treatment'});
title(hs(2),{'Tasteless placebo'});
title(hs(1),{'Bitter placebo'});
yticks(hs([1,2]),[])
ylabel(hs(3),'VAS pain rating ? 95% CI');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
text(hs(3),0.75, 0.7, 'pre','Units','normalized','FontSize',11)
text(hs(3),0.75, 0.3, 'post','Units','normalized','FontSize',11)
text(hs(2),0.75, 0.7, 'pre','Units','normalized','FontSize',11)
text(hs(2),0.75, 0.3, 'post','Units','normalized','FontSize',11)
text(hs(1),0.75, 0.7, 'pre','Units','normalized','FontSize',11)
text(hs(1),0.75, 0.3, 'post','Units','normalized','FontSize',11)

hgexport(gcf, '../paper_placebo_taste/figure1Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure1Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure1Sb.png');


%% Figure 1a: plot %AUCP pre versus post
subplot(1,2,1)

[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.aucrating_perc);
title('Area under the pain curve, pre vs post')
ylabel('% area under the pain curve ? 95% CI')
%legend(h_means,{'pre','post'},...
%        'location','southoutside',...
%        'orientation','horizontal');
%legend('boxoff')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
pbaspect([1 2 1])

% groupplot(dfl_c.prepost,dfl_c.treat,dfl_c.aucrating_perc)
% title('Area under the pain curve, pre vs post')
% ylabel('% area under the pain curve')
% legend({'No Treatment','Tasteless Placebo','Bitter Placebo'},...
%         'location','southoutside',...
%         'orientation','horizontal');
% legend('boxoff')
% xticks(1:2)
% xticklabels({'pre','post'});

%% Figure 1b: plot %AUCP change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])

[~,h_means]=groupplot(dfw_c.treat,dfw_c.AUC_diff);
title('Area under the pain curve, post - pre')
ylabel('Change in % area under the pain curve ? 95% CI')
%legend(h_means,{'pre','post'},...
%        'location','southoutside',...
%        'orientation','horizontal');
%legend('boxoff')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
hline(0,'color',[0 0 0])
pbaspect([1 2 1])

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figure1.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure1.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure1.png');

%% SUPPLEMENT 2a: plot FULL HR curves
h_means=cpt_timeplot2(dfl_c.prepost,dfl_c.treat,dfl_c.CPT_HR,80);
hs = findall(gcf,'Type','axes');
xticks(hs(4:6),[])
yticks(hs([1,2,4,5]),[])
title(hs(4),{'No treatment'});
title(hs(5),{'Tasteless placebo'});
title(hs(6),{'Bitter placebo'});
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
h_means=cpt_timeplot_means(dfl_c.treat,dfl_c.prepost,dfl_c.CPT_HR,80);
hs = findall(gcf,'Type','axes');
title(hs(3),{'No treatment'});
title(hs(2),{'Tasteless placebo'});
title(hs(1),{'Bitter placebo'});
yticks(hs([1,2]),[])
ylabel(hs(3),'Mean heart rate (bpm) ? 95% CI');
xlabel(hs(1),'Time (s)');
xlabel(hs(2),'Time (s)');
xlabel(hs(3),'Time (s)');
text(hs(3),0.75, 0.55, 'pre','Units','normalized','FontSize',11)
text(hs(3),0.75, 0.25, 'post','Units','normalized','FontSize',11)
text(hs(2),0.75, 0.55, 'pre','Units','normalized','FontSize',11)
text(hs(2),0.75, 0.25, 'post','Units','normalized','FontSize',11)
text(hs(1),0.75, 0.55, 'pre','Units','normalized','FontSize',11)
text(hs(1),0.75, 0.25, 'post','Units','normalized','FontSize',11)

hgexport(gcf, '../paper_placebo_taste/figure2Sb.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2Sb.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2Sb.png');


%% Figure 2a: plot HR pre versus post
subplot(1,2,1)

[~,h_means]=groupplot2(dfl_c.treat,dfl_c.prepost,dfl_c.CPT_HR_mean);
title('Mean heart rate, pre vs post')
ylabel('Mean heart rate (bpm) ? 95% CI')
%legend(h_means,{'pre','post'},...
%        'location','southoutside',...
%        'orientation','horizontal');
%legend('boxoff')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
pbaspect([1 2 1])

%% Figure 2b: plot HR change: post-pre
subplot(1,2,2)
pbaspect([2 1 1])

[~,h_means]=groupplot(dfw_c.treat,dfw_c.CPT_HR_mean_diff);
title('Mean heart rate change, post - pre')
ylabel('Change in mean heart rate (bpm) ? 95% CI (post-pre)')
%legend(h_means,{'pre','post'},...
%        'location','southoutside',...
%        'orientation','horizontal');
%legend('boxoff')
xticklabels({'No treatment','Tasteless placebo','Bitter placebo'});
xtickangle(45)
hline(0,'color',[0 0 0])
pbaspect([1 2 1])

%set(gcf, 'Position', [0 0 960 540])
hgexport(gcf, '../paper_placebo_taste/figure2.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figure2.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figure2.png');

%% Mixed model analysis %AUCP

AUPCm0=fitlme(dfl_c,'aucrating_perc~1','CheckHessian',1)
AUPCmm0=fitlme(dfl_c,'aucrating_perc~1+(1|subject_no)','CheckHessian',1)
AUPCmm1=fitlme(dfl_c,'aucrating_perc~prepost*treat+(1|subject_no)','CheckHessian',1)
%age, male, body_weight_in_kg, height_in_cm, alcoholic_drinks_per_week,contraception, skin_temperature_2-skin_temperature_1
%mm2=fitlme(dfl_c,'aucrating_perc~bmi+prepost*treat+(1|subject_no)','CheckHessian',1)

stats=anova(AUPCmm1)


HRm0=fitlme(dfl_c,'CPT_HR_mean~1','CheckHessian',1)
HRmm0=fitlme(dfl_c,'CPT_HR_mean~1+(1|subject_no)','CheckHessian',1)
HRmm1=fitlme(dfl_c,'CPT_HR_mean~prepost*treat+(1|subject_no)','CheckHessian',1)
%age, male, body_weight_in_kg, height_in_cm, alcoholic_drinks_per_week,contraception, skin_temperature_2-skin_temperature_1
%mm2=fitlme(dfl_c,'aucrating_perc~bmi+prepost*treat+(1|subject_no)','CheckHessian',1)

stats=anova(HRmm1)
%% T-Test (TASTE) AUC_diff, maxtime_diff, taste intensity, valence, subj efficacy

testvars={'AUC_diff','maxtime_diff','CPT_HR_mean_diff','treat_expect_post','taste_intensity_post','taste_valence_post','treat_efficacy_post'};%,'treat_expect_post','taste_intensity_post','taste_valence_post','treat_efficacy_post'};
for i=1:length(testvars)
disp(['##### Ttest and permuted ttest for: ',testvars{i},'#####']);
x=dfw_c_taste{dfw_c_taste.treat=='1',testvars(i)};
y=dfw_c_taste{dfw_c_taste.treat=='2',testvars(i)};
x=x(~isnan(x));
y=y(~isnan(y));
%[h,p,ci,stats] = ttest2(x,y) %classic t-test
x_CI=bootci(1000,{@nanmean,x},'type','cper');
y_CI=bootci(1000,{@nanmean,y},'type','cper');

sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(x),x_CI)
sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(y),y_CI)
[pval, t_orig, crit_t, est_alpha, ~]=mult_comp_perm_t2(x,y,10000)
end

%% Sample descriptives treatment vs no treatment only
dfw_c.waiting_time=(dfw_c.time_second_rating-dfw_c.time_drug_administration)*24*60;
dfw_c.treat_or_not=dfw_c.treat~='0';

n=length(dfw_c.treat);
n0=sum(dfw_c.treat_or_not==0);
n1=sum(dfw_c.treat_or_not==1);


demovars={'treat_or_not','AUC_diff','maxtime_diff','CPT_HR_max_pre','CPT_HR_max_post','CPT_HR_max_diff',};
grpstats(dfw_c(:,demovars),'treat_or_not',{'mean','std'})
demovars={'healthy','AUC_diff','maxtime_diff'};
grpstats(dfw_c(:,demovars),'healthy',{'mean','std'})

%% T-Test (TREATMEN) AUC_diff, maxtime_diff
testvars={'AUC_diff','maxtime_diff','CPT_HR_mean_diff'}
for i=1:length(testvars)
disp(['##### Ttest and permuted ttest for: ',testvars{i},'#####']);
x=dfw_c{dfw_c.treat=='0',testvars(i)};
y=dfw_c{dfw_c.treat~='0',testvars(i)};

x=x(~isnan(x));
y=y(~isnan(y));
%[h,p,ci,stats] = ttest2(x,y) %classic t-test
x_CI=bootci(1000,{@nanmean,x},'type','cper');
y_CI=bootci(1000,{@nanmean,y},'type','cper');

sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(x),x_CI)
sprintf([testvars{i},': mean: %f, 95%% CI [%f, %f]'],nanmean(y),y_CI)
[pval, t_orig, crit_t, est_alpha, ~]=mult_comp_perm_t2(x,y)
end

%% Explore all data

for i=1:width(dfw_c)
    figure
    if isnumeric(dfw_c{:,i})
    %histogram(dfw_c{:,i},round(height(dfw_c)/5))
    elseif iscategorical(dfw_c{:,i})
    histogram(dfw_c{:,i})
    end
    title(dfw_c.Properties.VariableNames(i))
end

% Peculiarities exploration

% Make all categoricals categorical!
% On what scale is time measured?

% ? A there is one very low (<10bpm) post_heart_rate_2
% ? A there is one very low (<40bpm) pre_heart_rate_2

% ? skin_temperature_2 is ridiculously low for many participants
% ? A there is one very low (<30bpm) ppst_diast_rr_1 and one very high >120

% ? A there is one very low (<30bpm) pre_syst_rr_2
% ? A there is one very low (<30bpm) pre_diast_rr_2
% ? A there is one very low (<.25bpm) time second rating

% - There is one guy with very high (>20) alcohol consumption
%% General linear model: main result
AUC_notaste=dfw.AUC_diff(dfw.treat=='1');
AUC_taste=dfw.AUC_diff(dfw.treat=='2');

n1=length(AUC_notaste);
n2=length(AUC_taste);
df1=n1-1;
df2=n2-1;

[h,p,ci,stats] =ttest2(AUC_notaste,AUC_taste);
   
effect=mean(AUC_notaste)-mean(AUC_taste);
SEeffect=sqrt((df1*std(AUC_notaste)^2+df2*std(AUC_taste)^2)/(df1+df2));

bayesfactor(effect,SEeffect,0,[0,5,2])
   
%Simple one-way ANOVA of differences between groups
mdl1=fitglm(dfw_c,'AUC_diff~treat')

[p,tbl,stats] = anova1(dfw_c.AUC_diff,dfw_c.treat);
[c,m,h,gnames] =multcompare(stats,'CType','lsd');

sprintf('Effect of Placebo-NoTaste vs NoTreatment: %0.2f 95%%CI [%0.2f; %0.2f]', c(1,4),c(1,3),c(1,5))
sprintf('Effect of Placebo-Bitter vs NoTreatment: %0.2f 95%%CI [%0.2f; %0.2f]', c(2,4),c(2,3),c(2,5))
sprintf('Effect of Placebo-Bitter vs Placebo-NoTaste: %0.2f 95%%CI [%0.2f; %0.2f]', c(3,4),c(3,3),c(3,5))
%% Main results AUC

% Plot pre & post
pre0=nanmean(dfw_c.aucrating_perc_pre(dfw_c.treat=='0'));
pre1=nanmean(dfw_c.aucrating_perc_pre(dfw_c.treat=='1'));
pre2=nanmean(dfw_c.aucrating_perc_pre(dfw_c.treat=='2'));
post0=nanmean(dfw_c.aucrating_perc_post(dfw_c.treat=='0'));
post1=nanmean(dfw_c.aucrating_perc_post(dfw_c.treat=='1'));
post2=nanmean(dfw_c.aucrating_perc_post(dfw_c.treat=='2'));

SDpre0=nanstd(dfw_c.aucrating_perc_pre(dfw_c.treat=='0'));
SDpre1=nanstd(dfw_c.aucrating_perc_pre(dfw_c.treat=='1'));
SDpre2=nanstd(dfw_c.aucrating_perc_pre(dfw_c.treat=='2'));
SDpost0=nanstd(dfw_c.aucrating_perc_post(dfw_c.treat=='0'));
SDpost1=nanstd(dfw_c.aucrating_perc_post(dfw_c.treat=='1'));
SDpost2=nanstd(dfw_c.aucrating_perc_post(dfw_c.treat=='2'));

figure
hold on
errorbar([-0.1,0.9],[pre0,post0],[SDpre0,SDpost0],'Color','black')
errorbar([0,1],[pre1,post1],[SDpre1,SDpost1],'Color','green')
errorbar([0.1,1.1],[pre2,post2],[SDpre2,SDpost2],'Color','blue')
hold off

% Plot post-pre
figure(1)
boxplot(dfw.AUC_diff,dfw.treat)
figure(2)
boxplot(dfw_c.AUC_diff,dfw_c.treat)

ttest2()
%% Plot ALL curves with mean curve
figure
hold on
for i=1:length(dfraw.subIDs)
      plot(dfraw.timefull(i,:),dfraw.ratingfull(i,:))
end
plot(nanmean(dfraw.timefull,1),nanmean(dfraw.ratingfull,1),'b','LineWidth',5)
hold off

% Display curves with mean curve by condition pre vs post
unipres=unique(dfraw.prepost);
for j=1:length(unipres)
currcond=unipres(j);
df_temp=structfun(@(x) x(dfraw.prepost==currcond,:),dfraw,'UniformOutput',0);
    subplot(1,length(unipres),j) % Plot Pre
    hold on
    for i=1:length(df_temp.subIDs)
          plot(df_temp.timefull(i,:),df_temp.ratingfull(i,:))
    end
    plot(nanmean(df_temp.timefull,1),nanmean(df_temp.ratingfull,1),'b','LineWidth',5)
    hold off
end

% Display curves with mean curve by condition pre vs post
unipres=unique(dfraw.prepost);
unitreats=unique(dfraw.treat);
runs=0;
for k=1:length(unitreats)
    currtreat=unitreats(k);
    for j=1:length(unipres)
    runs=runs+1;
    currcond=unipres(j);
    df_temp=structfun(@(x) x((dfraw.prepost==currcond)&(dfraw.treat==currtreat),:),dfraw,'UniformOutput',0);
        subplot(length(unitreats),length(unipres),runs) % Plot Pre
        hold on
        for i=1:length(df_temp.subIDs)
              plot(df_temp.timefull(i,:),df_temp.ratingfull(i,:))
        end
        plot(nanmean(df_temp.timefull,1),nanmean(df_temp.ratingfull,1),'b','LineWidth',5)
        hold off
        ms(k,j)=nanmean(nanmean(df_temp.ratingfull,1));
    end
end



lme=fitlme(df,'aucrating100_perc~prepost*treat+(1+prepost|subID)','CheckHessian',1)
anova(lme)



axis([-0.5,1.5,min(df.aucrating100_perc),max(df.aucrating100_perc)])