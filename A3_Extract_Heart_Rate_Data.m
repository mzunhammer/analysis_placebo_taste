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

%% Start
load('HR_df_raw.mat')
load('df.mat')
% Join dfl and HR timecourses
HR_df_raw.subIDs_num=categorical(HR_df_raw.subIDs_num);
HR_df_raw.prepost=categorical(HR_df_raw.prepost);

dfl=outerjoin(dfl,HR_df_raw,'LeftKeys', {'subject_no','prepost'},...
                            'RightKeys', {'subIDs_num','prepost'}); 
dfl.Properties.VariableNames{'prepost_dfl'} = 'prepost';
dfl.prepost_HR_df_raw=[];   

%% #Exclude sessions where true trigger could not be determined
% Based on the assessment of maxtime_diff the following outliers with two
% triggers in the HR recording were detected. These have to be excluded
% a-priori, otherwise they will bias the synchronization of Rating and HR
% time.
%
% 82: Subj 41, Session 2:
% Two HR triggers in fairly close (47 s) succession that do not match the
% duration of rating (180 s). I suspect "post"-HR-triggering from the
% looking at the timing of BP measures, but the "true" trigger cannot be
% determined>> Excluded.
%
% 109: Subj 55, Session 1:
% Two HR triggers in close (31 s) succession that do not match the
% duration of rating (180 s). True "first" trigger cannot be
% determined>> Excluded.
% 
for i=[82,109]
    dfl.dfraw{i}.triggers=NaN(size(dfl.dfraw{i}.triggers));
    dfl.dfraw{i}.HR=NaN(size(dfl.dfraw{i}.HR));
end                                             
%% Correct recordings with three triggers
% Delete superfluous (pre-term) first trigger (start of session triggered
% twice)
for i=[23,41,53,114]
    t=find(dfl.dfraw{i}.triggers);
    dfl.dfraw{i}.triggers(t(1))=0;
end
% Delete superfluous (pre-term) last trigger (end of session triggered
% twice)
for i=[40,82,109]
    t=find(dfl.dfraw{i}.triggers);
    dfl.dfraw{i}.triggers(t(1))=0;
end                       
%% #For sessions with 4 triggers >> Split, in first and second session
% Gerrit forgot to pause recordings inbetween sessions. Splitting half-way
% solves the issue (double-checked for every case).
for i=[29,61,65,67,69,83,103,147,237]
    n=length(dfl.dfraw{i}.triggers);
    dfl.dfraw{i+1}=dfl.dfraw{i}(round(n/2):end,:);
    dfl.dfraw{i}=dfl.dfraw{i}(1:round(n/2),:);
end
%% Check number of triggers and duration of epochs between triggers
for i=1:length(dfl.dfraw)
    if ~isempty(dfl.dfraw{i})
        dfl.ntriggers(i)=sum(dfl.dfraw{i}.triggers);
    end
end
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

% Plots to check for outliers
figure
hist(dfl.time_of_last_bp_before_CPT)
title('Time from last bp before CPT to pre-trigger')

figure
hist(dfl.time_of_last_bp_after_CPT)
title('Time from post-trigger to next bp after CPT ')
%% Approximate correction for deviation of MATLAB time and HR monitor time
% For sessions with two triggers on the monitor, triggger 2 should be very
% close in time to the end of pain rating (datetime_CPT_filetime).
% The monitor time was fairly aligned in the beginning of measurements but
% was running on a battery... time drifted over the course of measurements

% Create synchronized version of trigger_times for better comparability
% via linear regression.
y=datenum(dfl.datetime_CPT_filetime);
X=datenum(dfl.trigger_time_2);
glm_timeshift = fitglm(X,y);

% Add corrected datetime to all HR time-courses
for i=1:length(dfl.dfraw)
   	if ~isempty(dfl.dfraw{i})
        timenew=glm_timeshift.predict(datenum(dfl.dfraw{i}.datetime));
        dfl.dfraw{i}.datetime_corr=datetime(datestr(timenew));
    end
end

% Create trigger_time_2_sync
y_new=glm_timeshift.predict();
dfl.trigger_time_2_sync=NaT(height(dfl),1);
dfl.trigger_time_2_sync(~isnan(y_new))=datetime(datestr(y_new(~isnan(y_new))),'Format','default');
figure(1)
subplot(1,2,1)
plot(timeofday(dfl.datetime_CPT_filetime),timeofday(dfl.trigger_time_2),'.')
xlabel('CPT endtime');
ylabel('trigger time 2');
subplot(1,2,2)
plot(timeofday(dfl.datetime_CPT_filetime)-timeofday(dfl.trigger_time_2),'.')
xlabel('Subject NO');
ylabel('CPT endtime - trigger time 2');

