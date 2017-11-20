clear
load df.mat

%% Create wide df with difference values

noprepost=['prepost','treat',crf.Properties.VariableNames];
pre=dfl(dfl.prepost=='1',:);
post=dfl(dfl.prepost=='2',:);
dfw=join(pre,post,'Keys','subject_no','KeepOneCopy',noprepost);

% Drop empty/ all-nan variables
dfw.cursorini_treat_expect_pre=[];
dfw.ratingdur_treat_expect_pre=[];
dfw.treat_efficacy_pre=[];
dfw.taste_intensity_pre=[];
dfw.taste_valence_pre=[];
dfw.cursorini_treat_efficacy_pre=[];
dfw.cursorini_taste_intensity_pre=[];
dfw.cursorini_taste_valence_pre=[];
dfw.ratingdur_treat_efficacy_pre=[];
dfw.ratingdur_taste_intensity_pre=[];
dfw.ratingdur_taste_valence_pre=[];
dfw.datetime_VAS_end_pre=[];

dfw.AUC_diff=dfw.aucrating_perc_post-dfw.aucrating_perc_pre;
dfw.maxtime_diff=dfw.maxtime_post-dfw.maxtime_pre;

% Make time more readable in wide format
timevars={'arrival_time',...
          'time_instruction',...
          'time_baseline_rating',...
          'time_drug_administration',...
          'time_second_rating',...
          'time_self_evaluation',...
          'time_blood_sample',...
          'time_debriefing',...
          };
for i=1:length(timevars)
    dfw.(['day',timevars{i}])=frac2daytime(dfw.(timevars{i}));
end

save df.mat dfl dfraw crf dfw '-append'