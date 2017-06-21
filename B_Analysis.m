clear

load dfraw.mat
%% Create long df from raw imports
subject_no=categorical(cellfun(@str2num,dfraw.subIDs));

prepost=categorical(dfraw.prepost);
treat=categorical(dfraw.treat);
maxtime=cellfun(@max, dfraw.time);

%For AUC and Mean rating, the mean has to be taken across the maximum time interval(3
%min) with max rating (100) imputed instead of NaN for subjects that aborted testing.
%ACHTUNG: ratingfull fills with NaNs ratingfull100 with max-ratings!!
meanrating=cellfun(@nanmean,dfraw.rating);
aucrating=cellfun(@(x,y) trapz(x,y),dfraw.time,dfraw.rating);
aucrating100=trapz(dfraw.ratingfull100,2); % same as meanrating100=mean(dfraw.ratingfull100,2);
max_aucrating100=length(dfraw.ratingfull100)*100;
aucrating100_perc=aucrating100/max_aucrating100;

meanratingbaseline=meanrating;

df=table(subject_no,...
    prepost,...
    treat,...
    maxtime,...
    meanrating,...
    aucrating100_perc);

%% Create wide df with difference values
AUC_pre=df(:,df.prepost=='1');
AUC_post=df(:,df.prepost=='2');

crf.subject_no=categorical(crf.subject_no);
df=join(df,crf);


dfs=crf;



%% Display ALL curves with mean curve
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

pre_post_group0=df.aucrating100_perc(df.prepost=='2'&df.treat=='0')-df.aucrating100_perc(df.prepost=='1'&df.treat=='0')
pre_post_group1=df.aucrating100_perc(df.prepost=='2'&df.treat=='1')-df.aucrating100_perc(df.prepost=='1'&df.treat=='1')
pre_post_group2=df.aucrating100_perc(df.prepost=='2'&df.treat=='2')-df.aucrating100_perc(df.prepost=='1'&df.treat=='2')

pre0=nanmean(df.aucrating100_perc(df.prepost=='1'&df.treat=='0'));
pre1=nanmean(df.aucrating100_perc(df.prepost=='1'&df.treat=='1'));
pre2=nanmean(df.aucrating100_perc(df.prepost=='1'&df.treat=='2'));
post0=nanmean(df.aucrating100_perc(df.prepost=='2'&df.treat=='0'));
post1=nanmean(df.aucrating100_perc(df.prepost=='2'&df.treat=='1'));
post2=nanmean(df.aucrating100_perc(df.prepost=='2'&df.treat=='2'));

CIpre0=nanstd(df.aucrating100_perc(df.prepost=='1'&df.treat=='0'))/(1.96*sqrt(length(df.aucrating100_perc(df.prepost=='1'&df.treat=='0')-1)));
CIpre1=nanstd(df.aucrating100_perc(df.prepost=='1'&df.treat=='1'))/(1.96*sqrt(length(df.aucrating100_perc(df.prepost=='1'&df.treat=='1')-1)));
CIpre2=nanstd(df.aucrating100_perc(df.prepost=='1'&df.treat=='2'))/(1.96*sqrt(length(df.aucrating100_perc(df.prepost=='1'&df.treat=='2')-1)));
CIpost0=nanstd(df.aucrating100_perc(df.prepost=='2'&df.treat=='0'))/(1.96*sqrt(length(df.aucrating100_perc(df.prepost=='2'&df.treat=='0')-1)));
CIpost1=nanstd(df.aucrating100_perc(df.prepost=='2'&df.treat=='1'))/(1.96*sqrt(length(df.aucrating100_perc(df.prepost=='2'&df.treat=='1')-1)));
CIpost2=nanstd(df.aucrating100_perc(df.prepost=='2'&df.treat=='2'))/(1.96*sqrt(length(df.aucrating100_perc(df.prepost=='2'&df.treat=='2')-1)));

figure
hold on
errorbar([-0.1,0.9],[pre0,post0],[CIpre0,CIpost0],'Color','black')
errorbar([0,1],[pre1,post1],[CIpre1,CIpost1],'Color','green')
errorbar([0.1,1.1],[pre2,post2],[CIpre2,CIpost2],'Color','blue')
hold off

axis([-0.5,1.5,min(df.aucrating100_perc),max(df.aucrating100_perc)])