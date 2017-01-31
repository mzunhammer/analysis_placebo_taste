clear

load dfraw.mat


% Display ALL curves with mean curve
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

%% Statistical testing
subID=categorical(cellfun(@str2num,dfraw.subIDs));
prepost=categorical(dfraw.prepost);
treat=categorical(dfraw.treat);
maxtime=cellfun(@max, dfraw.time);
meanrating=nanmean(dfraw.ratingfull,2);
aucrating=cellfun(@(x,y) trapz(x,y),dfraw.time,dfraw.rating);
meanratingbaseline=meanrating;
%meanratingbaseline(prepost==2)=meanrating(prepost==1);
df=table(subID,prepost,treat,maxtime,meanrating,aucrating);

fitlme(df,'aucrating~prepost*treat+(1+prepost|subID)','CheckHessian',1)

pre0=nanmean(df.aucrating(df.prepost=='1'&df.treat=='0'));
pre1=nanmean(df.aucrating(df.prepost=='1'&df.treat=='1'));
pre2=nanmean(df.aucrating(df.prepost=='1'&df.treat=='2'));
post0=nanmean(df.aucrating(df.prepost=='2'&df.treat=='0'));
post1=nanmean(df.aucrating(df.prepost=='2'&df.treat=='1'));
post2=nanmean(df.aucrating(df.prepost=='2'&df.treat=='2'));

CIpre0=nanstd(df.aucrating(df.prepost=='1'&df.treat=='0'))/(1.96*sqrt(length(df.aucrating(df.prepost=='1'&df.treat=='0')-1)));
CIpre1=nanstd(df.aucrating(df.prepost=='1'&df.treat=='1'))/(1.96*sqrt(length(df.aucrating(df.prepost=='1'&df.treat=='1')-1)));
CIpre2=nanstd(df.aucrating(df.prepost=='1'&df.treat=='2'))/(1.96*sqrt(length(df.aucrating(df.prepost=='1'&df.treat=='2')-1)));
CIpost0=nanstd(df.aucrating(df.prepost=='2'&df.treat=='0'))/(1.96*sqrt(length(df.aucrating(df.prepost=='2'&df.treat=='0')-1)));
CIpost1=nanstd(df.aucrating(df.prepost=='2'&df.treat=='1'))/(1.96*sqrt(length(df.aucrating(df.prepost=='2'&df.treat=='1')-1)));
CIpost2=nanstd(df.aucrating(df.prepost=='2'&df.treat=='2'))/(1.96*sqrt(length(df.aucrating(df.prepost=='2'&df.treat=='2')-1)));

hold on
errorbar([pre0,post0],[CIpre0,CIpost0],'Color','black')
errorbar([pre1,post1],[CIpre1,CIpost1],'Color','green')
errorbar([pre2,post2],[CIpre2,CIpost2],'Color','blue')
hold off

axis([0,3,min(df.aucrating),max(df.aucrating)])