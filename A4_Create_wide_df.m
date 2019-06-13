clear
load df.mat

%% Create wide df with difference values

noprepost=['prepost','treat','study',crf.Properties.VariableNames];
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
dfw.sumUAW_pre=[];

% Create "Maxtimers"
dfw.maxtimers_pre=dfw.maxtime_pre>179;
dfw.maxtimers_post=dfw.maxtime_post>179;

% Create difference values
dfw.AUC90_diff=dfw.aucrating_perc90_post-dfw.aucrating_perc90_pre;
dfw.AUC_diff=dfw.aucrating_perc_post-dfw.aucrating_perc_pre;
dfw.maxtime_diff=dfw.maxtime_post-dfw.maxtime_pre;
dfw.maxtimers_diff=dfw.maxtimers_post-dfw.maxtimers_pre;
dfw.SYS_after_CPT_diff=dfw.SYS_after_CPT_post-dfw.SYS_after_CPT_pre;
dfw.DIA_after_CPT_diff=dfw.DIA_after_CPT_post-dfw.DIA_after_CPT_pre;

dfw.CPT_HR_mean_diff=dfw.CPT_HR_mean_post-dfw.CPT_HR_mean_pre;
dfw.CPT_HR_mean_perc_BL_diff=dfw.CPT_HR_mean_perc_BL_post-dfw.CPT_HR_mean_perc_BL_pre;

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

%% Additional info on environmental Temperatures (Wetterstation Düsseldorf)

df_tempdata=readtable('../data_placebo_taste/wetterdaten_station_duesseldorf_dwd_stunde/wetterdaten_stuendlich_duesseldorf_20161718.txt','Format','%u%{yyyyMMddHH}D%u%f%f%s');
df_tempdata.TT_TU_1d=movmean(df_tempdata.TT_TU,days(1),...
                            'SamplePoints',df_tempdata.MESS_DATUM);
df_tempdata.TT_TU_7d=movmean(df_tempdata.TT_TU,days(7),...
                            'SamplePoints',df_tempdata.MESS_DATUM);

dfw.datetime_CPT_post_hour = dateshift(dfw.datetime_CPT_end_post, 'start', 'hour', 'nearest');                             
dfl.datetime_CPT_end_hour = dateshift(dfl.datetime_CPT_end, 'start', 'hour', 'nearest');
dfw=outerjoin(dfw,df_tempdata,...
                    'LeftKeys','datetime_CPT_post_hour',...
                    'RightKeys','MESS_DATUM',...
                    'Type','left',...
                    'RightVariables',{'TT_TU','TT_TU_1d','TT_TU_7d'});
dfl=outerjoin(dfl,df_tempdata,...
                    'LeftKeys','datetime_CPT_end_hour',...
                    'RightKeys','MESS_DATUM',...
                    'Type','left',...
                    'RightVariables',{'TT_TU','TT_TU_1d','TT_TU_7d'});
dfw=sortrows(dfw,'subject_no');

save df.mat dfl dfraw crf dfw '-append'