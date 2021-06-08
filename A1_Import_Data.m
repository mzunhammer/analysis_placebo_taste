clear

%% Read cold_pressor rating files
protfolder='../data_placebo_taste/cold_pressor_combined/';
dir_protfolder=dir(protfolder);
fnames={dir_protfolder.name};
fnames=regexp(fnames,'^\d\d\d_\w_\w_\d_\d\d\d\d\d\d_\d+.mat','match');
fnames=[fnames{:}]';

% Get info from filename
fnameprts=regexp(fnames,'^(\d\d\d)_(\w)_\w_(\d)_(\d\d\d\d\d\d_\d+).mat','tokens');
dfraw.subIDs=cellfun(@(x) x{1}{1},fnameprts,'UniformOutput',0);
dfraw.sex=cellfun(@(x) x{1}{2},fnameprts,'UniformOutput',0);
dfraw.prepost=cellfun(@(x) str2num(x{1}{3}),fnameprts,'UniformOutput',0);
dfraw.prepost=[dfraw.prepost{:}]';
dfraw.datetime_CPT_end=NaT(length(fnameprts),1);
for i = 1:length(fnameprts)
    try
        dfraw.datetime_CPT_end(i)= datetime(fnameprts{i}{1}{4},'InputFormat','ddMMyy_HHmm');
    catch
        dfraw.datetime_CPT_end(i)= datetime(fnameprts{i}{1}{4},'InputFormat','ddMMyy_HHmmss');
    end
end
%Unfortunately no exact daytime was saved in rating-results.
%As a proxy, file-creation time was extracted and is used
load /Users/matthiaszunhammer/Dropbox/Gerrit/data_placebo_taste/exact_rating_end_times.mat
dfraw.datetime_CPT_filetime=NaT(length(fnameprts),1);
dfraw.datetime_CPT_filetime(1:length(exacttimes))=exacttimes;
% Get data from files
for i=1:length(fnames)
    % To load all
    %dfraw.matdata{i,1}=load(fullfile(protfolder,fnames{i}));
    a=load(fullfile(protfolder,fnames{i}));
    dfraw.rating{i,1}=a.Results.Rating;
    dfraw.time{i,1}=a.Results.Time;
    
    if isfield(a.Results,'ratingTreatExpect')&&~isempty(a.Results.ratingTreatExpect)
        dfraw.treat_expect(i,1)=a.Results.ratingTreatExpect;
        dfraw.cursorini_treat_expect(i,1)=a.Results.IniCursorPosTreatExpect;
        dfraw.ratingdur_treat_expect(i,1)=a.Results.ratingDurTreatExpect;
    else
        dfraw.treat_expect(i,1)=NaN;
        dfraw.cursorini_treat_expect(i,1)=NaN;
        dfraw.ratingdur_treat_expect(i,1)=NaN;
    end

    if isfield(a.Results,'ratingTreatEfficacy')&&~isempty(a.Results.ratingTreatEfficacy)
        dfraw.treat_efficacy(i,1)=a.Results.ratingTreatEfficacy;
        dfraw.cursorini_treat_efficacy(i,1)=a.Results.IniCursorPosTreatEfficacy;
        dfraw.ratingdur_treat_efficacy(i,1)=a.Results.ratingDurTreatEfficacy;
    else
        dfraw.treat_efficacy(i,1)=NaN;
        dfraw.cursorini_treat_efficacy(i,1)=NaN;
        dfraw.ratingdur_treat_efficacy(i,1)=NaN;
    end
    
    if  isfield(a.Results,'ratingTreatTasteVal')&&~isempty(a.Results.ratingTreatTasteVal)
        dfraw.taste_valence(i,1)=a.Results.ratingTreatTasteVal;
        dfraw.cursorini_taste_valence(i,1)=a.Results.IniCursorPosTreatTasteVal;
        dfraw.ratingdur_taste_valence(i,1)=a.Results.ratingDurTreatTasteVal;
    else
        dfraw.taste_valence(i,1)=NaN;
        dfraw.cursorini_taste_valence(i,1)=NaN;
        dfraw.ratingdur_taste_valence(i,1)=NaN;
    end
    
    if  isfield(a.Results,'ratingTreatTasteInt')&&~isempty(a.Results.ratingTreatTasteInt)
        dfraw.taste_intensity(i,1)=a.Results.ratingTreatTasteInt;
        dfraw.cursorini_taste_intensity(i,1)=a.Results.IniCursorPosTreatTasteInt;
        dfraw.ratingdur_taste_intensity(i,1)=a.Results.ratingDurTreatTasteInt;
    else
        dfraw.taste_intensity(i,1)=NaN;
        dfraw.cursorini_taste_intensity(i,1)=NaN;
        dfraw.ratingdur_taste_intensity(i,1)=NaN;
    end
