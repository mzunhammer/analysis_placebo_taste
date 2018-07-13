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
dfw.sumUAW_pre=[];

dfw.AUC90_diff=dfw.aucrating_perc90_post-dfw.aucrating_perc90_pre;
dfw.AUC_diff=dfw.aucrating_perc_post-dfw.aucrating_perc_pre;
dfw.maxtime_diff=dfw.maxtime_post-dfw.maxtime_pre;

dfw.CPT_HR_mean_diff=dfw.CPT_HR_mean_post-dfw.CPT_HR_mean_pre;
dfw.CPT_HR_max_diff=dfw.CPT_HR_max_post-dfw.CPT_HR_max_pre;
dfw.CPT_HR_max_perc_BL_diff=dfw.CPT_HR_max_perc_BL_post-dfw.CPT_HR_max_perc_BL_pre;


% Make time more readable in wide format
timevars={'arrival_time',...
          'time_instructions_CPT',...
          'time_pre_treat_CPT',...
          'time_drug_administration',...
          'time_post_treat_CPT',...
          'time_self_evaluation',...
          'time_blood_sample',...
          'time_debriefing',...
          };
for i=1:length(timevars)
    dfw.(['day',timevars{i}])=frac2daytime(dfw.(timevars{i}));
end

%% Additional info on timing
dfw.lab_time_before_pre_treat_CPT=(dfw.time_pre_treat_CPT-dfw.arrival_time)*24*60;
dfw.lab_time_before_post_treat_CPT=(dfw.time_post_treat_CPT-dfw.arrival_time)*24*60;
dfw.waiting_time=(dfw.time_post_treat_CPT-dfw.time_drug_administration)*24*60;
dfw.between_cpt_time=(dfw.time_post_treat_CPT-dfw.time_pre_treat_CPT)*24*60;

dfw.maxtimers_pre=dfw.maxtime_pre>179;
dfw.maxtimers_post=dfw.maxtime_post>179;


save df.mat dfl dfraw crf dfw '-append'