title('Time of day MATLAB vs Monitor')

figure(2)
subplot(1,2,1)
plot(timeofday(dfl.datetime_CPT_filetime),timeofday(dfl.trigger_time_2_sync),'.')
xlabel('CPT endtime');
ylabel('trigger time 2 synced');
subplot(1,2,2)
plot(timeofday(dfl.datetime_CPT_filetime)-timeofday(dfl.trigger_time_2_sync),'.')
xlabel('Subject NO');
ylabel('CPT endtime - trigger time 2 synced');
title('Time of day MATLAB vs Monitor (synchronized')

% Create trigger_time_1_sync
y_new=glm_timeshift.predict(datenum(dfl.trigger_time_1));
dfl.trigger_time_1_sync=NaT(height(dfl),1);
dfl.trigger_time_1_sync(~isnan(y_new))=datetime(datestr(y_new(~isnan(y_new))),'Format','default');

% Create difference between Rating and HR duration
dfl.maxtime_HR=dfl.trigger_time_2-dfl.trigger_time_1;
dfl.maxtime_diff=seconds(dfl.maxtime_HR)-dfl.maxtime;

%% Check for differences between maxtime (Rating) and maxtime(HR)
%Positive time differences are expected, as Gerrit pressed the HR-
%post-measurement trigger only after ending the rating. Negative
%differences indicate that HR recordings were shorter than the rating period,
%This is incompatible with the experimental time-course and indicates
%problems.
% figure(3)
% hist(dfl.maxtime_diff)
% title('Difference maxtime (Rating) minus maxtime (HR Monitor)')
% figure(4)
% hist(dfl.maxtime_diff)
% title('Difference maxtime (Rating) minus maxtime (HR Monitor), clean')
% After removing two outliers, the differences in Rating and HR times seem
% reasonable. >> As expected, HR times are a little longer. We can proceed
% with extracting the HR time-windows based on rating maxtime.
%% Plot files with more than two triggers >> Required once to hand-pick
%files for repair
% for i = find(dfl.ntriggers>2)'
% figure
% plot(dfl.dfraw{i}.datetime_corr,...
%     [dfl.dfraw{i}.HR,...
%      dfl.dfraw{i}.triggers*100]);
% title(sprintf('i=%d, subID=%d, sess=%d',i,dfl.subIDs_num(i),dfl.prepost(i)))
% hold on
% plot(dfl.dfraw{i}.datetime_corr,...
%     dfl.dfraw{i}.NBPS,'LineWidth',30);
% hold off
% end
%% Plot files with only one trigger >> Required once to hand-pick
%files for repair
% for i = find(dfl.ntriggers==1)'
% figure
% plot(dfl.dfraw{i}.datetime_corr,...
%     [dfl.dfraw{i}.HR,...
%      dfl.dfraw{i}.triggers*100]);
% title(sprintf('i=%d, subID=%d, sess=%d',i,dfl.subIDs_num(i),dfl.prepost(i)))
% hold on
% plot(dfl.dfraw{i}.datetime_corr,...
%     dfl.dfraw{i}.NBPS,'LineWidth',30);
% line([dfl.datetime_CPT_filetime(i)-seconds(dfl.maxtime(i)),...
%       dfl.datetime_CPT_filetime(i)],[100,100],'LineWidth',10);
% hold off
% end
% Fazit: In all cases where only one trigger was found in the HR records,
% these corresponded to "early triggers", indicating the start of CPT. This
% was confirmed by comparing (synced) trigger times with rating periods and
% by checking that they are placed between BP measurements.


%%  Extraction of timecourse
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
            i,dfl.subject_no(i),dfl.prepost(i))
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
        
        dfl.CPT_HR_mean_pre(i)=nanmean(dfl.CPT_HR_pre{i});
        dfl.CPT_HR_perc_BL{i}=(dfl.CPT_HR{i}./dfl.CPT_HR_mean_pre(i))'.*100;
        dfl.CPT_HR_max(i)=max(dfl.CPT_HR{i})';
    end
    end
end

dfl.CPT_HR_max_perc_BL=dfl.CPT_HR_max./dfl.CPT_HR_mean_pre.*100;

save df.mat dfl dfraw crf '-append'