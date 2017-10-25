clear

load df.mat


%% Basic sample descriptives
disp(['Age median: ',...
    num2str(median(dfw.age))])

disp(['Age range: ',...
    num2str(min(dfw.age)),...
    ' bis ',...
    num2str(max(dfw.age))])

waiting_time=dfw.time_second_rating-dfw.time_drug_administration
disp(['Mean[min,max] waiting time after drug administration, before post-treatement CPT: ',...
    num2str(nanmean(waiting_time)),...
    ' [',...
    num2str(min(waiting_time))
    '; min',...
    num2str(min(waiting_time))],...
    '] min')
%% Exclude excluded and outlier
excluded=dfw.subject_no(dfw.exclusion==1|dfw.aucrating_perc_pre<5)

dfl_c=dfl;
dfw_c=dfw;

dfl_c(ismember(dfl.subject_no,excluded),:)=[];
dfw_c(ismember(dfw.subject_no,excluded),:)=[];


%%
dfw.taste_intensity(dfw.treat=='0')
mean(dfw.taste_intensity(dfw.treat=='1'))
mean(dfw.taste_intensity(dfw.treat=='2'))

std(dfw.taste_intensity(dfw.treat=='1'))
std(dfw.taste_intensity(dfw.treat=='2'))

mean(dfw.taste_valence(dfw.treat=='1'))
mean(dfw.taste_valence(dfw.treat=='2'))

std(dfw.taste_valence(dfw.treat=='1'))
std(dfw.taste_valence(dfw.treat=='2'))
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