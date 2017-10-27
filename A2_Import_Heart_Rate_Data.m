clear

%% Read heart_rate files
protfolder='../data_placebo_taste/heart_rate/';
dir_protfolder=dir(protfolder);
fnames={dir_protfolder.name};
fnames_trends=regexp(fnames,'^\d\d\d_\w_\w_\d-trends.txt','match');
fnames_trends=[fnames_trends{:}]';

fnames_xml_events=regexp(fnames,'^\d\d\d_\w_\w_\d.xml','match');
fnames_xml_events=[fnames_xml_events{:}]';

%% Get info from filename
fnameprts=regexp(fnames_trends,'^(\d\d\d)_(\w)_\w_(\d)-trends.txt','tokens');
subIDs=cellfun(@(x) x{1}{1},fnameprts,'UniformOutput',0);
sex=cellfun(@(x) x{1}{2},fnameprts,'UniformOutput',0);
prepost=cellfun(@(x) str2num(x{1}{3}),fnameprts,'UniformOutput',0);
prepost=[prepost{:}]';

subIDs_num=cellfun(@(x) str2num(x),subIDs);
%% Get HR and O2 saturation time-lines from files
format='%u%u%{HH:mm:ss}D%f%{MM/dd/uuuu}D%{HH:mm:ss}D%f%f%f%f%f%f%f%f%f%f%f%f';
%Read-in numeric outcomes as str first... have to replace missing data encoded as *** for NaN.
for i=1:length(fnames_trends)
    dfraw{i}=readtable(fullfile(protfolder,fnames_trends{i}),...
                       'Format',format,...
                       'Delimiter', '\t',...
                       'HeaderLines', 0,...
                       'ReadVariableNames', true,...
                       'TreatAsEmpty',{'***',''});
   dfraw{i}.datetime=dfraw{i}.DATE+timeofday(dfraw{i}.TIME);
   dfraw{i}.datetime.Format='default';
end

%% Clean tables
for i=1:length(dfraw)
    %Drop empty variables
    try dfraw{i}.PVC_min=[];
    end;
    try dfraw{i}.ARR=[];
    end;
    try dfraw{i}.x_Pace=[];
    end;
    try dfraw{i}.Var8=[];
    end;
    try dfraw{i}.Var9=[];
    end;
    try dfraw{i}.Var18=[];
    end;
    
    % Replace '***' with NaN
    %dfraw{i}(:,7:end)=strrep(dfraw{i}{:,7:end},'***','NaN')
end


%% Get xml markers
for i=1:length(fnames_xml_events)
    xmlraw{i}=xml2struct(fullfile(protfolder,fnames_xml_events{i}));
end

%% Extract trigger timing from xmls
for i=1:length(xmlraw)
    curr_events=xmlraw{i}.events.event;
    event_types=cellfun(@(x) x.eventClassStr.Text,curr_events,...
        'UniformOutput',0);
    man_event=strcmp(event_types,'MAN');   
    curr_man_events=curr_events(man_event);
    man_trigger_times{i}=cellfun(@(x) str2double(x.absTime.Text),...
                                curr_man_events);
end

%% Add trigger events to time-lines
for i=1:length(dfraw)
    dfraw{i}.triggers=ismember(dfraw{i}.JULIAN, man_trigger_times{i});
    
    if sum(dfraw{i}.triggers)>2
        fprintf('More than two triggers in dfraw %d, Subj %s Run %d.\n',...
            i,subIDs{i},prepost(i));
    elseif sum(dfraw{i}.triggers)==2
        %everything fine here
    elseif sum(dfraw{i}.triggers)==1
        fprintf('One trigger only in dfraw %d, Subj %s Run %d.\n',...
            i,subIDs{i},prepost(i));
    elseif sum(dfraw{i}.triggers)==0
        fprintf('No trigger in dfraw %d, Subj %s Run %d.\n',...
            i,subIDs{i},prepost(i));
    end
end

%% Export
dfraw=dfraw';
HR_df_raw=table(fnames_trends,fnames_xml_events,subIDs,subIDs_num,sex,prepost,dfraw)

save('HR_df_raw.mat','HR_df_raw')