end

% Get maximum matrix size for ratings
max_len_rating=max(cellfun(@length, dfraw.rating));
max_len_time=max(cellfun(@length, dfraw.time));

assert(max_len_rating==max_len_time,...
       'ERROR: Longest rating array is not equal to longest time array.' )
    
% Define maximum length of data, fill rest with NaNs
dfraw.ratingfull=NaN(length(dfraw.rating),max_len_rating);
dfraw.timefull=NaN(length(dfraw.time),max_len_rating);
% Fill all rating and time data into maximum length array
for i=1:length(dfraw.rating)
    dfraw.ratingfull(i,1:length(dfraw.rating{i}))=dfraw.rating{i};
    dfraw.timefull(i,1:length(dfraw.time{i}))=dfraw.time{i};
end

%Clip end of matrices by 4 epochs to account for minor inequalities in the number of
%sampling intervals/3 minutes
dfraw.ratingfull=dfraw.ratingfull(:,1:end-4);
dfraw.timefull=dfraw.timefull(:,1:end-4);

%Clip end of matrices by 4 epochs to account for minor inequalities in the number of
%sampling intervals/3 minutes
dfraw.ratingfull(:,1)=0; % sometimes the very first epoch recorded a non-null signal that immediately returned to 0 (the actual start position of all measurements)


% Correction of User-Error
% Participant 278 had the slider at 100 for the first seconds of
% CPT testing, before setting to 0 (both sessions).
dfraw.ratingfull((cellfun(@(x) strcmp(x,'278'),dfraw.subIDs)&(dfraw.prepost==1)),1:50)=0;
dfraw.ratingfull((cellfun(@(x) strcmp(x,'278'),dfraw.subIDs)&(dfraw.prepost==2)),1:10)=0;

% Create a vector of full rating data where NaNs are filled with 100
dfraw.ratingfull100=dfraw.ratingfull;
dfraw.ratingfull100(isnan(dfraw.ratingfull))=100;

% Summarize time in s across measurement timepoints
dfraw.timemean=nanmean(dfraw.timefull);

%% Read post-treatment rating files
% Note that from participant 139 on these ratings were saved in the same.
% mat as the CPT ratings.
protfolder2='../data_placebo_taste/post_treatment_on_screen_questions/';
dir_protfolder2=dir(protfolder2);
fnames2={dir_protfolder2.name};
fnames2=regexp(fnames2,'^\d\d\d_\w_\w_\d\d\d\d\d\d_\d+.mat','match');
fnames2=[fnames2{:}]';

% Get info from filename
fnameprts=regexp(fnames2,'^(\d\d\d)_(\w)_\w_(\d\d\d\d\d\d_\d+).mat','tokens');
dfraw2.subIDs=cellfun(@(x) x{1}{1},fnameprts,'UniformOutput',0);
dfraw2.sex=cellfun(@(x) x{1}{2},fnameprts,'UniformOutput',0);
dfraw2.datetime_VAS_end=cellfun(@(x) datetime(x{1}{3},'InputFormat','ddMMyy_HHmm'),fnameprts,'UniformOutput',0);
dfraw2.datetime_VAS_end=[dfraw2.datetime_VAS_end{:}]';

% Get data from files
for i=1:length(fnames2)
    a=load(fullfile(protfolder2,fnames2{i}));
    dfraw2.treat_efficacy(i,1)=a.Results.ratingTreatEff;
    dfraw2.taste_intensity(i,1)=a.Results.ratingTasteInt;
    dfraw2.taste_valence(i,1)=a.Results.ratingTasteVal;
    
    dfraw2.cursorini_treat_efficacy(i,1)=a.Results.IniCursorPosTreatEff;
    dfraw2.cursorini_taste_intensity(i,1)=a.Results.IniCursorPosTasteInt;
    dfraw2.cursorini_taste_valence(i,1)=a.Results.IniCursorPosTasteVal;
    
    dfraw2.ratingdur_treat_efficacy(i,1)=a.Results.ratingDurTreatEff;
    dfraw2.ratingdur_taste_intensity(i,1)=a.Results.ratingDurTasteInt;
    dfraw2.ratingdur_taste_valence(i,1)=a.Results.ratingDurTasteVal;
