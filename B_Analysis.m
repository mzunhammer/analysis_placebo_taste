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
meanratingbaseline=meanrating;
%meanratingbaseline(prepost==2)=meanrating(prepost==1);
df=table(subID,prepost,treat,maxtime,meanrating);

fitlme(df,'meanrating~prepost*treat+(1+prepost|subID)','CheckHessian',1)

h=histogram(df.meanrating(df.treat=='0'&prepost=='1'));
h.FaceColor=[1 0 0];
hold on
histogram(df.meanrating(df.treat=='0'&prepost=='2'));
hold off