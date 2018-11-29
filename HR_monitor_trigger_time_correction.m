function dfl_out=HR_monitor_trigger_time_correction(dfl)

%% Approximate correction for deviation of MATLAB time and HR monitor time
% For sessions with two triggers on the monitor, triggger 2 should be very
% close in time to the end of pain rating (datetime_CPT_filetime).
% The monitor time was fairly aligned in the beginning of the measurement periods but
% was running on a battery... time drifted over the course of measurements

% Create synchronized version of trigger_times for better comparability
% via linear regression.
y=datenum(dfl.datetime_CPT_end);
X=datenum(dfl.trigger_time_2);
glm_timeshift = fitlm(X,y,'RobustOpts','fair');

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
figure('Name','Before time-correction')
subplot(1,2,1)
plot(timeofday(dfl.datetime_CPT_end),timeofday(dfl.trigger_time_2),'.')
xlabel('Time: CPT end');
ylabel('Time: 2nd HR trigger');
title({'Time of record','CPT-MATLAB vs HR-Monitor'})

subplot(1,2,2)
plot(dfl.datetime_CPT_end,timeofday(dfl.datetime_CPT_end)-timeofday(dfl.trigger_time_2),'.')

maxtime=timeofday(dfl.datetime_CPT_end)-timeofday(dfl.trigger_time_2)
plot(dfl.datetime_CPT_end(dfl.prepost=='1'),maxtime(dfl.prepost=='1'),'.')
hold on
plot(dfl.datetime_CPT_end(dfl.prepost=='2'),maxtime(dfl.prepost=='2'),'.')
hold off

xlabel('Time: CPT end');
ylabel('Difference CPT end - 2nd HR trigger');
title({'Difference in time of record','CPT-MATLAB vs HR-Monitor'})

figure('Name','After time-correction')
subplot(1,2,1)
plot(timeofday(dfl.datetime_CPT_end),timeofday(dfl.trigger_time_2_sync),'.')
xlabel('Time: CPT end');
ylabel('Time: 2nd HR trigger (synced)');
title({'Time of record','CPT-MATLAB vs HR-Monitor (synced)'})
subplot(1,2,2)
plot(dfl.datetime_CPT_end,timeofday(dfl.datetime_CPT_end)-timeofday(dfl.trigger_time_2_sync),'.')
xlabel('Time: CPT end');
ylabel('Difference CPT end - 2nd HR trigger (synced)');
title({'Difference in time of record','CPT-MATLAB vs HR-Monitor (synchronized)'})

% Create trigger_time_1_sync
y_new=glm_timeshift.predict(datenum(dfl.trigger_time_1));
dfl.trigger_time_1_sync=NaT(height(dfl),1);
dfl.trigger_time_1_sync(~isnan(y_new))=datetime(datestr(y_new(~isnan(y_new))),'Format','default');

% Create difference between Rating and HR duration
dfl.maxtime_HR=dfl.trigger_time_2-dfl.trigger_time_1;
dfl.maxtime_diff=seconds(dfl.maxtime_HR)-dfl.maxtime;

dfl_out=dfl;