end


%% Read treatment group allocation from randomization, add to raw df
randomlist_path='../data_placebo_taste/Randomisierung_Gerrit_und_Max_Geschmacksstudie_Final.xlsx';
[ndata, ~, ~] = xlsread(randomlist_path);
xlsID=ndata(:,1);
treat=ndata(:,2);
treat(isnan(treat))=-1; % 0:No treatment, 1: no taste, 2: bitter, 3: sweet
treat=treat+1;

for i=1:length(dfraw.subIDs)
    currID=str2num(dfraw.subIDs{i});
    dfraw.treat(i,1)=treat(xlsID==currID);
end

%% Read demografic/crf/questionnaire data
crfdata_path='../data_placebo_taste/case_report_forms_combined.xlsx';
crf=readtable(crfdata_path,...
          'sheet',2,...
          'ReadVariableNames',true);

%% Read side-effects data
UAW_data_path='../data_placebo_taste/side_effects_combined.xlsx';
UAW=readtable(UAW_data_path,...
          'sheet',1,...
          'ReadVariableNames',true);
UAW.sumUAW=sum(UAW{:,5:end},2);
UAW.subject_no=categorical(UAW.subject_no);

%% Create long df (dfl) from raw imports (pain ratings)
subject_no=categorical(cellfun(@str2num,dfraw.subIDs));

prepost=categorical(dfraw.prepost);
treat=categorical(dfraw.treat);

