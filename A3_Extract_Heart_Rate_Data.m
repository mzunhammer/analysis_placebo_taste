%% Exploration and cleaning of HR data
% The following script was not developed in the exact sequence of code, but
% rather by iterating back and forth. The process was as follows:
% 
% 1. Load extracted HR timecourses & combine with rest of data.
% 2. Compare between-trigger duration of HR recordings, compare with
% ratingduration >> check for unrealistic timing
% 3. Exclude two sessions where HR-recording was shorter than rating
% recording (Gerrit always triggerd HR after ratings)
% 4. Sync HR time to ratingtime using the second trigger of valid HR recordings
% with two triggers. (Time of HR monitor drifted w time, as it was running on a batterie)
% 5. Check validity of HR sessions with 3 or 4 triggers. >> Repair if
% unambiguous solution possible (was the case for all).
% - Re-sync HR time againg, after including 3 and 4 trigger sessions
% .6 One-by-one check of HR synced timecourses with one trigger only.
% Match with ratingtime. >> All of these were start-triggered only.
%
clear
%%  Define extraction parameters

max_dur=180; % maximum duration of CPT was 3min
% Number pre-trigger baseline epochs in seconds.
pre_t=15; 
% The longer the better, but:
% ? For some participants only 30s of pre-testing baseline available.
% - Most participants had a blood pressure measurement btw. 10 and 150
% seconds before the CPT, which may affect heart rate.
% Number post-trigger baseline epochs in seconds.
post_t=15;
% The longer the better, but:
% ? For some participants only 28s of pre-testing baseline available.
% - Most participants had a blood pressure measurement btw.
% 30 and 150 seconds after the CPT, which may affect heart rate.

%% Load pre-read raw data and long df
load('HR_df_raw.mat')
load('df.mat')
% Join dfl and HR timecourses
HR_df_raw.subject_no=categorical(HR_df_raw.subIDs_num);
HR_df_raw.prepost=categorical(HR_df_raw.prepost);
dfl.subject_no_numeric=str2double(string(dfl.subject_no));

dfl=outerjoin(dfl,HR_df_raw,'key',{'subject_no','prepost'},...
                                   'Type','left',...
                                   'MergeKeys',true,...
                                    'RightVariables',{'fnames_trends','dfraw'});                     

%% Excluded due to erronenous recordings:

 erronenous=[395,451,495,497,587,625];              % 395 extreme maxtime_diff, 625,451,497,587 and 317 are recording with one trigger, which are not clearly aligned with the CTP-start, 495 was excluded as pre-testing CPT had to be repeated due to technical failure (Subj 280) 
 for i=erronenous
     dfl.dfraw{i}=[];
 end                       
%% In the first part of the experiment the end-time of CPT was logged with minute, but not second precision
% Fore these files it is better to use the file-creation time.
dfl.datetime_CPT_end(dfl.subject_no_numeric<=138)=dfl.datetime_CPT_filetime(dfl.subject_no_numeric<=138);

%% #For sessions with 4 triggers >> Split, in first and second session
% Gerrit sometimes forgot to pause recordings inbetween CPT measurements.
% For Max, we decided to let measurements continue inbetween CPT
% measurements
% Splitting half-way
% solves the issue (double-checked for every case).
for i=1:length(dfl.dfraw) % Get number of triggers
    if ~isempty(dfl.dfraw{i})
        dfl.ntriggers(i)=sum(dfl.dfraw{i}.triggers);
    end
end

disp({'Number of Sessions with 4-Triggers:',sum(dfl.ntriggers==4)});
for i=find(dfl.ntriggers==4)'%[29,61,65,67,69,83,103,147,237,277:2:height(dfl)]
    n=length(dfl.dfraw{i}.triggers);
    dfl.dfraw{i+1}=dfl.dfraw{i}(round(n/2):end,:);
    dfl.dfraw{i}=dfl.dfraw{i}(1:round(n/2),:);
end

for i=1:length(dfl.dfraw) % Get number of triggers again
    if ~isempty(dfl.dfraw{i})
        dfl.ntriggers(i)=sum(dfl.dfraw{i}.triggers);
    end
