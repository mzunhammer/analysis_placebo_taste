%% Clean workspace, load packets
addpath('/Users/matthiaszunhammer/Documents/MATLAB/crop')

clear
close all

%% Bitter
datafolder='../data_placebo_taste/pre_test_bitterness.xlsx';
[NUM,TXT,RAW]=xlsread(datafolder);

dfpre=array2table(NUM,'VariableNames',TXT(1,1:size(NUM,2)));
var_names=dfpre.Properties.VariableNames;
dfpre_l=stack(dfpre,{...
    var_names(~cellfun(@isempty,regexp(var_names,'^t.+_relative$','match'))),...
    var_names(~cellfun(@isempty,regexp(var_names,'^t.+_absolute$','match')))},...
    'NewDataVariableName',{'int_relative','int_absolute'});
dfpre_l.t=repmat([0,1,2,3,5,10,15,20,25,30]',height(dfpre_l)/10,1);

% Drop Subjects 4 and 5's second run, as the same concentration was measured twice
dfpre_l=dfpre_l(~((dfpre_l.subject_ID==4) & (dfpre_l.run==2)),:);
dfpre_l=dfpre_l(~((dfpre_l.subject_ID==5) & (dfpre_l.run==2)),:);

subs=unique(dfpre_l.subject_ID);
n=0;
for i=1:length(subs)
    idx = (dfpre_l.subject_ID==subs(i)) &...
          (dfpre_l.conzentration==0.03);
    plot(dfpre_l.t(idx),...
         dfpre_l.int_absolute(idx),...
     'Color',[0.25,0.25,0.25])
    hold on
    if ~isnan(dfpre_l.int_absolute(idx))
        n=n+1;
    end
end

mean_t0=nanmean(dfpre_l.int_absolute((dfpre_l.t==0)&(dfpre_l.conzentration==0.03)));
sd_t0=nanstd(dfpre_l.int_absolute((dfpre_l.t==0)&(dfpre_l.conzentration==0.03)));
line([-2.5,-1],[mean_t0,mean_t0],'Color',[0.25,0.25,0.25])
errorbar(-1.75,mean_t0,sd_t0,'Color',[0.25,0.25,0.25])

dfpre_l_by_t=grpstats(dfpre_l(dfpre_l.conzentration==0.03,:),'t','mean');
plot(dfpre_l_by_t.t,...
     dfpre_l_by_t.mean_int_absolute,...
 'Color',[0.25,0.25,0.25],...
'LineWidth',3)

ax=gca;
ax.YAxisLocation = 'origin';
hold off
text(-3.5,20,...
    'Taste intensity rating (101-pt NRS units) ± SD',...
    'Rotation',90);
xlabel('Time since application (minutes)');
title(sprintf('Time-course of taste intensity ratings for 0.08 ml of a 0.03%% quinine solution (n = %d)',n));
axis([-4,30,0,100])
box off;

hgexport(gcf, '../paper_placebo_taste/figureS1.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figureS1.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figureS1.png');

%% Sweet
datafolder_sweet='../data_placebo_taste/pre_test_sweetness.xlsx';
[NUM,TXT,RAW]=xlsread(datafolder_sweet);

dfpre_sweet=array2table(NUM,'VariableNames',TXT(1,1:size(NUM,2)));
var_names=dfpre_sweet.Properties.VariableNames;
dfpre_sweet_l=stack(dfpre_sweet,{...
    var_names(~cellfun(@isempty,regexp(var_names,'^t.+_relative$','match'))),...
    var_names(~cellfun(@isempty,regexp(var_names,'^t.+_absolute$','match')))},...
    'NewDataVariableName',{'int_relative','int_absolute'});
dfpre_sweet_l.t=repmat([0,1,2,3,5,10,15,20,25,30]',height(dfpre_sweet_l)/10,1);

subs=unique(dfpre_sweet_l.subject_ID);
n=0;
for i=1:length(subs)
    idx = (dfpre_sweet_l.subject_ID==subs(i)) &...
          (dfpre_sweet_l.conzentration==1);
    plot(dfpre_sweet_l.t(idx),...
         dfpre_sweet_l.int_absolute(idx),...
     'Color',[0.25,0.25,0.25])
    hold on
    if ~isnan(dfpre_sweet_l.int_absolute(idx))
        n=n+1;
    end
end

mean_t0=nanmean(dfpre_sweet_l.int_absolute((dfpre_sweet_l.t==0)&(dfpre_sweet_l.conzentration==1)));
sd_t0=nanstd(dfpre_sweet_l.int_absolute((dfpre_sweet_l.t==0)&(dfpre_sweet_l.conzentration==1)));
line([-2.5,-1],[mean_t0,mean_t0],'Color',[0.25,0.25,0.25])
errorbar(-1.75,mean_t0,sd_t0,'Color',[0.25,0.25,0.25])

dfpre_sweet_l_by_t=grpstats(dfpre_sweet_l(dfpre_sweet_l.conzentration==1,:),'t','mean');
plot(dfpre_sweet_l_by_t.t,...
     dfpre_sweet_l_by_t.mean_int_absolute,...
 'Color',[0.25,0.25,0.25],...
'LineWidth',3)

ax=gca;
ax.YAxisLocation = 'origin';
hold off
text(-3.5,20,...
    'Taste intensity rating (101-pt NRS units) ± SD',...
    'Rotation',90);
xlabel('Time since application (minutes)');
title(sprintf('Time-course of taste intensity ratings for 0.8 ml of a 1.0 mM saccharin solution (n = %d)',n));
axis([-4,30,0,100])
box off;

hgexport(gcf, '../paper_placebo_taste/figureS2.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../paper_placebo_taste/figureS2.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('../paper_placebo_taste/figureS2.png');