% Resample time-courses to 180 seconds and as cells
% dfl.rating180=num2cell(resample(dfraw.ratingfull100',1,10)',2);

% Note that the resampling can introduce values slightly below 0 or above
% 100!
rating180=cell(size(subject_no));
rating180_full=cell(size(subject_no));
for i = 1:length(subject_no)
    disp(i)
    x=dfraw.ratingfull100(i,:);
    t=dfraw.timefull(i,:);
    [r_w_nan,r_w_100]=resample_CPT(x,t,180,1);
    rating180{i}=r_w_nan';
    rating180_full{i}=r_w_100';
end

%For AUC and Mean rating, the mean has to be taken across the maximum time interval(3
%min) with max rating (100) imputed instead of NaN for subjects that aborted testing.
%ACHTUNG: ratingfull fills with NaNs ratingfull100 with max-ratings!!
maxtime=cellfun(@max, dfraw.time);
meanrating=cellfun(@nanmean,rating180);

aucrating_perc=cellfun(@nanmean,rating180_full); % same nansum(rating180_full)/max_aucrating100
aucrating_perc90=cellfun(@(x) nanmean(x(90:end)),rating180_full); % same nansum(rating180_full)/max_aucrating100

% Alternatively calculate from raw, non-re-sampled data
%aucrating=cellfun(@(x,y) trapz(x,y),dfraw.time,dfraw.rating);
%aucrating100=trapz(dfraw.ratingfull100,2); % same as meanrating100=mean(dfraw.ratingfull100,2);
%max_aucrating100=length(dfraw.ratingfull100)*100;
%aucrating_perc=aucrating100/max_aucrating100*100;

meanratingbaseline=meanrating;
datetime_CPT_end=dfraw.datetime_CPT_end;
datetime_CPT_filetime=dfraw.datetime_CPT_filetime;

treat_expect=dfraw.treat_expect;
cursorini_treat_expect=dfraw.cursorini_treat_expect;
ratingdur_treat_expect=dfraw.ratingdur_treat_expect;

% Note: Treat efficacy & taste ratings were saved in separate .mat files
% for participants 1-138 and in the same file as post-treatment CPT
% afterwards. 
treat_efficacy=dfraw.treat_efficacy;
taste_intensity=dfraw.taste_intensity;
taste_valence=dfraw.taste_valence;

cursorini_treat_efficacy=dfraw.cursorini_treat_efficacy;
cursorini_taste_intensity=dfraw.cursorini_taste_intensity;
cursorini_taste_valence=dfraw.cursorini_taste_valence;

ratingdur_treat_efficacy=dfraw.ratingdur_treat_efficacy;
ratingdur_taste_intensity=dfraw.ratingdur_taste_intensity;
ratingdur_taste_valence=dfraw.ratingdur_taste_valence;

dfl1=table(subject_no,...
    prepost,...
    treat,...
    maxtime,...
    rating180,...
    rating180_full,...
    meanrating,...
    aucrating_perc,...
    aucrating_perc90,...
    datetime_CPT_end,...
    datetime_CPT_filetime,...
    treat_expect,...
    cursorini_treat_expect,...
    ratingdur_treat_expect,...
    treat_efficacy,...
    taste_intensity,...
    taste_valence,...
    cursorini_treat_efficacy,...
    cursorini_taste_intensity,...
    cursorini_taste_valence,...
    ratingdur_treat_efficacy,...
    ratingdur_taste_intensity,...
    ratingdur_taste_valence);

%For participant 139 onwards the stimulation script also posted
% treatment-intensity, -expectations and -valence ratings for participants in the non-treatment
% group, also. For these sessions the experimenter entered nonsensical values to
% continue the experiment.
dfl1.treat_efficacy(dfl1.treat=="0")=NaN;
dfl1.taste_intensity(dfl1.treat=="0")=NaN;
dfl1.taste_valence(dfl1.treat=="0")=NaN;
%% Create long df (dfl) from raw imports (post-treatment ratings)
subject_no=categorical(cellfun(@str2num,dfraw2.subIDs));

prepost=categorical(repmat(2,size(subject_no)));

treat_efficacy=dfraw2.treat_efficacy;
taste_intensity=dfraw2.taste_intensity;
taste_valence=dfraw2.taste_valence;

cursorini_treat_efficacy=dfraw2.cursorini_treat_efficacy;
cursorini_taste_intensity=dfraw2.cursorini_taste_intensity;
cursorini_taste_valence=dfraw2.cursorini_taste_valence;

ratingdur_treat_efficacy=dfraw2.ratingdur_treat_efficacy;
ratingdur_taste_intensity=dfraw2.ratingdur_taste_intensity;
ratingdur_taste_valence=dfraw2.ratingdur_taste_valence;

datetime_VAS_end=dfraw2.datetime_VAS_end;

dfl2=table(subject_no,...
    prepost,...
    treat_efficacy,...
    taste_intensity,...
    taste_valence,...
    cursorini_treat_efficacy,...
    cursorini_taste_intensity,...
    cursorini_taste_valence,...
    ratingdur_treat_efficacy,...
    ratingdur_taste_intensity,...
    ratingdur_taste_valence,...
    datetime_VAS_end);

%% Join dfl with crf data
crf.subject_no=categorical(crf.subject_no);
crf.handedness=categorical(crf.handedness);
crf.bmi=crf.body_weight_in_kg./(crf.height_in_cm/100).^2;

dfl=join(dfl1,crf);

%% Join in post-testing ratings from first experiment
post_test_vars={'treat_efficacy'
'taste_intensity'
'taste_valence'
'cursorini_treat_efficacy'
'cursorini_taste_intensity'
'cursorini_taste_valence'
'ratingdur_treat_efficacy'
'ratingdur_taste_intensity'
'ratingdur_taste_valence'};

dfl=outerjoin(dfl,dfl2,'key',{'subject_no','prepost'},...
                       'Type','left',...
                       'MergeKeys',true,...
                       'RightVariables',post_test_vars);

for i=1:length(post_test_vars)
    a=dfl{:,[post_test_vars{i},'_dfl']};
    b=dfl{:,[post_test_vars{i},'_dfl2']};
    a(isnan(a))=b(isnan(a));
    dfl(:,post_test_vars{i})=table(a);
    dfl(:,[post_test_vars{i},'_dfl'])=[];
    dfl(:,[post_test_vars{i},'_dfl2'])=[];
end

dfl.taste_valence=dfl.taste_valence-50; % 101pt VAS with "neutral" at 50 >> to obtain intuitive positive and negative values

%% Blood pressure data were recorded before and after each CPT
% have to be merged or will be present in duplicate form:
dfl.SYS_before_CPT=NaN(height(dfl),1);
dfl.SYS_after_CPT=NaN(height(dfl),1);
dfl.DIA_before_CPT=NaN(height(dfl),1);
dfl.DIA_after_CPT=NaN(height(dfl),1);

dfl.SYS_before_CPT(dfl.prepost=='1')=dfl.SYS_before_pre_treat_CPT(dfl.prepost=='1');
dfl.SYS_before_CPT(dfl.prepost=='2')=dfl.SYS_before_post_treat_CPT(dfl.prepost=='2');
dfl.SYS_after_CPT(dfl.prepost=='1')=dfl.SYS_after_pre_treat_CPT(dfl.prepost=='1');
dfl.SYS_after_CPT(dfl.prepost=='2')=dfl.SYS_after_post_treat_CPT(dfl.prepost=='2');
dfl.DIA_before_CPT(dfl.prepost=='1')=dfl.DIA_before_pre_treat_CPT(dfl.prepost=='1');
dfl.DIA_before_CPT(dfl.prepost=='2')=dfl.DIA_before_post_treat_CPT(dfl.prepost=='2');
dfl.DIA_after_CPT(dfl.prepost=='1')=dfl.DIA_after_pre_treat_CPT(dfl.prepost=='1');
dfl.DIA_after_CPT(dfl.prepost=='2')=dfl.DIA_after_post_treat_CPT(dfl.prepost=='2');

dfl.SYS_before_pre_treat_CPT=[];
dfl.SYS_after_pre_treat_CPT=[];
dfl.SYS_before_post_treat_CPT=[];
dfl.SYS_after_post_treat_CPT=[];
dfl.DIA_before_pre_treat_CPT=[];
dfl.DIA_after_pre_treat_CPT=[];
dfl.DIA_before_post_treat_CPT=[];
dfl.DIA_after_post_treat_CPT=[];
%% Join dfl with UAW sumscore
UAW_sum=UAW(:,{'subject_no','sumUAW'});
dfl=join(dfl,UAW_sum,'Keys',{'subject_no'});

%% Additional variables:
% Add (sub-)study as a variable
dfl.study=zeros(size(dfl.subject_no));
dfl.study(double(dfl.subject_no)<=138)=1;
dfl.study((double(dfl.subject_no)>138 & double(dfl.subject_no)<=168))=2;
dfl.study(double(dfl.subject_no)>168)=3;
dfl.study=categorical(dfl.study);

% Lab-time variables to check for deviations from  experimental schedule
dfl.lab_time_before_pre_treat_CPT=(dfl.time_pre_treat_CPT-dfl.arrival_time)*24*60;
dfl.lab_time_before_post_treat_CPT=(dfl.time_post_treat_CPT-dfl.arrival_time)*24*60;
dfl.waiting_time=(dfl.time_post_treat_CPT-dfl.time_drug_administration)*24*60;
dfl.between_cpt_time=(dfl.time_post_treat_CPT-dfl.time_pre_treat_CPT)*24*60;

dfl.lab_time_since_arrival(dfl.prepost=="1")=dfl.lab_time_before_pre_treat_CPT(dfl.prepost=="1");
dfl.lab_time_since_arrival(dfl.prepost=="2")=dfl.lab_time_before_post_treat_CPT(dfl.prepost=="2");

%% Add COMT Genetic data
COMT_list_path='../data_placebo_taste/COMT_Genotyping_rs4680_Bingel_SchmerzGU.xlsx';
[~, comtraw, ~] = xlsread(COMT_list_path);
COMT_ID=cellfun(@(x) regexp(x,'^(\d+)','tokens'),comtraw(2:end,1));
COMT_ID=categorical([COMT_ID{:}]');
COMT_genotype=categorical(comtraw(2:end,5));
COMT_genotype(~ismember(COMT_genotype,{'AG';'AA';'GG';'GA'}))='unknown';
COMT_genotype=removecats(COMT_genotype);
comt=table(COMT_ID,COMT_genotype);
dfl=outerjoin(dfl,comt,'LeftKeys',{'subject_no'},'RightKeys',{'COMT_ID'});

%% Add Questionnaire Data
df_questionnaire=A4_Import_Questionnaire_Data('../data_placebo_taste/daten_GUpain.txt');
dfl=outerjoin(dfl,df_questionnaire,...
        'Type','left',...
        'MergeKeys',false,...
        'LeftKeys','subject_no','RightKeys','participant_no');
save df.mat dfl dfraw crf df_questionnaire