end
disp({'Number of Sessions with 4-Triggers after splitting files:',sum(dfl.ntriggers==4)});


%% For selected recordings with two or three triggers also split
for i=[303, 297, 291] % Same for outliers, where only one trigger is available per CPT run
    n=length(dfl.dfraw{i}.triggers);
    dfl.dfraw{i+1}=dfl.dfraw{i}(round(n/2):end,:);
    dfl.dfraw{i}=dfl.dfraw{i}(1:round(n/2),:);
end

for i=[349, 317,293] % Same for outliers, where only one trigger is available for one of the two CPT runs
    n=length(dfl.dfraw{i}.triggers);
    dfl.dfraw{i+1}=dfl.dfraw{i}(round(n/2):end,:);
    dfl.dfraw{i}=dfl.dfraw{i}(1:round(n/2),:);
end

for i=1:length(dfl.dfraw) % Get number of triggers again
    if ~isempty(dfl.dfraw{i})
        dfl.ntriggers(i)=sum(dfl.dfraw{i}.triggers);
    end
end

%% Correct recordings with three triggers
disp({'Number of Sessions with 3-Triggers:',sum(dfl.ntriggers==3)});
% Plot files with maxtime-diff below 0 (indicating that HR trigger was pulled before CTP trigger. all except for the two outliers were  below 2 seconds in time-difference, so should indicate no BIG problems)
%files for repair
%plot_raw_HR(dfl,find(dfl.ntriggers==3)');

% Delete superfluous (pre-term) first trigger (start of session triggered
% twice)
for i=[23,40,41,53,114]
    t=find(dfl.dfraw{i}.triggers);
    dfl.dfraw{i}.triggers(t(1))=0;
end
% Delete superfluous (pre-term) last trigger (end of session triggered
% twice)
for i=[82,109]
    t=find(dfl.dfraw{i}.triggers);
    dfl.dfraw{i}.triggers(t(3))=0;
end
for i=1:length(dfl.dfraw) % Get number of triggers again
    if ~isempty(dfl.dfraw{i})
        dfl.ntriggers(i)=sum(dfl.dfraw{i}.triggers);
    end
end
disp({'Number of Sessions with 3-Triggers after splitting files:',sum(dfl.ntriggers==3)});

%% Analyze all files with two triggers (before and after measurement)
for i=1:length(dfl.dfraw)
    if dfl.ntriggers(i)==2 % For cases in which two triggers were set.
        onoff=find(dfl.dfraw{i}.triggers);
        dfl.trigger_time_1(i)=dfl.dfraw{i}.datetime(onoff(1));
        dfl.trigger_time_2(i)=dfl.dfraw{i}.datetime(onoff(2));
        bp_measurements=find(~isnan(dfl.dfraw{i}.NBPD));
        bp_dist_from_CPT_start=onoff(1)-bp_measurements;
        bp_dist_from_CPT_end=bp_measurements-onoff(2);
        t1=min(bp_dist_from_CPT_start(bp_dist_from_CPT_start>0));
        t2=min(bp_dist_from_CPT_end(bp_dist_from_CPT_end>0));
        if ~isempty(t1)
             dfl.time_of_last_bp_before_CPT(i)=t1;
        else
             dfl.time_of_last_bp_before_CPT(i)=NaN;
        end
        if ~isempty(t2)
             dfl.time_of_last_bp_after_CPT(i)=t2;
        else
             dfl.time_of_last_bp_after_CPT(i)=NaN;
        end
    end
end

%% Compare time periods between BP measurements (which were logged by the monitor)
% and HR measurements. BP measurements were always taken before and after CPT
% Long time periods may indicate outliers/missing triggers.
figure
hist(dfl.time_of_last_bp_before_CPT,50)
title('Time from last bp before CPT to pre-trigger')
%plot(dfl.dfraw{dfl.subject_no=='12'}.datetime,

%plot_raw_HR(dfl,find(dfl.time_of_last_bp_before_CPT>150)');

figure
hist(dfl.time_of_last_bp_after_CPT,50)
title('Time from post-trigger to next bp after CPT ')

%plot_raw_HR(dfl,find(dfl.time_of_last_bp_after_CPT>150)');

% All look ok except
% - i=303 (subject no 152, sess 1): Here there are two
% triggers far away from each other, I suspect that only one trigger was
% set for the pre-, as well as the post-treatment CPT
% - i=297 (subject no 149, sess 1): same as above
% - i=291 (subject no 146, sess 1): same as above

%% Approximate correction for deviation of MATLAB time and HR monitor time
%
% The monitor time and the time of the computer used for CPT recordings was
% fairly aligned in the beginning of the measurement periods. However, it
% was running on a battery... the absolute time of the monitor drifted over
% the course of measurements. For easier comparisons of CPT-start timestamps
% and HR-timestamps, the monitor-time is corrected.
% The procedure basically uses an robust linear regression of time CPT versus time
% HR. This way, sessions with erronenous triggers have limited
% influence.

dfl_new1=HR_monitor_trigger_time_correction(dfl(dfl.subject_no_numeric<=138,:));
dfl_new2=HR_monitor_trigger_time_correction(dfl(dfl.subject_no_numeric>138,:));
dfl=[dfl_new1;dfl_new2];

% Check for recording where rating- and HR- timestamps are far apart after
% synchronisation
dfl.HR_vs_rating_trig_diff=seconds(timeofday(dfl.datetime_CPT_end)-timeofday(dfl.trigger_time_2_sync));
figure
hist(dfl.HR_vs_rating_trig_diff,100)

%plot_raw_HR(dfl,find(dfl.HR_vs_rating_trig_diff<-300)','Corrected_Time');
%% Check for differences between maxtime (Rating) and maxtime(HR)
%Positive time differences are expected, as Gerrit & Max pressed the HR-
%post-measurement trigger usually just after ending the rating. Negative
%differences indicate that HR recordings were shorter than the rating period,
%which is incompatible with the experimental time-course and indicates
 %problems.

figure
hist(dfl.maxtime_diff,20)
title('Difference maxtime (HR Monitor) minus maxtime (Rating), clean')
% After removing two outliers, the differences in Rating and HR times seem
% reasonable. >> As expected, HR times are a little longer. We can proceed
% with extracting the HR time-windows based on rating maxtime.

% Plot files with maxtime-diff below 0 (indicating that HR trigger was pulled before CTP trigger).
%files for repair
%plot_raw_HR(dfl,find(dfl.maxtime_diff<-1)','Corrected_Time');
%  all of these showed very small time-difference, indicating no problems)

% Plot files with maxtime-diff above 15 seconds (indicating either very
% long trigger delay by Gerrit and Max or other problems)
%plot_raw_HR(dfl,find(dfl.maxtime_diff>15)','Corrected_Time');
%Fazit: For all of these extremes, HR recordings looked legitimate.
%Post-testing triggers for HR were likely pressed too late. No problem,
%since HR-recording windows are chosen based on the first trigger, only.
%% Plot files with only one trigger >> Required once to hand-pick
%files for repair
for i=1:length(dfl.dfraw) % Get number of triggers again
    if ~isempty(dfl.dfraw{i})
        dfl.ntriggers(i)=sum(dfl.dfraw{i}.triggers);
    end
end

%plot_raw_HR(dfl,find(dfl.ntriggers==1)','Corrected_Time');
% Fazit: Most cases where only one trigger was found in the HR records,
% these corresponded to "early triggers", indicating the start of CPT. This
% was confirmed by comparing (synced) trigger times with rating periods and
% by checking that they are placed between BP measurements.
% The following cases are suspects of "late
% "Late trigger" 451 497 587. Completely Unclear: 317
%%  Extraction of timecourse

% NOTE 1: ONLY THE "START TRIGGER IS USED TO DEFINE THE BEGINNING OF HR
% RECORDINGS
% NOTE 2: THE LENGTH OF THE HR PERIOD IS DEFINED BY "MAXTIME" AS OBTAINED
% IN THE PAIN RATING CPT RECORDING
dfl.CPT_HR_pre=cell(size(dfl.dfraw));
dfl.CPT_HR=cell(size(dfl.dfraw));
dfl.CPT_HR_post=cell(size(dfl.dfraw));

dfl.CPT_HR_mean_pre=NaN(size(dfl.dfraw));
dfl.CPT_HR_perc_BL=cell(size(dfl.dfraw));
dfl.CPT_HR_max=NaN(size(dfl.dfraw));

for i=1:height(dfl)
    ratingdur=round(dfl.maxtime(i));
    if ~isempty(dfl.dfraw{i})
        trigs=find(dfl.dfraw{i}.triggers);
    if ~isempty(trigs)
        i_pre=trigs(1)-pre_t;
        i_cpt=trigs(1);
        i_post=trigs(1)+ratingdur;
        if i_pre<0
            fprintf('Warning, i_pre<0 for i=%d, Participant: %d, prepost: %d\n',...
            i,dfl.subject_no_numeric(i),dfl.prepost(i))
            i_pre=1;
        end
        
        % Extract and NaN pad HR BL Period
        curr_HR_pre=NaN(pre_t,1); %pre-allocate BL period
        curr_HR_pre_raw=dfl.dfraw{i}.HR(i_pre:i_cpt-1); %NaN-pad (pre) BL
        curr_HR_pre(pre_t-length(curr_HR_pre_raw)+1:end)=curr_HR_pre_raw;
        dfl.CPT_HR_pre{i}=curr_HR_pre;
        
        % Extract and NaN pad HR MAIN Period
        curr_HR=NaN(max_dur,1); %pre-allocate HR main period
        curr_HR_raw=dfl.dfraw{i}.HR(i_cpt:i_post-1); %NaN-pad HR main period (post)
        curr_HR(1:length(curr_HR_raw))=curr_HR_raw;
        dfl.CPT_HR{i}=curr_HR;
        
        % Extract and NaN pad HR POST Period
        curr_HR_post=NaN(max_dur,1); %pre-allocate HR main period
        curr_HR_post_raw=dfl.dfraw{i}.HR(i_cpt:i_post-1); %NaN-pad HR main period (post)
        curr_HR_post(1:length(curr_HR_post_raw))=curr_HR_post_raw;
        dfl.CPT_HR_post{i}=curr_HR_pre;
        
        % Summarize pre,main,post periods
        dfl.CPT_HR_mean_pre(i)=nanmean(dfl.CPT_HR_pre{i});
        dfl.CPT_HR_mean(i)=nanmean(dfl.CPT_HR{i});
        dfl.CPT_HR_mean_post(i)=nanmean(dfl.CPT_HR_post{i});
        dfl.CPT_HR_mean_pre(dfl.CPT_HR_mean_pre==0)=NaN;
        dfl.CPT_HR_mean(dfl.CPT_HR_mean==0)=NaN;
        dfl.CPT_HR_mean_post(dfl.CPT_HR_mean_post==0)=NaN;
        
        dfl.CPT_HR_perc_BL{i}=(dfl.CPT_HR{i}./dfl.CPT_HR_mean_pre(i)).*100;
        dfl.CPT_HR_max(i)=max(dfl.CPT_HR{i})';
    end
    end
end

dfl.CPT_HR_mean_perc_BL=dfl.CPT_HR_mean./dfl.CPT_HR_mean_pre.*100;
dfl.CPT_HR_max_perc_BL=dfl.CPT_HR_max./dfl.CPT_HR_mean_pre.*100;

save df.mat dfl dfraw crf df_questionnaire '-append'

% %% For exploratory analysis of extreme values
% figure,hist(dfl.CPT_HR_mean_pre,100)
% figure,hist(dfl.CPT_HR_mean,100)
% figure,hist(dfl.CPT_HR_mean_post,100)
% figure,hist(dfl.CPT_HR_max,100)
% 
% % Check out very low HR_mean recordings
%plot_raw_HR(dfl,find(dfl.CPT_HR_mean<60)','Corrected_Time');

% % Check out very high HR_mean recordings
%plot_raw_HR(dfl,find(dfl.CPT_HR_mean>110)','Corrected_Time');
 
%% Final check:
%plot_raw_HR(dfl,randi([1,height(dfl)],1,10),'Corrected_Time','Trigger_Focus');